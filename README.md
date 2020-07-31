# nvidia-install-scripts

A set of Bash scripts used to install Nvidia proprietary graphics drivers on
linux as signed drivers.

When using UEFI to securely boot linux it is necessary to use signed drivers.
However, when the binary Nvidia graphics driver is not signed and will not install
on a UEFI system.

The solution is obvious, sign the driver, but the steps can be a bit cumbersome.
So a bit of Bash scripting makes things easier to handle.


# initial steps

The initial setup is derived from the [if-not-true-then-false Fedora Nvidia guide](https://www.if-not-true-then-false.com/2015/fedora-nvidia-guide/).

These steps are executed the first time the Nvidia driver is installed and are not
required for any driver updates. These commands must be executed as root so start
with a root terminal...
> sudo su -

## install dependencies

The build process will require some tools be installed on the system...
> dnf install git vim kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig

## disable nouveau

**a)** The open source nouveau driver for Nvidia graphics must be disabled.
> echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf

**b)** Edit the grub boot loader and add the blacklist setting to the end of GRUB_CMDLINE_LINUX
by appending *rd.driver.blacklist=nouveau.
> vim /etc/sysconfig/grub

The line should end up looking something like...

```
GRUB_CMDLINE_LINUX="rd.lvm.lv=fedora/swap rd.lvm.lv=fedora/root rhgb quiet rd.driver.blacklist=nouveau"
```

**c)** Update grub...
> grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

**d)** Remove the xorg-x11-drv-nouveau package.
> dnf remove xorg-x11-drv-nouveau

**e)** And generate the initramfs...
> mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).nouveau.img

> dracut /boot/initramfs-$(uname -r).img $(uname -r)

## install signing key

Use the key scripts from the project to create and install the signing key and
certificate that will be used to sign the driver.

> git clone https://github.com/bnielsen1965/nvidia-install-scripts.git

> cd nvidia-install-scripts

> ./make-key.sh

**NOTE:** When you run the import key script you will be asked to create a password
for the import. This password will be needed in the first reboot after installing
the key.
> ./import-key.sh

Copy the key files to the root directory where they will be used by the signed install
script.
> mkdir /root/nvidia

> cp nvidia.key /root/nvidia/

> cp nvidia.der /root/nvidia/

That completes the initial setup and the system is ready for the driver install.
These initial steps only need to be executed once and afterward only the install
steps need to be followed when updating the kernel or Nvidia driver.

**NOTE:** In the following install steps when you reboot you will be presented with
the key import screen before the operating system completes the boot process. You
will need to enter the previous generated password to complete the key import.


# nvidia driver install

These steps need to be executed whenever installing a new Nvidia driver or
updating the kernel.

**NOTE:** Pay attention when performing updates, if the kernel is updated you will
need to run these steps before the next reboot.

## download driver

**NOTE:** You can skip this step if you are installing a previously downloaded driver
on a new kernel.

Go to the [Nvidia](https://nvidia.com) website and navigate to the GeForce driver
download page. Select the driver details that match your linux system and download
the driver file.

The drive file will look something like *NVIDIA-Linux-x86_64-450.57.run*.

Start a root terminal by opening a terminal and using sudo su -
> sudo su -

Change into the previously cloned nvidia-install-scripts directory.
> cd nvidia-install-scripts

Copy the Nvidia driver file from the user's download path into the script path. I.E.
> cp /home/myuser/Downloads/NVIDIA-Linux-x86_64-450.57.run ./

And make the driver file executable.
> chmod a+x NVIDIA-Linux-x86_64-450.57.run

## no gui reboot

Next you need to boot into a non-gui mode. Use the nogui script to prepare for the
non-gui mode.
> ./nogui-target.sh

And reboot.
> reboot

## signed install

You should now be in a non-gui mode. Login with your user credentials then switch
the terminal to root with sudo.
> sudo su -

Change into the install script directory and run the signed install script.
> cd nvidia-install-scripts

> ./signed-install.sh

Follow the Nvidia driver install prompts until the installation is complete.

## reboot into gui mode

Use the scripts to switch back to a gui mode and reboot.
> ./gui-target.sh

> reboot

That completes the Nvidia driver installation.
