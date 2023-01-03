#!/bin/bash


if [ "$(whoami)" != "root" ] 
then
	echo "You are not root! EXITING ..."
exit
fi


	echo "Your IPV4 and your netmask:"
	ifconfig | head -n2 | grep -i inet | awk '{print $1 ,$2 ,$3 ,$4}'
	echo "[!] Please specify your network range or a single IP to scan:"
	read RANGE
	echo
	
function WELCOME() {
	DIR=$(echo $RANGE | cut -b -12)
	echo "Creating directory..."
	sleep 2
	mkdir $DIR
	cd $DIR
	echo
	echo "[*] The Directory Created!"
	sleep 2
	pwd
} 
 

function SCAN() {
	echo
	echo "[*] Starting Nmap Scan, Please Wait!"
	sleep 1
	sudo nmap $RANGE -sV --open -T5 -oN nmapScans.txt 1>/dev/null 2>/dev/null
	sudo nmap $RANGE -sV --open -T5 -oX nmapScans.xml 1>/dev/null 2>/dev/null
	xsltproc nmapScans.xml -o nmapScans.html 1>/dev/null 2>/dev/null
	sleep 1
	echo 
	echo "[!] Done."
	sleep 1
	cat nmapScans.txt | grep -i scan | grep -i report | awk '{print $5}' > HOSTS.txt
}


function NSE() {
	echo
	echo "[*] Starting Nmap Scan for NSE, Please Wait!"
	sudo nmap -sV --open -T5 --script vuln $RANGE -oX NSE.xml 1>/dev/null 2>/dev/null
	xsltproc NSE.xml -o NSE.html 1>/dev/null 2>/dev/null
	sleep 2
	echo 
	echo "[!] Done."
	echo
}


function SEARCHSPLOIT() {
	echo "[*] Starting SearchSploit Scan, Please Wait!"
	searchsploit --exclude="Privilege Escalation" --nmap nmapScans.xml > searchsploit.txt  2>/dev/null
	sleep 2
	echo
	echo "[!] Done."
	echo
}

function BRUTEFORCE() {
	echo "[*] Starting Hydra.."
	echo
	echo "[!] Create usernames list (CTRL+D to save)"
	cat > user.lst
	echo
	echo "[!] Create password list (CTRL+D to save)"
	cat > pass.lst
	echo
	echo
	read -p "[!] Select a service to Brute-Force (ftp, ssh, smb, rdp, etc.)" SERVICE
	echo
	echo "[*] Brute-forcing the service.."
	hydra -L user.lst -P pass.lst -M HOSTS.txt $SERVICE -V > hydra.txt 2>/dev/null
	cat hydra.txt | grep -iv Attempt | grep -iv Data | grep -iv targets | grep -iv hydra > BRUTED.txt ; 	rm hydra.txt
	echo 
	echo "[!] Done."
}


 function LOG() {
	echo "Number of discovered hosts:" > LOG.txt
	cat HOSTS.txt | wc -l >> LOG.txt
	echo "Total Open Ports:" >> LOG.txt
	cat nmapScans.txt | grep -i open | grep -i /tcp | sort | uniq | wc -l >> LOG.txt
	echo "Number of VSFTPD vuln. found [searchsploit]:" >> LOG.txt
	cat searchsploit.txt | grep -i vsftpd | sort | uniq | wc -l >> LOG.txt
	echo "Number of OpenSSH vuln. found [searchsploit]:" >> LOG.txt
	cat searchsploit.txt | grep -i OpenSSH | sort | uniq | wc -l >> LOG.txt
	echo "Number of ProFTPd vuln. found [searchsploit]:" >> LOG.txt
	cat searchsploit.txt | grep -i ProFTPd | sort | uniq | wc -l >> LOG.txt
	echo "Number of RpcBind Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat searchsploit.txt | grep -i rpcbind | sort | uniq | wc -l >> LOG.txt
	echo "Number of PostgreSQL Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat searchsploit.txt | grep -i PostgreSQL | sort | uniq | wc -l >> LOG.txt
	echo "Number of VNC Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat searchsploit.txt | grep -i VNC | sort | uniq | wc -l >> LOG.txt
	echo "Number of successfully bruteforced cridentials:" >> LOG.txt
	cat BRUTED.txt | wc -l >> LOG.txt
}

function MENU() {
	EXIT=EXIT
		while [ "$EXIT" = EXIT ]; 
do
		echo "[*] Enter [1] - Nmap Results(HTML, wait..)" 
		echo "[*] Enter [2] - NSE Results(HTML, wait..)"
		echo "[*] Enter [3] - Hosts List Results"
		echo "[*] Enter [4] - Hydra Cracked Results"
		echo "[*] Enter [5] - Searchsploits Results"
		echo "[*] Enter [6] - View Log"
		echo "[*] Enter [EXIT] - For EXIT ..."
		echo
		read -p "[!] Select [1-6]:" SLCT
			case $SLCT in
			1)
			open nmapScans.html 2>/dev/null
			;;
			2)
			open NSE.html 2>/dev/null
			;;
			3)
			cat HOSTS.txt
			;;
			4)
			cat BRUTED.txt
			;;
			5)
			cat searchsploit.txt
			;;
			6)
			cat LOG.txt
			;;
			EXIT)
			exit 
			;;
			esac 
done
}

WELCOME
SCAN
NSE
SEARCHSPLOIT
BRUTEFORCE
LOG
MENU

