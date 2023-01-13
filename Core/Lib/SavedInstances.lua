--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, LibStub, M, ns = SDNR_LibPack(...)
local GC, API = O.GlobalConstants, O.API
local IsEmptyTable = O.LU.Table.isEmpty
local KC = Kapresoft_LibUtil_Constants
local SAVED_INSTANCE_COLOR = 'fc1605'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class SavedInstances : BaseLibraryObject
local L = LibStub:NewLibrary(M.SavedInstances)
local p = L.logger

local colors = {
    header = 'ffffff',
    headerSides = 'ffffff',
    subh = 'fbeb2d',
}
---@param text string
local function header(text)
    local sides = sformat("|cfd%s%s|r", colors.headerSides, ':::')
    local fmth = sides .. " |cfd" .. colors.header .. "%s|r " .. sides
    return sformat(fmth, text)
end
---@param text string
local function subh(text) return KC:FormatColor(colors.subh, text) end

---@param o SavedInstances
local function Methods(o)

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
            local success = dungeonButton:HookScript('OnClick', function()
                p:log(10, 'ApplyLFGFrameHooks::Dungeon::OnClick called...%s', GetTime())
                self:HandleSavedInstances()
            end)
            self.Dungeon_OnClick_Hooked = success
        end
        if self.Raid_OnClick_Hooked ~= true then
            if #categoryButtons <= 0 then return end
            local button = categoryButtons[2]
            if not button then return end
            local success = button:HookScript('OnClick', function()
                p:log(10, 'ApplyLFGFrameHooks::Raid::OnClick called...%s', GetTime())
                self:HandleSavedInstances()
            end)
            self.Raid_OnClick_Hooked = success
        end

        if self.LFGListingFrame_OnShow_Hooked ~= true then
            local success = LFGListingFrame:HookScript('OnShow', function()
                p:log(10, 'ApplyLFGFrameHooks::LFGListingFrame:OnShow called...%s', GetTime())
                self:HandleSavedInstances()
            end)
            self.LFGListingFrame_OnShow_Hooked = success
        end
    end
    function o:RegisterLFGFrameHooksDelayed() C_Timer.After(0.5, function() self:RegisterLFGFrameHooks() end) end

    function o:RegisterRetailFrameHook()
        local f = _G['PVEFrame']
        if not f then return end
        local success = f:HookScript('OnShow', function ()
            self:RegisterLFGFrameHooksDelayed()
            -- self:ReportSavedInstances()
            RequestRaidInfo()
        end)
        assert(success, 'Failed to RegisterHooks() in PVEFrame.')
    end
    function o:RegisterPreRetailFrameHook()
        local LFGParentFrame = _G['LFGParentFrame']
        if not LFGParentFrame then return end
        local success = LFGParentFrame:HookScript('OnShow', function ()
             self:RegisterLFGFrameHooksDelayed()
             -- self:ReportSavedInstances()
            RequestRaidInfo()
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
        local selectedCategory = self:GetSelectedCategory()
        p:log(10, 'HandleSavedDungeons::Category: %s', selectedCategory or 'none')
        if not selectedCategory then return end
        if 'Dungeons' == selectedCategory then
            self:UpdateSavedDungeonsInLFGFrame()
        elseif 'Raids' == selectedCategory then
            self:UpdateSavedRaidsInLFGFrame()
        end
    end

    function o:UpdateSavedDungeonsInLFGFrame()
        local view = _G['LFGListingFrameActivityViewScrollBox']
        if not view then return end
        local dungeons = API:GetSavedDungeonsElement()
        if IsEmptyTable(dungeons) then return end

        for name, elem in pairs(dungeons) do
            local data = elem:GetData()
            if elem.data then
                elem.data.name = KC:FormatColor(SAVED_INSTANCE_COLOR, elem.data.name)
                --p:log('%s: %s', name, pformat(elem.data))
            end
        end
        view:GetView():Rebuild()
    end

    function o:UpdateSavedRaidsInLFGFrame()
        local view = _G['LFGListingFrameActivityViewScrollBox']
        if not view then return end
        local raids = API:GetSavedRaidsElement()
        if IsEmptyTable(raids) then return end

        for name, elem in pairs(raids) do
            local data = elem:GetData()
            if elem.data then
                elem.data.name = KC:FormatColor(SAVED_INSTANCE_COLOR, elem.data.name)
                --p:log('%s: %s', name, pformat(elem.data))
            end
        end
        view:GetView():Rebuild()
    end

    function o:GetSelectedCategory()
        local LFGListingFrame = _G['LFGListingFrame']
        local C_LFGList = _G['C_LFGList']
        if not (LFGListingFrame and C_LFGList) then return nil end
        local catID = LFGListingFrame:GetCategorySelection()
        return catID and C_LFGList.GetCategoryInfo(catID)
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

        for name, d in pairs(dungeons) do
            pp:log('  - %s (%s)', name, tostring(d.difficultyName))
        end
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

        for name, r in pairs(raids) do
            pp:log('  - %s (%s)', name, tostring(r.difficultyName))
        end
        print('\n')
    end

end

Methods(L)
