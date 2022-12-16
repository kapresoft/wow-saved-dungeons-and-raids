--[[-----------------------------------------------------------------------------
BaseLibraryObject
-------------------------------------------------------------------------------]]

---@class BaseLibraryObject
local BaseLibrary = {}
---@param o BaseLibraryObject
local function BaseLibraryMethods(o)
    ---@type table
    o.mt = { __tostring = function()  end }

    ---@type LoggerInterface
    o.logger = {}
end
BaseLibraryMethods(BaseLibrary)





