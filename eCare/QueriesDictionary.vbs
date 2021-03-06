Option Explicit

Public Function fCheckQueryResults (ByVal sStepName, ByVal sStepDesc, ByVal rc)

'----------------------------------------------------------------
' Function name: fCheckQueryResults
' Description: The function check the query results
' Parameters: sStepName, sStepDesc, rc
' Return value: Success - True, Failure - False
'----------------------------------------------------------------
	
	Dim sResult
    If rc = False Then					'DB connection failed /Ouery execution failed
		Call fReport(sStepName,sStepDesc,"FAIL","DB connection failed /Ouery execution failed",0)
		fCheckQueryResults = False
		Exit Function		
	ElseIf rc = NO_RECORDS_FOUND Then	'NO_RECORDS_FOUND
		Call fReport(sStepName,sStepDesc,"INFO","No records return by the query",1)
		fCheckQueryResults = False
		Exit Function
    End If

	fCheckQueryResults = True
End Function

Public Function fGetQuery (ByVal sQueryName, ByVal arrParamValue)
	
'----------------------------------------------------------------
' Function name: fGetQuery
' Description: The function reutrns sql query by query name. And replace all parameters in query [optional]
' Parameters: sQueryName - 	Name on QueriesDictionary, [optional]arrParamValue - 2d array of parameters values: Key + value 
'							(If there are no query parameters, send an empty string - ""
' Return value: Success - SQL query
'----------------------------------------------------------------
	
	Dim sSQL

	sSQL = QueriesDictionary(lcase(sQueryName))
	If arrParamValue(0,0) <> "" Then
		For i = 0 to uBound(arrParamValue) 
			If instr (1,sSQL, "<" & arrParamValue(i,0) & ">") > 0 Then
				sSQL = Replace(sSQL, "<" & arrParamValue(i,0) & ">", arrParamValue(i,1))
			End If
		Next
	End If

	fGetQuery = sSQL
	
End Function

'----------------------------------------------------------------
'---------------------  Queries dictionary  ---------------------
'----------------------------------------------------------------

Dim QueriesDictionary
Set QueriesDictionary = CreateObject("Scripting.Dictionary")

'################
QueriesDictionary("UnbilledTraffic_query") = "" & _
"SELECT  DESTINATION_NAME ""DESTINATION NAME"" " & _
",to_char(units,'999,999,990.99') ""MINUTES/MESSAGE"" " & _
",currency ""CURRENCY"" " & _
",to_char(amount,'999,999,990.99') ""TOTAL CHARGES"" " & _
",to_char(""CONVERSION CURRENCY RATE"",'990.9999') ""CONVERSION CURRENCY RATE"" " & _
",to_char(amount*""CONVERSION CURRENCY RATE"",'999,999,990.99') ""CONVERTED AMOUNT"" " & _
"FROM( " & _
"SELECT DESTINATION_NAME " & _
",units " & _
",currency " & _
",amount " & _
",(SELECT distinct round(RATE,4) FROM billing.EXCHANGE_RATE " & _ 
"WHERE FROM_CURRENCY = currency AND TO_CURRENCY = TODO :to_currency) ""CONVERSION CURRENCY RATE"" " & _
",CUSTOMER_ID " & _
",DESTINATION_ID " & _ 
",SELF_DECLARE_FLAG " & _
",APPLICATION " & _
"FROM billing.CUST_UNBILLED " & _
"WHERE self_declare_flag = 0 " & _
"AND customer_id IN (SELECT ID FROM billing.CUSTOMER_MASTER WHERE headquarters =:cust_id)) " & _
"where 1=1 " & _
"ORDER BY destination_name --or other sort: units or amount or currency + ASC or DESC " & _
",CUSTOMER_ID, DESTINATION_ID, CURRENCY, SELF_DECLARE_FLAG, APPLICATION "
'"--Filter by "DESTINATION NAME"
'"--and UPPER(DESTINATION_NAME) like UPPER('%'|| :filterDestination ||'%')
'"--Filter by "MINUTES / MESSAGE"
'"--and units >= :filterMinutes -- or = or <=
'"--Filter by "TOTAL CHARGES"
'"--and amount >= :filterTotalCharges  -- or = or <=
'"--Filter by "CURRENCY"
'"--and UPPER(currency) like UPPER(:filterCurrency)    

