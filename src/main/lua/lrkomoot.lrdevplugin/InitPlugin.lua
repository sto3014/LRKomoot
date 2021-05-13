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
    prefs.hasErrors = nil
    prefs.exportCanceledByUser=nil
    prefs.showTourNameWarnings=nil
    prefs.showTourURLWarnings=nil
    prefs.defaultSubFolder = nil
    prefs.uniqueTourURL = nil
    prefs.openAnnotateURL = nil
end

-------------------------------------------------------------------------------

local function init()
    -- resetPrefs()

    logger.trace("Init plug-in")
    local prefs = LrPrefs.prefsForPlugin()
    prefs.hasErrors = false
    prefs.exportCanceledByUser = false

    if ( prefs.showTourNameWarnings == nil) then
        prefs.showTourNameWarnings = true
    end
    if ( prefs.showTourURLWarnings == nil) then
        prefs.showTourURLWarnings = true
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

