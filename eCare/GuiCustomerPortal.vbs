Public Const SCHEMA = "BILLING."
Public Const PORTAL = "PORTAL."
Public iImagesCounter, sTest

iImagesCounter = 1

'###########################################################
' Function name: fGuiLogIn
' Description:   Logs into Customer Portal
' Parameters:
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiLogIn()

	Dim sUserName, sPassword
	
	'Get the expected login details (from the Environment excel or from the parameres excel)
	If GlobalDictionary("USER_NAME") <> "" Then 'Use the parameters excel login details
		UserName = GlobalDictionary("USER_NAME")
		sPassword = GlobalDictionary("PASSWORD")
	Else 'Use the Environment excel login details
		sUserName = Environment("USER")
		sPassword = Environment("PASSWORD")
	End If
	
	'Check if application is allready open
	If Browser("iBasis Customer Portal").Exist(0) = "True" Then
		' Check if we are allready in home page
		If Browser("iBasis Customer Portal").Page("Home").Exist(0) = "True" Then
			fGuiLogIn = "Success_and_do_not_Report"
					
		' Check if we are allready in login page
		ElseIf Browser("iBasis Customer Portal").Page("Login").Exist(0) = "True" Then
			Browser("iBasis Customer Portal").Page("Login").WebEdit("username").Set sUserName
	        Browser("iBasis Customer Portal").Page("Login").WebEdit("password").Set  sPassword
			Browser("iBasis Customer Portal").Page("Login").Image("signInButton").Click
			fGuiLogIn = "Success_and_Report"
		
        Else ' In any other page - go to home page
			Browser("iBasis Customer Portal").Page("All Pages").Link("Home").Click
			fGuiLogIn = "Success_and_do_not_Report"
			If Browser("iBasis Customer Portal").Page("Home").Exist(30) = "False" Then
				Reporter.ReportEvent micFail, "fGuiLogIn", "Failed to navigate to 'Welcome' page"
				Call fWriteHtmlReportRow("fGuiLogIn", "Navigate to 'Welcome' page", "FAIL", "Failed to navigate to 'Welcome' page")
				fGuiLogIn = False
				ExitRun
			End If
		End If
	Else	'Lunch the browser and login
		'SystemUtil.Run "C:\Program Files\Mozilla Firefox\firefox.exe", Environment("URL") '--- FF - Use for XP
		SystemUtil.Run "C:\Program Files\Internet Explorer\iexplore.exe", Environment("URL") '-- IE - Use for windows 7
		'SystemUtil.Run "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", Environment("URL") '-- Chrome - Use for windows 7
		Call fBrowserMaximize()
		If Browser("iBasis Customer Portal").Page("Certificate Error").Exist(3) = "True" Then
			 Browser("iBasis Customer Portal").Page("Certificate Error").Link("Continue link").Click
		End If
		If Browser("iBasis Customer Portal").Page("Login").Exist(30) = "False" Then
			Reporter.ReportEvent micFail, "fGuiLogIn", "'Login' page didn't open for: " & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword
			Call fWriteHtmlReportRow("fGuiLogIn", "Login to application", "FAIL", "'Login' page didn't open for: " & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword)
			fGuiLogIn = False
			ExitRun
		End If

		Browser("iBasis Customer Portal").Page("Login").WebEdit("username").Set sUserName
        Browser("iBasis Customer Portal").Page("Login").WebEdit("password").Set  sPassword
		Browser("iBasis Customer Portal").Page("Login").Image("signInButton").Click
		fGuiLogIn = "Success_and_Report"
	End If
	
	If Browser("iBasis Customer Portal").Page("Home").Exist(30) = "False" Then
		Reporter.ReportEvent micFail, "fGuiLogIn", "'Welcome' page didn't open for: " & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword
		Call fWriteHtmlReportRow("fGuiLogIn", "Login to application", "FAIL", "'Login' page didn't open for: " & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword)
		fGuiLogIn = False
		ExitRun
	End If
	
	If fGuiLogIn = "Success_and_Report" Then
		Reporter.ReportEvent micPass, "fGuiLogIn", "Login succeeded." & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword
		Call fWriteHtmlReportRow("fGuiLogIn", "Login to application", "PASS", "Login succeeded." & vbNewLine & "URL: " & Environment("URL") & vbNewLine & "User: " & sUserName & vbNewLine & "Password: " & sPassword)
    End If
	
End Function
'###########################################################

'###########################################################
' Function name: fBrowserMaximize
' Description: The function maximize the browser if it's minimize
' Parameters:	
' Return value: 
' Example:
'###########################################################
Public Function fBrowserMaximize() 
	
	Dim hwnd, isMaximized, isMaximizable
 
	'Find the handle for the Browser window
	hwnd = Browser("CreationTime:=1").Object.HWND
	 
	'Check if the Browser is already maximized or not
	If Window("hwnd:=" & hwnd).GetROProperty("maximized") = True Then
	  isMaximized = True
	Else
	  isMaximized = False
	End If
	 
	'Check if the Browser is maximizable or not
	If Window("hwnd:=" & hwnd).GetROProperty("maximizable") = True Then
	  isMaximizable = True
	Else
	  isMaximizable = False
	End If
	 
	'Maximize the browser window if it is not already maximized and is maximizable
	If isMaximized = False and isMaximizable = True Then
	  Window("hwnd:=" & hwnd).Maximize
	End If
	
End Function
'###########################################################

'###########################################################
' Function name: fGetCustomerIdByName
' Description:   Get customer id by name using DB query
' Parameters:	cutomer name
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGetCustomerIdByName()
'TODO:
End Function
'###########################################################

'###########################################################
' Function name: fSelectCustomer
' Description:   Select customer using advanced search
' Parameters:	cutomer id
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fSelectCustomer()

	'Get the customer id to be selected (from the excel paramenters)
	Call fGetReferenceVerificationData("CUST_ID", sCustomerID)
	
	'Check if customer is already selected
	sCustomerName = Browser("iBasis Customer Portal").Page("All Pages").WebElement("Customer Filter").WebEdit("Customer Filter Field").GetROProperty("value")
	If inStr(1,sCustomerName, sCustomerID) > 0 Then
		Exit Function
	End If
	
	'Open the advanced search window
	Browser("iBasis Customer Portal").Page("All Pages").WebElement("Advanced Search").Click
	If Browser("iBasis Customer Portal").Page("All Pages").WebElement("Advanced Search window").Exist(30) = "False" Then
		Reporter.ReportEvent micFail, "fSelectCustomer", "The advanced Search window was not opened" 
		Call fWriteHtmlReportRow("fSelectCustomer", "Open the advanced Search window", "FAIL", "The advanced Search window was not opened")
		fSelectCustomer = False
		ExitRun
	End If
	
	'Search the customer on the advance search by customer id
	Browser("iBasis Customer Portal").Page("All Pages").WebEdit("Cust ID Filter").Set sCustomerID
	Browser("iBasis Customer Portal").Page("All Pages").WebElement("Apply").Click
	
	'SyncByImage - for refresh data
	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fSelectCustomer", "Failed to select customer name" 
		Call fWriteHtmlReportRow("fSelectCustomer", "sync for refresh data", "FAIL", "Failed to select customer name")
		fSelectCustomer = False
		ExitRun 
	End If
	
	If Browser("iBasis Customer Portal").Page("All Pages").WebTable("Filter results table").RowCount <> 1 Then
		Reporter.ReportEvent micFail, "fSelectCustomer", "Filter by customer id failed - there is more than one record in the results" 
		Call fWriteHtmlReportRow("fSelectCustomer", "Filter customers table on advanced search by customer id", "FAIL", "Filter by customer id failed - there is more than one record in the results")
		fSelectCustomer = False
		ExitRun
	End If
	
	'Select the customer
	Browser("iBasis Customer Portal").Page("All Pages").WebTable("Filter results table").ChildItem(1,1,"WebElement",0).Click
	wait(1)
	Browser("iBasis Customer Portal").Page("All Pages").WebElement("Select").Click
	
	'Sync untill system is refreshed with the selected customer's details
	Dim iCounter, sCustomerName, iTime
	iCounter = 1
	iTime = 30
	wait 1
	sCustomerName = Browser("iBasis Customer Portal").Page("All Pages").WebElement("Customer Filter").WebEdit("Customer Filter Field").GetROProperty("value")
	
	While inStr(1,sCustomerName,sCustomerID) = 0  And iCounter <= iTime
		iCounter = iCounter + 1
		Wait 1
		sCustomerName = Browser("iBasis Customer Portal").Page("All Pages").WebElement("Customer Filter").WebEdit("Customer Filter Field").GetROProperty("value")
	Wend
	
	If iCounter > iTime Then
		Reporter.ReportEvent micFail, "fSelectCustomer", "The application was not refreshed with the selected customer's details" 
		Call fWriteHtmlReportRow("fSelectCustomer", "Sync untill system is refreshed with the selected customer's details", "FAIL", "The application was not refreshed with the selected customer's details")
		fSelectCustomer = False
		ExitRun
	Else
		Reporter.ReportEvent micPass, "fSelectCustomer", "Customer: '" & sCustomerName & "' is selected"
		Call fWriteHtmlReportRow("fSelectCustomer", "Select customer", "PASS", "Customer: '" & sCustomerName & "' is selected")
		fSelectCustomer = True
	End If
End Function

'###########################################################
' Function name: fSelectCustomer_OLD --- NOT IN USE
' Description:   Select customer using customer search
' Parameters:	cutomer name
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fSelectCustomer_OLD()
'    Dim sCustomerName, bFlag
'	bFlag = False
'
'	Browser("iBasis Customer Portal").Page("Home").Link("Finance").Click
'	'Sync 
'	If Browser("iBasis Customer Portal").Page("Finance").WebElement("Credit Limit").Exist(30) = "False" Then
'		Reporter.ReportEvent micFail, "fSelectCustomer", "Failed to Navigate the protlet: 'Finance'" 
'		Call fWriteHtmlReportRow("fSelectCustomer" , "Navigate to the protlet", "FAIL", "Failed to Navigate the protlet: 'Finance'")
'		fSelectCustomer = False
'		Exit Function
'	End If
'
'	'Select a customer using customer search
'	Call fGetReferenceVerificationData("CUST_NAME", sCustomerName)
'	Call fGetReferenceVerificationData("CUST_ID", sCustomerID)
'
'	'Set customer name
'	Browser("iBasis Customer Portal").Page("Finance").WebElement("Customer Filter").WebEdit("Customer Filter Field").Click
'	Browser("iBasis Customer Portal").Page("Finance").WebElement("Customer Filter").WebEdit("Customer Filter Field").Set sCustomerName & "--" & sCustomerID
'
'	'SyncByImage - for refresh data
'	If fSyncByImage(60) = False Then
'		Reporter.ReportEvent micFail, "fSelectCustomer", "Failed to select customer name" 
'		Call fWriteHtmlReportRow("fSelectCustomer", "sync for refresh data", "FAIL", "Failed to select customer name")
'		fSelectCustomer = False
'		Exit Function
'	End If
'
'	'Sync for popup list to be open
'    Browser("iBasis Customer Portal").Page("Finance").WebElement("List Open").SetTOProperty "innertext", sCustomerName & ":" & sCustomerID
'	If Browser("iBasis Customer Portal").Page("Finance").WebElement("List Open").Exist(10) = "True" Then				
'		Browser("iBasis Customer Portal").Page("Finance").WebElement("List Open").FireEvent "OnMouseOver"
'		Browser("iBasis Customer Portal").Page("Finance").WebElement("List Open").Click
'	End If
'
'	'Sync for all data on home page will refresh according to the selected customer 
'	Dim iCounter
'	iCounter = 0	
'	While (instr(1,Browser("iBasis Customer Portal").Page("Finance").WebElement("Name").GetROProperty("outertext"),sCustomerName) = 0 and iCounter < 60) 
'		iCounter = iCounter + 1
'		wait 1
'	Wend
'
'	'Sync
'	If iCounter >= 60 Then
'		Reporter.ReportEvent micFail, "fSelectCustomer", "Failed to select customer name" 
'		Call fWriteHtmlReportRow("fSelectCustomer", "sync for refresh data", "FAIL", "Failed to select customer name")
'		fSelectCustomer = False
'		Exit Function
'	End If
'
'	'Sync succeeded
'    Reporter.ReportEvent micPass, "fSelectCustomer", "Select customer name PASSED" 
'	Call fWriteHtmlReportRow("fSelectCustomer", "sync for select customer", "PASS", "Select customer name PASSED")
'	fSelectCustomer = True
'
'	Browser("iBasis Customer Portal").Page("Finance").Link("Welcome").Click
'	'Sync 
'	If Browser("iBasis Customer Portal").Page("Home").Exist(30) = "False" Then
'		Reporter.ReportEvent micFail, "fSelectCustomer", "Nevigation to Welcome page failed" 
'		Call fWriteHtmlReportRow("fSelectCustomer" , "Navigate to the Welcome", "FAIL", "Nevigation to Welcome page failed")
'		fSelectCustomer = False
'		Exit Function
'	End If
End Function


'###########################################################
   
'###########################################################
' Function name: fVerifyFilter
' Description:   The function checks a specific filter validation
' Parameters:	Protlet Name, Filter Name, Filter's Values
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fVerifyFilter(ByVal sProtletName, ByVal sFilterBy, ByVal sValue1, ByVal sValue2, ByVal iColumn)

	Dim iRowCount, i, sCellData, bFound

	bFound = True
	iRowCount = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").RowCount
	If iRowCount > 0 Then

		'Find type of filter
		Select Case sFilterBy
	
			'"Contains" filters  
			Case "Reference", "Invoice ID"
	
				For i = 1 To iRowCount
					
					sCellData = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").GetCellData(i, iColumn)
					If instr(1,UCase(sCellData),UCase(sValue1)) = 0 Then
						bFound = False
						Reporter.ReportEvent micFail, "Verify filter",  "Protlet Name: " & sProtletName & ", Column: " & sFilterBy & ", Row: " & i & ", CellData:" & sCellData & " - does not Contains " & sValue1 
						Call fWriteHtmlReportRow("Verify filter", "Protlet Name: " & sProtletName & ", Column: " & sFilterBy, "FAIL", "Row: " & i & ", CellData:" & sCellData & " - does not Contains " & sValue1)
					End If
	
				Next
				
	
			'"Select & Field" filters 
			Case "Minutes/Message", "Total Charges", "Open Amount", "Total Amount", "Invoice Amount", "Paid Amount", "Other Cleared Amount", "Amount", "Dispute Amount"
	
				For i = 1 To iRowCount
	
					sCellData = fConvertFormat(Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").GetCellData(i, iColumn))
	
					Select Case sValue1
						Case ">="
							If cdbl(sCellData) < cdbl(sValue2) Then
								bFound = False
								Reporter.ReportEvent micFail, "Verify filter",  "Protlet Name: " & sProtletName & ", Column: " & sFilterBy & ", Row: " & i & ", CellData:" & sCellData & " - does not more than " & sValue2 
								Call fWriteHtmlReportRow("Verify filter", "Protlet Name: " & sProtletName & ", Column: " & sFilterBy, "FAIL", "Row: " & i & ", CellData: " & sCellData & " - does not more than " & sValue2)
							End If
						Case "<="
							If cdbl(sCellData) > cdbl(sValue2) Then
								bFound = False
								Reporter.ReportEvent micFail, "Verify filter",  "Protlet Name: " & sProtletName & ", Column: " & sFilterBy & ", Row: " & i & ", CellData:" & sCellData & " - does not less than " & sValue2 
								Call fWriteHtmlReportRow("Verify filter", "Protlet Name: " & sProtletName & ", Column: " & sFilterBy, "FAIL", "Row: " & i & ", CellData: " & sCellData & " - does not less than " & sValue2)
							End If
						Case "="
							If cdbl(sCellData) <> cdbl(sValue2) Then
            					bFound = False
								Reporter.ReportEvent micFail, "Verify filter",  "Protlet Name: " & sProtletName & ", Column: " & sFilterBy & ", Row: " & i & ", CellData:" & sCellData & " - does not equal to " & sValue2 
								Call fWriteHtmlReportRow("Verify filter", "Protlet Name: " & sProtletName & ", Column: " & sFilterBy, "FAIL", "Row: " & i & ", CellData: " & sCellData & " - does not Equal " & sValue2)
							End If
					End Select
	
				Next
	
			'"Field" filters
			Case "Currency", "Transaction Type", "Severity", "Destination Name", "Case Number"

				If sValue1 <> "All" Then

					For i = 1 To iRowCount
						sCellData = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").GetCellData(i, iColumn)
						If UCase(sCellData) <> UCase(sValue1) Then
							bFound = False
							Reporter.ReportEvent micFail, "Verify filter",  "Protlet Name: " & sProtletName & ", Column: " & sFilterBy & ", Row: " & i & ", CellData:" & sCellData & " - does not equal " & sValue1 
							Call fWriteHtmlReportRow("Verify filter", "Protlet Name: " & sProtletName & ", Column: " & sFilterBy, "FAIL", "Row: " & i & ", CellData: " & sCellData & " - does not Equal " & sValue1)
						End If
					Next

				End If
	
			'"Date Before/After" filters
			Case "Invoice Date", "Payment Date", "Dispute Date", "Document Date", "Due Date", "Alert Date & Time (GMT)"
	
				For i = 1 To iRowCount
					
					sCellData = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").GetCellData(i, iColumn)
					Select Case sValue1
	
						Case "<="
							If  dateDiff("d",sCellData, sValue2) < 0 Then
								bFound = False
								Reporter.ReportEvent micFail, "Verify filter",  "Protlet Name: " & sProtletName & ", Column: " & sFilterBy & ", Row: " & i & ", CellData: " & sCellData & " - does not Before " & sValue2 
								Call fWriteHtmlReportRow("Verify filter", "Protlet Name: " & sProtletName & ", Column: " & sFilterBy, "FAIL", "Row: " & i & ", CellData: " & sCellData & " - does not Before " & sValue2)
							End If

						Case "="
							If  dateDiff("d",sCellData, sValue2) <> 0 Then
								bFound = False
								Reporter.ReportEvent micFail, "Verify filter",  "Protlet Name: " & sProtletName & ", Column: " & sFilterBy & ", Row: " & i & ", CellData: " & sCellData & " - does not Equal " & sValue2 
								Call fWriteHtmlReportRow("Verify filter", "Protlet Name: " & sProtletName & ", Column: " & sFilterBy, "FAIL", "Row: " & i & ", CellData: " & sCellData & " - does not Equal " & sValue2)

							End If
	
						Case ">="
							If  dateDiff("d",sCellData, sValue2) > 0 Then
								bFound = False
								Reporter.ReportEvent micFail, "Verify filter", "Protlet Name: " & sProtletName & ", Column: " & sFilterBy & ", Row: " & i & ", CellData: " & sCellData & " - does not After " & sValue2 
								Call fWriteHtmlReportRow("Verify filter", "Protlet Name: " & sProtletName & ", Column: " & sFilterBy, "FAIL", "Row: " & i & ", CellData: " & sCellData & " - does not After " & sValue2)
							End If
					End Select
	
				Next	
	
					
		End Select
		If bFound = True Then
			Reporter.ReportEvent micPass, "Verify filter", "All rows in protlet name: " & sProtletName & ", Column: '" & sFilterBy & "' are matching to the filter value" 
			Call fWriteHtmlReportRow("Verify filter", "Check the matching of filter values" , "PASS", "All rows in protlet name: " & sProtletName & ", Column: '" & sFilterBy & "' are matching to the filter value")
		End If

	    fVerifyFilter = True

	 Else
			Reporter.ReportEvent micWarning, "Verify filter", "No Data found after filter column: "  & sFilterBy & " with value: " & sValue1 & " " & sValue2 & " in protlet name: " & sProtletName
			Call fWriteHtmlReportRow("Verify filter", "Filter Column: " & sFilterBy & " In Protlet Name: " & sProtletName, "INFO", "No Data found after filter ")
			fVerifyFilter = False
	 End If
	
End Function
'###########################################################
'###########################################################
' Function name: fFormatDate
' Description:   
' Parameters:	String date
' Return value:  Success - date formated to customer's default date format
' Example:
'###########################################################
Public Function fFormatDate(ByVal sDate)

	Dim sDateFormat
	Dim sTimeFormat, sTime, defaultTime
	defaultTime = cdate("12:00:00 AM")

	sDate = cDate(sDate)
	Call fGetReferenceVerificationData("DATE_FORMAT", sDateFormat)
	Call fGetReferenceVerificationData("TIME_FORMAT", sTimeFormat)

    Select Case lcase(sDateFormat)

		Case lcase("dd-Mon-yy")

			sMon = Left(monthname(month(sDate)), 3)
			sYear = Right(Year(sDate), 2)
			sDay = Day(sDate)
			If sDay < 10 Then
				sDay = "0"& sDay
			End If
			fFormatDate = sDay & "-"& sMon & "-" & sYear
			
		Case lcase("MM/dd/yy")

			sMon = month(sDate)
			If sMon < 10 Then
				sMon = "0"& sMon
			End If
            sDay = Day(sDate)
			If sDay < 10 Then
				sDay = "0"& sDay
			End If
			sYear = Right(Year(sDate), 2)
			fFormatDate = sMon & "/"& sDay & "/" & sYear

	End Select

	If TimeValue(sDate) <> defaultTime Then

		Select Case lcase(sTimeFormat)
			Case lcase("hh:mi")
                fFormatDate = fFormatDate & " " & hour(sDate) & ":" & minute(sDate)
			Case lcase("hh:mi am")
				If hour(sDate) < 12 Then
					fFormatDate = fFormatDate & " " & hour(sDate) & ":" & minute(sDate) & " AM"
				Else 
					sHour = "0" & hour(sDate)-12
                    fFormatDate = fFormatDate & " " & Right(sHour,2) & ":" & minute(sDate) & " PM"
				End If
		End Select
      	
	End If

End Function
'############################################################

'###########################################################
' Function name: fGuiCheckDefaults
'###########################################################
Public Function fSelectItem(ByVal sPage, ByVal sSelectObject, ByVal sItem)

    Browser("iBasis Customer Portal").Page(sPage).WebElement("Open " & sSelectObject).Click
	Browser("iBasis Customer Portal").Page(sPage).WebElement("Item").SetTOProperty "innertext", sItem
	If Browser("iBasis Customer Portal").Page(sPage).WebElement("Item").Exist(2) = "True" Then
		Browser("iBasis Customer Portal").Page(sPage).WebElement("Item").Click
	Else
		If Browser("iBasis Customer Portal").Page(sPage).WebElement("Next").Exist(2) = "True" Then
			Do
				Browser("iBasis Customer Portal").Page(sPage).WebElement("Next").Click
			Loop Until Browser("iBasis Customer Portal").Page(sPage).WebElement("Item").Exist = "True"
			If Browser("iBasis Customer Portal").Page(sPage).WebElement("Item").Exist = "True" Then
				Browser("iBasis Customer Portal").Page(sPage).WebElement("Item").Click
			Else
				Reporter.ReportEvent micFail, "fSelectItem", "The item: '"& sItem & "' was not found in: '" & sSelectObject & "' list"
				Call fWriteHtmlReportRow("fSelectItem - Page: " & sPage, "Select item for filter", "FAIL", "The item: '"& sItem & "' was not found in: '" & sSelectObject & "' list")	
			End If
		Else
			Reporter.ReportEvent micFail, "fSelectItem", "The item: '"& sItem & "' was not found in: '" & sSelectObject & "' list"
			Call fWriteHtmlReportRow("fSelectItem - Page: " & sPage, "Select item for filter", "FAIL", "The item: '"& sItem & "' was not found in: '" & sSelectObject & "' list")	
		End If
    End If

End Function

'###########################################################
' Function name: fGuiFilter
' Description:   The function checks all filters validations
'				and all DB validations AFTER filtering
' Parameters:	Protlet Name, Filters Names and Values
' Return value:  Success - True
' Example:
'###########################################################
Public Function fGuiFilter

   	Dim i, j, iColCount, sHeadData, iRowCount, k, sCellData, arrDate, sSQL, objRS

	'Navigation to the Portlet
	Browser("iBasis Customer Portal").Page("Home").Link("Finance").FireEvent "OnMouseOver"
	Browser("iBasis Customer Portal").Page("Home").Link(globaldictionary("PROTLET_NAME")).Click
	If Browser("iBasis Customer Portal").Page(globaldictionary("PROTLET_NAME")).Exist(30) = "False" Then
		Reporter.ReportEvent micFail, "fGuiFilter", "Failed to Navigate the protlet :" & globaldictionary("PROTLET_NAME")
		Call fWriteHtmlReportRow("fGuiFilter -" & globaldictionary("PROTLET_NAME"), "Navigate to the protlet", "FAIL", "Failed to Navigate the protlet :" & globaldictionary("PROTLET_NAME"))
		fGuiFilter = False
		Exit Function
	End If
	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fGuiFilter", "Failed to Navigate the protlet :" & globaldictionary("PROTLET_NAME")
		Call fWriteHtmlReportRow("fGuiFilter -" & globaldictionary("PROTLET_NAME"), "sync for refresh data", "FAIL", "sync failed after 60 seconds")
		fGuiFilter = False
		Exit Function
	End If

	sProtletName = globaldictionary("PROTLET_NAME")
	If Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName& " Table").RowCount = 0 Then 'No rows in table
		Reporter.ReportEvent micWarning, "fGuiFilter", "Check table's data on protlet: " & globaldictionary("PROTLET_NAME") & " - No data to filter"
		Call fWriteHtmlReportRow("fGuiFilter -" & globaldictionary("PROTLET_NAME"), "Check table's data on protlet: " & globaldictionary("PROTLET_NAME"), "INFO", "No data to filter on the table")
		Exit Function
	End If

	'Loop for each filter 
	i = 1
	While GlobalDictionary("FILTER_BY" & i) <> "" 

		'Date filters	
		If instr(1,lCase(GlobalDictionary("FILTER_BY" & i)), "date")  Then
			globaldictionary("FILTER" & i & "_VALUE2") = fFormatDate(globaldictionary("FILTER" & i & "_VALUE2"))
		End If
        
	  'Set filters' values from the Excel sheet
		'Check if the filter has more then one value 
		If globaldictionary("FILTER" & i & "_VALUE2") <> "" Then		'"select & field" filters
			
			Call fSelectItem(globaldictionary("PROTLET_NAME"), GlobalDictionary("FILTER_BY" & i),globaldictionary("FILTER" & i & "_VALUE1"))
			If fSyncByImage(60) = False Then
				Reporter.ReportEvent micFail, "fGuiFilter", "Sync for refresh filter's data failed on protlet: " & globaldictionary("PROTLET_NAME")
				Call fWriteHtmlReportRow("fGuiFilter -" & globaldictionary("PROTLET_NAME"), "sync for refresh filter's data", "FAIL", "sync failed after 60 seconds")
				fGuiFilter = False
				Exit Function
			End If
			Browser("iBasis Customer Portal").Page(globaldictionary("PROTLET_NAME")).WebEdit(globaldictionary("FILTER_BY" & i) & " Field").Set globaldictionary("FILTER" & i & "_VALUE2")

		ElseIf GlobalDictionary("FILTER_BY" & i) = "Currency" OR GlobalDictionary("FILTER_BY" & i) = "Transaction Type" OR GlobalDictionary("FILTER_BY" & i) = "Destination Name" Then
			'Browser("iBasis Customer Portal").Page(globaldictionary("PROTLET_NAME")).WebEdit(globaldictionary("FILTER_BY" & i)).Set globaldictionary("FILTER" & i & "_VALUE1")
			Call fSelectItem(globaldictionary("PROTLET_NAME"), GlobalDictionary("FILTER_BY" & i),globaldictionary("FILTER" & i & "_VALUE1"))
			If fSyncByImage(60) = False Then
				Reporter.ReportEvent micFail, "fGuiFilter", "Sync for refresh filter's data failed on protlet: " & globaldictionary("PROTLET_NAME")
				Call fWriteHtmlReportRow("fGuiFilter -" & globaldictionary("PROTLET_NAME"), "sync for refresh filter's data", "FAIL", "sync failed after 60 seconds")
				fGuiFilter = False
				Exit Function
			End If
		ElseIf GlobalDictionary("FILTER_BY" & i) = "Severity" Then
			Browser("iBasis Customer Portal").Page("Alerts").WebList("Severity").Select globaldictionary("FILTER" & i & "_VALUE1")
				
        Else	'Other filters
			Browser("iBasis Customer Portal").Page(globaldictionary("PROTLET_NAME")).WebEdit(globaldictionary("FILTER_BY" & i)).Set globaldictionary("FILTER" & i & "_VALUE1")	
		End If

		'Click "Apply"
		Browser("iBasis Customer Portal").Page(globaldictionary("PROTLET_NAME")).WebElement("Apply").Click
		Browser("iBasis Customer Portal").Page(globaldictionary("PROTLET_NAME")).WebElement("Apply").Click
		'Sync
		If fSyncByImage(60) = False Then
			Reporter.ReportEvent micFail, "fGuiFilter", "Failed to Navigate the protlet :" & globaldictionary("PROTLET_NAME")
			Call fWriteHtmlReportRow("fGuiFilter -" & globaldictionary("PROTLET_NAME"), "sync for refresh data", "FAIL", "sync failed after 60 seconds")
			fGuiFilter = False
			Exit Function
		End If
		wait(3)

	  'Check all rows in the displayed table after filtering
		iColumn = fGetColumnIndexByName(globaldictionary("PROTLET_NAME"),globaldictionary("FILTER_BY" & i))
		rc = fVerifyFilter(globaldictionary("PROTLET_NAME"),GlobalDictionary("FILTER_BY" & i),globaldictionary("FILTER" & i & "_VALUE1"),globaldictionary("FILTER" & i & "_VALUE2"),iColumn)

		If rc = False Then
			fGuiFilter = False
		End If

		i = i + 1
    Wend

	'Get the query for this protlet - After filter
	sSQL = fBuildSQL(globaldictionary("PROTLET_NAME"),null,null)
	
	'Check DB validations after filtering, using the SQL query
	rc = fGuiDBValidations(globaldictionary("PROTLET_NAME"), sSQL)
	If rc = False Then
		Reporter.ReportEvent micFail, "Check DB validation after filter", "DB validation after filter failed"
		Call fWriteHtmlReportRow("fGuiFilter", "Check DB validation after filter- " & sProtletName , "FAIL", "DB validation after filter failed")
		fGuiFilter = False
		Exit Function
	End If
	
	Reporter.ReportEvent micPass, "Check DB validation after filter", "DB validation after filter succeeded"
	Call fWriteHtmlReportRow("fGuiFilter", "Check DB validation after filter" , "PASS", "DB validation after filter succeeded")

	fGuiFilter = True

End Function
'###########################################################

'###########################################################
' Function name: fGetColumnIndexByName
' Description:  The function gets a Column Name and returns the Column Index
' Parameters:	Protlet Name, Column Name
' Return value:  Success - Column Index
'				 Failture - False
' Example:
'###########################################################
Public Function fGetColumnIndexByName(ByVal sProtletName,ByVal sColumnName)

	Dim iColCount, sCellData, i
	iColCount = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName& " Headers").ColumnCount(1)
	For i = 1 To iColCount
		sCellData = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName& " Headers").GetCellData(1, i)
		If Ucase(sCellData) = Ucase(sColumnName) Then
			fGetColumnIndexByName = i
			Exit Function
		End If

	Next

	fGetColumnIndexByName = False

End Function
'###########################################################

