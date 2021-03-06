'Yael Comment
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
' Parameters: sQueryName - 	Name on QueriesDictionary, [optional]arrParamValue - array of parameters values. 
'							(If there are no query parameters, send an empty string - ""
' Return value: Success - SQL query
' Example: Call fGetQuery("Get_cust_rate_mod_temporary_sheet",Array("parma1","param2"))
'----------------------------------------------------------------
	
	Dim sSQL

	sSQL = QueriesDictionary(sQueryName)
	If arrParamValue(0) <> "" Then
		For i = 1 to uBound(arrParamValue)+1
			If instr (1,sSQL, "<<parameter" & i & ">>") > 0 Then
				sSQL = Replace(sSQL,  "<<parameter" & i & ">>",arrParamValue(i-1))
			End If
		Next
	End If

	fGetQuery = sSQL
	
End Function

Public Function fGetQuery2Parameters (ByVal sQueryName, ByVal sParamValue1, ByVal sParamValue2)

'----------------------------------------------------------------
' Function name: fGetQuery2Parameters
' Description: The function reutrns sql query by query name. And replace parameter in query [optional]
' Parameters: sQueryName - Name on QueriesDictionary, [optional]sParamValue - parameter value 
' Return value: Success - True, Failure - False
'----------------------------------------------------------------

	sSQL = QueriesDictionary(sQueryName)
	If instr (1,sSQL, "<<parameter1>>") > 0 Then
        sSQL = Replace(sSQL, "<<parameter1>>",sParamValue1)
	End If

	If instr (1,sSQL, "<<parameter2>>") > 0 Then
        sSQL = Replace(sSQL, "<<parameter2>>",sParamValue2)
	End If

	fGetQuery2Parameters = sSQL
End Function

Public Function fGetQuery3Parameters (ByVal sQueryName, ByVal sParamValue1, ByVal sParamValue2, ByVal sParamValue3)

'----------------------------------------------------------------
' Function name: fGetQuery3Parameters
' Description: The function reutrns sql query by query name. And replace parameters in query [optional]
' Parameters: sQueryName - Name on QueriesDictionary, [optional]sParamValue - parameter value 
' Return value: Success - True, Failure - False
'----------------------------------------------------------------

	Dim sSQL

	sSQL = fGetQuery2Parameters(sQueryName,sParamValue1, sParamValue2)

	'sSQL = QueriesDictionary(sQueryName)
	If instr (1,sSQL, "<<parameter3>>") > 0 Then
        sSQL = Replace(sSQL, "<<parameter3>>",sParamValue3)
	End If

	fGetQuery3Parameters = sSQL
End Function

Public Function fReplaceParamInQuery (ByVal sQuery, ByVal arrParamValue)
	
'----------------------------------------------------------------
' Function name: fReplaceParamInQuery
' Description: The function replace all parameters in query
' Parameters: 
' Return value: Success - SQL query after replacing parameters
' Example: 
'----------------------------------------------------------------
	
	sSQL = sQuery
	If arrParamValue(0) <> "" Then
		For i = 1 to uBound(arrParamValue)+1
			If instr (1,sSQL, "<<parameter" & i & ">>") > 0 Then
				sSQL = Replace(sSQL,  "<<parameter" & i & ">>",arrParamValue(i-1))
			End If
		Next
	End If

	fReplaceParamInQuery = sSQL
	
End Function


'----------------------------------------------------------------
'---------------------  Queries dictionary  ---------------------
'----------------------------------------------------------------
'NOTE! Parameters format is <<parameter1>>, <<parameter2>>, etc...
'----------------------------------------------------------------
Dim QueriesDictionary
Set QueriesDictionary = CreateObject("Scripting.Dictionary")

QueriesDictionary("Get_new_created_BC") = "" & _
"SELECT Max(ID) FROM business_case BC WHERE BC.Description like '<<parameter1>>'"
'Replace with BC description

