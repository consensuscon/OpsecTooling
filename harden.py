import subprocess

def install_packages(self):
    self.apt = "sudo apt-get "
    self.ins = "install -y "
    self.packages = "fail2ban clamp clamav-daemon debsums aide libpam-cracklib acct sysstat auditd gcc libpcre3-dev zliblg-dev libluajit-5.1-dev libpcap-dev openssl libssl-dev libnghttp2-dev libdumbnet-dev bison flex libnetd"

    self.color.print_green("[+] Installation of the ubuntu packages is starting:")

    for self.items in self.packages.split():
        self.command = str(self.apt) + str(self.ins) + str(self.items)

        subprocess.run(self.command.split())
        self.color.print_blue("\t[+] Package [{}] Installed".format(str(self.items)))


if __name__ == '__main__':
    install_packages(self)