# chroot-to-docker script for Ubuntu 20
echo "Creating the chroot jail in Ubuntu..."

if [ -d /home/jailbird ]
  then
    while true; do
      read -r -p "The chroot jail exists. Do you wish to recreate the chroot jail (y/n): " yn
      case $yn in
          [Yy]* ) sudo rm -rf /home/jailbird; break;;
          [Nn]* ) echo "Good-bye."; exit;;
          * ) echo "Please answer (y)es or (n)o.";;
      esac
    done
fi

# Stop execution if directories are not created, if files are not found, or if files are not copied.
set -e

sudo mkdir /home/jailbird

sudo mkdir /home/jailbird/bin
sudo cp -u /bin/bash /home/jailbird/bin

sudo mkdir /home/jailbird/lib
sudo mkdir /home/jailbird/lib/x86_64-linux-gnu
sudo mkdir /home/jailbird/lib64

sudo cp -u /lib/x86_64-linux-gnu/libtinfo.so.6 /home/jailbird/lib/x86_64-linux-gnu
sudo cp -u /lib/x86_64-linux-gnu/libdl.so.2 /home/jailbird/lib/x86_64-linux-gnu
sudo cp -u /lib/x86_64-linux-gnu/libc.so.6 /home/jailbird/lib/x86_64-linux-gnu
sudo cp -u /lib64/ld-linux-x86-64.so.2 /home/jailbird/lib64

sudo cp -u /bin/ls /home/jailbird/bin

sudo cp -u /lib/x86_64-linux-gnu/libselinux.so.1 /home/jailbird/lib/x86_64-linux-gnu
sudo cp -u /lib/x86_64-linux-gnu/libc.so.6 /home/jailbird/lib/x86_64-linux-gnu
sudo cp -u /lib/x86_64-linux-gnu/libpcre2-8.so.0 /home/jailbird/lib/x86_64-linux-gnu
sudo cp -u /lib/x86_64-linux-gnu/libdl.so.2 /home/jailbird/lib/x86_64-linux-gnu
sudo cp -u /lib64/ld-linux-x86-64.so.2 /home/jailbird/lib64
sudo cp -u /lib/x86_64-linux-gnu/libpthread.so.0 /home/jailbird/lib/x86_64-linux-gnu

echo "Contents of the chroot jail:"
ls -lR /home/jailbird

echo "Chroot jail created. Enter 'sudo chroot jailbird' to enter the jail, and 'exit' to leave the jail."

echo "Updating system..."
sudo apt -y update
echo "System updated."

echo "Checking if Docker is installed..."
if [ ! -e /bin/docker ]
  then
    while true; do
      read -r -p "Docker is not installed. Do you wish to install Docker (y/n): " yn
      case $yn in
          [Yy]* ) sudo apt -y install docker.io; break;;
          [Nn]* ) echo "Good-bye."; exit;;
          * ) echo "Please answer (y)es or (n)o.";;
      esac
    done
fi
echo "Docker is installed"

echo "Starting Docker..."
sudo systemctl start docker
echo "Docker started."

echo "Cretaing Dockerfile..."
cd /home/jailbird || exit
sudo rm -rf /home/jailbird/Dockerfile
sudo touch /home/jailbird/Dockerfile
sudo chmod 777 /home/jailbird/Dockerfile
{
  echo "FROM scratch"
  echo
  echo "ADD /bin/bash /bin/bash"
  echo "ADD /bin/ls /bin/ls"
  echo "ADD /lib/x86_64-linux-gnu/libtinfo.so.6 /lib/x86_64-linux-gnu/libtinfo.so.6"
  echo "ADD /lib/x86_64-linux-gnu/libdl.so.2 /lib/x86_64-linux-gnu/libdl.so.2"
  echo "ADD /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libc.so.6"
  echo "ADD /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2"
  echo "ADD /lib/x86_64-linux-gnu/libselinux.so.1 /lib/x86_64-linux-gnu/libselinux.so.1"
  echo "ADD /lib/x86_64-linux-gnu/libpcre2-8.so.0 /lib/x86_64-linux-gnu/libpcre2-8.so.0"
  echo "ADD /lib/x86_64-linux-gnu/libpthread.so.0 /lib/x86_64-linux-gnu/libpthread.so.0"
  echo
  echo "CMD [\"/bin/bash\"]"
} >> Dockerfile
echo "Dockerfile created."

echo "Building Docker image..."
cd /home/jailbird || exit
sudo docker build --tag jailbird . || exit
sudo docker images
echo "Docker image created. Enter 'sudo docker run -it jailbird' to start a container, and 'exit' to leave the container."

echo "Script complete. Have a nice day."