QueriesDictionary("Get_Customer_Currency") = "" & _ 
"select distinct * from(select CU.ISO_CURRENCY_CODE as currency from " & _
"(select P.PRODUCT_DESC, c.customer_name as RMS_customer, nvl(cv.COLO_CODES, c.colo_code) as colo, c.customer_id as RMS_Id " & _
"from customer c join customer_combined_map ccm on c.customer_id = CCM.source_customer_id " & _ 
"join customer_combined cc on CCM.customer_COMBINE_ID = cc.customer_COMBINE_ID join product p on P.PRODUCT_ID = C.PRODUCT_ID " & _
"left join vw_customer_colos_sms cv on CV.CUSTOMER_ID = C.CUSTOMER_ID " & _
"where customer_combine_name in ('<<parameter1>>') " & _
"and p.product_id in(select product_id from BC_VALID_PRODUCT) and nvl(c.delete_flag, 'N') = 'N')RMS_Details " & _
"join customer c on RMS_Details.RMS_ID = C.customer_ID join billing_tree bt on c.BILLING_TREE_ID = BT.BILLING_TREE_ID " & _ 
"join currency cu on BT.CURRENCY_ID = CU.CURRENCY_ID order by product_desc,CU.CURRENCY_ID, RMS_customer)"
'Replace by customer name

QueriesDictionary("Get_Vendor_Currency") = "" & _ 
"select Distinct(BILLING_TREE.ISO_CURRENCY_CODE) Currency from vendor " & _ 
"join vendor_combined_map on VENDOR.VENDOR_ID= vendor_combined_map.source_vendor_id " & _
"join VENDOR_COMBINED on VENDOR_COMBINED.VENDOR_COMBINE_ID = vendor_combined_map.vendor_combine_id " & _
"join billing_tree on billing_tree.billing_tree_ID = vendor.billing_tree_id " & _
"where VENDOR_COMBINED.VENDOR_COMBINE_name = '<<parameter1>>' and VENDOR.DELETE_FLAG is null"
'Replace by vendor name

QueriesDictionary("Get_Route_ID") = "" & _ 
"SELECT PR.PREFFERED_ROUTE_ID FROM MIS.PREFFERED_ROUTE pr WHERE PR.PL_ROUTE_DESC = '<<parameter1>>'"
'Replace by: for origination - preferred route description, for termination - iBasis route description 

QueriesDictionary("Get_Customer_RMS_IDs") = "" & _ 
"select distinct * from (select RMS_Details.* from (select c.customer_id as RMS_Id " & _
"from customer c join customer_combined_map ccm on c.customer_id = CCM.source_customer_id " & _ 
"join customer_combined cc on CCM.customer_COMBINE_ID = cc.customer_COMBINE_ID " & _ 
"join product p on P.PRODUCT_ID = C.PRODUCT_ID left join vw_customer_colos_sms cv on CV.CUSTOMER_ID = C.CUSTOMER_ID " & _
"where customer_combine_name in ('<<parameter1>>') " & _
"and p.product_id in(select product_id from BC_VALID_PRODUCT) and nvl(c.delete_flag, 'N') = 'N') RMS_Details " & _
"join customer c on RMS_Details.RMS_ID = C.customer_ID join billing_tree bt on c.BILLING_TREE_ID = BT.BILLING_TREE_ID " & _
"join currency cu on BT.CURRENCY_ID = CU.CURRENCY_ID order by CU.CURRENCY_ID)"
'Replace by customer name

QueriesDictionary("Get_Vendor_RMS_IDs") = "" & _
"SELECT VENDOR.VENDOR_ID RMS_ID FROM vendor " & _ 
"JOIN vendor_combined_map ON VENDOR.VENDOR_ID= vendor_combined_map.source_vendor_id " & _
"JOIN VENDOR_COMBINED ON VENDOR_COMBINED.VENDOR_COMBINE_ID = vendor_combined_map.vendor_combine_id " & _
"JOIN billing_tree ON billing_tree.billing_tree_ID = vendor.billing_tree_id " & _
"WHERE VENDOR_COMBINED.VENDOR_COMBINE_name = '<<parameter1>>' AND VENDOR.DELETE_FLAG IS NULL order by VENDOR.VENDOR_NAME"
'Reolace by vendor name

QueriesDictionary("Get_Exchange_Rate") = "" & _
"select round(EX.EXCHANGE_RATE,3) from MIS.CURRENCY_EXCHANGE_RATE ex " & _
"join MIS.CURRENCY c on EX.CURRENCY_ID = C.CURRENCY_ID " & _ 
"where C.ISO_CURRENCY_CODE in 'EUR' " & _
"and end_date is null "
