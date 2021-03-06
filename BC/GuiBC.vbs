'Yael Comment
'Option Explicit

Public Function fGuiLogin()

'------------------------------------------
' Function name: fGuiLogin
' Description: Login to Business case application
' Parameters:
' Return value:
' Example:
'------------------------------------------

  	'If browser is close -> open browser and sync
  	If Not Browser("BC").Exist(1) Then
  		Call SystemUtil.Run ("C:\Program Files\Internet Explorer\iexplore.exe",Environment("URL"))
  		If fSyncByObjectForPage("Login") <> True Then
			Call fReport("fGuiLogin","Login to BC application","FAIL","Application not opened",0)
			ExitRun
		End If 
   	End If

	'If application is open in the login page and any user is login, click on "BC-Online" link in order to sign out
	If Not Browser("BC").Page("Login").Exist(0) and Browser("BC").Page("Login").WebButton("SignIn").Exist(0) Then
		Browser("BC").Page("Login").Link("BC Online").Click
		'Sync to Search page
		If fSyncByObjectForPage("SearchBC") <> True Then
			Call fReport("fGuiLogin","Login to BC application","FAIL","Login failed",0)
			ExitRun
		End If
	End If
		
	'If application is opened in any page and any user is sign in -> logout
	If Not Browser("BC").Page("Login").WebButton("SignIn").Exist(0) Then
  		Browser("BC").Link("Sign Out").Click
  		'Sync to load Login page	
		If fSyncByObjectForPage("Login") <> True Then
			Call fReport("fGuiLogin","Navigate to Search-BC page","FAIL","Navigation failed",0)
			ExitRun
		End If
	End If

  	'If application is opened and no user is sign in -> set UserName/Password, click sign in
  	If Browser("BC").Page("Login").WebButton("SignIn").Exist(0) Then
  		Browser("BC").Page("Login").WebEdit("UserName").Set(Environment("USER"))
  		Browser("BC").Page("Login").WebEdit("Password").Set(Environment("PASSWORD"))
  		Browser("BC").Page("Login").webButton("SignIn").Click
  		Wait 4
  		'Sync to login, load Search-BC page
		If fSyncByObjectForPage("SearchBC") <> True Then
			Call fReport("fGuiLogin","Login to BC application","FAIL","Login failed",0)
			ExitRun
		Else
			Call fReport("fGuiLogin","Login to BC application","PASS","Login successfully",0)
		End If
	End If
		
	fGuiLogin = True

End Function

Public Function fGuiSearchBC(ByVal arrFilterBy,ByVal arrFilterValues)
	
'------------------------------------------
' Function name: fGuiSearchBC
' Description: The function search BC on Search-BC screen by required values 
' Parameters: arrFilterBy - fields to filter, arrFilterValues = values to filter with, arrFieldsTypes - types of the filtered fields
' Return value: Success - True, Failed - False
' Example:
'------------------------------------------
	
	Dim i,sObjHierarchy,sObjType
	i = 0
	
	'Navigate to search screen
	 If fNavigateToPage("Search","SearchLink") = False Then
	 	Call fCaptureScreen("BC","fGuiSearchBC","Navigate to Search page","Navigation failed, can't search BC - stop running!")
	 	ExitRun
	 End If
	
	If arrFilterBy(0) = "" Then 'Doesn't get the search values as parameter, should collect them from the XL			
		'Get the search fields/values from the GlobalDictionary
		While GlobalDictionary("FILTER_BY_" & i+1) <> ""	
			arrFilterBy(i) = GlobalDictionary("FILTER_BY_" & i+1)
			arrFilterValues(i) = GlobalDictionary("FILTER_VALUE_" & i+1) 
			i = i + 1	
		Wend			
	End If
	
	For i = 0 To uBound(arrFilterBy) Step 1
		'Get Obj hierarchy and Obj Type
		Call fGuiGetSearchFieldDetails(arrFilterBy(i),sObjHierarchy,sObjType)
		'Set the Search Value		
		Call fSetValue(sObjHierarchy,sObjType,arrFilterValues(i))	
	Next
	
	'Click on Search button
	Browser("BC").Page("SearchBC").WebButton("Search").Click
	
	'Sync to search results
	If fSyncByObject("fGuiSearchBC","BC","SearchBC","WebElement","SearchTableElement",60) <> True Then
		Call fCaptureScreen("BC","fGuiSearchBC","Sync to BC searching","Search BC failed")
	End If

End Function	

Public Function fGuiCreateBasicDeal(ByRef bSelectionFailed, ByRef sBCDescription, ByVal sTest)
	
'------------------------------------------
' Function name: fGuiCreateBasicDeal
' Description: The function create a basic deal to sanity test and save it
' Parameters: 
' Return value:
' Example:
'------------------------------------------
	
	bSelectionFailed = 0
	
	'Click on 'New Business case' button in order to create one
	Browser("BC").Page("SearchBC").WebButton("CreateBC").Click
	If fSyncByObjectForPage("DealSummary") <> True Then
		Call fReport("fGuiCreateBasicDeal","Click on 'New Business Case' button","FAIL","Creation failed",0)
		ExitRun
	End If 
	
	'Set BC description
	Call fGuiSetBCDescription(sBCDescription)
	
	'Selected Start/End dates
	Call fGuiSelectDates(bSelectionFailed)
	
	'Select Regional Customer and Vendor
	Call fGuiSelectPartners(bSelectionFailed,sTest)

fGuiCreateBasicDeal = True
	
End Function

Public Function fGuiSelectDates(ByRef bSelectionFailed)

'------------------------------------------
' Function name: fGuiSelectDates
' Description: The function select dates and verify set succesfully
' Parameters: 
' Return value:
' Example:
'------------------------------------------
	
	Dim sSelectedStartDate,sSelectedEndDate,sSysDate,sSysMonth,sSysYear,sMonth

	'Get current Month and Year
	sSysDate = date
	
	sMonth = month(sSysDate)
	If sMonth < 10 Then
		sSysMonth = "0" & sMonth
	Else 
		sSysMonth = month(sSysDate)
	End If
	
	sSysYear = year(sSysDate)
	
	'Select Start date
	Browser("BC").Page("DealSummary").WebElement("StartDate").WebButton("OpenDatePicker").Click
	Call fSetValue("Browser(""BC"").Page(""DealSummary"").WebElement(""StartDate"").WebElement(""DatePicker"").WebButton(""DayButton"")","Date","10")
	Wait 1

	'Verify selection success 
	'Get the selected Start date
	sSelectedStartDate = Browser("BC").Page("DealSummary").WebElement("StartDate").WebEdit("SelectedDay").GetROProperty("Value") 

	If sSysMonth & "-" & "10-" & sSysYear <> sSelectedStartDate Then
		Call fReport("fGuiSelectDates","Select 'Start Date'","FAIL","Select 'Start Date' failed",0)
		bSelectionFailed = 1 'Selection failed flag
	Else
		Call fReport("fGuiSelectDates","Select 'Start Date'","PASS","Select 'Start Date' success",0)
	End If

	'Select End date
	Browser("BC").Page("DealSummary").WebElement("EndDate").WebButton("OpenDatePicker").Click
	Call fSetValue("Browser(""BC"").Page(""DealSummary"").WebElement(""EndDate"").WebElement(""DatePicker"").WebButton(""DayButton"")","Date","12")
	
	'Verify selection success 
	'Get the selected End date
	sSelectedEndDate = Browser("BC").Page("DealSummary").WebElement("EndDate").WebEdit("SelectedDay").GetROProperty("Value") 

	If sSysMonth & "-" & "12-" & sSysYear <> sSelectedEndDate Then
		Call fReport("fGuiSelectDates","Select 'End Date'","FAIL","Select 'End Date' failed",0)
		bSelectionFailed = 1 'Selection failed flag
	Else
		Call fReport("fGuiSelectDates","Select 'End Date'","PASS","Select 'End Date' success",0)
	End If

