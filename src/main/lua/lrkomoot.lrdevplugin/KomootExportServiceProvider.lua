--[[---------------------------------------------------------------------------
-- Created by Dieter Stockhausen
-- Created on 11.04.21
-----------------------------------------------------------------------------]]
require("PluginInit")
local LrApplication = import("LrApplication")
local LrDialogs = import 'LrDialogs'
local LrPrefs = import("LrPrefs")
local LrTasks = import("LrTasks")
local logger = require("Logger")

-------------------------------------------------------------------------------
--- Properties
-------------------------------------------------------------------------------
local exportServiceProvider = {
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
--- Function to generate a subfolder according to the property tourName.
--- Returns
---     value of the first tourName found, if all photos have the same tourName.
---         Photos with tourName not set will be ignored
---     "LR2Komoot", if all photos have tourName not set, or if tourName is not
---         unique.
-------------------------------------------------------------------------------
local function getSubFolder()

    logger.trace("Enter getSubFolder")
    local activeCatalog = LrApplication.activeCatalog()
    local photos = activeCatalog:getTargetPhotos()
    local subFolder = nil
    local previousSubfolder = ""
    local photosNoTourName = {}
    local indexNoTour = 1
    local differentTours = false
    local differentToursCount = 1

    for _, photo in ipairs(photos) do
        logger.trace("Photo: " .. photo:getFormattedMetadata("fileName"))
        local currentSubFolder = (photo:getPropertyForPlugin(PluginInit.pluginID, 'tourName'))
        logger.trace("Tour name: " .. tostring(currentSubFolder))

        if (currentSubFolder == nil or currentSubFolder == "") then
            photosNoTourName[indexNoTour] = photo
            indexNoTour = indexNoTour + 1
        else
            if (previousSubfolder == "") then
                subFolder = currentSubFolder
                previousSubfolder = currentSubFolder
            else
                if (previousSubfolder ~= currentSubFolder) then
                    differentTours = true
                    differentToursCount = differentToursCount + 1
                end
            end
        end
    end

    local prefs = LrPrefs.prefsForPlugin()

    if (differentTours and #photosNoTourName > 0) then
        logger.trace("Different and empty tours found.")
        if (prefs.showTourDialog) then
            LrDialogs.message(#photosNoTourName > 1
                    and LOC("$$$/Komoot/TourName/DiffBothMany=Photos have ^1 different tour names and ^2 tour names are not set.", differentToursCount, #photosNoTourName)
                    or LOC("$$$/Komoot/TourName/DiffBothOne=Photos have ^1 different tour names and one tour name is not set.", differentToursCount),
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
                        LrDialogs.message(#photosNoTourName > 1
                                and LOC("$$$/Komoot/TourName/EmptyMany=^1 tour names are not set.", #photosNoTourName)
                                or LOC("$$$/Komoot/TourName/EmptyOne=One tour name is not set."),
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
    logger.trace("Chosen folder: " .. tostring(subFolder))

    logger.trace("Exit getSubFolder")
    return subFolder
end

-------------------------------------------------------------------------------
--- Function to convert a tour URL to a URL which points to the annotation page
--- of the tour
--- The format of the tour URL is
--- <protocol>://<komoot server>/tour/<tour id>[/...]
--- Example
---     https://www.komoot.de/tour/12345678
---     https://www.komoot.de/tour/12345678/zoom
--- Returns
---     The annotation URL. Example:
---         https://www.komoot.de/tour/12345678/annotate/photos
---     nil, if the tour URL is not valid
-------------------------------------------------------------------------------
local function getAnnotateURL(anyTourUrl)
    logger.trace("Enter getAnnotateURL")

    if (anyTourUrl == nil or anyTourUrl == "") then
        return nil
    end

    -- LrMobdebug.on()

    local idxSlash = 1
    local count = 0
    local annotateURL
    while (true) do
        idxSlash = string.find(anyTourUrl, "/", idxSlash)
        if (idxSlash == nil) then
            break
        end
        idxSlash = idxSlash + 1
        local currentSub = string.sub(anyTourUrl, idxSlash)
        logger.trace("Idx = " .. tostring(idxSlash) .. ", substring: " .. currentSub)
        count = count + 1
        if (count == 4) then
            idxSlash = string.find(anyTourUrl, "/", idxSlash)
            if (idxSlash == nil) then
                annotateURL = anyTourUrl .. "/annotate/photos"
            else
                annotateURL = string.sub(anyTourUrl, 1, idxSlash - 1) .. "/annotate/photos"
            end
            break
        end
    end

    logger.trace("Exit getAnnotateURL")
    return annotateURL
end

----------------------------------------------------------------------------------
--- Function extract the tour id out of a tour URL
--- Returns
---     The tour id
---     nil, if no id could be found.
-------------------------------------------------------------------------------------
local function getTourID(anyTourUrl)
    logger.trace("Enter getTourID")
    if (anyTourUrl == nil or anyTourUrl == "") then
        return nil
    end

    local idxSlash = 1
    local count = 0
    local id = nil
    while (true) do
        idxSlash = string.find(anyTourUrl, "/", idxSlash)
        if (idxSlash == nil) then
            break
        end
        idxSlash = idxSlash + 1
        local currentSub = string.sub(anyTourUrl, idxSlash)
        logger.trace("Idx = " .. tostring(idxSlash) .. ", substring: " .. currentSub)
        count = count + 1
        if (count == 4) then
            idxSlash = string.find(anyTourUrl, "/", idxSlash)
            if (idxSlash == nil) then
                id = currentSub
            else
                idxSlash = string.find(currentSub, "/")
                if (idxSlash ~= nil) then
                    id = string.sub(currentSub, 1, idxSlash - 1)
                end
            end
            break
        end
    end

    if (id == nil or id == "" or id:match("^%-?%d+$") == nil) then
        logger.trace("Exit getTourID")

        return nil
    else
        logger.trace("Exit getTourID")

        return id
    end

end

-------------------------------------------------------------------------------
--- Function determines the unique tour URL
--- Example
---     https://www.komoot.de/tour/12345678
---     https://www.komoot.de/tour/12345678/zoom
--- Returns
---     The tour URL for the first valid tour URL found.
---         Empty URLs or URLs where no tour id were found are just ignored.
---     nil, if the tour ids found are not unique, or if no tour id could be
---         found at all
-------------------------------------------------------------------------------
local function getUniqueTourURL()
    logger.trace("Enter getCurrentKomootURL")

    local activeCatalog = LrApplication.activeCatalog()
    local photos = activeCatalog:getTargetPhotos()
    local firstValidURL
    local prevID = ""
    local tourID
    local differentTours = false

    for _, photo in ipairs(photos) do
        logger.trace("Photo: " .. photo:getFormattedMetadata("fileName"))
        local tourURL = (photo:getPropertyForPlugin(PluginInit.pluginID, 'komootUrl'))
        logger.trace("Komoot URL: " .. tostring(tourURL))
        if (tourURL ~= nil and tourURL ~= "") then
            tourID = getTourID(tourURL)
            logger.trace("Tour ID: " .. tostring(tourID))
            if (tourID ~= nil) then
                firstValidURL = tourURL
                if (prevID == "") then
                    prevID = tourID
                else
                    if (prevID ~= tourID) then
                        logger.trace("PrevID: " .. tostring(prevID) .. ", currID: " .. tostring(tourID))
                        differentTours = true
                        break
                    end
                end
            end
        end
    end

    if (not differentTours) then
        if (firstValidURL == nil) then
            LrDialogs.message(LOC("$$$/Komoot/URL/NotValid=No valid Komoot URL found."),
                    LOC("$$$/Komoot/URL/NotOpenBrowser=Annotation page will not be opened."), "info")
            logger.trace("No valid Komoot URL found.")
        else
            logger.trace("First valid Komoot URL will be used: " .. tostring(firstValidURL))
            logger.trace("Exit getCurrentKomootURL")
        end
        return firstValidURL
    else
        LrDialogs.message(LOC("$$$/Komoot/URL/MultiURLs=More than one valid tour URL found."),
                LOC("$$$/Komoot/URL/NotOpenBrowser=Annotation page will not be opened."), "info")
        logger.trace("Different tours found. No Komoot URL can be taken.")
        logger.trace("Exit getCurrentKomootURL")
        return nil
    end
end
----------------------------------------------------------------------------------
--- hook updateExportSettings
---     If use subfolder is checked in the export preset and there is no value
---     defined for the subfolder, the subfolder will be set to a name of tour
---
---     If the annotation page should be opened after the export, the URL is
---     determined.
-------------------------------------------------------------------------------------

function exportServiceProvider.updateExportSettings (exportSettings)
    logger.trace("Enter updateExportSettings")
    if (exportSettings.LR_export_useSubfolder == true and exportSettings.LR_export_destinationPathSuffix == "") then
        subFolder = getSubFolder()
        exportSettings.LR_export_destinationPathSuffix = subFolder
    end
    local prefs = LrPrefs.prefsForPlugin()
    if (prefs.openAnnotateURL) then
        prefs.uniqueTourURL = getUniqueTourURL()
    end

    logger.trace("Exit updateExportSettings")
end

----------------------------------------------------------------------------------
--- hook processRenderedPhotos
---     Exports the photos.
---
---     Opens annotation URL after export
-------------------------------------------------------------------------------------
function exportServiceProvider.processRenderedPhotos(functionContext,
                                                     exportContext)

    local prefs = LrPrefs.prefsForPlugin()
    if prefs.hasErrors then
        return
    end

    --
    -- Export photos
    --
    local exportSession = exportContext.exportSession
    local nPhotos = exportSession:countRenditions()
    -- Progress bar
    local progressScope = exportContext:configureProgress {
        title = nPhotos > 1 and
                LOC("$$$/Komoot/ProgressMany=Export ^1 photos for Komoot", nPhotos)
                or LOC "$$$/Komoot/ProgressOne=Export one photo for Komoot",
    }

    for i, rendition in exportContext:renditions { stopIfCanceled = true } do
        -- Wait for the upstream task to finish its work on this photo.
        local success, pathOrMessage = rendition:waitForRender()
        if success then
            logger.trace("Exported " .. pathOrMessage .. " successfully")
        else
            logger.trace(pathOrMessage .. " could not be exported")
        end
    end


    --
    -- Annotation page
    --
    if (not prefs.openAnnotateURL) then
        return
    end

    logger.trace("Unique tour URL: " .. tostring(prefs.uniqueTourURL))
    if (prefs.uniqueTourURL ~= nil and prefs.uniqueTourURL ~= "") then
        cmd = getAnnotateURL(prefs.uniqueTourURL)
        logger.trace("Annotate URL: " .. tostring(cmd))
        if (cmd ~= nil and cmd ~= "") then
            if (WIN_ENV) then
                cmd = 'start ' .. cmd
            else
                cmd = 'open ' .. cmd
            end
            logger.trace("Execute: " .. cmd)
            local status = LrTasks.execute(cmd)
        end
    end

end

-------------------------------------------------------------------------------

return exportServiceProvider
