import subprocess
import os

def install_deps():
    os.chdir("/home/sysadmin/")
    packages = ["fail2ban", "clamp", "clamav-daemon", "debsums", "aide", "libpam-cracklib",
                "acct", "sysstat", "auditd", "gcc", "libpcre3-dev", "zliblg-dev", "libluajit-5.1-dev",
                "libpcap-dev", "openssl", "libssl-dev", "libnghttp2-dev", "libdumbnet-dev", "bison", 
                "flex", "libnetd"]

    for package in packages:
        process = subprocess.Popen('sudo apt-get install -y ' + package, shell=True, stdin=None, executable="/bin/bash")
        process.wait()

def configure_node_exporter():
    server = "172.31.18.149"
    os.chdir("/home/sysadmin/")
    make_node_user = subprocess.Popen('useradd --no-create-home --shell /bin/false node_exporter', shell=True, stdin=None, executable="/bin/bash")
    make_node_user.wait()
    get_node_exporter = subprocess.Popen('wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz && tar xvf node_exporter-0.18.1.linux-amd64.tar.gz && cd node_exporter-0.18.1.linux-amd64',
                                          shell=True, stdin=None, executable="/bin/bash")
    get_node_exporter.wait()
    os.chdir("/home/sysadmin/node_exporter-0.18.1.linux-amd64")
    set_permissions = subprocess.Popen('cp node_exporter /usr/local/bin && chown node_exporter:node_exporter /usr/local/bin/node_exporter',
                                        shell=True, stdin=None, executable="/bin/bash")
    set_permissions.wait()
    os.chdir("/home/sysadmin/")
    clean_up = subprocess.Popen('rm -rf node_exporter-0.18.1.linux-amd64 node_exporter-0.18.1.linux-amd64.tar.gz', shell=True, stdin=None, executable="/bin/bash")
    clean_up.wait()
    os.chdir("/etc/systemd/system/")
    f = open("node_exporter.service", "w+")
    f.write("[Unit] \n"
            "Description=Node Exporter \n"
            "Wants=network-online.target \n"
            "After=network-online.target \n \n"

            "[Service] \n"
            "User=node_exporter \n"
            "Group=node_exporter \n"
            "Type=simple \n"
            "ExecStart=/usr/local/bin/node_exporter \n \n"

            "[Install] \n"
            "WantedBy=multi-user.target")
    f.close()
    open_port = subprocess.Popen('ufw allow from ' + server + ' to any port 9100', shell=True, stdin=None, executable="/bin/bash")
    open_port.wait()
    enable_service = subprocess.Popen('systemctl daemon-reload && systemctl enable node_exporter && systemctl start node_exporter', shell=True, stdin=None, executable="/bin/bash")
    enable_service.wait()
    print('node exporter installed')

def configure_snort():
    os.chdir("/home/sysadmin/OpsecTooling/snort/daq-2.0.6")
    build_daq_binaries = subprocess.Popen('./configure && make && make install', shell=True, stdin=None, executable="/bin/bash")
    build_daq_binaries.wait()

    os.chdir("/home/sysadmin/OpsecTooling/snort/snort-2.9.15.1")
    build_snort_binaries = subprocess.Popen('./configure -—enable-sourcefire && make && make install', shell=True, stdin=None, executable="/bin/bash")
    build_snort_binaries.wait()

    # snort_config('ldconfig && ln -s /usr/loca/bin/snort /usr/sbin/snort && grouped snort')

if __name__=="__main__":
    # configure_node_exporter()
    configure_snort()
    