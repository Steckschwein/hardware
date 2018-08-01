#!/bin/bash

dir=`dirname $0`
logfile=$1.log
$dir/asmunit_runner.sh $1 $2 > $logfile
test_ok=`grep "PASS" $logfile | wc -l`
test_fail=`grep "FAIL" $logfile | wc -l`
echo "Tests run: "`expr $test_ok + $test_fail`", Failures: ${test_fail}"
if [ -n "`grep FAIL $logfile`" ] ; then
        cat $logfile
        exit 1
fi

exit 0