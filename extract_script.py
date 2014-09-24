import os 
import os.path
import sys
import re
###################################################################################################### 
###### DIR CLEAR FUNCTION 
######################################################################################################
def cleaner (directory):
  formats = ('.sig') # list of extractor extensions (keep them in lower case)
  n       = 0

  #get path from command line argument
  path = directory

  #check if path exists
  if not os.path.isdir(path):
    print "Error: path does not exist"
    return  

  # traverse root directory, and list directories as dirs and files as files
  for root, dirs, files in os.walk(path):
      for file in files:
        fileN, fileExtension = os.path.splitext(file)
        # if any(fileExtension.lower().endswith(format) for format in formats):
        fileToDelete = os.path.join(root, file)
        if fileExtension.lower() in formats and fileExtension is not '' and os.path.getsize(fileToDelete) is 0:
          try:
            print "File "+file+" deleted. (File extension: "+fileExtension+"  File Size: "+str(os.path.getsize(fileToDelete))+" )"
            os.remove(fileToDelete)
            n +=1
          except OSError, e:
            print ("Error: %s - %s." % (e.fileToDelete,e.strerror))

  print "\n\nAll files whit .sig extension and zero size from "+path+" deleted. Number of files: "+str(n)+"\n\n"
###################################################################################################### 
###### DIR EXTRCT FUNCTION 
######################################################################################################
def extractor (directory):
  supportedFormat   = [".mp3",".aiff",".wav"] # list of extractor extensions (keep them in lower case)
  essentiaExtractor = "./code/essentia/streaming_extractor_archivemusic" # path of the essentia binary to use
  essentiaModels    = "./code/essentia/" # path of the essentia models lib

  path = directory

  total_files  = 0
  done_files   = 0
  extract_fies = 0

  # check if path exists
  if not os.path.isdir(path):
    print "Error: path does not exist"
    return  
  for root, dirs, files in os.walk(path):
      for file in files:
        fileName, fileExtension = os.path.splitext(file)
        if fileExtension.lower() in supportedFormat:
          total_files += 1

  # traverse root directory, and list directories as dirs and files as files
  for root, dirs, files in os.walk(path):
      for file in files:
        fileName, fileExtension = os.path.splitext(file)
        if fileExtension.lower() in supportedFormat:
          done_files += 1
          if os.path.isfile(root+"/"+fileName+".sig"):
            print "The sig file ("+fileName+") already exist!"
            print ("   %d/100 Done! (%d/%d)" % (100*done_files/total_files, done_files, total_files))
          else:
            fullpath = root + "/"+file
            # print fullpath
            # create the command line to be launched
            if "'" in fileName or root:
              # print "There is a ( ' ) in the path! Change command line construction."
              # Prevent other threads to analyse the file
              t = open(root+'/'+fileName+'.sig', 'a')
              t.close()
              cmd = essentiaExtractor +' "'+fullpath+'" "'+root+'/'+fileName+'.sig"'+' '+'"'+essentiaModels+'"'
            else:
              t = open(root+"/"+fileName+".sig", 'a')
              t.close()
              cmd = essentiaExtractor +" '"+fullpath+"' '"+root+"/"+fileName+".sig'"+" "+"'"+essentiaModels+"'"
            print "\n Command Line ==> "+cmd+"\n"
            #launches the command line
            os.system(cmd)
            extract_fies += 1
            # Print progress information
            print ("   %d/100 Done! Files extracted: %d  Total: (%d/%d)" % (100*done_files/total_files, extract_fies, done_files, total_files))
            print "\n"
#######################################################################################################
############ MAIN 
#######################################################################################################
# EXAMPLE CALL python extract_script.py
def main ():
  dirToExtract = ["/Users/marcelfarres/Music", "/Users/marcelfarres/Desktop/TFG", "/Volumes/Mac Data/MUSIC"]

  for dir in dirToExtract:
    if not os.path.isdir(dir):
      print "Error: path does not exist"
      continue 
    else:
      cleaner(dir)
      extractor (dir)

  print "All the dir are correctly processed"

if __name__ == "__main__":
  main()