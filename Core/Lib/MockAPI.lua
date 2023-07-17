--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub, sformat = ns.O, ns.O.GlobalConstants, ns.M, ns.LibStub, ns.sformat
local INSTANCE_DIFFICULTY = GC.C.INSTANCE_DIFFICULTY
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class MockAPI : BaseLibraryObject
local L = LibStub:NewLibrary(M.MockAPI);
if not L then
    return
end
local p = L.logger;

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param instanceInfo MockedInstanceInfo
local function CreateMockData(instanceInfo)
    local difficultyID = instanceInfo.difficultyID or INSTANCE_DIFFICULTY.Heroic.id
    local encounterSize = 1
    local encounterProgress = 0
    if instanceInfo.encounters then
        encounterSize = #instanceInfo.encounters
        for i, encounter in ipairs(instanceInfo.encounters) do
            if encounter.isKilled == true then
                encounterProgress = encounterProgress + 1
            end
        end
    end

    local mockData = {
        activity = {
            categoryID = 2,
            difficultyID = difficultyID,
            difficultyName = instanceInfo.difficultyName,
            displayType = 1,
            filters = 1,
            fullName = instanceInfo.name,
            groupFinderActivityGroupID = 289,
            iconFileDataID = 0,
            id = instanceInfo.activity,
            isHeroic = difficultyID == INSTANCE_DIFFICULTY.Heroic.id,
            mapID = 596,
            maxLevel = 0,
            maxLevelSuggestion = 80,
            maxNumPlayers = instanceInfo.maxNumPlayers,
            minLevel = 80,
            orderIndex = 0,
            redirectedDifficultyID = 2,
            shortName = instanceInfo.name,
            useDungeonRoleExpectations = true
        },
        data = {
            activityID = instanceInfo.activity,
            buttonType = 2,
            maxLevel = 80,
            minLevel = 80,
            name = instanceInfo.name,
            orderIndex = 0
        },
        info = {
            difficulty = difficultyID,
            difficultyName = instanceInfo.difficultyName,
            encounterProgress = encounterProgress,
            encounters = instanceInfo.encounters or {},
            extendDisabled = false,
            instanceID = 596,
            instanceIndex = 1,
            isExtended = false,
            isLocked = true,
            isRaid = instanceInfo.isRaid or false,
            lockoutID = 201684163,
            maxPlayers = instanceInfo.maxNumPlayers,
            name = instanceInfo.name,
            nameId = '',
            numEncounters = encounterSize,
            reset = 28904
        }
    }

    if instanceInfo.isRaid == true then
        mockData.activity.categoryID = 114
    end
    return mockData
end

---@param activityID number
---@param instanceName string
---@param encounters Encounters|nil
---@param encounterProgress number|nil
local function CreateMockDataHeroicInstance(activityID, instanceName, encounters, encounterProgress)
    return CreateMockData({
        isRaid = false,
        activity = activityID,
        name = instanceName,
        difficultyName = INSTANCE_DIFFICULTY.Heroic.name,
        difficultyID = INSTANCE_DIFFICULTY.Heroic.id,
        maxNumPlayers = 5,
        maxLevel = 80,
        minLevel = 80,
        encounterProgress = encounterProgress,
        encounters = encounters
    })
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o MockAPI
local function Methods(o)
    --- @param index number
    --- @return SavedInstanceInfo
    function o:GetSavedInstanceInfoByIndex(index)
        local saved = self.SavedInstanceDetails[index]
        p:log(0, 'Mocked::SavedInstanceInfo: index=%s [%s]', index, O.API:GetUniqueName(saved.info))
        return saved.info
    end
    function o:GetNumSavedInstances()
        local count = #self.SavedInstanceDetails
        p:log('Mock::SavedInstanceDetails: count=%s', count)
        return count
    end

    function o:FindActivityInfoTable(activityID)
        for _, v in pairs(self.SavedInstanceDetails) do
            if activityID == v.activity.id then
                return v.activity
            end
        end
        return nil
    end

    ---@param activityID number
    function o:GetActivityInfoTable(activityID)
        local activity = self:FindActivityInfoTable(activityID)
        if activity then p:log(0, 'Mock::Activity: %s', activity.fullName) end
        return activity
    end
end

Methods(L)

--[[-----------------------------------------------------------------------------
Mocked Data
-------------------------------------------------------------------------------]]


--[[-----------------------------------------------------------------------------
Halls of Lightning
-------------------------------------------------------------------------------]]
local Nexus_Title = 'The Nexus'
L.Nexus = CreateMockDataHeroicInstance(1132, Nexus_Title, {
    {
        bossName = "Grand Magus Telestra",
        isKilled = true
    },
    {
        bossName = 'Anomalus',
        isKilled = false
    },
    {
        bossName = 'Ormorok the Tree-Shaper',
        isKilled = false
    },
    {
        bossName = "Keristrasza",
        isKilled = true
    }
})
L.Nexus_TitanRuneBeta = CreateMockDataHeroicInstance(1213, Nexus_Title, {
    {
        bossName = "Grand Magus Telestra",
        isKilled = true
    },
    {
        bossName = 'Anomalus',
        isKilled = true
    },
    {
        bossName = 'Ormorok the Tree-Shaper',
        isKilled = false
    },
    {
        bossName = "Keristrasza",
        isKilled = true
    }
})

