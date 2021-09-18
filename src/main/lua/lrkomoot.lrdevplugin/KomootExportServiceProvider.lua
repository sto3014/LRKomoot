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
        if (prefs.showTourNameWarnings) then
            local status = LrDialogs.confirm(#photosNoTourName > 1
                    and LOC("$$$/Komoot/TourName/DiffBothMany=Photos have ^1 different tour names and ^2 tour names are not set.", differentToursCount, #photosNoTourName)
                    or LOC("$$$/Komoot/TourName/DiffBothOne=Photos have ^1 different tour names and one tour name is not set.", differentToursCount),
                    LOC("$$$/Komoot/TourName/ExportedIn=Photos will exported in subfolder '^1'.", prefs.defaultSubFolder))
            if (status ~= "ok") then
                prefs.exportCanceledByUser = true
                return nil
            end
        end
        subFolder = "LR2Komoot"
    else
        if (differentTours) then
            logger.trace("Different tours found.")
            if (prefs.showTourNameWarnings) then
                local status = LrDialogs.confirm(LOC("$$$/Komoot/TourName/DiffNames=Photos have different tour names."),
                        LOC("$$$/Komoot/TourName/ExportedIn=Photos will exported in subfolder '^1'.", prefs.defaultSubFolder))
                if (status ~= "ok") then
                    prefs.exportCanceledByUser = true
                    return nil
                end
            end
            subFolder = "LR2Komoot"
        else
            if (#photosNoTourName > 0) then
                if (subFolder ~= nil and subFolder ~= "") then
                    logger.trace("Empty  tours found.")
                    if (prefs.showTourNameWarnings) then
                        local status = LrDialogs.confirm(#photosNoTourName > 1
                                and LOC("$$$/Komoot/TourName/EmptyMany=^1 tour names are not set.", #photosNoTourName)
                                or LOC("$$$/Komoot/TourName/EmptyOne=One tour name is not set."),
                                LOC("$$$/Komoot/TourName/ExportedIn=Photos will exported in subfolder '^1'.", subFolder))
                        if (status ~= "ok") then
                            prefs.exportCanceledByUser = true
                            return nil
                        end
                    end
                else
                    logger.trace("Only empty  tours found.")
                    if (prefs.showTourNameWarnings) then
                        local status = LrDialogs.confirm(LOC("$$$/Komoot/TourName/AllEmpty=All tour names are not set."),
                                LOC("$$$/Komoot/TourName/ExportedIn=Photos will exported in subfolder '^1'.", prefs.defaultSubFolder))
                        if (status ~= "ok") then
                            prefs.exportCanceledByUser = true
                            return nil
                        end
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
                local idxHash=1
                idxHash = string.find(anyTourUrl, "#", idxHash)
                if ( idxHash == nil) then
                    annotateURL = anyTourUrl .. "/annotate/photos"
                else
                    annotateURL = string.sub(anyTourUrl, 1, idxHash - 1) .. "/annotate/photos"
                end
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
--- Function extract the tour id out of a tour URL.
--- Returns
---     The tour id
---     nil, if no id could be found.
-------------------------------------------------------------------------------------
local function getTourID(anyTourUrl)
    logger.trace("Enter getTourID")
    if (anyTourUrl == nil or anyTourUrl == "") then
        return nil
    end
    logger.trace(anyTourUrl)

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
                local idxHash=1
                idxHash = string.find(currentSub, "#", idxHash)
                if ( idxHash == nil) then
                    id = currentSub
                else
                    id = string.sub(currentSub, 1, idxHash - 1)
                end
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
        logger.trace("Tour ID '" .. tostring(id) .. "' is  not valid")
        logger.trace("Exit getTourID")
        return nil
    else
        logger.trace("Tour ID: " .. tostring(id))
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
    logger.trace("Enter getUniqueTourURL")

    local activeCatalog = LrApplication.activeCatalog()
    local photos = activeCatalog:getTargetPhotos()
    local firstValidURL
    local prevID = ""
    local tourID
    local differentTours = false
    local invalidTourIDs = 0
    local notSetTourIDs = 0

    for _, photo in ipairs(photos) do
        logger.trace("Photo: " .. photo:getFormattedMetadata("fileName"))
        local tourURL = (photo:getPropertyForPlugin(PluginInit.pluginID, 'komootUrl'))
        logger.trace("Tour URL: " .. tostring(tourURL))
        if (tourURL ~= nil and tourURL ~= "") then
            tourID = getTourID(tourURL)
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
            else
                invalidTourIDs = invalidTourIDs + 1
            end
        else
            notSetTourIDs = notSetTourIDs + 1
        end
    end

    local prefs = LrPrefs.prefsForPlugin()

    if (not differentTours) then
        if (firstValidURL == nil) then
            logger.trace("No valid Tour URL found.")
            if (prefs.showTourURLWarnings) then
                local status = LrDialogs.confirm(LOC("$$$/Komoot/URL/NotValid=No valid tour URL found."),
                        LOC("$$$/Komoot/URL/NotOpenBrowser=Annotation page will not be opened."))
                if (status ~= "ok") then
                    prefs.exportCanceledByUser = true
                    return nil
                end
            end
        else
            if (invalidTourIDs == 0 and notSetTourIDs == 0) then
                logger.trace("First valid tour URL will be used: " .. tostring(firstValidURL))
                logger.trace("Exit getUniqueTourURL")
            else
                if (invalidTourIDs > 0 and notSetTourIDs == 0) then
                    logger.trace("Invalid tour URL found.")
                    if (prefs.showTourURLWarnings) then
                        local status = LrDialogs.confirm(
                                invalidTourIDs > 1
                                        and LOC("$$$/Komoot/URL/HasInvalidURLMany=^1 tour URLs are invalid.", invalidTourIDs)
                                        or LOC("$$$/Komoot/URL/HasInvalidURLOne=One tour URL is invalid."),
                                LOC("$$$/Komoot/URL/OpenBrowserInValidURLs=Annotation page will be opened with the valid URL found."))
                        if (status ~= "ok") then
                            prefs.exportCanceledByUser = true
                            return nil
                        end

                    end
                else
                    if (invalidTourIDs == 0 and notSetTourIDs > 0) then
                        logger.trace("Not set tour URL found.")
                        if (prefs.showTourURLWarnings) then
                            local status = LrDialogs.confirm(
                                    notSetTourIDs > 1
                                            and LOC("$$$/Komoot/URL/HasNotSetURLMany=^1 tour URLs are not set.", notSetTourIDs)
                                            or LOC("$$$/Komoot/URL/HasNotSetURLOne=One tour URL is not set."),
                                    LOC("$$$/Komoot/URL/OpenBrowserInValidURLs=Annotation page will be opened with the valid URL found."))
                            if (status ~= "ok") then
                                prefs.exportCanceledByUser = true
                                return nil
                            end

                        end
                    else
                        logger.trace("Invalid and not set tour URL found.")
                        if (prefs.showTourURLWarnings) then
                            local status = LrDialogs.confirm(
                                    LOC("$$$/Komoot/URL/HasInvalidAndNotSetURLMany=^1 tour URLs are invalid resp. not set.", invalidTourIDs + notSetTourIDs),
                                    LOC("$$$/Komoot/URL/OpenBrowserInValidURLs=Annotation page will be opened with the valid URL found."))
                            if (status ~= "ok") then
                                prefs.exportCanceledByUser = true
                                return nil
                            end
                        end
                    end
                end
            end
        end
        return firstValidURL
    else
        logger.trace("Different tours found. No Tour URL can be taken.")
        if (prefs.showTourURLWarnings) then
            local status = LrDialogs.confirm(LOC("$$$/Komoot/URL/MultiURLs=More than one valid tour URL found."),
                    LOC("$$$/Komoot/URL/NotOpenBrowser=Annotation page will not be opened."))
            if (status ~= "ok") then
                prefs.exportCanceledByUser = true
                return nil
            end

        end
        logger.trace("Exit getUniqueTourURL")
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
    local prefs = LrPrefs.prefsForPlugin()
    prefs.exportCanceledByUser = false

    if (exportSettings.LR_export_useSubfolder == true and exportSettings.LR_export_destinationPathSuffix == "") then
        local subFolder = getSubFolder()

        if (prefs.exportCanceledByUser) then
            logger.trace("Export interrupted by user.")
            return
        end
        exportSettings.LR_export_destinationPathSuffix = subFolder
    end

    if (prefs.openAnnotateURL) then
        prefs.uniqueTourURL = getUniqueTourURL()
        if (prefs.exportCanceledByUser) then
            logger.trace("Export interrupted by user.")
            return
        end
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
    if prefs.hasErrors or prefs.exportCanceledByUser then
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
