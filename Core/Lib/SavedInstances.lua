--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, LibStub, M = SDNR_LibPack(...)
local GC = O.GlobalConstants
local IsEmptyTable = O.LU.Table.isEmpty
local KC = Kapresoft_LibUtil_Constants

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class SavedInstances : BaseLibraryObject
local L = LibStub:NewLibrary(M.SavedInstances)
local p = L.logger;

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

    ---@param logger LoggerInterface
    function o:ReportSavedInstances(logger)
        local dungeons, raids = O.API:GetSavedInstances()
        print('\n')
        self:ReportSavedDungeons(dungeons, logger)
        self:ReportSavedRaid(raids, logger)
    end

    ---@param pp LoggerInterface
    function o:ReportSavedDungeons(dungeons, pp)
        pp:log(header('Saved Dungeons'))
        pp:log('')
        pp:log(subh('Dungeons'))

        if #dungeons == 0 then
            pp:log("  - No saved instances found.")
        else
            for i=1, #dungeons do pp:log('  - %s', dungeons[i]) end
            pp:log('')
        end
    end

    ---@param pp LoggerInterface
    function o:ReportSavedRaid(raids, pp)
        pp:log(subh('Raids'))
        if #raids == 0 then
            pp:log("- No saved raids found.")
        else
            if #raids == 0 then return end
            for i=1, #raids do
                pp:log('  - %s', raids[i])
            end
            print('\n')
        end
    end

end

Methods(L)