'################
QueriesDictionary("OpenTransactions_query") = "" & _
"SELECT  ""TRANSACTION TYPE"" " & _
",document_reference ""REFERENCE"" " & _
",to_char(document_date, 'mm/dd/yy') ""DOCUMENT DATE"" " & _
",to_char(due_date, 'mm/dd/yy') ""DUE DATE"" " & _
",document_currency ""CURRENCY"" " & _
",to_char(document_amount,'999,999,990.99') ""TOTAL AMOUNT"" " & _
",to_char(open_amount,'999,999,990.99') ""OPEN AMOUNT"" " & _
",to_char(""CONVERSION CURRENCY RATE"",'990.9999') ""CONVERSION CURRENCY RATE"" " & _
",to_char(open_amount*""CONVERSION CURRENCY RATE"",'999,999,990.99') ""CONVERTED AMOUNT"" " & _
"FROM( " & _ 
"SELECT " & _
"case item_type " & _
"when 'C' then 'Credit Memo' " & _
"when 'I' then 'Invoice' " & _
"when 'P' then 'Payment' " & _
"when 'O' then 'Remaining Balance' " & _       
"End ""TRANSACTION TYPE"" " & _
",document_reference " & _
",document_date " & _
",due_date " & _
",document_currency" & _ 
",document_amount " & _
",open_amount" & _
",(SELECT distinct round(RATE,4) FROM billing.EXCHANGE_RATE " & _
"WHERE FROM_CURRENCY = document_currency AND TO_CURRENCY = :to_currency) ""CONVERSION CURRENCY RATE"" " & _
",YEAR " & _
",COMPANY " & _
",SAP_DOCUMENT_NUMBER " & _
",SAP_DOCUMENT_LINE_ITEM " & _
"FROM BILLING.CUSTOMER_BILLED_TRANS " & _
"WHERE customer_id in(SELECT ID FROM BILLING.CUSTOMER_MASTER WHERE headquarters = :customerID)) " & _ 
"where 1=1 " & _
"ORDER BY document_date DESC -- or other sort: ""TRANSACTION TYPE"" or document_reference or document_date or due_date or document_amount or open_amount or document_currency + ASC or DESC " & _ 
",YEAR, COMPANY, SAP_DOCUMENT_NUMBER, SAP_DOCUMENT_LINE_ITEM "
'"--Filter by "TRANSACTION TYPE"
'"--and UPPER("TRANSACTION TYPE") like UPPER(:FilterTransactionType)
'"--Filter by "REFERENCE"
'"--and UPPER(document_reference) like UPPER('%'|| :reference ||'%')
'"--Filter by "DOCUMENT DATE"
'"--and document_date >= to_date(:FilterDocumentDate, 'mm/dd/yy')  -- or = or <= 
'"--Filter by "DUE DATE"
'"--and due_date >= to_date(:FilterDueDate, 'mm/dd/yy')  -- or = or <=
'"--Filter by "TOTAL AMOUNT"
'"--and document_amount >= :FilterTotalAmount -- or = or <= 
'"--Filter by "OPEN AMOUNT"
'"--and open_amount >= :FilterOpenAmount -- or = or <= 
'"--Filter by "CURRENCY"
'"--and UPPER(document_currency) like UPPER(:FilterCurrency)

'################
QueriesDictionary("invoices_query") = "" & _
"SELECT document_reference ""INVOICE ID"" " & _
",to_char(document_date,'mm/dd/yy') ""INVOICE DATE"" " & _
",document_currency ""CURRENCY"" " & _
",to_char(document_amount,'999,999,990.99') ""INVOICE AMOUNT"" " & _
",to_char(paid_amount,'999,999,990.99') ""PAID AMOUNT""" & _
",to_char(cleared_amount,'999,999,990.99') ""OTHER CLEARED AMOUNT"" " & _
",to_char(open_amount,'999,999,990.99') ""OPEN AMOUNT"" " & _
",to_char(""CONVERSION CURRENCY RATE"",'990.9999') ""CONVERSION CURRENCY RATE"" " & _
",to_char(open_amount*""CONVERSION CURRENCY RATE"",'999,999,990.99') ""CONVERTED OPEN AMOUNT"" " & _
"FROM( " & _
"    SELECT document_reference " & _
"    ,document_date " & _  
"    ,document_currency " & _
"    ,document_amount " & _
"    ,paid_amount " & _
"    ,cleared_amount " & _
"    ,open_amount " & _
"    ,(SELECT distinct round(RATE,4) FROM billing.EXCHANGE_RATE WHERE FROM_CURRENCY = document_currency AND TO_CURRENCY = '<TO_CURRENCY>') ""CONVERSION CURRENCY RATE"" " & _
"    ,YEAR " & _
"    ,COMPANY  " & _
"    ,SAP_DOCUMENT_NUMBER " & _ 
"    ,SAP_DOCUMENT_LINE_ITEM " & _
"    FROM BILLING.CUSTOMER_INVOICE_HISTORY " & _
"    WHERE customer_id in(SELECT ID FROM billing.CUSTOMER_MASTER WHERE headquarters = <CUSTOMER_ID>)  " & _   
") " & _
"where 1=1 " & _
"order by document_date DESC "& _
",YEAR, COMPANY, SAP_DOCUMENT_NUMBER, SAP_DOCUMENT_LINE_ITEM"
'"--Filter BY "INVOICE ID" _
'"--and UPPER(document_reference) like UPPER('%' || :FilterInvoiceID || '%')
'"--Filter by "INVOICE DATE"
'"--and document_date >= to_date(:FilterInvoiceDate, 'mm/dd/yy')  -- or = or <=    
'"--Filter BY "INVOICE AMOUNT"
'"--and document_amount >= :FilterInvoiceAmount  -- or = or <= 
'"--Filter BY "PAID AMOUNT"
'"--and paid_amount >= :FilterPaidAmount  -- or = or <= 
'"--Filter BY "OTHER CLEARED AMOUNT"
'"--and cleared_amount >= :FilterClearedAmount  -- or = or <=  
'"--Filter BY "OPEN AMOUNT"
'"--and  open_amount >= :FilterOpenAmount  -- or = or <=   
'"--Filter BY "CURRENCY"
'"--and UPPER(document_currency) like UPPER('%' || :FilterCurrency || '%') " & _

