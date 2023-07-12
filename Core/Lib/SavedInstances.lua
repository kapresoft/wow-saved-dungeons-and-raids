--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local RequestRaidInfo = RequestRaidInfo
local After = C_Timer.After

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, LibStub, M, E = ns.O, ns.LibStub, ns.M, ns.GC.E

local GC, API = O.GlobalConstants, O.API
local IsEmptyTable, GetSortedKeys = O.LU.Table.isEmpty, O.LU.Table.getSortedKeys
local ColorHelper = ns.Kapresoft_LibUtil.CH
-- TODO NEXT: Add to Settings
local SAVED_INSTANCE_COLOR = 'FC1605'
local SAVED_INSTANCE_REL_COLOR = 'FC511C'

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class SavedInstances : BaseLibraryObject
local L = LibStub:NewLibrary(M.SavedInstances)
local p = L.logger

local colors = {
    header = 'ffffff',
    headerSides = 'ffffff',
    subh = 'fbeb2d',
}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param dungeons table<string, SavedInstanceDetails>
---@param activityId number
local function findDungeon(dungeons, activityId)
    for _, savedInstanceDetails in pairs(dungeons) do
        if activityId == savedInstanceDetails.activity.id then return savedInstanceDetails end
    end
    return nil
end

--- @param text string
local function header(text)
    local sides = sformat("|cfd%s%s|r", colors.headerSides, ':::')
    local fmth = sides .. " |cfd" .. colors.header .. "%s|r " .. sides
    return sformat(fmth, text)
end
--- @param text string
local function subh(text) return ColorHelper:FormatColor(colors.subh, text) end

