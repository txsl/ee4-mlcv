@echo off
mkdir %2
ECHO "Copying %1 to %2." 
xcopy %1 %2 /e /Y