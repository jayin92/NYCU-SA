#!/usr/local/bin/bash
# /root/uploadscript.sh

if [[ $1 == *.exe ]]; then
        mv $1 /home/ftp/hidden/.exe/
        logger -p local2.warning "${1} violate file detected. Uploaded by ${UPLOAD_VUSER}." # -p: log pid
fi