'################
QueriesDictionary("Payments/Credits_query") = "" & _
"SELECT to_char(document_date,'mm/dd/yy') ""PAYMENT DATE"" " & _
",document_reference ""REFERENCE"" " & _
",to_char(document_amount, '999,999,990.99') ""AMOUNT"" " & _
",document_currency ""CURRENCY"" " & _
"FROM( " & _
"SELECT document_date " & _
",document_reference " & _
",document_amount " & _
",document_currency " & _
",YEAR " & _
",COMPANY " & _
",SAP_DOCUMENT_NUMBER " & _
",SAP_DOCUMENT_LINE_ITEM " & _ 
"FROM billing.CUST_PMT_CMEMO_HIST_HEADER " & _
"WHERE customer_id in(SELECT ID FROM billing.CUSTOMER_MASTER WHERE headquarters = :cust_id)) " & _
"where 1 = 1 " & _
"ORDER BY document_date DESC -- or other sort: document_reference or document_amount or document_currency + ASC or DESC " & _ 
",YEAR, COMPANY, SAP_DOCUMENT_NUMBER, SAP_DOCUMENT_LINE_ITEM "
'"--Filter by "PAYMENT DATE"
'"--and document_date >= to_date(:FilterPaymentDate, 'mm/dd/yy')  -- or = or <=    
'"--Filter by "REFERENCE"
'"--and UPPER(document_reference) like UPPER('%' || :FilterReference || '%')
'"--Filter by "AMOUNT"
'"--and document_amount >= :FilterAmount -- or = or <=
'"--Filter by "CURRENCY"
'"--and UPPER(document_currency) like UPPER('%' || :FilterCurrency || '%')

'################
'QueriesDictionary("InvoicesAssociatedWithPayment_query") = "" & _

'--Use this query in order to get the "DOCUMENT NUMBER" of a specific row 
QueriesDictionary("DocumentNumber_query") = "" & _
"SELECT to_char(document_date,'mm/dd/yy') ""PAYMENT DATE"" " & _
",document_reference ""REFERENCE"" " & _
",to_char(document_amount, '999,999,990.99') ""AMOUNT"" " & _
",document_currency ""CURRENCY"" " & _
",'  -->  ' "" "" " & _
",SAP_DOCUMENT_NUMBER ""DOCUMENT NUMBER"" " & _
"FROM( " & _
"SELECT document_date " & _
",document_reference " & _
",document_amount " & _
",document_currency " & _
",YEAR " & _
",COMPANY " & _
",SAP_DOCUMENT_NUMBER " & _
",SAP_DOCUMENT_LINE_ITEM " & _
"FROM billing.CUST_PMT_CMEMO_HIST_HEADER " & _
"WHERE customer_id in(SELECT ID FROM billing.CUSTOMER_MASTER WHERE headquarters = :cust_id)) " & _
"where 1 = 1 " & _
"ORDER BY document_date DESC -- or other sort: document_reference or document_amount or document_currency + ASC or DESC " & _    
",YEAR, COMPANY, SAP_DOCUMENT_NUMBER, SAP_DOCUMENT_LINE_ITEM "
'--Filter by "PAYMENT DATE"
'--and document_date >= to_date(:FilterPaymentDate, 'mm/dd/yy')  -- or = or <=    
'--Filter by "REFERENCE"
'--and UPPER(document_reference) like UPPER('%' || :FilterReference || '%')
'--Filter by "AMOUNT"
'--and document_amount >= :FilterAmount -- or = or <=
'--Filter by "CURRENCY"
'--and UPPER(document_currency) like UPPER('%' || :FilterCurrency || '%')

'--Use this query in order to get the 'Associated Invoices'. 
'--Replace the DocumentNumber paramter with the document number you found in query (*)
QueriesDictionary("InvoicesAssociatedWithPayment_query") = "" & _
"SELECT PAID_DOCUMENT_REFERENCE ""INVOICE ID"" " & _
",to_char(PAID_DOCUMENT_DATE,'mm/dd/yy') ""INVOICE DATE"" " & _
",to_char(PAID_DOCUMENT_AMOUNT,'999,999,990.99') ""APPLIED AMOUNT"" " & _
",PH.DOCUMENT_CURRENCY ""CURRENCY"" " & _
"FROM billing.CUST_PMT_CMEMO_HIST_DETAIL pd " & _
"JOIN billing.CUST_PMT_CMEMO_HIST_HEADER ph on PD.PAYMENT_SAP_DOCUMENT_NUMBER = PH.SAP_DOCUMENT_NUMBER " & _
"WHERE ph.customer_id in(SELECT ID FROM billing.CUSTOMER_MASTER WHERE headquarters = :cust_id) " & _
"and PAYMENT_SAP_DOCUMENT_NUMBER = :DocumentNumber --Replace by document number " & _ 
"ORDER BY PAID_DOCUMENT_DATE DESC -- or other sort: PAID_DOCUMENT_REFERENCE or PAID_DOCUMENT_AMOUNT or PH.DOCUMENT_CURRENCY "   

