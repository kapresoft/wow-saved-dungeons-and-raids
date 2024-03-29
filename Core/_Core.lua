--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, LibStub, M = ns.O, ns.LibStub, ns.M

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class Core : BaseLibraryObject
local L = LibStub:NewLibrary(M.Core, 1)
local p = L.logger

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

