return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 2.0,
	LrToolkitIdentifier = 'at.homebrew.lrkomoot',

	LrPluginName = LOC "$$$/Komoot/PluginName=Komoot",

	-- Add the Metadata Definition File
	LrMetadataProvider = 'KomootMetadataDefinition.lua',
	
	-- Add the Metadata Tagset File
	LrMetadataTagsetFactory = {
		'KomootMetadataTagset.lua',
	},

	LrExportServiceProvider = {
		title = "Komoot",
		file = "KomootExportServiceProvider.lua",
	},

	LrInitPlugin = "InitPlugin.lua",
	LrPluginInfoProvider = "InfoProvider.lua",
	
	VERSION = { major=1, minor=1, revision=1, build=1, },

}
