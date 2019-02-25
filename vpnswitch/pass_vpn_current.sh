#! /bin/bash
if ls *.conf > /dev/null ; then
    F="`ls *.conf`"
    basename "$F" .conf
else
    exit 1
fi