'################
QueriesDictionary("Disputes_query") = "" & _
"SELECT document_reference ""INVOICE ID"" " & _
",to_char(dispute_date,'mm/dd/yy') ""DISPUTE DATE"" " & _
",dispute_case_number ""CASE NUMBER"" " & _
",currency ""CURRENCY"" " & _
",to_char(invoice_amount,'999,999,990.99') ""INVOICE AMOUNT"" " & _
",to_char(dispute_amount,'999,999,990.99') ""DISPUTE AMOUNT"" " & _
"FROM( " & _
"SELECT document_reference " & _
",dispute_date " & _
",dispute_case_number " & _
",currency " & _
",invoice_amount " & _
",dispute_amount " & _
",CUSTOMER_ID " & _
"FROM billing.CUSTOMER_DISPUTES_FROM_SAP " & _
"WHERE customer_id in(SELECT ID FROM billing.CUSTOMER_MASTER WHERE headquarters = :cust_id)) " & _
"where 1 = 1 " & _
"ORDER BY dispute_date DESC -- or other sort: document_reference or dispute_case_number or invoice_amount or dispute_amount or currency + ASC or DESC " & _ 
",CUSTOMER_ID, DISPUTE_CASE_NUMBER "
'--Filter by "INVOICE ID"
'--and UPPER(document_reference) like UPPER('%' || :FilterInvoiceID ||'%')
'--Filter by "DISPUTE DATE"
'--and dispute_date  >= to_date(:FilterDisputeDate, 'mm/dd/yy')  -- or = or <=      
'--Filter by "CASE NUMBER"
'--and UPPER(dispute_case_number) like UPPER('%' || :FilterCaseNumber ||'%')
'--Filter by "INVOICE AMOUNT"
'--and invoice_amount >= :FilterInvoiceAmount -- or = or <=
'--Filter by "DISPUTE AMOUNT"
'--and dispute_amount >= :FilterDisputeAmount -- or = or <=
'--Filter by "CURRENCY"
'--and UPPER(currency) like UPPER('%' || :FilterCurrency ||'%')

'################
QueriesDictionary("Alerts_query") = "" & _
"SELECT to_char(SENT_DATE,'mm/dd/yy hh:mi AM') ""ALERT DATE and TIME (GMT)"" " & _
",SEVERITY ""SEVERITY"" " & _
",MESSAGE ""ALERT MESSAGE"" " & _
"FROM( " & _
"SELECT SENT_DATE " & _
",case SEVERITY " & _
"when 0 then 'Info' " & _
"when 1 then 'Warning' " & _
"when 2 then 'Critical' " & _
"when 3 then 'Block' " & _
"else 'Clear' " & _
"end SEVERITY " & _
",MESSAGE " & _
",CUSTOMER_ID " & _
"FROM billing.ECARE_CUSTOMER_ALERT_HISTORY " & _
"WHERE customer_id in(SELECT ID FROM billing.CUSTOMER_MASTER WHERE headquarters = :cust_id)) " & _
"WHERE 1=1 " & _
"ORDER BY SENT_DATE DESC --or other sort: " & _
",CUSTOMER_ID, SENT_DATE "
'--Filter by "ALERT DATE and TIME (GMT)"
'--and SENT_DATE  >= to_date(:FilterSentDate, 'mm/dd/yy hh:mi AM')  -- or = or <=
'--Filter by "SEVERITY"
'--and UPPER(SEVERITY) like UPPER('%' || :FilterSeverity || '%')

''################
'QueriesDictionary("OpenTickets_query") = "" & _
' No queries for ticketing
''################
'QueriesDictionary("SeacrhTickets_query") = "" & _

'################
QueriesDictionary("FraudAlerts_query") = "" & _
"SELECT PR.PL_ROUTE_DESC AS ""DESTINATION"" " & _
",CASE TO_CHAR(AD.SEVERITY) " & _
"WHEN '1' THEN 'Info' " & _
"WHEN '2' THEN 'Warning' " & _
"WHEN '3' THEN 'Critical' " & _
"END AS ""SEVERITY TYPE"" " & _
",CASE AD.STATUS " & _
"WHEN 'N' THEN 'New' " & _
"WHEN 'I' THEN 'Ignored' " & _
"WHEN 'A' THEN 'Acknowledged' " & _
"WHEN 'B' THEN 'Blocked' " & _
"END AS ""STATUS"" " & _
",TO_CHAR(AD.CREATE_DATE,'MM/DD/YY') AS ""CREATED DATE"" " & _
",TO_CHAR(AD.UPDATE_DATE,'MM/DD/YY') AS ""UPDATE DATE"" " & _
",CASE AD.STATUS " & _
"WHEN 'N' THEN 'Blocked Acknowledged Ignore' " & _
"WHEN 'I' THEN 'Blocked Acknowledged' " & _
"WHEN 'A' THEN 'Blocked' " & _
"WHEN 'B' THEN ' ' " & _
"END AS ""ACTION"" " & _
"FROM ICATCHU.ALERT_DETAILS AD " & _
"JOIN XTRACT.MIS_PREFFERED_ROUTE PR ON AD.PREFERRED_ROUTE_PARENT_ID = PR.PREFFERED_ROUTE_ID " & _
"WHERE AD.CUSTOMER_ID = :CUSTOMER_ID --REPLACE BY CUSTOMER ID " & _
"AND AD.RMS_CUSTOMER_ID IN(SELECT RMS_ID FROM BILLING.ECARE_RMS_CUSTOMER_MAP WHERE CUSTOMER_ID = 101215) " & _
"AND AD.CREATE_DATE IS NOT NULL " & _
"AND AD.STATUS LIKE :STATUS --REPLACE BY STATUS N/B/I/A " & _
"AND AD.PREFERRED_ROUTE_PARENT_ID IN " & _
"(SELECT PR.PREFFERED_ROUTE_ID from XTRACT.MIS_PREFFERED_ROUTE PR where PR.COUNTRY_ID = " & _
"(SELECT MC.COUNTRY_ID FROM XTRACT.MIS_COUNTRY MC WHERE MC.NAME LIKE '%' || :COUNTRY_NAME || '%')) --Replace by country name " & _
"AND AD.SEVERITY = :SEVERITY --REPLACE BY SEVERITY 1-Info, 2-Warning, 3-Critical " & _
"AND AD.CREATE_DATE BETWEEN TO_DATE(:FROMDATE,'MM/DD/YY') AND TO_DATE(:TODATE,'MM/DD/YY')  --REPLACE BY DATE RANGE"

