--[[----------------------------------------------------------------------------

KomootMetadataTagset.lua
Sample custom metadata tagset

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2008 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

return{

	title = LOC "$$$/Metadata/Tagset/Title=Custom Metadata",
	id = 'CustomMetadataTagset',
	
	items = {
		{ 'com.adobe.label', label = LOC "$$$/Metadata/OrigLabel=Standard Metadata" },
		'com.adobe.filename',
		'com.adobe.folder',
		
		'com.adobe.separator',
		
		'com.adobe.title',
		{ 'com.adobe.caption', height_in_lines = 3 },

		'com.adobe.separator',

		{ "com.adobe.copyrightState", pruneRedundantFields = false },
		"com.adobe.copyright",

		'com.adobe.separator',
		{
			formatter = "com.adobe.label",
			label = LOC "$$$/Metadata/Tagset/Title=Komoot",
		},

		'at.homebrew.lrkomoot.tourName',

		{'at.homebrew.lrkomoot.komootUrl', height_in_lines = 2},

		"com.adobe.separator",
		{
			formatter = "com.adobe.label",
			label = LOC "$$$/Metadata/ExifLabel=EXIF",
		},

		"com.adobe.imageFileDimensions",		-- dimensions
		"com.adobe.imageCroppedDimensions",

		"com.adobe.exposure",					-- exposure factors
		"com.adobe.brightnessValue",
		"com.adobe.exposureBiasValue",
		"com.adobe.flash",
		"com.adobe.exposureProgram",
		"com.adobe.meteringMode",
		"com.adobe.ISOSpeedRating",

		"com.adobe.focalLength",				-- lens info
		"com.adobe.focalLength35mm",
		"com.adobe.lens",
		"com.adobe.subjectDistance",

		"com.adobe.dateTimeOriginal",
		"com.adobe.dateTimeDigitized",
		"com.adobe.dateTime",

		"com.adobe.make",						-- camera
		"com.adobe.model",
		"com.adobe.serialNumber",

		"com.adobe.userComment",

		"com.adobe.artist",
		"com.adobe.software",

		"com.adobe.GPS",						-- gps
		"com.adobe.GPSAltitude",
		"com.adobe.GPSImgDirection",

	},
}
