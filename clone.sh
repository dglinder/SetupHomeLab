#!/bin/sh
# Usage: clone.sh SOURCE_DIR DEST_DIR
# Where:
#   SOURCE_DIR : The directory containing the VM to clone FROM
#   DEST_DIR   : The directory to clone into.
#
# Alternate usage in a loop:
#    for X in 2 3 4 5 6 7 8 ; do
#      (./clone.sh ansvm0b ansvm${X} 2>&1 | tee clone.ansvm${X}.log ) & sleep 30
#    done
# Then use "watch -n 30 'tail -10 clone.ansvm*.log'" to monitor progoress.
#
#set -x  # Show commands as they are run.
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
#for F in $END.nvram $END.vmdk $END.vmsd $END.vmx ; do
#for F in ${END}*.nvram ${END}*.vmdk ${END}*.vmsd ${END}*.vmx ${END}*.vmsn; do
#for F in ${END}*.nvram ${END}*.vmsd ${END}*.vmx ${END}*.vmsn; do
for F in $(find . -type f -size -2048k) ; do
  echo "Fixing $F"
  sed -i "/$START/ s/$START/$END/g" $F
  sleep 1
done

cd -
