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
mysql -uerecharge -precharge@6Dtech -h127.0.0.1 -P3306 ERECHARGE_MALAWI -ANe "select SERVICE_NAME ,count(*) AS TOTAL,sum(case when ERROR_TYPE='S' then 1 else 0 end) AS SUCCESS_COUNT,sum(case when ERROR_TYPE='F' then 1 else 0 end) AS FAILURE_COUNT FROM MFS_ETOPUP_CDR_MASTER where CHANNEL_NAME IN ('USSD','WEB','MOBILE','POS') and SERVICE_NAME IN ('TOPUP','E-VOUCHER','SUBSCRIPTION','DEALER TOPUP') and TRANSACTION_DATE like '$SearchTimeTab%' and ERROR_TYPE !='P' group by SERVICE_NAME;\q" > /home/erecharge/Script/TextResult.txt
cd /home/erecharge/Script/
sed -i 's/DEALER TOPUP/DEALER_TOPUP/g' TextResult.txt
#sed -i 's/\tS/\tSUCCESS/g' TextResult.txt
#sed -i 's/\tF/\tFAILURE/g' TextResult.txt

#==Assemble HTML for Report==#
echo '<html>' > body.html
echo '<p>Hello Team,<br /><br />Please find the LastDay -- '$SearchTimeTab' Transaction Alert.&nbsp;</p>
<style>
table, th, td {
  border: 2px solid black;
}</style>
<table style="width:350;" border="1"><tbody>
<tr>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Service</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Total</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Success Count</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Failure Count</strong></th>
</tr>' >> body.html
awk '{print "<tr align=center>";for(i=1;i<=NF;i++)print "<td>&nbsp;" $i"</td>";print "</tr>"} END{print "</td></tr>"}' TextResult.txt >> body.html
echo '
</tbody></table>
<p><br />Thanks and Regards,</p>
<p><br />SixDee Technologies pvt.ltd<br />No.26, Bannerghatta Main Rd, Bangalore, 560076.</p>
<p><b>Note:</b> This is a system generated mail alert.</p>' >> body.html
echo '</html>' >> body.html
sleep 1;
mv body.html Txn_Report_Body.html
echo "====End===="