'###########################################################
' Function name: fGuiSort
' Description:  The function checks all filters validations
' Parameters:	Protlet Name, Column Name, Sort Type (Ascending/Descending)
' Return value:  Success - True
'	             Incorrect Column Name - False
' Example:
'###########################################################
Public Function fGuiSort(ByVal sProtletName, ByVal sColumnName, ByVal sSortType)

   	Dim iColumn, iGridRows, sCellData1, sCellData2, bFound
	bFound = True
	
	'Title - Portlet name
	Call fWriteHtmlReportRow("fGuiSort" ,globaldictionary("PROTLET_NAME"), "", "")
	
	'Navigation to the Portlet
	Browser("iBasis Customer Portal").Page("Home").Link("Finance").FireEvent "OnMouseOver"
	Browser("iBasis Customer Portal").Page("Home").Link(sProtletName).Click
	If Browser("iBasis Customer Portal").Page(sProtletName).Exist(30) = "False" Then
		Reporter.ReportEvent micFail, "fGuiSort", "Failed to Navigate the protlet: " & sProtletName
		Call fWriteHtmlReportRow("fGuiSort -" & sProtletName, "Navigate to the protlet", "FAIL", "Failed to Navigate the protlet: " & sProtletName)
		fGuiSort = False
		Exit Function
	End If
	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fGuiSort", "Failed to Navigate the protlet: " & sProtletName
		Call fWriteHtmlReportRow("fGuiSort -" & sProtletName, "sync for refresh data", "FAIL", "sync failed after 60 seconds")
		fGuiSort = False
		Exit Function
	End If

	iColumn = fGetColumnIndexByName(sProtletName,sColumnName)

	'COLUMN_NAME was not found
	If iColumn = False Then
		fGuiSort = False
		Exit Function
	End If

	iGridRows = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName& " Table").RowCount
	If iGridRows < 2 Then
		Reporter.ReportEvent micWarning, "Sort Column: " & sColumnName & " in protlet: " & sProtletName,iGridRows & " rows on table - There is no (enough) data to sort"
		Call fWriteHtmlReportRow("Sort Column", "Sort Column: " & sColumnName & " in protlet: " & sProtletName & " -" & sSortType, "INFO", iGridRows & " rows on table - There is no (enough) data to sort")
		fGuiSort = False
		Exit Function 
	End If
	
	Select Case sSortType
	
		Case "Ascending" 

			'Ascending - One click on the column header
			Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName& " Headers").ChildItem(1, iColumn, "WebElement",1).Click
			'Sync
			If fSyncByImage(60) = False Then
				Reporter.ReportEvent micFail, "fGuiSort", "Failed to Navigate the protlet: " & sProtletName
				Call fWriteHtmlReportRow("fGuiSort -" & sProtletName, "sync for refresh data", "FAIL", "sync failed after 60 seconds")
				fGuiSort = False
				Exit Function
			End If

			iGridRows = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName& " Table").RowCount
			If iGridRows = 0 Then
				Reporter.ReportEvent micFail, "Sort Column: " & sColumnName & "in protlet: " & sProtletName, " There is no data to sort after click on sort"
				Call fWriteHtmlReportRow("Sort Column", "Sort Column: " & sColumnName & " in protlet: " & sProtletName & " -" & sSortType, "FAIL", " There is no data to sort after click on sort")
				fGuiSort = False
				Exit Function 
			End If

			set objForm = objPB.fInitForm("Verifying Sort - " & sColumnName &  " Column...")
			Set objProgressBar = objPB.fInitProgressBar(objForm, 0, 100, Cint(100/iGridRows))
  
			'Veriry the sorted column
			For i = 1 To iGridRows - 1
				
				sCellData1 = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName& " Table").GetCellData(i, iColumn)
				sCellData2 = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName& " Table").GetCellData(i+1, iColumn)
				objProgressBar.PerformStep
				If sCellData1 <> "" AND sCellData2 <> "" Then
				
					If IsNumeric(sCellData1)And sColumnName <> "Reference" And sColumnName <> "Invoice ID" Then	'Numeric Column			
						Call fConvertFormat(sCellData1)
						Call fConvertFormat(sCellData2)
						If cdbl(sCellData2) < cdbl(sCellData1) Then
							bFound = False
							Reporter.ReportEvent micFail, "Sort Column: " & sColumnName & " in protlet: " & sProtletName, " Sort: " & sSortType & ". '" & sCellData2 & "' in row: " & (i + 1) & " is smaller than '" & sCellData1 & "' in row: "& i				
							Call fWriteHtmlReportRow("Sort Column", "Sort Column: " & sColumnName & " in protlet: " & sProtletName & " -" & sSortType, "FAIL", "'" & sCellData2 & "' in row: " & (i + 1) & " is smaller than '" & sCellData1 & "' in row: "& i)
							Exit For
						End If
	
					ElseIf IsDate(sCellData1) Then	'Date Column
						If DateDiff("d",sCellData1,sCellData2) < 0 Then
							bFound = False
							Reporter.ReportEvent micFail, "Sort Column: " & sColumnName & " in protlet: " & sProtletName, " Sort: " & sSortType & ". '" & sCellData2 & "' in row: " & (i + 1) & " is smaller than '" & sCellData1 & "' in row: "& i
							Call fWriteHtmlReportRow("Sort Column", "Sort Column: " & sColumnName & " in protlet: " & sProtletName & " -" & sSortType, "FAIL","'" & sCellData2 & "' in row: " & (i + 1) & " is smaller than '" & sCellData1 & "' in row: "& i)
							Exit For
						End If
	
					Else							'Alpha Column
						If StrComp(Trim(sCellData2),Trim(sCellData1))< 0 Then
							bFound = False
							Reporter.ReportEvent micFail, "Sort Column: " & sColumnName & " in protlet: " & sProtletName, " Sort: " & sSortType & ". '" & sCellData2 & "' in row: " & (i + 1) & " is smaller than '" & sCellData1 & "' in row: "& i
							Call fWriteHtmlReportRow("Sort Column", "Sort Column: " & sColumnName & " in protlet: " & sProtletName & " -" & sSortType, "FAIL", "'" & sCellData2 & "' in row: " & (i + 1) & " is smaller than '" & sCellData1 & "' in rows: "& i)
							Exit For
						End If
					End If

				End If
			Next
			objForm.Close
		Case "Descending"
			'Descending - Two clicks on the column header
			Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName& " Headers").ChildItem(1, iColumn, "WebElement",1).Click
			'Sync
			If fSyncByImage(60) = False Then
				Reporter.ReportEvent micFail, "fGuiSort", "Failed to Navigate the protlet: " & sProtletName
				Call fWriteHtmlReportRow("fGuiSort -" & sProtletName, "sync for refresh data", "FAIL", "sync failed after 60 seconds")
				fGuiSort = False
				Exit Function
			End If
			Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName& " Headers").ChildItem(1, iColumn, "WebElement",1).Click
			'Sync
			If fSyncByImage(60) = False Then
				Reporter.ReportEvent micFail, "fGuiSort", "Failed to Navigate the protlet: " & sProtletName
				Call fWriteHtmlReportRow("fGuiSort -" & sProtletName, "sync for refresh data", "FAIL", "sync failed after 60 seconds")
				fGuiSort = False
				Exit Function
			End If

			'Veriry the sorted column
			For i = 1 To iGridRows - 1
				sCellData1 = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName& " Table").GetCellData(i, iColumn)
				sCellData2 = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName& " Table").GetCellData(i+1, iColumn)

				If sCellData1 <> "" AND sCellData2 <> "" Then

					If IsNumeric(sCellData1) Then	'Numeric Column	
						Call fConvertFormat(sCellData1)
						Call fConvertFormat(sCellData2)		
						If cdbl(sCellData2) > cdbl(sCellData1) Then
                            bFound = False
							Reporter.ReportEvent micFail, "Sort Column: " & sColumnName & " in protlet: " & sProtletName," Sort: " & sSortType & ". '" & sCellData2 & "' in row: " & (i + 1) & " is bigger than '" & sCellData1 & "' in row: "& i
							Call fWriteHtmlReportRow("Sort Column", "Sort Column: " & sColumnName & " in protlet: " & sProtletName & " -" & sSortType, "FAIL","'" & sCellData2 & "' in row: " & (i + 1) & " is bigger than '" & sCellData1 & "' in row: "& i)
							Exit For
						End If
	
					ElseIf IsDate(sCellData1) Then	'Date Column
						If DateDiff("d",sCellData1,sCellData2) > 0 Then
							bFound = False
							Reporter.ReportEvent micFail, "Sort Column: " & sColumnName & " in protlet: " & sProtletName, " Sort: " & sSortType & ". '"  & sCellData2 & "' in row: " & (i + 1) & " is bigger than '" & sCellData1 & "' in row: "& i
							Call fWriteHtmlReportRow("Sort Column", "Sort Column: " & sColumnName & " in protlet: " & sProtletName & " -" & sSortType, "FAIL", "'" & sCellData2 & "' in row: " & (i + 1) & " is bigger than '" & sCellData1 & "' in row: "& i)
							Exit For
						End If
	
					Else							'Alpha Column
						If StrComp(Trim(sCellData2),Trim(sCellData1))> 0 Then
							bFound = False
							Reporter.ReportEvent micFail, "Sort Column: " & sColumnName & " in protlet:" & sProtletName , " Sort: " & sSortType & ". '" & sCellData2 & "' in row: " & (i + 1) & " is bigger than '" & sCellData1 & "' in row: "& i
							Call fWriteHtmlReportRow("Sort Column", "Sort Column: " & sColumnName & " in protlet: " & sProtletName & " -" & sSortType, "FAIL","'" & sCellData2 & "' in row: " & (i + 1) & " is bigger than 's" & sCellData1 & "' in row: "& i)
							Exit For
						End If
					End If

				End If
			Next

	End Select

	If bFound = true Then
		reporter.ReportEvent micPass,"Sort column " & sColumnName& " in protlet:" & sProtletName,"All items sorted by " & sSortType
		Call fWriteHtmlReportRow("Sort Column", "Sort Column: " & sColumnName & " in protlet: " & sProtletName & " -" & sSortType, "PASS", "All items sorted by " & sSortType)
	End If 

	'Get the query for this protlet - After sort
	sSQL = fBuildSQL(globaldictionary("PROTLET_NAME"),sColumnName, sSortType)
	'Check DB validations after filtering, using the SQL query
	rc = fGuiDBValidations(globaldictionary("PROTLET_NAME"), sSQL)
	If rc <> True Then
		Reporter.ReportEvent micFail, "Check DB validation after filter", "DB validation after filter failed"
		Call fWriteHtmlReportRow("fGuiFilter", "Check DB validation after filter- " & sProtletName , "FAIL", "DB validation after filter failed")
		fGuiFilter = False
		Exit Function
	End If
    Reporter.ReportEvent micPass, "Check DB validation after sort", "DB validation after filter succeeded"
	Call fWriteHtmlReportRow("fGuiFilter", "Check DB validation after sort" , "PASS", "DB validation after filter succeeded")       

	fGuiSort = True

End Function
'###########################################################

'###########################################################
' Function name: fExchageRate
' Description:   The function calculates and returns the Exchange Rate between
'				two currencies multiplied by a number (-FromCurrency number)
' Parameters:	cellData, From Currency, To Currency
' Return value: Success - Result of the multiplication
'				failure - False (DB connection faild) / NO_RECORDS_FOUND
' Example:
'###########################################################
Public Function fExchageRate (ByVal iCellData, ByVal sFromCur, ByVal sToCur)

	Dim sSQL, rc

	If sFromCur = sToCur Then
		fExchageRate = Cdbl(iCellData)
	Else
		'Convert Value from FromCur to USD
		sSQL = "SELECT DISTINCT RATE FROM " & SCHEMA & "EXCHANGE_RATE WHERE FROM_CURRENCY = '" & sFromCur & "' AND TO_CURRENCY = '"& sToCur &"'" 
		rc = fDBGetOneValue("BILLING", sSQL, sOutValue)

		'Check sOutValue returned value
		If rc = False Then						'DB Connection failed
			Reporter.ReportEvent micFail, "fExchageRate", "Connetion to DB was failed"
			Call fWriteHtmlReportRow("fExchageRate", "Check the connection to DB", "FAIL","Connetion to DB was failed")
			fExchageRate = False
			Exit Function		
		ElseIf rc = NO_RECORDS_FOUND Then		'NO_RECORDS_FOUND
			Reporter.ReportEvent micWarning, "fExchageRate", "No records returned by the query."
			Call fWriteHtmlReportRow("fExchageRate", "No records returned by the query", "INFO","Missing conversion from " & sFromCur & " to " & sToCur)
			fExchageRate = Cdbl(iCellData)
			Exit Function
		End If

		fExchageRate =  cdbl(sOutValue) * Cdbl(iCellData) 'query that returns the exchange rate * iCellData

	End If
		
End Function
'###########################################################

'###########################################################
' Function name: fGuiGrandTotal
' Description:  Check if the Displayed Grand Total of a column is correct 
' Parameters:	Protlet Name, Columns names
' Return value:  Success - True
' Example:
'###########################################################
Public Function fGuiGrandTotal (ByVal sProtletName)

   	Dim i, j, k,iId, iColumn, iGrandTotal,  iCellData, iGrandDataUI
	Dim sTableName, sSQL, sCurrency, sColumnName
	
	'Navigation to the Portlet
	Browser("iBasis Customer Portal").Page("Home").Link("Finance").FireEvent "OnMouseOver"
	Browser("iBasis Customer Portal").Page("Home").Link(sProtletName).Click
	If Browser("iBasis Customer Portal").Page(sProtletName).Exist(30) = "False" Then
		Reporter.ReportEvent micFail, "fGuiGrandTotal", "Failed to Navigate the protlet: " & sProtletName
		Call fWriteHtmlReportRow("fGuiGrandTotal - " & sProtletName, "Navigate to the protlet", "FAIL", "Failed to Navigate the protlet: " & sProtletName)
		fGuiGrandTotal = False
		Exit Function
	End If
	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fGuiGrandTotal", "Failed to Navigate the protlet: " & sProtletName
		Call fWriteHtmlReportRow("fGuiGrandTotal - " & sProtletName, "sync for refresh data", "FAIL", "sync failed after 60 seconds")
		fGuiGrandTotal = False
		Exit Function
	End If

	Call fGetReferenceVerificationData("CUST_ID", iId)
	Call fGetReferenceVerificationData("DEFAULT_CURRENCY", sDefaultCur)

    'Loop for each column
	i = 1
	While GlobalDictionary("COLUMN_NAME" & i) <> ""
		sTableName = sProtletName
		sColumnName = GlobalDictionary("COLUMN_NAME" & i)

		Call fGetTableAndColumnName(sTableName, sColumnName, sCurrency)

		sSQL = "SELECT " & sColumnName & "," & sCurrency & " FROM " & sTableName & " WHERE customer_id IN (SELECT ID FROM " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters =" & iId & ") " & GlobalDictionary("CONDITION")
		rc = fDBGetRS ("BILLING", sSQL, objRS) 

		'Check fDBGetRS returned value
		If rc = False Then						'DB Connection failed
			Reporter.ReportEvent micFail, "fGuiGrandTotal - "& sProtletName, "Protlet: " & sProtletName & " - Connetion to DB was failed."
			Call fWriteHtmlReportRow("fGuiGrandTotal - "& sProtletName, "Check the connection to DB", "FAIL","Connetion to DB was failed")
			fGuiGrandTotal = False
			Exit Function		
		ElseIf rc = NO_RECORDS_FOUND Then		'NO_RECORDS_FOUND
			Reporter.ReportEvent micWarning, "fGuiGrandTotal - "& sProtletName, "Protlet: " & sProtletName & " - No records returned by the query."
			Call fWriteHtmlReportRow("fGuiGrandTotal - "& sProtletName, "Check if records returned from DB", "INFO","No records returned by the query")
			fGuiGrandTotal = False
			Exit Function
		End If

		iGrandTotal = 0

		'Handling "Minutes/Message" Column (Unbilled Traffic)
		If(UCase(GlobalDictionary("COLUMN_NAME" & i)) = "MINUTES / MESSAGE") Then
			objRS.MoveFirst
			While Not objRS.EOF
				iCellData = objRS.Fields(sColumnName).Value
				iGrandTotal = iGrandTotal + Cdbl(iCellData)
				objRS.MoveNext
			Wend
						
		'Handling Other Columns
		Else
			While Not objRS.EOF
				iCellData = objRS.Fields(sColumnName).Value
				iGrandTotal = iGrandTotal + fExchageRate(Cdbl(iCellData), objRS.Fields(sCurrency).Value, sDefaultCur)
				objRS.MoveNext
			Wend
				
		End If
	
			'Check if the Displayed Grand Total of a column match to the sum of rows
			iColumn = fGetColumnIndexByName(sProtletName, GlobalDictionary("COLUMN_NAME" & i))
			If UCase(GlobalDictionary("COLUMN_NAME" & i)) = "TOTAL CHARGES" Or UCase(GlobalDictionary("COLUMN_NAME" & i)) = "OPEN AMOUNT"  Then
				iGrandDataUI = Browser("iBasis Customer Portal").Page(sProtletName).webTable("Grand Total").GetCellData(1,iColumn+2)
			Else
				iGrandDataUI = Browser("iBasis Customer Portal").Page(sProtletName).webTable("Grand Total").GetCellData(1,iColumn)
			End If
			iGrandDataUI = fConvertFormat(iGrandDataUI)

			If Round(Cdbl(iGrandTotal),2) = Cdbl(iGrandDataUI) Then
				reporter.ReportEvent micPass,"Calculate Grand Total- " & sProtletName,"Column " & GlobalDictionary("COLUMN_NAME" & i) & " in protlet: " & sProtletName & " Displayed Grand Total match to the sum of rows from DB"
				Call fWriteHtmlReportRow("Calculate Grand Total", "Calculate Column : '" & GlobalDictionary("COLUMN_NAME" & i) & "' in protlet: " & sProtletName, "PASS", " Displayed Grand Total match to the sum of rows from DB")
			Else
				reporter.ReportEvent micFail,"Calculate Grand Total- " & sProtletName,"Column " & GlobalDictionary("COLUMN_NAME" & i) & " in protlet: " & sProtletName & " Displayed Grand Total: " & iGrandDataUI & "does not match to the sum of rows from DB: " & Round(Cdbl(iGrandTotal),2) 
				Call fWriteHtmlReportRow("Calculate Grand Total", "Calculate Column " & GlobalDictionary("COLUMN_NAME" & i) & " in protlet: " & sProtletName, "FAIL", " Displayed Grand Total: " & iGrandDataUI & "does not match to the sum of rows from DB: " & Round(Cdbl(iGrandTotal),2))
			End If 

		i = i + 1
	Wend

	fGuiGrandTotal = True

End Function
'###########################################################

'###########################################################
' Function name: fAssociateGrandTotal
' Description:  Check if the Displayed Grand Total of Applied Amount column
'				and the Amount on the Payments Table are match
'				to the sum of rows in the Associated Table 
' Parameters:	FromCurrency, ToCurrency, PaymentAmount, PaymentCurrentRow
' Return value:  Success - True
' Example:
'###########################################################
Public Function fAssociateGrandTotal(ByVal sCurData, ByVal sDefaultCur, ByVal iPaymentAmount, ByVal iPaymentCurrentRow)

	Dim iRowCount, iGrandTotal, iCellData, i

		iRowCount = Browser("iBasis Customer Portal").Page("Payments").WebTable("Invoices associated with Payment Table").RowCount
		iGrandTotal = 0
        For i = 1 To iRowCount
			iCellData = Browser("iBasis Customer Portal").Page("Payments").WebTable("Invoices associated with Payment Table").GetCellData(i,3)
			iGrandTotal = iGrandTotal + fExchageRate(Cdbl(iCellData), sCurData, sDefaultCur)
		Next

		'Check if the Displayed Grand Total of a column match to the sum of rows
		iGrandData = Browser("iBasis Customer Portal").Page(sProtletName).webTable("Invoices associated with Payment Grand Total").GetCellData(1,3)
		If Round(Cdbl(iGrandTotal),2) = Cdbl(iGrandData) Then
			reporter.ReportEvent micPass,"Calculate Grand Total","Column Applied Amount in protlet: Payment - Associated Table, Displayed Grand Total match to the sum of rows"
			Call fWriteHtmlReportRow("Calculate Grand Total", "Calculate Column: Applied Amount, in protlet: Payment - Associated Table", "PASS","Displayed Grand Total match to the sum of rows")
		Else
			reporter.ReportEvent micFail,"Calculate Grand Total","Column Applied Amount in protlet: Payment - Associated Table, Displayed Grand Total: " & iGrandData & "does not match to the sum of rows: " & iGrandTotal 
			Call fWriteHtmlReportRow("Calculate Grand Total", "Calculate Column: Applied Amount, in protlet: Payment - Associated Table", "FAIL","Displayed Grand Total: " & iGrandData & "does not match to the sum of rows: " & iGrandTotal)
		End If

		'Check if the Displayed sum of rows match to the "Amount" on the Payments main table
		If Round(Cdbl(iGrandTotal),2) = Cdbl(iPaymentAmount) Then
			reporter.ReportEvent micPass,"Calculate Grand Total","The Amount on Payments Table, row: " & iPaymentCurrentRow & " Value: " & iPaymentAmount &" match to the sum of rows in the Associated Table, Value: " & Round(Cdbl(iGrandTotal),2)
			Call fWriteHtmlReportRow("Calculate Grand Total", "Check the matching of 'Amount' on the Payments main table with sum of rowes in associate", "PASS","The Amount on Payments Table, row: " & iPaymentCurrentRow & " Value: " & iPaymentAmount &" match to the sum of rows in the Associated Table, Value: " & Round(Cdbl(iGrandTotal),2))
		Else
			reporter.ReportEvent micFail,"Calculate Grand Total","The Amount on Payments Table, row: " & iPaymentCurrentRow & " Value: " & iPaymentAmount &" does NOT match to the sum of rows in the Associated Table, Value: " & Round(Cdbl(iGrandTotal),2)
			Call fWriteHtmlReportRow("Calculate Grand Total", "Check the matching of 'Amount' on the Payments main table with sum of rowes in associate", "FAIL","The Amount on Payments Table, row: " & iPaymentCurrentRow & " Value: " & iPaymentAmount &" does NOT match to the sum of rows in the Associated Table, Value: " & Round(Cdbl(iGrandTotal),2))
		End If 
    
	fAssociateGrandTotal = True
End Function
'###########################################################

'###########################################################
' Function name: fGuiDBValidations
' Description:  Check all DB Validations, Using a SQL query
' Parameters:	Protlet Name, SQL query
' Return value:  Success - True
' Example:
'###########################################################
Public Function fGuiDBValidations (ByVal sProtletName, ByVal sSQL)

  	Dim i, j, k, iRowCount, iColCount, iRowCountDB, sCellDataUI, sCellDataDB, bFound, arrDate, rc
	bFound = True

	'Gets Rows/Columns count on UI
	iRowCount = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").RowCount
	iColCount = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Headers").ColumnCount(1)
 
	'Gets a RS, using a SQL query
     rc = fDBGetRS ("BILLING", sSQL, objRS) 

	'Check fDBGetRS returned value
	If rc = False Then						'DB Connection failed
		Reporter.ReportEvent micFail, "fGuiDBValidations - "& sProtletName, "Protlet: " & sProtletName & " - Connetion to DB was failed."
		Call fWriteHtmlReportRow("DB Validation - "& sProtletName, "Check the connection to DB", "FAIL","Connetion to DB was failed")
		fGuiDBValidations = False
		Exit Function		
    ElseIf rc = NO_RECORDS_FOUND Then		'NO_RECORDS_FOUND
    	If iRowCount > 0 Then
    		Reporter.ReportEvent micFail, "fGuiDBValidations - "& sProtletName, "Protlet: " & sProtletName & " - No records found on DB, but some records found on the UI."
		    Call fWriteHtmlReportRow("DB Validation - "& sProtletName, "Check if records returned from DB", "FAIL","No records found on DB, but some records found on the UI.")
		    fGuiDBValidations = NO_RECORDS_FOUND
		Else' iRowCount = 0
			Reporter.ReportEvent micWarning, "fGuiDBValidations - "& sProtletName, "Protlet: " & sProtletName & " - No records found on both DB and UI."
			Call fWriteHtmlReportRow("DB Validation - "& sProtletName, "Check if records returned from DB", "INFO","No records found on both DB and UI")
			fGuiDBValidations = NO_RECORDS_FOUND
    	End If		
		Exit Function
	End If	
	
	If iRowCount = 0 Then
		Reporter.ReportEvent micWarning, "fGuiDBValidations - "& sProtletName, "Protlet: " & sProtletName & " - No records found on UI"
		Call fWriteHtmlReportRow("DB Validation - "& sProtletName, "Check if there is data on UI", "INFO","No records found on UI")
		fGuiDBValidations = False
		Exit Function
	End If

    'Count the Rows of the RS
   	iRowCountDB = 0
	objRS.MoveFirst
	While Not objRS.EOF
		iRowCountDB = iRowCountDB +1
		objRS.MoveNext
	Wend

	'Handling main table in protlet
	'If iRowCount = iRowCountDB Then
	If iRowCount > 15 Then
		iRowCount = 15
	End If

		objRS.MoveFirst
		For i = 1 To iRowCount 
			k = 0
			For j = 1 To iColCount
				sHeadDataUI = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Headers").GetCellData(1, j)
				If Instr(1, lCase(sHeadDataUI), "conversion") > 0 Then
					j = j + 2 'Skip conversion columns

					If j = iColCount+1 Then 'No more columns after conversion columns
						Exit For
					End If

                    sCellDataUI = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").GetCellData(i, j)
					sCellDataDB = objRS.Fields(k).Value
				Else
            		sCellDataUI = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").GetCellData(i, j)
					sCellDataDB = objRS.Fields(k).Value
				End If

                'Handling 'Null' value on DB/UI
				If IsNull(sCellDataDB) Then
					sCellDataDB = ""
				End If
                				
				'Handling item_type column on Billed Transactions/Alerts protlet
			    If objRS.Fields(j-1).Name = "SEVERITY" Then
				
					Select Case sCellDataDB
						Case "0"
							sCellDataDB = "Info"
						Case "1"
							sCellDataDB = "Warning"
						Case "2"
							sCellDataDB = "Critical"
						Case "3"
							sCellDataDB = "Blocked"
							If sProtletName = "Alerts" Then
								sCellDataDB = "Block"
							End If
					End Select
				End If

				'Handling item_type column on Billed Transactions protlet
			    If sProtletName = "Open Transactions" And objRS.Fields(j-1).Name = "ITEM_TYPE" Then
				
					Select Case sCellDataDB
						Case "I"
							sCellDataDB = "Invoice"
						Case "P"
							sCellDataDB = "Payment"
						Case "C"
							sCellDataDB = "Credit Memo"
						Case "O"
							sCellDataDB = "Remaining Balance"
					End Select
				End If

				'Change string to double for Numeric columns
				If IsNumeric(cstr(sCellDataDB)) Then
					sCellDataUI = fConvertFormat(sCellDataUI)
					If IsNumeric(sCellDataUI) AND IsNumeric(cstr(sCellDataDB)) Then
						sCellDataUI = Round(cdbl(Trim(sCellDataUI)),2)
						sCellDataDB = Round(cdbl(Trim(sCellDataDB)),2)
					End If

                    If right(sCellDataUI,2) - right(sCellDataDB,2) = 1 Then '(when value is xxx.xx5, UI and DB round are different)
						sCellDataDB = sCellDataUI
					End If
				'Change date format for Date columns
				ElseIf isDate(sCellDataUI) AND isDate(sCellDataDB) Then	
					sCellDataUI = cDate(Trim(sCellDataUI)) 
					sCellDataDB = cDate(Trim(sCellDataDB))									
				Else
					sCellDataUI = Trim(sCellDataUI) 
					sCellDataDB = Trim(sCellDataDB)
				End If

				If sCellDataUI = "N\A"  Then
					sCellDataUI = Null
					sCellDataDB = Null
				End If

				'Compare the value from UI to DB
				If sCellDataUI <> sCellDataDB Then
					 reporter.ReportEvent micFail,"DB Validation - "& sProtletName,"Protlet Name: "& sProtletName & ", The value from UI: " & sCellDataUI & " in Row: "& i & " Column: " & j & " is not equal to value from DB: "& sCellDataDB
					 Call fWriteHtmlReportRow("DB Validation - "& sProtletName, "Check the matching of values from UI to DB", "FAIL","The value from UI: " & sCellDataUI & " in Row: "& i & " Column: " & j & " is not equal to value from DB: "& sCellDataDB)
					 bFound = False
				End If

			k = k + 1
			Next
	
			'Handling "Invoices associated with payment" table
'			If sProtletName = "Payments/Credits" Then
'				'Click the row
'				Browser("iBasis Customer Portal").Page("Payments").WebTable("Payments Table").ChildItem(i,1,"WebElement",0).click
'				wait(2)
'
'				'Call fVerifyAssociatePayment
'				rc = fVerifyAssociatePayment(objRS.Fields("sap_document_number").Value, i)
'			End If
			
			objRS.MoveNext	'next row
		Next

		'All values match
		If bFound = True Then
		   reporter.ReportEvent micPass,"DB Validation - "& sProtletName,"Protlet Name: "& sProtletName & ", All values from UI are equal to DB" 
		   Call fWriteHtmlReportRow("DB Validation - "& sProtletName, "Check the matching of values from UI to DB", "PASS","All values from UI are equal to DB")
		Else
			fGuiDBValidations = False
			Exit function
		End If
			 
'	Else	'RS row count is not equal to UI row count 
'		reporter.ReportEvent micFail,"DB Validation - "& sProtletName,"Protlet Name: "& sProtletName &", The count of rows in UI is not equal to DB"
'		Call fWriteHtmlReportRow("DB Validation - "& sProtletName, "Check the matching of rowcount of UI to DB", "FAIL","The count of rows in UI is not equal to DB")
'	End If
	
	fGuiDBValidations = True

End Function
'###########################################################

'###########################################################
' Function name: VerifyAssociatePayment
' Description:  Check all DB Validations for Associate with Payment table
' Parameters:	
' Return value:  Success - True
' Example:
'###########################################################
Public Function fVerifyAssociatePayment(ByVal sInvoiceReference, ByVal iRowInPayment)

	Dim iRowAssociate, iColAssociate, sSQL, iRowAssociateDB, sCellDataUI, sCellDataDB
	Dim i, j, bFound, iId

	bFound = True

    iRowAssociate = Browser("iBasis Customer Portal").Page("Payments").WebTable("Invoices associated with Payment Table").RowCount
	iColAssociate = Browser("iBasis Customer Portal").Page("Payments").WebTable("Invoices associated with Payment Headers").ColumnCount(1)

	Call fGetReferenceVerificationData("CUST_ID", iId)
	sSQL = "SELECT i.paid_document_reference, i.paid_document_date, i.paid_document_amount, p.document_currency FROM " & SCHEMA & "CUST_PMT_CMEMO_HIST_DETAIL I JOIN CUST_PMT_CMEMO_HIST_HEADER P On i.payment_sap_document_number = p.sap_document_number WHERE i.customer_id in(SELECT ID FROM " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters =" & iId &") AND i.payment_sap_document_number =" & sInvoiceReference 
	rc = fDBGetRS ("BILLING", sSQL, objAssociateRS)

	'Check fDBGetRS returned value
	If rc = False Then
		Reporter.ReportEvent micWarning, "fVerifyAssociatePayment", "Protlet: Payment - Associated Table, Row In Payment: " & iRowInPayment & " - Connetion to DB was failed."
		Call fWriteHtmlReportRow("DB Validation - "& sProtletName, "Check the connection to DB", "INFO","No records found on UI")
		fVerifyAssociatePayment = False
		Exit Function
    ElseIf rc = NO_RECORDS_FOUND Then
		Reporter.ReportEvent micWarning, "fVerifyAssociatePayment", "Protlet: Payment - Associated Table, Row In Payment: " & iRowInPayment & " - No records returned by the query."
		Call fWriteHtmlReportRow("DB Validation - "& sProtletName, "Check if records returned from DB", "INFO","No records returned by the query")
		fVerifyAssociatePayment = False
		Exit Function
	End If

	'Count the rows of RS
	iRowAssociateDB = 0
	objAssociateRS.MoveFirst
	While Not objAssociateRS.EOF
		iRowAssociateDB = iRowAssociateDB +1
		objAssociateRS.MoveNext
	Wend
			
	'Handling Associated with Payment table 
	If iRowAssociate = iRowAssociateDB Then
		objAssociateRS.MoveFirst
		For i = 1 To iRowAssociate 
			For j = 1 To iColAssociate
				sCellDataUI = Browser("iBasis Customer Portal").Page("Payments").WebTable("Invoices associated with Payment Table").GetCellData(i, j)
				sCellDataDB = objAssociateRS.Fields(j-1).Value
		
				'Change string to double for Numeric columns
				If IsNumeric(sCellDataUI) Then
					sCellDataUI = Round(cdbl(Trim(sCellDataUI)),2)
					sCellDataDB = Round(cdbl(Trim(sCellDataDB)),2)
				'Change date format for Date columns
				ElseIf isDate(sCellDataUI) Then	
					sCellDataUI = cDate(Trim(sCellDataUI)) 
					sCellDataDB = cDate(Trim(sCellDataDB))
				Else
					sCellDataUI = Trim(sCellDataUI) 
					sCellDataDB = Trim(sCellDataDB)
				End If
			
				If sCellDataUI <> sCellDataDB Then
					reporter.ReportEvent micFail,"DB Validation - Payment - Associated","Protlet: Payment - Associated Table, Row In Payment: " & iRowInPayment & ", The value from UI: " & sCellDataUI & " in Row: "& i & " Column: " & j & " is not equal to value from DB: "& sCellDataDB
					Call fWriteHtmlReportRow("DB Validation -  Payment - Associated", "Check the matching of values from UI to DB,Row In Payment: " & iRowInPaymen, "FAIL","The value from UI: " & sCellDataUI & " in Row: "& i & " Column: " & j & " is not equal to value from DB: "& sCellDataDB)
					bFound = False
				End If
		
			Next
				objAssociateRS.MoveNext
		Next

		'All values match
		If bFound = True Then
		   reporter.ReportEvent micPass,"DB Validation - Payment - Associated","Protlet: Payment - Associated Table, Row In Payment: " & iRowInPayment & ", All values from UI are equal to DB" 
		   Call fWriteHtmlReportRow("DB Validation - Payment - Associated", "Check the matching of values from UI to DB, Row In Payment: " & iRowInPayment, "PASS","All values from UI are equal to DB")
		End If
			 
	Else
		reporter.ReportEvent micFail,"DB Validation - Payment - Associated","Protlet: Payment - Associated Table, Row In Payment: " & iRowInPayment & ", The count of rows in UI is not equal to DB"
		Call fWriteHtmlReportRow("DB Validation - Payment - Associated", "Check the matching of rowcount of UI to DB, Row In Payment: " & iRowInPayment, "FAIL","The count of rows in UI is not equal to DB")
	End If
	
	VerifyAssociatePayment = True
					
End Function
'###########################################################

