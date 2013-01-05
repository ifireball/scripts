@ECHO off
REM unison-auto.bat
REM Run Unison to synchronize files while using Pagent
REM for authentication
REM
"c:\Program Files\PuTTY\pageant.exe" c:\Users\ifireball\.ssh\ifireball@barakroam2.ppk
c:\cygwin\bin\ssh-pageant.exe c:\cygwin\bin\unison.exe -contactquietly autosync-windows
