---
--- This is where external libraries are integrated into our local source
---
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local pformat = ns.Kapresoft_LibUtil.pformat
ns.pformat = pformat

local function CreateSimpleFormatter()

    ---@param t table
     local function objectToString(t)
        if type(t) ~= 'table' then return tostring(t) end
        local s = '{ '
        for k, v in pairs(t) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. objectToString(v) .. ','
        end
        return s .. '} '
    end
    local function pack(...) return { len = select("#", ...), ... } end

    --- @class SimpleFormat
    local o = {}

    function o:pformat(...)
        local args = pack(...)
        local str = ''
        for i = 1, args.len do str = str .. ' ' .. objectToString(args[i]) .. ' ' end
        print(str)
    end

    o.mt = { __call = function (_, ...) return o.pformat(o, ...) end }
    setmetatable(o, o.mt)

    return o
end

--[[-----------------------------------------------------------------------------
Pretty Formatter
-------------------------------------------------------------------------------]]

-- ## Functions ------------------------------------------------

---@param o PrettyPrintWrapped
local function PrettyPrintMethods(o)
    --- @type Kapresoft_LibUtil_PrettyPrint
    local pprint = Kapresoft_LibUtil.PrettyPrint

    --- @return PrettyPrintWrapped
    function o:Default()
        pprint.setup({ use_newline = true, wrap_string = false, indent_size=4, sort_keys=true, level_width=120, depth_limit = true,
                       show_all=false, show_function = false })
        return self;
    end
    ---no new lines
    --- @return PrettyPrintWrapped
    function o:D2()
        pprint.setup({ use_newline = false, wrap_string = false, indent_size=4, sort_keys=true, level_width=120, depth_limit = true,
                       show_all=false, show_function = false })
        return self;
    end

    ---Configured to show all
    --- @return PrettyPrintWrapped
    function o:A()
        pprint.setup({ use_newline = true, wrap_string = false, indent_size=4, sort_keys=true, level_width=120,
                       show_all=true, show_function = true, depth_limit = true })
        return self;
    end

    ---Configured to print in single line
    --- @return PrettyPrintWrapped
    function o:B()
        pprint.setup({ use_newline = false, wrap_string = true, indent_size=2, sort_keys=true,
                       level_width=120, show_all=true, show_function = true, depth_limit = true })
        return self;
    end

    --- @return string
    function o:pformat(obj, option, printer)
        local str = pprint.pformat(obj, option, printer)
        o:Default(o)
        return str
    end
    o.mt = { __call = function (_, ...) return o.pformat(o, ...) end }
    setmetatable(o, o.mt)
end

---### Syntax:
---```
--- // Default Setup without functions being shown
--- local str = pformat(obj)
--- local str = pformat:Default()(obj)
--- // Shows functions, etc.
--- local str = pformat:A():pformat(obj)
---```
local function InitPrettyPrint()
    --- @class PrettyPrintWrapped
    local o = { wrapped = pprint }
    pformat = pformat or o
    PrettyPrintMethods(o)
    ns.pformat = pformat
    return o
end

local nsk = ns.Kapresoft_LibUtil
if nsk and nsk.pformat then ns.pformat = nsk.pformat; return end
if (Kapresoft_LibUtil and Kapresoft_LibUtil.PrettyPrint) then ns.pformat = InitPrettyPrint(); return end

--- Fallback to a simple formatter
ns.pformat = CreateSimpleFormatter()
--ns.pformat(sformat("%s::External-Lib-Wrapper: %s", ns.name, "Failed to load PrettyFormat"))
