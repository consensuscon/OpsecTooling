#!/bin/bash
trap review_ctrl_c INT

function review_ctrl_c() {
        echo "Encountered CTRL-C review output for completeness ..." 
	exit;
}

echo "################################################################################################"
echo "This Script Will Upload $HOSTNAME Audit Results for Further Review!"
echo
echo "Hostname: $HOSTNAME"
echo
echo "################################################################################################"
echo "++++++++++++++UPLOADING RESULTS++++++++++++++"
chmod +x s3-upload-aws4.sh
sudo tar -czvf "$3-$HOSTNAME.tar.gz" /var/log/lynis-report.dat /var/log/lynis.log $HOSTNAME-audit.out
export AWS_ACCESS_KEY="$1"
export AWS_SECRET_KEY="$2"
./s3-upload-aws4.sh "$3-$HOSTNAME.tar.gz" validator-challenge-script us-east-2
export AWS_ACCESS_KEY=""
export AWS_SECRET_KEY=""
echo
echo "++++++++++++++EXITING UPLOAD++++++++++++++"

exit 0;