End Function

Public Function fGuiSelectPartners(ByRef bSelectionFailed, ByVal sTest)

'------------------------------------------
' Function name: fGuiSelectPartners
' Description: The function select Regional Customer and Regional Vendor and verify selected succesfully
' Parameters: 
' Return value:
' Example:
'------------------------------------------
	
	Dim sCustomer, sVendor
	
	'Select Case sTest
		'Case "Sanity"
			'sCustomer = GlobalDictionary("SANITY_CUSTOMER")
			'sVendor = GlobalDictionary("SANITY_VENDOR")
		'Case "SystemCalculation"
			sCustomer = GlobalDictionary("SYS_CALC_CUSTOMER")
			sVendor = GlobalDictionary("SYS_CALC_VENDOR")		
	'End Select

'Select Customer
	Call fSetValue("Browser(""BC"").Page(""DealSummary"").WebEdit(""SearchCustomer"")","WebEdit",sCustomer)
	Wait 1	
	Call fSetValue("Browser(""BC"").Page(""DealSummary"").WebTable(""RegionalCustomers"").WebCheckbox(""CustomerCheckBox"")","WebCheckBox","")
	Wait 2
	'Verify selection success 
	If Browser("BC").Page("DealSummary").WebElement("SelectedCustomers").Exist(0) = False Then
		Call fReport("fGuiSelectPartners","Select 'Regional Customer'","FAIL","Selected 'Regional Customer' failed",0)
		bSelectionFailed = 1 'Selection failed flag
	Else
		Call fReport("fGuiSelectPartners","Select 'Regional Customer'","PASS","Selected 'Regional Customer' success",0)
	End If

'Select Vendor
	Call fSetValue("Browser(""BC"").Page(""DealSummary"").WebEdit(""SearchVendor"")","WebEdit",sVendor)	
	Wait 1
	Call fSetValue("Browser(""BC"").Page(""DealSummary"").WebTable(""RegionalVendors"").WebCheckbox(""VendorCheckBox"")","WebCheckBox","")
	Wait 2
	'Verify selection success 
	If Browser("BC").Page("DealSummary").WebElement("SelectedVendors").Exist(0) = False Then
		Call fReport("fGuiSelectPartners","Select 'Regional Vendor'","FAIL","Selected 'Regional Vendor' failed",0)
		bSelectionFailed = 1 'Selection failed flag
	Else
		Call fReport("fGuiSelectPartners","Select 'Regional Vendor'","PASS","Selected 'Regional Vendor' success",0)
	End If

fGuiSelectPartners = True

End Function

Public Function fGuiSetBCDescription(ByRef sBCDescription)

'------------------------------------------
' Function name: fGuiSetBCDescription
' Description: The function set unique text in the 'BC Description' field
' Parameters: sDescription 
' Return value: sDescription - Return the unique seted value in order to search by it the new created BC
' Example:
'------------------------------------------
	
	'To create a unique description
	sBCDescription = "BC Created at " & now
	
	Call fSetValue("Browser(""BC"").Page(""DealSummary"").WebElement(""BCDescription"").WebEdit(""SetDescription"")","WebEdit",sBCDescription)
	If Browser("BC").Page("DealSummary").WebElement("BCDescription").WebEdit("SetDescription").GetROProperty("Value") <> sBCDescription Then
		Call fReport("fGuiSetBCDescription","Set 'BC Description'","FAIL","Set 'BC description' value failed",0)
		bSelectionFailed = 1 'Selection failed flag
	Else
		Call fReport("fGuiSetBCDescription","Set 'BC Description'","PASS","Set 'BC escription' value success",0)
	End If

fGuiSetBCDescription = True

End Function

Public Function fGuiGetNewCreatedBC(ByVal sBCDescription)	

'------------------------------------------
' Function name: fGuiGetNewCreatedBC
' Description: The function get the ID of a new created BC by running query 
' Parameters: sBCDescription
' Return value: DealID - the new Deal ID 
' Example:
'------------------------------------------
	
	Dim sSQL,rc,DealID
	
	sSQL = fGetQuery("Get_new_created_BC",array(sBCDescription))
	
	rc = fDBGetOneValue ("BC", sSQL, DealID)
	
	If fCheckQueryResults("fGuiGetNewCreatedBC - Get new BC ID","Get the new BC_ID by query", rc) <> True Then 
		fGuiGetNewCreatedBC = False
		Exit Function
	End If
	
	Call fReport("fGuiGetNewCreatedBC","Get the new BC_ID by query","PASS","The new created BC_ID is " & DealID ,0)	
	fGuiGetNewCreatedBC = DealID
		
End Function

Public Function fGuiGetSearchFieldDetails(ByVal sObjName,ByRef sObjHierarchy, ByRef sObjType)

'------------------------------------------
' Function name: fGuiGetSearchFieldDetails
' Description: The function contains the search fields hierarchies and types
' Parameters: sObjName - search field name, 
' Return value: sObjHierarchy - field hierarchy ,sObjType = field type
' Example:
'------------------------------------------
	
	Select Case sObjName
		
		Case "DealID"
			sObjHierarchy = "Browser(""BC"").Page(""SearchBC"").WebEdit(""DealID"")"
			sObjType = "WebEdit"
		
		Case "RegionalCustomer"
		
		Case "RegionalVendor"
		
		Case "StartDate"
		
		Case "EndDate"
		
		Case "CreateDate"
		
		Case "Status"
		
		Case "Type"
		
		Case "Opertaor"
		
	End Select

End Function

Public Function fGuiSelectBC(ByVal DealID, ByVal sTableName)

'------------------------------------------
' Function name: fGuiSelectBC
' Description: The function select a specific BC in search page
' Parameters: DealID - Deal to select, sTableName - the table to check the BC 
' Return value: 
' Example:
'------------------------------------------
	
	Dim iRow

	'Navigate to search screen 
	If Not Browser("BC").Page("SearchBC").Exist(0) Then
		 If fNavigateToPage("Search","SearchLink") = False Then
		 	Call fCaptureScreen("BC","fGuiSelectBC","Navigate to Search page","Navigation failed, can't select BC. stop running!")
		 	ExitRun
		 End If
	 End If
	  
	'Get the BC row number
	iRow = Browser("BC").Page("SearchBC").WebElement(sTableName & "TableElement").WebTable(sTableName & "Table").GetRowWithCellText(DealID,2)
	
	'Select the specific BC
	Browser("BC").Page("SearchBC").WebElement(sTableName & "TableElement").WebTable(sTableName & "Table").ChildItem(iRow,1,"WebCheckBox",0).Click
	
	'Validation of seccess selection 
	'If Browser("BC").Page("SearchBC").WebElement(sTableName & "TableElement").WebTable(sTableName & "Table").ChildItem(iRow,1,"WebCheckBox",0). Then
	'	Call fReport("fGuiUpdateBC","Verify update mode","PASS","Load BC - " & DealID &" in 'Update' mode success",0)
	'End If
	
