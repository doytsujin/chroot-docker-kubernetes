# chroot script for Ubuntu 20
echo "Creating the chroot jail in Ubuntu..."
sudo mkdir /home/jailbird

sudo mkdir /home/jailbird/bin
sudo cp /bin/bash /home/jailbird/bin/bash

sudo mkdir /home/jailbird/lib
sudo mkdir /home/jailbird/lib/x86_64-linux-gnu
sudo mkdir /home/jailbird/lib64

sudo cp /lib/x86_64-linux-gnu/libtinfo.so.6 /home/jailbird/lib/x86_64-linux-gnu
sudo cp /lib/x86_64-linux-gnu/libdl.so.2 /home/jailbird/lib/x86_64-linux-gnu
sudo cp /lib/x86_64-linux-gnu/libc.so.6 /home/jailbird/lib/x86_64-linux-gnu
sudo cp /lib64/ld-linux-x86-64.so.2 /home/jailbird/lib64

sudo cp /bin/ls /home/jailbird/bin/ls

sudo cp /lib/x86_64-linux-gnu/libselinux.so.1 /home/jailbird/lib/x86_64-linux-gnu
sudo cp /lib/x86_64-linux-gnu/libc.so.6 /home/jailbird/lib/x86_64-linux-gnu
sudo cp /lib/x86_64-linux-gnu/libpcre2-8.so.0 /home/jailbird/lib/x86_64-linux-gnu
sudo cp /lib/x86_64-linux-gnu/libdl.so.2 /home/jailbird/lib/x86_64-linux-gnu
sudo cp /lib64/ld-linux-x86-64.so.2 /home/jailbird/lib64
sudo cp /lib/x86_64-linux-gnu/libpthread.so.0 /home/jailbird/lib/x86_64-linux-gnu

ls -l /home/jailbird/bin /home/jailbird/lib /home/jailbird/lib64

echo "Chroot jail created. Enter 'sudo chroot jailbird' to enter the jail, and 'exit' to leave."