'###########################################################
' Function name: fGlobalDictionaryTo2dArray
' Description: 
' Parameters: 
' Return value: 
' Example:
'###########################################################
Function fGlobalDictionaryTo2dArray()
	
	Dim	DictionaryItems, DictionaryKeys, iItemsCount
	Dim arrDictionary, newArrDictionary
	
	Call fGetReferenceData(GlobalDictionary)
	
	DictionaryItems = GlobalDictionary.Items
	DictionaryKeys = GlobalDictionary.Keys
	iItemsCount = GlobalDictionary.Count
	ReDim arrDictionary(iItemsCount,1)	
	
	For i = 0 To GlobalDictionary.Count - 1
		If  DictionaryKeys(i) <> "" and  DictionaryItems(i) <> "" and DictionaryKeys(i) <> "ACTION" Then			
			arrDictionary(i,0) = DictionaryKeys(i)
			arrDictionary(i,1) = DictionaryItems(i)
		End If		
	Next 
	
	iEmptyCounter = 0
	For i = 0 To uBound(arrDictionary) 
		If isEmpty(arrDictionary(i,0)) Then
			iEmptyCounter = iEmptyCounter + 1
		End If
	Next
	
	ReDim newArrDictionary(uBound(arrDictionary) -iEmptyCounter,1)
	index = 0
	For i = 0 To uBound(arrDictionary) 
		If Not isEmpty(arrDictionary(i,0)) Then
			newArrDictionary(index,0) = arrDictionary(i,0)
			newArrDictionary(index,1) = arrDictionary(i,1)
			index = index + 1 
		End If
	Next
	
	fGlobalDictionaryTo2dArray = newArrDictionary
	
End Function
'###########################################################

'###########################################################
' Function name: ConvertToLetter
' Description: The function convert an excel column number to letter
' Parameters: iCol - Excel column number
' Return value: Success - Column in letter
' Example:
'###########################################################
Function fConvertToLetter(iCol) 
   Dim iAlpha 
   Dim iRemainder 
   iAlpha = Int(iCol / 27)
   iRemainder = iCol - (iAlpha * 26)
   If iAlpha > 0 Then
      fConvertToLetter = Chr(iAlpha + 64)
   End If
   If iRemainder > 0 Then
      fConvertToLetter = fConvertToLetter & Chr(iRemainder + 64)
   End If
End Function
'###########################################################


'###########################################################
' Function name: TransposeArray
' Description: The function export results of  a query to excel
' Parameters: arr - array to transpose
' Return value: The transposed array
' Example:
'###########################################################
Function fTransposeArray(arr) 
' Custom Function to Transpose a 0-based array (arr)

    Dim X , Y , Xupper, Yupper
    Dim tempArray 

    Xupper = UBound(arr, 2)
    Yupper = UBound(arr, 1)

    ReDim tempArray(Xupper, Yupper)
    For X = 0 To Xupper
        For Y = 0 To Yupper
            tempArray(X, Y) = arr(Y, X)
        Next 
    Next 

    fTransposeArray = tempArray    
   
End Function
'###########################################################


'###########################################################
' Function name: mergeArr
' Description: The function merges 2 arrays
' Parameters:
' Return value: 
' Example:
'###########################################################
Function mergeArr(a1, a2)
  ReDim aTmp(Ubound(a1, 1), UBound(a1, 2) + Ubound(a2, 2) + 1)
  Dim i, j, k
  For i = 0 To UBound(a1, 2)
      For j = 0 To UBound(aTmp, 1)
          aTmp(j, i) = a1(j, i)
      Next
  Next
  For k = 0 To UBound(a2, 2)
      For j = 0 To UBound(aTmp, 1)
          aTmp(j, i + k) = a2(j, k)
      Next
  Next
  mergeArr = aTmp
End Function
'###########################################################