End Function

Public Function fGuiLoadBCInMode(ByVal sPage, ByVal sMode, ByVal DealID)

'------------------------------------------
' Function name: fGuiLoadBCInMode
' Description: The function load BC in 'Create'/'Update'/'View' mode
' Parameters: sPage - page to click in - Search or Deal summary, sMode - Button to click - NewBc/UpdateBc or ViewBC
' Return value: 
' Example:
'------------------------------------------
	
	Dim iLoadedBC
	
	'Click on the required button on the required page
	Call fSetValue("Browser(""BC"").Page(""" & sPage & "BC"").WebButton(""" & sMode & "BC"")","WebButton","")
	
	'Submit the Corporate Policy Popup
	If Browser("BC").Dialog("CorporatePolicyPopup").Exist(1) Then
		Browser("BC").Dialog("CorporatePolicyPopup").WinButton("OK").Click
	End If
	
	'Sync to Deal summary page
	If fSyncByObjectForPage("DealSummary") <> True Then
		Call fReport("fGuiUpdateBC","Click on '" & sMode & "BC' button","FAIL",sMode & " BC failed",0)
		Exit Function
	End If 
	
	'Validate action success
	Select Case sMode
		
		'On Update/View - Verify changed to required mode and correct DealID displayed
		Case "Update", "View"
		
			iLoadedBC = Browser("BC").Page("DealSummary").WebElement("DealIDLable").WebElement("DealID").GetROProperty("innertext")
			If Browser("BC").WebElement(sMode & "Mode").Exist(0) and cInt(iLoadedBC) = cInt (DealID) Then
				Call fReport("fGuiLoadBCInMode","Verify '" & sMode & "' mode","PASS","Click on '" & sMode & "BC' to BC " & DealID & " success",0)
			Else
				Call fReport("fGuiLoadBCInMode","Verify '" & sMode & "' mode","FAIL","Click on '" & sMode & "BC' to BC " & DealID & " failed",0)
			End If

		'On Create - Verify changed to Create mode
		Case "Create"
			If Browser("BC").WebElement(sMode & "Mode").Exist(0) Then
				Call fReport("fGuiLoadBCInMode","Verify '" & sMode & "' mode","PASS","Click on '" & sMode & "BC' success",0)
			Else
				Call fReport("fGuiLoadBCInMode","Verify '" & sMode & "' mode","FAIL","Click on '" & sMode & "BC' failed",0)
			End If
		
	End Select
	
End Function

Public Function fGuiNavigateToScreen(ByVal sParentScreen, ByVal sChildScreen)

'------------------------------------------
' Function name: fGuiNavigateToScreen
' Description: The function is moving between Screens
' Parameters: 
' Return value: 
' Example:
'------------------------------------------
		
	If sParentScreen <> " " Then
		Call Browser("BC").Page("AllPages").WebElement("ParentLink").SetTOProperty ("innertext",sParentScreen)
		Browser("BC").Page("AllPages").WebElement("ParentLink").Click
	End If
	If sChildScreen <> " " Then
		sScreen = sChildScreen
		Call Browser("BC").Page("AllPages").Link("ChildLink").SetTOProperty ("text",sChildScreen)
		Browser("BC").Page("AllPages").Link("ChildLink").Click	
	Else	
		sScreen = sParentScreen
	End If	
		
	'Sync for navigation to screens
	If fSyncByObjectForPage(sScreen) <> True Then
		Call fReport("fGuiNavigateToScreen","Get to " & sChildScreen & "screen","FAIL", "Navigation to screen failed",0)
		fGuiNavigateToScreen = False	
		Exit Function
	End If 

	fGuiNavigateToScreen = True

End Function

Public Function fGuiNavigateToScreenWithoutChild(ByVal sScreen)

'------------------------------------------
' Function name: fGuiNavigateToScreenWithoutChild
' Description: The function is moving between Screens that have no child page
' Parameters: 
' Return value: 
' Example:
'------------------------------------------
		
	If sScreen <> " " Then
		Call Browser("BC").Page("AllPages").Link("ChildLink").SetTOProperty ("text",sScreen)
		Call Browser("BC").Page("AllPages").Link("ChildLink").SetTOProperty ("innertext",sScreen)
		Browser("BC").Page("AllPages").Link("ChildLink").Click
	End If	
		
	'Sync for navigation to screens
	If fSyncByObjectForPage(sScreen) <> True Then
		Call fReport("fGuiNavigateToScreenWithoutChild","Get to " & sScreen & "screen","FAIL", "Navigation to screen failed",0)
		fGuiNavigateToScreenWithoutChild = False	
		Exit Function
	End If 
	
	fGuiNavigateToScreenWithoutChild = True

End Function

Public Function fGuiCreateBucket(ByVal sPartner)

