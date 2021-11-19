# chroot-to-docker
This tutorial explains how to use chroot to create an isolated shell, and how to convert that "jail" into a Docker image. 

Rob's CHROOT to DOCKER Tutorial

Open a Terminal

```
cd /home
```


```
sudo mkdir jailbird
# Attempt to enter the jailbird
sudo chroot jailbird
```

```
    chroot: failed to run command '/bin/bash': No such file or directory
```

```
# Add bash to the jailbird
cd jailbird
sudo mkdir bin
sudo cp /bin/bash bin
# Look up bash dependencies
ldd /bin/bash
```

```
    linux-vdso.so.1 =>  (0x00007ffe6fa55000)
    libtinfo.so.5 => /lib64/libtinfo.so.5 (0x00007effc0335000)
    libdl.so.2 => /lib64/libdl.so.2 (0x00007effc0131000)
    libc.so.6 => /lib64/libc.so.6 (0x00007effbfd63000)
    /lib64/ld-linux-x86-64.so.2 (0x00007effc055f000)
```

```
# Copy bash dependencies to jailbird
sudo mkdir lib64
sudo cp /lib64/libtinfo.so.5 lib64
sudo cp /lib64/libdl.so.2 lib64
sudo cp /lib64/libc.so.6 lib64
sudo cp /lib64/ld-linux-x86-64.so.2 lib64
# Check files
ls -l bin
```

```
    total 944
    -rwxr-xr-x. 1 root root 964536 Nov 17 11:19 bash
```

```
ls -l lib64
```

```
    total 2460
    -rwxr-xr-x. 1 root root  163312 Nov 17 11:21 ld-linux-x86-64.so.2
    -rwxr-xr-x. 1 root root 2156592 Nov 17 11:21 libc.so.6
    -rwxr-xr-x. 1 root root   19248 Nov 17 11:21 libdl.so.2
    -rwxr-xr-x. 1 root root  174576 Nov 17 11:21 libtinfo.so.5
```

```
# Go back to home directory
cd ..
# Enter the jailbird
sudo chroot jailbird
```

```
    bash-4.2# 
```

```
# Look up the present working directory using a built-in command
pwd
```

```
    /
```

```
# Go to bin directory using a built-in command
cd bin
pwd
```

```
    /bin
```

```
# Attempt to look at directory contents using an external command
ls -l
```

```
    bash: ls: command not found
```

```
# Leave the jailbird
exit
```

```
    [user ~]$
```

```
# Add ls to the jailbird
cd jailbird
sudo cp /bin/ls bin
# Look up ls dependencies
ldd /bin/ls
```

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

```
# Copy ls dependencies to jailbird
sudo cp /lib64/libselinux.so.1 lib64
sudo cp /lib64/libcap.so.2 lib64
sudo cp /lib64/libacl.so.1 lib64
sudo cp /lib64/libc.so.6 lib64
sudo cp /lib64/libpcre.so.1 lib64
sudo cp /lib64/libdl.so.2 lib64
sudo cp /lib64/ld-linux-x86-64.so.2 lib64
sudo cp /lib64/libattr.so.1 lib64
sudo cp /lib64/libpthread.so.0 lib64
# Check files
ls -l bin
```

```
    total 1060
    -rwxr-xr-x. 1 root root 964536 Nov 17 11:32 bash
    -rwxr-xr-x. 1 root root 117608 Nov 17 11:39 ls
```

```
ls -l lib64
```

```
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

```
# Go back to home directory
cd ..
# Enter the jailbird
sudo chroot jailbird
```

```
    bash-4.2# 
```

```
# Go to bin directory using a built-in command
cd bin
pwd
```

```
    /bin
```

```
# Look at directory contents using an external command
ls -l
```

```
    total 1060
    -rwxr-xr-x. 1 0 0 964536 Nov 17 16:32 bash
    -rwxr-xr-x. 1 0 0 117608 Nov 17 16:39 ls
```

```
# Leave the jailbird
exit
```

```
    [user ~]$
```

Create Docker Image:

```
cd jailbird
vim Dockerfile
```

```
FROM scratch

ADD /bin/bash /bin/bash
ADD /lib64/libtinfo.so.5 /lib64/libtinfo.so.5
ADD /lib64/libdl.so.2 /lib64/libdl.so.2
ADD /lib64/libc.so.6 /lib64/libc.so.6
ADD /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
ADD /bin/ls /bin/ls
ADD /lib64/libselinux.so.1 /lib64/libselinux.so.1
ADD /lib64/libcap.so.2 /lib64/libcap.so.2
ADD /lib64/libacl.so.1 /lib64/libacl.so.1
ADD /lib64/libc.so.6 /lib64/libc.so.6
ADD /lib64/libpcre.so.1 /lib64/libpcre.so.1
ADD /lib64/libdl.so.2 /lib64/libdl.so.2
ADD /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
ADD /lib64/libattr.so.1 /lib64/libattr.so.1
ADD /lib64/libpthread.so.0 /lib64/libpthread.so.0

