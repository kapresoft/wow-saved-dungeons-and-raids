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

local API, pformat = O.API, ns.pformat
local IsEmptyTable, GetSortedKeys = O.LU.Table.isEmpty, O.LU.Table.getSortedKeys
local ColorHelper = ns.Kapresoft_LibUtil.CH
local SAVED_INSTANCE_COLOR = 'fc1605'
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
        --TODO next: If profile.showReportInConsole
        self:RegisterPreRetailFrameHook()
        self:RegisterRetailFrameHook()
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
        self:ReportSavedDungeons(dungeons)
        self:ReportSavedRaid(raids)
    end

    function o:HandleSavedInstances()
        local selectedCategory = API:GetSelectedCategory()
        if not selectedCategory then return end
        p:log(10, 'HandleSavedDungeons::Category: %s', pformat({ selectedCategory.id, selectedCategory.name }))
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

        local btn = view.view.frames[2].CheckButton
        local nd = btn:GetParent():GetElementData()

        --local count = 0
        --view.view:ForEachFrame(function(f)
        --    count = count + 1
        --    local button = f.CheckButton
        --    --- @type DataProviderElement
        --    local node = button:GetParent():GetElementData()
        --    local data = node.data
        --    p:log('f: %s [%s]', f.NameButton.Name:GetText(), pformat(data))
        --end)
        --p:log('Count: %s', count)

        --[[local dp = view:GetDataProvider()
        ---@param dataElem DataProviderElement
        dp:ForEach(function(dataElem)
            local data = dataElem.data
            --local f = safecall(function() view.view:FindFrame(data) end)
            if data.minLevel == 80 then
                p:log('instance name: %s frame: %s', dataElem.data.name, type(f))
            end
        end)]]

        local dungeons = API:GetSavedDungeonsElement()
        if IsEmptyTable(dungeons) then return end

        local _dungeons = {}
        for _, savedInstanceDetails in pairs(dungeons) do
            local data = savedInstanceDetails.data
            local activity = savedInstanceDetails.activity
            local info = savedInstanceDetails.info
            local d = { data = data, activity = activity, info = info }
            table.insert(_dungeons, d)
            if data and (data.maxLevel == activity.minLevel) and info.encounterProgress > 0 then
                data.name = ColorHelper:FormatColor(SAVED_INSTANCE_COLOR, data.name)
            end
        end
        self:JiggleView(view)
        self:ApplyLFGFrameTooltip(view, dungeons)

    end

    ---@param dungeons table<string, SavedInstanceDetails>
    ---@param scrollBox LFGListingFrameActivityViewScrollBox
    function o:ApplyLFGFrameTooltip(scrollBox, dungeons)
        if 'table' ~= type(dungeons) then return end
        if not (scrollBox and scrollBox.view and 'table' == type(scrollBox.view.frames)) then return end
        local scrollView = scrollBox.view
        --- @type table<number, LFGFrameGroup>
        local frames = scrollView.frames
        for _, f in pairs(frames) do
            if o.hooked ~= true then self:ApplyTooltipHooks(f, dungeons) end
        end
    end

    ---@param fgroup LFGFrameGroup
    ---@param dungeons table<string, SavedInstanceDetails>
    function o:ApplyTooltipHooks(fgroup, dungeons)
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

    function o:UpdateSavedRaidsInLFGFrame()
        local view = _G['LFGListingFrameActivityViewScrollBox']
        if not view then return end
        local raids = API:GetSavedRaidsElement()
        if IsEmptyTable(raids) then return end

        for name, savedInstanceDetails in pairs(raids) do
            local data = savedInstanceDetails.data
            if data then
                data.name = ColorHelper:FormatColor(SAVED_INSTANCE_COLOR, data.name)
                --p:log('%s: %s', name, pformat(elem.data))
            end
        end
        view:GetView():Rebuild()
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
