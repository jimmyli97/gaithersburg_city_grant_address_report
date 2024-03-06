Attribute VB_Name = "RecordsIntegrationTest"
'@TestModule
'@Folder "City_Grant_Address_Report.test"


Option Explicit
Option Private Module

Private Assert As Object
Private Fakes As Object

'@ModuleInitialize
Private Sub ModuleInitialize()
    'this method runs once per module.
    Set Assert = CreateObject("Rubberduck.AssertClass")
    Set Fakes = CreateObject("Rubberduck.FakesProvider")
End Sub

'@ModuleCleanup
Private Sub ModuleCleanup()
    'this method runs once per module.
    Set Assert = Nothing
    Set Fakes = Nothing
End Sub

'@TestInitialize
Private Sub TestInitialize()
    ClearAll
    autocorrect.printRemainingRequests 8000
End Sub

'@TestCleanup
Private Sub TestCleanup()
    ClearAll
    autocorrect.printRemainingRequests 8000
End Sub

Private Sub PasteTestRecords(ByRef addressArr() As String)
    InterfaceSheet.Select
    getPastedRecordsRng.Cells.Item(1, 1).Select
    
    Dim i As Long
    Dim fileArrLine() As String
    For i = 1 To UBound(addressArr, 1)
        If addressArr(i) <> vbNullString Then
            fileArrLine = Split(addressArr(i), ",")
            Dim j As Long
            For j = 0 To 14 ' TODO when adding adult/child. Not UBound because of test notes
                ActiveCell.value = fileArrLine(j)
                ActiveCell.offset(0, 1).Select
            Next j
            ActiveSheet.Cells(ActiveCell.row + 1, 1).Select
        End If
    Next i
End Sub

