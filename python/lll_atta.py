import os

txt = "C:\oracle_output.txt"
f1 = os.open(txt, os.O_RANDOM)
print(f1)
f2 = open(txt)
print(f2.read())
print(f2)