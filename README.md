# de-LUKS
de-LUKS (pronounced deluxe) is a tool for conducting evil maid attacks against
Linux systems secured with LUKS full-disk encryption (this is the default for
basically every distro out there).

de-LUKS will intercept the user's decryption password after it is entered and
will add a new backdoor password that can subsequently be used to decrypt the
disk (in this case, it'll add the password "pwned").  This completely defeats
full disk encryption, and has no easy fix.

The attack can be conducted by an actor with physical access to the laptop
(like a maid who enters your hotel room) or by software that has read/write
access to /boot on your system.

de-LUKS is confirmed working on the following platforms:
  * Ubuntu 16.04

**IMPORTANT NOTE**: Since de-LUKS is a tool for security assessment, I put 0
effort into making it hide itself.  Note, however, that if someone really
wanted to, they could make this tool nearly undetectable (only software that
runs before initramfs or the user searching the hard drive before boot for a
modified initramfs would be able to detect it).


## Evil maid attack?
An evil maid attack defeats full disk encryption when the attacker has physical
access to an unattended laptop .  The
attack exploits the fact that the system that asks for your password and
decrypts your harddrive is necessarily unencrypted.  This means an attacker can
modify it to steal the password you type in when you next boot your computer.


## Usage
de-LUKS installs a backdoor in the target system's initramfs/initrd file,
which is located in /boot.  You must first obtain this image from your target,
either by copying it directly from their hard drive, getting root on their
system when you're logged in and stealing it, by SE (lol), etc.  After you have
it, simply run `install_backdoor.sh <image_file>` on the image and then replace
the original initramfs/initrd file on the target machine with the backdoored
image produced by de-LUKS.

### Example attack:
```shell
# Get access to the target's hard drive (run this tool from a bootable usb on
the target system, plug it in to the attacker's computer, etc) and mount it.
mount <target_device> ./target/

# Copy the initramfs/initrd file from /boot
# NOTE: the filename will likely be different on your target's system.  This is
#       the file that can be found on an Ubuntu 16.04 machine as of 05/28/18.
cp ./target/boot/initrd.img.4.13.0-36-generic .

# Install backdoor
./install_backdoor.sh initrd.img.4.13.0-36-generic

# Replace original image with backdoored version on the target's system.
cp initrd.img.4.13.0-36-generic.backdoored ./target/boot/initrd.img.4.13.0-36-generic

# Unmount hard drive
umount ./target/

# Backdoor is now installed!  Plug target's hard drive back into their computer
# and next time they boot their system and enter their password, the backdoor
# will add "pwned" as an additional password that can unlock the LUKS
# container.  Note that once this password is installed, you can later steal or
# copy the hard drive and decrypt/analyse it offsite at your convenience.

```


## How does de-LUKS work?
Linux systems with full disk encryption prompt you for your password in an
initramfs (or initrd, basically same thing) image.  [Initramfs][1] is a scheme
for loading a small temporary file system into memory during boot.  It is
used, among other things, to prepare the system to mount the real root file
system.  This is where the system will prompt for the decryption passsword and
decrypt & mount the now-unlocked filesystem.  Since this area is necessarily
unencrypted, we simply modify it to intercept the password and use `cryptsetup`
(tool for working with LUKS containers, used by the system to decrypt the
encrypted disk) to add an additional backdoor password.


## Defending against de-LUKS.
Evil maid attacks are pretty hard to defend against.  UEFI provides some
protection on systems that can use secure boot, but this isn't yet supported by
Linux.  Here are a few defenses you can employ in the meantime.
  * Keep your boot partititon on a removable drive you carry with you at all
    times.  I'd reccomend putting it on a usb drive you can wear as jewlery
    (necklace, bracelet, earings, etc).  So long as no one steals this and
    backdoors it, you're safe.
  * Never leave your laptop unattended.  Also, if your threat model includes
    ninjas, guard it when you sleep.

As you can see, the fixes for this attack are pretty far past the threshold of
what the average user might consider a reasonable consession in favor of
security :v
