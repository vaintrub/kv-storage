#  Key-value storage accessible by http
##  What is it?
This is a key-value storage using Tarantool
## DEMO
The application is deployed to http://kv-storage-tarantool.site/

## 📚 Technologies
This project is powered by Lua.
Also used:
- Nginx
- Docker
- Tarantool

## ✌️ API
Path | Method | Body (json) | Description
--- | --- | --- | --- 
/kv | POST | ```{"key": "Your key", "value": some json } ``` | Add a new tuple in database
/kv/:key | GET |  | Select tuple by key
/kv/:key | DELETE | | Delete tuple if key was in the database
/kv/:key | PUT | ```{ "value": some json} ``` | Update new pair if the key was in the database

### You can check the api with the following commands
```
curl -d '{"key":"Hello", "value": "World"}' -H "Content-Type: application/json" -X POST http://kv-storage-tarantool.site/kv

curl -X GET http://kv-storage-tarantool.site/kv/Hello

curl -d '{"value": "!"}' -H "Content-Type: application/json" -X PUT http://kv-storage-tarantool.site/kv/Hello

curl -X DELETE http://kv-storage-tarantool.site/kv/Hello
```

## 📝 Deployment
### Docker
1. Clone this repository
2. If you have docker-compose installed you can simply run:

```
cd kv-storage-tarantool
docker-compose build
docker-compose up -d
```
***Note:** tests will run automatically
## ☑️ TODO
- [ ] Add more tests
- [x] add dockerfils & nginx 

## Keywords
  - [Tarantool](https://www.tarantool.io/en/)
  - [Lua](https://www.lua.org)
  - [Docker](https://hub.docker.com/r/ax4docker/ax_tarantool)
