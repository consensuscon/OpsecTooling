#!/bin/bash
trap review_ctrl_c INT

function review_ctrl_c() {
        echo "Encountered CTRL-C review output for completeness ..." 
	exit;
}

echo "################################################################################################"
echo "This Script Will Help Audit Your Linux Machine for the Celo Master Validator Challenge!"
echo
echo "This script will execute opsec-audit and opsec-uploader if the appropriate flags are set."
echo "Note: it has been tested for Debian/Centos:"
echo
echo "Hostname: $HOSTNAME"
echo
echo "################################################################################################"

access_key=''
container_name=''
secret_key=''
audit_number=''
upload="false"
log_only="false"

print_usage() {
  echo "Usage: ./opsec_wrapper -a <access_key> -c <container_name> -l(log_only) -n <audit_number> -s <secret_key> -u(enable uploads)"
  echo "-a <access_key>       access key for s3 bucket"
  echo "-c <container_name"   "name of container you are auditing"
  echo "-h		  			  show usage"
  echo "-l					  write output to log file"
  echo "-n <audit_number.     number of this audit"
  echo "-s <secret_key>       secret key for s3 bucket"
  echo "-u,       			  enable uploading"
}

while getopts 'a:c:ln:s:u' flag; do
  case "${flag}" in
    a) access_key="${OPTARG}" ;;
	c) container_name="${OPTARG}" ;;
    l) log_only="true" ;;
    n) audit_number="${OPTARG}" ;;
    s) secret_key="${OPTARG}" ;;
    u) upload="true" ;;
    *) print_usage
       exit 1 ;;
  esac
done

echo "++++++++++++++EXECUTING LYNIS++++++++++++++"
chmod +x opsec-audit.sh
if [ "$log_only" = "true" ]; then
	./opsec-audit.sh -c "$container_name" -l &> $HOSTNAME-audit.out
else
	./opsec-audit.sh -c "$container_name"
fi

if [ "$upload" = "true" ]; then
	echo "++++++++++++++UPLOADING RESULTS++++++++++++++"
	chmod +x opsec-uploader.sh 	
	./opsec-uploader.sh $access_key $secret_key $audit_number
	echo
else
	echo "++++++++++++++UPLOADING NOT ENABLED++++++++++++++"
fi
echo "++++++++++++++EXITING++++++++++++++"

exit 0;