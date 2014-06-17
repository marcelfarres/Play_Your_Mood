Play_Your_Mood
==============

Play Your Mood v2.0 is a music player that, after analysing all your music library (using Essentia+Gaia), creates mood-related playlist and then reproduces it depending on your mood. The mood is approximated using real time Enobio/Emotiv EEG data or also can be choose by the user (switch between master/MoodPlayer). 

In this readme you can find:
* How to install the music player whith and whithout EEG mood detection + dependences.
* How to _RUN_ the player.
* Issues.

# Install Dependences

## Essentia + Gaia  
You can follow the instructions first [Install Gaia](https://github.com/MTG/gaia/blob/master/README.md) and after [Install  Essentia](http://essentia.upf.edu/documentation/installing.html).

   NOTE: you have to install the 2.0.1 version of Essentia.  
   NOTE: before you building essentia you have to replace the `streaming_extractor_archivemusic.cpp` file in `build/src/examples/` whith the one whith the same name provided in this repo. 

## Python 
The curren version is tested under Python 2.7.7.  
You can download and install this version [here](https://www.python.org/download/releases/2.7.7/).

## GoLang 
The curren version is tested under go1.2.2.  
You can download and install this version [here](http://golang.org/dl/).

## Processing
The curren version is tested under Processing 2.2.1.  
You can download and install this version [here](https://www.processing.org/download/?processing).

## OpenViBE
   NOTE: This is only necessary if you want to use EEG version.
* Emotiv+Enobio EEG version.  
  If you want to use both you will have to build OpenViBE whith Enobio3G libs.  
  Follow this steps.  
  1. Download [OpenViBE src](http://openvibe.inria.fr/downloads/).
  1. Download [this](http://www.neuroelectrics.com/sites/neuroelectrics.com/files/enobio/enobio3Gopenvibe-v1.2.1.zip) (enobio Lib files for OpenViBE)  
  2. (Only Windows) Download and install VS2010/VS2008 ([here](http://www.visualstudio.com/en-us/downloads/download-visual-studio-vs#DownloadFamilies_4))
  2. Download and Install QT v.4.8.6 (for windos choose the VS verison you alrredy install, for Linux Qt libraries 4.8.6 for Linux/X11 )
  2. Copy `src/` and `share/` folders and contents to `OV_SOURCE_CODE/contrib/plugins/server-drivers/enobio3G` (you'll need to create this folder first).
  3. Copy `Enobio3GAPI.win` or `Enobio3GAPI.linux`, depending on your platform, to `OV_SOURCE_CODE/contrib/plugins/server-drivers/enobio3G`. For windows, you'll need to copy the contents of `MSVC/` or `MINGW/` to `Enobio3GAPI.win32`
  4. Copy `FindThirdPartyNeuroelectricsEnobio3G.cmake` to `OV_SOURCE_CODE/cmake-modules` 
  5. Edit this new file `OV_SOURCE_CODE/cmake-modules/FindThirdPartyNeuroelectrics3G.cmake` and make sure QT paths are correctly set on `QTCORE_INCLUDE_PREFIX` and `QTCORE_LIB_PREFIX variables`.
  6. Edit `OV_SOURCE_CODE/contrib/common/contribAcquisitionServerLinkLibs.cmake` and add the following line:
  `INCLUDE("FindThirdPartyNeuroelectricsEnobio3G")`  
  7. Edit `OV_SOURCE_CODE/contrib/common/contribAcquisitionServer.inl` and add the following lines, where you find similar lines for other drivers:
  ```
  #include "ovasCDriverEnobio3G.h"`
  vDriver->push_back(new OpenViBEAcquisitionServer::CDriverEnobio3G(pAcquisitionServer->getDriverContext()
  ```
  8. Edit `OV_SOURCE_CODE/contrib/common/contribAcquisitionServer.cmake` and add the following line:
  `OV_ADD_CONTRIB_DRIVER("${CMAKE_SOURCE_DIR}/contrib/plugins/server-drivers/enobio3G")`
  9. For linux, additionally, at the time of running the acquisition server, you may need to copy `libEnobio3GAPI.so*` and `libBluezBluetooth.so*` (in `ENOBIO3GAPI/libs`) to the platform dependant folder in `OV_SOURCE_CODE/dist/lib/` 
  10. For windows, additionally, at the time of running the acquisition server, you may need to copy `WinBluetoothAPI.dll` and `.lib` to `OV_SOURCE_CODE/dist`.
  11. After follow the steps in [OpenViBE build instructions](http://openvibe.inria.fr/build-instructions/). 


* Emotiv EEG version.  
  If you want to use Emotiv, you can just install the current version of OpenViBE ([here](http://openvibe.inria.fr/downloads/)).


# Issues in the current version. 
* EEG mood detection version is only working under Windows (tested) and Linux (not tested)
* 
