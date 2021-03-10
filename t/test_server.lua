#!/usr/bin/env tarantool

local tap = require('tap')
local http_client = require('http.client')
local json = require('json')

local test = tap.test("test-server")

local HOST = os.getenv('HOST')
if HOST == nil then
    HOST = "http://localhost:8080/"
end
local URL = HOST.."kv/"

test:plan(4)

test:diag("Testing key-value storage")

local testing_data = {
    key = "some_key",
    value = "some_value"
}
local test_body_json = json.encode(testing_data)
local expected_body_json = testing_data['value']
local test_put_body = json.encode({value = "another_val"})
local exp_invalid_body = json.encode({error = "Invalid body"})
local function exp_not_found_err(key)
    return json.encode({error = "The key '"..key.."' not found"})
end

local function test_cases(tests)
    local cnt_tests = table.getn(tests)
    test:plan(cnt_tests * 2)
    for i = 1, cnt_tests do
        local data = tests[i].data
        local name = tests[i].name
        local r = http_client.request(data['method'], data['url'], data['body'])
        test:is(r.status, data['expected_status'], name.."status")
        test:is(r.body, data['expected_body'], name.."body")
    end
end

test:test("POST method", function(test)
    local cases = {
        {
            name = "check POST method: ",
            data = {
                method = "POST",
                url = URL,
                body = test_body_json,
                expected_status = 200,
                expected_body = 'OK'
            }
        },
        {
            name = "check POST with existing key: ",
            data = {
                method = "POST",
                url = URL ,
                body = test_body_json,
                expected_status = 409,
                expected_body = json.encode({error = "The key '"..testing_data["key"].."' already exists"})
            }
        },
        {
            name = "check POST 'invalid body' error: ",
            data = {
                method = "POST",
                url = URL,
                body = "some_body",
                expected_status = 400,
                expected_body = exp_invalid_body
            }
        },
        {
            name = "check POST 'invalid body' error: ",
            data = {
                method = "POST",
                url = URL,
                body = json.encode({key = {}}),
                expected_status = 400,
                expected_body = exp_invalid_body             }
        }
    }
    test_cases(cases)
end)

test:test("GET method", function(test)
    local cases = {
        {
            name = "check GET method: ",
            data = {
                method = "GET",
                url = URL..testing_data['key'],
                body = "",
                expected_status = 200,
                expected_body = expected_body_json
            }
        },
        {
            name = "check GET not found key: ",
            data = {
                method = "GET",
                url = URL.."not_existing_key",
                body = "",
                expected_status = 404,
                expected_body = exp_not_found_err("not_existing_key")
            }
        }
    }
    test_cases(cases)
end)

test:test("PUT method", function(test)
    local cases = {
        {
            name = "check PUT method: ",
            data = {
                method = "PUT",
                url = URL..testing_data['key'],
                body = test_put_body,
                expected_status = 200,
                expected_body = "OK"
            }
        },
        {
            name = "check GET after PUT: ",
            data = {
                method = "GET",
                url = URL..testing_data['key'],
                body = "",
                expected_status = 200,
                expected_body = 'another_val'
            }
        },
        {
            name = "check PUT not found error: ",
            data = {
                method = "PUT",
                url = URL.."not_existing_key",
                body = test_put_body,
                expected_status = 404,
                expected_body = exp_not_found_err("not_existing_key")
            }
        },
        {
            name = "check PUT 'invalid body' error: ",
            data = {
                method = "PUT",
                url = URL..testing_data['key'],
                body = "some_body",
                expected_status = 400,
                expected_body = exp_invalid_body
            }
        }
    }
    test_cases(cases)

end)

test:test("DELETE method", function(test)
   local cases = {
        {
            name = "check DELETE method: ",
            data = {
                method = "DELETE",
                url = URL..testing_data['key'],
                body = "",
                expected_status = 200,
                expected_body = "OK"
            }
        },
        {
            name = "check DELETE not found error: ",
            data = {
                method = "DELETE",
                url = URL.."not_existing_key",
                body = "",
                expected_status = 404,
                expected_body = exp_not_found_err("not_existing_key")
            }
        },
        {
            name = "check GET 'not found' error: ",
            data = {
                method = "GET",
                url = URL..testing_data['key'],
                body = "",
                expected_status = 404,
                expected_body = exp_not_found_err(testing_data['key'])
            }
        }

    }
    test_cases(cases)
end)



os.exit(test:check() == true and 0 or 1)
