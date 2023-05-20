--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub, pformat, sformat = ns.O, ns.O.GlobalConstants, ns.M, ns.LibStub, ns.pformat, ns.sformat

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class MockAPI : BaseLibraryObject
local L = LibStub:NewLibrary(M.MockAPI);
if not L then
    return
end
local p = L.logger;

---@param o MockAPI
local function Methods(o)
    --- @param index number
    --- @return SavedInstanceInfo
    function o:GetSavedInstanceInfoByIndex(index)
        local saved = self.SavedInstanceDetails[index]
        p:log('Mocked saved dungeon index: %s [%s]', index, O.API:GetUniqueName(saved.info))
        return saved.info
    end
    function o:GetNumSavedInstances()
        local count = #self.SavedInstanceDetails
        p:log('Mock SavedInstanceDetails count: %s', count)
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
        if activity then p:log('Retrieve mocked activity: %s', activity.fullName) end
        return activity
    end
end

Methods(L)

--[[-----------------------------------------------------------------------------
Mocked Data
-------------------------------------------------------------------------------]]
L.HallsOfLightning = {
    activity = {
        categoryID = 2,
        difficultyID = 2,
        difficultyName = 'Heroic',
        displayType = 1,
        filters = 1,
        fullName = 'Halls of Lightning',
        groupFinderActivityGroupID = 289,
        iconFileDataID = 0,
        id = 1127,
        isHeroic = true,
        mapID = 605,
        maxLevel = 0,
        maxLevelSuggestion = 80,
        maxNumPlayers = 5,
        minLevel = 80,
        orderIndex = 0,
        redirectedDifficultyID = 2,
        shortName = 'Halls of Lightning',
        useDungeonRoleExpectations = true
    },
    data = {
        activityID = 1127,
        buttonType = 2,
        maxLevel = 80,
        minLevel = 80,
        name = 'Halls of Lightning',
        orderIndex = 0
    },
    info = {
        difficulty = 2,
        difficultyName = 'Heroic',
        encounterProgress = 1,
        encounters = {
            {
                bossName = "General Bjarngrim",
                isKilled = true
            },
            {
                bossName = 'Vokhan',
                isKilled = false
            },
            {
                bossName = 'Ionar',
                isKilled = false
            },
            {
                bossName = "Loken",
                isKilled = false
            } },
        extendDisabled = false,
        instanceID = 604,
        instanceIndex = 3,
        isExtended = false,
        isLocked = true,
        isRaid = false,
        lockoutID = 201742307,
        maxPlayers = 5,
        name = 'Halls of Lightning',
        nameId = '',
        numEncounters = 4,
        reset = 28904
    }
}
L.Gundrak = {
    activity = {
        categoryID = 2,
        difficultyID = 2,
        difficultyName = 'Heroic',
        displayType = 1,
        filters = 1,
        fullName = 'Gundrak',
        groupFinderActivityGroupID = 289,
        iconFileDataID = 0,
        id = 1130,
        isHeroic = true,
        mapID = 604,
        maxLevel = 0,
        maxLevelSuggestion = 80,
        maxNumPlayers = 5,
        minLevel = 80,
        orderIndex = 0,
        redirectedDifficultyID = 2,
        shortName = 'Gundrak',
        useDungeonRoleExpectations = true
    },
    data = {
        activityID = 1130,
        buttonType = 2,
        maxLevel = 80,
        minLevel = 80,
        name = 'Gundrak',
        orderIndex = 0
    },
    info = {
        difficulty = 2,
        difficultyName = 'Heroic',
        encounterProgress = 5,
        encounters = { {
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
                       } },
        extendDisabled = false,
        instanceID = 604,
        instanceIndex = 3,
        isExtended = false,
        isLocked = true,
        isRaid = false,
        lockoutID = 201742306,
        maxPlayers = 5,
        name = 'Gundrak',
        nameId = '',
        numEncounters = 5,
        reset = 28904
    }
}
L.VioletHold = {
    activity = {
        categoryID = 2,
        difficultyID = 2,
        difficultyName = 'Heroic',
        displayType = 1,
        filters = 1,
        fullName = 'Violet Hold',
        groupFinderActivityGroupID = 289,
        iconFileDataID = 0,
        id = 1123,
        isHeroic = true,
        mapID = 608,
        maxLevel = 0,
        maxLevelSuggestion = 80,
        maxNumPlayers = 5,
        minLevel = 80,
        orderIndex = 0,
        redirectedDifficultyID = 2,
        shortName = 'Violet Hold',
        useDungeonRoleExpectations = true
    },
    data = {
        activityID = 1123,
        buttonType = 2,
        maxLevel = 80,
        minLevel = 80,
        name = 'Violet Hold',
        orderIndex = 0
    },
    info = {
        difficulty = 2,
        difficultyName = 'Heroic',
        encounterProgress = 5,
        encounters = { {
                           bossName = 'First Prisoner',
                           isKilled = true
                       }, {
                           bossName = 'Second Prisoner',
                           isKilled = true
                       }, {
                           bossName = 'Erekem',
                           isKilled = true
                       }, {
                           bossName = 'Moragg',
                           isKilled = false
                       }, {
                           bossName = 'Ichoron',
                           isKilled = false
                       }, {
                           bossName = 'Xevozz',
                           isKilled = false
                       }, {
                           bossName = 'Lavanthor',
                           isKilled = true
                       }, {
                           bossName = 'Zuramat',
                           isKilled = false
                       }, {
                           bossName = 'Cyanigosa',
                           isKilled = true
                       } },
        extendDisabled = false,
        instanceID = 608,
        instanceIndex = 2,
        isExtended = false,
        isLocked = true,
        isRaid = false,
        lockoutID = 201697488,
        maxPlayers = 5,
        name = 'Violet Hold',
        nameId = '',
        numEncounters = 9,
        reset = 28904
    }
}
L.CoS = {
    activity = {
        categoryID = 2,
        difficultyID = 2,
        difficultyName = 'Heroic',
        displayType = 1,
        filters = 1,
        fullName = 'The Culling of Stratholme',
        groupFinderActivityGroupID = 289,
        iconFileDataID = 0,
        id = 1126,
        isHeroic = true,
        mapID = 595,
        maxLevel = 0,
        maxLevelSuggestion = 80,
        maxNumPlayers = 5,
        minLevel = 80,
        orderIndex = 0,
        redirectedDifficultyID = 2,
        shortName = 'The Culling of Stratholme',
        useDungeonRoleExpectations = true
    },
    data = {
        activityID = 1126,
        buttonType = 2,
        maxLevel = 80,
        minLevel = 80,
        name = 'The Culling of Stratholme',
        orderIndex = 0
    },
    info = {
        difficulty = 2,
        difficultyName = 'Heroic',
        encounterProgress = 4,
        encounters = { {
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
                       } },
        extendDisabled = false,
        instanceID = 595,
        instanceIndex = 1,
        isExtended = false,
        isLocked = true,
        isRaid = false,
        lockoutID = 201684163,
        maxPlayers = 5,
        name = 'The Culling of Stratholme',
        nameId = '',
        numEncounters = 4,
        reset = 28904
    }
}

