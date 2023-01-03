#!/bin/bash

### 	Memory file analisys project
###     Create functions for memory analisys including directories with carved data -
###     Using binwalk, foremost, bulk extractor, strings and volatility.


function BINWALK()	
{
	binwalk -e $MEM -C BINWALK 	   2>/dev/null
}

function FOREMOST()
{
	foremost $MEM -t all -o FOREMOST	 2>/dev/null
}

function BULK()
{
	bulk_extractor $MEM -o BULK	    1>/dev/null
}


function VOL()
{
	VOLINFO="imageinfo pslist pstree userassist sockets connections hivelist hashdump"
	
		for i in $VOLINFO
			do
				echo "Extracting $i data..."
				./vol -f $MEM $i > vol-$i  		 2>/dev/null
		done
				mkdir VOLATILITY
				mv vol-* VOLATILITY
				mkdir REGDUMP
				./vol -f $MEM dumpregistry --dump-dir REGDUMP 	1>/dev/null
}

function STR()
{
	strings $MEM > mem-strings	2>/dev/null
	mkdir STRINGS
	mv mem-strings STRINGS
}

function PASS()
{
	cd STRINGS
	grep -iRn "password" * > password-strings.lst	2>/dev/null
	cd ..
}

##### Welcome screen and instructions for the user

echo "[*] You are now using a Memory/Disk Image analisys tool! [*]"
sleep 2
echo "[!] Make sure to have a file for analisys inside current folder [!]"
sleep 1
echo "[!] Please note, multiple directories and files will be created for the analysed data.[!]"
sleep 1
echo "[!] The proccess is automatic and cannot be iterrupted.[!]"
sleep 1
echo "[!] The analysis might last starting with 20 seconds and up to a few minutes depending
on the system configuration and the file size.[!]"
sleep 1
echo "[!] Once finished, you will recieve a message about analisys completion.[!]"
sleep 1

read -p " Would you like to proceed?[y/n] " YN

### 'if' statement in order to proceed with execution of the script or abandon the operation.

if [ "$YN" == "n" ]
	then
		echo "[*] Exiting... [*]"
		exit
	else
		echo "Proceeding... Please specify the file type. For RAM select 'R', for Disk Image select 'D'"
		read -p "Provide the file ***type*** to analyse: " RD
		read -p "Provide the file ***name*** to analyse: " MEM

### In case of proceeding, file name and type are required from the user to input

case $RD in
R)
	echo "[*] $MEM was recognized as *RAM* file [*]"
		sleep 1
	echo "[*] Extracting data [*]"
		sleep 1	
		
			BINWALK
			FOREMOST
			BULK
			VOL
			STR
			PASS
;;

D)
	echo "[*] $MEM was recognized as *Disk image* file [*]"
	echo "Extracting data..."
			BINWALK
			FOREMOST
			BULK
			STR
			PASS
;;
esac

### A 'case' statement to adjust the script to function depending on the file type.

fi
	

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "[***]  The operation was succesfully completed  [***]"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo "Folders 'BULK, FOREMOST, BINWALK, VOLATILITY, REGDUMP' with carved data have been created"
sleep 1
echo "-----------------------------------------------------------------------"
echo "For network file visit /BULK/packets.pcap  [!]for RAM files only[!]"
echo "-----------------------------------------------------------------------"
echo "For registry files access directory /REGDUMP   [!]for RAM files only[!]"
echo "-----------------------------------------------------------------------"
echo "[!]Note, if you would like to re-do the analisys or use another file 
you will have to move  the created directories and files to another place 
in order to avoid rewriting and duplications[!]"
echo
echo
echo "[*] ...Goodbye!... [*]"
