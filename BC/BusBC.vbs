'Yael Comment
Option Explicit
Public const sSearch = "Search"
Public const sDealSummary = "Deal Summary"
Public const sBuckets = "Buckets", sOrigBuckets = "Origination Buckets", sTermBuckets = "Termination Buckets"
Public const sVolumes = "Volumes", sOrigVolumes = "Origination Volumes", sTermVolumes = "Termination Volumes"
Public const sRatesCalc = "Rates & Calc", sOrigRatesCalc = "Origination Rates & Calculation", sTermRatesCalc = "Termination Rates & Calculation"
Public const sTermCodes = "Termination Codes"
Public const sNotes = "Notes"
Public const sXLFilePath = 	"T:\Matrix-QA\QTP-Aoutomation\QTP - BC\QTP\BC\Version1\STORAGE\CalcXL\SystemCalculationNew-V10.xlsx"

Public Function fBusSanity()

	'------------------------------------------
	' Function name: fBusSanity
	' Description: 
	' Parameters:
	' Return value:
	' Example:
	'------------------------------------------
		
	Dim bSelectionFailed,sBCDescription,DealID
	
	'Login to BC application and navigate to Search page
	Call fGuiLogin()
	
	'Create basic deal
	Call fGuiCreateBasicDeal(bSelectionFailed,sBCDescription,"Sanity")
	
	'Create Origination and Termination Buckets
	Call fGuiCreateBucket("Orig")
	Call fGuiCreateBucket("Term")
	
	'Validate the pages are loaded
	Call fGuiValidatePageLoaded()	
	
	'Save the BC as 'Draft' and verify correct saving
	Call fGuiSaveBC("Draft",bSelectionFailed)
			
	'Get the ID of the new created deal from the DB
	DealID = fGuiGetNewCreatedBC(sBCDescription)
	
	'Search BC_ID
	Call fGuiSearchBC(array("DealID"),array(DealID))
	
	'Select BC
	Call fGuiSelectBC(DealID,"Search")
	
	'Click on 'Update' button for the selected BC on search page 
	Call fGuiLoadBCInMode("Search","Update",DealID)	
	
	'Select BC
	Call fGuiSelectBC(DealID,"Search")
	
	'Click on 'View' button for the selected BC on search page 
	Call fGuiLoadBCInMode("Search","View",DealID)
	
fBusSanity = True
	
End Function

Public Function fBusSysCalc()

	'------------------------------------------
	' Function name: fBusSysCalc
	' Description: The function compare all system calculation fields UI VS XL
	' Parameters:
	' Return value:
	' Example:
	'------------------------------------------
	
	Dim bSelectionFailed,sBCDescription,iDealID
	Dim arrOrigXLValues(), arrOrigXLColumns, arrOrigUIColumns
	Dim arrOrigFieldsType
	Dim arrTermXLValues(), arrTermXLColumns, arrTermUIColumns
	Dim arrTermFieldsType
	Dim arrOrigUIValues()
	Dim arrTermUIValues()
	
	'Login to BC application and navigate to Search page
	Call fGuiLogin()
	
	'Create basic deal (set values on deal summary screen)
	Call fGuiCreateBasicDeal(bSelectionFailed,sBCDescription,"SystemCalculation")
	
	'Create Buckets
	Call fGuiCreateBucket("Orig")

	Call fGuiCreateBucket("Term")


	'---ORIGINATION & TERMINATION MAIN GRID
	
	'Get and set exchange rate in the excel
	Call fGuiGetAndSetExchangeRate()

	'Origination - Get ACPM & ShotfallMin from DB and set them in the excel
	Call fGuiGetDBFieldsValues("Orig",arrRequiredValues) 	
	
	'Termination - Get ARPM & ACPM from DB and set them in the excel
	Call fGuiGetDBFieldsValues("Term",arrRequiredValues) 
	
	'Origination - Get excel data
	Call fGuiGetXLData("Orig",arrOrigXLValues,arrOrigXLColumns)' val ref ref
	
	'Termination - Get excel data
	Call fGuiGetXLData("Term",arrTermXLValues,arrTermXLColumns)'val ref ref
	
	'Origination - Set editable fields in the UI
	Call fGuiSetEdiableValuesInUI("Orig",arrOrigXLValues,arrOrigUIColumns,arrOrigFieldsType)'val val ref ref
	
	'Termination - Set editable fields in the UI
	Call fGuiSetEdiableValuesInUI("Term",arrTermXLValues,arrTermUIColumns,arrTermFieldsType)'val val ref ref
		
	'Origination - Get UI data
	Call fGuiGetUIData("Orig",arrOrigUIValues,arrOrigUIColumns,arrOrigFieldsType) 'val ref val val
	
	'Termination - Get UI data
	Call fGuiGetUIData("Term",arrTermUIValues,arrTermUIColumns,arrTermFieldsType) 'val ref val val
	
	'Origination - Compare UI VS XL
	Call fGuiCompareUIWithXL("Origination",arrOrigXLValues,arrOrigUIValues,arrOrigXLColumns) 'val val val val

	'Termination - Compare UI VS XL
	Call fGuiCompareUIWithXL("Termination",arrTermXLValues,arrTermUIValues,arrTermXLColumns) 'val val val val

	'Save the deal as 'Draft' and verify correct saving
	Call fGuiSaveBC("Draft",bSelectionFailed)
	
	'Get the ID of the new created deal from the DB
	iDealID = fGuiGetNewCreatedBC(sBCDescription)

	'Compare Origination UI VS DB
	'Call fGuiCompareOrigUIwithDB(iDealID) 'iDealID

	'Compare Termination UI VS DB
	'Call fGuiCompareTermUIwithDB(iDealID) 'iDealID


	'---TOP
	
	'Originatiion top fields
	'TODO

	'Termination top fields
	'TODO
		

'	'---DEAL SUMMARY---
'	
'	'---STRATEGIC DETAILS
'	'Get excel data
'	Call fGuiGetXLData("StrategicDetails",arrXLValues,arrXLColumns)
'	'Get UI data
'	Call fGuiGetUIData("StrategicDetails",arrUIValues,arrUIColumns)
'	'Compare UI VS XL
'	Call fGuiCompareUIWithXL("StrategicDetails",arrXLValues,arrUIValues)
'	
'	'---DEAL DETAILS
'	'Set deal dates in the excel
'	Call fGuiSetDealDatesInXL()
'	'Get excel data
'	Call fGuiGetXLData("DealDetails",arrXLValues,arrXLColumns)
'	'Get UI data
'	Call fGuiGetUIData("DealDetails",arrUIValues,arrUIColumns)
'	'Compare UI VS XL
'	Call fGuiCompareUIWithXL("DealDetails",arrXLValues,arrUIValues)
	
	


End Function
