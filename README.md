# ```chroot``` to Docker

This tutorial explains how you can use ```chroot``` to create an isolated Bourne-Again Shell (```bash```) environment, and how to convert that "jail" into a Docker image.

Things to know and remember:

1. In Linux, everything is a file.
2. Most distributions of Linux use ```bash``` as their command-line interpreter (CLI). The ```bash``` executable file contains built-in commands, such as ```cd``` (change directory) and ```pwd``` (print working directory).
3. A root user can access all files that branch from the root directory (```/```). These files include external commands contained in the ```/bin``` directory, such as ```cp``` (copy), ```ls``` (list), ```find```, etc., and the libraries these programs depend on, , such as ```ld-linux-x86-64.so.2``` and ```libdl.so.2```, located in the ```/lib``` and ```/lib64``` directories.
4. The ```chroot [directory name]``` command switches the user's root directory to the specified directory; the specified directory becomes ```/```. The user will only be able to run programs contained within that directory or its subdirectories; they cannot go outside their jail. For example, if ```ls``` does not exist in the ```chroot``` "jail", the user will not be able to use that command, even if it in the host system's ```bin``` directory.
5. You can easily convert a ```chroot``` directory into a Docker container.

- [Using chroot](#using-chroot "Using chroot")
- [Using Docker](#using-docker "Using Docker")

---
## Using ```chroot```

Open a Terminal and enter the following commands to create the new root directory:

```sudo mkdir /home/jailbird```

Attempt to ```chroot``` into the new root directory:

```sudo chroot jailbird```

After a few seconds, you will see the following output:

```chroot: failed to run command '/bin/bash': No such file or directory```

Copy a shell program, such as ```bash```, into the directory:

```
sudo mkdir /home/jailbird/bin
sudo cp /bin/bash /home/jailbird/bin
```

You will also need to include any libraries that ```bash``` depends on. Look them up first, using the ```ldd``` (list dynamic dependencies) command:

```ldd /bin/bash```

After a few seconds, you will see a list of files, similar to the following:

```
linux-vdso.so.1 =>  (0x00007ffe6fa55000)
libtinfo.so.5 => /lib64/libtinfo.so.5 (0x00007effc0335000)
libdl.so.2 => /lib64/libdl.so.2 (0x00007effc0131000)
libc.so.6 => /lib64/libc.so.6 (0x00007effbfd63000)
/lib64/ld-linux-x86-64.so.2 (0x00007effc055f000)
```

>**NOTE** - I am using CentOS 7. Your list may contain a different set of files if you are using another Linux operating system, such as Ubuntu:
>
>```
># Ubuntu 20.04
>linux-vdso.so.1 (0x00007ffc39bf7000)
>libtinfo.so.6 => /lib/x86_64-linux-gnu/libtinfo.so.6 (0x00007f6085373000)
>libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f608536d000)
>libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f608517b000)
>/lib64/ld-linux-x86-64.so.2 (0x00007f60854e0000)
>```

Copy the ```bash``` dependencies into the new root directory:

```
sudo mkdir lib64
sudo cp /lib64/libtinfo.so.5 /home/jailbird/lib64
sudo cp /lib64/libdl.so.2 /home/jailbird/lib64
sudo cp /lib64/libc.so.6 /home/jailbird/lib64
sudo cp /lib64/ld-linux-x86-64.so.2 /home/jailbird/lib64
```

>**NOTE** - Other operating systems, such as Ubuntu, may use different directories, or directories with sub-directories. Make sure you "mirror" all the files correctly in the new root directory, for example:
>
>```
># Ubuntu 20.04
>sudo mkdir /home/jailbird/lib
>sudo mkdir /home/jailbird/lib/x86_64-linux-gnu
>sudo mkdir /home/jailbird/lib64
>sudo cp /lib/x86_64-linux-gnu/libtinfo.so.6 /home/jailbird/lib/x86_64-linux-gnu
>sudo cp /lib/x86_64-linux-gnu/libdl.so.2 /home/jailbird/lib/x86_64-linux-gnu
>sudo cp /lib/x86_64-linux-gnu/libc.so.6 /home/jailbird/lib/x86_64-linux-gnu
>sudo cp /lib64/ld-linux-x86-64.so.2 /home/jailbird/lib64
>```

Verify that you correctly copied the files the new root directory:

```ls -l /home/jailbird/bin /home/jailbird/lib64```

After a few seconds, you will see the following output:

```
/home/jailbird/bin:
 total 944
-rwxr-xr-x. 1 root root 964536 Nov 17 11:19 bash

/home/jailbird/lib64:
total 2460
-rwxr-xr-x. 1 root root  163312 Nov 17 11:21 ld-linux-x86-64.so.2
-rwxr-xr-x. 1 root root 2156592 Nov 17 11:21 libc.so.6
-rwxr-xr-x. 1 root root   19248 Nov 17 11:21 libdl.so.2
-rwxr-xr-x. 1 root root  174576 Nov 17 11:21 libtinfo.so.5
```

Make sure you are in the ```home``` directory, and enter the new root directory:

```
cd /home
sudo chroot jailbird
```

You are welcomed with a ```bash``` prompt:

```bash-4.2#```

Look up the present working directory, using a built-in command:

```pwd```

It will appear as your root directory:

```/```

Attempt to reach the parent ```home``` directory, using a built-in command:

```cd ..``` or ```cd /home```

Nothing will happen or you will receive the following error:

```bash: cd: /home: No such file or directory```

Go to ```bin``` sub-directory you created earlier and verify you are there, using a built-in command:

```
cd /bin
pwd
```

```/bin```

Attempt to look at directory contents, using a common external command:

```ls -l```

Since ```ls``` is not a built-in command or present in the ```bin``` directory, you will receive the following error:

```bash: ls: command not found```

Let's fix that. Leave the jailbird:

```exit```

You should be back at the Terminal prompt:

```/home]$```

Add ```ls``` to the jailbird, as you did with ```bash```:

```
# Copy the external command to the new root directory
sudo cp /bin/ls /home/jailbird/bin
# Look up ls dependencies
ldd /bin/ls
```

>**NOTE** - Remember, these files may be different, depending on the OS you are using.

```
linux-vdso.so.1 =>  (0x00007ffd8872f000)
libselinux.so.1 => /lib64/libselinux.so.1 (0x00007fda7efa1000)
libcap.so.2 => /lib64/libcap.so.2 (0x00007fda7ed9c000)
libacl.so.1 => /lib64/libacl.so.1 (0x00007fda7eb93000)
libc.so.6 => /lib64/libc.so.6 (0x00007fda7e7c5000)
libpcre.so.1 => /lib64/libpcre.so.1 (0x00007fda7e563000)
libdl.so.2 => /lib64/libdl.so.2 (0x00007fda7e35f000)
/lib64/ld-linux-x86-64.so.2 (0x00007fda7f1c8000)
libattr.so.1 => /lib64/libattr.so.1 (0x00007fda7e15a000)
libpthread.so.0 => /lib64/libpthread.so.0 (0x00007fda7df3e000)
```

Copy the dependencies to the new root directory (some may already exist there):

```
sudo cp /lib64/libselinux.so.1 /home/jailbird/lib64
sudo cp /lib64/libcap.so.2 /home/jailbird/lib64
sudo cp /lib64/libacl.so.1 /home/jailbird/lib64
sudo cp /lib64/libc.so.6 /home/jailbird/lib64
sudo cp /lib64/libpcre.so.1 /home/jailbird/lib64
sudo cp /lib64/libdl.so.2 /home/jailbird/lib64
sudo cp /lib64/ld-linux-x86-64.so.2 /home/jailbird/lib64
sudo cp /lib64/libattr.so.1 /home/jailbird/lib64
sudo cp /lib64/libpthread.so.0 /home/jailbird/lib64
```

Verify that you correctly copied the files the new root directory:

```ls -l /home/jailbird/bin /home/jailbird/lib64```

After a few seconds, you will see the following output:

```
/home/jailbird/bin:
total 1060
-rwxr-xr-x. 1 root root 964536 Nov 17 11:32 bash
-rwxr-xr-x. 1 root root 117608 Nov 17 11:39 ls

/home/jailbird/lib64:
total 3232
-rwxr-xr-x. 1 root root  163312 Nov 17 11:42 ld-linux-x86-64.so.2
-rwxr-xr-x. 1 root root   37064 Nov 17 11:42 libacl.so.1
-rwxr-xr-x. 1 root root   19896 Nov 17 11:42 libattr.so.1
-rwxr-xr-x. 1 root root   20048 Nov 17 11:42 libcap.so.2
-rwxr-xr-x. 1 root root 2156592 Nov 17 11:42 libc.so.6
-rwxr-xr-x. 1 root root   19248 Nov 17 11:42 libdl.so.2
-rwxr-xr-x. 1 root root  402384 Nov 17 11:42 libpcre.so.1
-rwxr-xr-x. 1 root root  142144 Nov 17 11:42 libpthread.so.0
-rwxr-xr-x. 1 root root  155744 Nov 17 11:42 libselinux.so.1
-rwxr-xr-x. 1 root root  174576 Nov 17 11:32 libtinfo.so.5
```

Make sure you are in the ```home``` directory, and enter the new root directory:

```
cd /home
sudo chroot jailbird
```

You are welcomed with a ```bash``` prompt:

```bash-4.2#```

Go to ```bin``` sub-directory you created earlier and verify you are there, using a built-in command:

```
cd /bin
pwd
```

```/bin```

Attempt to look at directory contents, using a common external command:

```ls -l```

This time, ```ls``` works, and a list of  files appear:

```
total 1060
-rwxr-xr-x. 1 0 0 964536 Nov 17 16:32 bash
-rwxr-xr-x. 1 0 0 117608 Nov 17 16:39 ls
```

Leave the jailbird:

```exit```

You should be back at the Terminal prompt:

```/home]$```

---
## Using Docker

>**NOTE** - Before installing or starting services, I recommend that you update your system before continuing (i.e., ```sudo yum update``` or ```sudo apt update```).

Now you will create a Docker image, using the ```chroot``` jail you created as a base. First, find out if Docker is installed on your system:

```which docker```

If Docker is installed, Linux will return the location of the Docker executable:

```/usr/bin/docker```

If not, enter the following command to install Docker:

```sudo yum -y install docker```

Once installed, start the Docker service:

```sudo systemctl start docker```

You can check the status of the service by entering the following command:

```systemctl status docker```

Go to the ```chroot``` jail and add a Dockerfile:

```
cd /home/jailbird
touch Dockerfile
```

Using your favorite editor (```vim```, ```emacs```, ```nano```, ```gedit```, etc.), open the Dockerfile and add the following commands:

>**NOTE** - Remember, these files may be different, depending on the OS you are using.

```
FROM scratch

ADD /bin/bash /bin/bash
ADD /bin/ls /bin/ls

ADD /lib64/libtinfo.so.5 /lib64/libtinfo.so.5
ADD /lib64/libdl.so.2 /lib64/libdl.so.2
ADD /lib64/libc.so.6 /lib64/libc.so.6
ADD /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
ADD /lib64/libselinux.so.1 /lib64/libselinux.so.1
ADD /lib64/libcap.so.2 /lib64/libcap.so.2
ADD /lib64/libacl.so.1 /lib64/libacl.so.1
ADD /lib64/libpcre.so.1 /lib64/libpcre.so.1
ADD /lib64/libattr.so.1 /lib64/libattr.so.1
ADD /lib64/libpthread.so.0 /lib64/libpthread.so.0

CMD ["/bin/bash"]
```

Create the Docker image:

```sudo docker build --tag jailbird .```

After a few seconds, you will see the following output similar to the following:

```
Sending build context to Docker daemon 4.415 MB
Step 1/15 : FROM scratch
 ---> 
Step 2/15 : ADD /bin/bash /bin/bash
 ---> Using cache
 ---> 4104d1cce445
Step 3/15 : ADD /bin/whoami /bin/whoami
 ---> ea22ed6f1ebc
Removing intermediate container 1ba82272a6b5
Step 4/15 : ADD /bin/ls /bin/ls
 ---> 3c48301deba1
Removing intermediate container 2325085fc57d
Step 5/15 : ADD /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
 ---> 0a23d9d0c2cf
Removing intermediate container b3c17e3bdba7
Step 6/15 : ADD /lib64/libacl.so.1 /lib64/libacl.so.1
 ---> d04fce99ffe7
Removing intermediate container 74ab429bb068
Step 7/15 : ADD /lib64/libattr.so.1 /lib64/libattr.so.1
 ---> 858ea10fd592
Removing intermediate container de06e9a33cea
Step 8/15 : ADD /lib64/libc.so.6 /lib64/libc.so.6
 ---> cf38f1c10da0
Removing intermediate container 4fde320ce20f
Step 9/15 : ADD /lib64/libcap.so.2 /lib64/libcap.so.2
 ---> 7c18e6715ff2
Removing intermediate container 803bf092752e
Step 10/15 : ADD /lib64/libdl.so.2 /lib64/libdl.so.2
 ---> e001e1e1a77d
Removing intermediate container d09e7bfdeabb
Step 11/15 : ADD /lib64/libpcre.so.1 /lib64/libpcre.so.1
 ---> 10ec733763c6
Removing intermediate container c116315dfeb4
Step 12/15 : ADD /lib64/libpthread.so.0 /lib64/libpthread.so.0
 ---> e964205de279
Removing intermediate container 527b45a24580
Step 13/15 : ADD /lib64/libselinux.so.1 /lib64/libselinux.so.1
 ---> fd1484de3480
Removing intermediate container 5b15658b83a6
Step 14/15 : ADD /lib64/libtinfo.so.5 /lib64/libtinfo.so.5
 ---> f5235ea2c25f
Removing intermediate container 7a18a47660b1
Step 15/15 : CMD /bin/bash
 ---> Running in 901297a6ed17
 ---> 1ed94b3b5376
Removing intermediate container 901297a6ed17
Successfully built 1ed94b3b5376
```

Check for errors; if any appear, repeat the creation process. Otherwise, verify the Docker image exists:

```sudo docker images```

```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
jailbird            latest              06edb23a3f1a        48 seconds ago      6.71 MB
```

Start the Docker container by entering the following command:

```sudo docker run -it jailbird```

You are welcomed with a bash prompt:

```bash-4.2#```

Play around a little bit. To exit, enter ```exit```:

```exit```

To remove the container and the image, look the image's container ID and name:

```sudo docker container ls -a```

After a few seconds, you will see the following output:

```
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                          PORTS               NAMES
4fa380eb6e18        jailbird            "/bin/bash"         2 minutes ago       Exited (0) About a minute ago                       trusting_swartz
```

First, you will need to remove the container:

```sudo docker container rm 4fa380eb6e18 # or trusting_swartz```

If you successfully removed the image, Docker will return the container ID (```4fa380eb6e18```).

Next, remove the image itself:

```sudo docker image rm jailbird```

After a few seconds, you will see the following output:

```
Untagged: jailbird:latest
Deleted: sha256:06edb23a3f1a08d85b1cdf956c19a2726fd18b7a3542a7ee65cbb194195b9aca
Deleted: sha256:25c4cadafe9f9e5e7f63e3a0657eb4d131de1710be4433fe0ee9e958bd15c338
Deleted: sha256:7301234a0cf4b87ede0a7effc979831257552ca7d9e4f20c00ddefd93698b961
Deleted: sha256:4ad587445363937414137aab5fbae305a3a68f4d5d46cf71706ed0474db708e7
Deleted: sha256:4b7941d38c5a33d19d0bbed72fc86e12c37ef5a5206caf6dd12c3034720d9a73
Deleted: sha256:9c8e9f746205b1dca466cc88573643634b4ba50a41827dc046929bce3189909c
Deleted: sha256:64e5c17368b70a4524c3215c3443a4fa154d49ca624c2a0f73ba3affa666b921
Deleted: sha256:b9eafa74c42298b4eb6ec32325c0b6d82b2a9772c765499dcca9276deb61e61c
Deleted: sha256:88cd06d2c755ed23e3c88458935f9e252d7bdc324e1b368594cef36c206bea06
Deleted: sha256:a788355ebe8be2b43e7affecfc1572938946755b6cd2f8fd5fdb7dd791c35c8e
Deleted: sha256:b1c2ed687192f9c2d3d26577c371e7d310859397352fe865e0081c88d6ae6b29
Deleted: sha256:368f024496fd88b7790cb7c51600ef9a37df8be796f74343e09f38db97a01a93
Deleted: sha256:3dd94f8d9954d575008331190b3cefbdd01f9afd04883f04a82d97155e8f2e49
Deleted: sha256:35fbf8636d5aa4014f0cb2c05a79d7bf4f91cec1392c65722518670c49b3b70c
Deleted: sha256:ef16ec021b4b78fb465c821f91960e4a3b1bf1ad40d5be8c2d7498c31677e294
Deleted: sha256:8eb51378d2b23718b3a7163c10d0f2f559739907c734612183167e2adf6c95ee
Deleted: sha256:9595c6bb484a0df0622e1da11ded3b2d9d1ba3c83af59f48e92f8c5eecff26f9
Deleted: sha256:a9c4afec1f23883657966394b0be2c715e45c066c23575e5ffb1d4491e4babc6
Deleted: sha256:5a3f8e315944976dd72802fc7e1679040af30c7c45fea37755640cc5edce0652
Deleted: sha256:d40642ccc7ac07843628c55c816b76c893616656932e6dccc7fbce9734544ce6
Deleted: sha256:48461b65e6ccf59ed2c198dc605b4ce75ac400e87f3446cc57056497155017c4
Deleted: sha256:8760235de8c5141d2c75504f3cbf1e2a110f03fd2a1e8a72098d1940375dee66
Deleted: sha256:d54c7a0769dac47ca592e79a18602f2678b6f65e8972aa0e4c3cfe9e68280596
Deleted: sha256:77508ccdd32a98e82cfd789150af0412516b769ad7116dbf5d379cadef5526dc
Deleted: sha256:95d4ab79979f640be6d8d904b3fec89176795760710d0f269642923208dffa66
Deleted: sha256:c4c94fafcf744bb5279f7370c081b0729fcd9e3554d0c228d7f5f191d0a6645c
Deleted: sha256:79ab8a93a07b90c85af99e51e6216fece6542d0cfaf381fdaf312b4b28545ba7
Deleted: sha256:650d0d5080a9a620680c1fb0e55a12f9b1eda62519282c2f0931c1d0e0b04f83
Deleted: sha256:720405debb4fcf4987f386eba3c5633dade35e680e24bc0900b0941bee600043
Deleted: sha256:2ba454450eb7c4d32740e3375ea16d25fa8ff258a59ae2f6f0a0971db81d476d
Deleted: sha256:d16804f7c2771d5f4d216ef64eead755b53bea4ac32464d0387b907537f82144
```

You can also remove all containers and images using the following command:

```sudo docker system prune -a```

After a few seconds, Docker will ask if you are sure you want to delete those files:

```
WARNING! This will remove:
- all stopped containers
- all volumes not used by at least one container
- all networks not used by at least one container
- all images without at least one container associated to them
Are you sure you want to continue? [y/N] y
Total reclaimed space: 0 B
```

---
## Included Scripts

I have included scripts to automate these commands. First, make sure you set the correct permissions:

```sudo chmod 777 chroot_centos.sh```

You can run them from your ```/home``` directory:

```sh  chroot_centos.sh``` or ```./ chroot_centos.sh```

---
## Inherited Bash Commands

See also: [gnu - Index of Shell Builtin Commands](https://www.gnu.org/software/bash/manual/html_node/Builtin-Index.html "gnu - Index of Shell Builtin Commands").

```
alias: Bash Builtins
bg: Job Control Builtins
bind: Bash Builtins
break: Bourne Shell Builtins
builtin: Bash Builtins
caller: Bash Builtins
cd: Bourne Shell Builtins
command: Bash Builtins
compgen: Programmable Completion Builtins
complete: Programmable Completion Builtins
compopt: Programmable Completion Builtins
continue: Bourne Shell Builtins
declare: Bash Builtins
dirs: Directory Stack Builtins
disown: Job Control Builtins
echo: Bash Builtins
enable: Bash Builtins
eval: Bourne Shell Builtins
exec: Bourne Shell Builtins
exit: Bourne Shell Builtins
export: Bourne Shell Builtins
fc: Bash History Builtins
fg: Job Control Builtins
getopts: Bourne Shell Builtins
hash: Bourne Shell Builtins
help: Bash Builtins
history: Bash History Builtins
jobs: Job Control Builtins
kill: Job Control Builtins
let: Bash Builtins
local: Bash Builtins
logout: Bash Builtins
mapfile: Bash Builtins
popd: Directory Stack Builtins
printf: Bash Builtins
pushd: Directory Stack Builtins
pwd: Bourne Shell Builtins
read: Bash Builtins
readarray: Bash Builtins
readonly: Bourne Shell Builtins
return: Bourne Shell Builtins
set: The Set Builtin
shift: Bourne Shell Builtins
shopt: The Shopt Builtin
source: Bash Builtins
suspend: Job Control Builtins
test: Bourne Shell Builtins
times: Bourne Shell Builtins
trap: Bourne Shell Builtins
type: Bash Builtins
typeset: Bash Builtins
ulimit: Bash Builtins
umask: Bourne Shell Builtins
unalias: Bash Builtins
unset: Bourne Shell Builtins
wait: Job Control Builtins
```

- - - - - - - - - - - - - - - - - - - -

## Good References

- [ldd(1) - Linux manual page](https://man7.org/linux/man-pages/man1/ldd.1.html "ldd(1) — Linux manual page")
- [Understanding Chroot - Rob Braxman](https://www.youtube.com/watch?v=2wSJREC7RV8&ab_channel=RobBraxmanTech "Understanding Chroot - Rob Braxman")
- [Restrict SSH User Access to Certain Directory Using Chrooted Jail - Aaron Kili](https://www.tecmint.com/restrict-ssh-user-to-directory-using-chrooted-jail/ "Restrict SSH User Access to Certain Directory Using Chrooted Jail - Aaron Kili")
