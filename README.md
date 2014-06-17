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
  If you want to use both follow this steps. 
** asdf
If you want to use Emotiv, you can just install the current version of OpenViBE ([here](http://openvibe.inria.fr/downloads/)).
If you want to use Enobio, 


# Issues in the current version. 
* EEG mood detection version is only working under Windows (tested) and Linux (not tested)
* 
