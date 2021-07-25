#!/bin/bash
. ~/.bashrc
#########################
# Author:               #
# Abin Sebastian        #
#Implementation Enginer #
# 6D Technologies       #
#########################

echo "===Start==="
TodayDate=`date +%d-%m-%Y`
CurrTime=`date +%r`
SearchTimeTab=`date -d '1 day ago' "+%Y-%m-%d"`
echo "Today " $TodayDate
echo "LastDay " $SearchTimeTab
mysql -uerecharge -precharge@6Dtech -h127.0.0.1 -P3306 ERECHARGE_INDO -ANe "SELECT MFS_ETOPUP_BULK_RECHARGE_FILE_SUMMARY.FILE_NAME,count(MFS_ETOPUP_BULK_RECHARGE_FILE_DETAILS.ID)as TOTAL_COUNT,sum(CASE WHEN MFS_ETOPUP_BULK_RECHARGE_FILE_DETAILS.STATUS_CODE=0 THEN 1 ELSE 0 END) AS SUCCESS_COUNT,sum(CASE WHEN MFS_ETOPUP_BULK_RECHARGE_FILE_DETAILS.STATUS_CODE!=0 THEN 1 ELSE 0 END) AS FAILURE_COUNT,FORMAT(SUM(CASE WHEN MFS_ETOPUP_BULK_RECHARGE_FILE_DETAILS.STATUS_CODE=0 THEN AMOUNT ELSE 0 END),3)  AS DEBITED_AMOUNT,FORMAT(SUM(MFS_ETOPUP_BULK_RECHARGE_FILE_DETAILS.AMOUNT),3) AS TOTAL_AMOUNT,CASE WHEN TYPE=1 THEN 'TOPUP' ELSE 'SUBSCRIPTION' END AS RECHARGE_TYPE,MFS_ETOPUP_BULK_RECHARGE_FILE_SUMMARY.UPLOADED_USER_ID as USER_ID,MFS_ETOPUP_BULK_RECHARGE_FILE_SUMMARY.UPLOADED_DATE AS UPDATED_DATE FROM MFS_ETOPUP_BULK_RECHARGE_FILE_DETAILS JOIN MFS_ETOPUP_BULK_RECHARGE_FILE_SUMMARY ON (MFS_ETOPUP_BULK_RECHARGE_FILE_DETAILS.FILE_ID=MFS_ETOPUP_BULK_RECHARGE_FILE_SUMMARY.FILE_ID) AND UPLOADED_DATE LIKE '$SearchTimeTab%' GROUP BY MFS_ETOPUP_BULK_RECHARGE_FILE_SUMMARY.FILE_NAME;\q" > /home/erecharge/Script/BULK_STATUS/Bulk_status.txt
cd /home/erecharge/Script/BULK_STATUS/
sed -i 's/ /_/g' Bulk_status.txt

#==Assemble HTML for Report==#
echo '<html>' > body.html
echo '<p>Hello Team,<br /><br />Please find the list of Bulk Recharge Transactions on '$SearchTimeTab', &nbsp;</p>
<style>
table, th, td {
  border: 2px solid black;
}</style>
<table style="width:350;" border="1"><tbody>
<tr>
<th style="font-weight: 400; text-align: center;" width="180" bgcolor="limegreen"><strong>File Name</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Total Count</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Success Count</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Failure Count</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Debited Amount</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Total Amount</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Recharge Type</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>User ID</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Updated Date</strong></th>
</tr>' >> body.html
awk '{print "<tr align=center>";for(i=1;i<=NF;i++)print "<td>&nbsp;" $i"</td>";print "</tr>"} END{print "</td></tr>"}' Bulk_status.txt >> body.html
echo '
</tbody></table>
<p><br />Thanks and Regards,</p>
<p><br />SixDee Technologies pvt.ltd<br />No.26, Bannerghatta Main Rd, Bangalore, 560076.</p>
<p><b>Note:</b> This is a system generated mail alert.</p>' >> body.html
echo '</html>' >> body.html
sleep 1;
mv body.html Bulk_status_Body.html
echo "====End===="