'------------------------------------------
' Function name: fGuiCreateBucket
' Description: The function creates buckets for origination and termination screens
' Parameters: sPartner = Orig/Term
' Return value: 
' Example:
'------------------------------------------
	
	Select Case sPartner
		Case "Orig"
		sChild = sOrigBuckets
		sFilterTextBox = "SearchPreferredRoutes"
		sSearchRoute = "SYS_CALC_PREF_ROUTE"
		sAvailableRoutes = "AvailablePreferredRoutes"
		sSelectedRoutes = "SelectedPreferredRoutes" 
	    Case "Term"
		sChild = sTermBuckets
		sFilterTextBox = "SearchRoutes"
		sSearchRoute = "SYS_CALC_VENDOR_ROUTE"
		sAvailableRoutes = "AvailableRoutes"
		sSelectedRoutes = "SelectedRoutes"
	End Select
	
	If fGuiNavigateToScreen(sBuckets, sChild) <> True Then
		Call fReport("fGuiCreateBucket","Navigate to " & sChild & "screen","FAIL", "Navigation failed",0)
		fGuiCreateBucket = False
		Exit Function
	Else 
		Call fReport("fGuiCreateBucket","Navigate to " & sChild & " screen succeeded","PASS", "Navigation succeeded",0)
	End If
	
	If Browser("BC").Page("Buckets").WebElement("Create" & sPartner & "Bucket").Exist(0) = false Then
		Browser("BC").Page("BC Online - BC Online").WebButton("AddBucket").Click
	End If
		
	'Type country to select
	Call Browser("BC").Page("Buckets").WebList("select").Select (GlobalDictionary("SYS_CALC_" & uCase(sPartner) & "_COUNTRY"))
	
	'Sync to search for the country routes to appear on the available table
	Call Browser("BC").Page("Buckets").WebElement("Create"&sPartner&"Bucket").WebElement(sAvailableRoutes).SetTOProperty("outertext",".*" & GlobalDictionary("SYS_CALC_" & uCase(sPartner) & "_COUNTRY") & ".*")
	While Browser("BC").Page("Buckets").WebElement("Create"&sPartner&"Bucket").WebElement(sAvailableRoutes).Exist(0) <> True 
		Wait 1
	Wend
	
	
	'Search for specific route / preferred routes
	Call Browser("BC").Page("Buckets").WebElement("Create"&sPartner&"Bucket").WebEdit(sFilterTextBox).Set(GlobalDictionary(sSearchRoute))
	'Check if the filtered country route appear on the available list
	Call Browser("BC").Page("Buckets").WebElement("Create"&sPartner&"Bucket").WebElement(sAvailableRoutes).SetTOProperty("outertext",".*" & GlobalDictionary(sSearchRoute) & ".*") 
	If Browser("BC").Page("Buckets").WebElement("Create"&sPartner&"Bucket").WebElement(sAvailableRoutes).Exist(0) <> True Then
		Call fReport("fGuiCreateBucket","Selected route " & "<B>" & GlobalDictionary(sSearchRoute) & "</B>","FAIL", "Selected route not appear on the <B> available routes </B> list",0)
		fGuiCreateBucket = False
		Call fReport("fGuiCreateBucket","Create " & "<B>" & sPartner & "ination </B> bucket","FAIL", "Bucket creation failed",0)
		Exit Function
	Else 
		Call fReport("fGuiCreateBucket","Selected route " & "<B>" & GlobalDictionary(sSearchRoute) & "</B>","PASS", "Selected routes appear on the <B> available routes </B> list",0)
	End If
	
	'Add the route to selected table by double click
	Call Browser("BC").Page("Buckets").WebElement("WebTable").SetTOProperty("innertext",GlobalDictionary(sSearchRoute))
	
	If Browser("BC").Page("Buckets").WebElement("WebTable").Exist(0) <> True Then
		Call fReport("fGuiCreateBucket","The " & "<B>" & GlobalDictionary(sSearchRoute) & "</B>" & " doesn't appear on the available routes table","FAIL", "Route doesn't appear on the routes table",0)
		fGuiCreateBucket = False
		Call fReport("fGuiCreateBucket","Create " & "<B>" & sPartner & "ination </B> bucket","FAIL", "Bucket creation failed",0)
		Exit Function
	Else 
		Call fReport("fGuiCreateBucket","The " & "<B>" & GlobalDictionary(sSearchRoute) & "</B>" & " route appears on the available routes table","PASS", "Route appears on the routes table",0)
	End If
	
	Browser("BC").Page("Buckets").WebElement("Create"&sPartner&"Bucket").WebButton("Add All >>").Click

	'Setting.WebPackage("ReplayType") = 2
	'Browser("BC").Page("Buckets").WebElement("WebTable").FireEvent("ondblclick")
	'Setting.WebPackage("ReplayType") = 1
	
	'Check the selected routes / preferred routes
	Call Browser("BC").Page("Buckets").WebElement("Create"&sPartner&"Bucket").WebElement(sSelectedRoutes).SetTOProperty("outertext",".*" & GlobalDictionary(sSearchRoute) & ".*") 
	If Browser("BC").Page("Buckets").WebElement("Create"&sPartner&"Bucket").WebElement(sSelectedRoutes).Exist(0) <> True Then
		Call fReport("fGuiCreateBucket","Selected route " & "<B>" & GlobalDictionary(sSearchRoute) & "</B>","FAIL", "Selected route not appear on the <B> selected </B> list",0)
		fGuiCreateBucket = False
		Call fReport("fGuiCreateBucket","Create " & "<B>" & sPartner & "ination </B> bucket","FAIL", "Bucket creation failed",0)
		Exit Function
	Else 
		Call fReport("fGuiCreateBucket","Selected route " & "<B>" & GlobalDictionary(sSearchRoute) & "</B>","PASS", "Selected route not appear on the <B> selected </B> list",0)
	End If
	'Set description (by mouse)
	Setting.WebPackage("ReplayType") = 2
	Browser("BC").Page("Buckets").WebEdit("Description").Set (GlobalDictionary(sSearchRoute))
	Setting.WebPackage("ReplayType") = 1
	'Click on Save
	Browser("BC").Page("Buckets").WebButton("Save").Click
	
'	'Sync for the bucket to appear on the screen
'	If fSyncByObject("fGuiCreateBucket", "BC", sPage, sObjType, sObjName, iTime) <> True Then
'		

'	End If

	fGuiCreateBucket = True
	Call fReport("fGuiCreateBucket","Create " & "<B>" & sPartner & "ination </B> bucket","PASS", "Bucket creation succeeded",0)

End Function

