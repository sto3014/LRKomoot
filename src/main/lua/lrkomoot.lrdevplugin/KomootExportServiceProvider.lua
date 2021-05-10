require("PluginInit")
local LrApplication = import("LrApplication")
local LrDialogs = import 'LrDialogs'
local LrPrefs = import("LrPrefs")
local LrTasks = import("LrTasks")
local logger = require("Logger")

-- local LrMobdebug = import 'LrMobdebug' -- Import LR/ZeroBrane debug module
-- LrMobdebug.start()

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
    local subFolder = nil
    local tourURL = nil
    local previousSubfolder = ""
    local photosNoTourName = {}
    local indexNoTour = 1
    local differentTours = false

    for _, photo in ipairs(photos) do
        local currentSubFolder = (photo:getPropertyForPlugin(PluginInit.pluginID, 'tourName'))
        local currentTourURL = (photo:getPropertyForPlugin(PluginInit.pluginID, 'komootUrl'))
        if (currentSubFolder == nil or currentSubFolder == "") then
            photosNoTourName[indexNoTour] = photo
            indexNoTour = indexNoTour + 1
        else
            if (previousSubfolder == "") then
                subFolder = currentSubFolder
                tourURL = currentTourURL
                previousSubfolder = currentSubFolder
            else
                if (previousSubfolder ~= subFolder) then
                    differentTours = true
                    break
                end
            end
        end
    end
    local prefs = LrPrefs.prefsForPlugin()
    prefs.lastExportedKomootURL = nil

    if (differentTours and #photosNoTourName > 0) then
        logger.trace("Different and empty tours found.")
        if (prefs.showTourDialog) then
            LrDialogs.message(LOC("$$$/Komoot/TourName/DiffBoth=Photos have different tour names and ^1 tour names are not set.", photosNoTourName),
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
                    prefs.lastExportedKomootURL = tourURL
                else
                    logger.trace("Only empty  tours found.")
                    if (prefs.showTourDialog) then
                        LrDialogs.message(LOC("$$$/Komoot/TourName/AllEmpty=All tour names are not set."),
                                LOC("$$$/Komoot/TourName/ExportedIn=Photos will exported in subfolder '^1'.", prefs.defaultSubFolder), "info")
                    end
                    subFolder = prefs.defaultSubFolder
                end
            else
                prefs.lastExportedKomootURL = tourURL
            end
        end
    end
    logger.trace("Chosen folder: " .. subFolder)
    return subFolder
end

-------------------------------------------------------------------------------
local function getAnnotateURL(anyTourUrl)
    if (anyTourUrl == nil or anyTourUrl == "") then
        return nil
    end

    -- LrMobdebug.on()

    local idxSlash = 1
    local count = 0
    local annotateURL
    local id
    while (true) do
        idxSlash = string.find(anyTourUrl, "/", idxSlash)
        if (idxSlash == nil) then
            break
        end
        idxSlash = idxSlash +1
        local currentSub = string.sub(anyTourUrl, idxSlash)
        logger.trace("Idx = " .. tostring(idxSlash) .. ", substring: " .. currentSub)
        count = count + 1
        if (count == 4) then
            idxSlash = string.find(anyTourUrl, "/", idxSlash)
            if (idxSlash == nil) then
                annotateURL = anyTourUrl .. "/annotate/photos"
                id = currentSub
            else
                annotateURL = string.sub(anyTourUrl, 1, idxSlash -1) .. "/annotate/photos"
                idxSlash =  string.find(currentSub,"/")
                if ( idxSlash ~= nil) then
                    id = string.sub(currentSub,1, idxSlash -1 )
                end
            end
            break
        end
    end

    logger.trace("ID: " .. tostring(id))
    if ( id == nil or id == "" or id:match("^%-?%d+$") == nil) then
        LrDialogs.message(LOC("$$$/Komoot/URL/NotValid=Komoot URL does not seem to be valid."),
                LOC("$$$/Komoot/URL/NotOpenBrowser=URL '^1' will not be opened.", tostring(annotateURL)), "critical")
        annotateURL = nil
    end
    return annotateURL
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

----------------------------------------------------------------------------------

function KomootExportServiceProvider.processRenderedPhotos(functionContext,
                                                           exportContext)
    --LrMobdebug.on()
    prefs = LrPrefs.prefsForPlugin()
    if prefs.hasErrors then
        return
    end

    if (not prefs.openAnnotateURL) then
        return
    end

    for i, rendition in exportContext:renditions { stopIfCanceled = true } do
        -- Wait for the upstream task to finish its work on this photo.
        local success, pathOrMessage = rendition:waitForRender()
        if success then
            logger.trace("Exported " .. pathOrMessage .. " successfully")
        else
            logger.trace(pathOrMessage .. " could not be exported")
        end
    end

    logger.trace("lastExportedKomootURL: " .. tostring(prefs.lastExportedKomootURL))

    if (prefs.lastExportedKomootURL ~= nil and prefs.lastExportedKomootURL ~= "") then
        cmd = getAnnotateURL(prefs.lastExportedKomootURL)
        logger.trace("Annotate URL: " .. tostring(cmd))
        if ( cmd ~= nil and cmd ~= "" ) then
            if (WIN_ENV) then
                cmd = '"start /wait /min "Komoot" ' .. cmd
            else
                cmd = 'open ' .. cmd
            end
            logger.trace("Execute: " .. cmd)
            local status = LrTasks.execute(cmd)

        end
    end

end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

return KomootExportServiceProvider