'@TestMethod
Public Sub TestAllAddresses()
    On Error GoTo TestFail
    
    Dim testAddressesArr() As String
    testAddressesArr = getCSV(ThisWorkbook.path & "\testdata\test1addresses.csv")
    
    PasteTestRecords testAddressesArr
    
    addRecords
    
    CompareSheetCSV Assert, "Addresses", ThisWorkbook.path & "\testdata\test1addresses_addressesoutput.csv"
    CompareSheetCSV Assert, "Interface", ThisWorkbook.path & "\testdata\test1addresses_totalsoutput.csv", getTotalsRng
    CompareSheetCSV Assert, "Interface", ThisWorkbook.path & "\testdata\test1addresses_countytotalsoutput.csv", getCountyRng
    CompareSheetCSV Assert, "Needs Autocorrect", ThisWorkbook.path & "\testdata\test1addresses_autocorrectoutput.csv"
    CompareSheetCSV Assert, "Discards", ThisWorkbook.path & "\testdata\test1addresses_discardsoutput.csv"
    CompareSheetCSV Assert, "Autocorrected", ThisWorkbook.path & "\testdata\test1addresses_autocorrectedoutput.csv"
    
    Dim testExtraAddressesArr() As String
    testExtraAddressesArr = getCSV(ThisWorkbook.path & "\testdata\test2extraaddresses.csv")

    PasteTestRecords testExtraAddressesArr

    addRecords

    CompareSheetCSV Assert, "Addresses", ThisWorkbook.path & "\testdata\test2extraaddresses_addressesoutput.csv"
    CompareSheetCSV Assert, "Interface", ThisWorkbook.path & "\testdata\test2extraaddresses_totalsoutput.csv", getTotalsRng
    CompareSheetCSV Assert, "Needs Autocorrect", ThisWorkbook.path & "\testdata\test2extraaddresses_autocorrectoutput.csv"
    CompareSheetCSV Assert, "Discards", ThisWorkbook.path & "\testdata\test2extraaddresses_discardsoutput.csv"
    CompareSheetCSV Assert, "Autocorrected", ThisWorkbook.path & "\testdata\test2extraaddresses_autocorrectedoutput.csv"

    Dim testAutocorrectAddressesArr() As String
    testAutocorrectAddressesArr = getCSV(ThisWorkbook.path & "\testdata\test3autocorrectaddresses.csv")

    PasteTestRecords testAutocorrectAddressesArr

    addRecords

    attemptValidation

    CompareSheetCSV Assert, "Addresses", ThisWorkbook.path & "\testdata\test3autocorrectaddresses_addressesoutput.csv"
    CompareSheetCSV Assert, "Interface", ThisWorkbook.path & "\testdata\test3autocorrectaddresses_totalsoutput.csv", getTotalsRng
    CompareSheetCSV Assert, "Needs Autocorrect", ThisWorkbook.path & "\testdata\test3autocorrectaddresses_autocorrectoutput.csv"
    CompareSheetCSV Assert, "Discards", ThisWorkbook.path & "\testdata\test3autocorrectaddresses_discardsoutput.csv"
    CompareSheetCSV Assert, "Autocorrected", ThisWorkbook.path & "\testdata\test3autocorrectaddresses_autocorrectedoutput.csv"

    Assert.IsTrue autocorrect.getRemainingRequests = 7980


    Dim testMergeAutocorrectedAddressesArr() As String
    testMergeAutocorrectedAddressesArr = getCSV(ThisWorkbook.path & "\testdata\test4mergeaddresses.csv")
    PasteTestRecords testMergeAutocorrectedAddressesArr

    addRecords

    CompareSheetCSV Assert, "Addresses", ThisWorkbook.path & "\testdata\test4mergeaddresses_addressesoutput.csv"
    CompareSheetCSV Assert, "Interface", ThisWorkbook.path & "\testdata\test4mergeaddresses_totalsoutput.csv", getTotalsRng
    CompareSheetCSV Assert, "Discards", ThisWorkbook.path & "\testdata\test4mergeaddresses_discardsoutput.csv"
    CompareSheetCSV Assert, "Autocorrected", ThisWorkbook.path & "\testdata\test4mergeaddresses_autocorrectedoutput.csv"

    Fakes.MsgBox.Returns vbYes

    InterfaceButtons.confirmDiscardAll

    DiscardsSheet.Select
    Union(DiscardsSheet.Range("A3:A7"), _
          DiscardsSheet.Range("A10:A11"), _
          DiscardsSheet.Range("A13:A14")).Select
    InterfaceButtons.confirmRestoreSelectedDiscard

    AutocorrectAddressesSheet.Select
    Union(AutocorrectAddressesSheet.Range("A6"), _
          AutocorrectAddressesSheet.Range("A8")).Select
    InterfaceButtons.confirmDiscardSelected

    AddressesSheet.Select
    Union(AddressesSheet.Range("A3"), _
          AddressesSheet.Range("A8"), _
          AddressesSheet.Range("A12")).Select
    InterfaceButtons.confirmMoveAutocorrect

    AutocorrectAddressesSheet.Select

    AutocorrectAddressesSheet.Range("C2").value = "13-15 E Deer Park Dr"
    AutocorrectAddressesSheet.Range("D2").value = "Ste 102"
    AutocorrectAddressesSheet.Range("C3").value = "13-15 E Deer Park Dr"
    AutocorrectAddressesSheet.Range("D3").value = "Ste 202"
    AutocorrectAddressesSheet.Range("D4").value = "Unit 102"
    AutocorrectAddressesSheet.Range("D5").value = "Unit 102"
    AutocorrectAddressesSheet.Range("B6").value = True
    AutocorrectAddressesSheet.Range("D9").value = "Apt 103"
    AutocorrectAddressesSheet.Range("D10").value = "Ste 100"
    AutocorrectAddressesSheet.Range("D11").value = "Apt 1"

    Union(AutocorrectAddressesSheet.Range("A2:A5"), _
          AutocorrectAddressesSheet.Range("A8:A11")).Select
    InterfaceButtons.toggleUserVerified
    
    DiscardsSheet.Select
    Union(DiscardsSheet.Range("A2"), _
          DiscardsSheet.Range("A4")).Select
    InterfaceButtons.toggleUserVerifiedAutocorrected

    CompareSheetCSV Assert, "Addresses", ThisWorkbook.path & "\testdata\test5usereditsaddresses_addressesoutput.csv"
    CompareSheetCSV Assert, "Interface", ThisWorkbook.path & "\testdata\test5usereditsaddresses_totalsoutput.csv", getTotalsRng
    CompareSheetCSV Assert, "Needs Autocorrect", ThisWorkbook.path & "\testdata\test5usereditsaddresses_autocorrectoutput.csv"
    CompareSheetCSV Assert, "Discards", ThisWorkbook.path & "\testdata\test5usereditsaddresses_discardsoutput.csv"
    CompareSheetCSV Assert, "Autocorrected", ThisWorkbook.path & "\testdata\test5usereditsaddresses_autocorrectedoutput.csv"

    InterfaceButtons.confirmAttemptValidation
    InterfaceButtons.confirmGenerateFinalReport

    CompareSheetCSV Assert, "Addresses", ThisWorkbook.path & "\testdata\test6validateduseredits_addressesoutput.csv"
    CompareSheetCSV Assert, "Interface", ThisWorkbook.path & "\testdata\test6validateduseredits_totalsoutput.csv", getTotalsRng
    CompareSheetCSV Assert, "Autocorrected", ThisWorkbook.path & "\testdata\test6validateduseredits_autocorrectedoutput.csv"
    CompareSheetCSV Assert, "Final Report", ThisWorkbook.path & "\testdata\test6validateduseredits_finalreportoutput.csv"


