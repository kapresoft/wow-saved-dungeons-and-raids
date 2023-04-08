local addonName = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
--- @type Namespace
local _, ns = ...
local LO = ns.Locale

-- General
SDNR_TITLE =  addonName
SDNR_CATEGORY                             = "AddOns/" .. SDNR_TITLE

-- Key binding localization text
BINDING_HEADER_SDNR_OPTIONS        = SDNR_TITLE
BINDING_NAME_SDNR_OPTIONS_DLG      = L["BINDING_NAME_SDNR_OPTIONS_DLG"]

SDNR_SAVED                         = L['SAVED']
SDNR_INSTANCES                     = L['INSTANCES']
SDNR_DUNGEONS                      = L['DUNGEONS']
SDNR_RAIDS                         = L['RAIDS']
SDNR_NO_SAVED_INSTANCES_FOUND      = L['NO_SAVED_INSTANCES_FOUND']
SDNR_NO_SAVED_RAID_FOUND           = L['NO_SAVED_RAID_FOUND']
LO.COMMAND_TEXT_FORMAT             = L['COMMAND_TEXT_FORMAT']
LO.COMMAND_INFO_TEXT               = L['COMMAND_INFO_TEXT']
LO.COMMAND_LIST_TEXT               = L['COMMAND_LIST_TEXT']
LO.COMMAND_CONFIG_TEXT             = L['COMMAND_CONFIG_TEXT']
LO.COMMAND_HELP_TEXT               = L['COMMAND_HELP_TEXT']
LO.OPTIONS_LABEL                   = L['OPTIONS_LABEL']
LO.USAGE_LABEL                     = L['USAGE_LABEL']
