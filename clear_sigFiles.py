import os 
import os.path

###################################################################################################### 
###### DIR PARSER FUNCTION 
######################################################################################################
def cleaner (directory):
  formats = ('.sig') # list of extractor extensions (keep them in lower case)
  n = 0

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
        if fileExtension.lower() in formats and fileExtension is not '':
          fileToDelete = os.path.join(root, file)
          try:
            # os.remove(fileToDelete)
            print "File "+file+" deleted. (File extension: "+fileExtension+" )"
            n +=1
          except OSError, e:
            print ("Error: %s - %s." % (e.fileToDelete,e.strerror))

  print "\n\nAll files whit .sig extension from "+path+" deleted. Number of files: "+str(n)+"\n\n"

#######################################################################################################
############ MAIN 
#######################################################################################################
# EXAMPLE CALL python clear_sigFiles.py
outputPath = "./data/songLib.json"
dirToDelete = ["/Users/marcelfarres/Downloads", "URERED"]

for dir in dirToDelete:
  # cmd = "python parse.py"+" "+dir
  # print cmd
  # os.system(cmd)
  if not os.path.isdir(dir):
    print "Error: path "+dir+" does not exist!"
    break
  cleaner (dir)

print "\n\nAll the dir are correctly cleaned !"