'################
QueriesDictionary("CLI_query") = "" & _
"select DESTINATION " & _
",TO_CHAR(Max(CREATE_DATE),'MM/DD/YY) ""LAST TEST DATE"" " & _
",round ((SUM(SUCCESS_CALLS)/SUM(CALL_COUNT))*100,0)|| '%' as ""CLI%"" " & _
"from XTRACT.ASCADE_KPI_PRODUCT_DEST_CLI " & _
"where PRODUCT_NAME like :product --Replace by 'PV' or 'PV/IPX' " & _
"and DESTINATION like '%'||:destination||'%' -- Replace by destination or remove for 'All' " & _
"and CREATE_DATE between to_date(:from_date, 'MM/DD/YY hh:mi AM')--Replace by to date " & _ 
"and to_date(:to_date, 'MM/DD/YY hh:mi AM')--Replace by from date " & _
"Group by DESTINATION " & _
"Order by DESTINATION"       

'################
QueriesDictionary("Tickets_query") = "" & _
"SELECT ""SLA FAULT CATEGORY"" " & _
",""TICKETS COUNT"" " & _
",replace(floor(MAX_MTTR/3600) || ':' || to_char(floor((MAX_MTTR - floor(MAX_MTTR/3600)*3600)/60),'09'),' ','') ""MAX TTR SERVICE (Hrs)"" " & _
",replace(floor(MIN_MTTR/3600) || ':' || to_char(floor((MIN_MTTR - floor(MIN_MTTR/3600)*3600)/60),'09'),' ', '') ""MIN TTR SERVICE (Hrs)"" " & _
"from( " & _
"select SLA_FAULT_CATEGORY ""SLA FAULT CATEGORY"" " & _
",count(*) ""TICKETS COUNT"" " & _
",max((LAST_RESOLVED_DATE-REPORTED_DATE)*24*60*60 - nvl(TOTALPENDINGSECONDS,0)) as MAX_MTTR " & _
",min((LAST_RESOLVED_DATE-REPORTED_DATE)*24*60*60 - nvl(TOTALPENDINGSECONDS,0)) as MIN_MTTR " & _ 
"from XTRACT.ARADMIN_KPI_VW_TICKETS kpi join XTRACT.MIS_PRODUCT " & _
"prod on kpi.product_id = PROD.PRODUCT_ID " & _
"where LAST_RESOLVED_DATE is not null " & _ 
"and SAP_ID like :customerID --Replace by customer id " & _
"and SLA_FAULT_CATEGORY like ('%'||:slaCategory||'%') --Replace by category OR remove for 'All' " & _    
"and short_name like ('%'||:productName||'%')  --Replace by product name OR remove foe 'All' " & _
"--and REPORTED_DATE between to_date(:from_date,'mm/dd/yy hh:mi am') --Replace by to date " & _
"--and to_date(:to_date,'mm/dd/yy hh:mi am') --Replace by from date " & _
"and LAST_RESOLVED_DATE >= to_date(:from_date,'mm/dd/yy hh:mi am') --Replace by to date " & _
"and REPORTED_DATE <= to_date(:to_date,'mm/dd/yy hh:mi am') --Replace by from date " & _
"Group by SLA_FAULT_CATEGORY " & _
"order by SLA_FAULT_CATEGORY)"                