Public Function fGuiValidatePageLoaded()
'------------------------------------------
' Function name: fGuiValidatePageLoaded
' Description: The function navigates to the screens: Volumes, Rates & Calc, Termination Codes and Notes and validate the data appear there
' Parameters: 
' Return value: 
' Example:
'------------------------------------------	
	
	'Navigate to 'Volumes - Origination volumes' screen	
	If fGuiNavigateToScreen(sVolumes, sOrigVolumes) <> True Then
		Call fReport("fGuiValidatePageLoaded","Navigate to " & sOrigVolumes & "screen","FAIL", "Navigation failed",0)
		fGuiNavigateToScreen = False
		Exit Function
	Else 
		Call fReport("fGuiValidatePageLoaded","Navigate to " & sOrigVolumes & " screen succeeded","PASS", "Navigation succeeded",0)
	End If
	
	'Validate the data appear in 'Volumes - Origination volumes'
	Browser("BC").Page("Volume").WebTable("RoutesTable").SetTOProperty "outertext",".*" & GlobalDictionary("SYS_CALC_ORIG_COUNTRY" & ".*")

	If Browser("BC").Page("Volume").WebTable("RoutesTable").Exist(0) <> True Then
		Call fReport("fGuiValidatePageLoaded","Selected route " & "<B>" & GlobalDictionary("SYS_CALC_ORIG_COUNTRY") & "</B>","FAIL", "Selected route not appear on the table",0)
		fGuiNavigateToScreen = False
		Exit Function
	Else 
		Call fReport("fGuiValidatePageLoaded","Selected route " & "<B>" & GlobalDictionary("SYS_CALC_ORIG_COUNTRY") & "</B>","PASS", "Selected route appear on the table",0)
	End If
	
	'Navigate to 'Volumes - Termination volumes' screen	
	If fGuiNavigateToScreen(sVolumes, sTermVolumes) <> True Then
		Call fReport("fGuiValidatePageLoaded","Navigate to " & sTermVolumes & "screen","FAIL", "Navigation failed",0)
		fGuiNavigateToScreen = False
		Exit Function
	Else 
		Call fReport("fGuiValidatePageLoaded","Navigate to " & sTermVolumes & " screen succeeded","PASS", "Navigation succeeded",0)
	End If
	
	'Validate the data appear in 'Volumes - Termination volumes'
	Browser("BC").Page("Volume").WebTable("RoutesTable").SetTOProperty "outertext",".*" & GlobalDictionary("SYS_CALC_TERM_COUNTRY" & ".*")

	If Browser("BC").Page("Volume").WebTable("RoutesTable").Exist(0) <> True Then
		Call fReport("fGuiValidatePageLoaded","Selected route " & "<B>" & GlobalDictionary("SYS_CALC_TERM_COUNTRY") & "</B>","FAIL", "Selected route not appear on the table",0)
		fGuiNavigateToScreen = False
		Exit Function
	Else 
		Call fReport("fGuiValidatePageLoaded","Selected route " & "<B>" & GlobalDictionary("SYS_CALC_TERM_COUNTRY") & "</B>","PASS", "Selected route appear on the table",0)
	End If
	
	'Navigate to 'Rates & Calc - Origination Rates & Calculation' screen
	If fGuiNavigateToScreen(sRatesCalc, sOrigRatesCalc) <> True Then
		Call fReport("fGuiValidatePageLoaded","Navigate to " & sOrigRatesCalc & "screen","FAIL", "Navigation failed",0)
		fGuiNavigateToScreen = False
		Exit Function
	Else 
		Call fReport("fGuiValidatePageLoaded","Navigate to " & sOrigRatesCalc & " screen succeeded","PASS", "Navigation succeeded",0)
	End If
	
	'Validate the data appear in 'Rates & Calc - Origination Rates & Calculation'
	Browser("BC").Page("RatesAndCalculation").WebTable("RouteTable").SetTOProperty "outertext",".*" & GlobalDictionary("SYS_CALC_ORIG_COUNTRY" & ".*")

	If Browser("BC").Page("RatesAndCalculation").WebTable("RouteTable").Exist(0) <> True Then
		Call fReport("fGuiValidatePageLoaded","Selected route " & "<B>" & GlobalDictionary("SYS_CALC_ORIG_COUNTRY") & "</B>","FAIL", "Selected route not appear on the table",0)
		fGuiNavigateToScreen = False
		Exit Function
	Else 
		Call fReport("fGuiValidatePageLoaded","Selected route " & "<B>" & GlobalDictionary("SYS_CALC_ORIG_COUNTRY") & "</B>","PASS", "Selected route appear on the table",0)
	End If
	
	'Navigate to 'Rates & Calc - Termination Rates & Calculation' screen
	If fGuiNavigateToScreen(sRatesCalc, sTermRatesCalc) <> True Then
		Call fReport("fGuiValidatePageLoaded","Navigate to " & sTermRatesCalc & "screen","FAIL", "Navigation failed",0)
		fGuiNavigateToScreen = False
		Exit Function
	Else 
		Call fReport("fGuiValidatePageLoaded","Navigate to " & sTermRatesCalc & " screen succeeded","PASS", "Navigation succeeded",0)
	End If
	
	'Validate the data appear in 'Rates & Calc - Termination Rates & Calculation'
	Browser("BC").Page("RatesAndCalculation").WebTable("RouteTable").SetTOProperty "outertext",".*" & GlobalDictionary("SYS_CALC_TERM_COUNTRY" & ".*")

	If Browser("BC").Page("RatesAndCalculation").WebTable("RouteTable").Exist(0) <> True Then
		Call fReport("fGuiValidatePageLoaded","Selected route " & "<B>" & GlobalDictionary("SYS_CALC_TERM_COUNTRY") & "</B>","FAIL", "Selected route not appear on the table",0)
		fGuiNavigateToScreen = False
		Exit Function
	Else 
		Call fReport("fGuiValidatePageLoaded","Selected route " & "<B>" & GlobalDictionary("SYS_CALC_TERM_COUNTRY") & "</B>","PASS", "Selected route appear on the table",0)
	End If
	
	'Navigate to 'Termination Codes'
	If fGuiNavigateToScreenWithoutChild(sTermCodes) <> True Then
		Call fReport("fGuiValidatePageLoaded","Navigate to " & sTermCodes & "screen","FAIL", "Navigation failed",0)
		fGuiNavigateToScreenWithoutChild = False
		Exit Function
	Else 
		Call fReport("fGuiValidatePageLoaded","Navigate to " & sTermCodes & " screen succeeded","PASS", "Navigation succeeded",0)
	End If
	
	'Navigate to 'Notes'
	If fGuiNavigateToScreenWithoutChild(sNotes) <> True Then
		Call fReport("fGuiValidatePageLoaded","Navigate to " & sNotes & "screen","FAIL", "Navigation failed",0)
		fGuiNavigateToScreenWithoutChild = False
		Exit Function
	Else 
		Call fReport("fGuiValidatePageLoaded","Navigate to " & sNotes & " screen succeeded","PASS", "Navigation succeeded",0)
	End If

End Function

Public Function fGuiGetAndSetExchangeRate()
	
'------------------------------------------
' Function name: fGuiGetAndSetExchangeRate
' Description: The function pulls Exchange rate (EUR --> USD) from the DB and set it in the excel
' Parameters:
' Return value: 
' Example:
'------------------------------------------	
	
	'Get exchange rate from the DB
	sqlExchangeRate = QueriesDictionary("Get_Exchange_Rate")
	rc = fDBGetOneValue("BC", sqlExchangeRate, iExchangeRate)
	If fCheckQueryResults("fGuiGetAndSetExchangeRate", "Get Exchange rate", rc) <> True Then
		Call fReport("fGuiGetAndSetExchangeRate","Get Exchange rate","FAIL", "Get Exchange rate from the DB failed",0)
		'fGuiGetAndSetExchangeRate = False
		Exit Function
	End If
	
	'Set exchange rate in the excel
	Call fSetValueInExcelOneField("OriginationRates&Calc","Rev","Global",iExchangeRate)
	
End Function

Public Function fGuiGetDBFieldsValues(ByVal sPartner,ByVal arrRequiredValues)
	
'------------------------------------------
' Function name: fGuiGetDBFieldsValues
' Description: The function pulls ACPM, ShortFall min. and ARPM from DB, compare with the UI and set them in the excel
' Parameters: sPartner = Orig/Term
' Return value: 
' Example:
'------------------------------------------
	
	ReDim arrRequiredValues(1)
	Dim arrColumns(1)
	
	
	'Set ACPM, ARPM and Shortfall minutes in the excel
	
	If sPartner = "Orig" Then 'Origination
	
		'Get Origination ACPM & ShortMin Query from the excel and values from DB
		If fGuiGetACPMShortMinARPM("Customer","Queries","ACPM & ShortMin","Base", rsRequiredValue) <> True Then
			'TODO - check on debbug if need to add report
			fGuiGetDBFieldsValues = False
			Exit Function
		Else
			rsRequiredValue.MoveFirst
			arrRequiredValues(0) = Trim(rsRequiredValue.Fields("SHORTFALL_MINUTES").Value)
			arrRequiredValues(1) = Trim(rsRequiredValue.Fields("ACPM").Value)
			arrColumns(0) = "Shortfall Min"
			arrColumns(1) = "T1 ACPM"
			'Set the values in the excel
			Call fSetValueInExcel("OriginationRates&Calc",arrColumns,"Route 1",arrRequiredValues)
		End If
	
	Else 'Termination
	
		'Get Termination ARPM and ACPM Query and values from DB
		If fGuiGetACPMShortMinARPM("Vendor","Queries","ARPM & ACPM","Base",rsRequiredValue) <> True Then
			'TODO - check on debbug if need to add report
			fGuiGetDBFieldsValues = False
			Exit Function
		Else
			rsRequiredValue.MoveFirst
			arrRequiredValues(0) = Trim(rsRequiredValue.Fields("ARPM").Value)
			arrRequiredValues(1) = Trim(rsRequiredValue.Fields("ACPM").Value)
			arrColumns(0) = "ARPM" 
			arrColumns(1) = "T1 P ACPM"
			'Set the values in the excel
			Call fSetValueInExcel("TerminationRates&Calc",arrColumns,"Route 1",arrRequiredValues)
		End If
	
	End If

