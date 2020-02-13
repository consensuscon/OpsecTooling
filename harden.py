from subprocess import check_call, CalledProcessError
import os

packages = ["fail2ban", "clamp", "clamav-daemon", "debsums", "aide", "libpam-cracklib",
            "acct", "sysstat", "auditd", "gcc", "libpcre3-dev", "zliblg-dev", "libluajit-5.1-dev",
             "libpcap-dev", "openssl", "libssl-dev", "libnghttp2-dev", "libdumbnet-dev", "bison", 
             "flex", "libnetd"]

for package in packages:
    try:
        check_call(['sudo apt-get', 'install', '-y', package], stdout=open(os.homesysadmin, 'wb'))
    except CalledProcessError as e:
        print(e.output)