'################
QueriesDictionary("PVIPXIPQuality_query") = "" & _
"SELECT SITE.SITE_NAME ""SITE"" " & _ 
",mis.PL_ROUTE_DESC ""DESTINATION"" " & _
",to_char(round(nvl(AVG((CUSTOMER_AVG_DELAY + VENDOR_AVG_DELAY)),0),2),'999,999,990.99') ""AVG DELAY"" " & _
",to_char(round(nvl(MIN((CUSTOMER_MIN_DELAY + VENDOR_MIN_DELAY)),0),2),'999,999,990.99') ""MIN DELAY"" " & _
",to_char(round(nvl(MAX((CUSTOMER_MAX_DELAY + VENDOR_MAX_DELAY)),0),2),'999,999,990.99') ""MAX DELAY"" " & _
",to_char(round(greatest (nvl(AVG(CUSTOMER_AVG_JITTER),0), nvl(AVG(VENDOR_AVG_JITTER),0)),2),'999,999,990.99') ""AVG JITTER"" " & _
",to_char(round(greatest (nvl(MIN(CUSTOMER_MIN_JITTER),0), nvl(MIN(VENDOR_MIN_JITTER),0)),2),'999,999,990.99') ""MIN JITTER"" " & _
",to_char(round(greatest (nvl(MAX(CUSTOMER_MAX_JITTER),0), nvl(MAX(VENDOR_MAX_JITTER),0)),2),'999,999,990.99') ""MAX JITTER"" " & _ 
",to_char(round(nvl(AVG(1-(1-CUSTOMER_AVG_PACKET_LOSS)*(1-VENDOR_AVG_PACKET_LOSS)),0),2)*100,'990.99')  || '%' ""AVG PACKET LOSS"" " & _
",to_char(round(nvl(MIN(1-(1-CUSTOMER_MIN_PACKET_LOSS)*(1-VENDOR_MIN_PACKET_LOSS)),0),2)*100,'990.99')  || '%' ""MIN PACKET LOSS"" " & _
",to_char(round(nvl(MAX(1-(1-CUSTOMER_MAX_PACKET_LOSS)*(1-VENDOR_MAX_PACKET_LOSS)),0),2)*100,'990.99') || '%' ""MAX PACKET LOSS"" " & _
"from xtract.BRIX_KPI_VW_IPX_DATA brix " & _
"join billing.KPI_TG_PREFROUTE_MAP kpi on KPI.TRUNK_GROUP_NUMBER = BRIX.VENDOR_TRUNKGROUP_NUMBER " & _
"join xtract.MIS_PREFFERED_ROUTE mis on MIS.PREFFERED_ROUTE_ID = KPI.PREFFERED_ROUTE_ID " & _
"join XTRACT.MIS_SITE site on BRIX.CUSTOMER_PING_FROM_SITE_NAME = SITE.SITE_ABBREV " & _
"where 1 = 1 " & _
"and CUSTOMER_TRUNKGROUP_NUMBER in ( " & _
"select XTRACT.MIS_ORIG_TRUNK_GROUP.TRUNK_GROUP_NUMBER from XTRACT.MIS_ORIG_TRUNK_GROUP, XTRACT.MIS_CUSTOMER, XTRACT.MIS_BILLING_TREE " & _
"where XTRACT.MIS_ORIG_TRUNK_GROUP.CUSTOMER_ID = XTRACT.MIS_CUSTOMER.CUSTOMER_ID " & _
"and XTRACT.MIS_CUSTOMER.BILLING_TREE_ID = XTRACT.MIS_BILLING_TREE.BILLING_TREE_ID " & _
"and XTRACT.MIS_BILLING_TREE.PLATINUM_ID = :cust_id) " & _
"--and brix.CUSTOMER_IP like '%' || :IP || '%'  -- Replace by customer_ip. E.g. 10.45.16.193 " & _
"--and SITE.SITE_NAME like '%' || :sites || '%'  -- Replace by site name " & _
"--and mis.COUNTRY_ID like '%' || (select COUNTRY_ID from MIS_COUNTRY where upper(name) like upper(:country)) || '%'--Replace by country " & _
"--and mis.PL_ROUTE_DESC like  :destination --Replace by destination " & _
"and RECORDED_AT between to_date(:from_date, 'mm/dd/yy hh:mi am') " & _
"and to_date(:to_date, 'mm/dd/yy hh:mi am') --Replace by from/end dates ad formats " & _
"group by SITE.SITE_NAME, mis.PL_ROUTE_DESC"

'################
QueriesDictionary("Source/Destination_query")' = "" & _
'Add another table and change the name 

'################
QueriesDictionary("ServiceAvailability_query")' = "" & _