End Function

Public Function fGuiGetACPMShortMinARPM(ByVal sPartner,ByVal sSheetName,ByVal sRequiredQuery,ByVal sCellName,ByRef sRequiredValue) 

'------------------------------------------
' Function name: fGuiGetACPMShortMinARPM
' Description: The function pulls ACPM, ShortFall min. and ARPM from DB
' Parameters: sPartner = Customer / Vendor
' Return value: 
' Example:
'------------------------------------------
	
	Dim strRMSIDs,arrParamValues
	
	fGuiGetACPMShortMinARPM = True
	
	Select Case sPartner
		Case "Customer"
			sRouteDesc = Array (Trim(GlobalDictionary("SYS_CALC_PREF_ROUTE")))
		Case "Vendor"
			sRouteDesc = Array (Trim(GlobalDictionary("SYS_CALC_IBASIS_ROUTE")))
	End Select

	'Get Termination ARPM Query and values from DB
	Call fGetDataFromExcelOneField(sSheetName, sRequiredQuery, sCellName, sQuery)

	'Get customer/vendor currency
	arrParamValues = Array(GlobalDictionary("SYS_CALC_" & uCase (sPartner)))
	arrParamValues(0) = Replace(arrParamValues(0),"&","' || Q'[&]' || '")
	sqlCurrency = fGetQuery ("Get_" & sPartner & "_Currency", arrParamValues)
	rc = fDBGetOneValue("BC", sqlCurrency, sCurrency)
	If fCheckQueryResults("fGuiGetACPMShortMinARPM", "Get Vendor currency", rc) <> True Then
		Call fReport("fGuiGetACPMShortMinARPM","Get " & sPartner & " currency","FAIL", "Get currency failed",0)
		fGuiGetACPMShortMinARPM = False
		Exit Function
	End If
	
	'Get route/preferred route id
	sqlRouteIDs = fGetQuery ("Get_Route_ID", sRouteDesc) 'Route/Preferred Route description
	rc = fDBGetRS("BC", sqlRouteIDs, rsRouteID)
	If fCheckQueryResults("fGuiGetACPMShortMinARPM", "Get preferred route / route IDs", rc) <> True Then
		Call fReport("fGuiGetACPMShortMinARPM","Get " & sPartner & " preferred route / route IDs","FAIL", "Get preferred route / route IDs failed",0)
		fGuiGetACPMShortMinARPM = False
		Exit Function
	End If
	
	'Get customer/vendor RMS IDs
	sqlRMSIDs = fGetQuery ("Get_" & sPartner & "_RMS_IDs", arrParamValues)
	rc = fDBGetRS("BC", sqlRMSIDs, rsRMSIDs)
	If fCheckQueryResults("fGuiGetACPMShortMinARPM", "Get " & sPartner & " RMS IDs", rc) <> True Then
		Call fReport("fGuiGetACPMShortMinARPM","Get " & sPartner & " RMS IDs","FAIL", "Get RMS IDs failed",0)
		fGuiGetACPMShortMinARPM = False
		Exit Function
	End If
	iCount = fObjRSRecordCount(rsRMSIDs)
	rsRMSIDs.MoveFirst
	For i = 1 To iCount
		If i = 1 Then
			strRMSIDs = strRMSIDs & rsRMSIDs.Fields("RMS_ID").Value
		Else
			strRMSIDs = strRMSIDs & "," & rsRMSIDs.Fields("RMS_ID").Value
		End If
			
		rsRMSIDs.MoveNext
	Next
	
	'Add select case sPartner (to add vendor route description to sRouteIDRS)
	Select Case sPartner
		Case "Customer"
			rsRoutePrefRouteID = rsRouteID.fields(0).value
		Case "Vendor"
			rsRoutePrefRouteID = rsRouteID.fields(0).value & "-" & Trim(GlobalDictionary("SYS_CALC_VENDOR_ROUTE"))
	End Select
	
	arrParamValue = Array(sCurrency,rsRoutePrefRouteID,strRMSIDs)
		
	'Run required query and get the results

	sSQL = fReplaceParamInQuery (sQuery, arrParamValue)
	rc = fDBGetRS("BC", sSQL, sRequiredValue)
	If fCheckQueryResults("fGuiGetACPMShortMinARPM", "Get " & sRequiredQuery, rc) <> True Then
		Call fReport("fGuiGetACPMShortMinARPM","Get " & sRequiredQuery & " from DB","FAIL", "Get " & sRequiredQuery & " failed",0)
		fGuiGetACPMShortMinARPM = False
		Exit Function 
		Call fReport("fGuiGetACPMShortMinARPM","Get " & sRequiredQuery & " from DB","PASS", "Get values from DB succeeded",0)
	End If	
	
End Function

Public Function fGuiGetXLData(ByVal sPartner,ByRef arrXLValues, ByRef arrXLColumns)
	
'------------------------------------------
' Function name: fGuiGetXLData
' Description: The function gets the fields from the excel into an array 
' Parameters: sPartner = Customer / Vendor
' Return value: 
' Example:
'------------------------------------------
	
	Dim sSheetName, sCellName, iArrSize
		
	Select Case sPartner
		Case "Orig"
			sSheetName = "OriginationRates&Calc"
			arrXLColumns = Array("T1 Sett. Rate","T1 Exp Vol","Incr Rate","Sett. Rev","Rev","T1 ACPM","Shortfall Min","Margin","Cost","GrossProfit (Sett.Rate)","Min Margin","Addl Margin Dist.","Auto Margin Dist.","T1 Eff Rate","Margin Trans/Min","Margin Trans","Partner Alt Cost","Partner Sub")
		Case "Term"
			sSheetName = "TerminationRates&Calc"
			arrXLColumns = Array("T1 P Sett. Rate","T1 Exp Vol","Incr Rate","ARPM","Revenue","Sett. cost","Cost","Margin","GrossProfit (Sett.Rate)","MTR Cost","T1 P ACPM","MPM Req Alt","Margin Alt. Match","Man Cost Decr","Addl Margin Usage","Tot Term Trans","Net Gross Profit","T1 Eff Rate P","Margin Trans/ Min","Margin Transfer","Partner Margin")
		Case "StrategicDetails"
			arrXLColumns = Array("Origination Margin Partner","Settlement Revenue Partner","Origination margin/min Partner","Incr Margin/Minute Partner","Origination Margin iBasis","Settlement Revenue iBasis","Origination margin/min iBasis","Incr Margin/Minute","Who has the better deal?")
		Case "DealDetails"
			arrXLColumns = Array("Origination Volume","Termination Volume","Total Volume","Origination Settlement Revenue","Origination Effective Revenue","Termination Settlement Cost","Termination Effective Cost","Round Trip Revenue (Effective Rates)","Projected Net Cash Position","Gross Profit Origination","Origination AMPM","Gross Profit Termination","Termination AMPM","Gross Profit Round Trip","Round trip AMPM","Incremental Gross Profit","Incremental AMPM","Incremental Gross Profit Per Month")
	End Select
	
	iArrSize = uBound(arrXLColumns)
	
	Call fGetDataFromExcel(sSheetName,arrXLColumns,"Route 1",arrXLValues,iArrSize)
	
