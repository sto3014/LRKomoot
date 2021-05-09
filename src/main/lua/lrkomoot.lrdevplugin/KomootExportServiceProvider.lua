require ("PluginInit")
local LrApplication = import("LrApplication")
local LrDialogs = import 'LrDialogs'

local LrMobdebug = import 'LrMobdebug' -- Import LR/ZeroBrane debug module
LrMobdebug.start()

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
  local previousSubfolder=""
  local photosNoTourName = {}
  local indexNoTour= 1
  local differentTours = false
  LrMobdebug.on()

  for _, photo in ipairs( photos ) do
    subFolder = (photo:getPropertyForPlugin( PluginInit.pluginID, 'tourName'))
    if ( subFolder==nil or subFolder == "") then
      photosNoTourName[indexNoTour] = photo
      indexNoTour = indexNoTour +1
    else
      if ( previousSubfolder == "") then
        previousSubfolder=subFolder
      else
        if ( previousSubfolder ~= subFolder) then
          differentTours = true
          break
        end
      end
    end
  end
  if ( differentTours and #photosNoTourName >0) then
    logger.trace("Different and empty tours found.")
    LrDialogs.message("Photos have different tour names and " .. #photosNoTourName .. " tour names are not set.", "Photos will exported in subfolder 'LR2Komoot'.",  "info")
    subFolder="LR2Komoot"
  else
    if ( differentTours ) then
      logger.trace("Different tours found.")
      LrDialogs.message("Photos have different tour names.", "Photos will exported in subfolder 'LR2Komoot'.",  "info")
      subFolder="LR2Komoot"
    else
      if ( #photosNoTourName >0) then
        if ( subFolder ~= nil and subFolder ~= "") then
          logger.trace("Empty  tours found.")
          LrDialogs.message(#photosNoTourName .. " tour names are not set.", "All photos will exported in subfolder '" .. subFolder .."'",  "info")
        else
          logger.trace("Only empty  tours found.")
          LrDialogs.message("All tour names are not set.", "All photos will exported in subfolder 'LR2Komoot'.",  "info")
          subFolder="LR2Komoot"
        end
      end
    end

  end
  logger.trace("Chosen folder: " .. subFolder)
  return subFolder
end

-------------------------------------------------------------------------------

function KomootExportServiceProvider.updateExportSettings (exportSettings )
  if ( exportSettings.LR_export_useSubfolder == true and exportSettings.LR_export_destinationPathSuffix == "") then
    subFolder = getSubFolder()
    exportSettings.LR_export_destinationPathSuffix =  subFolder
  end
end

-------------------------------------------------------------------------------

return KomootExportServiceProvider