'###########################################################
' Function name: fBuildSQL
' Description:  Build SQL query according to the filters 
' Parameters:	Protlet Name, [Filters Names, Filters' Values]
' Return value:  Success - Returns the SQL query
'				 Failure - False
' Example:
'###########################################################
Public Function fBuildSQL(ByVal sProtletName, ByVal sColumnToSort, ByVal sSortType)

	Dim i, sSQL, sSign, arrDate, sFormat, sTimeFormat, iId
	Call fGetReferenceVerificationData("DATE_FORMAT", sFormat)
	Call fGetReferenceVerificationData("TIME_FORMAT", sTimeFormat)
	'sTimeFormat = "HH:MI" ' GlobalDictionary("TIME_FORMAT") 

	Call fGetReferenceVerificationData("CUST_ID", iId)

	sSQL = "SELECT * FROM ("

	'Basic SQL query (for default tables)
	Select Case sProtletName
		Case "Unbilled Traffic"			
			sSQL = sSQL & "SELECT DESTINATION_NAME, units, currency, amount FROM " & SCHEMA & "CUST_UNBILLED WHERE self_declare_flag = 0 AND customer_id IN (SELECT ID FROM " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters =" & iId &")"
		Case "Open Transactions"
			sSQL = sSQL & "SELECT item_type,document_reference,document_date,due_date, document_currency, document_amount, open_amount FROM " & SCHEMA & "CUSTOMER_BILLED_TRANS WHERE customer_id in(SELECT ID FROM " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters =" & iId &")"
		Case "Invoices"
			sSQL = sSQL & "SELECT document_reference,document_date, document_currency, document_amount,paid_amount,cleared_amount,open_amount FROM " & SCHEMA & "CUSTOMER_INVOICE_HISTORY  WHERE customer_id in(SELECT ID FROM " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters = " & iId &")"
		Case "Payments / Credits"
			sSQL = sSQL & "SELECT document_date, document_reference, document_amount, document_currency, sap_document_number FROM " & SCHEMA & "CUST_PMT_CMEMO_HIST_HEADER WHERE customer_id in(SELECT ID FROM " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters = " & iId &")"
		Case "Disputes"
			sSQL = sSQL & "SELECT document_reference,dispute_date,dispute_case_number,currency,invoice_amount,dispute_amount FROM " & SCHEMA & "CUSTOMER_DISPUTES_FROM_SAP WHERE customer_id in(SELECT ID FROM " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters = " & iId &")"
		Case "Alerts" 
			sSQL = sSQL & "SELECT TO_CHAR(SENT_DATE, '" & sFormat & " HH:MI AM') as SENT__DATE, SEVERITY, MESSAGE FROM " & SCHEMA & "ECARE_CUSTOMER_ALERT_HISTORY WHERE customer_id in(SELECT ID FROM " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters = " & iId &")" 
	End Select

	i = 1
	'Add conditions for the query (for filtered tables)
	If GlobalDictionary("FILTER_BY" & i) <> ""  Then
	
		Select Case sProtletName 
			
			Case "Unbilled Traffic"
	
				'Loop for each filter 
				
				While GlobalDictionary("FILTER_BY" & i) <> "" 	 
				'sSQL = "SELECT DESTINATION_NAME, Minutes, amount, currency FROM CUST_UNBILLED WHERE self_declare_flag = 0 AND customer_id IN (SELECT ID FROM CUSTOMER_MASTER WHERE headquarters =" & GlobalDictionary("CUSTOMER_ID")&")"
					Select Case UCase(GlobalDictionary("FILTER_BY" & i))
						Case "DESTINATION NAME"
							sSQL = sSQL & " and UPPER(DESTINATION_NAME) like UPPER('%" & GlobalDictionary("FILTER" & i & "_VALUE1") & "%')"
						Case "MINUTES / MESSAGE"
							sSQL = sSQL & " and Minutes" & GlobalDictionary("FILTER" & i & "_VALUE1") & GlobalDictionary("FILTER" & i & "_VALUE2") 
						Case "TOTAL CHARGES"
							sSQL = sSQL & " and amount" & GlobalDictionary("FILTER" & i & "_VALUE1") & GlobalDictionary("FILTER" & i & "_VALUE2") 
						Case "CURRENCY"
							sSQL = sSQL & " and UPPER(currency) like UPPER('" & GlobalDictionary("FILTER" & i & "_VALUE1") & "')"

					End Select

					i = i + 1
				Wend
			   
			Case "Open Transactions"
	
				'Loop for each filter 
            	While GlobalDictionary("FILTER_BY" & i) <> "" 	 
	
					Select Case  UCase(GlobalDictionary("FILTER_BY" & i))
						Case "TRANSACTION TYPE"
							sSQL = sSQL & " and UPPER(item_type) like UPPER('" & Left(Trim(UCase(GlobalDictionary("FILTER" & i & "_VALUE1"))),1) & "')"
						Case "REFERENCE"
							sSQL = sSQL & " and UPPER(document_reference) like UPPER('%" & UCase(GlobalDictionary("FILTER" & i & "_VALUE1")) & "%')"
						Case "DOCUMENT DATE"
    						sSQL = sSQL & " and document_date " & GlobalDictionary("FILTER" & i & "_VALUE1")  & "To_DATE('" & GlobalDictionary("FILTER" & i & "_VALUE2") & "', '" & sFormat &"')"	
						Case "DUE DATE"
        					sSQL = sSQL & " and due_date" & GlobalDictionary("FILTER" & i & "_VALUE1") & "To_DATE('" & GlobalDictionary("FILTER" & i & "_VALUE2") & "', '" & sFormat &"')"	
						Case "TOTAL AMOUNT"
							sSQL = sSQL & " and document_amount" & GlobalDictionary("FILTER" & i & "_VALUE1") & GlobalDictionary("FILTER" & i & "_VALUE2") 
						Case "OPEN AMOUNT"
							sSQL = sSQL & " and open_amount" & GlobalDictionary("FILTER" & i & "_VALUE1") & GlobalDictionary("FILTER" & i & "_VALUE2") 
						Case "CURRENCY"
							sSQL = sSQL & " and UPPER(document_currency) like UPPER('" & GlobalDictionary("FILTER" & i & "_VALUE1") & "')"
					End Select

					i = i + 1
				Wend
	
			Case "Invoices"
				
				'Loop for each filter 
            	While GlobalDictionary("FILTER_BY" & i) <> "" 


					Select Case UCase(GlobalDictionary("FILTER_BY" & i))
						Case "INVOICE ID"
							sSQL = sSQL & " and UPPER(document_reference) like UPPER('%" & GlobalDictionary("FILTER" & i & "_VALUE1") & "%')"
						Case "INVOICE DATE"
							sSQL = sSQL & " and document_date" & GlobalDictionary("FILTER" & i & "_VALUE1") & "To_DATE('" & GlobalDictionary("FILTER" & i & "_VALUE2") & "', '" & sFormat &"')"	
						Case "INVOICE AMOUNT"
							sSQL = sSQL & " and document_amount" & GlobalDictionary("FILTER" & i & "_VALUE1") & GlobalDictionary("FILTER" & i & "_VALUE2") 
						Case "PAID AMOUNT"
							sSQL = sSQL & " and paid_amount" & GlobalDictionary("FILTER" & i & "_VALUE1") & GlobalDictionary("FILTER" & i & "_VALUE2") 
						Case "OTHER CLEARED AMOUNT"
							sSQL = sSQL & " and cleared_amount" & GlobalDictionary("FILTER" & i & "_VALUE1") & GlobalDictionary("FILTER" & i & "_VALUE2") 
						Case "OPEN AMOUNT"
							sSQL = sSQL & " and open_amount" & GlobalDictionary("FILTER" & i & "_VALUE1") & GlobalDictionary("FILTER" & i & "_VALUE2") 
						Case "CURRENCY"
							sSQL = sSQL & " and UPPER(document_currency) like UPPER('" & GlobalDictionary("FILTER" & i & "_VALUE1") & "')"

					End Select

					i = i + 1
				Wend
	
			Case "Payments / Credits"
	
				'Loop for each filter 
            	While GlobalDictionary("FILTER_BY" & i) <> "" 	 

					Select Case UCase(GlobalDictionary("FILTER_BY" & i))
						Case "PAYMENT DATE"
							sSQL = sSQL & " and document_date" & GlobalDictionary("FILTER" & i & "_VALUE1") & "To_DATE('" & GlobalDictionary("FILTER" & i & "_VALUE2") & "', '" & sFormat &"')"	
						Case "REFERENCE"
							sSQL = sSQL & " and UPPER(document_reference) like UPPER('%" & UCase(GlobalDictionary("FILTER" & i & "_VALUE1")) & "%')"
						Case "AMOUNT"
							sSQL = sSQL & " and document_amount" & GlobalDictionary("FILTER" & i & "_VALUE1") & GlobalDictionary("FILTER" & i & "_VALUE2") 
						Case "CURRENCY"
							sSQL = sSQL & " and UPPER(document_currency) like UPPER('" & GlobalDictionary("FILTER" & i & "_VALUE1") & "')"
					End Select

					i = i + 1
				Wend
			
			Case "Disputes"

				'Loop for each filter 
				While GlobalDictionary("FILTER_BY" & i) <> "" 	 

					Select Case UCase(GlobalDictionary("FILTER_BY" & i))
						Case "INVOICE ID"
							sSQL = sSQL & " and UPPER(document_reference) like UPPER('%" & Ucase(GlobalDictionary("FILTER" & i & "_VALUE1")) & "%')"
						Case "DISPUTE DATE"
							sSQL = sSQL & " and dispute_date" & GlobalDictionary("FILTER" & i & "_VALUE1") & "To_DATE('" & GlobalDictionary("FILTER" & i & "_VALUE2") & "', '" & sFormat &"')"	
						Case "CASE NUMBER"
							sSQL = sSQL & " and UPPER(dispute_case_number) like UPPER('%" & GlobalDictionary("FILTER" & i & "_VALUE1") & "%')"
						Case "INVOICE AMOUNT"
							sSQL = sSQL & " and invoice_amount" & GlobalDictionary("FILTER" & i & "_VALUE1") & GlobalDictionary("FILTER" & i & "_VALUE2") 
						Case "DISPUTE AMOUNT"
							sSQL = sSQL & " and dispute_amount" & GlobalDictionary("FILTER" & i & "_VALUE1") & GlobalDictionary("FILTER" & i & "_VALUE2") 
						Case "CURRENCY"
							sSQL = sSQL & " and UPPER(currency) like UPPER('" & GlobalDictionary("FILTER" & i & "_VALUE1") & "')"
					End Select

					i = i + 1
				Wend

			Case "Alerts"

				'Loop for each filter 
				While GlobalDictionary("FILTER_BY" & i) <> "" 	 

					Select Case UCase(GlobalDictionary("FILTER_BY" & i))
						Case "ALERT DATE & TIME (GMT)"
                            sSQL = sSQL & " and TO_DATE(TO_CHAR(SENT_DATE,'" & sDateFormat & " " & sTimeFormat & "'),'" & sDateFormat & " " & sTimeFormat & "') = To_DATE('" & GlobalDictionary("FILTER" & i & "_VALUE2") & "', '" & sDateFormat & " " & sTimeFormat & "')"
						Case "SEVERITY"
							sSQL = sSQL & " and UPPER(SEVERITY) like UPPER('" & GlobalDictionary("FILTER" & i & "_VALUE1") & "')"
                    End Select

					i = i + 1
				Wend
	
		End Select

	End If

	'Add order(sort) to the tables
	If IsNull(sColumnToSort) Then
		sAddSort = fAddSortToSQL(sProtletName,null,null)
		sSQL = sSQL & sAddSort
	Else
		sTable = sProtletName
		Call fGetTableAndColumnName(sTable, sColumnToSort, null)
        sAddSort = fAddSortToSQL(sProtletName, sColumnToSort, sSortType)
		sSQL = sSQL & sAddSort
	End If

	sSQL = sSQL & ") WHERE rownum <= 15"
	
	reporter.ReportEvent micPass,"DB Validation - SQL query","Protlet: " & sProtletName & " SQL query: " & sSQL 
    fBuildSQL = sSQL

End Function
'###########################################################

'###########################################################
' Function name: fAddSortToSQL
' Description:  Add ORDER BY statement to SQL query.
' Parameters:	portlet name, column to sort by. 
'				If sColumnToSort = null -> no special sort - use default table order
'				Else add spectial sort by column sColumnToSort
' Return Value: sStr - String to add to the basic SQL
' Example:
'###########################################################
Public Function fAddSortToSQL(ByVal sProtletName, ByVal sColumnToSort, ByVal sSortType)

	Dim sStr
	sStr = " ORDER BY"

	If IsNull(sColumnToSort) Then 'No Special sort - use default table order

		'Add default initial order to the tables
		Select Case sProtletName
			Case "Unbilled Traffic"			
				sStr = sStr & " destination_name ASC"							
			Case "Open Transactions"
				sStr = sStr & " document_date DESC"
			Case "Invoices"
				sStr = sStr & " document_date DESC"
			Case "Payments / Credits"
				sStr = sStr & " document_date DESC"
			Case "Disputes"
				sStr = sStr & " dispute_date DESC"
			Case "Alerts" 
				sStr = sStr & " sent_date DESC"
		End Select

    Else
		'Add specific column to sort
    	sStr = sStr & " " & sColumnToSort & " " & left(sSortType, len(sSortType) - 6) 	
			
	End If

	'Add sort by PK
	Select Case sProtletName
		Case "Unbilled Traffic"		
			If lcase(sColumnToSort) = "currency" Then
        		sStr = sStr & ", Customer_id, Destination_id, Self_declare_flag"
			Else										
				sStr = sStr & ", Customer_id, Destination_id, Currency, Self_declare_flag"							
			End If
		Case "Open Transactions","Invoices","Payments / Credits" 
			sStr = sStr & ", Year,Company,Sap_document_number,Sap_document_line_item"
      	Case "Disputes"
			If lcase(sColumnToSort) = "dispute_case_number" Then
				sStr = sStr & ", Customer_id"		
			Else
				sStr = sStr & ", Customer_id, Dispute_case_number"
			End If		
	End Select

	fAddSortToSQL = sStr
End Function
'###########################################################

'###########################################################
' Function name: fGuiAccountInfo
' Description:  DB verification to the displayed data on the Account Info box on home page
' Parameters:	
' Return Value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiAccountInfo(ByVal iId)

	Dim sName, sID, sAddress, sAddressDB, sEmail, sPhone, sVatId, sSQL, bFound, arrInfo 
	bFound = True 

	'Add header to the Results Viewer report
	Reporter.ReportEvent micDone, "------fGuiAccountInfo------" ,"fGuiAccountInfo"

	'Get data from UI (Account Information box)
	arrInfo = Split(Browser("iBasis Customer Portal").Page("Finance").WebElement("Name").GetROProperty("outertext"),":")
	sName = arrInfo(1)
	If sName = "" OR sName = " " Then
		sName = NULL
	End If

	arrInfo = Split(Browser("iBasis Customer Portal").Page("Finance").WebElement("ID").GetROProperty("outertext"),":")
	sID = arrInfo(1)
	If sName = "" OR sName = " " Then
		sName = NULL
	End If

	arrInfo = Split(Browser("iBasis Customer Portal").Page("Finance").WebElement("Address").GetROProperty("outertext"),":")
	sAddress = arrInfo(1)
	If sAddress = "" OR sAddress = " " Then
		sAddress = NULL
	End If

	arrInfo = Split(Browser("iBasis Customer Portal").Page("Finance").WebElement("Email").GetROProperty("outertext"),":")
	sEmail = arrInfo(1)
	If sEmail = "" OR sEmail = " " Then
		sEmail = NULL
	End If

	arrInfo = Split(Browser("iBasis Customer Portal").Page("Finance").WebElement("Phone").GetROProperty("outertext"),":")
	sPhone = arrInfo(1)
	If sPhone = "" OR sPhone = " " Then
		sPhone = NULL
	End If

	arrInfo = Split(Browser("iBasis Customer Portal").Page("Finance").WebElement("VAT ID").GetROProperty("outertext"),":")
	sVatId = arrInfo(1)
	If sVatId = "" OR sVatId = " " Then
		sVatId = NULL
	End If

	'Build and exacute a SQL query to retrieve customer's account information
	sSQL = "SELECT NAME, ID, STREET2, CITY, STATE, POSTAL_CODE, COUNTRY, EMAIL, TELEPHONE, VAT_ID FROM " & SCHEMA & "CUSTOMER_MASTER WHERE ID = " & iId
	rc = fDBGetRS ("BILLING", sSQL, objRS)

	'Check fDBGetRS returned value
	If rc = False Then
		Reporter.ReportEvent micFail, "fGuiAccountInfo", "Protlet: Finance - Connetion to DB was failed."
		Call fWriteHtmlReportRow("fGuiAccountInfo-Finance", "Check the connection to DB", "FAIL","Connetion to DB was failed")
		fGuiAccountInfo = False
		Exit Function
    ElseIf rc = NO_RECORDS_FOUND Then
		Reporter.ReportEvent micWarning, "fGuiAccountInfo", "Protlet: Finance - No records returned by the query."
		Call fWriteHtmlReportRow("fGuiAccountInfo - Finance", "Check if records returned from DB", "INFO","No records returned by the query")
		fGuiAccountInfo = False
		Exit Function
	End If

	'Compare the values from UI with the values on DB
	If Trim(objRS.Fields("NAME").Value) <> Trim(sName) Then	
		reporter.ReportEvent micFail, "Compare info data from UI and DB - Finance Page", "Name - UI value: " & sName & " DB value: " & objRS.Fields("NAME")
		Call fWriteHtmlReportRow("AccountInfo - Finance", "Compare info data from UI and DB", "FAIL","Name - UI value: " & sName & " DB value: " & objRS.Fields("NAME"))
		bFound = False
	End If

	If Trim(CStr(objRS.Fields("ID").Value)) <> Trim(sID) Then	
		reporter.ReportEvent micFail, "Compare info data from UI and DB - Finance Page", "ID - UI value: " & sID & " DB value: " & objRS.Fields("ID")
		Call fWriteHtmlReportRow("AccountInfo - Finance", "Compare info data from UI and DB", "FAIL","ID - UI value: " & sID & " DB value: " & objRS.Fields("ID"))
		bFound = False
	End If

	sAddressDB = objRS.Fields("STREET2").Value & objRS.Fields("CITY").Value & objRS.Fields("STATE").Value & objRS.Fields("POSTAL_CODE").Value & objRS.Fields("COUNTRY").Value
	If Trim(replace(sAddressDB," ","")) <> Trim(replace(sAddress," ","")) Then	
		reporter.ReportEvent micFail, "Compare info data from UI and DB - Finance Page", "Address - UI value: " & sAddress & " DB value: " & sAddressDB
		Call fWriteHtmlReportRow("AccountInfo - Finance", "Compare info data from UI and DB", "FAIL","Address - UI value: " & sAddress & " DB value: " & sAddressDB)
        bFound = False
	End If

	If Trim(objRS.Fields("EMAIL").Value) <> Trim(sEmail) Then	
		reporter.ReportEvent micFail, "Compare info data from UI and DB - Finance Page" , "EMAIL - UI value: " & sEmail & " DB value: " & objRS.Fields("EMAIL")
		Call fWriteHtmlReportRow("AccountInfo - Finance", "Compare info data from UI and DB", "FAIL","EMAIL - UI value: " & sEmail & " DB value: " & objRS.Fields("EMAIL"))
		bFound = False
	End If

	If Trim(objRS.Fields("TELEPHONE").Value) <> Trim(sPhone) Then	
		reporter.ReportEvent micFail, "Compare info data from UI and DB - Finance Page", "TELEPHONE - UI value: " & sPhone & " DB value: " & objRS.Fields("TELEPHONE")
		Call fWriteHtmlReportRow("AccountInfo - Finance", "Compare info data from UI and DB", "FAIL","TELEPHONE - UI value: " & sPhone & " DB value: " & objRS.Fields("TELEPHONE"))
		bFound = False
	End If

	If Trim(objRS.Fields("VAT_ID").Value) <> Trim(sVatId) Then	
		reporter.ReportEvent micFail, "Compare info data from UI and DB - Finance Page", "VAT_ID - UI value: " & sVatId & " DB value: " & objRS.Fields("VAT_ID")
		Call fWriteHtmlReportRow("AccountInfo - Finance", "Compare info data from UI and DB", "FAIL","VAT_ID - UI value: " & sVatId & " DB value: " & objRS.Fields("VAT_ID"))
		bFound = False
	End If

	'All Account Info in UI equal to DB data
	If bFound = True Then
		reporter.ReportEvent micPass, "Compare info data from UI and DB - Finance Page", "All Account Info in UI equal to DB data"
		Call fWriteHtmlReportRow("AccountInfo - Finance", "Compare info data from UI and DB", "PASS","All Account Info in UI equal to DB data")
	End If


    fGuiAccountInfo = True
End Function
'###########################################################

'###########################################################
' Function name: fGuiCreditLimit
' Description: DB verification to the displayed limit on Credit Limit box on Finance page
' Parameters:	
' Return Value:  Success - True
'				 Failtue - False
' Example:
'###########################################################
Public Function fGetDBCreditLimit(ByVal iId, ByVal sDefaultCur)

		'Build and execute a SQL query to retrieve all credit limit of customer HQ and his children
		sSQL = "SELECT credit_limit, credit_currency FROM " & SCHEMA & "CUSTOMER_MASTER WHERE ID in(SELECT ID From " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters =" & iId &")"
		rc = fDBGetRS ("BILLING", sSQL, objRS)
	
		'Check fDBGetRS returned value
		If rc = False Then
			Reporter.ReportEvent micFail, "fGuiCreditLimit", "Protlet: Finance - Connetion to DB was failed."
			Call fWriteHtmlReportRow("fGuiCreditLimit-Finance", "Check the connection to DB", "FAIL","Connetion to DB was failed")
			fGuiCreditLimit = False
			Exit Function
		ElseIf rc = NO_RECORDS_FOUND Then
			Reporter.ReportEvent micWarning, "fGuiCreditLimit", "Protlet: Finance - No records returned by the query."
			Call fWriteHtmlReportRow("fGuiCreditLimit - Finance", "Check if records returned from DB", "INFO","No records returned by the query")
			fGuiCreditLimit = False
			Exit Function
		End If
	
		'Summarize all credit limit sums
		iSumCredit = 0
		objRS.MoveFirst
		While Not objRS.EOF
			iSumCredit = iSumCredit + fExchageRate(Cdbl(objRS.Fields("credit_limit").Value), objRS.Fields("credit_currency").Value, sDefaultCur)
			objRS.MoveNext
		Wend
		iSumCredit = Round(cdbl(iSumCredit),2)

		fGetDBCreditLimit = iSumCredit
End Function
'###########################################################

'###########################################################
' Function name: fGuiCreditLimit
' Description: DB verification to the displayed limit on Credit Limit box on Finance page
' Parameters:	
' Return Value:  Success - True
'				 Failtue - False
' Example:
'###########################################################
Public Function fGuiCreditLimit(ByVal iId)

	Dim sSQL, iSumCredit, sDefaultCur, iCreditLimit, arrCredit
	
	'Add header to the Results Viewer report
	Reporter.ReportEvent micDone, "------fGuiCreditLimit------" ,"fGuiCreditLimit"
	
	Call fGetReferenceVerificationData("DEFAULT_CURRENCY", sDefaultCur)
    
	iSumCredit = fGetDBCreditLimit(iId, sDefaultCur)

	'Get credit limit sum form UI
    iCreditLimit = Trim(Browser("iBasis Customer Portal").Page("Finance").WebElement("CreditLimit").GetROProperty("outertext"))
	iCreditLimit = Trim(left(iCreditLimit,len (iCreditLimit)-3))
	iCreditLimit = Round(cdbl(fConvertFormat(iCreditLimit)),2)



	'Compare the value form UI with the value from DB
	If iSumCredit =  iCreditLimit Then
		Reporter.ReportEvent micPass, "fGuiCreditLimit", "Protlet: Finance - Sum of Credit Limit in UI: " & iCreditLimit & ", equal to Credit Limit in DB: " & iSumCredit 
		Call fWriteHtmlReportRow("fGuiCreditLimit - Finance", "Calculate Sum of Credit Limit", "PASS","Sum of Credit Limit in UI: " & iCreditLimit & ", equal to Credit Limit in DB: " & iSumCredit )
	Else
		Reporter.ReportEvent micFail, "fGuiCreditLimit", "Protlet: Finance - Sum of Credit Limit in UI :" & iCreditLimit & ", NOT equal to Credit Limit in DB: " & iSumCredit
		Call fWriteHtmlReportRow("fGuiCreditLimit - Finance", "Calculate Sum of Credit Limit", "FAIL","Sum of Credit Limit in UI: " & iCreditLimit & ", equal to Credit Limit in DB: " & iSumCredit )
	End If

    fGuiCreditLimit = True 
End Function
'###########################################################

'###########################################################
' Function name: fGuiBalanceSummary
' Description: DB verification to the displayed Balance Summery box on Finance page
' Parameters:	
' Return Value:  Success - True
'				 Failtue - False
' Example:
'###########################################################
Public Function fGuiBalanceSummary(ByVal iId)

	Dim sSQL, sDefaultCur, iSumUnbilled, iSumBilled, arrBalance, iUnbilledUI, iBilledUI
	Dim iSumVendorOpenPo, iSumVendorBilled , iSumVendorUnbilled, iVendorTotalUI, iSumVendorTotal
	
	'Add header to the Results Viewer report
	Reporter.ReportEvent micDone, "------fGuiBalanceSummary------" ,"fGuiBalanceSummary"
	
	
	Call fGetReferenceVerificationData("DEFAULT_CURRENCY", sDefaultCur)
    
	'Build Unbilled Traffic query
	sSQL = "SELECT amount, currency FROM " & SCHEMA & "CUST_UNBILLED  WHERE SELF_DECLARE_FLAG = 0 AND CUSTOMER_ID in(SELECT ID From " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters = " & iId &")"
	rc = fDBGetRS ("BILLING", sSQL, objRsCustUnbilled)

	'Check fDBGetRS returned value
	If rc = False Then
		Reporter.ReportEvent micFail, "fGuiBalanceSummary - Unbilled", "Protlet: Finance - Connetion to DB was failed."
		Call fWriteHtmlReportRow("fGuiBalanceSummary-Unbilled", "Check the connection to DB", "FAIL","Connetion to DB was failed")
		fGuiBalanceSummary = False
    ElseIf rc = NO_RECORDS_FOUND Then
		Reporter.ReportEvent micWarning, "fGuiBalanceSummary - Unbilled", "Protlet: Finance - No records returned by the query."
		Call fWriteHtmlReportRow("fGuiBalanceSummary - Unbilled", "Check if records returned from DB", "INFO","No records returned by the query")
		fGuiBalanceSummary = False
	End If

	iSumUnbilled = 0
	If rc = True Then
		'Summarize all credit limit sums
		objRsCustUnbilled.MoveFirst
		While Not objRsCustUnbilled.EOF
			iSumUnbilled = iSumUnbilled + fExchageRate(Cdbl(objRsCustUnbilled.Fields("amount")), objRsCustUnbilled.Fields("currency"), sDefaultCur)
			objRsCustUnbilled.MoveNext
		Wend
	End If
	'iSumUnbilled = Round(cdbl(iSumUnbilled),2)

	'Get Unbilled balance sum form UI
	iUnbilledUI = Browser("iBasis Customer Portal").Page("Finance").WebElement("Unbilled Balance").GetROProperty("innertext")
	iUnbilledUI = Trim(Left(Trim(iUnbilledUI),Len(iUnbilledUI)-3))
	iUnbilledUI = fConvertFormat(iUnbilledUI)

	'Compare the value form UI with the value from DB
	If Round(cdbl(iSumUnbilled),2) = iUnbilledUI Then
		Reporter.ReportEvent micPass, "fGuiBalanceSummary - Unbilled", "Protlet: Finance - Sum of Unbilled Balance in UI: " & iUnbilledUI & ", equal to Unbilled Balance in DB: " & Round(cdbl(iSumUnbilled),2) 
		Call fWriteHtmlReportRow("fGuiBalanceSummary - Unbilled", "Compare the value form UI to DB", "PASS","Sum of Unbilled Balance in UI: " & iUnbilledUI & ", equal to Unbilled Balance in DB: " & Round(cdbl(iSumUnbilled),2) )
	Else
		Reporter.ReportEvent micFail, "fGuiBalanceSummary - Unbilled", "Protlet: Finance - Sum of Unbilled Balance in UI :" & iUnbilledUI & ", NOT equal to Unbilled Balance in DB: " & Round(cdbl(iSumUnbilled),2)
		Call fWriteHtmlReportRow("fGuiBalanceSummary - Unbilled", "Compare the value form UI to DB", "FAIL","Sum of Unbilled Balance in UI: " & iUnbilledUI & ", Not equal to Unbilled Balance in DB: " & Round(cdbl(iSumUnbilled),2) )
	End If

'	-----------------
	'Build Billed Transactions query
	sSQL = "SELECT DOCUMENT_AMOUNT,DOCUMENT_CURRENCY FROM " & SCHEMA & "CUSTOMER_BILLED_TRANS  WHERE CUSTOMER_ID in(SELECT ID From " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters = " & iId &")"
		rc = fDBGetRS ("BILLING", sSQL, objRsCustBilled)

	'Check fDBGetRS returned value
	If rc = False Then
		Reporter.ReportEvent micFail, "fGuiBalanceSummary - Billed", "Protlet: Finance - Connetion to DB was failed."
		Call fWriteHtmlReportRow("fGuiBalanceSummary-Billed", "Check the connection to DB", "FAIL","Connetion to DB was failed")
		fGuiBalanceSummary = False
    ElseIf rc = NO_RECORDS_FOUND Then
		Reporter.ReportEvent micWarning, "fGuiBalanceSummary - Billed", "Protlet: Finance - No records returned by the query."
		Call fWriteHtmlReportRow("fGuiCreditLimit - Billed", "Check if records returned from DB", "INFO","No records returned by the query")
		fGuiBalanceSummary = False
	End If

 	iSumBilled = 0
	If rc = True Then
		'Summarize all credit limit sums
		objRsCustBilled.MoveFirst
		While Not objRsCustBilled.EOF
			iSumBilled = iSumBilled + fExchageRate(Cdbl(objRsCustBilled.Fields("DOCUMENT_AMOUNT")), objRsCustBilled.Fields("DOCUMENT_CURRENCY"), sDefaultCur)
			objRsCustBilled.MoveNext
		Wend
	End If

	'iSumBilled = Round(cdbl(iSumBilled),2)

    'Get Billed balance sum form UI
	iBilledUI = Browser("iBasis Customer Portal").Page("Finance").WebElement("Billed Trans Balance").GetROProperty("innertext")
	iBilledUI = Trim(Left(Trim(iBilledUI),Len(iBilledUI)-3))
	iBilledUI = fConvertFormat(iBilledUI)

	'Compare the value form UI with the value from DB
	If Round(cdbl(iSumBilled),2) = iBilledUI Then
		Reporter.ReportEvent micPass, "fGuiBalanceSummary - Billed", "Protlet: Finance - Sum of Billed Balance in UI: " & iBilledUI & ", equal to Billed Balance in DB: " & Round(cdbl(iSumBilled),2) 
		Call fWriteHtmlReportRow("fGuiBalanceSummary - Billed", "Compare the value form UI to DB", "PASS","Sum of Billed Balance in UI: " & iBilledUI & ", equal to Billed Balance in DB: " & Round(cdbl(iSumBilled),2) )
	Else
		Reporter.ReportEvent micFail, "fGuiBalanceSummary - Billed", "Protlet: Finance - Sum of Billed Balance in UI :" & iBilledUI & ", NOT equal to Billed Balance in DB: " & Round(cdbl(iSumBilled),2)
		Call fWriteHtmlReportRow("fGuiBalanceSummary - Billed", "Compare the value form UI to DB", "FAIL","Sum of Billed Balance in UI: " & iBilledUI & ", Not equal to Billed Balance in DB: " & Round(cdbl(iSumBilled),2) )
	End If

' 	-------------------

	'Get Total balance sum form UI
	iTotalUI = Browser("iBasis Customer Portal").Page("Finance").WebElement("Total Balance").GetROProperty("innertext")
	iTotalUI = Trim(Left(Trim(iTotalUI),Len(iTotalUI)-3))
	iTotalUI = cdbl(fConvertFormat(iTotalUI))

	'Compare the value form UI with the value from DB
	If Round(iSumBilled + iSumUnbilled,2) = iTotalUI Then
		Reporter.ReportEvent micPass, "fGuiBalanceSummary - Total", "Protlet: Finance - Sum of Total Balance in UI: " & iTotalUI & ", equal to sum of Unbilled + Billed Balance on DB: " & Round(iSumBilled + iSumUnbilled,2)
		Call fWriteHtmlReportRow("fGuiBalanceSummary - Total", "Compare the value form UI to DB", "PASS","Sum of Total Balance in UI: " & iTotalUI & ", equal to sum of Unbilled + Billed Balance on DB: " & Round(iSumBilled + iSumUnbilled,2) )
	Else
		Reporter.ReportEvent micFail, "fGuiBalanceSummary - Total", "Protlet: Finance - Sum of Total Balance in UI :" & iTotalUI & ", NOT equal to sum of Unbilled + Billed Balance on DB: " & Round(iSumBilled + iSumUnbilled,2)
		Call fWriteHtmlReportRow("fGuiBalanceSummary - Total", "Compare the value form UI to DB", "FAIL","Sum of Total Balance in UI: " & iTotalUI & ",Not equal to sum of Unbilled + Billed Balance on DB: " & Round(iSumBilled + iSumUnbilled,2) )
	End If

	'-------------------------------------------------------------------------------
	'-------------------------Calculate Total for vendor----------------------------
	'-------------------------------------------------------------------------------

    sSQL = "select sum(AmountInUSDollar) " & _ 
	"from ( " & _ 
		"select currency,sum(amount) as amount,sum(amount) * nvl((select rate from " & SCHEMA & "EXCHANGE_RATE e where e.FROM_CURRENCY = amount_sum_by_currency.currency and e.TO_CURRENCY = '"& sDefaultCur &"'),1) as AmountInUSDollar " & _
		"from( " & _
			"select v.amount, v.currency from " & SCHEMA & "VENDOR_BILLED_SUMMARY v where vendor_id in (select vendor_id from " & SCHEMA & "vendor_master where headquarters in(select distinct vendor_id from " & SCHEMA & "customer_master where id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS= "& iId & ")) or vendor_id in (select distinct vendor_id from " & SCHEMA & "customer_master where id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS= "& iId & "))) " & _ 
			"UNION ALL select v.amount, v.currency from " & SCHEMA & "VEND_UNBILLED v where vendor_id in (select vendor_id from " & SCHEMA & "vendor_master where headquarters in(select distinct vendor_id from " & SCHEMA & "customer_master where id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS= "& iId & ")) or vendor_id in (select distinct vendor_id from " & SCHEMA & "customer_master where id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS= "& iId & "))) " & _
			"UNION ALL select v.amount, v.currency from " & SCHEMA & "VENDOR_OPEN_PO_BALANCE v where vendor_id in (select vendor_id from " & SCHEMA & "vendor_master where headquarters in(select distinct vendor_id from " & SCHEMA & "customer_master where id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS= "& iId & ")) or vendor_id in (select distinct vendor_id from " & SCHEMA & "customer_master where id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS= "& iId & "))) " & _
			") amount_sum_by_currency " & _
	"group by currency " & _ 
	") amount_sum_in_us_dollar"	

	rc = fDBGetOneValue("BILLING", sSQL, iSumVendorTotal)

    'iSumVendorTotal = fExchageRate(iSumVendorTotal, "USD", sDefaultCur)
	iSumVendorTotal = Round(Cdbl(iSumVendorTotal),2)
	   
	iVendorTotalUI = Browser("iBasis Customer Portal").Page("Finance").WebElement("Total Vendor").GetROProperty("innertext")
	iVendorTotalUI = Trim(Left(Trim(iVendorTotalUI),Len(iVendorTotalUI)-3))
	iVendorTotalUI = fConvertFormat(iVendorTotalUI)

	'Compare the value form UI with the value from DB
	If iSumVendorTotal = iVendorTotalUI Then
		Reporter.ReportEvent micPass, "fGuiBalanceSummary - VendorTotal", "Protlet: Finance - Sum of Vendor Total in UI: " & iVendorTotalUI & ", equal to sum of VENDOR billed, unbilled, open_po and self_declare on DB: " & iSumVendorTotal 
		Call fWriteHtmlReportRow("fGuiBalanceSummary - VendorTotal", "Compare the value form UI to DB", "PASS","Sum of Vendor Total in UI: " & iVendorTotalUI & ", equal to sum of VENDOR billed, unbilled, open_po and self_declare on DB: " & iSumVendorTotal)
	Else
		Reporter.ReportEvent micFail, "fGuiBalanceSummary - VendorTotal", "Protlet: Finance - Sum of Vendor Total in UI :" & iVendorTotalUI & ", NOT equal to sum of VENDOR billed, unbilled, open_po and self_declare on DB: " & iSumVendorTotal 
		Call fWriteHtmlReportRow("fGuiBalanceSummary - VendorTotal", "Compare the value form UI to DB", "FAIL","Sum of Vendor Total in UI: " & iVendorTotalUI & ",Not equal to sum of VENDOR billed, unbilled, open_po and self_declare on DB: " & iSumVendorTotal)
	End If

	'-------------------------------------------------------------------------------
	'----------------------------- Available Credit --------------------------------
	'-------------------------------------------------------------------------------
	iSumCredit = fGetDBCreditLimit(iId, sDefaultCur)
	iExposure = fGetIBasisExposure(iId)
	iExposure = fExchageRate(iExposure, "USD", sDefaultCur)
	iAvailableCreditDB = Round(iSumCredit - iExposure,2)

	'Get Available Credit from UI
	sAvailableCreditUI = Browser("iBasis Customer Portal").Page("Finance").WebElement("Available Credit").GetROProperty("innertext")
	sAvailableCreditUI = Trim(Left(Trim(sAvailableCreditUI),Len(sAvailableCreditUI)-3))
	sAvailableCreditUI = fConvertFormat(sAvailableCreditUI)

	'Compare the value form UI with the value from DB
	If iAvailableCreditDB = sAvailableCreditUI Then
		Reporter.ReportEvent micPass, "fGuiBalanceSummary - AvailableCredit", "Protlet: Finance - Sum of Available Credit in UI: " & sAvailableCreditUI & ", equal to sum of Available Credit on DB: " & iAvailableCreditDB 
		Call fWriteHtmlReportRow("fGuiBalanceSummary - AvailableCredit", "Compare the value form UI to DB", "PASS","Sum of Available Credit in UI: " & sAvailableCreditUI & ", equal to sum of Available Credit on  DB: " & iAvailableCreditDB )
	Else
		Reporter.ReportEvent micFail, "fGuiBalanceSummary - AvailableCredit", "Protlet: Finance - Sum of Available Credit in UI :" & sAvailableCreditUI & ", NOT equal to sum of Available Credit on DB: " & iAvailableCreditDB 
		Call fWriteHtmlReportRow("fGuiBalanceSummary - AvailableCredit", "Compare the value form UI to DB", "FAIL","Sum of Available Credit in UI: " & sAvailableCreditUI & ",Not equal to sum of Available Credit on DB: " & iAvailableCreditDB )
	End If

	fGuiBalanceSummary = True
