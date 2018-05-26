## Cryptsetup primer
cryptsetup is the program that is used to work with encrypted disks on linux.
It's used during OS install to actually create the encrypted disk and later
used on boot in the initrd/initramfs image to decrypt the disk.  Because of the
latter usage, cryptsetup is therefore de-luks's target for intercepting
encrypted disk passwords.  This fact makes it important that we have a solid
unerstanding of how cryptsetup works.

How are we going to achieve that understanding?  By using it to actually set up
a disk to use while testing de-luks!

### Creating an encrypted (fake) disk
Don't have a spare HDD?  No problem.  For development, we're going to use a
file as a fake encrypted disk.  The following commands will create our fake
disk and encrypt it.

```shell
# Create 8mb fake disk that we can use for testing
dd if=/dev/zero of=./evilmaid_fakedisk bs=1M count=8

# Encrypt our disk
cryptsetup -v luksFormat --type luks2 ./evilmaid_fakedisk
```

That's it, we should now have an encrypted disk.  This is basically how all
linux installers will create an encrypted disk, it's really that easy.

Just to make sure everything worked, let's dump the luks disk header.  We
initialized our fake disk with zeros, so if we get any data chances are things
worked!

```shell
cryptsetup -v luksDump ./evilmaid_fakedisk
```

You should see output that looks something like:

```
LUKS header information for ./fake_disk

Version:        1
Cipher name:    aes
Cipher mode:    xts-plain64
Hash spec:      sha256
Payload offset: 4096
MK bits:        256
MK digest:      4d 55 e9 cf 70 05 bc 02 8b af 9f 5d 56 d5 85 ef 2f 36 79 10 
MK salt:        f9 bc 8e c9 f7 c0 d5 1b 43 2e 05 7b f0 15 c6 6b 
                b4 be 8e f4 ed 76 ec 45 0c 09 ae f3 33 f5 d3 25 
MK iterations:  387750
UUID:           39498bf0-0427-4c63-abd7-9228bf64fc78

Key Slot 0: ENABLED
        Iterations:             3121951
        Salt:                   05 a2 51 0c a1 11 ea 16 98 08 43 07 f6 ea 6a e4 
                                4e 35 b2 09 5e a0 b6 97 e2 4c 49 59 9e b1 40 0a 
        Key material offset:    8
        AF stripes:             4000
Key Slot 1: DISABLED
Key Slot 2: DISABLED
Key Slot 3: DISABLED
Key Slot 4: DISABLED
Key Slot 5: DISABLED
Key Slot 6: DISABLED
Key Slot 7: DISABLED
```

If everything looks correct, let's move on.

### Adding && removing passwords
It's important to know how to add and remove keys, since de-luks does that to
add its backdoor key.  A note on terminology: LUKS calls passwords "keys"
(since they're used to derive encryption keys), so we'll be using those terms
interchangably from here on.

Here are a few commands to add and remove keys:

```
# Add new key to disk
cryptsetup -v luksAddKey ./evilmaid_fakedisk

# Remove key for disk (will ask for the password to delete)
cryptsetup -v luksRemoveKey ./evilmaid_fakedisk

# Disable keyslot for disk (if you forgot the password for a keyslot, this'll nuke it)
cryptsetup -v luksKillSlot ./evilmaid_fakedisk <keyslot number e.g. "1">
```

### Decrypting and mounting our disk
Now that we have an encrypted container, we're going to want to decrypt our
disk.  To do that, we simply run the following command:

```shell
sudo cryptsetup -v open ./evilmaid_fakedisk evilmaid
```

What just happened?  Why did we need superuser permissions?  Basically, luks's
kernel driver creates a device (in this case at /dev/mapper/evilmaid) that acts
like our decrypted disk.  The kernel driver will read from and write to the
encrypted disk transparently, allowing us to use it just like we would a normal
block device.

Lets actually demonstrate this.  We'll create a filesystem on our decrypted
disk and write a file to it.

```shell
# Format the disk (only run this the first time you decrypt!)
sudo mkfs.ext4 /dev/mapper/evilmaid

# Mount the device
mkdir ./evilmaid_mount
sudo mount /dev/mapper/evilmaid ./evilmaid_mount

# Write a file to the disk
echo "Hello world." > ./evilmaid_mount/butt

# Make sure our file wrote to disk
cat butt

# Unmount the device since we're done with it now
sudo umount ./evilmaid_mount
```

### Re-encrypting our disk
This section's title is technically inaccurate since we don't actually need to
re-encrypt anything (remember, the luks kernel driver is doing encryption and
decryption on the fly for each read and write we perform on its device), but
it describes what we're accomplishing!

To remove the /dev/mapper/evilmaid device and thereby prevent future reads and
writes to our precious encrypted container, simply run the folling:

```shell
cryptsetup -v close evilmaid
```

Now the only trace of our encrypted container on the system is the
./evilmaid_fakedisk we made!

This is all you really need to know about cryptsetup in order to work with
de-luks.  Hopefully you found this interesting as well as helpful!
