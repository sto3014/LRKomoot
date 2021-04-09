--[[----------------------------------------------------------------------------

Info.lua
Summary information for custom metadata sample plugin

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2008 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

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
	
	VERSION = { major=1, minor=0, revision=0, build=0, },

}
