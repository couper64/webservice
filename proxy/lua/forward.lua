local pgmoon = require "pgmoon"

local db_conf = {
    host = "postgres", -- Matching the name of a service.
    port = "5432",
    database = "postgres",
    user = "postgres",
    password = "password", -- Matching the provided password.
}
local pg = pgmoon.new(db_conf)

local ok, err = pg:connect()
if not ok then
    ngx.log(ngx.ERR, "Postgres connection failed: ", err)
    return ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
end

local path = ngx.var.subpath  -- strip leading slash
path = ngx.escape_uri(path) -- Removes escaping characters but Lua encodes forward slashes (/) as %2F.
path = ngx.unescape_uri(path) -- Bring back %2F as forward slashes (/).
local res, err = pg:query("SELECT ip, port FROM forward WHERE path = '" .. path .. "' LIMIT 1")

if not res or #res == 0 then
    ngx.log(ngx.ERR, "No forward entry for path: ", path)
    return ngx.exit(ngx.HTTP_NOT_FOUND)
end

local ip = res[1].ip
local port = res[1].port
if not ip or not port then
    ngx.log(ngx.ERR, "Incomplete IP/port for path: ", path)
    return ngx.exit(ngx.HTTP_NOT_FOUND)
end

ngx.var.backend = ip .. ":" .. port

pg:keepalive()
