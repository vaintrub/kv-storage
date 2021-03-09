#  Key-value storage accessible by http
##  What is it?
This is a key-value storage using Tarantool

## 📚 Technologies
This project is powered by Lua.

## ✌️ API
Path | Method | Body (json) | Description
--- | --- | --- | --- 
/kv | POST | ```{"key": "Your key", "value": some json } ``` | Add a new tuple in database
/kv/:key | GET |  | Select tuple by key
/kv/:key | DELETE | | Delete tuple if key was in the database
/kv/:key | PUT | ```{ "value": some json} ``` | Update new pair if the key was in the database

## 📝 Deployment
### Docker

## ☑️ TODO
- [ ] ...
- [x] ... 
- [ ] ...
- [ ] ...

## Keywords
  - [Tarantool](https://www.tarantool.io/en/)
  - [Lua](https://www.lua.org)
  - [Docker](https://hub.docker.com/r/ax4docker/ax_tarantool)


### Installation

### Application launch
