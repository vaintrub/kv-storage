#!/usr/bin/env tarantool

local tap = require('tap')
local fio = require('fio')
local http_lib = require('http.lib')
local http_client = require('http.client')
local json = require('json')

local test = tap.test("http")
test:plan(4)

test:test("POST method", function(test)
    test:plan(6)
    local r = http_client.request(
            'POST', 
            'http://localhost:8080/', 
            '{"key": "Cities", "value": ["Moscow", "Kazan", "Omsk"]}', 
        {})
    test:is(r.status, 200, 'Ok')
end)

test:test("GET method", function(test)
    test:plan(6)
    local r = http_client.request(
            'POST', 
            'http://localhost:8080/', 
            '{"key": "Cities", "value": ["Moscow", "Kazan", "Omsk"]}', 
        {})
    test:is(r.status, 200, 'Ok')

end)

test:test("PUT method", function(test)
    test:plan(6)
    local r = http_client.request(
            'POST', 
            'http://localhost:8080/', 
            '{"key": "Cities", "value": ["Moscow", "Kazan", "Omsk"]}', 
        {})
end)

test:test("DELETE method", function(test)
    test:plan(6)
    test:plan(6)
    local r = http_client.request(
            'POST', 
            'http://localhost:8080/', 
            '{"key": "Cities", "value": ["Moscow", "Kazan", "Omsk"]}', 
        {})
end)



os.exit(test:check() == true and 0 or 1)
