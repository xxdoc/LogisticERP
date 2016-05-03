Attribute VB_Name = "JSON"

' VBJSON is a VB6 adaptation of the VBA JSON project at http://code.google.com/p/vba-json/
' Some bugs fixed, speed improvements added for VB6 by Michael Glaser (vbjson@ediy.co.nz)
' BSD Licensed

Option Explicit

Const INVALID_JSON      As Long = 1
Const INVALID_OBJECT    As Long = 2
Const INVALID_ARRAY     As Long = 3
Const INVALID_BOOLEAN   As Long = 4
Const INVALID_NULL      As Long = 5
Const INVALID_KEY       As Long = 6
Const INVALID_RPC_CALL  As Long = 7

Private psErrors As String

Public Function SafeJsonField(ByVal FieldString As String) As String

    FieldString = Replace(FieldString, """", "&quot;")
    FieldString = Replace(FieldString, "\", "\\")
    FieldString = Replace(FieldString, vbCrLf, "<br>")
    FieldString = Replace(FieldString, ",", "&#44;")
    SafeJsonField = FieldString
End Function

Public Function RestoreJsonField(ByVal FieldString As String) As String

    FieldString = Replace(FieldString, "&quot;", """")
    FieldString = Replace(FieldString, "\\", "\")
    FieldString = Replace(FieldString, "<br>", vbCrLf)
    FieldString = Replace(FieldString, "&#44;", ",")
    RestoreJsonField = FieldString
End Function

Public Function GetParserErrors() As String
    GetParserErrors = psErrors
End Function

Public Function ClearParserErrors() As String
    psErrors = ""
End Function

'
'   parse string and create JSON object
'
Public Function Parse(ByRef str As String) As Scripting.Dictionary

    Dim Index As Long
    Index = 1
    psErrors = ""
    On Error Resume Next
    Call skipChar(str, Index)
iTry:

    Select Case mID(str, Index, 1)

        Case "{"
            Set Parse = parseObject(str, Index)

        Case "["
            Set Parse = parseArray(str, Index)

        Case Else

            If Index < 20 Then
                Index = Index + 1
                Call skipChar(str, Index)
                GoTo iTry
            Else
                psErrors = "Invalid JSON"
            End If

    End Select

End Function

'
'   parse collection of key/value
'
Private Function parseObject(ByRef str As String, ByRef Index As Long) As Dictionary

    Set parseObject = New Dictionary
    Dim sKey As String
   
    ' "{"
    Call skipChar(str, Index)

    If mID(str, Index, 1) <> "{" Then

        psErrors = psErrors & "Invalid Object at position " & Index & " : " & mID(str, Index) & vbCrLf
        Exit Function

    End If
   
    Index = Index + 1

    Do

        Call skipChar(str, Index)

        If "}" = mID(str, Index, 1) Then

            Index = Index + 1
            Exit Do

        ElseIf "," = mID(str, Index, 1) Then

            Index = Index + 1
            Call skipChar(str, Index)

        End If
      
        ' add key/value pair
        'Debug.Print "**" & sKey & "**"
        sKey = parseKey(str, Index)
        On Error Resume Next
        '        Debug.Print sKey
        '    If sKey = "RatePlanList" Or sKey = "DayPriceList" Then
        '
        '        Debug.Print sKey
        '        Debug.Print index
        '    End If
        'If sKey = "wi17u000000|206103652" Then
        '        '
        '                Debug.Print sKey
        '        '        Debug.Print index
        '            End If
        parseObject.Add sKey, parseValue(str, Index)

        If Err.Number <> 0 Then

            psErrors = psErrors & Err.Description & ": " & sKey & vbCrLf
            Exit Do

        End If

    Loop

eh:

End Function

'
'   parse list
'
Private Function parseArray(ByRef str As String, ByRef Index As Long) As Collection

    Set parseArray = New Collection

    ' "["
    Call skipChar(str, Index)

    If mID(str, Index, 1) <> "[" Then

        psErrors = psErrors & "Invalid Array at position " & Index & " : " + mID(str, Index, 20) & vbCrLf
        Exit Function

    End If
   
    Index = Index + 1

    Do

        Call skipChar(str, Index)

        If "]" = mID(str, Index, 1) Then

            Index = Index + 1
            Exit Do

        ElseIf "," = mID(str, Index, 1) Then

            Index = Index + 1
            Call skipChar(str, Index)

        End If

        ' add value
        On Error Resume Next
        parseArray.Add parseValue(str, Index)

        If Err.Number <> 0 Then

            psErrors = psErrors & Err.Description & ": " & mID(str, Index, 20) & vbCrLf
            Exit Do

        End If

    Loop

End Function

'
'   parse string / number / object / array / true / false / null
'
Private Function parseValue(ByRef str As String, ByRef Index As Long)

    Call skipChar(str, Index)

    Select Case mID(str, Index, 1)

        Case "{"
            'Debug.Print Mid(str, index, 50)
            Set parseValue = parseObject(str, Index)

        Case "["
            Set parseValue = parseArray(str, Index)

        Case """", "'"
            parseValue = parseString(str, Index)

        Case "t", "f"
            parseValue = parseBoolean(str, Index)

        Case "n"
            parseValue = parseNull(str, Index)

        Case Else
            parseValue = parseNumber(str, Index)
    End Select

End Function

'
'   parse string
'
Private Function parseString(ByRef str As String, ByRef Index As Long) As String

    Dim quote   As String
    Dim Char    As String
    Dim Code    As String

    Dim SB As New clsStringBuilder

    Call skipChar(str, Index)
    quote = mID(str, Index, 1)
    Index = Index + 1
   
    Do While Index > 0 And Index <= Len(str)

        Char = mID(str, Index, 1)

        Select Case (Char)

            Case "\"
                Index = Index + 1
                Char = mID(str, Index, 1)

                Select Case (Char)

                    Case """", "\", "/", "'"
                        SB.Append Char
                        Index = Index + 1

                    Case "b"
                        SB.Append vbBack
                        Index = Index + 1

                    Case "f"
                        SB.Append vbFormFeed
                        Index = Index + 1

                    Case "n"
                        SB.Append vbLf
                        Index = Index + 1

                    Case "r"
                        SB.Append vbCr
                        Index = Index + 1

                    Case "t"
                        SB.Append vbTab
                        Index = Index + 1

                    Case "u"
                        Index = Index + 1
                        Code = mID(str, Index, 4)
                        SB.Append ChrW(Val("&h" + Code))
                        Index = Index + 4
                End Select

            Case quote
                Index = Index + 1
            
                parseString = SB.toString
                Set SB = Nothing
            
                Exit Function
            
            Case Else
                SB.Append Char
                Index = Index + 1
        End Select

    Loop
   
    parseString = SB.toString
    Set SB = Nothing
   
End Function

'
'   parse number
'
Private Function parseNumber(ByRef str As String, ByRef Index As Long)
        '<EhHeader>
        On Error GoTo parseNumber_Err
        '</EhHeader>

        Dim Value   As String
        Dim Char    As String

100     Call skipChar(str, Index)

102     Do While Index > 0 And Index <= Len(str)

104         Char = mID(str, Index, 1)

106         If InStr("+-0123456789.eE", Char) Then

108             Value = Value & Char
110             Index = Index + 1

            Else

                '            If InStr(Value, ".") Or InStr(Value, "e") Or InStr(Value, "E") Then
                '
                '                parseNumber = CDbl(Value)
                '
                '            Else

112             parseNumber = CDbl(Value)

                '            End If

                Exit Function

            End If

        Loop

        '<EhFooter>
        Exit Function

parseNumber_Err:
        WriteLog Err.Description & vbCrLf & _
           "in HotelList_Bot.JSON.parseNumber " & _
           "at line " & Erl
        Resume Next
        '</EhFooter>
End Function

'
'   parse true / false
'
Private Function parseBoolean(ByRef str As String, ByRef Index As Long) As Boolean

    Call skipChar(str, Index)

    If mID(str, Index, 4) = "true" Then

        parseBoolean = True
        Index = Index + 4

    ElseIf mID(str, Index, 5) = "false" Then

        parseBoolean = False
        Index = Index + 5

    Else

        psErrors = psErrors & "Invalid Boolean at position " & Index & " : " & mID(str, Index) & vbCrLf

    End If

End Function

'
'   parse null
'
Private Function parseNull(ByRef str As String, ByRef Index As Long)

    Call skipChar(str, Index)

    If mID(str, Index, 4) = "null" Then

        parseNull = Null
        Index = Index + 4

    Else

        psErrors = psErrors & "Invalid null value at position " & Index & " : " & mID(str, Index) & vbCrLf

    End If

End Function

Private Function parseKey(ByRef str As String, ByRef Index As Long) As String

    Dim dquote  As Boolean
    Dim squote  As Boolean
    Dim Char    As String

    Call skipChar(str, Index)

    Do While Index > 0 And Index <= Len(str)

        Char = mID(str, Index, 1)

        Select Case (Char)

            Case """"
                dquote = Not dquote
                Index = Index + 1

                If Not dquote Then

                    Call skipChar(str, Index)

                    If mID(str, Index, 1) <> ":" Then

                        psErrors = psErrors & "Invalid Key at position " & Index & " : " & parseKey & vbCrLf
                        Exit Do

                    End If

                End If

            Case "'"
                squote = Not squote
                Index = Index + 1

                If Not squote Then

                    Call skipChar(str, Index)

                    If mID(str, Index, 1) <> ":" Then

                        psErrors = psErrors & "Invalid Key at position " & Index & " : " & parseKey & vbCrLf
                        Exit Do

                    End If

                End If

            Case ":"
                Index = Index + 1

                If Not dquote And Not squote Then

                    Exit Do

                Else

                    parseKey = parseKey & Char

                End If

            Case Else

                If InStr(vbCrLf & vbCr & vbLf & vbTab & " ", Char) Then

                Else

                    parseKey = parseKey & Char

                End If

                Index = Index + 1
        End Select

    Loop

End Function

'
'   skip special character
'
Private Sub skipChar(ByRef str As String, ByRef Index As Long)
    Dim bComment As Boolean
    Dim bStartComment As Boolean
    Dim bLongComment As Boolean

    Do While Index > 0 And Index <= Len(str)

        Select Case mID(str, Index, 1)

            Case vbCr, vbLf

                If Not bLongComment Then

                    bStartComment = False
                    bComment = False

                End If
         
            Case vbTab, " ", "(", ")"
         
            Case "/"

                If Not bLongComment Then

                    If bStartComment Then

                        bStartComment = False
                        bComment = True

                    Else

                        bStartComment = True
                        bComment = False
                        bLongComment = False

                    End If

                Else

                    If bStartComment Then

                        bLongComment = False
                        bStartComment = False
                        bComment = False

                    End If

                End If
         
            Case "*"

                If bStartComment Then

                    bStartComment = False
                    bComment = True
                    bLongComment = True

                Else

                    bStartComment = True

                End If
         
            Case Else

                If Not bComment Then

                    Exit Do

                End If

        End Select
      
        Index = Index + 1

    Loop

End Sub

Public Function toString(ByRef obj As Variant) As String
    Dim SB As New clsStringBuilder

    Select Case VarType(obj)

        Case vbNull
            SB.Append "null"

        Case vbDate
            SB.Append """" & CStr(obj) & """"

        Case vbString
            SB.Append """" & EnCode(obj) & """"

        Case vbObject
         
            Dim bFI As Boolean
            Dim i As Long
         
            bFI = True

            If TypeName(obj) = "Dictionary" Then

                SB.Append "{"
                Dim keys
                keys = obj.keys

                For i = 0 To obj.Count - 1

                    If bFI Then bFI = False Else SB.Append ","

                    Dim key
                    key = keys(i)
                    SB.Append """" & key & """:" & toString(obj.Item(key))

                Next i

                SB.Append "}"

            ElseIf TypeName(obj) = "Collection" Then

                SB.Append "["
                Dim Value

                For Each Value In obj

                    If bFI Then bFI = False Else SB.Append ","

                    SB.Append toString(Value)

                Next Value

                SB.Append "]"

            End If

        Case vbBoolean

            If obj Then SB.Append "true" Else SB.Append "false"

        Case vbVariant, vbArray, vbArray + vbVariant
            Dim sEB
            SB.Append multiArray(obj, 1, "", sEB)

        Case Else
            SB.Append Replace(obj, ",", ".")
    End Select

    toString = SB.toString
    Set SB = Nothing
   
End Function

Private Function EnCode(str) As String

    Dim SB As New clsStringBuilder
    Dim i As Long
    Dim j As Long
    Dim aL1 As Variant
    Dim aL2 As Variant
    Dim c As String
    Dim p As Boolean

    aL1 = Array(&H22, &H5C, &H2F, &H8, &HC, &HA, &HD, &H9)
    aL2 = Array(&H22, &H5C, &H2F, &H62, &H66, &H6E, &H72, &H74)

    For i = 1 To Len(str)

        p = True
        c = mID(str, i, 1)

        For j = 0 To 7

            If c = Chr(aL1(j)) Then

                SB.Append "\" & Chr(aL2(j))
                p = False
                Exit For

            End If

        Next

        If p Then

            Dim a
            a = AscW(c)

            If a > 31 And a < 127 Then

                SB.Append c

            ElseIf a > -1 Or a < 65535 Then

                SB.Append "\u" & String(4 - Len(HEX(a)), "0") & HEX(a)

            End If

        End If

    Next
   
    EnCode = SB.toString
    Set SB = Nothing
   
End Function

Private Function multiArray(aBD, iBC, sPS, ByRef sPT)   ' Array BoDy, Integer BaseCount, String PoSition
   
    Dim iDU As Long
    Dim iDL As Long
    Dim i As Long
   
    On Error Resume Next
    iDL = LBound(aBD, iBC)
    iDU = UBound(aBD, iBC)

    Dim SB As New clsStringBuilder

    Dim sPB1, sPB2  ' String PointBuffer1, String PointBuffer2

    If Err.Number = 9 Then

        sPB1 = sPT & sPS

        For i = 1 To Len(sPB1)

            If i <> 1 Then sPB2 = sPB2 & ","

            sPB2 = sPB2 & mID(sPB1, i, 1)

        Next

        '        multiArray = multiArray & toString(Eval("aBD(" & sPB2 & ")"))
        SB.Append toString(aBD(sPB2))

    Else

        sPT = sPT & sPS
        SB.Append "["

        For i = iDL To iDU

            SB.Append multiArray(aBD, iBC + 1, i, sPT)

            If i < iDU Then SB.Append ","

        Next

        SB.Append "]"
        sPT = Left(sPT, iBC - 2)

    End If

    Err.Clear
    multiArray = SB.toString
   
    Set SB = Nothing
End Function

' Miscellaneous JSON functions

Public Function StringToJSON(st As String) As String
   
    Const FIELD_SEP = "~"
    Const RECORD_SEP = "|"

    Dim sFlds As String
    Dim sRecs As New clsStringBuilder
    Dim lRecCnt As Long
    Dim lFld As Long
    Dim fld As Variant
    Dim rows As Variant

    lRecCnt = 0

    If st = "" Then

        StringToJSON = "null"

    Else

        rows = Split(st, RECORD_SEP)

        For lRecCnt = LBound(rows) To UBound(rows)

            sFlds = ""
            fld = Split(rows(lRecCnt), FIELD_SEP)

            For lFld = LBound(fld) To UBound(fld) Step 2

                sFlds = (sFlds & IIf(sFlds <> "", ",", "") & """" & fld(lFld) & """:""" & toUnicode(fld(lFld + 1) & "") & """")

            Next 'fld

            sRecs.Append IIf((Trim(sRecs.toString) <> ""), "," & vbCrLf, "") & "{" & sFlds & "}"

        Next 'rec

        StringToJSON = ("( {""Records"": [" & vbCrLf & sRecs.toString & vbCrLf & "], " & """RecordCount"":""" & lRecCnt & """ } )")

    End If

End Function
'
'Public Function RStoJSON(rs As ADODB.Recordset) As String
'    On Error GoTo errHandler
'    Dim sFlds As String
'    Dim sRecs As New clsStringBuilder
'    Dim lRecCnt As Long
'    Dim fld As ADODB.Field
'
'    lRecCnt = 0
'
'    If rs.State = adStateClosed Then
'
'        RStoJSON = "null"
'
'    Else
'
'        If rs.EOF Or rs.BOF Then
'
'            RStoJSON = "null"
'
'        Else
'
'            Do While Not rs.EOF And Not rs.BOF
'
'                lRecCnt = lRecCnt + 1
'                sFlds = ""
'
'                For Each fld In rs.Fields
'
'                    sFlds = (sFlds & IIf(sFlds <> "", ",", "") & """" & fld.Name & """:""" & toUnicode(fld.Value & "") & """")
'
'                Next 'fld
'
'                sRecs.Append IIf((Trim(sRecs.toString) <> ""), "," & vbCrLf, "") & "{" & sFlds & "}"
'                rs.MoveNext
'
'            Loop
'
'            RStoJSON = ("( {""Records"": [" & vbCrLf & sRecs.toString & vbCrLf & "], " & """RecordCount"":""" & lRecCnt & """ } )")
'
'        End If
'
'    End If
'
'    Exit Function
'errHandler:
'
'End Function

'Public Function JsonRpcCall(url As String, methName As String, args(), Optional user As String, Optional pwd As String) As Object
'    Dim r As Object
'    Dim cli As Object
'    Dim pText As String
'    Static reqId As Integer
'
'    reqId = reqId + 1
'
'    Set r = CreateObject("Scripting.Dictionary")
'    r("jsonrpc") = "2.0"
'    r("method") = methName
'    r("params") = args
'    r("id") = reqId
'
'    pText = toString(r)
'
'    Set cli = CreateObject("MSXML2.XMLHTTP.6.0")
'   ' Set cli = New MSXML2.XMLHTTP60
'    If Len(user) > 0 Then   ' If Not IsMissing(user) Then
'        cli.Open "POST", url, False, user, pwd
'    Else
'        cli.Open "POST", url, False
'    End If
'    cli.setRequestHeader "Content-Type", "application/json"
'    cli.Send pText
'
'    If cli.Status <> 200 Then
'        Err.Raise vbObjectError + INVALID_RPC_CALL + cli.Status, , cli.statusText
'    End If
'
'    Set r = parse(cli.responseText)
'    Set cli = Nothing
'
'    If r("id") <> reqId Then Err.Raise vbObjectError + INVALID_RPC_CALL, , "Bad Response id"
'
'    If r.Exists("error") Or Not r.Exists("result") Then
'        Err.Raise vbObjectError + INVALID_RPC_CALL, , "Json-Rpc Response error: " & r("error")("message")
'    End If
'
'    If Not r.Exists("result") Then Err.Raise vbObjectError + INVALID_RPC_CALL, , "Bad Response, missing result"
'
'    Set JsonRpcCall = r("result")
'End Function

Public Function toUnicode(str As String) As String

    Dim x As Long
    Dim uStr As New clsStringBuilder
    Dim uChrCode As Integer

    For x = 1 To Len(str)

        uChrCode = Asc(mID(str, x, 1))

        Select Case uChrCode

            Case 8:   ' backspace
                uStr.Append "\b"

            Case 9: ' tab
                uStr.Append "\t"

            Case 10:  ' line feed
                uStr.Append "\n"

            Case 12:  ' formfeed
                uStr.Append "\f"

            Case 13: ' carriage return
                uStr.Append "\r"

            Case 34: ' quote
                uStr.Append "\"""

            Case 39:  ' apostrophe
                uStr.Append "\'"

            Case 92: ' backslash
                uStr.Append "\\"

            Case 123, 125:  ' "{" and "}"
                uStr.Append ("\u" & Right("0000" & HEX(uChrCode), 4))

            Case Is < 32, Is > 127: ' non-ascii characters
                uStr.Append ("\u" & Right("0000" & HEX(uChrCode), 4))

            Case Else
                uStr.Append Chr$(uChrCode)
        End Select

    Next

    toUnicode = uStr.toString
    Exit Function

End Function

Private Sub Class_Initialize()
    psErrors = ""
End Sub