End Function

Public Function fGuiSetEdiableValuesInUI(ByVal sPartner,ByVal arrXLValues,ByRef arrUIColumns,ByRef arrFieldsType)
	
'------------------------------------------
' Function name: fGuiSetEdiableValuesInUI
' Description: The function sets ediable fields in the UI 
' Parameters: sPartner = Orig / Term
' Return value: 
' Example:
'------------------------------------------
	
	Dim iArrSize, sChild
	iArrSize = uBound(arrXLValues)
	
	'	Set UI columns and fields type arrays
	Select Case sPartner 
		Case "Orig"
			sChild = sOrigRatesCalc
			arrFieldsType = Array("Edit","Edit","Both","Read","Read","Both","Read","Read","Read","Read","Both","Edit","Read","Read","Read","Read","Both","Read")
			arrUIColumns = Array("peakSetRate1","expectedMinutes1","incrementalRates","settlementRevenue","effectiveRevenue","acpmPeak1","shortfallMinutes","totalEffectiveMargin","totalCost","setRatesTotalGrossProfit","minMarginMinute","additionalMarginDistribution","addAutoMarginDistribution","effectiveRatePeak1","totalMarginTransferMinute","totalMarginTransfer ","partnerAlternativeCost","partnerSubstitution")
		Case "Term"
			sChild = sTermRatesCalc
			arrFieldsType = Array("Edit","Edit","Both","Both","Read","Read","Read","Read","Read","Both","Both","Read","Read","Edit","Read","Read","Read","Read","Read","Read","Read")
			arrUIColumns = Array("peakSetRate1","expectedMinutes1","incrementalRates","expectedArpm","estimatedRevenue","totalCostBasedSetRate","totalCostBasedEffRate","estimateMarginBasedEffRate","totalGrossProfitBasedSet","mtrCostOfPartner","acpmPeak1","distMinMeetAlternative","marginAlternativeMatch","additionalCostDecrease","additionalMarginUsage","grossProfitTermTransfer","netGrossProfitForTerm","effectiveRatePeak1","totalMarginTransferMinute","totalMarginTransfer ","marginOfOurPartner")
	End Select
	
	'	Navigate to rates & Calculation screen
	If fGuiNavigateToScreen(sRatesCalc, sChild) <> True Then
		Call fReport("fGuiGetDBFieldsValues","Navigate to " & sChild & " screen to set editable fields","FAIL", "Navigation failed",0)
		fGuiGetDBFieldsValues = False
		Exit Function
	Else 
		Call fReport("fGuiGetDBFieldsValues","Navigate to " & sChild & " screen to set editable fields","PASS", "Navigation succeeded",0)
	End If
	
	For i = 0 To iArrSize
	
'	If i = 0 Then
'		Call Browser("BC").Page("RatesAndCalculation").WebElement("Field").SetTOProperty("outerhtml",".*" & arrUIColumns(i) & ".*")
'		Browser("BC").Page("RatesAndCalculation").WebElement("Field").Click
'	End If
	
		If i = 0 Then
			Call Browser("BC").Page("RatesAndCalculation").WebTable("RoutesTable").WebElement("Field").SetToProperty("outerhtml",".*" & arrUIColumns(i) & ".*")
			Browser("BC").Page("RatesAndCalculation").WebTable("RoutesTable").WebElement("Field").Click
		End If
		
		If arrFieldsType(i) = "Edit" Then
			Call Browser("BC").Page("RatesAndCalculation").WebTable("RoutesTable").WebEdit("Edit").SetToProperty("outerhtml",".*" & arrUIColumns(i) & ".*")
			Browser("BC").Page("RatesAndCalculation").WebTable("RoutesTable").WebEdit("Edit").Set(arrXLValues(i))
		End If
		
	Next
	
End Function

Public Function fGuiGetUIData(ByVal sPartner, ByRef arrUIValues, ByVal arrUIColumns, ByVal arrFieldsType)
	
'------------------------------------------
' Function name: fGuiGetUIData
' Description: The function gets all UI data 
' Parameters: sPartner = Orig / Term
' Return value: 
' Example:
'------------------------------------------
	
	Dim iArrSize, sChild
	
	Select Case sPartner
		Case "Orig"
			sChild = sOrigRatesCalc
		Case "Term"
			sChild = sTermRatesCalc
	End Select
	
	'	Navigate to rates & Calculation screen
	If fGuiNavigateToScreen(sRatesCalc, sChild) <> True Then
		Call fReport("fGuiGetDBFieldsValues","Navigate to " & sChild & " screen to get UI fields data","FAIL", "Navigation failed",0)
		fGuiGetDBFieldsValues = False
		Exit Function
	Else 
		Call fReport("fGuiGetDBFieldsValues","Navigate to " & sChild & " screen to get UI fields data","PASS", "Navigation succeeded",0)
	End If
	
'	If sPartner = "StrategicDetails" Then 'Navigate to deal summary screen
''TODO update data in the following steps
''		If fNavigateToPage(sPage, sPageLink) <> True Then
''			Call fReport("fGuiGetDBFieldsValues","Navigate to " & sScreen & "screen","FAIL", "Navigation failed",0)
''			fGuiGetDBFieldsValues = False
''			Exit Function
''		Else 
''			Call fReport("fGuiGetDBFieldsValues","Navigate to " & sScreen & " screen succeeded","PASS", "Navigation succeeded",0)
''		End If
'	End If
	
	iArrSize = uBound(arrUIColumns)
	
	For i = 0 To iArrSize
	
'		If i = 0 Then
'			Browser("BC").Page("RatesAndCalculation").WebTable("RoutesTable").WebElement("Field").Click 'Focus on the record to get the fields editable
'		End If
		
		If arrFieldsType(i) = "Edit" OR arrFieldsType(i) = "Both" Then
			Call Browser("BC").Page("RatesAndCalculation").WebTable("RoutesTable").WebEdit("Edit").SetToProperty("outerhtml",".*" & arrUIColumns(i) & ".*")
			ReDim Preserve arrUIValues(i)
			arrUIValues(i) = Browser("BC").Page("RatesAndCalculation").WebTable("RoutesTable").WebEdit("Edit").GetROProperty("value")
		Else
			Call Browser("BC").Page("RatesAndCalculation").WebTable("RoutesTable").WebElement("Read").SetToProperty("outerhtml",".*" & arrUIColumns(i) & ".*")
			ReDim Preserve arrUIValues(i)
			arrUIValues(i) = Browser("BC").Page("RatesAndCalculation").WebTable("RoutesTable").WebElement("Read").GetROProperty("innertext")
		End If

	Next
	
