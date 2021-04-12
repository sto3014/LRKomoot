require ("PluginInit")
local LrApplication = import("LrApplication")
local LrLogger = import("LrLogger")
local logger = LrLogger("KomootLrLogger")
logger:enable("logfile")
--
function getSubFolder()
  local activeCatalog = LrApplication.activeCatalog()
  local photos = activeCatalog:getTargetPhotos()
  local subFolder
  local previousSubfolder=""
  for _, photo in ipairs( photos ) do
    subFolder = (photo:getPropertyForPlugin( PluginInit.pluginID, 'tourName'))
    if ( subFolder==nil or subFolder == "") then
      subFolder=""
      break
    else
      if ( previousSubfolder == "") then
        previousSubfolder=subFolder
      else
        if ( previousSubfolder ~= subFolder) then
          subFolder=""
          break
        end
      end
    end
  end
  logger:trace("Chosen folder: " .. subFolder)
  return subFolder
end
function initSettings (exportSettings )
  if ( exportSettings.LR_export_useSubfolder == true and exportSettings.LR_export_destinationPathSuffix == "") then
    subFolder = getSubFolder()
    exportSettings.LR_export_destinationPathSuffix =  subFolder
  end
end
--
return {
  -- endDialog = initSettings,
  updateExportSettings = initSettings,
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