'################
'nedd netteza
QueriesDictionary("Sent/ReceivedTransactions_query") = "" & _
"SELECT TO_CHAR(Begin_Date_Time.time_date,'MM/DD/YY') AS PERIOD " & _
",TO_CHAR(SUM(edw_fact_lsx_traffic_summary.downlink_total_tdrs + edw_fact_lsx_traffic_summary.Uplink_total_tdrs),'999,999,999') AS ""TOTAL TRANSACTIONS"" " & _
",TO_CHAR(SUM(edw_fact_lsx_traffic_summary.Uplink_total_tdrs),'999,999,999') AS ""SENT"" " & _
",TO_CHAR(ROUND(DECODE (SUM( edw_fact_lsx_traffic_summary.Uplink_total_tdrs),0,0, " & _
"(SUM(DECODE(NVL(edw_fact_lsx_traffic_summary.RESULT_CODE, 0),CODE_DEF_RSLT_CODE.DESCRIPTION, " & _
"DECODE(TRIM(CODE_DEF_RSLT_CODE.DESCRIPTION_3),'Success', edw_fact_lsx_traffic_summary.uplink_total_tdrs, 0),0)) " & _
"/SUM(edw_fact_lsx_traffic_summary.Uplink_total_tdrs) )* 100 )),'990.99') AS ""SENT SUCCESS %"" " & _
",TO_CHAR(SUM(edw_fact_lsx_traffic_summary.downlink_total_tdrs),'999,999,999') AS ""RECEIVED"" " & _
",TO_CHAR(ROUND(DECODE (SUM(edw_fact_lsx_traffic_summary.downlink_total_tdrs ),0,0, " & _
"(SUM(DECODE(NVL(edw_fact_lsx_traffic_summary.RESULT_CODE, 0),CODE_DEF_RSLT_CODE.DESCRIPTION, " & _
"DECODE(TRIM(CODE_DEF_RSLT_CODE.DESCRIPTION_3),'Success', edw_fact_lsx_traffic_summary.downlink_total_tdrs, 0),0)) " & _
"/SUM(edw_fact_lsx_traffic_summary.downlink_total_tdrs )) * 100 )),'990.99') AS ""RECEIVE SUCCESS %"" " & _
",TO_CHAR(DECODE ( COUNT( DISTINCT edw_fact_lsx_traffic_summary.imsi),0,0, " & _
"ROUND(SUM(edw_fact_lsx_traffic_summary.downlink_total_tdrs + edw_fact_lsx_traffic_summary.Uplink_total_tdrs) " & _
"/COUNT( DISTINCT edw_fact_lsx_traffic_summary.imsi))),'999,999,999') AS ""TRANSACTIONS/ROAMER"" " & _
"FROM " & _
"(SELECT * FROM EDW_DIM_CODE_DEF WHERE CODE_TYPE = 'RSLT_COD') " & _
"CODE_DEF_RSLT_CODE " & _
"RIGHT OUTER JOIN " & _
"edw_fact_lsx_traffic_summary ON (cASt(nvl(edw_fact_lsx_traffic_summary.result_code,'0') AS VARCHAR(100))=CODE_DEF_RSLT_CODE.description) " & _
"INNER JOIN (SELECT * FROM EDW_DIM_CODE_DEF WHERE CODE_TYPE = 'COMD_COD') " & _
"CODE_DEF_COMMAND_CODE ON (edw_fact_lsx_traffic_summary.command_code=CODE_DEF_COMMAND_CODE.code) -- Notice the Join to Command Codes " & _
"INNER JOIN ADMIN.edw_dim_time  Begin_Date_Time ON (Begin_Date_Time.time_id=edw_fact_lsx_traffic_summary.Begin_time_id) " & _
"INNER JOIN ADMIN.edw_dim_customer ON (edw_fact_lsx_traffic_summary.customer_gk=ADMIN.edw_dim_customer.customer_gk) " & _
"INNER JOIN ADMIN.edw_dim_billing_tree ON (ADMIN.edw_dim_billing_tree.billing_tree_gk=ADMIN.edw_dim_customer.billing_tree_gk) " & _
"WHERE " & _
"((( Begin_Date_Time.time_date ) >= '05/05/2015 12:00:00.0' and ( Begin_Date_Time.time_date ) <= '05/12/2015 05:00:00.0') " & _
"AND ADMIN.edw_dim_billing_tree.finance_id = '101215' " & _
"--AND CODE_DEF_COMMAND_CODE.description in ('ULR/ULA')  -- REPLACE IN LIST WITH CHOSEN COMMAND CODES OR OMIT FILTER FOR ALL COMMAND CODES " & _
"--AND CODE_DEF_RSLT_CODE.description_2  IN ('Diameter success') -- REPLACE IN LIST WITH CHOSEN RESULT CODES OR OMIT FILTER FOR ALL RESULT CODES) " & _
"GROUP BY " & _
"Begin_Date_Time. time_date  -- REPLACE THIS based on the GROUP BY PERIOD " & _
"ORDER BY period DESC"