End Function

Public Function fGuiCompareUIWithXL(ByVal sPartner,ByVal arrXLValues,ByVal arrUIValues,ByVal arrXLColumns)

'------------------------------------------
' Function name: fGuiCompareUIWithXL
' Description: The function Compare values between the excel and the UI 
' Parameters: sPartner = Orig / Term
' Return value: 
' Example:
'------------------------------------------
	
	Dim iArrSize
	
	Call fReport("fGuiCompareUIWithXL","Comparing <B>" & sPartner & " Rates & Calculation </B> Field","HEADER", "Comparing <B>" & sPartner & "</B> main grid fields",0)
	
'	arrOrigFieldsFormat = Array("Rate","Volume","Rate","Volume","Volume","Rate","Volume","Volume","Volume","Volume","Rate","Rate","Rate","Rate","Rate","Volume","Rate","Volume")
'	arrTermFieldsFormat = Array("Rate","Volume","Rate","Rate","Volume","Volume","Volume","Volume","Volume","Rate","Rate","Rate","Volume","Rate","Volume","Volume","Volume","Rate","Rate","Volume","Volume")

	iArrSize = uBound(arrXLValues)
	
	For i = 0 To iArrSize

		If arrXLValues(i) = arrUIValues(i) <> True Then
			'Report wrong values
			Call fReport("fGuiCompareUIWithXL","Comparison of <B>" & arrXLColumns(i) & "</B> Field","FAIL", "<B>" & arrXLColumns(i) & "</B> is <B>" & arrUIValues(i) & "</B> on the UI but <B>" & arrXLValues(i) & "</B> on the XL",0)
		Else
			'Report correct values
			Call fReport("fGuiCompareUIWithXL","Comparison of <B>" & arrXLColumns(i) & "</B> Field","PASS", "<B>" & arrXLColumns(i) & "</B> is <B>" & arrUIValues(i) & "</B> both on UI and XL",0)
		End If
		
	Next
		
End Function 

Public Function fGuiCompareOrigUIwithDB(ByVal iDealID)
	
'------------------------------------------
' Function name: fGuiCompareOrigUIwithDB
' Description:  
' Parameters: sPartner = Orig / Term, iDealID = Deal ID
' Return value: 
' Example:
'------------------------------------------

	Dim sSQL
			
	'Navigate to rates & Calculation screen
	If fGuiNavigateToScreen(sRatesCalc, sOrigRatesCalc) <> True Then
		Call fReport("fGuiGetDBFieldsValues","Navigate to " & sOrigRatesCalc & " screen to get UI fields data","FAIL", "Navigation failed",0)
		fGuiGetDBFieldsValues = False
		Exit Function
	Else 
		Call fReport("fGuiGetDBFieldsValues","Navigate to " & sOrigRatesCalc & " screen to get UI fields data","PASS", "Navigation succeeded",0)
	End If
	
	sSQL = DbTable("DbTableOrigDB").GetTOProperty("source")
	sSQL = Replace (sSQL,"BCID",iDealID)
	
	Browser("BC").Page("RatesAndCalculation").WebTable("OrigMainGrid").Output CheckPoint("OrigMainGrid")
	
	Call DbTable("DbTableOrigDB").SetTOProperty("source",sSQL)
	
	DbTable("DbTableOrigDB").Check CheckPoint("DbTableOrigGui")

End Function

Public Function fGuiCompareTermUIwithDB(ByVal iDealID)
	
'------------------------------------------
' Function name: fGuiCompareTermUIwithDB
' Description:  
' Parameters: sPartner = Orig / Term, iDealID = Deal ID
' Return value: 
' Example:
'------------------------------------------

	Dim sSQL
			
	'Navigate to rates & Calculation screen
	If fGuiNavigateToScreen(sRatesCalc, sTermRatesCalc) <> True Then
		Call fReport("fGuiGetDBFieldsValues","Navigate to " & sTermRatesCalc & " screen to get UI fields data","FAIL", "Navigation failed",0)
		fGuiGetDBFieldsValues = False
		Exit Function
	Else 
		Call fReport("fGuiGetDBFieldsValues","Navigate to " & sTermRatesCalc & " screen to get UI fields data","PASS", "Navigation succeeded",0)
	End If
	
	
	sSQL = DbTable("DbTableTermDB").GetTOProperty("source")
	sSQL = Replace (sSQL,"BCID",iDealID)

	'Browser("home").Page("BC Online - BC Online_3").WebTable("TermMainGrid").Output CheckPoint("TermMainGrid")
	Browser("BC").Page("RatesAndCalculation").WebTable("TermMainGrid").Output CheckPoint("TermMainGrid")

	Call DbTable("DbTableTermDB").SetTOProperty("source",sSQL)
	
	DbTable("DbTableTermDB").Check CheckPoint("DbTableTermGUI")


End Function

Public Function fGuiSaveBC(ByVal sSaveBCAs, ByVal bSelectionFailed)

'------------------------------------------
' Function name: fGuiSaveBC
' Description: The function save BC and verify correct saving
' Parameters: 
' Return value:
' Example:
'------------------------------------------
	
	Wait 5

	If bSelectionFailed = 1 Then
		Call fReport("fGuiSaveBC","Save basic created deal","INFO","Can't save the deal, selecting a value on one of mandatory fields failed - stop running",0)	
		Exitrun
	End If
	
	If Browser("BC").WebElement("Save").Exist(0.5) Then
		Browser("BC").WebElement("Save").Click
		Wait 1
		Browser("BC").Link("SaveAs" & sSaveBCAs).Click
	Else
		Call fReport("fGuiSaveBC","Save Business Case","FAIL","Clicking on 'Save' button failed",0)
		ExitRun
	End If	
	
	If Browser("BC").Dialog("CorporatePolicyPopup").WinButton("OK").Exist = True Then
		Browser("BC").Dialog("CorporatePolicyPopup").WinButton("OK").Click
	End If

	If Browser("BC").Dialog("CorporatePolicyPopup").WinButton("OK").Exist = True Then
		Browser("BC").Dialog("CorporatePolicyPopup").WinButton("OK").Click
	End If
	
	'Sync to save popup to appear
	While (Browser("BC").WebElement("SaveSuccesfully").Exist(1) <> True AND Browser("BC").WebElement("SaveFailed").Exist(1) <> True)
		Wait 1
	Wend
		
	'Saving verification
	If Browser("BC").WebElement("SaveSuccesfully").Exist(1) = True Then
		Call fReport("fGuiSaveBC","Save Business Case","PASS","Save BC succesfully",0)
		'Close the save status popup
		Browser("BC").WebElement("SaveSuccesfully").WebButton("OK").Click
	ElseIf Browser("BC").WebElement("SaveFailed").Exist(1) Then
		Call fReport("fGuiSaveBC","Save Business Case","FAIL","Saving BC failed",0)
		'Close the save status popup
		Browser("BC").WebElement("SaveFailed").WebButton("OK").Click
	End If
	
	Wait 1

fGuiSaveBC = True

End Function







