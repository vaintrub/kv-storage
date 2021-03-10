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

local httpd = http_server.new('0.0.0.0', PORT, {
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

-- Controllers:

local function create_tuple(req)
    local body = decode_body_json(req)
    -- Validating body
    if ( body == nil or body['key'] == nil or body['value'] == nil or type(body) == 'string' ) then
        return error_resp(req, "Invalid body", 400)
    end

    local key = body['key']
    local status, err = pcall(function() box.space.kv:insert{ key, body['value'] } end)
    -- Checking for existing tuple
    if ( not status ) and ( err:unpack().code == box.error.TUPLE_FOUND ) then
        return error_resp(req, "The key '"..key.."' already exists", 409)
    end
    return {status = 200, body = "OK"}
end

local function update_tuple(req)
    local body = decode_body_json(req)
    local key = req:stash('key')
    
    if ( type(body) == 'string'  or body['value'] == nil or key == nil ) then
        return error_resp(req, "Invalid body", 400)
    end

    local tuple = box.space.kv:update({key}, {{'=', 2, body['value']}})
    if tuple == nil then
        return error_resp(req, "The key '"..key.."' not found", 404)
    end

    return {status = 200, body = "OK"}
end

local function get_tuple(req)
    local key = req:stash('key')
    local tuple = box.space.kv:select{ key }
    if( table.getn( tuple ) == 0 ) then
        return error_resp(req, "The key '"..key.."' not found", 404)
    end

    return {status = 200, body = json.encode(unpack(tuple))}
end

local function delete_tuple(req)
    local key = req:stash('key')
    local tuple = box.space.kv:delete{ key }
    -- Storage vinyl engine always returns nil,
    -- but my web app doesn't work with it
    if( tuple == nil ) then
        return error_resp(req, "The key '"..key.."' not found", 404)
    end
    return {status = 200, body = "OK"}
end



-- Creating routes
router:route({method = 'POST', path = '/kv'}, create_tuple)
router:route({method = 'PUT', path = '/kv/:key'}, update_tuple)
router:route({method = 'GET', path = '/kv/:key'}, get_tuple)
router:route({method = 'DELETE', path = '/kv/:key'}, delete_tuple)

httpd:set_router(router)
httpd:start()
