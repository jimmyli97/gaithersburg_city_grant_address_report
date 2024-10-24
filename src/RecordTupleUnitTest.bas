Attribute VB_Name = "RecordTupleUnitTest"
'@TestModule
'@Folder "City_Grant_Address_Report.test"

Option Explicit
Option Private Module

Private Assert As Object

'@ModuleInitialize
Private Sub ModuleInitialize()
    'this method runs once per module.
    Set Assert = CreateObject("Rubberduck.AssertClass")
End Sub

'@ModuleCleanup
Private Sub ModuleCleanup()
    'this method runs once per module.
    Set Assert = Nothing
End Sub

'@TestMethod
Public Sub TestMergeRecord()
    Dim record As RecordTuple
    Set record = New RecordTuple
    Dim recordToMerge As RecordTuple
    Set recordToMerge = New RecordTuple
    
    record.AddVisit "09/10/2023", "food"
    record.AddVisit "08/17/2023", "food"
    recordToMerge.AddVisit "10/20/2024", "food"
    
    Assert.IsFalse record.MergeRecord(recordToMerge)
    
    Assert.isTrue record.visitData.Exists("food")
    Assert.isTrue record.visitData.Item("food").Exists("Q1")
    Assert.isTrue record.visitData.Item("food").Exists("Q2")
    Assert.isTrue record.visitData.Item("food").Item("Q1")(1) = CDate("09/10/2023")
    Assert.isTrue record.visitData.Item("food").Item("Q1")(2) = CDate("08/17/2023")
    Assert.isTrue record.visitData.Item("food").Item("Q2")(1) = CDate("10/20/2024")
End Sub

'@TestMethod
Public Sub TestVisitJson()
    Dim record As RecordTuple
    Set record = New RecordTuple
    
    Dim visitData As Scripting.Dictionary
    Set visitData = New Scripting.Dictionary
    
    visitData.Add "food", JsonConverter.ParseJson( _
        "{""Q1"":[""8/31/2023"",""9/15/2023""],""Q3"":[""2/15/2023""],""Q4"":[""5/31/2023""]}")
    
    Set record.visitData = visitData
    
    Assert.isTrue record.visitData.Exists("food")
    Assert.isTrue record.visitData.Item("food").Exists("Q1")
    Assert.isTrue record.visitData.Item("food").Exists("Q3")
    Assert.isTrue record.visitData.Item("food").Exists("Q4")
    Assert.isTrue record.visitData.Item("food").Item("Q1").Item(1) = "8/31/2023"
    Assert.isTrue record.visitData.Item("food").Item("Q1").Item(2) = "9/15/2023"
End Sub

'@TestMethod
Public Sub TestFormatAddress()
    Dim record As RecordTuple
    Set record = New RecordTuple
    
    record.RawAddress = "501A S Frederick Ave E"
    record.RawUnitWithNum = "Suite 1"
    
    Assert.isTrue record.isCorrectableAddress()
    
    Dim gburgFormat As Scripting.Dictionary
    Set gburgFormat = record.GburgFormatRawAddress
    
    Assert.isTrue gburgFormat.Item(addressKey.Full) = "501a S Frederick Ave E Ste 1", "Full address incorrect"
    Assert.isTrue gburgFormat.Item(addressKey.Postfix) = "E", "Postfix incorrect"
    Assert.isTrue gburgFormat.Item(addressKey.PrefixedStreetname) = "S Frederick", "Street name incorrect"
    Assert.isTrue gburgFormat.Item(addressKey.streetNum) = "501a", "Street no. incorrect"
    Assert.isTrue gburgFormat.Item(addressKey.StreetType) = "Ave", "Street type incorrect"
    Assert.isTrue gburgFormat.Item(addressKey.unitNum) = "1", "Unit no. incorrect"
    Assert.isTrue gburgFormat.Item(addressKey.unitType) = "Ste", "Unit type incorrect"
    
    Dim recordNoPostfix As RecordTuple
    Set recordNoPostfix = New RecordTuple
    
    recordNoPostfix.RawAddress = "2 Nina Ave"
    Set gburgFormat = recordNoPostfix.GburgFormatRawAddress
    
    Assert.isTrue gburgFormat.Item(addressKey.Postfix) = vbNullString, "Postfix incorrect"
    Assert.isTrue gburgFormat.Item(addressKey.PrefixedStreetname) = "Nina", "Street name incorrect"
    Assert.isTrue gburgFormat.Item(addressKey.unitNum) = vbNullString, "Unit no. incorrect"
    Assert.isTrue gburgFormat.Item(addressKey.unitType) = vbNullString, "Unit type incorrect"
    
    Dim numericRecord As RecordTuple
    Set numericRecord = New RecordTuple
    
    numericRecord.RawAddress = "3458"
    Assert.IsFalse numericRecord.isCorrectableAddress(), "Numeric record marked as correctable"
    
    Dim alphabeticRecord As RecordTuple
    Set alphabeticRecord = New RecordTuple
    
    alphabeticRecord.RawAddress = "Asdfcvn Dfdwer"
    Assert.IsFalse alphabeticRecord.isCorrectableAddress(), "Alphabetic record marked as correctable"
End Sub

'@TestMethod
Public Sub TestIsAutocorrected()
    Dim record As RecordTuple
    Set record = New RecordTuple
    record.RawZip = "20878"
    record.RawAddress = "123 Test"
    record.RawUnitWithNum = "Apt 23"
    Assert.IsFalse record.isAutocorrected
    
    record.ValidZipcode = "20878"
    record.validAddress = "123 Test"
    record.validUnitWithNum = "Apt 23"
    Assert.IsFalse record.isAutocorrected
    
    record.validUnitWithNum = "Ste 23"
    Assert.isTrue record.isAutocorrected

    record.validUnitWithNum = "Apt 23"
    record.ValidZipcode = "20877"
    Assert.isTrue record.isAutocorrected

    record.ValidZipcode = "20878"
    record.validAddress = "124 test"
    Assert.isTrue record.isAutocorrected
End Sub
