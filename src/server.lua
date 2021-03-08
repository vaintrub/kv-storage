#!/usr/bin/env tarantool

local http_router = require('http.router')
local http_server = require('http.server')
local json = require('json')
local log = require('log')

box.cfg{
	log = './server.log'
}

box.once('schema', 
	function()
		box.schema.create_space('kv-storage',
			{ 
				format = {
					{ name = 'key';   type = 'string' },
					{ name = 'value'; type = '*' },
				};
				if_not_exists = true;
			}
		)
		box.space.kv_storage:create_index('primary', 
			{ type = 'hash'; parts = {1, 'string'}; if_not_exists = true; }
		)
	end
)

local httpd = http_server.new('127.0.0.1', 8080, {
    log_requests = true,
    log_errors = true
})
local router = http_router.new()

-- Creating routes
router:route({method = 'POST', path = '/kv'}, create_tuple)
router:route({method = 'PUT', path = '/kv/:key'}, update_tuple)
router:route({method = 'GET', path = '/kv/:key'}, get_tuple)
router:route({method = 'DELETE', path = '/kv/:key'}, delete_tuple)

local function create_tuple(req)
    local status_code = 200
    -- TODO catch exception
    body = json.decode(req)

    -- Validating body
	if ( body['key'] == nil or body['value'] == nil or type(body) == 'string' ) then
		status_code = 400
	end
    -- Check for existing key
    local key = body['key']
	local tuple_already_exist = box.space.kv_storage:select(key)
	if ( table.getn(tuple_already_exist) ~= 0 ) then
		status_code = 409
	end
	
	box.space.kv_storage:insert{ key, body['value'] }

    return {status = status_code}
end

local function update_tuple(req)
    local status_code = 200
    local body = json.decode(req)
	local key = req:stash('key')

	if ( type(body) == 'string'  or body['value'] == nil or key == nil ) then
        status_code = 400
	end

	local tuple = box.space.kv_storage:select{ key }
	if( table.getn( tuple ) == 0 ) then
		status_code = 404
	end

	local tuple = box.space.kv_store:update({key}, {{'=', 2, body['value']}})

    return {status = status_code}
end

local function get_tuple(req)
    local status_code = 200
    local key = req:stash('key')

    local tuple = box.space.kv_storage:select{ key }
	if( table.getn( tuple ) == 0 ) then
        status_code = 404
	end

    return {status = status_code}
end

local function delete_tuple(req)
	status_code = 200
    local key = req:stash('key')

	local tuple = box.space.kv_storage:select(key)
	if( table.getn( tuple ) == 0 ) then
		status_code = 404
	end

	box.space.kv_store:delete{ key }
    return {status = status_code}
end


httpd:set_router(router)
httpd:start()
