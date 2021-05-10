--
-- Created by IntelliJ IDEA.
-- User: Dieter Stockhausen
-- Date: 02.05.21
-- To change this template use File | Settings | File Templates.
-------------------------------------------------------------------------------
local LrPrefs = import "LrPrefs"

local logger = require("Logger")
-------------------------------------------------------------------------------

local InitProvider = {}

-------------------------------------------------------------------------------

local function resetPrefs()
    local prefs = LrPrefs.prefsForPlugin()
    prefs.showTourDialog=nil
    prefs.defaultSubFolder = nil
    prefs.lastExportedKomootURL = nil
    prefs.openAnnotateURL = nil
end

-------------------------------------------------------------------------------

local function init()
    -- resetPrefs()

    logger.trace("Init plug-in")
    local prefs = LrPrefs.prefsForPlugin()
    prefs.hasErrors = false

    if ( prefs.showTourDialog == nil) then
        prefs.showTourDialog = true
    end

    if ( prefs.defaultSubFolder == nil or prefs.defaultSubFolder == "") then
        prefs.defaultSubFolder = "LR2Komoot"
    end

    if ( prefs.openAnnotateURL == nil) then
        prefs.openAnnotateURL = true
    end

    logger.trace("Init done.")
end

-------------------------------------------------------------------------------

init()

