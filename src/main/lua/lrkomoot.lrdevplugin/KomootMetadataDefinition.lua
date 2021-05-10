require "PluginInit"

local logger = require("Logger")

-------------------------------------------------------------------------------

local KomootMetadataDefinition = {
    metadataFieldsForPhotos = {
        {
            id = 'siteId',
        },

        {
            id = 'tourName',
            title = LOC "$$$/Komoot/Metadata/Fields/TourName=TourName",
            dataType = 'string', -- Specifies the data type for this field.
            browsable = true,
            searchable = true,
        },

        {
            id = 'komootUrl',
            title = LOC "$$$/Komoot/Metadata/Fields/Display/KomootURL=Komoot URL",
            version = 1,
            dataType = 'url',
            searchable = true,
            browsable = true,
        },
    },

    schemaVersion = 1, -- must be a number, preferably a positive integer
}

-------------------------------------------------------------------------------

function KomootMetadataDefinition.updateFromEarlierSchemaVersion(catalog, previousSchemaVersion)
    -- Note: This function is called from within a catalog:withPrivateWriteAccessDo
    -- block. You should not call any of the with___Do functions yourself.

    catalog:assertHasPrivateWriteAccess("CustomMetadataDefinition.updateFromEarlierSchemaVersion")

    if previousSchemaVersion == 1 then

        -- Retrieve photos that have been used already with the custom metadata.

        local photosToMigrate = catalog:findPhotosWithProperty(PluginInit.pluginID, 'siteId')

        -- Optional:  can add property version number here.

        for _, photo in ipairs(photosToMigrate) do
            local oldSiteId = photo:getPropertyForPlugin(PluginInit.pluginID, 'siteId') -- add property version here if used above
            local newSiteId = "new:" .. oldSiteId -- replace this with whatever data transformation you need to do
            photo:setPropertyForPlugin(_PLUGIN, 'siteId', newSiteId)
        end
    elseif previousSchemaVersion == 2 then

        -- Optional area to do further processing etc.
    end
end

-------------------------------------------------------------------------------

return KomootMetadataDefinition
