#!/bin/bash
# sq2h
CRSNAME=asmss2023
SCRIPTDIR=/home/quagadmin/courses/$CRSNAME/bash
DIRTOFETCH=ex/asm_ex03
TESTSTUDENT=/home/quagadmin/courses/$CRSNAME/students/20230303_test_student_usernames_asmss2023.txt
STUDENTUSER=/home/quagadmin/courses/$CRSNAME/students/20230303_student_usernames_$CRSNAME.txt
#' fetch individual directory
#' change to progdir
cd $SCRIPTDIR

#' fetch for test student
cat $TESTSTUDENT | while read s
do
  echo " * Student: $s"
  ./fetch.sh -s $s -d $DIRTOFETCH
  sleep 2
done

#' fetch for real students
cat $STUDENTUSER | while read s
do
  echo " * Student: $s"
  ./fetch.sh -s $s -d $DIRTOFETCH
  sleep 2
done

# check content
cat $STUDENTUSER | while read s
do
  echo " * Student: $s"
  ls -l /home/quagadmin/courses/$CRSNAME/home/$s/$CRSNAME/$DIRTOFETCH
  sleep 2
done
