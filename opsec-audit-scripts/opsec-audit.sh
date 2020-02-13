#!/bin/bash
trap review_ctrl_c INT

function review_ctrl_c() {
        echo "Encountered CTRL-C review output for completeness ..." 
	exit;
}

echo "################################################################################################"
echo "This Script Will Help Audit Your Linux Machine for the Celo Master Validator Challenge!"
echo
echo "This script will execute speedtest-cli, lynis, perform some extra checks and upload results:"
echo "Note: it has been tested for Debian/Centos:"
echo
echo "Hostname: $HOSTNAME"
echo
echo "################################################################################################"

container_name=''
log_only="false"

print_usage() {
  echo "Usage: ./opsec_audit -c <container_name> -l(log_only)"
  echo "-c <container_name"   "name of container you are auditing"
  echo "-h		  			  show usage"
  echo "-l					  write output to log file"
}

while getopts 'c:l' flag; do
  case "${flag}" in
	c) container_name="${OPTARG}" ;;
    l) log_only="true" ;;
    *) print_usage
       exit 1 ;;
  esac
done

echo
echo "[+] Executing Lynis"
echo "------------------------------------"
sudo chown -R 0:0 lynis
cd lynis
if [ "$log_only" = "true" ]; then
	sudo ./lynis audit system "--nocolors"
else
	sudo ./lynis audit system 
fi
cd ..
echo
echo "[+] Checking Kernel"
echo "------------------------------------"
sudo grep -Ei "no kernel update available" /var/log/lynis.log
sudo grep -Ei "os_kernel_version_full" /var/log/lynis-report.dat
echo
echo "[+] Checking Automatic Updates"
echo "------------------------------------"
sudo grep -Ei "unattended_upgrade_tool|unattended_upgrade_option" /var/log/lynis-report.dat
echo
echo "[+] Checking Security Framework"
echo "------------------------------------"
sudo grep -Ei "apparmor_enabled|apparmor_policy_loaded|selinux_status|selinux_mode|framework_selinux" /var/log/lynis-report.dat
echo
echo "[+] Checking Insecure Services/Vulnerable Programs"
echo "------------------------------------"
echo "Check Lynis Output"
echo
echo "[+] Checking GRUB"
echo "------------------------------------"
sudo grep -Ei "suggestion\[\]\=BOOT-5122" /var/log/lynis-report.dat
echo
echo "[+] Checking File Permissions"
echo "------------------------------------"
sudo grep -Ei "suggestion\[\]\=FILE-7524" /var/log/lynis-report.dat
echo "No Output is Positive"
echo
echo "[+] Check Blank Passwords"
echo "------------------------------------"
sudo grep -Ei "warning\[\]\=AUTH-9283" /var/log/lynis-report.dat
echo "No Output is Positive"
echo
echo "[+] Check Password Strength Tools"
echo "------------------------------------"
sudo grep -Ei "suggestion\[\]\=AUTH-9262" /var/log/lynis-report.dat
echo
echo "DEBIAN"
echo "common-auth"
sudo cat /etc/pam.d/common-auth
echo
echo "common-password"
sudo cat /etc/pam.d/common-password
echo
echo "CentOS-RHEL"
sudo cat /etc/pam.d/system-auth
sudo cat /etc/security/pwquality.conf
echo
echo "[+] Check IDS"
echo "------------------------------------"
sudo grep ids_ips_tooling /var/log/lynis-report.dat
echo "No Output Is Negative - Check Lynis Output for Software: System tooling"
echo
echo "[+] IPTables"
echo "------------------------------------"
echo "Check Lynis Output"
echo
echo "####################################"
echo "IPTables Rules For Manual Review"
echo "####################################"
sudo iptables -L
echo "####################################"
echo
echo
echo "[+] SSH"
echo "------------------------------------"
sudo grep -Ei "PermitRootLogin|PasswordAuthentication|ChallengeResponseAuthentication|UsePAM|AllowUsers|AllowGroups" /etc/ssh/sshd_config
echo
echo "[+] Check Docker File Permissions"
echo "------------------------------------"
echo "Check Lynis Output"
echo
echo "[+] Downloading and Executing Speedtest"
echo "------------------------------------"
chmod +x speedtest-cli
./speedtest-cli
echo
echo "[+] Check Ledger"
echo "------------------------------------"
echo
echo "Check Docker Image and Accounts ..."
echo
echo "[+] Processes/Containers"
echo "------------------------------------"
if [ -z "$container_name" ]; then
	sudo ps -ef | grep geth
else
	sudo docker container ls --no-trunc --format='{{json .}}'
fi
echo
echo "[+] Application Logs"
echo "------------------------------------"
if [ -z "$container_name" ]; then
	sudo journalctl -n 100|grep geth
else
	sudo docker logs $container_name --tail 10
fi
echo
echo "[+] Accounts (only viable for validator and attestation)"
echo "------------------------------------"
if [ -z "$container_name" ]; then
	geth account list
else
	sudo docker exec -it $container_name geth account list
fi
echo
echo "[+] Check Ledger"
echo "------------------------------------"
echo
echo "Checking USB Presence of Ledger ..."
sudo lsusb -d "2c97:"
echo
echo "++++++++++++++AUDIT SCRIPT FINISHED++++++++++++++"

exit 0;