End Function
'###########################################################

'###########################################################
' Function name: fGuiRecentAlert
' Description: DB verification to the displayed RecentAlert for the current customer
' Parameters:	
' Return Value:  Success - True
'				 Failtue - False
' Example:
'###########################################################
Public Function fGuiRecentAlert(ByVal iId)

	Dim sSQL, sFormat, sTimeFormat
	
	sFormat = "dd-mon-yy" ' GlobalDictionary("DATE_FORMAT") 
	'sTimeFormat = "HH:MM" ' GlobalDictionary("TIME_FORMAT") 

	sSQL = "SELECT TO_CHAR(SENT_DATE, '" & sFormat & " HH:MI') as SENT_DATE, SEVERITY, MESSAGE FROM " & SCHEMA & "CUSTOMER_ALERT_HISTORY WHERE customer_id in(SELECT ID FROM " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters = " & iId &")" 

	rc = fGuiDBValidations("Finance", sSQL)
	If rc <> True Then
		Reporter.ReportEvent micFail, "Check Recent Alert Table", "DB validation for Recent Alert table failed"
		Call fWriteHtmlReportRow("RecentAlert", "Check Recent Alert Table", "FAIL","DB validation for Recent Alert table failed")
		fGuiRecentAlert = False
		Exit Function
	End If

    Reporter.ReportEvent micPass, "Check Recent Alert Table", "DB validation for Recent Alert table succeeded"
	Call fWriteHtmlReportRow("RecentAlert", "Check Recent Alert Table", "PASS","DB validation for Recent Alert table succeeded")
	
    fGuiRecentAlert = True
End Function
'###########################################################

''###########################################################
'' Function name: fGuiDBValidations
'' Description:  Check all DB Validations, Using a SQL query
'' Parameters:	Protlet Name, SQL query
'' Return value:  Success - True
'' Example:
''###########################################################
Public Function fGuiDBValidations_old (ByVal sProtletName, ByVal sSQL)
'
'  	Dim i, j, iRowCount, iColCount, iRowCountDB, sCellDataUI, sCellDataDB, bFound, arrDate, rc, iCountOfRows
'	bFound = True
'
'    'Gets a RS, using a SQL query
'	rc = fDBGetRS ("BILLING", sSQL, objRS) 
'
'	'Check fDBGetRS returned value
'	If rc = False Then						'DB Connection failed
'		Reporter.ReportEvent micFail, "fGuiDBValidations - "& sProtletName, "Protlet: " & sProtletName & " - Connetion to DB was failed."
'		fGuiDBValidations = False
'		Exit Function		
'    ElseIf rc = NO_RECORDS_FOUND Then		'NO_RECORDS_FOUND
'		Reporter.ReportEvent micWarning, "fGuiDBValidations - "& sProtletName, "Protlet: " & sProtletName & " - No records returned by the query."
'		fGuiDBValidations = True
'		Exit Function
'	End If
'
'	
'	'Count the Rows of the RS
'   	iRowCountDB = 0
'	objRS.MoveFirst
'	While Not objRS.EOF
'		iRowCountDB = iRowCountDB +1
'		objRS.MoveNext
'	Wend
'
'	wait(3)	
'	'Gets Rows/Columns count on UI
'	iRowCount = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").RowCount
'	iColCount = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").ColumnCount(1)
'    wait(3)	
'
'	'Handling main table in protlet
'    If iRowCount = iRowCountDB Then
'		objRS.MoveFirst
'		For i = 1 To iRowCount 
'
'			sStrObjRS = ""
'			For j = 1 To iColCount
'				sCellDataUI = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").GetCellData(i, j)
'
'                'Change string to double for Numeric columns
'				If IsNumeric(sCellDataUI) Then
'					sCellDataUI = cdbl(sCellDataUI)
'				'Change date format for Date columns
'				ElseIf isDate(sCellDataUI) Then	
'					sCellDataUI =Cdate(sCellDataUI) 
'				Else
'					sCellDataUI = Trim(sCellDataUI)
'				End If
'
'				If Not(IsNumeric(sCellDataUI)) Then
'					sCellDataUI = "'" & sCellDataUI & "'"
'				End If
'
'				
'				sStrObjRS = sStrObjRS & objRS.Fields(j-1).Name & " = " & sCellDataUI
'				If j <> iColCount Then
'                   sStrObjRS = sStrObjRS & " AND "
'        		End If
'			Next
'
'			objRS.Filter = sStrObjRS
'
'			'Count the Rows of the RS
'			iCountOfRows = 0
'			objRS.MoveFirst
'			While Not objRS.EOF
'				iCountOfRows = iCountOfRows +1
'				objRS.MoveNext
'			Wend
'
'			If iCountOfRows <= 0 Then
'				Reporter.ReportEvent micFail, "fGuiDBValidations", "Protlet: " & sProtletName & " Row number: " & i & " in UI was not found in DB"
'			End If
'
'			objRS.Filter = 0
'            objRS.MoveNext
'		Next
'	End If
'
'
'	fGuiDBValidations = True
'
End Function
''###########################################################

'###########################################################
' Function name: fGuiOrganizationDefaults
' Description:  Save to KEEP_REFER all organization's defaults
' Parameters: 
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiOrganizationDefaults

	Dim sDefaultCurrency, sCurrencyFormat, sDateFormat, sTimeFormat, sEmailInfoAlerts, sEmailWarningAlerts

	'Navigate to "Admin" protlet	
	Browser("iBasis Customer Portal").Page("Home").Link("Admin").Click
	If Browser("iBasis Customer Portal").Page("Admin").Exist(30) = "False" Then
		Call fReport("fGuiOrganizationDefaults",  "Navigate to the Admin protlet", "FAIL", "Failed to Navigate the protlet :Admin", 0)
		Exit Function
	End If
	If fSyncByImage(60) = False Then
		Call fReport("fGuiOrganizationDefaults",  "Sync for data refresh (fSyncByImage)", "FAIL", "Sync failed after 60 seconds", 0)
		Exit Function
	End If

	'Get organization's defaults from UI
	sDefaultCurrency = Browser("iBasis Customer Portal").Page("Admin").WebEdit("View Currency").GetROProperty("Value")
	sCurrencyFormat = Browser("iBasis Customer Portal").Page("Admin").WebEdit("Currency Format").GetROProperty("Value")
	sDateFormat = Browser("iBasis Customer Portal").Page("Admin").WebEdit("Date Format").GetROProperty("Value")
	sTimeFormat = Browser("iBasis Customer Portal").Page("Admin").WebEdit("Time Format").GetROProperty("Value")

	Browser("iBasis Customer Portal").Page("Admin").WebElement("My Account").Click
	'Sync
	If Browser("iBasis Customer Portal").Page("Admin").WebElement("My Account_Header").Exist(10) = "False" Then
		Reporter.ReportEvent micFail, "fGuiOrganizationDefaults", "My Account window was not opened"		
		Call fReport("fGuiOrganizationDefaults",  "Open My Account window", "FAIL", "My Account window was not opened", 0)
		Exit Function
	End If

	If Browser("iBasis Customer Portal").Page("Admin").WebCheckBox("Custom Currency:").GetROProperty("Checked") = 1 Then
		sDefaultCurrency = Browser("iBasis Customer Portal").Page("Admin").WebEdit("Custom Currency").GetROProperty("Value")		
	End If

	If Browser("iBasis Customer Portal").Page("Admin").WebCheckBox("Custom Currency Format:").GetROProperty("Checked") = 1 Then
		sCurrencyFormat = Browser("iBasis Customer Portal").Page("Admin").WebEdit("Custom Currency Format:").GetROProperty("Value")		
	End If

	If Browser("iBasis Customer Portal").Page("Admin").WebCheckBox("Custom Time Format:").GetROProperty("Checked") = 1 Then
		sTimeFormat = Browser("iBasis Customer Portal").Page("Admin").WebEdit("Custom Time Format:").GetROProperty("Value")
	End If

	If Browser("iBasis Customer Portal").Page("Admin").WebCheckBox("Date Format:").GetROProperty("Checked") = 1 Then
		sDateFormat = Browser("iBasis Customer Portal").Page("Admin").WebEdit("Custom Date Format").GetROProperty("Value")
	End If

	'Set Time Format
	Select Case uCase(sTimeFormat)
		Case "HH:MM"
			sTimeFormat = "HH:MI"
		Case "HH:MM AM/PM"
			sTimeFormat = "HH:MI AM"
	End Select

	'Set Date Format
	Select Case (sDateFormat)
		Case "dd-MMM-yy"
			sDateFormat = "dd-Mon-yy"
		Case "MM/dd/yy"
            sDateFormat = "MM/dd/yy"
	End Select

	'Save organization's defaults to KEEP_REFER sheet
	Call SetReferenceVerificationData("DEFAULT_CURRENCY", sDefaultCurrency)

	Call SetReferenceVerificationData("CURRENCY_FORMAT", sCurrencyFormat)

	Call SetReferenceVerificationData("DATE_FORMAT", sDateFormat)

    Call SetReferenceVerificationData("TIME_FORMAT", sTimeFormat)

	'Close My Account window
	Browser("iBasis Customer Portal").Page("Admin").WebElement("Cancel").Click

	'Report 
	Call fReport("fGuiOrganizationDefaults", "Save the defaults formats to the KEEP_REFER sheet in the excel parameters", "PASS", "Saving the defaults formats to KEEP_REFER succeeded", 0)
	
End Function
'###########################################################

'###########################################################
' Function name: fReport
' Description: The function writes row to the HTML Report
' Parameters: sStepName, sStepDesc, sStatus, sStatusReason, iReportTo
'				sStatus: "PASS" / "FAIL" / "INFO" / "" (- for header etc.)
'				iReportTo: 0 = Both, 1 = Only QTP report, 2 = Only HTML report
' Return value: 
' Example:
'###########################################################
Public Function fReport(ByVal sStepName, ByVal sStepDesc, ByVal sStatus, ByVal sStatusReason, ByVal iReportTo)

	If iReportTo <> 2 Then
		'Write to QTP resutls report
		Select Case sStatus
			Case uCase("PASS")
				Reporter.ReportEvent micPass, sStepName, sStatusReason
			Case uCase("FAIL")
				Reporter.ReportEvent micFail, sStepName, sStatusReason
			Case uCase("INFO")
				Reporter.ReportEvent micWarning, sStepName, sStatusReason
		End Select
	End If

	If iReportTo <> 1 Then
		'Write to HTML results Report
		Call fWriteHtmlReportRow(sStepName, sStepDesc, sStatus, sStatusReason)
	End If

End Function
'###########################################################

'###########################################################
' Function name: fCheckCurrencyFormat
' Description:  The function checks if sNum is in sStrFormat
' Parameters: Currency format (string), number (string)
' Return value:  The number is in the right format - True
'				 The number is NOT in the right format - False
' Example: 	strFormat = "(x,xxx.yy)", sNum = "(1,200,002.12)" => True
'			strFormat = "(x,xxx.yy)", sNum = "-1,200,002.120" => False
'###########################################################

'strFormat = "(x.xxx,yy)"
'sNum = "102.12"
'Call fCheckCurrencyFormat(strFormat, sNum)

Public Function fCheckCurrencyFormat(ByVal strFormat, ByVal sNum)

	Dim sFormatSign, sSeperator, sDec, arrNum

	sFormatSign = Left(strFormat,1)
	sSeperator = Right(Left(strFormat,3),1)
	
	If sFormatSign = "(" Then
		sDec = Left(Right(strFormat,4),1)
	Else
		sDec = Left(Right(strFormat,3),1)
	End If
	
	'Check If Negative
	If Left(sNum,1) = "-" OR Left(sNum,1) = "(" Then
		If Left(sNum,1) <> sFormatSign Then
			fCheckCurrencyFormat = False
			Exit Function
			'msgbox "negative sign - False"
		End If
		If sFormatSign = "(" Then
			If Right(sNum,1) <> ")" Then
				fCheckCurrencyFormat = False
				Exit Function
				'msgbox "negative sign - False"
			End If
			sNum = Left(sNum, Len(sNum)-1)
		End If
		sNum = Right(sNum, Len(sNum)-1)
	End If
	
	'Check num of digits after the decimal
	If instr(1, sNum, sDec) Then
		arrNum = Split(sNum,sDec)

		If Len(arrNum(1)) > 2 Then
			fCheckCurrencyFormat = False
			Exit Function
			'msgbox "digits after decimal - False"
		End If
	
		sNum = arrNum(0)
	End If


	'Check the number's thousands separator
	If Len(sNum) > 3 Then
		arrNum = split(sNum, sSeperator)
		If Len(arrNum(0)) > 3 Then
			fCheckCurrencyFormat = False
			Exit Function
			'msgbox "thousands separator - False"
		End If
		For i = 1 To UBound(arrNum)
			If Len(arrNum(i)) <> 3 Then
				fCheckCurrencyFormat = False
				Exit Function
				'msgbox "thousands separator - False"
				Exit For
			End If
		Next
	End If

	'msgbox "True"
	fCheckCurrencyFormat = True
End Function
'###########################################################

'###########################################################
' Function name: fCheckDateFormat
' Description:  The function checks if sDate is in StrFormat
' Parameters: Date format (string), date (string)
' Return value:  The date is in the right format - True
'				 The date is NOT in the right format - False
' Example: 	strFormat = "mm/dd/yy", sDate = "10/03/11" => True
'			strFormat = "mm/dd/yy", sDate = "10.03.2011" => False
'###########################################################

'strFormat = "mm/dd/yy"
'sDate = "10/03/03"
'Call fCheckDateFormat(strFormat, sDate)

Public Function fCheckDateFormat(ByVal strFormat, ByVal sDate)

   Dim arrDate

	Select Case strFormat

		Case "dd-mmm-yy"
			arrDate = Split(sDate, "-")
			If UBound(arrDate) <> 2 Then
				fCheckDateFormat = False
				Exit Function
				'msgbox "Invalid Date - False"
			End If
			If Len(arrDate(0)) <> 2 OR cint(arrDate(0)) <> Day(sDate) Then
				fCheckDateFormat = False
				Exit Function
				'msgbox "day - False"
			End If
			If Len(arrDate(1)) <> 3 OR arrDate(1) <> MonthName(Month(sDate),True) Then
				fCheckDateFormat = False
				Exit Function
				'msgbox "month - False"
			End If
			If Len(arrDate(2)) <> 2 OR arrDate(2) <> Right(Year(sDate),2) Then
				fCheckDateFormat = False
				Exit Function
				'msgbox "year - False"
			End If
	

		Case "mm/dd/yy"
			arrDate = Split(sDate, "/")
			If UBound(arrDate) <> 2 Then
				fCheckDateFormat = False
				Exit Function
				'msgbox "Invalid Date - False"
			End If
			If Len(arrDate(1)) <> 2 OR cint(arrDate(1)) <> Day(sDate) Then
				fCheckDateFormat = False
				Exit Function
				'msgbox "month - False"
			End If
			If Len(arrDate(0)) <> 2 OR cint(arrDate(0)) <> Month(sDate) Then
				fCheckDateFormat = False
				Exit Function
				'msgbox "day - False"
			End If
			If Len(arrDate(2)) <> 2 OR arrDate(2) <> Right(Year(sDate),2) Then
				fCheckDateFormat = False
				Exit Function
				'msgbox "year - False"
			End If

	End Select

	'msgbox "True"
	fCheckDateFormat = True
End Function

'###########################################################
' Function name: fGuiCheckDefaults
' Description:  Compare in each protlet the default values from 
				'Organization Defaults in Admin protlet 
' Parameters:  Protlet Name,
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiCheckDefaults()

	Dim sDefaultCurrency, iColumnCount, iRowCount, i, j, k, sProtletName, sCellData, sGrandData
	Dim bDefaultCurrency, bCurrencyFormat, bDateFormat
	bDefaultCurrency = True
	bCurrencyFormat = True
	bDateFormat = True
	Dim curFormat

	Call fGetReferenceVerificationData("CURRENCY_FORMAT", curFormat)
	Call fGetReferenceVerificationData("DEFAULT_CURRENCY", defaultCur)
	Call fGetReferenceVerificationData("DATE_FORMAT", dateFormat)

	i =1
	While globaldictionary("PROTLET_NAME" & i)<> ""

		sProtletName = globaldictionary("PROTLET_NAME" & i)
		
		Browser("iBasis Customer Portal").Page("Home").Link("Finance").FireEvent "OnMouseOver"
		Browser("iBasis Customer Portal").Page("Home").Link(sProtletName).Click
		If Browser("iBasis Customer Portal").Page(sProtletName).Exist(30) = "False" Then
			Reporter.ReportEvent micFail, "fGuiCheckDefaults", "Failed to Navigate the protlet: " & sProtletName
			Call fWriteHtmlReportRow("fGuiCheckDefaults -" & sProtletName, "Navigate to the protlet", "FAIL", "Failed to Navigate the protlet: " & sProtletName)
			fGuiCheckDefaults = False
			Exit Function
		End If
		If fSyncByImage(60) = False Then
			Reporter.ReportEvent micFail, "fGuiCheckDefaults", "Failed to Navigate the protlet: " & sProtletName
			Call fWriteHtmlReportRow("fGuiCheckDefaults -" & sProtletName, "sync for refresh data", "FAIL", "sync failed after 60 seconds")
			fGuiCheckDefaults = False
			Exit Function
		End If

		
		
		'Check if grand total displayed currencies are equal to Default Currency
		iColumn = fGetColumnIndexByName(sProtletName,"CURRENCY")
		sDefaultCurrency = Browser("iBasis Customer Portal").Page(sProtletName).WebTable("Grand Total").GetCellData(1,iColumn)
		If sDefaultCurrency <> defaultCur Then
			Reporter.ReportEvent micFail, "fGuiCheckDefaults - Default Currency", "Protlet: " & sProtletName & ", Displayed currency: " & sDefaultCurrency & " is not equal to Default Currency: " & defaultCur
			Call fWriteHtmlReportRow("Check Defaults" , "Compare the Default Currency in protlet: " & sProtletName & " to Organization-DefaultCurrency", "FAIL", "Displayed currency: " & sDefaultCurrency & " is not equal to Default Currency: " & defaultCur)
			bDefaultCurrency = False
		End If
	

		'Check if currencies format in all protlets are equal to default currency format
        iColumnCount = Browser("iBasis Customer Portal").Page(sProtletName).WebTable("Grand Total").ColumnCount(1)
		iRowCount = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").RowCount

		If iRowCount = 0 Then
			Reporter.ReportEvent micWarning, "fGuiCheckDefaults - "& sProtletName, "Protlet: " & sProtletName & " - No records found on UI"
			Call fWriteHtmlReportRow("Check Defaults - "& sProtletName, "Check if there is data on UI", "INFO","No records found on UI")			
		End If
	
		If iRowCount > 15 Then
			iRowCount = 15
		End If

		If iRowCount > 0 Then
		
			For j = 1 To iColumnCount
				
				sCellData = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").GetCellData(1,j)
				'sGrandData = Browser("iBasis Customer Portal").Page(sProtletName).WebTable("Grand Total").GetCellData(1,j)
				sHeadData = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Headers").GetCellData(1,j)
				If  IsNumeric(sCellData) and Ucase(sHeadData) <> "MINUTES / MESSAGE" and Ucase(sHeadData) <> "REFERENCE" and Ucase(sHeadData) <> "INVOICE ID" and Ucase(sHeadData) <> "CASE NUMBER" and instr(1,Ucase(sHeadData),"CONVERSION") = 0 Then
					For k = 1 To iRowCount
						sCellData = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").GetCellData(k,j)
						If fCheckCurrencyFormat(curFormat, sCellData) <> True Then
							Reporter.ReportEvent micFail, "fGuiCheckDefaults - fCheckCurrencyFormat", "Protlet: " & sProtletName & ", Row: " & k & ", Column: " & j & " - Currency format is NOT equal to defalut curreny format: " & curFormat
							Call fWriteHtmlReportRow("Check Defaults" , "Compare the Default Currency format in protlet: " & sProtletName & " to Organization-DefaultCurrencyFormat", "FAIL", " Row: " & k & ", Column: " & j & " - Currency format is NOT equal to defalut curreny format: " & curFormat)
							bCurrencyFormat = False
						End If
					Next
				
			'Check if date format in all protlets are equal to default date format
				
				ElseIf  Instr(1,Ucase(sHeadData),"DATE") > 0 Then
					For k = 1 To iRowCount
						sCellData = Browser("iBasis Customer Portal").Page(sProtletName).WebTable(sProtletName & " Table").GetCellData(k,j)
						If fCheckDateFormat(dateFormat, sCellData) <> True Then
							Reporter.ReportEvent micFail, "fGuiCheckDefaults - fCheckDateFormat", "Protlet: " & sProtletName & ", Row: " & k & ", Column: " & j & " - Currency format is NOT equal to defalut curreny format: " & curFormat
							Call fWriteHtmlReportRow("Check Defaults" , "Compare the Date Format to Organization-DefaultDateFormat", "FAIL", "Row: " & k & ", Column: " & j & " - Currency format is NOT equal to defalut curreny format: " & curFormat)
							bDateFormat = False
						End If
					Next
				End If
			Next
		End If
		Browser("iBasis Customer Portal").Page(sProtletName).Link("Welcome").Click
		i = i + 1
	Wend

	If bDefaultCurrency = True Then
		Reporter.ReportEvent micPass, "fGuiCheckDefaults", "All grand total displayed currencies are equal to Default Currency: " & defaultCur
		Call fWriteHtmlReportRow("Check Defaults" , "Compare the Default Currency to Organization-DefaultCurrency", "PASS", "All grand total displayed currencies are equal to Default Currency: " & defaultCur)
	End If

	If bCurrencyFormat = True Then
		Reporter.ReportEvent micPass, "fGuiCheckDefaults", "All values in all currency cloumns are equal to Default Currency format: " & curFormat
		Call fWriteHtmlReportRow("Check Defaults" , "Compare the Default Currency Format to Organization-DefaultCurrencyFormat", "PASS", "All values in all currency cloumns are equal to Default Currency format: " & curFormat)
	End If

	If bDateFormat = True Then
		Reporter.ReportEvent micPass, "fGuiCheckDefaults", "All values in all date cloumns are equal to Default Date format: " & dateFormat
		Call fWriteHtmlReportRow("Check Defaults" , "Compare the Date Format to Organization-DefaultDateFormat", "PASS", "All values in all date cloumns are equal to Default Date format: " & dateFormat)
	End If

	fGuiCheckDefaults = True
End Function
'##############################################################

'###########################################################
' Function name: fConvertFormat
' Description:  Converts number in format -x.xxx,yy OR (x.xxx,yy) 
'								to format -x,xxx.yy OR (x,xxx.yy)
' Parameters:  number(string) in format -x.xxx,yy OR (x.xxx,yy)
' Return value:  Success - The converted number
' Example: 	1.002.325,56 => 1,002,325.56
'			-1.323,7 => -1,323.7
'###########################################################
Public Function fConvertFormat(sNum)

	Dim saveStr, sCurFormat
	Call fGetReferenceVerificationData("CURRENCY_FORMAT", sCurFormat)

	If sCurFormat = "-x.xxx,yy" OR sCurFormat = "(x.xxx,yy)" Then
		pos = instr(1,sNum,",")
		If pos <> 0 Then
			sNum =  replace(sNum, ".", ",")
			saveStr = left (sNum,pos-1)
			sNum = replace(sNum, ",", ".", pos)
			sNum = saveStr & sNum
		End If
	End If

    fConvertFormat = cdbl(sNum)
End Function
'###########################################################

''###########################################################
'' Function name: fGuiCheckPermissions
'' Description: Enter to App with different customers
'				'and  check their permissions
'' Parameters:  username, password, role
'' Return value:  Success - True

''				 Failure - False
'' Example:
''###########################################################
Public Function fGuiCheckPermissions(ByVal sRole)

	Dim sButtonClass, sInnerHTML, bFound
	Dim bContactInformation, bCreditLimit, bEstimatedBalanceSummary, bRecentAlerts
	Dim bUnbilledTraffic, bOpenTransactions, bInvoices, bPayments, bDisputes, bAlerts, bAdmin, bGlobal
	Dim bGCustomerSettings, bGAlertSettings, bGAlertEmailTemplates, bGOtherEmailTemplates, bGPortalStrings, bGiBasisUsers
	bFound = False
	Reporter.ReportEvent micDone,"----------" & sRole & "----------", "fGuiCheckPermissions"

    'Get permissions for user
	If instr(1,sRole, "iBasis") > 1 Then
		bContactInformation = True 
		bCreditLimit = True 
		bEstimatedBalanceSummary = True 
		bRecentAlerts = True
		bUnbilledTraffic = True 
		bOpenTransactions = True 
		bInvoices = True 
		bPayments = True
		bDisputes = True 
		bAlerts = True
		bAdmin = True
		bGlobal = True
	End If
    
    Select Case Trim(sRole)
    	                     
		Case "Customer Finance","Customer Admin"
            sSQL = "select role_.NAME From "& PORTAL &"role_ where role_.ROLEID in(select ROLEID From "& PORTAL &"users_roles where userid=(select USER_.USERID FROM "& PORTAL &"user_ WHERE screenname = '" & globaldictionary("USER_NAME") & "'))"

			'Gets a RS, using a SQL query
			 rc = fDBGetRS ("PORTAL", sSQL, objRS) 
		
			'Check fDBGetRS returned value
			If rc = False Then						'DB Connection failed
				Reporter.ReportEvent micFail, "fGuiCheckPermissions", "ROLE:Customer Finance - Connetion to DB was failed."
				Call fWriteHtmlReportRow("fGuiCheckPermissions - Customer Finance", "Check the connection to DB", "FAIL","Connetion to DB was failed")
				fGuiCheckPermissions = False
				Exit Function		
			ElseIf rc = NO_RECORDS_FOUND Then		'NO_RECORDS_FOUND
				Reporter.ReportEvent micWarning, "fGuiCheckPermissions", "ROLE:Customer Finance - No records returned by the query."
				Call fWriteHtmlReportRow("fGuiCheckPermissions - Customer Finance", "Check if records returned from DB", "INFO","No records returned by the query")
				fGuiCheckPermissions = False
				Exit Function
			End If
            
			bContactInformation = fReturnViewer(objRS,"Info")
			bCreditLimit = fReturnViewer(objRS,"Limit")
			bEstimatedBalanceSummary = fReturnViewer(objRS,"Balance")
			bRecentAlerts = fReturnViewer(objRS,"Recent Alerts")
			bUnbilledTraffic = fReturnViewer(objRS,"Unbilled")
			bOpenTransactions = fReturnViewer(objRS,"Transactions")
			bInvoices = fReturnViewer(objRS,"Invoices")
			bPayments = fReturnViewer(objRS,"Payments")
			bDisputes = fReturnViewer(objRS,"Disputes")
			bAlerts = fReturnViewer(objRS,"Alerts")
			bAdmin = fReturnViewer(objRS,"Admin")
			bGlobal = fReturnViewer(objRS,"Global")

	
		Case "iBasis Content Admin"
        	bGCustomerSettings = False
			bGAlertSettings = False
			bGAlertEmailTemplates = True
			bGOtherEmailTemplates = True
			bGPortalStrings = True
			bGiBasisUsers = False

		Case "iBasis Customer Admin"
            bGCustomerSettings = True
			bGAlertSettings = False
			bGAlertEmailTemplates = False
			bGOtherEmailTemplates = False
			bGPortalStrings = False
			bGiBasisUsers = True

		Case "iBasis Finance Admin"
			bGCustomerSettings = False
			bGAlertSettings = True
			bGAlertEmailTemplates = True
			bGOtherEmailTemplates = False
			bGPortalStrings = False
			bGiBasisUsers = False

		Case "iBasis Read Only"
			bGCustomerSettings = True
			bGAlertSettings = True
			bGAlertEmailTemplates = True
			bGOtherEmailTemplates = True
			bGPortalStrings = True
			bGiBasisUsers = True

	End Select

'Check permissions
	
	'Check the Home page pemissions
	i = 1
	While globaldictionary("HOME" & i) <> ""
			If Eval(Replace("b" & globaldictionary("HOME" & i)," ", "")) = True Then
				If NOT Browser("iBasis Customer Portal").Page("Finance").WebElement(globaldictionary("HOME" & i)).Exist(10) Then
					Reporter.ReportEvent micFail, "fGuiCheckPermissions-" & sRole, globaldictionary("HOME" & i) & " does not appear"
					Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "FAIL",  globaldictionary("HOME" & i) & " does not appear")
				Else
					Reporter.ReportEvent micPass, "fGuiCheckPermissions-" & sRole, globaldictionary("HOME" & i) & " appears"
					Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "PASS",  globaldictionary("HOME" & i) & " appears")
				End If
			Else
				If Browser("iBasis Customer Portal").Page("Finance").WebElement(globaldictionary("HOME" & i)).Exist(10) Then
					Reporter.ReportEvent micFail, "fGuiCheckPermissions-" & sRole, globaldictionary("HOME" & i) & " appears"
					Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "FAIL",  globaldictionary("HOME" & i) & " appears")
				Else
					Reporter.ReportEvent micPass, "fGuiCheckPermissions-" & sRole, globaldictionary("HOME" & i) & " does not appear"
					Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & "user " , "PASS",  globaldictionary("HOME" & i) & " does not appear")
				End If
			End If

		i = i + 1
	Wend

	'Check the protlets pemissions
	i = 1
	While globaldictionary("PROTLET_NAME" & i) <> ""
			If eval(replace("b" & globaldictionary("PROTLET_NAME" & i)," ", "")) = True Then
				If globaldictionary("PROTLET_NAME" & i) = "Payments" Then
					globaldictionary("PROTLET_NAME" & i) = "Payments / Credits"
				End If
				Browser("iBasis Customer Portal").Page("Home").Link("Finance").FireEvent "OnMouseOver"
				If NOT Browser("iBasis Customer Portal").Page("Home").Link(globaldictionary("PROTLET_NAME" & i)).Exist(2) Then
					Reporter.ReportEvent micFail, "fGuiCheckPermissions-" & sRole, globaldictionary("PROTLET_NAME" & i) & " protlet does not appear"
					Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "FAIL",  globaldictionary("PROTLET_NAME" & i) & " protlet does not appear")
				Else
					Reporter.ReportEvent micPass, "fGuiCheckPermissions-" & sRole, globaldictionary("PROTLET_NAME" & i) & " protlet appears"
					Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "PASS",  globaldictionary("PROTLET_NAME" & i) & " protlet appears")
				End If
			Else
				If globaldictionary("PROTLET_NAME" & i) = "Payments" Then
					globaldictionary("PROTLET_NAME" & i) = "Payments / Credits"
				End If
				Browser("iBasis Customer Portal").Page("Home").Link("Finance").FireEvent "OnMouseOver"
				If Browser("iBasis Customer Portal").Page("Home").Link(globaldictionary("PROTLET_NAME" & i)).Exist(2) Then
					Reporter.ReportEvent micFail, "fGuiCheckPermissions-" & sRole, globaldictionary("PROTLET_NAME" & i) & " protlet appears"
					Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "FAIL",  globaldictionary("PROTLET_NAME" & i) & " protlet appears")
				Else
					Reporter.ReportEvent micPass, "fGuiCheckPermissions-" & sRole, globaldictionary("PROTLET_NAME" & i) & " protlet does not appear"
					Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "PASS",  globaldictionary("PROTLET_NAME" & i) & " protlet does not appear")
				End If
			End If
		i = i + 1
	Wend

	'Check the Global pemissions
	If bGlobal = True Then

		Browser("iBasis Customer Portal").Page("Home").Link("Admin").FireEvent "OnMouseOver"
		Browser("iBasis Customer Portal").Page("Home").Link("Global").Click
		If Browser("iBasis Customer Portal").Page("Global").Exist(30) = "False" Then
			Reporter.ReportEvent micFail, "fGuiCheckPermissions", "Failed to Navigate the protlet: Global" 
			Call fWriteHtmlReportRow("fGuiCheckPermissions" , "Navigate to the protlet", "FAIL", "Failed to Navigate the protlet: Global")
			fGuiCheckPermissions = False
			Exit Function
		End If

		i = 1
		While globaldictionary("GLOBAL" & i) <> ""
				If eval(replace("bG" & globaldictionary("GLOBAL" & i)," ", "")) = True Then
					If NOT Browser("iBasis Customer Portal").Page("Global").WebElement(globaldictionary("GLOBAL" & i)).Exist(2) Then
						Reporter.ReportEvent micFail, "fGuiCheckPermissions-" & sRole, globaldictionary("GLOBAL" & i) & " Tab does not appear"
						Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "FAIL",  globaldictionary("GLOBAL" & i) & " Tab does not appear")
					Else
						Reporter.ReportEvent micPass, "fGuiCheckPermissions-" & sRole, globaldictionary("GLOBAL" & i) & " Tab appears"
						Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "PASS",  globaldictionary("GLOBAL" & i) & " Tab appears")
					End If
				Else
					If Browser("iBasis Customer Portal").Page("Global").WebElement(globaldictionary("GLOBAL" & i)).Exist(2) Then
						Reporter.ReportEvent micFail, "fGuiCheckPermissions-" & sRole, globaldictionary("GLOBAL" & i) & " Tab appears"
						Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "FAIL",  globaldictionary("GLOBAL" & i) & " Tab appears")
					Else
						Reporter.ReportEvent micPass, "fGuiCheckPermissions-" & sRole, globaldictionary("GLOBAL" & i) & " Tab does not appear"
						Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "PASS",  globaldictionary("GLOBAL" & i) & " Tab does not appear")
					End If
				End If
			i = i + 1
		Wend
	End If


	'Check if iBasis read-only user - Can not Edit or update
	If sRole = "iBasis Read Only" Then
		'Customer Settings tab
		Browser("iBasis Customer Portal").Page("Global").WebElement("Customer Settings").Click
		If Browser("iBasis Customer Portal").Page("Global").WebElement("Finance Details").Exist(30) = "False" Then
			Reporter.ReportEvent micFail, "fGuiCheckPermissions-Navigate to 'Customer Settings' Tab", "Finance Details element does not exit"
			Call fWriteHtmlReportRow("Check Permissions" , "Navigate to 'Customer Settings' Tab" , "FAIL", "Finance Details element does not exit")
		Else
			If Browser("iBasis Customer Portal").Page("Global").WebElement("Update").Exist(2) = "True" Then
				Reporter.ReportEvent micFail, "fGuiCheckPermissions-" & sRole, "'Update' links on 'Customer Settings' tab are available"
				Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "FAIL", "'Update' links on 'Customer Settings' tab are available")
			Else
				Reporter.ReportEvent micPass, "fGuiCheckPermissions-" & sRole, "'Update' links on 'Customer Settings' tab are disable"
				Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "PASS", "'Update' links on 'Customer Settings' tab are disable")
			End If
		End If
		
		'Alert Settings tab
		Browser("iBasis Customer Portal").Page("Global").WebElement("Alert Settings").Click
		If Browser("iBasis Customer Portal").Page("Global").WebElement("Alert Exposure Thresholds").Exist(30) = "False" Then
			Reporter.ReportEvent micFail, "fGuiCheckPermissions-Navigate to 'Alert Settings' Tab", "Alert Exposure Thresholds element does not exit"
			Call fWriteHtmlReportRow("Check Permissions" , "Navigate to 'Alert Settings' Tab" , "FAIL", "Alert Exposure Thresholds element does not exit")
		Else
			sButtonClass = Browser("iBasis Customer Portal").Page("Global").WebElement("Update").GetROProperty("class")
			If instr(1, sButtonClass, "disabled") = 0 Then
				Reporter.ReportEvent micFail, "fGuiCheckPermissions-" & sRole, "'Update' buttons on 'Alert Settings' tab are available"
				Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "FAIL", "'Update' buttons on 'Alert Settings' tab are available")
			Else
				Reporter.ReportEvent micPass, "fGuiCheckPermissions-" & sRole, "'Update' buttons on 'Alert Settings' tab are disable"
				Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "PASS", "'Update' buttons on 'Alert Settings' tab are disable")
			End If
		End If
		
		'Alert Email Templates tab
		Browser("iBasis Customer Portal").Page("Global").WebElement("Alert Email Templates").Click
		If Browser("iBasis Customer Portal").Page("Global").WebElement("Alert Email Templates_2").Exist(30) = "False" Then
			Reporter.ReportEvent micFail, "fGuiCheckPermissions-Navigate to 'Alert Email Templates' Tab", "Alert Email Templates element does not exit"
			Call fWriteHtmlReportRow("Check Permissions" , "Navigate to 'Alert Email Templates' Tab" , "FAIL", "Alert Email Templates element does not exit")
		Else
			sInnerHTML = Browser("iBasis Customer Portal").Page("Global").WebTable("Alert Email Templates table").GetROProperty("innerhtml")
			If instr(1, sInnerHTML, "disabled") = 0 Then
				Reporter.ReportEvent micFail, "fGuiCheckPermissions-" & sRole, "'Templates' Table on 'Alert Email Templates' tab are available"
				Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "FAIL", "'Templates' Table on 'Alert Email Templates' tab are available")
			Else
				Reporter.ReportEvent micPass, "fGuiCheckPermissions-" & sRole, "'Templates' Table on 'Alert Email Templates' tab are disable"
				Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "PASS", "'Templates' Table on 'Alert Email Templates' tab are disable")
			End If
		End If
		
		'Other Email Templates tab
		Browser("iBasis Customer Portal").Page("Global").WebElement("Other Email Templates").Click
		If Browser("iBasis Customer Portal").Page("Global").WebElement("User Account Email Templates").Exist(30) = "False" Then
			Reporter.ReportEvent micFail, "fGuiCheckPermissions-Navigate to 'Other Email Templates' Tab", "User Account Email Templates element does not exit"
			Call fWriteHtmlReportRow("Check Permissions" , "Navigate to 'Other Email Templates' Tab" , "FAIL", "User Account Email Templates element does not exit")
		Else
			sInnerHTML = Browser("iBasis Customer Portal").Page("Global").WebTable("Other Email Templates table").GetROProperty("innerhtml")
			If instr(1, sInnerHTML, "disabled") = 0 Then
				Reporter.ReportEvent micFail, "fGuiCheckPermissions-" & sRole, "'Templates' Table on 'Other Email Templates' tab are available"
				Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "FAIL", "'Templates' Table on 'Other Email Templates' tab are available")
			Else
				Reporter.ReportEvent micPass, "fGuiCheckPermissions-" & sRole, "'Templates' Table on 'Other Email Templates' tab are disable"
				Call fWriteHtmlReportRow("Check Permissions" , "Check Permissions for: " & sRole & " user" , "PASS", "'Templates' Table on 'Other Email Templates' tab are disable")
			End If
		End If
				
	End If
	
	Browser("iBasis Customer Portal").Close

    fGuiCheckPermissions = True