'################
'Need netteza
QueriesDictionary("OutboundTransactions_query") = "" & _
"SELECT TO_CHAR(Begin_Date_Time.time_date,'MM/DD/YY') AS PERIOD " & _
",TO_CHAR(SUM(edw_fact_lsx_traffic_summary.downlink_total_tdrs + edw_fact_lsx_traffic_summary.Uplink_total_tdrs),'999,999,999') AS ""TOTAL TRANSACTION"" " & _
",TO_CHAR(round(decode(SUM(edw_fact_lsx_traffic_summary.downlink_total_tdrs + edw_fact_lsx_traffic_summary.Uplink_total_tdrs),0,0, " & _
"((SUM(DECODE(NVL(edw_fact_lsx_traffic_summary.RESULT_CODE, 0),CODE_DEF_RSLT_CODE.DESCRIPTION, " & _
"DECODE(TRIM(CODE_DEF_RSLT_CODE.DESCRIPTION_3),'Success', edw_fact_lsx_traffic_summary.uplink_total_tdrs, 0),0)) " & _
"+ SUM(DECODE(NVL(edw_fact_lsx_traffic_summary.RESULT_CODE, 0),CODE_DEF_RSLT_CODE.DESCRIPTION, " & _
"DECODE(TRIM(CODE_DEF_RSLT_CODE.DESCRIPTION_3),'Success', edw_fact_lsx_traffic_summary.downlink_total_tdrs, 0),0))) " & _
"/SUM(edw_fact_lsx_traffic_summary.downlink_total_tdrs + edw_fact_lsx_traffic_summary.Uplink_total_tdrs)) * 100 )),'990.99') AS ""SUCCESS RATIO %"" " & _
",TO_CHAR(SUM(edw_fact_lsx_traffic_summary.Uplink_total_tdrs),'999,999,999') AS ""SENT"" " & _
",TO_CHAR(ROUND(DECODE(SUM( edw_fact_lsx_traffic_summary.Uplink_total_tdrs),0,0, " & _
"(SUM(DECODE(NVL(edw_fact_lsx_traffic_summary.RESULT_CODE, 0),CODE_DEF_RSLT_CODE.DESCRIPTION, " & _
"DECODE(TRIM(CODE_DEF_RSLT_CODE.DESCRIPTION_3),'Success', edw_fact_lsx_traffic_summary.uplink_total_tdrs, 0),0)) " & _
"/SUM(edw_fact_lsx_traffic_summary.Uplink_total_tdrs) )* 100 )),'990.99') AS ""SENT SUCCESS %"" " & _
",TO_CHAR(SUM(edw_fact_lsx_traffic_summary.downlink_total_tdrs),'999,999,999') AS ""RECEIVED"" " & _
",TO_CHAR(ROUND(DECODE(SUM(edw_fact_lsx_traffic_summary.downlink_total_tdrs ),0,0, " & _
"(SUM(DECODE(NVL(edw_fact_lsx_traffic_summary.RESULT_CODE, 0),CODE_DEF_RSLT_CODE.DESCRIPTION, " & _
"DECODE(TRIM(CODE_DEF_RSLT_CODE.DESCRIPTION_3),'Success', edw_fact_lsx_traffic_summary.downlink_total_tdrs, 0),0)) " & _
"/SUM(edw_fact_lsx_traffic_summary.downlink_total_tdrs )) * 100 )),'990.99') AS ""RECEIVE SUCCESS %"" " & _
",TO_CHAR(COUNT(distinct edw_fact_lsx_traffic_summary.imsi),'999,999,999') AS ""ROAMERS"" " & _
",TO_CHAR(DECODE(COUNT(DISTINCT edw_fact_lsx_traffic_summary.imsi),0,0, " & _
"ROUND(SUM(edw_fact_lsx_traffic_summary.downlink_total_tdrs + edw_fact_lsx_traffic_summary.Uplink_total_tdrs)/ " & _
"COUNT(DISTINCT edw_fact_lsx_traffic_summary.imsi))),'999,999,999') AS ""TRANSACTIONS/ROAMER"" " & _
"FROM (SELECT * FROM EDW_DIM_CODE_DEF WHERE CODE_TYPE = 'RSLT_COD') " & _
"CODE_DEF_RSLT_CODE RIGHT OUTER JOIN edw_fact_lsx_traffic_summary ON (cast(nvl(edw_fact_lsx_traffic_summary.result_code,'0') as varchar(100))=CODE_DEF_RSLT_CODE.description) " & _
"INNER JOIN ( " & _
"SELECT * FROM EDW_DIM_CODE_DEF WHERE CODE_TYPE = 'COMD_COD') " & _
"CODE_DEF_COMMAND_CODE ON (edw_fact_lsx_traffic_summary.command_code=CODE_DEF_COMMAND_CODE.code) -- Notice the Join to Command Codes " & _
"INNER JOIN ADMIN.edw_dim_time  Begin_Date_Time ON (Begin_Date_Time.time_id=edw_fact_lsx_traffic_summary.Begin_time_id)"
'INNER JOIN ADMIN.edw_dim_customer ON (edw_fact_lsx_traffic_summary.customer_gk=ADMIN.edw_dim_customer.customer_gk)
'INNER JOIN ADMIN.edw_dim_billing_tree ON (ADMIN.edw_dim_billing_tree.billing_tree_gk=ADMIN.edw_dim_customer.billing_tree_gk)
'WHERE
'(
'( ( Begin_Date_Time.time_date ) >= '05/05/2015 12:00:00.0' and ( Begin_Date_Time.time_date ) <= '05/12/2015 06:00:00.0'   )
'AND
'ADMIN.edw_dim_billing_tree.finance_id  =  '101215'
')
'AND edw_fact_lsx_traffic_summary.roaming_direction = 'OUTBOUND'
'--AND CODE_DEF_COMMAND_CODE.description in ('ULR/ULA')  -- REPLACE IN LIST WITH CHOSEN COMMAND CODES OR OMIT FILTER FOR ALL COMMAND CODES
'--AND CODE_DEF_RSLT_CODE.description_2  IN ('Diameter success') -- REPLACE IN LIST WITH CHOSEN RESULT CODES OR OMIT FILTER FOR ALL RESULT CODES 
'GROUP BY
'--DATE:
'Begin_Date_Time.time_date  -- REPLACE THIS based on the GROUP BY PERIOD
'--WEEK:
'--TO_CHAR(Begin_Date_Time.time_date - TO_CHAR(Begin_Date_Time.time_date- 1, 'D')::int + 1, 'MM/DD/YY') || ' - ' || TO_CHAR(Begin_Date_Time.time_date - TO_CHAR(Begin_Date_Time.time_date - 1, 'D')::int + 7, 'MM/DD/YY')
'--MONTH:
'--TO_CHAR(TO_DATE(TRIM(TO_CHAR(Begin_Date_Time.time_month_id,'09')) || '/01/'|| TRIM(TO_CHAR(Begin_Date_Time.time_year,'9999')),'MM/DD/YYYY'),'MM/DD/YY')
'--QUARTER:
'--TO_CHAR(Begin_Date_Time.TIME_DATE,'YYYY') || '-Q' || TO_CHAR(Begin_Date_Time.TIME_DATE,'Q')
'ORDER BY period DESC
'
''################
'QueriesDictionary("InboundTransactions_query") = "" & _
'
'
''################
'QueriesDictionary("OutboundRoaming_query") = "" & _
'
'
''################
'QueriesDictionary("InboundRoaming_query") = "" & _
'
'
''################
'QueriesDictionary("CountryAnalysis_query") = "" & _
'
'
''################
'QueriesDictionary("MNOAnalysis_query") = "" & _
'
'
''################
'QueriesDictionary("ErrorAnalysis_query") = "" & _
'
'
''################
'QueriesDictionary("Users_query") = "" & _
