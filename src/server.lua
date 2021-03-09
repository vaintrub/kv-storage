#!/usr/bin/env tarantool

local http_router = require('http.router')
local http_server = require('http.server')
local json = require('json')
local log = require('log')

local PORT = os.getenv('PORT')
if PORT == nil then
    PORT = 8080
end

box.cfg{
	log = './server.log'
}

box.once('init', 
	function()
		box.schema.space.create('kv',
			{ 
				format = {
					{ name = 'key',   type = 'string' },
					{ name = 'value'},
				};
			}
		)
		box.space.kv:create_index('primary', 
			{ 
                type = 'hash',
                parts = {'key'}
            }
		)
	end
)

local httpd = http_server.new('127.0.0.1', PORT, {
    log_requests = true,
    log_errors = true
})
local router = http_router.new()

-- Utils:
local function decode_body_json(req)
    local status, body = pcall(function() return req:json() end)
    log.info("REQUEST: %s %s", status, body)
    return body
end

local function error_resp(req, msg, status_code)
    local resp = req:render({json = {error = msg}})
    resp.status = status_code
    return resp
end

local function has_tuple(key)
    local value = box.space.kv:select({key})
    return (value ~= nil and next(value) ~= nil)
end

-- Controllers:

local function create_tuple(req)
    local body = decode_body_json(req)
    -- Validating body
	if ( body == nil or body['key'] == nil or body['value'] == nil or type(body) == 'string' ) then
        return error_resp(req, "Invalid body", 400)
    end

    local key = body['key']
	if ( has_tuple(key) ) then
        return error_resp(req, "The key '"..key.."' already exists", 409)
    else
        box.space.kv:insert{ key, body['value'] }
	end
    return {status = 200, body = "OK"}
end

local function update_tuple(req)
    local body = decode_body_json(req)
	local key = req:stash('key')
    
	if ( type(body) == 'string'  or body['value'] == nil or key == nil ) then
        return error_resp(req, "Invalid body", 400)
	end

	if( has_tuple(key)) then
        box.space.kv:update({key}, {{'=', 2, body['value']}})
    else
        return error_resp(req, "The key '"..key.."' not found", 404)
	end

    return {status = 200, body = "OK"}
end

local function get_tuple(req)
    local key = req:stash('key')

    local value = box.space.kv:select{ key }
	if( table.getn( value ) == 0 ) then
        return error_resp(req, "The key '"..key.."' not found", 404)
	end

    return {status = 200, body = json.encode(unpack(value))}
end

local function delete_tuple(req)
    local key = req:stash('key')

	if( not has_tuple(key) ) then
        return error_resp(req, "The key '"..key.."' not found", 404)
	end

	box.space.kv:delete{ key }
    return {status = 200, body = "OK"}
end



-- Creating routes
router:route({method = 'POST', path = '/kv'}, create_tuple)
router:route({method = 'PUT', path = '/kv/:key'}, update_tuple)
router:route({method = 'GET', path = '/kv/:key'}, get_tuple)
router:route({method = 'DELETE', path = '/kv/:key'}, delete_tuple)

httpd:set_router(router)
httpd:start()
