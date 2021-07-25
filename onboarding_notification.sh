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
mysql -uerecharge -precharge@6Dtech -h127.0.0.1 -P3306 ERECHARGE_INDO -ANe "SELECT CASE WHEN LEVEL_ID=2 THEN 'Dealer' WHEN LEVEL_ID=5 THEN 'Agent' WHEN LEVEL_ID=7 THEN 'Vendor' WHEN LEVEL_ID=6 THEN 'Independent Vendor' END AS ITEM, count(LEVEL_ID) AS TOTAL,sum(case when STATUS='1' then 1 else 0 end) as ACTIVE,sum(case when STATUS='0' then 1 else 0 end) AS INACTIVE FROM MFS_ETOPUP_USER_MASTER WHERE LEVEL_ID in (2,5,6,7) GROUP BY LEVEL_ID;\q" > /home/erecharge/Script/Onboarding_status_alert/Onboard_status.txt
cd /home/erecharge/Script/Onboarding_status_alert/
sed -i 's/Independent Vendor/Independent_Vendor/g' Onboard_status.txt

#==Assemble HTML for Report==#
echo '<html>' > body.html
echo '<p>Hello Team,<br /><br />Please find the Onboarding status of '$TodayDate', &nbsp;</p>
<style>
table, th, td {
  border: 2px solid black;
}</style>
<table style="width:350;" border="1"><tbody>
<tr>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>User Level</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Total Users</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Active Users</strong></th>
<th style="font-weight: 400; text-align: center;" width="140" bgcolor="limegreen"><strong>Inactive Users</strong></th>
</tr>' >> body.html
awk '{print "<tr align=center>";for(i=1;i<=NF;i++)print "<td>&nbsp;" $i"</td>";print "</tr>"} END{print "</td></tr>"}' Onboard_status.txt >> body.html
echo '
</tbody></table>
<p><br />Thanks and Regards,</p>
<p><br />SixDee Technologies pvt.ltd<br />No.26, Bannerghatta Main Rd, Bangalore, 560076.</p>
<p><b>Note:</b> This is a system generated mail alert.</p>' >> body.html
echo '</html>' >> body.html
sleep 1;
mv body.html Onboard_status_Body.html
echo "====End===="