local HoL_Title = 'Halls of Lightning'
L.HallsOfLightning = CreateMockDataHeroicInstance(1127, HoL_Title, {
    {
        bossName = "General Bjarngrim",
        isKilled = true
    },
    {
        bossName = 'Vokhan',
        isKilled = true
    },
    {
        bossName = 'Ionar',
        isKilled = true
    },
    {
        bossName = "Loken",
        isKilled = false
    }
})
L.HallsOfLightning_TitanRuneAlpha = CreateMockDataHeroicInstance(1202, HoL_Title, {
    {
        bossName = "General Bjarngrim",
        isKilled = true
    },
    {
        bossName = 'Vokhan',
        isKilled = true
    },
    {
        bossName = 'Ionar',
        isKilled = false
    },
    {
        bossName = "Loken",
        isKilled = false
    }
})

--[[-----------------------------------------------------------------------------
Gundrak
-------------------------------------------------------------------------------]]
local Gundrak_Title = 'Gundrak'
L.Gundrak = CreateMockDataHeroicInstance(1130, Gundrak_Title, {
    {
        bossName = "Slad'ran",
        isKilled = true
    }, {
        bossName = 'Drakkari Colossus',
        isKilled = true
    }, {
        bossName = 'Moorabi',
        isKilled = true
    }, {
        bossName = "Gal'darah",
        isKilled = true
    }, {
        bossName = 'Eck the Ferocious',
        isKilled = true
    }
})
L.Gundrak_TitanRuneBeta = CreateMockDataHeroicInstance(1217, Gundrak_Title, {
    {
        bossName = "Slad'ran",
        isKilled = true
    }, {
        bossName = 'Drakkari Colossus',
        isKilled = true
    }, {
        bossName = 'Moorabi',
        isKilled = false
    }, {
        bossName = "Gal'darah",
        isKilled = false
    }, {
        bossName = 'Eck the Ferocious',
        isKilled = false
    }
})

--[[-----------------------------------------------------------------------------
Violet Hold
-------------------------------------------------------------------------------]]
local VioletHold_Title = 'Violet Hold'
L.VioletHold = CreateMockDataHeroicInstance(1123, VioletHold_Title, {
    { bossName = 'First Prisoner', isKilled = true },
    { bossName = 'Second Prisoner', isKilled = true },
    { bossName = 'Erekem', isKilled = true },
    { bossName = 'Moragg', isKilled = false },
    { bossName = 'Ichoron', isKilled = false },
    { bossName = 'Xevozz', isKilled = false },
    { bossName = 'Lavanthor', isKilled = true },
    { bossName = 'Zuramat', isKilled = false },
    { bossName = 'Cyanigosa', isKilled = true }
})
L.VioletHold_TitanRuneBeta = CreateMockDataHeroicInstance(1209, VioletHold_Title, {
    { bossName = 'First Prisoner', isKilled = true },
    { bossName = 'Second Prisoner', isKilled = true },
    { bossName = 'Erekem', isKilled = true },
    { bossName = 'Moragg', isKilled = false },
    { bossName = 'Ichoron', isKilled = false },
    { bossName = 'Xevozz', isKilled = false },
    { bossName = 'Lavanthor', isKilled = false },
    { bossName = 'Zuramat', isKilled = false },
    { bossName = 'Cyanigosa', isKilled = false }
})

local CoS_Title = 'The Culling of Stratholme'
L.CoS = CreateMockDataHeroicInstance(1126, CoS_Title, {
    {
        bossName = 'Meathook',
        isKilled = true
    }, {
        bossName = 'Salram the Fleshcrafter',
        isKilled = true
    }, {
        bossName = 'Chrono-Lord Epoch',
        isKilled = true
    }, {
        bossName = "Mal'ganis",
        isKilled = true
    }
})
L.CoS_TitanRuneBeta = CreateMockDataHeroicInstance(1214, CoS_Title, {
    {
        bossName = 'Meathook',
        isKilled = true
    }, {
        bossName = 'Salram the Fleshcrafter',
        isKilled = true
    }, {
        bossName = 'Chrono-Lord Epoch',
        isKilled = true
    }, {
        bossName = "Mal'ganis",
        isKilled = true
    }
})

L.NAXX_10 = CreateMockData({
    isRaid = true,
    activity = 841,
    name = 'Naxxramas',
    difficultyName = INSTANCE_DIFFICULTY.Normal_10Player.name,
    difficultyID = INSTANCE_DIFFICULTY.Normal_10Player.id,
    maxNumPlayers = 10,
    maxLevel = 80,
    minLevel = 80,
})
L.NAXX_25 = CreateMockData({
    isRaid = true,
    activity = 1098,
    name = 'Naxxramas',
    difficultyName = INSTANCE_DIFFICULTY.Normal_25Player.name,
    difficultyID = INSTANCE_DIFFICULTY.Normal_25Player.id,
    maxNumPlayers = 25,
    maxLevel = 80,
    minLevel = 80,
})
L.EOE_10 = CreateMockData({
    isRaid = true,
    activity = 1102,
    name = 'The Eye of Eternity',
    difficultyName = INSTANCE_DIFFICULTY.Normal_10Player.name,
    difficultyID = INSTANCE_DIFFICULTY.Normal_10Player.id,
    maxNumPlayers = 10,
    maxLevel = 80,
    minLevel = 80,
})
L.EOE_25 = CreateMockData({
    isRaid = true,
    activity = 1094,
    name = 'The Eye of Eternity',
    difficultyName = INSTANCE_DIFFICULTY.Normal_25Player.name,
    difficultyID = INSTANCE_DIFFICULTY.Normal_25Player.id,
    maxNumPlayers = 25,
    maxLevel = 80,
    minLevel = 80,
})


--- @type table<number, SavedInstanceDetails>
L.SavedInstanceDetails = { L.HallsOfLightning, L.Gundrak }
