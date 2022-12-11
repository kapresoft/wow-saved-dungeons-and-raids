local ns = SDNR_Namespace(...)
local O, LibStub, M = ns:LibPack()
local AceConsole = O.AceConsole
local GC = O.GlobalConstants

local L = ns.LibStub:NewLibrary(M.Wrapper)
local mt = {
    __tostring = ns.ToStringFunction(M.Wrapper)
}
setmetatable(L, mt)
AceConsole:Embed(L)

L:Printf('loaded...')
L:Printf('Table is: %s', type(ns.O.Table))
