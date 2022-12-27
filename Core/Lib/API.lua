--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetSavedInstanceInfo = GetSavedInstanceInfo

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, LibStub, M = SDNR_LibPack(...)
local GC = O.GlobalConstants
local IsEmptyTable = O.LU.Table.isEmpty
local INSTANCE_COUNT
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class API : BaseLibraryObject
local L = LibStub:NewLibrary(M.API)
local p = L.logger;

---@return table, table The first table is regular instance and second is raid
---@param o API
local function Methods(o)

    function o:GetSavedInstances()
        local dungeons = {}
        local raids = {}
        for i=1, 25 do
            local name, _, _, _, _, _, _, isRaid, _, difficultyName = GetSavedInstanceInfo(i)
            if name then
                local str = string.format('%s (%s)', name, tostring(difficultyName))
                local tbl = dungeons
                if isRaid == true then tbl = raids end
                table.insert(tbl, str)
            end
        end
        -- Temporary

        if false then
            local name = 'Naxxramas (10)'
            local difficultyName = 'Heroic'
            local str = string.format('%s (%s)', name, tostring(difficultyName))
            table.insert(raids, str)
        end

        table.sort(dungeons)
        table.sort(raids)
        return dungeons, raids
    end

end

Methods(L)