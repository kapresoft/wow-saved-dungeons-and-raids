-- SEE: https://github.com/BigWigsMods/packager/wiki/Localization-Substitution
local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true);

-- ###################### No Translations ######################
L['Version'] = true
L['Curse-Forge'] = true
L['Bugs'] = true
L['Repo'] = true
L['Last-Update'] = true
L['Interface-Version'] = true
L['Locale'] = true
-- ###################### /No Translations ######################

L['Addon Info']                                     = 'Addon Info'
L["BINDING_NAME_SDNR_OPTIONS_DLG"]                  = 'Options Dialog'

L['SAVED']                                          = 'Saved'
L['INSTANCES']                                      = 'Instances'
L['DUNGEONS']                                       = 'Dungeons'
L['RAIDS']                                          = 'Raids'
L['NO_SAVED_INSTANCES_FOUND']                       = 'No saved instance found'
L['NO_SAVED_RAID_FOUND']                            = 'No saved raid found'
L['COMMAND_TEXT_FORMAT']                            = '%s Initialized. Type %s on the console for available commands.'
L['COMMAND_INFO_TEXT']                              = ':: Prints additional addon info'
L['COMMAND_LIST_TEXT']                              = ':: Prints the saved dungeons and raids on the console'
L['COMMAND_CONFIG_TEXT']                            = ':: Shows the config UI'
L['COMMAND_HELP_TEXT']                              = ':: Shows this help'
L['OPTIONS_LABEL']                                  = 'options'
L['USAGE_LABEL']                                    = 'usage'
