# importing os module
import os
import time

pid = os.fork()

if pid > 0:
    print("parent: {}".format(os.getpid()))
    for i in range(6):
        print("| attempt: {}".format(i))
        time.sleep(10)
    print("finish: {}".format(os.getpid()))
else:
    print("|\tchild: {}".format(os.getpid()))
    for i in range(3):
        print("|\t| attempt: {}".format(i))
        time.sleep(10)
    print("|\t| finish: {}".format(os.getpid()))
