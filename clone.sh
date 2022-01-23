#!/bin/sh
#
# Description: Quick(ish) way to clone a VM on an ESXi host from the
#   underlying Unix shell prompt.
#
# NOTE: This does NOT adjust the IP addresses, nor the MAC addresses so
#   there is potential for conflicts between the source and the cloned VMs.
#
# Usage: clone.sh SOURCE_DIR DEST_DIR
#
# Where:
#   SOURCE_DIR : The directory containing the VM to clone FROM
#   DEST_DIR   : The directory to clone into.
#set -x
set -e  # Exit on any error
set -u  # Exit on any undefined variable

START=$1
END=$2

if [[ -e $END ]] ; then
  echo "ERROR: Destination directory must not exist!"
  exit 1
fi

echo "Recusively copying $START to $END"
cp -rv $START $END

echo "Renaming files in $END"
cd $END
for X in `ls -1 *$START*` ; do
  echo "Renaming $X to $START - $END"
  N=`echo $X | sed "s/$START/$END/"`
  mv -v $X $N
done

echo "Adjusting files in $END"
for F in $END.nvram $END.vmdk $END.vmsd $END.vmx ; do
  echo "Fixing $F"
  sed -i "s/$START/$END/g" $F
done

cd -