--- @param o SavedInstances
local function PropsAndMethods(o)

    o.LFGListingFrame_OnShow_Hooked = false
    o.LFGParentFrameTab1_OnClick_Hooked = false
    o.Dungeon_OnClick_Hooked = false
    o.Raid_OnClick_Hooked = false

    ---Should only be called once
    function o:RegisterConsoleHooks()
        self:RegisterDebugHooks()
        self:RegisterPreRetailFrameHook()
        self:RegisterRetailFrameHook()
    end

    function o:RegisterDebugHooks()
        if GC.C.DEBUG_LFG_PRE_RETAIL_DEBUG_HOOK_ENABLED == true then
            self:RegisterPreRetailDebugFrameHook()
        end
    end

    function o:RegisterPreRetailDebugFrameHook()
        if self.preRetailDebugHook == true then return end
        ---@param data DataProviderElementData
        hooksecurefunc('LFGListingActivityView_InitActivityButton', function(fgroup, data, collapsed)
            local onEnterHooked = fgroup.NameButton:HookScript('OnEnter', function(nameBtn)
                --local f = nameBtn:GetParent()
                --@type DataProviderElementData
                --local data = f:GetElementData().data; if not data then return end
                p:log('ElemData::%s %s [DEBUG]', data.name, pformat(data))
            end)
            self.preRetailDebugHook = true

            p:log(10, '[%s] RegisterPreRetailDebugFrameHook::OnEnter::Hook-Success? %s preRetailDebugHook=%s [%s]',
                    fgroup.NameButton:GetObjectType(), tostring(onEnterHooked),
                    tostring(self.preRetailDebugHook), GetTime())
        end)
        p:log(10, 'GC.C.DEBUG_LFG_PRE_RETAIL_DEBUG_HOOK_ENABLED is set')
    end

    --TODO next: If profile.showSavedInLFGFrame
    function o:RegisterLFGFrameHooks()
        local LFGListingFrame = _G['LFGListingFrame']
        if not LFGListingFrame then return end

        local categoryButtons = LFGListingFrame.CategoryView.CategoryButtons
        if self.Dungeon_OnClick_Hooked ~= true then
            if #categoryButtons <= 0 then return end
            local dungeonButton = categoryButtons[1]
            if not dungeonButton then return end
            local success = dungeonButton:HookScript(E.OnClick, function()
                p:log(10, 'ApplyLFGFrameHooks::Dungeon::OnClick called...%s', GetTime())
                self:HandleSavedInstances()
            end)
            self.Dungeon_OnClick_Hooked = success
        end
        if self.Raid_OnClick_Hooked ~= true then
            if #categoryButtons <= 0 then return end
            local button = categoryButtons[2]
            if not button then return end
            local success = button:HookScript(E.OnClick, function()
                p:log(10, 'ApplyLFGFrameHooks::Raid::OnClick called...%s', GetTime())
                self:HandleSavedInstances()
            end)
            self.Raid_OnClick_Hooked = success
        end

        if self.LFGListingFrame_OnShow_Hooked ~= true then
            local success = LFGListingFrame:HookScript(E.OnShow, function()
                p:log(10, 'ApplyLFGFrameHooks::LFGListingFrame:OnShow called...%s', GetTime())
                self:HandleSavedInstances()
            end)
            self.LFGListingFrame_OnShow_Hooked = success
        end

        if self.LFGParentFrameTab1_OnClick_Hooked ~= true then
            local success = LFGParentFrameTab1:HookScript(E.OnClick, function (f)
                self:HandleSavedInstances()
            end)
            assert(success, 'Failed to Register OnClick() Hook to LFGParentFrameTab1.')
            self.LFGParentFrameTab1_OnClick_Hooked = success
        end
    end

    function o:RegisterLFGFrameHooksDelayed() After(0.5, function() self:RegisterLFGFrameHooks() end) end

    function o:RegisterRetailFrameHook()
        local f = _G['PVEFrame']
        if not f then return end
        local success = f:HookScript(E.OnShow, function ()
            self:RegisterLFGFrameHooksDelayed()
            -- self:ReportSavedInstances()
            --- Callback function is in MainEventHandler for Event UPDATE_INSTANCE_INFO
            --- @see MainEventHandler#RegisterOnRequestRaidInfo
            --RequestRaidInfo()
        end)
        assert(success, 'Failed to RegisterHooks() in PVEFrame.')
    end

    function o:RegisterPreRetailFrameHook()
        local LFGParentFrame = _G['LFGParentFrame']
        if not LFGParentFrame then return end
        local success = LFGParentFrame:HookScript(E.OnShow, function ()
             self:RegisterLFGFrameHooksDelayed()
        end)
        assert(success, 'Failed to RegisterHooks() in LFGParentFrame.')
    end

    function o:ReportSavedInstances()
        local dungeons, raids = O.API:GetSavedInstances()
        print('\n')
        if not IsEmptyTable(dungeons) then
            self:ReportSavedDungeons(dungeons)
        end
        if not IsEmptyTable(raids) then
            self:ReportSavedRaid(raids)
        end
    end

    function o:HandleSavedInstances()
        C_Timer.After(0.1, function() self:HandleSavedInstancesDelayed() end)
    end

    function o:HandleSavedInstancesDelayed()
        local selectedCategory = API:GetSelectedCategory()
        if not selectedCategory then return end
        --p:log(10, 'HandleSavedDungeons::Category: %s', pformat({ selectedCategory.id, selectedCategory.name }))
        if selectedCategory:IsDungeon() then
            self:UpdateSavedDungeonsInLFGFrame()
        elseif selectedCategory:IsRaid() then
            self:UpdateSavedRaidsInLFGFrame()
        end
    end

    function o:UpdateSavedDungeonsInLFGFrame()
        --- @type LFGListingFrameActivityViewScrollBox
        local view = _G['LFGListingFrameActivityViewScrollBox']
        if not view then return end

        --- @type table<string, SavedInstanceDetails>
        local dungeons = API:GetSavedInstanceByFilter()
        if IsEmptyTable(dungeons) then return end

        for nameID, savedInstanceDetails in pairs(dungeons) do
            local data = savedInstanceDetails.data
            local activity = savedInstanceDetails.activity
            local info = savedInstanceDetails.info
            if data and (data.maxLevel == activity.minLevel) and info.encounterProgress > 0 then
                data.name = ColorHelper:FormatColor(SAVED_INSTANCE_COLOR, data.name)
                --- @type DataProviderElementData
                local rel = savedInstanceDetails.relatedInstances
                if #rel > 0 then
                    for i, elemData in ipairs(rel) do
                        elemData.name = ColorHelper:FormatColor(SAVED_INSTANCE_REL_COLOR, elemData.name)
                    end
                end
            end
        end
        self:JiggleView(view)
        self:ApplyLFGFrameTooltip(view, dungeons)

    end

    -- TODO next: Can be merged with HandleSavedInstances
    function o:UpdateSavedRaidsInLFGFrame()
        local view = _G['LFGListingFrameActivityViewScrollBox']
        if not view then return end
        local raids = API:GetSavedInstanceByFilter()
        if IsEmptyTable(raids) then return end

        for name, savedInstanceDetails in pairs(raids) do
            local data = savedInstanceDetails.data
            local activity = savedInstanceDetails.activity
            --print('data:', pformat(data), 'activityID:', activity.id)
            if data and data.maxLevel == activity.minLevel
                    and data.activityID == activity.id then
                data.name = ColorHelper:FormatColor(SAVED_INSTANCE_COLOR, data.name)
            end
        end
        self:JiggleView(view)
    end

    ---@param dungeons table<string, SavedInstanceDetails>
    ---@param scrollBox LFGListingFrameActivityViewScrollBox
    function o:ApplyLFGFrameTooltip(scrollBox, dungeons)
        if 'table' ~= type(dungeons) then return end
        if not (scrollBox and scrollBox.view and 'table' == type(scrollBox.view.frames)) then return end

        --- @see Interface/SharedXML/Scroll/ScrollBoxListView.lua
        local scrollView = scrollBox.view
        --- @type table<number, LFGFrameGroup>
        local frames = scrollView.frames
        for _, f in pairs(frames) do
            if o.hooked ~= true then self:ApplyTooltipHooks(dungeons) end
        end
    end

    ---@param dungeons table<string, SavedInstanceDetails>
    function o:ApplyTooltipHooks(dungeons)
        if not LFGListingActivityView_InitActivityButton then return end
        hooksecurefunc('LFGListingActivityView_InitActivityButton', function(fgroup, data, collapsed)
            self:HandleTooltip(fgroup, dungeons)
        end)
    end

    ---@param fgroup LFGFrameGroup
    ---@param dungeons table<string, SavedInstanceDetails>
    function o:HandleTooltip(fgroup, dungeons)
        local onEnterHooked = fgroup.NameButton:HookScript('OnEnter', function(nameBtn)
            o.hooked = true
            local f = nameBtn:GetParent()
            --- @type DataProviderElementData
            local data = f:GetElementData().data; if not data then return end
            local dungeon = findDungeon(dungeons, data.activityID)
            if not (dungeon and dungeon.activity and dungeon.info) then return end

            self:ApplyTooltip(dungeon, nameBtn)
        end)

        local onLeaveHooked = fgroup.NameButton:HookScript('OnLeave', function(_nameBtn) GameTooltip:Hide() end)
        p:log(10, '[%s] OnEnter::Hook-Success? %s, OnLeave::Hook-Success? %s %s',
                fgroup.NameButton:GetObjectType(),
                tostring(onEnterHooked), tostring(onLeaveHooked), GetTime())
    end

    ---@param dungeon SavedInstanceDetails
    ---@param nameBtn LFGFrameGroupNameButton
    function o:ApplyTooltip(dungeon, nameBtn)
        local info = dungeon.info
        local encounters = info.encounters
        if not (dungeon.activity.isHeroic and info.encounterProgress > 0) then return end

        local bossesKilledText = ColorHelper:FormatColor(SAVED_INSTANCE_COLOR, '(%s/%s Bosses Killed)')
        GameTooltip:SetOwner(nameBtn, "ANCHOR_RIGHT");
        GameTooltip:AddLine(sformat('Instance Lock ID: %s ' .. bossesKilledText,
                dungeon.info.lockoutID, info.encounterProgress, info.numEncounters))
        if encounters then
            ---@param enc EncounterInfo
            for i, enc in ipairs(encounters) do
                local killed = ''
                local bossName = enc.bossName
                if enc.isKilled then
                    killed = ColorHelper:FormatColor(SAVED_INSTANCE_COLOR, '(Killed)')
                    bossName = ColorHelper:FormatColor(SAVED_INSTANCE_COLOR, bossName) end
                GameTooltip:AddLine(sformat('  • %s %s', bossName, killed))
            end
        end
        GameTooltip:Show()
    end

    --- Jiggle the scroll view up and down -- a hack to get the entries to update
    ---@param scrollBox LFGListingFrameActivityViewScrollBox
    function o:JiggleView(scrollBox)
        scrollBox:GetView():Rebuild()
        scrollBox:OnMouseWheel(-1)
        scrollBox:OnMouseWheel(1)
    end

    --- @param dungeons table<string,SavedInstanceInfo>
    function o:ReportSavedDungeons(dungeons)
        local pp = ns:GetAddonLogger()
        pp:log(header(sformat('%s %s', SDNR_SAVED, SDNR_INSTANCES)))
        pp:log('')
        pp:log(subh(SDNR_DUNGEONS))
        if IsEmptyTable(dungeons) then
            pp:log("  - %s", SDNR_NO_SAVED_INSTANCES_FOUND)
            return
        end
        for _, name in pairs(GetSortedKeys(dungeons)) do pp:log("  - %s", name) end
        pp:log('')
    end

    --- @param raids table<string, SavedInstanceInfo>
    function o:ReportSavedRaid(raids)
        local pp = ns:GetAddonLogger()
        pp:log(subh(SDNR_RAIDS))
        if IsEmptyTable(raids) then
            pp:log("  - %s", SDNR_NO_SAVED_RAID_FOUND)
            return
        end

        for _, name in pairs(GetSortedKeys(raids)) do pp:log("  - %s", name) end
        print('\n')
    end

end

PropsAndMethods(L)
