local M = {}
local C = {}

local ALLOWED_METHODS = { OPTIONS = true, GET = true, POST = true, PUT = true, DELETE = true }


function M.init(zone)
    local self = setmetatable({}, {__index = C})
    self.prometheus = require("prometheus").init(zone)

    self.requests = self.prometheus:counter(
        "nginx_http_requests_total", "Number of HTTP requests", {"method", "route", "port", "status", "host", "backend"})

    self.latency = self.prometheus:histogram(
        "nginx_http_request_duration_seconds", "HTTP request latency", {"method", "route", "port", "status", "host", "backend"})

    self.connections = self.prometheus:gauge(
        "nginx_http_connections", "Number of HTTP connections", {"state"})

    return self
end

function C:handle_request()
    local latency = ngx.now() - ngx.req.start_time()
    local method = ngx.var.request_method
    local route = ngx.var.prometheus_route
    local backend = ngx.var.prometheus_backend

    if not ALLOWED_METHODS[method] then
        method = "OTHER"
    end

    if route == "unknown" then
        method = ""
    end

    self.requests:inc(1, {method, route, ngx.var.server_port, ngx.var.status, ngx.var.host, backend})
    self.latency:observe(latency, {method, route, ngx.var.server_port, ngx.var.status, ngx.var.host, backend})
end

function C:collect()
    self.connections:set(ngx.var.connections_reading, {"reading"})
    self.connections:set(ngx.var.connections_waiting, {"waiting"})
    self.connections:set(ngx.var.connections_writing, {"writing"})
    return self.prometheus:collect()
end

return M