End Function
'###########################################################

'###########################################################
' Function name: fGuiCreateUser
' Description: Create New User
' Parameters:  Protlet Name,
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiCreateUser

	Dim i, iRowCount, arrUsers, iUsersInUse, bFound, sNotification 
	Dim ArrRoles()
	iArrIndex = 0
	bFound = True

	Select Case Ucase(globaldictionary("CUSTOMER / IBASIS"))
		Case "IBASIS"
			sPage = "Global"

			'Enter to Global protlet
			'Navigate to iBasis Users tab
			 If fNavigateToTab("iBasis Users", "New User") <> True Then
			   fGuiCreateUser = False
			   Exit Function
			End If

			iRowCount = Browser("iBasis Customer Portal").Page("Global").WebTable("Users Table").RowCount

		Case "CUSTOMER"
			sPage = "Admin"
			Browser("iBasis Customer Portal").Page("Home").Link("Admin").Click
			If Browser("iBasis Customer Portal").Page("Admin").Exist(30) = "False" Then
				Reporter.ReportEvent micFail, "fGuiCreateUser", "Failed to Navigate the protlet: Admin"
				Call fWriteHtmlReportRow("fGuiCreateUser - Admin", "Navigate to the protlet", "FAIL", "Failed to Navigate the protlet: " & sProtletName)
				fGuiCreateUser = False
				Exit Function
			End If
			If fSyncByImage(60) = False Then
				Reporter.ReportEvent micFail, "fGuiCreateUser", "Failed to Navigate the protlet: Admin"
				Call fWriteHtmlReportRow("fGuiCreateUser - Admin", "sync for refresh data", "FAIL", "sync failed after 60 seconds")
				fGuiCreateUser = False
				Exit Function
			End If

			iRowCount = Browser("iBasis Customer Portal").Page("Admin").WebTable("Users Table").RowCount
	
			arrUsers = Split(Browser("iBasis Customer Portal").Page("Admin").WebElement("User Accounts in Use").GetRoProperty("outertext"),":")
			iUsersInUse = Clng(Trim(arrUsers(1)))

	End Select

	'Click on new user button
	Browser("iBasis Customer Portal").Page(sPage).WebElement("New User").Click
	'SyncByImage
	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fGuiCreateUser - " & globaldictionary("CUSTOMER / IBASIS"), "Sync to Create window to be opened"
		Call fWriteHtmlReportRow("fGuiCreateUser - " & globaldictionary("CUSTOMER / IBASIS"), "Sync to Create window to be opened", "FAIL", "Create window did not opened")
		fGuiCreateUser = False
		Exit Function
	End If
	'Sync
	If Browser("iBasis Customer Portal").Page(sPage).WebElement("Create New User").Exist(10) = "False" Then
		Reporter.ReportEvent micFail, "fGuiCreateUser", "'Create "& globaldictionary("CUSTOMER / IBASIS")&" User' window was not opened"
		Call fWriteHtmlReportRow("fGuiCreateUser ", "Create New User", "FAIL", "'Create "& globaldictionary("CUSTOMER / IBASIS")&" User' window was not opened")
		fGuiCreateUser = False
		Exit Function
	End If

	'Fill the details of the new user
	Browser("iBasis Customer Portal").Page(sPage).WebEdit("User Name").Set globaldictionary("USERNAME")
	Browser("iBasis Customer Portal").Page(sPage).WebEdit("Full Name").Set globaldictionary("FULL_NAME")
    Browser("iBasis Customer Portal").Page(sPage).WebEdit("Password").Set globaldictionary("PASSWORD")
	Browser("iBasis Customer Portal").Page(sPage).WebEdit("Retype Password").Set globaldictionary("PASSWORD")
	Browser("iBasis Customer Portal").Page(sPage).WebEdit("Email").Set globaldictionary("EMAIL")
	Browser("iBasis Customer Portal").Page(sPage).WebEdit("Phone").Set globaldictionary("PHONE")

	If sPage = "Admin" And lCase(globaldictionary("ROLE_TYPE")) = "general" Then
		Browser("iBasis Customer Portal").Page("Admin").WebList("Role").Select globaldictionary("ROLE_TYPE")
	End If

	If lCase(globaldictionary("ROLE_TYPE")) = "administrator" Then
		Set colObject = fCollectRolesFromUI(sPage) 'Collect permissions items
		ReDim ArrRoles(colObject.Count - 1)
		For i = 0 To colObject.Count - 1			
			ArrRoles(i) = colObject(i).GetROProperty("innertext")
		Next
	Else
		
		Call fUncheckAllPermissions(sPage) ' Clear all permission checkboxes

		Set colObject = fCollectRolesFromUI(sPage) 'Collect permissions items
		i = 1
		While globaldictionary("ROLE"& i) <> "" 

				rc = fSelectRolesInUI(colObject, globaldictionary("ROLE"& i),"Checked",sPage)
				If rc = True Then 'Collect the item to an array
					iArrIndex = iArrIndex + 1
					ReDim Preserve ArrRoles(iArrIndex - 1)
					ArrRoles(iArrIndex - 1) = fGetRoleName(globaldictionary("ROLE"& i))
				End If
				temp = Right(globaldictionary("ROLE"& i), len(globaldictionary("ROLE"& i))-7) 
				sRoles = sRoles & temp & ","
				i = i + 1
		Wend

	End If
	
	'Apply the creation
	Browser("iBasis Customer Portal").Page(sPage).WebElement("Apply").SetTOProperty "innertext", "Create"
	Browser("iBasis Customer Portal").Page(sPage).WebElement("Apply").Click	

	If fVerifyCloseWindow(60, sPage ,"Create New User") = False Then
		If Browser("iBasis Customer Portal").Page(sPage).WebElement("Notification").Exist(2) = "True" Then
			sNotification = Browser("iBasis Customer Portal").Page(sPage).WebElement("Notification").GetROProperty("innertext")
			Reporter.ReportEvent micFail, "Check if window was closed", sNotification
			Call fWriteHtmlReportRow("Create User" , "Check if window was closed" , "FAIL", sNotification)
		Else
			Reporter.ReportEvent micFail, "Check if window was closed", "The field's validation failed"
			Call fWriteHtmlReportRow("Create User" , "Check if window was closed", "FAIL", "The field's validation failed")
		End If
		fGuiCreateUser = False
		Exit Function
	End If

	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fGuiCreateUser", "Create Customer user was failed"
		Call fWriteHtmlReportRow("fGuiCreateUser - Admin", "sync for refresh data", "FAIL", "Create Customer user was failed")
		fGuiCreateUser = False
		Exit Function
	End If

	'Notification for creation succeeded
	sNotification = Browser("iBasis Customer Portal").Page(sPage).WebElement("Notification").GetROProperty("innertext")
	Call fWriteHtmlReportRow("Create User" , "Check if creation succeeded" , "PASS", sNotification)

	'Check if user was created => one row was added to the users table
	If Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").RowCount = iRowCount + 1 Then
		Reporter.ReportEvent micPass, "Create New User", "The user was added to Users Table"
		Call fWriteHtmlReportRow("Create User" , "Create New User" , "PASS", "The user was added to Users Table")
	Else
		Reporter.ReportEvent micFail, "Create New User", "The user was not added to Users Table"
		Call fWriteHtmlReportRow("Create User" , "Create New User" , "FAIL", "The user was not added to Users Table")
	End If

	If sPage = "Admin" Then
		'Check if 'Users In Use' value was updated
		arrUsers = Split(Browser("iBasis Customer Portal").Page("Admin").WebElement("User Accounts in Use").GetRoProperty("outertext"),":")
		If Clng(Trim(arrUsers(1))) = iUsersInUse + 1 Then
			Reporter.ReportEvent micPass, "Create New User", "The user was added to 'User Account in Use'"
			Call fWriteHtmlReportRow("Create User" , "Create New User" , "PASS", "The user was added to 'User Account in Use'")
		Else
			Reporter.ReportEvent micFail, "Create New User", "The user was not added to 'User Account in Use'"
			Call fWriteHtmlReportRow("Create User" , "Create New User" , "FAIL", "The user was not added to 'User Account in Use'")
		End If
	End If

	iRow = Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").GetRowWithCellText(lcase(globaldictionary("USERNAME")),1)

	If lcase(Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").GetCellData(iRow,1)) <>  lcase(globaldictionary("USERNAME")) Then
		bFound = False
		Reporter.ReportEvent micFail, "Create New User", "The username in the table is different from the creation"
		Call fWriteHtmlReportRow("Create User" , "Create New User" , "FAIL", "The username in the table is different from the creation")
	End If

	If lcase(Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").GetCellData(iRow,2)) <>  lcase(globaldictionary("FULL_NAME")) Then
		bFound = False
		Reporter.ReportEvent micFail, "Create New User", "The full name in the table is different from the creation"
		Call fWriteHtmlReportRow("Create User" , "Create New User" , "FAIL", "The full name in the table is different from the creation")
	End If

	If sPage = "Admin" Then
		If lCase(Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").GetCellData(iRow,3)) <>  lCase(globaldictionary("ROLE_TYPE")) Then
			bFound = False
			Reporter.ReportEvent micFail, "Create New User", "The role type in the table is different from the creation"
			Call fWriteHtmlReportRow("Create User" , "Create New User" , "FAIL", "The role type in the table is different from the creation")
		End If
	Else
    	If lCase(Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").GetCellData(iRow,3)) <>  lCase(Left(sRoles, Len(sRoles)-1)) Then
			bFound = False
			Reporter.ReportEvent micFail, "Create New User", "The roles in the table is different from the creation"
			Call fWriteHtmlReportRow("Create User" , "Create New User" , "FAIL", "The roles in the table is different from the creation")
		End If
	End If
	If lcase(Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").GetCellData(iRow,4)) <>  lcase(globaldictionary("EMAIL")) Then
		bFound = False
		Reporter.ReportEvent micFail, "Create New User", "The email in the table is different from the creation"
		Call fWriteHtmlReportRow("Create User" , "Create New User" , "FAIL", "The email in the table is different from the creation")
	End If

	If Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").GetCellData(iRow,5) <>  globaldictionary("PHONE") Then
		bFound = False
		Reporter.ReportEvent micFail, "Create New User", "The phone in the table is different from the creation"
		Call fWriteHtmlReportRow("Create User" , "Create New User" , "FAIL", "The phone in the table is different from the creation")
	End If

	If bFound = True Then
		Reporter.ReportEvent micPass, "Create New User", "The creation of the new user " & globaldictionary("FULL_NAME") & "successfully"
		Call fWriteHtmlReportRow("Create User" , "Create New User" , "PASS", "The creation of the new user " & globaldictionary("FULL_NAME") & "successfully")
	End If

	'DB Verification
	Call fCompUserRolesUiAndDb(ArrRoles, globaldictionary("USERNAME"), globaldictionary("CUSTOMER / IBASIS"))

    fGuiCreateUser = True 
End Function
'##################################################################

'###########################################################
' Function name: fCompUserRolesUiAndDb
' Description: fCompUserRolesUiAndDb
' Parameters:  
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fCompUserRolesUiAndDb(ByVal ArrRolesUI, ByVal sUserName, ByVal userType)
    Dim sSQL

	Select Case uCase(userType)
		Case "IBASIS"
			sSQL = "select role_.NAME From "& PORTAL &"role_ where role_.ROLEID in(select ROLEID From "& PORTAL &"users_roles " & _
			"where ROLEID in(select distinct role_id from " & SCHEMA & "ECARE_ROLE_GROUP_ROLES) " & _
			"and userid=(select USER_.USERID FROM "& PORTAL &"user_ WHERE screenname = '" & lcase(sUserName) & "'))" & _
			"and name like '%iBasis%'"

		Case "CUSTOMER"
			sSQL = "select role_.NAME From "& PORTAL &"role_ where role_.ROLEID in(select ROLEID From "& PORTAL &"users_roles " & _
			"where ROLEID in(select distinct role_id from " & SCHEMA & "ECARE_ROLE_GROUP_ROLES) " & _
			"and userid=(select USER_.USERID FROM "& PORTAL &"user_ WHERE screenname = '" & lcase(sUserName) & "'))"
	End Select
    

	'Gets a RS, using a SQL query
	 rc = fDBGetRS ("PORTAL", sSQL, objRS) 

	'Check fDBGetRS returned value
	If rc = False Then						'DB Connection failed
		Reporter.ReportEvent micFail, "fGuiCheckPermissions", "ROLE:Customer Finance - Connetion to DB was failed."
		Call fWriteHtmlReportRow("fGuiCheckPermissions - Customer Finance", "Check the connection to DB", "FAIL","Connetion to DB was failed")
		fGuiCheckPermissions = False
		Exit Function		
	ElseIf rc = NO_RECORDS_FOUND Then		'NO_RECORDS_FOUND
		Reporter.ReportEvent micWarning, "fGuiCheckPermissions", "ROLE:Customer Finance - No records returned by the query."
		Call fWriteHtmlReportRow("fGuiCheckPermissions - Customer Finance", "Check if records returned from DB", "INFO","No records returned by the query")
		fGuiCheckPermissions = False
		Exit Function
	End If

	If lCase(globaldictionary("USER_ACTION")) = "update" And lCase(globaldictionary("ROLE_TYPE")) <> "administration" Then
		For i = 0 To uBound(ArrRolesUI)
			bFound = False
			bRoleNotUncheck = False
			objRS.MoveFirst
			Do While Not objRS.EOF
				If lCase(objRS.Fields(0).Value) = lCase(ArrRolesUI(i)) And lCase(ArrRolesUI(i + 1)) = "checked" Then
					Reporter.ReportEvent micPass, "Compare UI and DB users roles", "Role " & ArrRolesUI(i) & " that was assigned to user on UI was found on DB"
					Call fWriteHtmlReportRow("fCompUserRolesUiAndDb" , "Compare UI and DB users roles" , "PASS",  "Role " & ArrRolesUI(i) & " that was assigned to user on UI was found on DB")
                    bFound = True
					Exit Do
				ElseIf lCase(objRS.Fields(0).Value) = lCase(ArrRolesUI(i)) And lCase(ArrRolesUI(i + 1)) = "unchecked" Then
					Reporter.ReportEvent micFail, "Compare UI and DB users roles", "Role " & ArrRolesUI(i) & " that was remove from user on UI was found on DB"
					Call fWriteHtmlReportRow("fCompUserRolesUiAndDb" , "Compare UI and DB users roles" , "PASS",  "Role " & ArrRolesUI(i) & " that was remove from user on UI was found on DB")
					bRoleNotUncheck = True
					Exit Do
                End If
				objRS.MoveNext
			Loop
			If lCase(ArrRolesUI(i + 1)) = "unchecked" And bRoleNotUncheck = False Then 'Role not found
					Reporter.ReportEvent micFail, "Compare UI and DB users roles", "Role " & ArrRolesUI(i) & " that was remove from user on UI was not found on DB"
					Call fWriteHtmlReportRow("fCompUserRolesUiAndDb" , "Compare UI and DB users roles" , "PASS",  "Role " & ArrRolesUI(i) & " that was remove from user on UI was not found on DB")
			End If
			If lCase(ArrRolesUI(i + 1)) = "checked" And bFound = False Then 'Role not found
					Reporter.ReportEvent micFail, "Compare UI and DB users roles", "Role " & ArrRolesUI(i) & " that was assigned to user on UI was not found on DB"
					Call fWriteHtmlReportRow("fCompUserRolesUiAndDb" , "Compare UI and DB users roles" , "FAIL",  "Role " & ArrRolesUI(i) & " that was not assigned to user on UI was found on DB")
			End If
			i = i + 1
		Next

	Else
		bRoleNotFound = False
		objRS.MoveFirst
		While Not objRS.EOF
			bFound = False
			For i = 0 To uBound(ArrRolesUI)
				If lCase(objRS.Fields(0).Value) = lCase(ArrRolesUI(i)) Then 'If role found on
					bFound = True
					Exit For
				End If
			Next
			
			If bFound = False Then 'Role not found
				Reporter.ReportEvent micFail, "Compare UI and DB users roles", "Role " & ArrRolesUI(i) & " that was assigned to user on UI was not found on DB"
				Call fWriteHtmlReportRow("fCompUserRolesUiAndDb" , "Compare UI and DB users roles" , "FAIL",  "Role " & ArrRolesUI(i) & " that was assigned to user on UI was not found on DB")
				bRoleNotFound = True
			End If
			objRS.MoveNext
		Wend
	
		'All Roles found
		If bRoleNotFound = False Then
			Reporter.ReportEvent micPass, "Compare UI and DB users roles", "All Roles that were assigned to user " & sUserName & " on UI match to DB"
			Call fWriteHtmlReportRow("fCompUserRolesUiAndDb" , "Compare UI and DB users roles" , "PASS","All Roles that were assigned to user " & sUserName & " on UI match to DB")
		End If

	End If

End Function

'###########################################################
' Function name: fGuiUpdateUser
' Description: Update User
' Parameters:  
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiUpdateUser

	Dim i, iRowCount, arrUsers, iUsersInUse

	Dim ArrRoles()
	iArrIndex = 0
	bFound = True

	Select Case Ucase(globaldictionary("CUSTOMER / IBASIS"))
		Case "IBASIS"
			sPage = "Global"
			'Enter to Global protlet
			'Navigate to iBasis Users tab
			 If fNavigateToTab("iBasis Users", "New User") <> True Then
			   fGuiUpdateUser = False
			   Exit Function
			End If

		Case "CUSTOMER"
			sPage = "Admin"
			Browser("iBasis Customer Portal").Page("Home").Link("Admin").Click
			If Browser("iBasis Customer Portal").Page("Admin").Exist(30) = "False" Then
				Reporter.ReportEvent micFail, "fGuiUpdateUser", "Failed to Navigate the protlet: Admin"
				Call fWriteHtmlReportRow("fGuiUpdateUser - Admin", "Navigate to the protlet", "FAIL", "Failed to Navigate the protlet: " & sProtletName)
				fGuiUpdateUser = False
				Exit Function
			End If
			If fSyncByImage(60) = False Then
				Reporter.ReportEvent micFail, "fGuiUpdateUser", "Failed to Navigate the protlet: Admin"
				Call fWriteHtmlReportRow("fGuiUpdateUser - Admin", "sync for refresh data", "FAIL", "sync failed after 60 seconds")
				fGuiUpdateUser = False
				Exit Function
			End If
       
	End Select
	
	'Click on user for update
	iRow = Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").GetRowWithCellText(lcase(globaldictionary("USERNAME")),1)
	Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").ChildItem(iRow, 1,"WebElement", 0).click

	'Sync for Update button to be enabled
	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fGuiUpdateUser - " & globaldictionary("CUSTOMER / IBASIS"), "Update button is disabled"
		Call fWriteHtmlReportRow("fGuiUpdateUser - " & globaldictionary("CUSTOMER / IBASIS"), "Sync for Update button to be enabled", "FAIL", "Update button is disabled")
		fGuiUpdateUser = False
		Exit Function
	End If

	'Click on Update User button
	Browser("iBasis Customer Portal").Page(sPage).WebElement("Update User").Click
	'Sync for Update button to be enabled
	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fGuiUpdateUser - " & globaldictionary("CUSTOMER / IBASIS"), "Update Window did not opened"
		Call fWriteHtmlReportRow("fGuiUpdateUser - " & globaldictionary("CUSTOMER / IBASIS"), "Sync for Update Window to be opened", "FAIL", "Update Window did not opened")
		fGuiUpdateUser = False
		Exit Function
	End If
	'Sync
	If Browser("iBasis Customer Portal").Page(sPage).WebElement("Update User Window").Exist(10) = "False" Then
		Reporter.ReportEvent micFail, "fGuiUpdateUser",  globaldictionary("CUSTOMER / IBASIS") & " User updation was failed"
		Call fWriteHtmlReportRow("fGuiUpdateUser - " & globaldictionary("CUSTOMER / IBASIS"), "Update Customer User", "FAIL",  globaldictionary("CUSTOMER / IBASIS") & " User updation was failed")
		fGuiUpdateUser = False
		Exit Function
	End If

    'Update the details of the user
	If globaldictionary("FULL_NAME") <> "" Then
		Browser("iBasis Customer Portal").Page(sPage).WebEdit("Full Name").Set ""
		Browser("iBasis Customer Portal").Page(sPage).WebEdit("Full Name").Set globaldictionary("FULL_NAME")
	End If

	If globaldictionary("EMAIL") <> "" Then
		Browser("iBasis Customer Portal").Page(sPage).WebEdit("Email").Set globaldictionary("EMAIL")
	End If

	If globaldictionary("PHONE") <> "" Then
		Browser("iBasis Customer Portal").Page(sPage).WebEdit("Phone").Set globaldictionary("PHONE")
	End If

	If sPage = "Admin" and (globaldictionary("ROLE_TYPE") <> "" or lcase(globaldictionary("ROLE_TYPE")) <> "ibasis") Then 'Customer user General/Admin
		Browser("iBasis Customer Portal").Page(sPage).WebList("Role").Select globaldictionary("ROLE_TYPE")
	End If

	If sPage = "Admin" and	lcase(Browser("iBasis Customer Portal").Page("Admin").WebList("Role").GetROProperty ("selection")) = "administrator" Then
		'customer user administrator
		Set colObject = fCollectRolesFromUI(sPage) 'Collect permissions items
		ReDim ArrRoles(colObject.Count - 1)
		For i = 0 To colObject.Count - 1			
			ArrRoles(i) = colObject(i).GetROProperty("innertext")
		Next
	Else
		'customer user general
		Set colObject = fCollectRolesFromUI(sPage) 'Collect permissions items
		i = 1
		While globaldictionary("ROLE"& i) <> "" 

				rc = fSelectRolesInUI(colObject, globaldictionary("ROLE"& i), globaldictionary("VALUE"& i),sPage)
				If rc = True Then 'Collect the item to an array
					If iArrIndex = 0  Then
						iArrIndex = iArrIndex + 1
					Else
						iArrIndex = iArrIndex + 2
					End If
					
					ReDim Preserve ArrRoles(iArrIndex)
					ArrRoles(iArrIndex - 1) = fGetRoleName(globaldictionary("ROLE"& i))
					ArrRoles(iArrIndex) = lCase(globaldictionary("VALUE"& i))
				End If
				i = i + 1
		Wend

	End If
	

	'Apply the update
	Browser("iBasis Customer Portal").Page(sPage).WebElement("Apply").SetTOProperty "innertext", "Update"
	Browser("iBasis Customer Portal").Page(sPage).WebElement("Apply").Click

	If fVerifyCloseWindow(60,sPage,"Update User Window") = False Then
		If Browser("iBasis Customer Portal").Page(sPage).WebElement("Notification").Exist(2) = "True" Then
			sNotification = Browser("iBasis Customer Portal").Page(sPage).WebElement("Notification").GetROProperty("innertext")
			Reporter.ReportEvent micFail, "Check if window was closed", sNotification
			Call fWriteHtmlReportRow("Update User" , "Check if window was closed" , "FAIL", sNotification)
		Else
			Reporter.ReportEvent micFail, "Check if window was closed", "The field's validation failed"
			Call fWriteHtmlReportRow("Update User" , "Check if window was closed", "FAIL", "The field's validation failed")
		End If
		fGuiUpdateUser = False
		Exit Function
	End If

	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fGuiCreateUser", "Create Customer user was failed"
		Call fWriteHtmlReportRow("fGuiUpdateUser - Admin", "sync for refresh data", "FAIL", "Create Customer user was failed")
		fGuiCreateUser = False
		Exit Function
	End If

	sNotification = Browser("iBasis Customer Portal").Page(sPage).WebElement("Notification").GetROProperty("innertext")
	Call fWriteHtmlReportRow("Update User" , "Check if update succeeded" , "PASS", sNotification)

		
	If globaldictionary("FULL_NAME") <> "" Then
		If Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").GetCellData(iRow,2) <>  globaldictionary("FULL_NAME") Then
			Reporter.ReportEvent micFail, "Update User", "The full name in the table is different from the update value"
			Call fWriteHtmlReportRow("Update User" , "Check if update was done" , "FAIL", "The full name in the table is different from the update value")
			bFound = False
		End If
	End If

	If sPage = "Admin" And globaldictionary("ROLE_TYPE") <> "" Then
		If Browser("iBasis Customer Portal").Page("Admin").WebTable("Users Table").GetCellData(iRow,3) <>  globaldictionary("ROLE_TYPE") Then
			Reporter.ReportEvent micFail, "Update User", "The role in the table is different from the update value"
			Call fWriteHtmlReportRow("Update User" , "Check if update was done" , "FAIL", "The role in the table is different from the update value")
			bFound = False
		End If
	End If

	If globaldictionary("EMAIL") <> "" Then
		If Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").GetCellData(iRow,4) <>  globaldictionary("EMAIL") Then
			Reporter.ReportEvent micFail, "Update User", "The email in the table is different from the update value"
			Call fWriteHtmlReportRow("Update User" , "Check if update was done" , "FAIL", "The email in the table is different from the update value")
			bFound = False
		End If
	End If

	If globaldictionary("PHONE") <> "" Then
		If Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").GetCellData(iRow,5) <>  globaldictionary("PHONE") Then
			Reporter.ReportEvent micFail, "Update User", "The phone in the table is different from the update value"
			Call fWriteHtmlReportRow("Update User" , "Check if update was done" , "FAIL", "The phone in the table is different from the update value")
			bFound = False
		End If
	End If

	If bFound = True Then
		Reporter.ReportEvent micPass, "Update User", "The Update of the user " & globaldictionary("FULL_NAME") & " was done successfully"
		Call fWriteHtmlReportRow("Update User" , "Update User" , "PASS", "The Update of the user " & globaldictionary("FULL_NAME") & " was done successfully")
	End If

	'DB Verification
	Call fCompUserRolesUiAndDb(ArrRoles, globaldictionary("USERNAME"), globaldictionary("CUSTOMER / IBASIS"))

    fGuiUpdateUser = True 

End Function
'##################################################################

'###########################################################
' Function name: fGuiResetPassword
' Description:ResetPassword
' Parameters:  Protlet Name,
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiResetPassword

	Dim iRow

	Select Case Ucase(globaldictionary("CUSTOMER / IBASIS"))
		Case "IBASIS"
			sPage = "Global"
			sButton = "Update_Reset"
			'Enter to Global protlet
			'Navigate to iBasis Users tab
			 If fNavigateToTab("iBasis Users", "New User") <> True Then
			   fGuiResetPassword = False
			   Exit Function
			End If

		Case "CUSTOMER"
			sPage = "Admin"
			sButton = "Apply"
			Browser("iBasis Customer Portal").Page("Home").Link("Admin").Click
			If Browser("iBasis Customer Portal").Page("Admin").Exist(30) = "False" Then
				Reporter.ReportEvent micFail, "fGuiResetPassword", "Failed to Navigate the protlet: Admin"
				Call fWriteHtmlReportRow("fGuiResetPassword - Admin", "Navigate to the protlet", "FAIL", "Failed to Navigate the protlet: " & sProtletName)
				fGuiResetPassword = False
				Exit Function
			End If
			If fSyncByImage(60) = False Then
				Reporter.ReportEvent micFail, "fGuiResetPassword", "Failed to Navigate the protlet: Admin"
				Call fWriteHtmlReportRow("fGuiResetPassword - Admin", "sync for refresh data", "FAIL", "sync failed after 60 seconds")
				fGuiResetPassword = False
				Exit Function
			End If
       
	End Select
	
	'Click on user for Reset Password
	iRow = Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").GetRowWithCellText(lcase(globaldictionary("USERNAME")),1)
	Browser("iBasis Customer Portal").Page(sPage).WebTable("Users Table").ChildItem(iRow, 1,"WebElement", 0).click

	'Sync for Reset Password button to be enabled
	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fGuiResetPassword - " & globaldictionary("CUSTOMER / IBASIS"), "Reset Password button is disabled"
		Call fWriteHtmlReportRow("fGuiResetPassword - " & globaldictionary("CUSTOMER / IBASIS"), "Sync for Reset Password button to be enabled", "FAIL", "Reset Password button is disabled")
		fGuiResetPassword = False
		Exit Function
	End If

	'Click on Update User button
	Browser("iBasis Customer Portal").Page(sPage).WebElement("Reset Password").Click
	'Sync for Reset Password button to be enabled
	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fGuiResetPassword - " & globaldictionary("CUSTOMER / IBASIS"), "Reset Password Window did not opened"
		Call fWriteHtmlReportRow("fGuiResetPassword - " & globaldictionary("CUSTOMER / IBASIS"), "Sync for Reset Password Window to be opened", "FAIL", "Reset Password Window did not opened")
		fGuiResetPassword = False
		Exit Function
	End If
	'Sync
	If Browser("iBasis Customer Portal").Page(sPage).WebElement("Reset Password Window").Exist(10) = "False" Then
		Reporter.ReportEvent micFail, "fGuiResetPassword",  "Reset Password Window did not opened"
		Call fWriteHtmlReportRow("fGuiResetPassword - " & globaldictionary("CUSTOMER / IBASIS"), "Reset Password for User", "FAIL",  "Reset Password Window did not opened")
		fGuiResetPassword = False
		Exit Function
	End If

	'Set fileds
	Browser("iBasis Customer Portal").Page(sPage).WebEdit("New Password").Set globaldictionary("NEW_PASSWORD")
	Browser("iBasis Customer Portal").Page(sPage).WebEdit("Retype Password").Set globaldictionary("NEW_PASSWORD")
   
	'Apply the update
	Browser("iBasis Customer Portal").Page(sPage).WebElement(sButton).SetTOProperty "innertext", "Update"
	Browser("iBasis Customer Portal").Page(sPage).WebElement(sButton).Click

	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fGuiResetPassword", "Customer User - ResetPassword was failed"
		Call fWriteHtmlReportRow("fGuiResetPassword - Admin", "sync for refresh data", "FAIL", "Customer User - ResetPassword was failed")
		fGuiResetPassword = False
		Exit Function
	End If

	sNotification = Browser("iBasis Customer Portal").Page("Admin").WebElement("Notification").GetROProperty("innertext")
	Call fWriteHtmlReportRow("Create User" , "Check if ResetPassword succeeded" , "PASS", sNotification)


	'sing out
	Browser("iBasis Customer Portal").Page("Admin").Link("Logout").Click

	If Browser("iBasis Customer Portal").Page("Login").WebEdit("username").Exist(10) = "False"  Then
		Reporter.ReportEvent micFail, "fGuiResetPassword", "Customer User - ResetPassword was failed"
		Call fWriteHtmlReportRow("fGuiResetPassword - Admin", "Sign out - Check if Login page was opened", "FAIL", "Open Login page failed")
		fGuiResetPassword = False
		Exit Function
	End If

	'try to login with the OLD password
	Browser("iBasis Customer Portal").Page("Login").WebEdit("username").Set globaldictionary("USERNAME")
	Browser("iBasis Customer Portal").Page("Login").WebEdit("password").Set globaldictionary("PASSWORD")
	Browser("iBasis Customer Portal").Page("Login").Image("signInButton").Click
	
	If NOT Browser("iBasis Customer Portal").Page("Login").WebElement("Authentication failed").Exist(10) Then
		Reporter.ReportEvent micFail, "ResetPassword", "ResetPassword was failed - Login with OLD password succeeded"
		Call fWriteHtmlReportRow("ResetPassword" , "Login with OLD password" , "FAIL", "Login with OLD password succeeded")
	End If

	'try to login with the NEW password
	Browser("iBasis Customer Portal").Page("Login").WebEdit("password").Set globaldictionary("NEW_PASSWORD")
	Browser("iBasis Customer Portal").Page("Login").Image("signInButton").Click
	
	If Browser("iBasis Customer Portal").Page("Home").Exist(30) = "True" Then
		Reporter.ReportEvent micPass, "ResetPassword", "ResetPassword - Login with NEW password succeeded"
		Call fWriteHtmlReportRow("ResetPassword" , "Login with NEW password" , "PASS", "Login with NEW password succeeded")

	Else
		Reporter.ReportEvent micFail, "ResetPassword", "ResetPassword was failed - Login with NEW password failed"
		Call fWriteHtmlReportRow("ResetPassword" , "Login with NEW password" , "FAIL", "Login with NEW password failed")
	End If


	fGuiResetPassword = True
End Function
'###########################################################

'###########################################################
' Function name: fGuiDeleteUser
' Description: DeleteUser
' Parameters:  username
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiDeleteUser

	Dim iRow, iRowCount, arrUsers, iUsersInUse

	'---------------------Delete IBasis user----------------------
	If Ucase(globaldictionary("CUSTOMER / IBASIS")) = "IBASIS" Then

		Exit Function
	End If

	'ELSE - 
	'---------------------Delete Customer user----------------------

'	'sing out
'	If Browser("iBasis Customer Portal").Page("Admin").Exist(2) Then
'		Browser("iBasis Customer Portal").Page("Admin").Link("Sign Out").Click
'		wait(3)
'	ElseIf Browser("iBasis Customer Portal").Page("Home").Exist(2) Then
'		Browser("iBasis Customer Portal").Page("Home").Link("Sign Out").Click
'		wait(3)
'	End If
'
'	'Login portal  
'	Call fGuiLogIn()

    'Enter to Admin protlet
	'Browser("iBasis Customer Portal").Page("Home").Link("AdminOut").FireEvent "OnMouseOver"
	Browser("iBasis Customer Portal").Page("Home").Link("Admin").Click
	If Browser("iBasis Customer Portal").Page("Admin").Exist(30) = "False" Then
		Reporter.ReportEvent micFail, "fGuiDeleteUser", "Failed to Navigate the protlet: Admin"
		Call fWriteHtmlReportRow("fGuiDeleteUser - Admin", "Navigate to the protlet", "FAIL", "Failed to Navigate the protlet: " & sProtletName)
		fGuiDeleteUser = False
		Exit Function
	End If
	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fGuiDeleteUser", "Failed to Navigate the protlet: Admin"
		Call fWriteHtmlReportRow("fGuiDeleteUser - Admin", "sync for refresh data", "FAIL", "sync failed after 60 seconds")
		fGuiDeleteUser = False
		Exit Function
	End If

	iRowCount = Browser("iBasis Customer Portal").Page("Admin").WebTable("Users Table").RowCount
	
	arrUsers = Split(Browser("iBasis Customer Portal").Page("Admin").WebElement("User Accounts in Use").GetRoProperty("outertext"),":")
	iUsersInUse = Clng(Trim(arrUsers(1)))

	'Click on user to be deleted
	iRow = Browser("iBasis Customer Portal").Page("Admin").WebTable("Users Table").GetRowWithCellText(globaldictionary("USERNAME"),1)
	Browser("iBasis Customer Portal").Page("Admin").WebTable("Users Table").ChildItem(iRow, 1,"WebElement", 0).click

	'Click on Delete User button
	Browser("iBasis Customer Portal").Page("Admin").WebElement("Delete User").Click
	If Browser("iBasis Customer Portal").Page("Admin").WebElement("Yes").Exist(5) = "True" Then
		Browser("iBasis Customer Portal").Page("Admin").WebElement("Yes").Click
	End If

	'Sync
	If fSyncByImage(60) = False Then
		Reporter.ReportEvent micFail, "fGuiDeleteUser", "Delete Customer User was failed"
		Call fWriteHtmlReportRow("fGuiDeleteUser - Admin", "sync for refresh data", "FAIL", "Delete Customer User was failed")
		fGuiDeleteUser = False
		Exit Function
	End If

	sNotification = Browser("iBasis Customer Portal").Page("Admin").WebElement("Notification").GetROProperty("innertext")
	Call fWriteHtmlReportRow("Create User" , "Check if update succeeded" , "PASS", sNotification)


	'Check if the user was deleted => one less row on the users table
	If Browser("iBasis Customer Portal").Page("Admin").WebTable("Users Table").RowCount <> iRowCount - 1 Then
		Reporter.ReportEvent micFail, "Delete User", "Delete User was failed. The user was not deleted"
		Call fWriteHtmlReportRow("Delete User" , "Check if user was deleted from the table" , "FAIL", "The user was not deleted from the table")
	End If

	'Chek if 'Users In Use' value was updated
	arrUsers = Split(Browser("iBasis Customer Portal").Page("Admin").WebElement("User Accounts in Use").GetRoProperty("outertext"),":")
	If Clng(Trim(arrUsers(1))) <> iUsersInUse - 1 Then
		Reporter.ReportEvent micFail, "Delete User", "The user was not deleted from 'User Account in Use'"
		Call fWriteHtmlReportRow("Delete User" , "Check if 'Users In Use' value was updated" , "FAIL", "The user was not deleted from 'User Account in Use'")
	End If

    'sing out
	Browser("iBasis Customer Portal").Page("Admin").Link("Logout").Click
	If Browser("iBasis Customer Portal").Page("Login").WebEdit("username").Exist(10) = "False"  Then
		Reporter.ReportEvent micFail, "Delete User", "Customer User - Delete User was failed"
		Call fWriteHtmlReportRow("Delete User - Admin", "Sign out - Check if Login page was opened", "FAIL", "Open Login page failed")
		fGuiDeleteUser = False
		Exit Function
	End If
	

	'try to login with the DELETED username and password
	Browser("iBasis Customer Portal").Page("Login").WebEdit("username").Set globaldictionary("USERNAME")
	Browser("iBasis Customer Portal").Page("Login").WebEdit("password").Set globaldictionary("PASSWORD")
	Browser("iBasis Customer Portal").Page("Login").Image("signInButton").Click

	If NOT Browser("iBasis Customer Portal").Page("Login").WebElement("Authentication failed").Exist(3) Then
		Reporter.ReportEvent micFail, "Delete User", "Delete User was failed - Login with the DELETED username and password succeeded"
		Call fWriteHtmlReportRow("Delete User" , "Login with the DELETED username and password" , "FAIL", "Login with the DELETED username and password succeeded")
	End If

    fGuiDeleteUser = True
End Function
'##################################################################


'###########################################################
' Function name: fGetTableAndColumnName
' Description:  Return Name of Table and Column in DB
' Parameters:	Protlet Name, Columns names
' Return value:  Success - True
' Example:
'###########################################################
Public Function fGetTableAndColumnName(ByRef sTable, ByRef sColumnName, ByRef sCurrency)

  Select Case lcase(sTable)

		Case "unbilled traffic"
   			sTable = "" & SCHEMA & "cust_unbilled"

			Select Case lcase(sColumnName)
				Case "destination name"
					sColumnName = "destination_name"
				Case "minutes / message"
					sColumnName = "Minutes"
				Case "total charges"
					sColumnName = "Amount"
				Case "currency"
					sColumnName = "Currency"
			End Select

			If Not IsNull(sCurrency) Then
				sCurrency = "Currency"
			End If

		Case "open transactions"
   			sTable = "" & SCHEMA & "Customer_Billed_Trans"

			Select Case lcase(sColumnName)
				Case "transaction type"
					sColumnName = "ITEM_TYPE"
				Case "reference"
					sColumnName = "DOCUMENT_REFERENCE"
				Case "document date"
					sColumnName = "DOCUMENT_DATE"
				Case "due date"
					sColumnName = "DUE_DATE"
				Case "total amount"
					sColumnName = "DOCUMENT_AMOUNT"
				Case "open amount"
					sColumnName = "OPEN_AMOUNT"
				Case "currency"
					sColumnName = "DOCUMENT_CURRENCY"
			End Select

			If Not IsNull(sCurrency) Then
				sCurrency = "DOCUMENT_CURRENCY"
			End If

		Case "invoices"
	   		sTable = "" & SCHEMA & "Customer_Invoice_History"

			Select Case lcase(sColumnName)
				Case "invoice id"
					sColumnName = "DOCUMENT_REFERENCE"
				Case "invoice date"
					sColumnName = "DOCUMENT_DATE"
				Case "invoice amount"
					sColumnName = "DOCUMENT_AMOUNT"
				Case "paid amount"
					sColumnName = "PAID_AMOUNT"
				Case "other cleared amount"
					sColumnName = "CLEARED_AMOUNT"
				Case "open amount"
					sColumnName = "OPEN_AMOUNT"
				Case "currency"
					sColumnName = "DOCUMENT_CURRENCY"
			End Select

			If Not IsNull(sCurrency) Then
				sCurrency = "DOCUMENT_CURRENCY"
			End If

		Case "payments / credits"
			sTable = "" & SCHEMA & "CUST_PMT_CMEMO_HIST_HEADER"

			Select Case lcase(sColumnName)
				Case "payment date"
					sColumnName = "DOCUMENT_DATE"
				Case "Reference"
					sColumnName = "DOCUMENT_REFERENCE"
				Case "amount"
					sColumnName = "DOCUMENT_AMOUNT"
				Case "currency"
					sColumnName = "DOCUMENT_CURRENCY"
			End Select

			If Not IsNull(sCurrency) Then
				sCurrency = "DOCUMENT_CURRENCY"
			End If

		Case "disputes"
            sTable = "" & SCHEMA & "CUSTOMER_DISPUTES_FROM_SAP"
			
			Select Case lcase(sColumnName)
				Case "invoice id"
					sColumnName = "DOCUMENT_REFERENCE"
				Case "dispute date"
					sColumnName = "DISPUTE_DATE"
				Case "case number"
					sColumnName = "DISPUTE_CASE_NUMBER"
				Case "invoice amount"
					sColumnName = "INVOICE_AMOUNT"
				Case "dispute amount"
					sColumnName = "DISPUTE_AMOUNT"
				Case "currency"
					sColumnName = "CURRENCY"
			End Select
				
			If Not IsNull(sCurrency) Then
				sCurrency = "CURRENCY"		
			End If

   End Select
   fGetTableAndColumnName = True
End Function

'###################################################################
'###########################################################
' Function name: fSyncByImage
' Description:  The function does sync according the time that was sent
' Parameters:	Protlet Name, Columns names
' Return value:  Success - True, time over - False
' Example:
'###########################################################
Public Function fSyncByImage(ByVal iTime)
  	iCounter = 1
	wait 2
	While ((Ucase(Browser("iBasis Customer Portal").Page("All Pages").WebElement("class:=v-loading-indicator.*","index:=0").Object.style.display) = "BLOCK" OR Ucase(Browser("iBasis Customer Portal").Page("All Pages").WebElement("class:=v-loading-indicator.*","index:=1").Object.style.display) = "BLOCK" OR Ucase(Browser("iBasis Customer Portal").Page("All Pages").WebElement("class:=v-loading-indicator.*","index:=2").Object.style.display) = "BLOCK")) And iCounter <= iTime
		iCounter = iCounter + 1
		Wait 1
	Wend

	If iCounter > iTime Then
		fSyncByImage = False
	Else
		fSyncByImage = True
	End If

	
End Function
'######################################################################

'######################################################################
' Function name: fGuiCheckPageIsLoaded
' Description: Sanity test - check that a page is loaded
' Parameters: page name, parent page name, object in the page (to verify with it that the page was loaded), object type
' Return value: Success - True, Failure - Time over - False
' Example: 
'######################################################################
Public Function fGuiCheckPageIsLoaded(ByVal sPage, ByVal sParentPage, ByVal sLink, ByVal sObjectInPage, ByVal sObjectType, ByVal sSyncTime, ByVal bReturnToHome)

	If sParentPage <> "" Then
		sPagePath = sParentPage & " -> " & sPage
	Else
		sPagePath = sPage
	End If
	
	
	'Handling iView pages 
	If sParentPage = "iView" Then
		Call fGuiCheckIviewPageIsLoaded(sPage,sObjectInPage,sSyncTime)
		Exit Function
	End If
	
   'Open the specific page and validate that it was loaded properly
	'If page is GMS - navigate to it by URL (since it's an hidden page)
	If sPage = "GMS - IP Quality" Then 'in
		sURL = Browser("iBasis Customer Portal").GetRoProperty ("Url")
		sURL = left(sURL,len(sURL) - 4)
		Browser("iBasis Customer Portal").Navigate sURL & "gms-ip-quality"
	'Click on the parent page link
	Else
		If sParentPage <> "" Then
			Select Case lcase(sParentPage)
				Case lcase("KPIs"), lcase("InVision"), lcase("Fraud"), lcase("Ticketing")
					If Browser("iBasis Customer Portal").Page("All Pages").WebElement(sParentPage).Exist(1) = "False" Then
						Reporter.ReportEvent micFail, "fGuiCheckPageIsLoaded", "Link '" & sParentPage & "' is missing in the menu"
						Call fWriteHtmlReportRow("fGuiCheckPageIsLoaded", "Check if parent link exist for page '" & sPagePath & "'", "FAIL","Link '" & sParentPage & "' is missing in the menu")	
						fGuiCheckPageIsLoaded = False
						Exit Function
					End If
					Browser("iBasis Customer Portal").Page("All Pages").WebElement(sParentPage).FireEvent "OnMouseOver"
				Case else
					If Browser("iBasis Customer Portal").Page("All Pages").Link(sParentPage).Exist(1) = "False" Then
						Reporter.ReportEvent micFail, "fGuiCheckPageIsLoaded", "Link '" & sParentPage & "' is missing in the menu"
						Call fWriteHtmlReportRow("fGuiCheckPageIsLoaded", "Check if parent link exist for page '" & sPagePath & "'", "FAIL","Link '" & sParentPage & "' is missing in the menu")	
						fGuiCheckPageIsLoaded = False
						Exit Function
					End If
					Browser("iBasis Customer Portal").Page("All Pages").Link(sParentPage).FireEvent "OnMouseOver"
			End Select	
		End If
		
	   'Click on the page link
		'In case of 'Fraud Custom Rules Details' page - Click on 
		If sPage = "Fraud Custom Rules Details" Then
			If Browser("iBasis Customer Portal").Page("All Pages").Link("Fraud Custom Rules").Exist(1) = "False" Then
				Reporter.ReportEvent micFail, "fGuiCheckPageIsLoaded", "Link '" & sPage & "' is missing in the menu"
				Call fWriteHtmlReportRow("fGuiCheckPageIsLoaded", "Check if link exist for page '" & sPagePath & "'", "FAIL","Link '" & sPagePath & "' is missing in the menu")	
				fGuiCheckPageIsLoaded = False
				Exit Function
			End If
			Browser("iBasis Customer Portal").Page("All Pages").Link("Fraud Custom Rules").Click
			wait(1)
			Browser("iBasis Customer Portal").Page("Fraud Custom Rules").WebElement("New Rule Button").Click
		
		Else 'All other pages -Click on the page link
			If Browser("iBasis Customer Portal").Page("All Pages").Link(sPage).Exist(1) = "False" Then
					Reporter.ReportEvent micFail, "fGuiCheckPageIsLoaded", "Link '" & sPage & "' is missing in the menu"
					Call fWriteHtmlReportRow("fGuiCheckPageIsLoaded", "Check if link exist for page '" & sPagePath & "'", "FAIL","Link '" & sPagePath & "' is missing in the menu")	
					fGuiCheckPageIsLoaded = False
					Exit Function
			End If
		Browser("iBasis Customer Portal").Page("All Pages").Link(sPage).Click
		End If
	End If
		
	'Close a dialog if exist (A dialog appear when no records found for Ticketing pages)
	If lcase(sParentPage) = lcase("Ticketing") Then
		If Browser("iBasis Customer Portal").Dialog("Message from webpage").Exist(10) = "True" Then
			Browser("iBasis Customer Portal").Dialog("Message from webpage").WinButton("OK").Click
		End If
	End If	

'In case of 'Key Diameter Reports', 'IPX Key Metrics' and 'Advanced Diameter Reports'
		'If sPage = "Key Diameter Reports" Or sPage = "IPX Key Metrics" Then 'Or "Advanced Diameter Reports" Then 
		If sLink <> "" Then
				Browser("iBasis Customer Portal").Page(sPage).Link(sLink).Click
				If sLink = "IR.34 Key Metrics" Then
				Browser("iBasis Customer Portal").Page(sPage).Link(sLink).Click	
				End If
				sPage = sLink
		End If

'	'In case of 'Key Diameter Reports', click on the 'Signaling Volume' link
'	If sPage =  "Key Diameter Reports" Then
'		Browser("iBasis Customer Portal").Page(sPage).Link("Signaling Volume").Click
'		sPage = "Signalling Volume"		
'	End If
'	
'	'In case of 'IPX Key Metrics', click on the 'Signalling Volume' link
'	If sPage =  "IPX Key Metrics" Then
'		Browser("iBasis Customer Portal").Page(sPage).Link("IR.34 Key Metrics").Click
'		sPage = "IR.34 Key Metrics"		
'	End If

	'Sync to find an obect in the page to verify that the page was loaded properly
	If fSyncByObject ("fGuiCheckPageIsLoaded","iBasis Customer Portal",sPage,sObjectType,sObjectInPage,sSyncTime,"Verify that '" & sPagePath & "' page was loaded properly",sPage &" page was not loaded properly",sPage & " page was loaded properly") = False Then
		fGuiCheckPageIsLoaded = False
	End If

	'Return to home page
	If bReturnToHome Then
		Browser("iBasis Customer Portal").Page("All Pages").Link("Home").Click
		wait(3)
	End If
		
	fGuiCheckPageIsLoaded = True

End Function
'######################################################################

'######################################################################
' Function name: fGuiCheckIviewPageIsLoaded
' Description: Sanity test - check that iView page is loaded
' Parameters: page name, parent page name, object in the page (to verify with it that the page was loaded), object type
' Return value: Success - True, Failure - Time over - False
' Example: 
'######################################################################
Public Function fGuiCheckIviewPageIsLoaded(ByVal sPage, ByVal sObjectInPage, ByVal sSyncTime)
	
	'---- For iView pages - disable the popupblock
		'Create the shell object
		Set WshShell = CreateObject("WScript.Shell")
		'Path to edit in registry
		popupKeyPath = "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\New Windows\PopupMgr"
		'Disable the IE pop-up blocker
		WshShell.RegWrite popupKeyPath, "no"

	'---- Open the iView page and validate that it was loaded properly
		Browser("iBasis Customer Portal").Page("All Pages").WebElement("iView").FireEvent "OnMouseOver"
		Browser("iBasis Customer Portal").Page("All Pages").Link(sPage).Click
		wait(5)
		
		'Confirm the Certificate Error if appear
		If Browser("iView").Page("Certificate Error").Exist(3) = "True" Then
			 Browser("iView").Page("Certificate Error").Link("Continue link").Click
		End If
				
		'Validate that the iView window was loaded properly
		Call fSyncByObject ("fGuiCheckIviewPageIsLoaded","iView","iView","WebElement", sObjectInPage,sSyncTime,"Verify that 'iView -> " & sPage & "' page was loaded properly" ,sPage &" page was not loaded properly",sPage & " page was loaded properly")
				
		
	'---- Close the iView tab 
		Browser("iView").WinObject("WinObject").WinButton("Close Tab").Click
	
	'---- Return to home page
		Browser("iBasis Customer Portal").Page("All Pages").Link("Home").Click
		wait(3)
	
		'Enable the IE pop-up blocker back 
		WshShell.RegWrite popupKeyPath, "yes"
		
End Function
'######################################################################

'######################################################################
' Function name: fSyncByObject
' Description: The function wait for synchronization by object – Wait to the object to appear on UI.
' Parameters: iTime - Max time [in seconds] to wait to sync, Object to sync by [name and type]					
' Return value: Success - True, Failure - Time over - False
' Example: Call fSyncByObject("fSelectCustomer","iBasis Customer Portal","Finance","Link", "Welcome",30)
'######################################################################
Public Function fSyncByObject(sFuncName, sBrowser, sPage, sObjType, sObjName, iTime, sStepDescription, sErrorDescription, sSuccessDescription)

	Dim sStr, sRes

    sStr = "sRes = Browser(sBrowser).Page(sPage).sObjType(sObjName).Exist(iTime)"
	sStr = replace(sStr,"sObjType",sObjType)
    Execute sStr 

	If sStepDescription = "" Then
		sStepDescription = "Sync By Object"
	End If
	If sErrorDescription = "" Then
		sErrorDescription = "Object: " & sObjName & " on page: " & sPage & " was not found"
	End If
	
	If sRes = False Then
		Call fCaptureScreen(sBrowser, sFuncName, sStepDescription, sErrorDescription & vbNewLine & "(after " & iTime & " seconds)")		
        fSyncByObject = False
	Else
		If sSuccessDescription <> "" Then
			Reporter.ReportEvent micPass, sFuncName & " - " & "fSyncByObject", sSuccessDescription
			Call fWriteHtmlReportRow(sFuncName & " - " & "fSyncByObject", sStepDescription, "PASS",sSuccessDescription)	
		End If		
        fSyncByObject = True
	End If
	
End Function
'######################################################################

'######################################################################
' Function name: fVerifyObjectDoesNotExist
' Description: The function wait for synchronization by object – Verify that the object does NOT appear on UI.
' Parameters: iTime - Max time [in seconds] to wait to sync, Object to sync by [name and type]					
' Return value: Success - True, Failure - Time over - False
' Example: 
'######################################################################
Public Function fVerifyObjectDoesNotExist(sFuncName, sBrowser, sPage, sObjType, sObjName, iTime, sErrorDescription, sSuccessDescription)

	Dim sStr, sRes

    sStr = "sRes = Browser(sBrowser).Page(sPage).sObjType(sObjName).Exist(iTime)"
	sStr = replace(sStr,"sObjType",sObjType)
    Execute sStr 

	If sRes = True Then
		If sErrorDescription <> "" Then
			Reporter.ReportEvent micFail, sFuncName & " - " & "fSyncByObject", sErrorDescription
			Call fWriteHtmlReportRow(sFuncName & " - " & "fSyncByObject", "Sync By Object", "FAIL",sErrorDescription)	
		Else
			Reporter.ReportEvent micFail, sFuncName & " - " & "fSyncByObject", "Object: " & sObjName & " on page: " & sPage & " was found (Expected: it should not found)"
			Call fWriteHtmlReportRow(sFuncName & " - " & "fSyncByObject", "Sync By Object", "FAIL","Object: " & sObjName & " on page: " & sPage & " was found (Expected: it should not found)")
		End If		
        fSyncByObject = False
	Else
		If sSuccessDescription <> "" Then
			Reporter.ReportEvent micPass, sFuncName & " - " & "fSyncByObject", sSuccessDescription
			Call fWriteHtmlReportRow(sFuncName & " - " & "fSyncByObject", "Sync By Object", "PASS",sSuccessDescription)	
		End If		
        fSyncByObject = True
	End If
	
End Function
'######################################################################

'######################################################################

Public Function fVerifyCloseWindow(ByVal iTime, ByVal sProtletName, ByVal sWindowName)

'	wait 10
'	fVerifyCloseWindow = true

	Dim iCounter

	iCounter = 1

	While Browser("iBasis Customer Portal").Page(sProtletName).WebElement(sWindowName).Exist(0) = "True" And iCounter <= iTime
		Wait 1
		iCounter = iCounter + 1
	Wend

	If iCounter > iTime Then
		fVerifyCloseWindow = False
	Else
		fVerifyCloseWindow = True
	End If


End Function

'#####################################################################
Public Function fReturnViewer(ByVal objRS, ByVal str)

   bFound = False

			objRS.MoveFirst
			Do While Not objRS.EOF
				If Instr(1,lCase(objRS.Fields(0).Value), lCase(str)) > 0 Then
					bFound = True
					fReturnViewer = True
					Exit Do
				Else
					objRS.MoveNext
				End If
			Loop
			If bFound = False Then
				fReturnViewer = False
			End If
End Function
'####################################################################
Public Function fCompareOrgRolesToUserRoles_(ByVal objRsOrg ,ByVal objRsUser)
'
'   bFound = False
'
'			objRsOrg.MoveFirst
'        	Do While Not objRsOrg.EOF
'				objRsUser.MoveFirst
'				Do While Not objRsUser.EOF
'					If objRsOrg.Fields(0).Value = objRsUser.Fields(0).Value Then
'						bFound = True
'						Exit Do
'					Else
'						objRsUser.MoveNext
'					End If
'				Loop
'				If bFound = False Then
'					Reporter.ReportEvent micFail, "fCompareOrgRolesToUserRoles", "The role: "& objRsOrg.Fields(0).Value &" from organization roles, was not found in users roles for Administrator"
'					Call fWriteHtmlReportRow(fCompareOrgRolesToUserRoles, "Check if all organization roles appear in admin user roles" , "FAIL", "The role: "& objRsOrg.Fields(0).Value &" from organization roles, was not found in users roles for Administrator")
'				End If
'			Loop
'			If bFound = False Then
'				fCompareOrgRolesToUserRoles = False
'			End If
'
End Function
'###########################################################

'###########################################################
' Function name: fGetIBasisExposure
' Description: 
' Parameters:	customer id
' Return value:  Exposure
' Example:
'###########################################################
Public Function fGetIBasisExposure(iId) 

'	sSQL = "select sum(AmountInUSDollar) from (" & _
'		"select customer_id,document_currency,sum(open_amount) as amount,sum(open_amount) * nvl((select  rate from " & SCHEMA & "EXCHANGE_RATE e where E.FROM_CURRENCY = amount_sum_by_currency.document_currency and e.TO_CURRENCY ='USD'),1) as AmountInUSDollar " & _
'		"from(" & _
'			   "SELECT CB.CUSTOMER_ID ,cb.open_amount,cb.document_currency from " & SCHEMA & "CUSTOMER_BILLED_TRANS cb where CB.CUSTOMER_ID in (select cm.id from " & SCHEMA & "CUSTOMER_MASTER cm where cm.id != CM.HEADQUARTERS) " & _
'			   "union all SELECT CM.HEADQUARTERS, cb.open_amount,cb.document_currency from " & SCHEMA & "CUSTOMER_BILLED_TRANS cb," & SCHEMA & "CUSTOMER_MASTER cm where CB.CUSTOMER_ID = CM.id " & _
'			   "union all SELECT CB.CUSTOMER_ID ,cb.amount,cb.currency from " & SCHEMA & "CUST_SELF_DECLARED_SAP cb where CB.CUSTOMER_ID in (select cm.id from " & SCHEMA & "CUSTOMER_MASTER cm where  cm.id != CM.HEADQUARTERS) " & _
'			   "union all SELECT CM.HEADQUARTERS, cb.amount,cb.currency from " & SCHEMA & "CUST_SELF_DECLARED_SAP cb," & SCHEMA & "CUSTOMER_MASTER cm where CB.CUSTOMER_ID = CM.id " & _  
'			   "union all SELECT CB.CUSTOMER_ID ,cb.amount,cb.currency from " & SCHEMA & "CUST_UNBILLED cb where CB.CUSTOMER_ID in (select cm.id from " & SCHEMA & "CUSTOMER_MASTER cm where  cm.id != CM.HEADQUARTERS) " & _ 
'			   "union all SELECT CM.HEADQUARTERS, cb.amount,cb.currency from " & SCHEMA & "CUST_UNBILLED cb," & SCHEMA & "CUSTOMER_MASTER cm where CB.CUSTOMER_ID = CM.id " & _ 
'			   "union all SELECT cm.id as customer_id,vb.amount as open_amount,vb.currency as document_currency from " & SCHEMA & "VENDOR_OPEN_PO_BALANCE vb," & SCHEMA & "customer_master cm where vb.vendor_id in (select vm.vendor_id from " & SCHEMA & "VEndor_MASTER vm where  vm.vendor_id != vm.HEADQUARTERS) and CM.VENDOR_ID = vb.vendor_id union all select CM2.HEADQUARTERS,VB.AMOUNT,VB.CURRENCY from " & SCHEMA & "customer_master cm1  join " & SCHEMA & "customer_master cm2 on cm1.id = cm2.id join " & SCHEMA & "VENDOR_OPEN_PO_BALANCE vb on CM1.VENDOR_ID = VB.VENDOR_ID " & _
'			   "union all SELECT cm.id as customer_id,vb.amount as open_amount,vb.currency as document_currency from " & SCHEMA & "VENDOR_BILLED_SUMMARY vb," & SCHEMA & "customer_master cm where vb.vendor_id in (select vm.vendor_id from " & SCHEMA & "VEndor_MASTER vm where  vm.vendor_id != vm.HEADQUARTERS) and CM.VENDOR_ID = vb.vendor_id union all select CM2.HEADQUARTERS,VB.AMOUNT,VB.CURRENCY from " & SCHEMA & "customer_master cm1  join " & SCHEMA & "customer_master cm2 on cm1.id = cm2.id join " & SCHEMA & "VENDOR_BILLED_SUMMARY vb on CM1.VENDOR_ID = VB.VENDOR_ID " & _ 
'			   "union all SELECT cm.id as customer_id,vb.amount as open_amount,vb.currency as document_currency from " & SCHEMA & "VEND_UNBILLED vb," & SCHEMA & "customer_master cm where vb.vendor_id in (select vm.vendor_id from " & SCHEMA & "VEndor_MASTER vm where  vm.vendor_id != vm.HEADQUARTERS) and CM.VENDOR_ID = vb.vendor_id union all select CM2.HEADQUARTERS,VB.AMOUNT,VB.CURRENCY from " & SCHEMA & "customer_master cm1  join " & SCHEMA & "customer_master cm2 on cm1.id = cm2.id join " & SCHEMA & "VEND_UNBILLED vb on CM1.VENDOR_ID = VB.VENDOR_ID " & _ 
'			 ") amount_sum_by_currency group by customer_id,document_currency " & _ 
'	")amount_sum_in_us_dollar " & _
'	"WHERE customer_id = " & iId & _
'	" group by customer_id"

	sSQL = "select sum(AmountInUSDollar) " & _ 
	"from ( " & _
		"select currency,sum(amount) as amount,sum(amount) * nvl((select rate from " & SCHEMA & "EXCHANGE_RATE e where e.FROM_CURRENCY = amount_sum_by_currency.currency and e.TO_CURRENCY = 'USD'),1) as AmountInUSDollar " & _
		"from( " & _
			"select c.open_amount as amount, c.document_currency as currency from " & SCHEMA & "CUSTOMER_BILLED_TRANS c where customer_id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS = "& iId & ") " & _
			"UNION ALL select c.amount, c.currency from " & SCHEMA & "CUST_UNBILLED c where customer_id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS = "& iId & ") " & _
			"UNION ALL select c.amount, c.currency from " & SCHEMA & "CUST_SELF_DECLARED_SAP c where customer_id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS = "& iId & ") " & _
			"UNION ALL select v.amount, v.currency from " & SCHEMA & "VENDOR_BILLED_SUMMARY v where vendor_id in (select vendor_id from " & SCHEMA & "vendor_master where headquarters in(select distinct vendor_id from " & SCHEMA & "customer_master where id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS= "& iId & ")) or vendor_id in (select distinct vendor_id from " & SCHEMA & "customer_master where id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS= "& iId & "))) " & _
			"UNION ALL select v.amount, v.currency from " & SCHEMA & "VEND_UNBILLED v where vendor_id in (select vendor_id from " & SCHEMA & "vendor_master where headquarters in(select distinct vendor_id from " & SCHEMA & "customer_master where id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS= "& iId & ")) or vendor_id in (select distinct vendor_id from " & SCHEMA & "customer_master where id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS= "& iId & "))) " & _
			"UNION ALL select v.amount, v.currency from " & SCHEMA & "VENDOR_OPEN_PO_BALANCE v where vendor_id in (select vendor_id from " & SCHEMA & "vendor_master where headquarters in(select distinct vendor_id from " & SCHEMA & "customer_master where id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS= "& iId & ")) or vendor_id in (select distinct vendor_id from " & SCHEMA & "customer_master where id in (select id from " & SCHEMA & "customer_master where HEADQUARTERS= "& iId & "))) " & _
			") amount_sum_by_currency " & _
	"group by currency " & _ 
	") amount_sum_in_us_dollar"
	
	rc = fDBGetOneValue("BILLING", sSQL, sIBasisExposure)

	If rc = False Then
		Reporter.ReportEvent micFail, "fGetIBasisExposure ", "Connetion to DB was failed."
		Call fWriteHtmlReportRow("fGetIBasisExposure ", "Check the connection to DB", "FAIL","Connetion to DB was failed")
		fGetIBasisExposure = False
		Exit Function
	ElseIf rc = NO_RECORDS_FOUND Then
		Reporter.ReportEvent micWarning, "fGetIBasisExposure", "No value returned by the query (- iBasis Exposure Calculation)"
		Call fWriteHtmlReportRow("fGetIBasisExposure ", "Check if records returned from DB", "INFO","No records found (- iBasis Exposure Calculation)")
		fGetIBasisExposure = False
		Exit Function
	End If

	fGetIBasisExposure = Round(Cdbl(sIBasisExposure), 2)
End Function
'###########################################################

'###########################################################
' Function name: fGuiAlerts
' Description: The function create an HTML report that supply details for the alerts that customers are expected to receive
' Parameters: Customers ids list (in the parameters excel)
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiAlerts()

   Dim i, sSQL, sCustName, sEstimatedBalance, sIBasisExposure, sRemainingBalance, sCustomerCurrency, sExpectedAlert
   Dim sLastStatus, sRiskCategory, sCreditLimit, sType, sCredit
	'Create report for expected Alerts
   Call fCreateHtmlReportAlerts()

   i = 1
   While GlobalDictionary("CUSTOMER_ID_" & i) <> ""

	iId = GlobalDictionary("CUSTOMER_ID_" & i)	

	'-------------- Find customer's exposure --------------
	sIBasisExposure = fGetIBasisExposure(iId)
		
	'-------------- Find customer's details --------------

		sSQL = "Select Name, Credit_limit, Risk_Category From " & SCHEMA & "CUSTOMER_MASTER Where ID =" & iId	
		rc = fDBGetRS ("BILLING", sSQL, objRS)

		'Check fDBGetRS returned value
		If rc = False Then
			Reporter.ReportEvent micFail, "fGuiAlerts", "Connetion to DB was failed (-Customer's credit limit)"
			Call fWriteHtmlReportRow("fGuiAlerts", "Check the connection to DB", "FAIL","Connetion to DB was failed (-Customer's credit limit)")
			fGuiAlerts = False
			Exit Function
		ElseIf rc = NO_RECORDS_FOUND Then
			Reporter.ReportEvent micWarning, "fGuiAlerts", "No records returned by the query (-Customer's credit limit)"
			Call fWriteHtmlReportRow("fGuiAlerts", "Check if records returned from DB", "INFO","No records returned by the query (-Customer's credit limit)")
			fGuiAlerts = False
			Exit Function
		End If

		sCustName = objRS.Fields("Name").Value
		sRiskCategory = objRS.Fields("Risk_Category").Value
		sCredit = Cdbl(objRS.Fields("Credit_limit").Value)

		'Find customer's type
		If sCredit = 0 Then
			sType = "Pre-Paid"
		Else
			sType = "Post-Paid"
		End If
		 
		'Find customer's default currency
		sSQL = "SELECT CURRENCY FROM ECARE_CUSTOMER_DETAILS WHERE CUSTOMER_ID = " & iId
        rc = fDBGetOneValue("BILLING", sSQL, sCurrency)
	

		If rc = False Then
			Reporter.ReportEvent micFail, "fGuiAlerts ", "Connetion to DB was failed. (-customer's default currency)"
			Call fWriteHtmlReportRow("fGuiAlerts ", "Check the connection to DB", "FAIL","Connetion to DB was failed (-customer's default currency) ")
			fGuiAlerts = False
			Exit Function
		ElseIf rc = NO_RECORDS_FOUND Then
			Reporter.ReportEvent micWarning, "fGuiAlerts", "No value returned by the query (- customer's default currency)"
			Call fWriteHtmlReportRow("fGuiAlerts ", "Check if records returned from DB", "INFO","No records found (- customer's default currency)")
			fGuiAlerts = False
			Exit Function
		End If
		sCustomerCurrency = sCurrency

	'-------------- Find customer's Credit Limit (HQ and Children * ExchangeRate) --------------
		Dim iSumCredit
	
		'Build and execute a SQL query to retrieve all credit limit of customer HQ and his children
		sSQL = "SELECT credit_limit, credit_currency FROM " & SCHEMA & "CUSTOMER_MASTER WHERE ID in(SELECT ID From " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters =" & iId &")"
		rc = fDBGetRS ("BILLING", sSQL, objRS)
	
		'Check fDBGetRS returned value
		If rc = False Then
			Reporter.ReportEvent micFail, "fGuiAlerts", "Connetion to DB was failed (-Find Customer's credit limit)"
			Call fWriteHtmlReportRow("fGuiAlerts", "Check the connection to DB", "FAIL","Connetion to DB was failed (-Find Customer's credit limit)")
			fGuiAlerts = False
			Exit Function
		ElseIf rc = NO_RECORDS_FOUND Then
			Reporter.ReportEvent micWarning, "fGuiAlerts", "No records returned by the query (-Find Customer's credit limit)"
			Call fWriteHtmlReportRow("fGuiAlerts", "Check if records returned from DB", "INFO","No records returned by the query (-Find Customer's credit limit)")
			fGuiAlerts = False
			Exit Function
		End If
	
		'Summarize all credit limit sums
		iSumCredit = 0
		objRS.MoveFirst
		While Not objRS.EOF
			iSumCredit = iSumCredit + fExchageRate(Cdbl(objRS.Fields("credit_limit").Value), objRS.Fields("credit_currency").Value, sCurrency)
			objRS.MoveNext
		Wend
		iSumCredit = Round(cdbl(iSumCredit),0)

		sCreditLimit = iSumCredit

		'-------------- Find customer's last status --------------

		sSQL = "SELECT RISK_SEVERITY FROM ECARE_CUST_LAST_SEVERITY_ALERT WHERE CUSTOMER_ID = " & iId
        rc = fDBGetOneValue("BILLING", sSQL, sLastStatus)
	
		If rc = False Then
			Reporter.ReportEvent micFail, "fGuiAlerts ", "Connetion to DB was failed. (-customer's last status)"
			Call fWriteHtmlReportRow("fGuiAlerts ", "Check the connection to DB", "FAIL","Connetion to DB was failed (-customer's last status)")
			fGuiAlerts = False
			Exit Function
		ElseIf rc = NO_RECORDS_FOUND Then
			sLastStatus = -1
		End If
		
    	Select Case sLastStatus
			Case -1
				sLastStatus = "Clear"
			Case 0
				sLastStatus = "Info"
			Case 1
				sLastStatus = "Warning"
			Case 2
				sLastStatus = "Critical"
			Case 3
				sLastStatus = "Blocked"
		End Select

		'--------------Find Estimated Balance ------------------
		'Build Unbilled Traffic query
		sSQL = "SELECT amount, currency FROM " & SCHEMA & "CUST_UNBILLED  WHERE SELF_DECLARE_FLAG = 0 AND CUSTOMER_ID in(SELECT ID From " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters = " & iId &")"
		rc = fDBGetRS ("BILLING", sSQL, objRS)
	
		'Check fDBGetRS returned value
		If rc = False Then
			Reporter.ReportEvent micFail, "fGuiAlerts - Unbilled", "Protlet: Home - Connetion to DB was failed."
			Call fWriteHtmlReportRow("fGuiAlerts-Unbilled", "Check the connection to DB", "FAIL","Connetion to DB was failed")
			fGuiAlerts = False
		ElseIf rc = NO_RECORDS_FOUND Then
			Reporter.ReportEvent micWarning, "fGuiAlerts - Unbilled", "Protlet: Home - No records returned by the query."
			Call fWriteHtmlReportRow("fGuiAlerts - Unbilled", "Check if records returned from DB", "INFO","No records returned by the query")
			fGuiAlerts = False
		End If
	
		'Summarize all Unbilled sums
		iSumUnbilled = 0
		objRS.MoveFirst
		While Not objRS.EOF
			iSumUnbilled = iSumUnbilled + fExchageRate(Cdbl(objRS.Fields("amount").Value), objRS.Fields("currency").Value, sCurrency)
			objRS.MoveNext
		Wend
			
	'	-----------------
	
		'Build Billed Tramsactions query
		sSQL = "SELECT DOCUMENT_AMOUNT,DOCUMENT_CURRENCY FROM " & SCHEMA & "CUSTOMER_BILLED_TRANS  WHERE CUSTOMER_ID in(SELECT ID From " & SCHEMA & "CUSTOMER_MASTER WHERE headquarters = " & iId &")"
		rc = fDBGetRS ("BILLING", sSQL, objRS)
	
		'Check fDBGetRS returned value
		If rc = False Then
			Reporter.ReportEvent micFail, "fGuiAlerts - Billed", "Protlet: Finance - Connetion to DB was failed."
			Call fWriteHtmlReportRow("fGuiAlerts-Billed", "Check the connection to DB", "FAIL","Connetion to DB was failed")
			fGuiAlerts = False
		ElseIf rc = NO_RECORDS_FOUND Then
			Reporter.ReportEvent micWarning, "fGuiAlerts - Billed", "Protlet: Finance - No records returned by the query."
			Call fWriteHtmlReportRow("fGuiAlerts - Billed", "Check if records returned from DB", "INFO","No records returned by the query")
			fGuiAlerts = False
		End If
	
		'Summarize all Billed sums
		iSumBilled = 0
		objRS.MoveFirst
		While Not objRS.EOF
			iSumBilled = iSumBilled + fExchageRate(Cdbl(objRS.Fields("DOCUMENT_AMOUNT")), objRS.Fields("DOCUMENT_CURRENCY").Value, sCurrency)
			objRS.MoveNext
		Wend

    	sEstimatedBalance = Round(cdbl(iSumUnbilled + iSumBilled),0)
        sEstimatedBalance = sEstimatedBalance * -1

 	
		'-------------- Find Expected Alert Type --------------
		Dim iCreditInUSD, sCurrentStatus
		sCurrentStatus = ""

		iCreditInUSD = fExchageRate(Cdbl(sCreditLimit), sCurrency, "USD")
		sExpectedAlert = fExpectedAlert(sType, sRiskCategory, iCreditInUSD, sIBasisExposure, sLastStatus, sCurrentStatus)

		If sExpectedAlert <> False Then
			
			sIBasisExposure = fExchageRate(Cdbl(sIBasisExposure),"USD", sCurrency)

			sRemainingBalance = cdbl(sCreditLimit) - cdbl(sIBasisExposure)
			'sRemainingBalance = fExchageRate(Cdbl(sRemainingBalance),"USD", sCurrency)
			sRemainingBalance = Round(sRemainingBalance,0)

			sIBasisExposure = Round(sIBasisExposure, 0)
            sIBasisExposure = sIBasisExposure * -1

			Call fWriteHtmlReportAlerts(iId, sCustName, sCreditLimit, sEstimatedBalance, sIBasisExposure, sRemainingBalance, sCustomerCurrency, sLastStatus, sCurrentStatus, sExpectedAlert)
           
		End If
		i = i + 1
	Wend

	fGuiAlerts = True
End Function
'###########################################################

'###########################################################
' Function name: fExpectedAlert
' Description: 
' Parameters: 
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fExpectedAlert(ByVal sType, ByVal sRiskCategory, ByVal sCreditLimit, ByVal sIBasisExposure, ByVal sLastStatus, ByRef sCurrentStatus)

	Dim sSQL, sCurrentSeverity, iExposure

	iExposure = cdbl(sIBasisExposure)

	Select Case sType

		Case "Pre-Paid"
			sSQL = "SELECT INFO, WARNING, CRITICAL, BLOCK, ALERT_NOC_TO_BLOCK FROM ECARE_PRE_PAID_ALERTS WHERE RISK_CATEGORY = '" & sRiskCategory & "'"  
			rc = fDBGetRS ("BILLING", sSQL, objRS)
	
			'Check fDBGetRS returned value
			If rc = False Then
				Reporter.ReportEvent micFail, "fExpectedAlert", "Connetion to DB was failed (-Find Expected Alert)"
				Call fWriteHtmlReportRow("fExpectedAlert", "Check the connection to DB", "FAIL","Connetion to DB was failed (-Find Expected Alert)")
				fExpectedAlert = False
				Exit Function
			ElseIf rc = NO_RECORDS_FOUND Then
				Reporter.ReportEvent micWarning, "fGuifExpectedAlertAlerts", "No records returned by the query (-Find Expected Alert)"
				Call fWriteHtmlReportRow("fExpectedAlert", "Check if records returned from DB", "INFO","No records returned by the query (-Find Expected Alert)")
				fExpectedAlert = False
				Exit Function
			End If

			
'			If (NOT IsNull(objRS.Fields("INFO").Value) and iExposure > cdbl(objRS.Fields("INFO").Value) AND iExposure < cdbl(objRS.Fields("WARNING").Value)) and (sLastStatus = "Clear") Then
'				fExpectedAlert = "Pre-Paid Info Alert"
'			ElseIf (NOT IsNull(objRS.Fields("WARNING").Value) and iExposure > cdbl(objRS.Fields("WARNING").Value) AND iExposure < cdbl(objRS.Fields("CRITICAL").Value)) and (sLastStatus = "Clear" Or sLastStatus = "Info") Then
'				fExpectedAlert = "Pre-Paid Warning Alert"
'			ElseIf (NOT IsNull(objRS.Fields("CRITICAL").Value) and iExposure > cdbl(objRS.Fields("CRITICAL").Value) AND iExposure < cdbl(objRS.Fields("BLOCK").Value)) and (sLastStatus = "Clear" Or sLastStatus = "Info" Or sLastStatus = "Warning") Then
'				fExpectedAlert = "Pre-Paid Critical Alert"
'			ElseIf (NOT IsNull(objRS.Fields("BLOCK").Value) and iExposure > cdbl(objRS.Fields("BLOCK").Value)) and (sLastStatus = "Clear" Or sLastStatus = "Info" Or sLastStatus = "Warning" Or sLastStatus = "Critical") Then
'    			fExpectedAlert = "Pre-Paid Blocked Alert"
'				If cdbl(objRS.Fields("ALERT_NOC_TO_BLOCK").Value) = 1 Then
'					fExpectedAlert = fExpectedAlert & " + NOC"
'				End If
'			Else 
'				fExpectedAlert = "Pre-Paid - No Email Alert"
'			End If

		Case "Post-Paid"

			sIBasisExposure = cdbl(sIBasisExposure) / cdbl(sCreditLimit) * 100
			iExposure = cdbl(sIBasisExposure)

			sSQL = "SELECT INFO, WARNING, CRITICAL, BLOCK, ALERT_NOC_TO_BLOCK FROM ECARE_POST_PAID_ALERTS WHERE RISK_CATEGORY = '" & sRiskCategory & "'" 
			rc = fDBGetRS ("BILLING", sSQL, objRS)

			'Check fDBGetRS returned value
			If rc = False Then
				Reporter.ReportEvent micFail, "fExpectedAlert", "Connetion to DB was failed (-Find Expected Alert)"
				Call fWriteHtmlReportRow("fExpectedAlert", "Check the connection to DB", "FAIL","Connetion to DB was failed (-Find Expected Alert)")
				fExpectedAlert = False
				Exit Function
			ElseIf rc = NO_RECORDS_FOUND Then
				Reporter.ReportEvent micWarning, "fGuifExpectedAlertAlerts", "No records returned by the query (-Find Expected Alert)"
				Call fWriteHtmlReportRow("fExpectedAlert", "Check if records returned from DB", "INFO","No records returned by the query (-Find Expected Alert)")
				fExpectedAlert = "Post-Paid - No Email Alert"
				Exit Function
			End If
		
	End Select

	'Find Expected Alert
	bFlag = False
	bNullInfo = True
	bNullWarning = True
	bNullCritical = True
	bNullBlock = True
	If NOT IsNull(objRS.Fields("INFO").Value) and bFlag = False Then
		bNullInfo = False
		If (iExposure > cdbl(objRS.Fields("INFO").Value) AND iExposure < cdbl(objRS.Fields("WARNING").Value)) Then
			sCurrentStatus = "Info"
			If(sLastStatus = "Clear") Then
				bFlag = True
				fExpectedAlert = sType & " Info Alert"
			End If
		End If
	End If

	If NOT IsNull(objRS.Fields("WARNING").Value) and bFlag = False Then
		bNullWarning = False
		If (iExposure > cdbl(objRS.Fields("WARNING").Value) AND iExposure < cdbl(objRS.Fields("CRITICAL").Value)) Then
			sCurrentStatus = "Warning"
			If(sLastStatus = "Clear" Or sLastStatus = "Info") Then
				bFlag = True
				fExpectedAlert = sType & " Warning Alert"
			End If
		End If
	End If

	If NOT IsNull(objRS.Fields("CRITICAL").Value) and bFlag = False Then
		bNullCritical = False
		If (iExposure > cdbl(objRS.Fields("CRITICAL").Value) AND iExposure < cdbl(objRS.Fields("BLOCK").Value)) Then
			sCurrentStatus = "Critical"
			If(sLastStatus = "Clear" Or sLastStatus = "Info" Or sLastStatus = "Warning") Then
				bFlag = True
				fExpectedAlert = sType & " Critical Alert"
			End If
		End If
	End If

	If NOT IsNull(objRS.Fields("BLOCK").Value) and bFlag = False Then
		bNullBlock = False
		If (iExposure > cdbl(objRS.Fields("BLOCK").Value)) Then
			sCurrentStatus = "Block"
			If(sLastStatus = "Clear" Or sLastStatus = "Info" Or sLastStatus = "Warning" Or sLastStatus = "Critical") Then
				bFlag = True
				fExpectedAlert = sType & " Blocked Alert"
				If cdbl(objRS.Fields("ALERT_NOC_TO_BLOCK").Value) = 1 Then
					fExpectedAlert = fExpectedAlert & " + NOC"
				End If 
			End If
		End If
	End If

	If fExpectedAlert = "" OR isEmpty(fExpectedAlert) Then
		sCurrentStatus = "Clear"
		If (bNullInfo <> True and bNullWarning <> True and bNullCritical <> True and bNullBlock <> True) or bFlag <> False Then
			fExpectedAlert = sType & " - No Email Alert"
		Else
			fExpectedAlert = sType & " - No Email Alert - Null alret settings"
		End If
	End If            

 

'	if (NOT IsNull(objRS.Fields("INFO").Value) and iExposure > cdbl(objRS.Fields("INFO").Value) AND iExposure < cdbl(objRS.Fields("WARNING").Value)) Then
'		sCurrentStatus = "Info"
'	ElseIf (NOT IsNull(objRS.Fields("WARNING").Value) and iExposure > cdbl(objRS.Fields("WARNING").Value) AND iExposure < cdbl(objRS.Fields("CRITICAL").Value)) Then
'		sCurrentStatus = "Warning"
'	ElseIf (NOT IsNull(objRS.Fields("CRITICAL").Value) and iExposure > cdbl(objRS.Fields("CRITICAL").Value) AND iExposure < cdbl(objRS.Fields("BLOCK").Value)) Then
'		sCurrentStatus = "Critical"
'	ElseIf (NOT IsNull(objRS.Fields("BLOCK").Value) and iExposure > cdbl(objRS.Fields("BLOCK").Value)) Then
'		sCurrentStatus = "Blocked"
'	Else 
'		sCurrentStatus = "Clear"
'	End If

End Function
'###########################################################

'###########################################################
' Function name: fGuiAddNewRoleGroup
' Description: 
' Parameters: 
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiAddNewRoleGroup()

	'Navigate to 'Role Group' Tab
   If fNavigateToTab("Role Groups", "Role Group Name:") <> True Then
	   fGuiAssignRoleGroupToOrg = False
	   Exit Function
   End If
   
   'Add new role group
	Browser("iBasis Customer Portal").Page("Global").WebElement("Add").Click
	'Sync
	If Browser("iBasis Customer Portal").Page("Global").WebElement("New Role Group").Exist(10) = "False" Then
		Reporter.ReportEvent micFail, "fGuiAddNewRoleGroup", "'New Role Group' window was not opened"
		Call fWriteHtmlReportRow("fGuiAddNewRoleGroup - Global", "New Role Group", "FAIL", "'New Role Group' window was not opened")
		fGuiAddNewRoleGroup = False
		Exit Function
	End If
	'Add new role group
	Browser("iBasis Customer Portal").Page("Global").WebEdit("New Role Group").Set globaldictionary("NEW_ROLE_GROUP")
	Browser("iBasis Customer Portal").Page("Global").WebElement("Add New Group").Click

	If Browser("iBasis Customer Portal").Page("Global").WebElement("Notification").Exist(2) = "True" Then
		sNotification = Browser("iBasis Customer Portal").Page("Global").WebElement("Notification").GetROProperty("innertext")
		If instr(1, sNotification, "already exists") > 0  Then
			Call fWriteHtmlReportRow("fGuiAddNewRoleGroup" , "Add new role group" , "FAIL", sNotification)
			fGuiAddNewRoleGroup = False
			Exit Function
		Else
			Call fWriteHtmlReportRow("fGuiAddNewRoleGroup" , "Add new role group" , "PASS", sNotification)
		End If

	End If

	'UI Verification - The new role group appears in all list(role group and available)
	If fCheckRoleGroupList(globaldictionary("NEW_ROLE_GROUP")) = False Then
		fGuiPermissionManagement = False
		Exit Function
	End If

	'DB Verification
	sSQL = "select ROLE_GROUP_ID, ROLE_GROUP_NAME from ECARE_ROLE_GROUP where ROLE_GROUP_NAME ='" & globaldictionary("NEW_ROLE_GROUP") & "'"  
	rc = fDBGetRS ("BILLING", sSQL, objRS)

	'Check fDBGetRS returned value
	If rc = False Then
		Reporter.ReportEvent micFail, "fGuiAddNewRoleGroup", "Connetion to DB was failed (-Find Expected Alert)"
		Call fWriteHtmlReportRow("fGuiAddNewRoleGroup", "Check the connection to DB", "FAIL","Connetion to DB was failed (-Find Expected Alert)")
		fGuiAddNewRoleGroup = False
		Exit Function
	ElseIf rc = NO_RECORDS_FOUND Then
		Reporter.ReportEvent micFail, "fGuiAddNewRoleGroup", "No records returned by the query (-Find Expected Alert)"
		Call fWriteHtmlReportRow("fGuiAddNewRoleGroup", "Check if records returned from DB - verify if new role group was created", "FAIL","No records returned by the query")
		fGuiAddNewRoleGroup = False
		Exit Function
	End If

	Reporter.ReportEvent micPass, "Role Group", "New Role Group : "& globaldictionary("NEW_ROLE_GROUP") &" was added to 'Role Group' table in DB"
	Call fWriteHtmlReportRow("Role Group - Global", "Check if new Role Group was added", "PASS", "New Role Group : "& globaldictionary("NEW_ROLE_GROUP") &" was added to 'Role Group' table in DB")

End Function
'###########################################################
' Function name: fGuiAssignRolestoGroup
' Description: 
' Parameters: 
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiAssignRolestoGroup()

    Dim i, sRole, sRoleGroup
	'Navigate to 'Role Group' Tab
    If fNavigateToTab("Role Groups", "Role Group Name:") <> True Then
	   fGuiAssignRolestoGroup = False
	   Exit Function
    End If
	i = 1
	While globaldictionary("ROLE"& i) <> ""

		sRole = fGetRoleName(globaldictionary("ROLE"& i))
		sRoleGroup = fFindRoleUnit(globaldictionary("ROLE"& i))

		If uCase(sRoleGroup) = uCase(globaldictionary("ASSIGN_TO_RG"))  Then
			Reporter.ReportEvent micFail, "fGuiAssignRolestoGroup", "The role " & sRole & " is already assigned to role group: " & sRoleGroup
			Call fWriteHtmlReportRow("fGuiAssignRolestoGroup", "Assign role to role group","The role " & sRole & " is already assigned to role group: " & sRoleGroup)
		Else
    	   'Assign role to role group
			Browser("iBasis Customer Portal").Page("Global").WebEdit("Select From").Set sRoleGroup
			Browser("iBasis Customer Portal").Page("Global").WebElement("list item").SetTOProperty "innertext",sRoleGroup
			If Browser("iBasis Customer Portal").Page("Global").WebElement("list item").Exist(10) Then
				Browser("iBasis Customer Portal").Page("Global").WebElement("list item").FireEvent "OnMouseOver"
				Browser("iBasis Customer Portal").Page("Global").WebElement("list item").Click
			End If

			Browser("iBasis Customer Portal").Page("Global").WebEdit("Select To").Set globaldictionary("ASSIGN_TO_RG")
			Browser("iBasis Customer Portal").Page("Global").WebElement("list item").SetTOProperty "innertext",globaldictionary("ASSIGN_TO_RG")
			If Browser("iBasis Customer Portal").Page("Global").WebElement("list item").Exist(10) Then
				Browser("iBasis Customer Portal").Page("Global").WebElement("list item").FireEvent "OnMouseOver"
				Browser("iBasis Customer Portal").Page("Global").WebElement("list item").Click
			End If

			Browser("iBasis Customer Portal").Page("Global").WebList("Select From").Select sRole
			Browser("iBasis Customer Portal").Page("Global").WebElement("Move").Click
			'Sync
			If fSyncByImage(60) = False Then
				Reporter.ReportEvent micFail, "fGuiAssignRolestoGroup", "Assigned - move role to role group failed"
				Call fWriteHtmlReportRow("fGuiAssignRolestoGroup ", "sync for refresh data", "FAIL", "Assigned - move role to role group failed")
				fGuiAssignRolestoGroup = False
				Exit Function
			End If
			
			sAssignRole = Browser("iBasis Customer Portal").Page("Global").WebList("Select To").GetROProperty("all items")
			'Check if role was moved to the ASSIGN_TO_RG list
			If instr(1, sAssignRole, globaldictionary("ROLE")) = 0 Then
				Reporter.ReportEvent micFail, "fGuiAssignRolestoGroup", "The role was not assigned to role group"
				Call fWriteHtmlReportRow("fGuiAssignRolestoGroup", "Check if the role appears in the correct role group list", "FAIL","The role does not appear in role group list")
			End If
		
			Browser("iBasis Customer Portal").Page("Global").WebElement("Save").Click
			'UI verification 
			If Browser("iBasis Customer Portal").Page("Global").WebElement("Notification").Exist(15) = "True" Then
				sNotification = Browser("iBasis Customer Portal").Page("Global").WebElement("Notification").GetROProperty("innertext")
				Call fWriteHtmlReportRow("fGuiAssignRolestoGroup" , "Assign role to role group" , "PASS", sNotification)
			End If
			'DB verification
			sRoleGroup = fFindRoleUnit(globaldictionary("ROLE"& i))
			If sRoleGroup = globaldictionary("ASSIGN_TO_RG") Then
				Reporter.ReportEvent micPass, "fGuiAssignRolestoGroup", "The role was assigned to role group"
				Call fWriteHtmlReportRow("fGuiAssignRolestoGroup", "Check assign role to role group", "PASS","The role is assigned to the correct role group")
				fGuiAssignRolestoGroup = True
			Else
				Reporter.ReportEvent micFail , "fGuiAssignRolestoGroup", "The role is not assigned to the correct role group"
				Call fWriteHtmlReportRow("fGuiAssignRolestoGroup", "Check assign role to role group", "FAIL","The role is not assigned to the correct role group")
			End If
	
		End If

		i = i + 1
	Wend
	
	fGuiAssignRolestoGroup = True
End Function

'###########################################################
' Function name: fGuiAssignRoleGroupToOrg
' Description: 
' Parameters: 
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiAssignRoleGroupToOrg()

   Dim i, sAvailableRg, sCurrentRg, bFound
   bFound = True
   'Select Customer - Organization (for assign rg to org)
   Call fSelectCustomer()

   If fNavigateToTab("Customer Settings", "Available Role Groups") <> True Then
	   fGuiAssignRoleGroupToOrg = False
	   Exit Function
   End If

   Call fGetReferenceVerificationData("CUST_NAME", sCustomerName)
   Call fGetReferenceVerificationData("CUST_ID", sCustomerID)
   
   i = 1
   While globaldictionary("ROLE_GROUP"&i) <> ""
	   sAvailableRg = Browser("iBasis Customer Portal").Page("Global").WebList("Available Role Group").GetROProperty("all items")
	   sCurrentRg = Browser("iBasis Customer Portal").Page("Global").WebList("Current Role Group").GetROProperty("all items")
	   If instr(1, sAvailableRg, globaldictionary("ROLE_GROUP"&i))> 0  Then
		    Browser("iBasis Customer Portal").Page("Global").WebList("Available Role Group").Select globaldictionary("ROLE_GROUP"&i)
			Browser("iBasis Customer Portal").Page("Global").WebElement("Add To Current Rg").Click
			Browser("iBasis Customer Portal").Page("Global").WebElement("Update").Click
			'UI verification - Check the notification
			If Browser("iBasis Customer Portal").Page("Global").WebElement("Notification").Exist(2) = "True" Then
				sNotification = Browser("iBasis Customer Portal").Page("Global").WebElement("Notification").GetROProperty("innertext")
				Call fWriteHtmlReportRow("fGuiAssignRoleGroupToOrg" , "Assign role group to organization" , "PASS", sNotification)
			End If
			'DB verification
			sSQL = "select CUSTOMER_ID from ecare_customer_details c join ecare_orgs_role_groups o on c.organization_id = o.org_id and o.role_group_id = (select ROLE_GROUP_ID from ecare_role_group r where r.role_group_name = '"&globaldictionary("ROLE_GROUP"&i)&"')"
			rc = fDBGetRS ("BILLING", sSQL, objRS) 
			
			If rc = False Then
				Reporter.ReportEvent micFail, "fGuiAssignRoleGroupToOrg ", "Connection to DB was failed."
				Call fWriteHtmlReportRow("fGuiAssignRoleGroupToOrg ", "Check the connection to DB", "FAIL","Connetion to DB was failed ")
				fGuiAssignRoleGroupToOrg = False
				Exit Function
			ElseIf rc = NO_RECORDS_FOUND Then
				Reporter.ReportEvent micWarning, "fGuiAssignRoleGroupToOrg", "No value returned by the query "
				Call fWriteHtmlReportRow("fGuiAssignRoleGroupToOrg", "Check if records returned from DB", "INFO","No records found ")
				fGuiAssignRoleGroupToOrg = False
				Exit Function
			End If 
			'Check if the role group was assigned to the expected organization
			sDBCustomerID = fReturnViewer(objRS, sCustomerID)
			
			If sDBCustomerID = False Then
				Reporter.ReportEvent micFail , "fGuiAssignRoleGroupToOrg", "The role group: "& globaldictionary("ROLE_GROUP"&i)& " was not assigned to organization-customer: " &sCustomerName
				Call fWriteHtmlReportRow("fGuiAssignRoleGroupToOrg", "Assign role group to organization", "FAIL","The role group: "& globaldictionary("ROLE_GROUP"&i)& " was not assigned to organization-customer: " &sCustomerName)
				bFound = False
			Else
				Reporter.ReportEvent micPass , "fGuiAssignRoleGroupToOrg", "The role group: "& globaldictionary("ROLE_GROUP"&i)& " not assigned to organization-customer: " &sCustomerName
				Call fWriteHtmlReportRow("fGuiAssignRoleGroupToOrg", "Assign role group to organization", "PASS","The role group: '"& globaldictionary("ROLE_GROUP"&i)& "' was assigned to organization-customer: " &sCustomerName)
			End If
		

	   ElseIf instr(1, sCurrentRg, globaldictionary("ROLE_GROUP"&i))> 0 Then
			Reporter.ReportEvent micWarning , "fGuiAssignRoleGroupToOrg", "The role group: "& globaldictionary("ROLE_GROUP"&i)& " is already assigned to the organization-customer: " &sCustomerName
			Call fWriteHtmlReportRow("fGuiAssignRoleGroupToOrg", "Assign role group to organization", "INFO","The role group: '"& globaldictionary("ROLE_GROUP"&i)& "' is already assigned to the organization-customer: " &sCustomerName)
	   Else
			Reporter.ReportEvent micFail , "fGuiAssignRoleGroupToOrg", "The role group: "& globaldictionary("ROLE_GROUP"&i)& " does not appear in 'Available RG' and in 'Current RG' "
			Call fWriteHtmlReportRow("fGuiAssignRoleGroupToOrg", "Assign role group to organization", "FAIL","The role group: '"& globaldictionary("ROLE_GROUP"&i)& "' does not appear in 'Available RG' and in 'Current RG'")
			bFound = False
	   End If

	   i = i + 1
   Wend
   If bFound = True Then
	   Reporter.ReportEvent micPass , "fGuiAssignRoleGroupToOrg", "All role groups were assigned to organization-customer: " &sCustomerName
	   Call fWriteHtmlReportRow("fGuiAssignRoleGroupToOrg", "Assign role group to organization", "PASS","All role groups were assigned to organization-customer: " &sCustomerName)
	   fGuiAssignRoleGroupToOrg = True
   End If
   
End Function
'###########################################################
' Function name: fGuiRemoveRoleGroup
' Description: 
' Parameters: 
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiRemoveRoleGroup()
 '//TODO
   fGuiRemoveRoleGroup = True
End Function

'###########################################################
' Function name: fFindRoleUnit
' Description: 
' Parameters: 
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fFindRoleUnit(sRole)

	Dim sRoleName, sUIRoleGroup, sDBRoleGroup

	sRoleName = fGetRoleName(sRole)
	If sRoleName <> False Then
		'UI - Find role group of the roles
		Browser("iBasis Customer Portal").Page("Global").WebEdit("Find Role").Set sRoleName
		'Sync
		If fSyncByImage(60) = False Then
			Reporter.ReportEvent micFail, "fFindRoleUnit", "Find Role Unit"
			Call fWriteHtmlReportRow("fFindRoleUnit", "sync for refresh data", "FAIL", "Role Group does not appear")
			fFindRoleUnit = False
			Exit Function
		End If
		If Browser("iBasis Customer Portal").Page("Global").WebElement("Role Group List").Exist(15) = "True" Then
			Browser("iBasis Customer Portal").Page("Global").WebElement("Role Group List").FireEvent "OnMouseOver"
			Browser("iBasis Customer Portal").Page("Global").WebElement("Role Group List").Click
		End If

		sUIRoleGroup = Browser("iBasis Customer Portal").Page("Global").WebElement("Role Group Name").GetROProperty("innertext")
		
		'DB - Find role group of the role
		sSQL = "select ROLE_GROUP_NAME From ECARE_ROLE_GROUP erg join ecare_role_group_roles rg on erg.role_group_id = rg.role_group_id join "& PORTAL &"ROLE_ r on rg.role_id = r.roleid and r.name = '"& sRoleName & "'"
        rc = fDBGetOneValue("BILLING", sSQL, sDBRoleGroup)

		If rc = False Then
			Reporter.ReportEvent micFail, "fFindRoleUnit ", "Connetion to DB was failed."
			Call fWriteHtmlReportRow("fFindRoleUnit ", "Check the connection to DB", "FAIL","Connetion to DB was failed ")
			fFindRoleUnit = False
			Exit Function
		ElseIf rc = NO_RECORDS_FOUND Then
			Reporter.ReportEvent micWarning, "fFindRoleUnit", "No value returned by the query "
			Call fWriteHtmlReportRow("fFindRoleUnit ", "Check if records returned from DB", "INFO","No records found ")
			fFindRoleUnit = False
			Exit Function
		End If 

		If Trim(sUIRoleGroup) = sDBRoleGroup Then
			Reporter.ReportEvent micPass , "fFindRoleUnit", "The role: "& sRoleName &" is assigned in UI to role group: "& sUIRoleGroup& " ,in DB: "& sDBRoleGroup
			Call fWriteHtmlReportRow("fFindRoleUnit", "Check if the role was assigned to the correct role group", "PASS","The role: "& sRoleName &" is assigned in UI to role group: "& sUIRoleGroup& " ,in DB: "& sDBRoleGroup)
			fFindRoleUnit = sUIRoleGroup
		Else
			Reporter.ReportEvent micFail, "fFindRoleUnit", "The role: "& sRoleName &" is assigned in UI to role group: "& sUIRoleGroup& " ,in DB: "& sDBRoleGroup
			Call fWriteHtmlReportRow("fFindRoleUnit", "Check if the role was assigned to the correct role group", "FAIL","The role: "& sRoleName &" is assigned in UI to role group: "& sUIRoleGroup& " ,in DB: "& sDBRoleGroup)
			fFindRoleUnit = False
		End If

	Else
		Reporter.ReportEvent micFail, "fFindRoleUnit", "The role was not assigned to role group"
		Call fWriteHtmlReportRow("fFindRoleUnit", "Check if the role was assigned to role group", "FAIL","The role does not appear in role group list")
		fFindRoleUnit = False
	End If

End Function
'##############################################################


'###########################################################
' Function name: fGetRolesOrganiizationByUser()
'###########################################################
'select r.NAME From portal_qa.role_ r join billing_qa.ECARE_ROLE_GROUP_ROLES e on e.role_id= r.roleid and e.role_group_id in(select ROLE_GROUP_ID from billing_qa.ECARE_ORGS_ROLE_GROUPS where org_id=(select ORGANIZATIONID from portal_qa.USERS_ORGS where userid=(select USER_.USERID FROM portal_qa.user_ WHERE screenname = 'shoshuser')));
'select r.NAME From portal_qa.role_ r join billing_qa.ECARE_ROLE_GROUP_ROLES e on e.role_id= r.roleid and e.role_group_id in(select ROLE_GROUP_ID from billing_qa.ECARE_ORGS_ROLE_GROUPS where org_id=(select ORGANIZATIONID from portal_qa.USERS_ORGS uo join portal_qa.user_ u on uo.userid=u.USERID and u.screenname = 'shoshuser'));

'###########################################################
' Function name: fGetRolesByRoleGroup
'###########################################################
'get role group of a role
'select ROLE_GROUP_NAME From billing_qa.ECARE_ROLE_GROUP erg join billing_qa.ecare_role_group_roles rg on erg.role_group_id = rg.role_group_id join PORTAL_QA.ROLE_ r on rg.role_id = r.roleid and r.name = 'Home: Balance Summary Viewer';

 '###########################################################
' Function name: fCheckRoleGroupList
' Description: 
' Parameters: 
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fCheckRoleGroupList(sRoleGroup)

    Dim bFound
	bFound = False

   'UI Verification - The new role group appears in all list(role group and available)
	Browser("iBasis Customer Portal").Page("Global").WebEdit("Select Role Group").Set sRoleGroup
	sRoleGroupList = Browser("iBasis Customer Portal").Page("Global").WebElement("Role Group List").GetROProperty("outertext")
	If instr(1, sRoleGroupList, sRoleGroup) = 0 Then
		Reporter.ReportEvent micFail, "fCheckRoleGroupList", "New Role Group : "&sRoleGroup &" was not added to role group list"
		Call fWriteHtmlReportRow("fCheckRoleGroupList - Global", "Check if new Role Group was added", "FAIL", "New Role Group : "& sRoleGroup &" was not added to role group list")
		bFound = True
    End If 
	'"Assign role from" List 
	Browser("iBasis Customer Portal").Page("Global").WebEdit("Select From").Set sRoleGroup
	sRoleGroupList = Browser("iBasis Customer Portal").Page("Global").WebElement("Role Group List").GetROProperty("outertext")
	If instr(1, sRoleGroupList, sRoleGroup) = 0 Then
		Reporter.ReportEvent micFail, "fCheckRoleGroupList", "New Role Group : "& sRoleGroup &" was not added to 'From' role group list"
		Call fWriteHtmlReportRow("fCheckRoleGroupList - Global", "Check if new Role Group was added", "FAIL", "New Role Group : "& sRoleGroup &" was not added to 'From' role group list")
		bFound = True
    End If 
	'"Assign role To" List 
	Browser("iBasis Customer Portal").Page("Global").WebEdit("Select To").Set sRoleGroup
	sRoleGroupList = Browser("iBasis Customer Portal").Page("Global").WebElement("Role Group List").GetROProperty("outertext")
	If instr(1, sRoleGroupList, sRoleGroup) = 0 Then
		Reporter.ReportEvent micFail, "fCheckRoleGroupList", "New Role Group : "& sRoleGroup &" was not added to 'To' role group list"
		Call fWriteHtmlReportRow("fCheckRoleGroupList - Global", "Check if new Role Group was added", "FAIL", "New Role Group : "& sRoleGroup &" was not added to 'To' role group list")
		bFound = True
    End If 
	'Check available role group list
	Browser("iBasis Customer Portal").Page("Global").WebElement("Customer Settings").Click
	'Sync
	If Browser("iBasis Customer Portal").Page("Global").WebElement("Available Role Groups").Exist(10) = "False" Then
		Reporter.ReportEvent micFail, "fCheckRoleGroupList", "'Customer Settings' tab was not opened"
		Call fWriteHtmlReportRow("fCheckRoleGroupList - Global", "Navigate to 'Customer Settings' tab", "FAIL", "'Customer Settings' tab was not opened")
		fCheckRoleGroupList = False
		Exit Function
	End If

	sRoleGroupList = Browser("iBasis Customer Portal").Page("Global").WebList("Available Role Group").GetROProperty("all items")
	If instr(1, sRoleGroupList, sRoleGroup) = 0 Then
		Reporter.ReportEvent micFail, "fCheckRoleGroupList", "New Role Group : "& sRoleGroup &" was not added to 'Available' role group list"
		Call fWriteHtmlReportRow("fCheckRoleGroupList - Global", "Check if new Role Group was added", "FAIL", "New Role Group : "& sRoleGroup &" was not added to 'Available' role group list")
		bFound = True
    End If 
	
	If bFound = True Then
		fCheckRoleGroupList = False
	Else
		Reporter.ReportEvent micPass, "fCheckRoleGroupList", "New Role Group : "& sRoleGroup &" was added to all role group list"
		Call fWriteHtmlReportRow("fCheckRoleGroupList - Global", "Check if new Role Group was added", "PASS", "New Role Group : "& sRoleGroup &" was added to all role group list")
		fCheckRoleGroupList = True
	End If
	
End Function
'########################################################
 '###########################################################
' Function name: fGetRoleName
' Description: 
' Parameters: 
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGetRoleName(ByVal sRole)

    bFound = False

   sSQL = "Select NAME From "& PORTAL &"ROLE_"
   rc = fDBGetRS ("PORTAL", sSQL, objRS)

	'Check fDBGetRS returned value
	If rc = False Then
		Reporter.ReportEvent micFail, "fGetRoleName", "Connetion to DB was failed"
		Call fWriteHtmlReportRow("fGetRoleName", "Check the connection to DB", "FAIL","Connetion to DB was failed")
		fGetRoleName = False
		Exit Function
	ElseIf rc = NO_RECORDS_FOUND Then
		Reporter.ReportEvent micFail, "fGetRoleName", "No records returned by the query "
		Call fWriteHtmlReportRow("fGetRoleName", "Check if records returned from DB - Name of role", "FAIL","No records returned by the query")
		fGetRoleName = False
		Exit Function
	End If
   
	objRS.MoveFirst
	Do While Not objRS.EOF
		If Instr(1,Lcase(objRS.Fields(0).Value), Lcase(sRole)) > 0 Then
			bFound = True
			sRoleName = objRS.Fields(0).Value
			Exit Do
		Else
			objRS.MoveNext
		End If
	Loop
	If bFound = False Then
		fGetRoleName = False
	Else
		fGetRoleName = sRoleName
	End If

End Function
'##################################################################
 '###########################################################
' Function name: fNavigateToTab
' Description: 
' Parameters: 
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fNavigateToTab(ByVal sTab, ByVal sElementInTab )

	'Login - Navigate to 'welcme'
   If fGuiLogIn() <> True Then
		Reporter.ReportEvent micFail, "fNavigateToTab", "fGuiLogIn failed"
		Call fWriteHtmlReportRow("fNavigateToTab" , "Login to App", "FAIL", "fGuiLogIn failed")
		fNavigateToTab = False
		Exit Function
	End If

	'Navigate to 'Global' protlet
   Browser("iBasis Customer Portal").Page("Home").Link("Admin").FireEvent "OnMouseOver"
   Browser("iBasis Customer Portal").Page("Home").Link("Global").Click
   If Browser("iBasis Customer Portal").Page("Global").Exist(30) = "False" Then
		Reporter.ReportEvent micFail, "fNavigateToTab", "Failed to Navigate the protlet: Global" 
		Call fWriteHtmlReportRow("fNavigateToTab" , "Navigate to the protlet", "FAIL", "Failed to Navigate the protlet: Global")
		fNavigateToTab = False
		Exit Function
   End If

	wait(5)

   'Enter to  Tab
   Browser("iBasis Customer Portal").Page("Global").WebElement(sTab).Click
	'Sync
   If Browser("iBasis Customer Portal").Page("Global").WebElement(sElementInTab).Exist(30) = "False" Then
		Reporter.ReportEvent micFail, "fNavigateToTab", "'"& sTab &"' tab was not opened"
		Call fWriteHtmlReportRow("fNavigateToTab - Global", "Navigate to '"& sTab &"' tab", "FAIL", "'"& sTab &"' tab was not opened")
		fNavigateToTab = False
		Exit Function
   End If

   fNavigateToTab = True

End Function
'##########################################################

'###########################################################
' Function name: fCollectRolesFromUI
' Description: The function collects all permission items form UI
' Parameters: 
' Return value:  collection of all permission items
' Example:
'###########################################################
Public Function fCollectRolesFromUI(sProtlet)

	Set oDesc = Description.Create
	oDesc("micclass").value = "WebElement"
	oDesc("class").value = "v-tree-node-leaf.*"
	Set colObject = Browser("iBasis Customer Portal").Page(sProtlet).ChildObjects(oDesc)

	Set fCollectRolesFromUI = colObject
	wait(5)
End Function
'###########################################################

'###########################################################
' Function name: fUncheckAllPermissions
' Description: The function uncheck all permission items on UI
' Parameters: 
' Return value:  
' Example:
'###########################################################
Public Function fUncheckAllPermissions(sProtlet)
	Dim i
	wait(2)
	Set colObject = fCollectRolesFromUI(sProtlet)
	For i = 0 To colObject.count - 1
		sInnerText = colObject(i).GetRoProperty("innertext")
		'msgbox sInnerText &" index= "&i
		If instr(1,colObject(i).GetRoProperty("class"),"unchecked") = 0 Then 
			Browser("iBasis Customer Portal").Page(sProtlet).WebElement("Permission CheckBox").SetTOProperty "innertext",sInnerText
			Browser("iBasis Customer Portal").Page(sProtlet).WebElement("Permission CheckBox").SetTOProperty "outerhtml","<SPAN>"&sInnerText&"</SPAN>"
            wait(1)
			Browser("iBasis Customer Portal").Page(sProtlet).WebElement("Permission CheckBox").Click
			'wait (1)
		End If
	Next
	fUncheckAllPermissions = True
End Function
'###########################################################

'###########################################################
' Function name: fSelectRolesInUI
' Description: Set premission item value - checked/unchecked
' Parameters: premissions items collection, role to set, value to set (checked/unchecked)
' Return value:  Success - True
'				 Failure (Role not found) - False
' Example:
'###########################################################
Public Function fSelectRolesInUI(ByVal colObject, ByVal sRole, ByVal sCheck, ByVal sPage)

	Dim i
	sRole = fGetRoleName(sRole)
 
	For  i = 0  To colObject.count - 1 
		If colObject(i).GetRoProperty ("innertext") = sRole Then

			If instr(1,colObject(i).GetRoProperty ("class"), "unchecked") = 0 Then '= checked
				If lcase(sCheck) = "unchecked" Then 'if checked -> uncheck
					Browser("iBasis Customer Portal").Page(sPage).WebElement("Permission CheckBox").SetTOProperty "innertext",sRole
					Browser("iBasis Customer Portal").Page(sPage).WebElement("Permission CheckBox").Click
				End If

			Else '= unchecked
				If lcase(sCheck) = "checked" Then 'if unchecked -> check
					Browser("iBasis Customer Portal").Page(sPage).WebElement("Permission CheckBox").SetTOProperty "innertext",sRole
					Browser("iBasis Customer Portal").Page(sPage).WebElement("Permission CheckBox").Click
				End If

			End If

			'Return "true" - role was found
			fSelectRolesInUI = True
			Exit Function

		End If
	Next

	'Return "false" - role was NOT found on the collection
	fSelectRolesInUI = False
	
End Function
'############################################################

'###########################################################
' Function name: fCompOrgRolesFromUIToDB
' Description: 
' Parameters: 
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fCompOrgRolesFromUIToDB()
End Function

''############################################################

'###########################################################
' Function name: fGuiHomeDBValidations
' Description:  Check all DB Validations
' Parameters:  Protlet Name,
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiHomeDBValidations

	Dim iId
	
	'Get the customer_id from the KEEP_REFER
    Call fGetReferenceVerificationData("CUST_ID", iId)

	'Add Title in the HTML - Portlet name
	Call fWriteHtmlReportRow("fGuiHomeDBValidations" ,"Finance", "", "")

	'Navigate to 'Finance' page
	If fGuiCheckPageIsLoaded("Finance","","CreditLimit","WebElement", 20, False) = False Then
		Exit Function
	End If 
	
	'Validate the 'Account Info' details on UI vs DB
	Call fGuiAccountInfo(iId) 
	
	'Validate the 'Credit Limit' details on UI vs DB
	Call fGuiCreditLimit(iId)
	
	'Validate the 'Balance Summary' details on UI vs DB
	Call fGuiBalanceSummary(iId)

End Function
'#############################################################

'###########################################################
' Function name: fGuiUserActions
' Description: create/update/delete/resetpassword user
' Parameters:  User action: Create/update/delete/resetpassword
' Return value:  Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiUserActions()

  	Select Case Ucase(GlobalDictionary("USER_ACTION"))

		Case "CREATE"
			Call fSelectCustomer()
			Call fWriteHtmlReportRow("fGuiUserActions" , "Create New User", "", "")
			If fGuiCreateUser() <> True Then
				Reporter.ReportEvent micFail, "fGuiUserActions", "fGuiCreateUser failed"
				'Call fWriteHtmlReportRow("fGuiUserActions" , "Create New User", "FAIL", "fGuiCreateUser failed")
				fGuiUserActions = False
				Exit Function
			End If

		Case "UPDATE"
			Call fWriteHtmlReportRow("fGuiUserActions" , "Update User", "", "")
			If fGuiUpdateUser() <> True Then
				Reporter.ReportEvent micFail, "fGuiUserActions", "fGuiUpdateUser failed"
				'Call fWriteHtmlReportRow("fGuiUserActions" , "Update User", "FAIL", "fGuiUpdateUser failed")
				fGuiUserActions = False
				Exit Function
			End If
		
		Case "RESETPASSWORD"
			Call fWrite ("fGuiUserActions" , "Reset Password", "", "")
			If fGuiResetPassword() <> True Then
				Reporter.ReportEvent micFail, "fGuiUserActions", "fGuiResetPassword failed"
				'Call fWriteHtmlReportRow("fGuiUserActions" , "Reset Password", "FAIL", "fGuiResetPassword failed")
				fGuiUserActions = False
				Exit Function
			End If

		Case "DELETE"
			Call fWriteHtmlReportRow("fGuiUserActions" , "Delete User", "", "")
			If fGuiDeleteUser() <> True Then
				Reporter.ReportEvent micFail, "fGuiUserActions", "fGuiDeleteUser failed"
				'Call fWriteHtmlReportRow("fGuiUserActions" , "Delete User", "FAIL", "fGuiDeleteUser failed")
				fGuiUserActions = False
				Exit Function
			End If
	End Select
    
     fGuiUserActions = True
End Function
'############################################################

Public Function fGuiCompareUIVSDB(ByVal sPage, ByVal sParentPage, ByVal sLink, ByVal sTableName, ByVal sObjectInPage, ByVal sObjectType, ByVal sSyncTime)
'###########################################################
' Function name: fGuiCompareUIVSDB
' Description: The function verifies all tables - UI VS DB
' Parameters: sPage, sParentPage, sLink, sObjectInPage, sObjectType, sSyncTime 
' Return value: 			 
' Example:
'###########################################################

	'Navigate to page
	
	'Parent pages (Alerts & Admin)
	If sParentPage = "" Then
		Browser("iBasis Customer Portal").Page("AllPages").Link(sParentPage).Click
		If fSyncByObject("fGuiCompareUIVSDB", "iBasis Customer Portal", sParentPage, sObjectType, sObjectInPage, sSyncTime, "Check if page " & sParentPage & " is loaded", "The page " & sParentPage & " is not loaded", "The page " & sParentPage & " loaded") <> True Then
			Call fReport("fGuiCompareUIVSDB", "Load page " & sParentPage, "FAIL", "Page is not loaded",0)
			fGuiCompareUIVSDB = False
			Exit Function
		Else
			Call fReport("fGuiCompareUIVSDB", "Load page " & sParentPage, "PASS", "Page is loaded correctly",0)
			fGuiCompareUIVSDB = True
		End If
	Else 
		
	End If

	'Export the grid

	Select Case sTableName
		Case "Unbilled Traffic Table"
			sTableHeaders = sUnbilledTrafficHeaders
		Case "Open Transactions Table"
			sTableHeaders = sOpenTransactionsHeaders
		Case "Invoices Table"
			sTableHeaders = sInvoicesHeaders 
		Case "Payments / Credits Table"
			sTableHeaders = sPaymentsCreditsHeaders
		Case "Invoices Associated With Payment Table"
			sTableHeaders = sInvoicesAssociatedWithPaymentHeaders
		Case "Disputes Table"
			sTableHeaders = sDisputesHeaders
		Case "Alerts Table"
			sTableHeaders = sAlertsHeaders
		Case "Open Tickets Table"
			sTableHeaders = sOpenTicketsHeaders
		Case "Seacrh Tickets Table"
			sTableHeaders = sSeacrhTicketsHeaders
		Case "TODO1-Fraud Alerts Table"
			sTableHeaders = sFraudAlertsHeadrs
		Case "TODO2-CLI Table"
			sTableHeaders = sCLIHeaders
		Case "TODO3-Tickets Table"
			sTableHeaders = sTicketsHeaders
		Case "TODO4-PVIPX IP Quality Table"
			sTableHeaders = sPVIPXIPQualityHeaders
		Case "Source / Destination"
			sTableHeaders = sSourceDestinationHeaders
		Case "TODO5-Service Availability Table"
			sTableHeaders = sServiceAvailabilityHeaders
		Case "TODO6-Sent/Received Transactions Table"
			sTableHeaders = sSentReceivedTransactionsHeaders
		Case "TODO7-Outbound Transactions Table"
			sTableHeaders = sOutboundTransactionsHeaders
		Case "TODO8-Inbound Transactions Table"
			sTableHeaders = sInboundTransactionsHeaders
		Case "TODO9-Outbound Roaming Table"
			sTableHeaders = sOutboundRoamingHeaders
		Case "TODO10-Inbound Roaming Table"
			sTableHeaders = sInboundRoamingHeaders
		Case "TODO11-Country Analysis Table"
			sTableHeaders = sCountryAnalysisHeaders
		Case "TODO12-MNO Analysis Table"
			sTableHeaders = sMNOAnalysisHeaders 
		Case "TODO13-Error Analysis Table"
			sTableHeaders = sErrorAnalysisHeaders
		Case "Users Table"
			sTableHeaders = sUsersHeaders
	End Select
	
	sUIFilePath = "T:\Matrix-QA\QTP-Aoutomation\QTP-CP\QTP\CustomerPortal\Version1\DB Compare Files\UI"
	sDBFilePath = "T:\Matrix-QA\QTP-Aoutomation\QTP-CP\QTP\CustomerPortal\Version1\DB Compare Files\DB"
	sGridName = Replace(Replace(sTableName," ",""),"Table","")
	sUIFileName = sGridName & "UI"
	sDBFileName = sGridName & "DB"
	
	If fGuiExportGridIntoExcel("iBasis Customer Portal",sParentPage,sTableName,sTableHeaders,sUIFilePath,sUIFileName,sGridName,iRows) <> True Then
		Call fReport("fGuiCompareUIVSDB","Export grid into excel","FAIL","Failed to export" & sGridName & "grid to excel",0)
		fGuiCompareUIVSDB = False
		Exit Function
	End If
	
	'Run the query and export the results
	If fGuiExportDBIntoExcel(sDBFilePath,sDBFileName,sGridName,iRows,sHeaders) <> True Then
		Call fReport("fGuiCompareUIVSDB","Export DB data into excel","FAIL","Failed to export" & sGridName & "DB data to excel",0)
		fGuiCompareUIVSDB = False
		Exit Function
	End If
	
	'Compare between UI and DB

End Function
'############################################################

Public Function fGuiExportGridIntoExcel(ByVal sBrowser, ByVal sPage, ByVal sWebTable, ByVal sWebTableHeaders, ByVal sFilePath, ByVal sFileName, ByVal sGridName, ByRef iRows)
'###########################################################
' Function name: fGuiExportGridIntoExcel
' Description: The function export a grid from UI to UFT's data table
' Parameters:  sBrowser, sPage, sWebTable, sWebTableHeaders, sFilePath, sFileName, sGridName
' Return value: Success - Numbers of rows in the exported excel
'				 Failure - False
' Example:
'###########################################################
	
	Dim sTableInnerHTML, sHeadersRowInHTML, objFSO, objFile
		
	'Handle file path and name to be valid
	If Right(sFilePath,1) <> "\" Then
		sFilePath = sFilePath & "\"
	End If
		
	'Get table headers
	sHeadersColumns = Browser(sBrowser).Page(sPage).WebTable(sWebTableHeaders).GetROProperty("column names")
	sHeadersRowInHTML = "<tr><td>" & replace(sHeadersColumns,";","</td><td>") & "</td></tr>"

	'Get table inner HTML
	sTableInnerHTML = Browser(sBrowser).Page(sPage).WebTable(sWebTable).GetROProperty("innerhtml")
	sTableInnerHTML = "<html><table>" & sHeadersRowInHTML & sTableInnerHTML & "</table></html>"
	
	'Get table row number
	'TODO (get property of row number and put it in iRows)
	'iRows = 
	
	'Create an HTML file with .xls extension
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFile = objFSO.CreateTextFile(sFilePath & sFileName & ".xls", True)
	
	'Check if file Path is valid
	If objFSO.FolderExists(sFilePath) = False Then
		fGuiExportGridIntoExcel = False
		Call fReport("fGuiExportGridIntoExcel", sGridName &" - Export UI grid to an excel","FAIL", "Export file path (" & sFilePath & ") is not valid", 0)
		ExitRun
	End If
	
	'Check if file created, if not - return false
	If objFSO.FileExists(sFilePath & sFileName & ".xls") = False Then
		fGuiExportGridIntoExcel = False
		Call fReport("fGuiExportGridIntoExcel", sGridName &" - Export UI grid to an excel","FAIL", "Exporting to '" & sFilePath & sFileName & "' failed", 0)
		ExitRun
	End If
	
	'Write to the file
	objFile.WriteLine(sTableInnerHTML)
	objFile.Close
		
	'Open the file in excel
	Dim oExcel, oWB, oSheet, setVal
	Set oExcel=CreateObject("Excel.Application")
	oExcel.DisplayAlerts = False
	
	Set oWB=oExcel.Workbooks.Open(sFilePath & sFileName)
	Set oSheet=oWB.WorkSheets(sFileName)
	
	'TODO: Check how to export without auto formatting
	'oSheet.Columns("A:Z").NumberFormat = "@" 
	
	If err.description <> "" Then
		fGuiExportGridIntoExcel = False
		Call fReport("fGuiExportGridIntoExcel", sGridName &" - Export UI grid to an excel","FAIL", "Exporting to '" & sFilePath & sFileName & "' failed <BR> Error: " & err.description, 0)  
		ExitRun	
	End If
	
	oWB.Save
	
	If oWB.SaveAs (sFilePath & "UI_" & sFileName & ".xls", "56") <> True Then'Save into regular excel format. 56 = Excel8.
		fGuiExportGridIntoExcel = False
		Call fReport("fGuiExportGridIntoExcel", sGridName &" - Export UI grid to an excel","FAIL", "Saving the exported file to an excel file failed <BR> Error: " & err.description, 0) 
		ExitRun	
	End If
	
	'Import the file to UFT's datatable
	'DataTable.Importsheet sFilePath & "Output" & sFileName & ".xls" ,1,dtGlobalSheet
	
	fGuiExportGridIntoExcel = oSheet.UsedRange.Rows.Count
	Call fReport("fGuiExportGridIntoExcel", sGridName &" - Export UI grid to an excel","PASS", "Exporting UI grid into excel succeeded", 0) 
	
	oWB.Close
	Set oExcel=Nothing
End Function
'###########################################################

'###########################################################
' Function name: fGuiExportDBIntoExcel
' Description: The function export results of  a query to excel
' Parameters:  sSQL, iRows - Num of first rows to retrieve, sHeaders - String of headers row
' Return value: Success - True
'				 Failure - False
' Example:
'###########################################################
Public Function fGuiExportDBIntoExcel(ByVal sFilePath, ByVal sFileName, ByVal sGridName, ByVal iRows, ByVal sHeaders)
	'sSQL = "SELECT document_reference ""INVOICE ID"",to_char(document_date,'mm/dd/yy') ""INVOICE DATE"" ,document_currency ""CURRENCY"" ,to_char(document_amount,'999,999,990.99') ""INVOICE AMOUNT"",to_char(paid_amount,'999,999,990.99') ""PAID AMOUNT"",to_char(cleared_amount,'999,999,990.99') ""OTHER CLEARED AMOUNT"",to_char(open_amount,'999,999,990.99') ""OPEN AMOUNT"",to_char(""CONVERSION CURRENCY RATE"",'990.9999') ""CONVERSION CURRENCY RATE"",to_char(open_amount*""CONVERSION CURRENCY RATE"",'999,999,990.99') ""CONVERTED OPEN AMOUNT"" FROM(SELECT document_reference    ,document_date      ,document_currency    ,document_amount    ,paid_amount    ,cleared_amount    ,open_amount    ,(SELECT distinct round(RATE,4) FROM billing.EXCHANGE_RATE WHERE FROM_CURRENCY = document_currency AND TO_CURRENCY = 'USD') ""CONVERSION CURRENCY RATE""    ,YEAR    ,COMPANY     ,SAP_DOCUMENT_NUMBER     ,SAP_DOCUMENT_LINE_ITEM    FROM BILLING.CUSTOMER_INVOICE_HISTORY       WHERE customer_id in(SELECT ID FROM billing.CUSTOMER_MASTER WHERE headquarters = 101215) order by document_date DESC ,YEAR, COMPANY, SAP_DOCUMENT_NUMBER, SAP_DOCUMENT_LINE_ITEM)"
	'iRows = 46
	'sHeaders = "INVOICE ID,INVOICE DATE,CURRENCY,INVOICE AMOUNT,PAID AMOUNT,OTHER CLEARED AMOUNT,OPEN AMOUNT,CONVERSION CURRENCY RATE,CONVERTED OPEN AMOUNT"
	
	Dim i, rc, rs, sLastCell
	Dim arrValues, arrHeaders, arrParameters
	Dim oExcel, oWB, oSheet
		
	'Handle file path and name to be valid
	If Right(sFilePath,1) <> "\" Then
		sFilePath = sFilePath & "\"
	End If

	 arrParameters = fGlobalDictionaryTo2dArray()
	 sSQL = fGetQuery(sGridName & "_query", arrParameters)

' Add case "invoices associated with payment" run 2 queries

	'Adjust the SQl to retreive only first 'iRows' rows number
	sSQL = "select * from(" & replace(sSQL,"SELECT ", "SELECT rownum as rnum ,",1,1) & ") where rnum <=" & iRows
	rc = fDBGetRS ("BILLING", sSQL, rs)
	If rc = False Then	'DB connection failed /Ouery execution failed
		Call fReport(sStepName,sStepDesc,"FAIL","DB connection failed or Ouery execution failed",0)
		fGuiExportDBIntoExcel = False
		ExitRun
	End If 
	
	'Get Columns Count
	iColumns = rs.Fields.Count
	
	ReDim arrValues(iColumns)
	
	arrValues = rs.getRows() 'Getting all the values from the Record set
	arrValues = fTransposeArray(arrValues)
		
	Set oExcel = CreateObject("excel.application")
    'oExcel.Visible = True
    Set oWB = oExcel.Workbooks.Add
    sLastCell = fConvertToLetter(iColumns) & iRows    
    Set oSheet = oExcel.sheets("sheet1")
    oSheet.Range("A1:" & sLastCell).Value = arrValues
	oSheet.Columns("A").Delete '--Delete first column of row numbers
		
	'Add headers row	
	arrHeaders = split(sHeaders,",")
	oSheet.Range("A1").EntireRow.Insert
	For i = 1 To uBound(arrHeaders)+1 Step 1
		oSheet.Range(fConvertToLetter(i) & "1").Value = arrHeaders(i-1)
	Next

	rs.Close
	oExcel.DisplayAlerts = False
	
	If oWB.SaveAs (sFilePath & "DB_" & sFileName & ".xls", "56") <> True Then'Save into regular excel format. 56 = Excel8.
		fGuiExportDBIntoExcel = False
		Call fReport("fGuiExportDBIntoExcel", sGridName &" - Export DB grid to an excel","FAIL", "Saving the exported file to an excel file failed <BR> Error: " & err.description, 0) 
		ExitRun	
	End If
	
	oWB.Close
	Set oExcel = Nothing
	
	
	fGuiExportDBIntoExcel = True
	Call fReport("fGuiExportDBIntoExcel", sGridName &" - Export DB grid to an excel","PASS", "Exporting DB query results into excel succeeded", 0) 
	
End Function
'###########################################################

Public Function fGuiCompareReportsSheet(ByRef objWorksheet1, ByRef objWorksheet2, ByRef objWorksheetResults, ByRef iComparedValues, byVal sGridName)
'###########################################################
' Function name: fGuiSheetComparison
' Description: The function compare between 2 sheets and add comments to the results sheet with the differences that were found 
' Parameters: 2 sheet to compare (objWorksheet1 and objWorksheet2) and one sheets of results.
' Return value: Number of mismatches
' Example: 
'###########################################################
	Dim iMaxRowsUsedRange, iMaxColumnsUsedRange, iRowsUsedRangeFile1, iRowsUsedRangeFile2, iColumnsUsedRangeFile1, iColumnsUsedRangeFile2
	Dim iMismatchCounter
	iMismatchCounter = 0
	
	iRowsUsedRangeFile1 = objWorksheet1.UsedRange.Rows.Count 
	iRowsUsedRangeFile2 = objWorksheet2.UsedRange.Rows.Count 
	
	iColumnsUsedRangeFile1 = objWorksheet1.UsedRange.Columns.Count 
	iColumnsUsedRangeFile2 = objWorksheet2.UsedRange.Columns.Count 
	
	'Set the max rows as max used range
	If iRowsUsedRangeFile1 > iRowsUsedRangeFile2 Then
		iMaxRowsUsedRange = iRowsUsedRangeFile1
	Else
		iMaxRowsUsedRange = iRowsUsedRangeFile2
	End If
	
	'Set the max columns as max used range
	If iColumnsUsedRangeFile1 > iColumnsUsedRangeFile2 Then
		iMaxColumnsUsedRange = iColumnsUsedRangeFile1
	Else
		iMaxColumnsUsedRange = iColumnsUsedRangeFile2
	End If
	
	'Run on all the file and compare cells between the 2 excels
	For i = 1 To iMaxRowsUsedRange Step 1
		For j = 1 To iMaxColumnsUsedRange Step 1
			
			iComparedValues = iComparedValues + 1
			'Check if formats are different
			'Check if there are changes
			If Trim(objWorksheet1.Cells(i,j).Text) <> Trim(objWorksheet2.Cells(i,j).Text) Then
				
				iMismatchCounter = iMismatchCounter + 1
								
				'When the cell in file1 is empty and the cell in file2 is not empty
				If (Not isEmpty (objWorksheet1.Cells(i,j).Value)) and (isEmpty (objWorksheet2.Cells(i,j).Value)) Then
					objWorksheetResults.Cells(i,j).AddComment ("Mismatching data. Cell value on DB is: " & objWorksheet1.Cells(i,j).Value & " while on UI is empty") 				
					
				'When the cell in file1 is not empty and the cell in file2 is empty
				ElseIf (isEmpty (objWorksheet1.Cells(i,j).Value)) and (Not isEmpty (objWorksheet2.Cells(i,j).Value)) Then
					objWorksheetResults.Cells(i,j).AddComment ("Mismatching data. Cell value on DB is empty while on UI is: " & objWorksheet2.Cells(i,j).Value)
					
				'When there are values on both files but they are mismatched
				Else
					objWorksheetResults.Cells(i,j).AddComment ("Mismatching data. Cell value on DB is: " & objWorksheet1.Cells(i,j).Value & " while on UI is: " & objWorksheet2.Cells(i,j).Value) 	
				End If
				
				objWorksheetResults.Cells(i,j).Interior.ColorIndex = 27
								
			End If
	
		Next
	Next
	
	If iMismatchCounter > 0 Then 'Mismatches were found
		Call fReport("fGuiCompareReportsSheet",sGridName & " - Compare DB vs UI", "FAIL","Comparison completed with failure <BR> (" & iMismatchCounter & " differences found)",0)	
	Else
		Call fReport("fGuiCompareReportsSheet",sGridName & " - Compare DB vs UI", "PASS","Comparison completed successfully <BR> (no differences found)",0)
	End If	
	
	fGuiCompareReportsSheet = iMismatchCounter

End Function
'###########################################################

Public Function fGuiOpenReportsWorkbooks(ByRef objWorkbookUI, ByRef objWorkbookDB, ByRef objWorkbookResults, ByVal sFilesPath, ByVal sGridName)
'###########################################################
' Function name: fGuiOpenReportsWorkbooks
' Description: The function open the 2 excel files to be compared 
' Parameters: 
' Return value: 
' Example: 
'###########################################################
	Dim sReport1SourcePath, sReport2SourcePath, objExcel, sReport1DestinationPath, sReport2DestinationPath, sReportResultsPath
	Dim sFile1Name, sFile2Name
	fGuiOpenReportsWorkbooks = True
	
	If Right(sFilesPath,1) <> "\" Then
		sFilesPath = sFilesPath & "\"
	End If
	
	Set objExcel = CreateObject("Excel.Application")
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	
	'-------------------------------------------
	'Open UI data file
	'-------------------------------------------
	Set objWorkbookUI = objExcel.Workbooks.Open(sFilesPath & "UI_" & sGridName & ".xls")
	
	'Check if an error occurs when opening the file and report for Success or Failure
	If err.number <> 0 Then 'An error occurs during file opening 
		Call fReport("fGuiOpenReportsWorkbooks","Open UI data file","FAIL","UI data file opening failed <BR> Error Description: " & err.description,0)
		fGuiOpenReportsWorkbooks = False
	Else  'File was opened successfully
		Call fReport("fGuiOpenReportsWorkbooks","Open UI data file","PASS","UI data file was opened successfully",0)
	End If
	
	
	'-------------------------------------------
	'Open DB data file
	'-------------------------------------------
	Set objWorkbookUI = objExcel.Workbooks.Open(sFilesPath & "DB_" & sGridName & ".xls")
	
	'Check if an error occurs when opening the file and report for Success or Failure
	If err.number <> 0 Then 'An error occurs during file opening 
		Call fReport("fGuiOpenReportsWorkbooks","Open DB data file","FAIL","DB data file opening failed <BR> Error Description: " & err.description,0)
		fGuiOpenReportsWorkbooks = False
	Else  'File was opened successfully
		Call fReport("fGuiOpenReportsWorkbooks","Open DB data file","PASS","DB data file was opened successfully",0)
	End If
	
	'-------------------------------------------
	'Open reults data file (as copy of DB file)
	'-------------------------------------------
	Call objFSO.CopyFile(sFilesPath & "DB_" & sGridName & ".xls", sFilesPath & "Results_" & sGridName & ".xls")
	Set objWorkbookResults = objExcel.Workbooks.Open(sFilesPath & "Results_" & sGridName & ".xls")
	
	'Check if an error occurs when opening the file and report for Success or Failure
	If err.number <> 0 Then 'An error occurs during file opening 
		Call fReport("fGuiOpenReportsWorkbooks","Open results data file","FAIL","Results data file opening failed <BR> Error Description: " & err.description,0)
		fGuiOpenReportsWorkbooks = False
	Else  'File was opened successfully
		Call fReport("fGuiOpenReportsWorkbooks","Open results data file","PASS","Results data file was opened successfully",0)
	End If

End Function
