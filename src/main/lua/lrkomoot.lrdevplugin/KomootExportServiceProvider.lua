require("PluginInit")
local LrApplication = import("LrApplication")
local LrDialogs = import 'LrDialogs'
local LrPrefs = import("LrPrefs")
local logger = require("Logger")

-------------------------------------------------------------------------------

local KomootExportServiceProvider = {
    allowFileFormats = {
        "JPEG",
        "TIFF",
    },
    hideSections = {
        "postProcessing",
        "video",
        "watermarking",
    },
}

-------------------------------------------------------------------------------

local function getSubFolder()
    local activeCatalog = LrApplication.activeCatalog()
    local photos = activeCatalog:getTargetPhotos()
    local subFolder
    local previousSubfolder = ""
    local photosNoTourName = {}
    local indexNoTour = 1
    local differentTours = false

    for _, photo in ipairs(photos) do
        subFolder = (photo:getPropertyForPlugin(PluginInit.pluginID, 'tourName'))
        if (subFolder == nil or subFolder == "") then
            photosNoTourName[indexNoTour] = photo
            indexNoTour = indexNoTour + 1
        else
            if (previousSubfolder == "") then
                previousSubfolder = subFolder
            else
                if (previousSubfolder ~= subFolder) then
                    differentTours = true
                    break
                end
            end
        end
    end
    local prefs = LrPrefs.prefsForPlugin()

    if (differentTours and #photosNoTourName > 0) then
        logger.trace("Different and empty tours found.")
        if (prefs.showTourDialog) then
            LrDialogs.message( LOC("$$$/Komoot/TourName/DiffBoth=Photos have different tour names and ^1 tour names are not set.", photosNoTourName),
                    LOC("$$$/Komoot/TourName/ExportedIn=Photos will exported in subfolder '^1'.", prefs.defaultSubFolder), "info")
        end
        subFolder = "LR2Komoot"
    else
        if (differentTours) then
            logger.trace("Different tours found.")
            if (prefs.showTourDialog) then
                LrDialogs.message(LOC("$$$/Komoot/TourName/DiffNames=Photos have different tour names."),
                        LOC("$$$/Komoot/TourName/ExportedIn=Photos will exported in subfolder '^1'.", prefs.defaultSubFolder), "info")
            end
            subFolder = "LR2Komoot"
        else
            if (#photosNoTourName > 0) then
                if (subFolder ~= nil and subFolder ~= "") then
                    logger.trace("Empty  tours found.")
                    if (prefs.showTourDialog) then
                        LrDialogs.message(LOC("$$$/Komoot/TourName/Empty=^1 tour names are not set.", #photosNoTourName),
                                LOC("$$$/Komoot/TourName/ExportedIn=Photos will exported in subfolder '^1'.", subFolder), "info")
                    end
                else
                    logger.trace("Only empty  tours found.")
                    if (prefs.showTourDialog) then
                        LrDialogs.message(LOC("$$$/Komoot/TourName/AllEmpty=All tour names are not set."),
                                LOC("$$$/Komoot/TourName/ExportedIn=Photos will exported in subfolder '^1'.", prefs.defaultSubFolder), "info")
                    end
                    subFolder = prefs.defaultSubFolder
                end
            end
        end

    end
    logger.trace("Chosen folder: " .. subFolder)
    return subFolder
end

-------------------------------------------------------------------------------
function KomootExportServiceProvider.startDialog(propertyTable)
    logger.trace("startDialog")
end
function KomootExportServiceProvider.endDialog(propertyTable, why)
    logger.trace("endDialog:" .. why)
end
----------------------------------------------------------------------------------

function KomootExportServiceProvider.updateExportSettings (exportSettings)
    if (exportSettings.LR_export_useSubfolder == true and exportSettings.LR_export_destinationPathSuffix == "") then
        subFolder = getSubFolder()
        exportSettings.LR_export_destinationPathSuffix = subFolder
    end
end

-------------------------------------------------------------------------------

return KomootExportServiceProvider
