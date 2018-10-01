#!/bin/bash

dir=`dirname $0`
logfile=$1.log
$dir/asmunit_runner.sh $1 $2 > $logfile
test_ok=`grep "PASS" $logfile | wc -l`
test_fail=`grep "FAIL" $logfile | wc -l`
tests=`expr $test_ok + $test_fail`

echo "Tests run: "${tests}", Failures: ${test_fail}"
if [ -n "`grep FAIL $logfile`" ] ; then
        cat $logfile
        exit 1
fi

TARGET_DIR=target/surefire-reports

mkdir -p ${TARGET_DIR}
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<testsuite xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"https://maven.apache.org/surefire/maven-surefire-plugin/xsd/surefire-test-report.xsd\" 
	name=\"${1}\" \ time=\"0.001\" tests=\"${tests}\" errors=\"0\" skipped=\"0\" failures=\"${test_fail}\">
  <testcase name=\"\" classname=\"${1}\" time=\"0\"/>
</testsuite>" > ${TARGET_DIR}/${1}.xml

exit 0