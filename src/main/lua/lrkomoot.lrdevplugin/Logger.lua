---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Dieter Stockhausen.
--- DateTime: 06.05.21 12:44
---
local LrLogger = import("LrLogger")
local _logger = LrLogger("KomootLrLogger")
_logger:enable("logfile")
local enabled = true
-------------------------------------------------------------------------------
local logger = {}
-------------------------------------------------------------------------------
function logger.trace(msg)
    if (enabled) then
        _logger:trace(msg)
    end
end
-------------------------------------------------------------------------------
return logger