Play_Your_Mood
==============

Play Your Mood v2.0 is a music player that, after analysing all your music library (using Essentia+Gaia), creates mood-related play-list and then reproduces it depending on your mood. The mood is approximated using real time Enobio/Emotiv EEG data or also can be choose by the user (switch between master/MoodPlayer). 

In this readme you can find:
* How to install the music player with and without EEG mood detection + dependences.
* How to _RUN_ the player.
* Issues.

# Install Dependencies

## Essentia + Gaia  
You can follow the instructions first [Install Gaia](https://github.com/MTG/gaia/blob/master/README.md) and after [Install  Essentia](http://essentia.upf.edu/documentation/installing.html).

   NOTE: you have to install the **2.0.1** version of Essentia.  
   NOTE: before you building Essentia you have to replace the `streaming_extractor_archivemusic.cpp` file in `build/src/examples/` with the one with the same name provided in this repository. 

## Python 
The current version is tested under **Python 2.7.7**.  
You can download and install this version [here](https://www.python.org/download/releases/2.7.7/).

## GoLang 
The current version is tested under **go 1.2.2**.  
You can download and install this version [here](http://golang.org/dl/).

## Processing
The current version is tested under **Processing 2.2.1**.  
You can download and install this version [here](https://www.processing.org/download/?processing).

## OpenViBE
   NOTE: This is only necessary if you want to use EEG version.
* **Emotiv+Enobio EEG version.**  
  If you want to use both you will have to build OpenViBE with Enobio3G libs.  
  Follow this steps.  
  1. Download [OpenViBE src](http://openvibe.inria.fr/downloads/).
  1. Download [this](http://www.neuroelectrics.com/sites/neuroelectrics.com/files/enobio/enobio3Gopenvibe-v1.2.1.zip) (enobio Lib files for OpenViBE)  
  2. (Only Windows) Download and install VS2010/VS2008 ([here](http://www.visualstudio.com/en-us/downloads/download-visual-studio-vs#DownloadFamilies_4))
  2. Download and Install QT v.4.8.6 (for windows choose the VS version you already install, for Linux Qt libraries 4.8.6 for Linux/X11 )
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


* **Emotiv EEG version.**  
  If you want to use Emotiv, you can just install the current version of OpenViBE ([here](http://openvibe.inria.fr/downloads/)).

# Run Play Your Mood 
In order to use the EEG version (online/offline) follow the next steps.

**Preparation.**  
  1. Compile `enobioDSP` and `enobioFileClient` from `eegMood` (open cmd inside each folder and then run `go build`).
  1. Copy `streaming_extractor_archivemusic` from `/build/src/examples/` to `/code/essentia/`.
  2. Copy the `svm_models` folder from `/build/src/examples/` to `/code/essentia/`.
  3. Edit `extract_script.py` line 94, `parser_script.py` line 100 and `clear_sigFiles.py` line 39 and add your musics path. 
  4. Run as many cores your machine have `extraxt_script.py` ( from cmd `python extraxt_script.py`).
  5. When step 4 is compled, run `parser_script.py` ( from cmd `python parser_script.py`).

**Run the program.**  
  6. Open `openvibe-designer.cmd` from `src/dist` and load:
    1. If on-line mode `load Arousal-Valence-Enobio-online.xml` or `Arousal-Valence-Emotiv-online.xml` from `OpenViBE_config` folder.
    2. If off-line mode `load Arousal-Valence-Enobio-offline.xml` or `Arousal-Valence-Emotiv-offline.xml` from `OpenViBE_config` folder.  
      NOTE: Remember to choose input file.
  7. (if on-line)Open `openvibe-adquisition-server.cmd`
    1. Choose Enobio/Emotiv device from the drivers list 
    2. Check that connection port is `1024`.
    3. (if Enobio) Open Driver Properties and 
      1. Set number of channels. 
      2. Set mac address (rear in Enobio device). 
      3. Load `Enobio_ch_config.txt` (in `OpenViBE_config`) or enter electrode names for each channel.
    4. Click `Connect`.
    5. Click `Play`.
  8. Click `Play` from `openvibe-designer`.
  9. Execute `enobioFileClient.exe`.
  10. Open `Play_Your_Mood.pde` with Processing and press `Play`. 
  11. Wait for 1 min in order that the program runs smooth (Arousal and Valence values must be different to 1 and -1)

In order to use the non EEG version follow the next steps.

**Preparation.**  
  1. Copy `streaming_extractor_archivemusic` from `/build/src/examples/` to `/code/essentia/`.
  2. Copy the `svm_models` folder from `/build/src/examples/` to `/code/essentia/`.
  3. Edit `extract_script.py` line 94, `parser_script.py` line 100 and `clear_sigFiles.py` line 39 and add your musics path. 
  4. Run as many cores your machine have `extraxt_script.py` ( from cmd `python extraxt_script.py`).
  5. When step 4 is compled, run `parser_script.py` ( from cmd `python parser_script.py`).

**Run the program.**  
  1. Open `Play_Your_Mood.pde` with Processing and press `Play`. 

    **GENERAL NOTE: Is not required but recommended to run `extract_script.py` and  `parser_script.py` every time you use the program.**  
    **GENERAL NOTE: You can change the song by pressing `n` and pause it by pressing `p`.**  
    **GENERAL NOTE: You can export the app by `File --> Export Application`.**  
    **GENERAL NOTE: You can clear all sig files generated by using `clear_sigFiles.py` (uncomment line 27 after testing!).**  
    
# Issues in the current version. 
* EEG mood detection version is only working under Windows (tested) and Linux (not tested) due to OpenViBE dependency.

