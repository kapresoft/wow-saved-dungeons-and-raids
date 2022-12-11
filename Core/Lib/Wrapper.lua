local ns = SDNR_Namespace(...)
local O, LibStub = ns:LibPack()
local sformat = string.format
local AceConsole = O.AceConsole
local GC = O.GlobalConstants

local L = LibStub:NewLibrary(GC:LibName('Wrapper'), 1)
local mt = {
    __tostring = function() return sformat('{{%s::%s}}', ns.name, 'Wrapper')  end
}
setmetatable(L, mt)
AceConsole:Embed(L)

L:Printf('loaded...')