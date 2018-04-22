#!/usr/bin/env bash
 # This is script will show net attacker's ip and location

 # Make sure a file was supplied as an argument
if [[ "${#}" -ne 1 ]]
then
  echo "Cannot open log file: " >&2
  exit 1
fi

if [[ ! -e "${1}" ]]
then
  echo "Cannot open log file: ${1}" >&2
  exit 1
fi

#grep "Failed password for root from" syslog-sample|awk -F ' ' '{print $11}'|sort|uniq -c|awk '{if ($1 > 10) print}'|sort -n  > ipslog
#ips=`grep "Failed password for root from" syslog-sample|awk -F ' ' '{print $11}'|sort|uniq -c|awk '{if ($1 > 10) print}'|sort -nr`
ips=`grep Failed syslog-sample |awk '{print $(NF - 3)}'|sort|uniq -c|awk '{if($1 > 10) print}'|sort -rn`
line_total=`wc -l ipslog`
#echo "totle items: ${line_total}"

 # Display the CSV header.
echo "Count, IP, Location"
#count=`grep "Failed password for root from" ${1}|awk -F ' ' '{print $11}'|sort|uniq -c|awk '{print $1 }'`
#ips=`grep "Failed password for root from" ${1}|awk -F ' ' '{print $11}'|sort|uniq -c|awk '{print $2 }'`
#echo ${ips} ${count}


 # Loop through the list of the failed attempts and corresponding IP addresses
#for i in $(cat ipslog);
#do
#	echo "item ${i}"
#done
idx=0
for i in ${ips}
do
	#echo "ips ${i}"
	if [[ "${idx}" -eq 1 ]]
	then
		location=`geoiplookup ${i}|awk -F ',' '{print $2}'`
		idx=0
		#echo "IP: ${i}"
		#echo "location: ${location}"
		echo "${count}, ${i}, ${location}"
	else
		count=`echo ${i}`
		idx=1
		#echo "count: ${count}"
	fi
	
done


 # If the number of failed attempts is greater than the limit, display count, IP, and location.