'    ' TODO test delete service column, generate final report
'    InterfaceButtons.confirmDeleteService
'    InterfaceButtons.confirmGenerateFinalReport
'
'    ' TODO move one record to needs autocorrect, test delete all visit data
'    InterfaceButtons.confirmDeleteAllVisitData
    Exit Sub
TestFail:
    Assert.Fail "Test raised an error: #" & Err.Number & " - " & Err.Description
End Sub

'@TestMethod
Public Sub TestToggleUserVerifiedAutocorrect()
    On Error GoTo TestFail
    
    Dim testAddressesArr() As String
    testAddressesArr = getCSV(ThisWorkbook.path & "\testdata\testtoggleuserverified.csv")
    
    PasteTestRecords testAddressesArr
    
    addRecords
    attemptValidation
    
    AutocorrectedAddressesSheet.Select
    AutocorrectedAddressesSheet.Range("A2:A3").Select
    InterfaceButtons.toggleUserVerifiedAutocorrected
    
    AutocorrectedAddressesSheet.Range("A2").Select
    InterfaceButtons.toggleUserVerifiedAutocorrected
    
    CompareSheetCSV Assert, "Addresses", ThisWorkbook.path & "\testdata\testtoggleuserverified_addressesoutput.csv"
    CompareSheetCSV Assert, "Discards", ThisWorkbook.path & "\testdata\testtoggleuserverified_discardsoutput.csv"
    CompareSheetCSV Assert, "Autocorrected", ThisWorkbook.path & "\testdata\testtoggleuserverified_autocorrectedoutput.csv"
    
    
    Exit Sub
TestFail:
    Assert.Fail "Test raised an error: #" & Err.Number & " - " & Err.Description
End Sub

'@TestMethod
Public Sub TestCountyTotals()
    On Error GoTo TestFail
    
    Dim testAddressesArr() As String
    testAddressesArr = getCSV(ThisWorkbook.path & "\testdata\testcounty.csv")

    PasteTestRecords testAddressesArr

    addRecords
    attemptValidation
    
    CompareSheetCSV Assert, "Interface", ThisWorkbook.path & "\testdata\testcounty_totalsoutput.csv", getCountyRng
    
    Exit Sub
TestFail:
    Assert.Fail "Test raised an error: #" & Err.Number & " - " & Err.Description
End Sub


'@TestMethod
Public Sub TestHandcorrected()
    On Error GoTo TestFail
    
    Dim testAddressesArr() As String
'    testAddressesArr = getCSV(ThisWorkbook.path & "\testdata\testhandcorrected.csv")
    testAddressesArr = getCSV(ThisWorkbook.path & "\testdata\testdifficultaddresses.csv")
    PasteTestRecords testAddressesArr
    
    addRecords
    attemptValidation
    
'    CompareSheetCSV Assert, "Addresses", ThisWorkbook.path & "\testdata\testhandcorrected_addressesoutput.csv"
'    CompareSheetCSV Assert, "Needs Autocorrect", ThisWorkbook.path & "\testdata\testhandcorrected_autocorrectoutput.csv"
'    CompareSheetCSV Assert, "Discards", ThisWorkbook.path & "\testdata\testhandcorrected_discardsoutput.csv"
'    CompareSheetCSV Assert, "Autocorrected", ThisWorkbook.path & "\testdata\testhandcorrected_autocorrectedoutput.csv"
    CompareSheetCSV Assert, "Addresses", ThisWorkbook.path & "\testdata\testdifficultaddresses_addressesoutput.csv"
    CompareSheetCSV Assert, "Needs Autocorrect", ThisWorkbook.path & "\testdata\testdifficultaddresses_autocorrectoutput.csv"
    CompareSheetCSV Assert, "Discards", ThisWorkbook.path & "\testdata\testdifficultaddresses_discardsoutput.csv"
    CompareSheetCSV Assert, "Autocorrected", ThisWorkbook.path & "\testdata\testdifficultaddresses_autocorrectedoutput.csv"
    
    
    Exit Sub
TestFail:
    Assert.Fail "Test raised an error: #" & Err.Number & " - " & Err.Description
End Sub