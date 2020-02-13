import subprocess
import os

os.chdir("/home/sysadmin/")
packages = ["fail2ban", "clamp", "clamav-daemon", "debsums", "aide", "libpam-cracklib",
            "acct", "sysstat", "auditd", "gcc", "libpcre3-dev", "zliblg-dev", "libluajit-5.1-dev",
             "libpcap-dev", "openssl", "libssl-dev", "libnghttp2-dev", "libdumbnet-dev", "bison", 
             "flex", "libnetd"]

for package in packages:
    try:
        subprocess.Popen('sudo apt-get install -y ' + package, shell=True, stdin=None, xecutable="/bin/bash")
    except CalledProcessError as e:
        print(e.output)