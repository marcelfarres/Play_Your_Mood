# #############################################################
# ## Version 1
# import multiprocessing 
# import os 

# def worker (x):
#   cmd = "python extract_script.py" 
#   print "This is worker: "+str(x) 
#   os.system(cmd)

# core_num = multiprocessing.cpu_count()

# if __name__ == '__main__':
#   for x in range(core_num):
#     p = multiprocessing.Process(target=worker(x))
#     p.start()

# ##########################################################
# ## Version 2
# import sys
# import subprocess
# import multiprocessing 


# core_num = multiprocessing.cpu_count()
# print "Total Numer of cores: "+str(core_num)

# procs = []
# for i in range(core_num):
#   print "This is core: "+str(i)
#   proc = subprocess.Popen([sys.executable, 'extract_script.py'])
#   procs.append(proc)

# # for proc in procs:
# #   proc.wait()

# ############################################################
# ## Version 3
# import multiprocessing 
# import os 

# core_num = multiprocessing.cpu_count()
# cmd = ""
# for x in range(core_num):
#   cmd +="python extract_script.py & \n"

# print cmd 

# # os.system(cmd)

# ###########################################################
# ## Version 4
# import multiprocessing 
# import extract_script
# # import os 

# def main():
#   core_num = multiprocessing.cpu_count()
#   for x in range(core_num):
#     extract_script.main()

# if __name__ == "__main__":
#   main()