---@param instanceInfo MockedInstanceInfo
local function CreateMockData(instanceInfo)
    local mockData = {
        activity = {
            categoryID = 2,
            difficultyID = 3,
            difficultyName = instanceInfo.difficultyName,
            displayType = 1,
            filters = 1,
            fullName = instanceInfo.name,
            groupFinderActivityGroupID = 289,
            iconFileDataID = 0,
            id = instanceInfo.activity,
            isHeroic = false,
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
            difficulty = 2,
            difficultyName = instanceInfo.difficultyName,
            encounterProgress = 4,
            encounters = { {
                               bossName = 'Malygos',
                               isKilled = true
                           }},
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
            numEncounters = 4,
            reset = 28904
        }
    }

    if instanceInfo.isRaid == true then
        mockData.activity.categoryID = 114
    end
    return mockData
end

L.NAXX_10 = CreateMockData({
    isRaid = true,
    activity = 841,
    name = 'Naxxramas',
    difficultyName = '10 Player',
    maxNumPlayers = 10,
    maxLevel = 80,
    minLevel = 80,
})
L.NAXX_25 = CreateMockData({
    isRaid = true,
    activity = 1098,
    name = 'Naxxramas',
    difficultyName = '25 Player',
    maxNumPlayers = 25,
    maxLevel = 80,
    minLevel = 80,
})
L.EOE_10 = CreateMockData({
    isRaid = true,
    activity = 1102,
    name = 'The Eye of Eternity',
    difficultyName = '10 Player',
    maxNumPlayers = 10,
    maxLevel = 80,
    minLevel = 80,
})
L.EOE_25 = CreateMockData({
    isRaid = true,
    activity = 1094,
    name = 'The Eye of Eternity',
    difficultyName = '25 Player',
    maxNumPlayers = 25,
    maxLevel = 80,
    minLevel = 80,
})


--- @type table<number, SavedInstanceDetails>
L.SavedInstanceDetails = { L.HallsOfLightning, L.Gundrak }
