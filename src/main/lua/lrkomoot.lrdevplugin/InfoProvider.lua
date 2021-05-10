local LrView = import("LrView")
local LrPrefs = import("LrPrefs")
local logger = require("Logger")
-------------------------------------------------------------------------------

local InfoProvider = {}

-------------------------------------------------------------------------------

function InfoProvider.sectionsForTopOfDialog(f, _)
    logger:trace("sectionsForTopOfDialog")
    local prefs = LrPrefs.prefsForPlugin()
    return {
        {
            title = LOC("$$$/Komoot/PluginSettings=Plug-in Settings"),
            bind_to_object = prefs,
            f:row {
                f:static_text {
                    title = LOC("$$$/Komoot/TourNameDialog/Title=Tour name dialog"),
                    width_in_chars = 19,
                },
                f:checkbox {
                    title = LOC("$$$/Komoot/TourNameDialog/Show=Show"),
                    value = LrView.bind("showTourDialog"),
                    --checked_value = true, -- this is the initial state
                    --unchecked_value = false,
                },
            },
        },
    }
end

-------------------------------------------------------------------------------

function InfoProvider.sectionsForBottomOfDialog(f, property_table)
   return {}
end

-------------------------------------------------------------------------------

return InfoProvider