#!/usr/bin/env python

import socket
import netaddr
import ftplib

def ftpconn(ip):
	f=open("/home/jbt/myscripts/users_pass.txt","r")
	for line in f:
		user,passwd=line.split()
		try:
			ftp=ftplib.FTP(ip,user,passwd)
			pwd=ftp.pwd()
			print "Successfully connected ftp to %s, pwd is: %s"%(ip,pwd)
		except Exception as e:
			pass
	f.close()
	ftp.close()
	
def getans(ip, port):
	socket.setdefaulttimeout(2)
	try:
		s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
		s.connect((ip,port))
		print "Successfully connected to %s:%s"%(ip,port)
		ans=s.recv(1024)
		if ans:
			print "Recieved answer from %s:%s"%(ip,port)
			print "Answer: %s"%(ans)
		if port==21:
			ftpconn(ip)
	except Exception as e:
		print "Error connecting to %s:%s: %s"%(ip,port,e)
	finally:
		s.close()

segment=raw_input("Please enter the wanted segment in X.X.X.X/X format: ")
ports=raw_input("Please enter the wanted ports: ").split()
for ip in netaddr.IPNetwork(segment):
	for j in ports:
		getans(str(ip),int(j))
