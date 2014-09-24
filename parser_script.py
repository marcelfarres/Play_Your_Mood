import os 
import os.path
import sys
import json

###################################################################################################### 
###### DIR PARSER FUNCTION 
######################################################################################################
def parser (directory, b_id, in_index, outData):
  supportedFormatIn    = ".sig" # list of extractor extensions (keep them in lower case)
  supportedFormatCheck = [".mp3",".aiff",".wav"]# list of extractor extensions (keep them in lower case)

  path     = directory
  sig_size = 0

  #check if path exists
  if not os.path.isdir(path):
    print ("Error: path does not exist")
    return   
  # Set the id (avoid duplicate ids )
  id    = b_id;
  index = in_index 

  mood = " "
  moods = ["Sad","Relaxed","Happy","Angry"]

  # traverse root directory, and list directories as dirs and files as files
  for root, dirs, files in os.walk(path):
      for file in files:
        fileN, fileExtension = os.path.splitext(file)
        if fileExtension.lower() in supportedFormatIn:
          filePathNoExt = root+"/"+fileN;
          for extension in supportedFormatCheck:
            fullpath = root + "/"+file
            if os.path.isfile(filePathNoExt+extension) and (os.path.getsize(fullpath) > 0):
              # print fullpath +" and this is the size "+str(os.path.getsize(fullpath))
              sig_size  += os.path.getsize(fullpath)
              json_file = open(fullpath)
              # print (fullpath)
              
              data      = json.load(json_file)
              max_value = 0

              # (data["highlevel"]["danceability"]["value"])
              # (data["highlevel"]["genre_dortmund"]["value"])
              if (data["highlevel"]["mood_aggressive"]["value"]) == "aggressive":
                value = data["highlevel"]["mood_aggressive"]["probability"]
                if value > max_value:
                  mood      = "Angry"
                  max_value = value
              
              if (data["highlevel"]["mood_happy"]["value"]) == "happy":
                value = data["highlevel"]["mood_happy"]["probability"]
                if value > max_value:
                  mood      = "Happy"
                  max_value = value
              
              if (data["highlevel"]["mood_relaxed"]["value"]) == "relaxed":
                value = data["highlevel"]["mood_relaxed"]["probability"]
                if value > max_value:
                  mood      = "Relaxed"
                  max_value = value
              
              if (data["highlevel"]["mood_sad"]["value"]) == "sad":
                value = data["highlevel"]["mood_sad"]["probability"]
                if value > max_value:
                  mood      = "Sad"
                  max_value = value

              if mood  not in  moods:
                mood = "noMood"
                print ("test")

              directory = root +"/"
              fileName  = fileN+extension

              # print mood 
              # print directory
              # print fileName

              if max_value>0.5:
                outData[id] = {'id':id, 'dir':directory, 'file': fileName, 'mood': mood, 'p': max_value} 
                id += 1
                print ("    "+str(id)+"-Song: "+fileName+" from: "+root+" added.")
                # DOnar total de cancons descartades ! 
                # Mirar quin es el llindar de deciscio bo 
              else:
                print ("\nSong ("+str(max_value)+" "+mood+"): "+fileName+" from: "+root+" not added!\n" )


              index += 1
              # with open(outputPath, 'a') as outfile:
              # outfile.close
                    
              json_file.close()
            

  print ("\n\nAll files from "+path+" are in the database. Last ID(number of songs): "+str(id))
  print ("  Sig Files Size: "+str(sig_size/1000000)+" MB\n\n")
  return (id, index, outData) 

#######################################################################################################
############ MAIN 
#######################################################################################################
# EXAMPLE CALL python extract_script.py
dirToExtract = ["C:\Users\user\Desktop\TFG\Music"]
# dirToExtract = ["/Users/marcelfarres/Desktop/TFG", "/Volumes/Mac Data/MUSIC"]
outputPath   = "./data/songLib.json"
outData      = {}
id           = 0
index        = 0 

try:
    os.remove(outputPath)
except OSError:
    pass

for dir in dirToExtract:
  if not os.path.isdir(dir):
    print( "Error: path does not exist ( "+dir+")")
    continue
  # print dir
  (id, index, outData) = parser (dir, id, index, outData)

with open(outputPath, 'a') as outfile:
  json.dump([outData], outfile, sort_keys = True, indent = 4, ensure_ascii=False)
outfile.close

print ("\n\nAll the dir are correctly parsed. Songs added/total: "+str(id)+"/"+str(index)+"\n\n\n")