CMD ["/bin/bash"]
```

```
sudo docker build --tag jailbird .
```

```
Sending build context to Docker daemon 4.385 MB
Step 1/17 : FROM scratch
 ---> 
Step 2/17 : ADD /bin/bash /bin/bash
 ---> 2ba454450eb7
Removing intermediate container 4347c079bf10
Step 3/17 : ADD /lib64/libtinfo.so.5 /lib64/libtinfo.so.5
 ---> 650d0d5080a9
Removing intermediate container 64708923db92
Step 4/17 : ADD /lib64/libdl.so.2 /lib64/libdl.so.2
 ---> c4c94fafcf74
Removing intermediate container 1357b86a5fcd
Step 5/17 : ADD /lib64/libc.so.6 /lib64/libc.so.6
 ---> 77508ccdd32a
Removing intermediate container b5c861077ae8
Step 6/17 : ADD /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
 ---> 8760235de8c5
Removing intermediate container f5190bb9a319
Step 7/17 : ADD /bin/ls /bin/ls
 ---> d40642ccc7ac
Removing intermediate container 8a68f3f937e1
Step 8/17 : ADD /lib64/libselinux.so.1 /lib64/libselinux.so.1
 ---> a9c4afec1f23
Removing intermediate container 33f7041c7785
Step 9/17 : ADD /lib64/libcap.so.2 /lib64/libcap.so.2
 ---> 8eb51378d2b2
Removing intermediate container e66462f37edd
Step 10/17 : ADD /lib64/libacl.so.1 /lib64/libacl.so.1
 ---> 35fbf8636d5a
Removing intermediate container 93904f857221
Step 11/17 : ADD /lib64/libc.so.6 /lib64/libc.so.6
 ---> 368f024496fd
Removing intermediate container 0c806cd6f2ae
Step 12/17 : ADD /lib64/libpcre.so.1 /lib64/libpcre.so.1
 ---> a788355ebe8b
Removing intermediate container 56026b84c04c
Step 13/17 : ADD /lib64/libdl.so.2 /lib64/libdl.so.2
 ---> b9eafa74c422
Removing intermediate container 47f975f1d550
Step 14/17 : ADD /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
 ---> 9c8e9f746205
Removing intermediate container 500c949b81ed
Step 15/17 : ADD /lib64/libattr.so.1 /lib64/libattr.so.1
 ---> 4ad587445363
Removing intermediate container 4f10092b7ea7
Step 16/17 : ADD /lib64/libpthread.so.0 /lib64/libpthread.so.0
 ---> 25c4cadafe9f
Removing intermediate container 0f81fce22f80
Step 17/17 : CMD /bin/bash
 ---> Running in f22b5879ef3a
 ---> 06edb23a3f1a
Removing intermediate container f22b5879ef3a
Successfully built 06edb23a3f1a
```

```
sudo docker images
```

```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
jailbird            latest              06edb23a3f1a        48 seconds ago      6.71 MB
```

```
sudo docker run -it jailbird
```

```
bash-4.2#
```

Play around a little bit. To exit, enter ```exit```:

```
exit
```

To remove the container and the image:

```
sudo docker container ls -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                          PORTS               NAMES
4fa380eb6e18        jailbird            "/bin/bash"         2 minutes ago       Exited (0) About a minute ago                       trusting_swartz

sudo docker container rm 4fa380eb6e18 # or trusting_swartz
4fa380eb6e18

sudo docker image rm jailbird
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

sudo docker system prune -a
WARNING! This will remove:
	- all stopped containers
	- all volumes not used by at least one container
	- all networks not used by at least one container
	- all images without at least one container associated to them
Are you sure you want to continue? [y/N] y
Total reclaimed space: 0 B
```

Inherited Bash Commands

https://www.gnu.org/software/bash/manual/html_node/Builtin-Index.html

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

Reference:
https://man7.org/linux/man-pages/man1/ldd.1.html
https://www.youtube.com/watch?v=2wSJREC7RV8&ab_channel=RobBraxmanTech
https://unix.stackexchange.com/questions/559937/using-useradd-r-for-chrooting
https://www.tecmint.com/restrict-ssh-user-to-directory-using-chrooted-jail/
