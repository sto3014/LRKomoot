# LRKomoot

# Features
Lightroom Classic plug-in which add some simple functionalities for the route planner [Komoot](https://www.komoot.com):
* Komoot metadata
* Export service
* Library filter

At the time the API of Komoot does not support upload of photos. Therefore, this plugin cannot provide a 
publishing service.

## Installation
* Download the zip archive for your operating system from [GitHub](https://github.com/sto3014/LRKomoot/tree/main/target).
* Extract the archive into your home directory.
* Restart Lightroom

## Komoot metadata
The new metadata set Komoot is made available.
It displays some standard metadata, the Komoot metadata and the EFIX metadata.
The Komoot metadata consists of two fields:
* Tour Name  
  Can hold the Komoot tour name. It will be used as subfolder during export.
  Must be manual maintained.
* Tour URL  
  Can hold the Komoot tour URL. It is used to open the photo annotation 
  page after export.  
  Must be manual maintained.
## Export service
The standard settings of the Komoot service exports the selected photos to your picture folder. 
As subfolder, the value of the *Tour Name* field is taken. In case that not all photos have
the same tour name value the photos will be exported into a subfolder named "LR2Komoot".

Tour names are only taken as subfolder when the *Put in Subfolder* field in the export preset is empty, and 
the checkbox is selected.

After the export the Komoot photo annotation page will be opened. For this to work, you must set the
tour URL field. This URL must point to a valid tour in Komoot. Examples:
* https://www.komoot.de/tour/12345678
* https://www.komoot.de/tour/12345678/zoom

## Library filter
A filter named *Komoot* uses the *Date*, the *Tour Name* and the *Tour URL*. Even when 
its active it displays all photos, but you can use it as a starting point for creating your 
own filters.

## Plug-in Settings
After Export
* The *Open Annotation Page* checkbox controls if the photo annotation page should be opened after export or not.

Show Warnings
* The *Tour Names*  checkbox controls if any warning concerning the validity of the tour names should be
  displayed during export. 
* The *Tour URLs*  checkbox controls if any warning concerning the validity of the tour URLs should be
  displayed during export. 


