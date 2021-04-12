# LRKomoot

# Features
Lightroom Classic plugin which add some simple functionalities for the route planner [Komoot](https://www.komoot.com).
* Komoot metadata
* Export service
* Library filter

At the time the API of Komoot does not support upload of photos. Therefore, this plugin cannot provide a 
publishing service.

## Komoot metadata
The new metadata set Komoot is made available.
It displays some standard metadata, the Komoot metadata and the EFIX metadata.
The Komoot metadata consists of two fields:
* Komoot Tour  
  Can hold the Komoot name. It can also used as subfolder during export.
  Must be manual maintained.
* Komoot URL  
  Can hold a Komoot URL which points to the tour. The small button at the end of the filed 
  brings you directly to the desired Komoot page. 
  Must be manual maintained.
## Export service
The standard settings of the Komoot service exports the selected photos to your picture folder. 
As subfolder the value of the *Komoot Tour* field is taken. In case that not all photos have
the same Komoot Tour value the photos will be exported into the picture folder itself.
Be also aware that the *Put in subfolder* checkbox in the export dialog is checked.
## Library filter
A filter named *Komoot* uses the *Date*, the *Komoot Tour* and the *Komoot URL*. Even when 
its active it displays all photos, but you can use it as a starting point for creating your 
own filters.

# Installation
Clone the LRKomoot repository or download the zip archive from [GitHub](https://github.com/sto3014/LRKomoot)
Execute the install script for your operating system:
* install.sh for Mac
* install.bat for Windows  

The script extracts the corresponding zip archive (target/LRKomoot1.0.0_mac.zip or 
  target/LRKomoot1.0.0_win.zip) into your user directory

