#!/bin/bash

dir=`dirname $0`
logfile=$1.log
failonerror=true

if [ "${3}" = "false" ]; then
	failonerror=false
fi

_ts=$(date +%s%N)
$dir/asmunit_runner.sh $1 $2 > $logfile
_tt=$((($(date +%s%N) - $_ts)/1000000))
test_ok=`grep "PASS" $logfile | wc -l`
test_fail=`grep "FAIL" $logfile | wc -l`
tests=`expr $test_ok + $test_fail`

TARGET_DIR=target/test-reports

mkdir -p ${TARGET_DIR}
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<testsuite xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"https://maven.apache.org/surefire/maven-surefire-plugin/xsd/surefire-test-report.xsd\" 
	name=\"${1}\"
	time=\"$(awk "BEGIN {printf (\"%.3f\"), ${_tt}/1000}")\"
	tests=\"${tests}\"
	errors=\"0\"
	skipped=\"0\"
	failures=\"${test_fail}\">" > ${TARGET_DIR}/${1}.xml
	
	while IFS='' read -r line || [[ -n "$line" ]]; do
		if [[ $line =~ ^\[(.*)\]$ ]] ; then
#			echo ${BASH_REMATCH[1]} line was $line
			echo "<testcase name=\"${BASH_REMATCH[1]}\" classname=\"${1}\" time=\"0\"/>" >> ${TARGET_DIR}/${1}.xml
#		echo "<testcase name=\"\" classname=\"${1}\" time=\"0\"/>"
		fi
	done < $logfile
  
echo "</testsuite>" >> ${TARGET_DIR}/${1}.xml

echo "Tests run: "${tests}", Failures: ${test_fail}"
if [ -n "`grep FAIL $logfile`" ] ; then
	cat $logfile
	if [ $failonerror = true ]; then
		exit 1
	fi
fi
exit 0