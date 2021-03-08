#!/usr/bin/env tarantool

local tap = require('tap')
local http_client = require('http.client')
local json = require('json')

local test = tap.test("server")
test:plan(1)

test:test("POST method", function(test)
    test:plan(1)
    local options = 
    { 
        ["headers"] = 
        {
            ['Content-Type'] = 'application/json; charset=utf-8'
        }
    }
    local r = http_client.request('POST', 'http://localhost:8080/kv/', "{'key': 42, 'value': 'lol'}", options)
    test:is(r.status, 200, 'OK')
end)

--test:test("GET method", function(test)
--    test:plan(6)
--    local r = http_client.request(
--            'POST', 
--            'http://localhost:8080/', 
--            '{"key": "Cities", "value": ["Moscow", "Kazan", "Omsk"]}', 
--        {})
--    test:is(r.status, 200, 'Ok')
--
--end)
--
--test:test("PUT method", function(test)
--    test:plan(6)
--    local r = http_client.request(
--            'POST', 
--            'http://localhost:8080/', 
--            '{"key": "Cities", "value": ["Moscow", "Kazan", "Omsk"]}', 
--        {})
--end)
--
--test:test("DELETE method", function(test)
--    test:plan(6)
--    test:plan(6)
--    local r = http_client.request(
--            'POST', 
--            'http://localhost:8080/', 
--            '{"key": "Cities", "value": ["Moscow", "Kazan", "Omsk"]}', 
--        {})
--end)



os.exit(test:check() == true and 0 or 1)
