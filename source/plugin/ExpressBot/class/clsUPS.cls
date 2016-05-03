VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsUPS"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Function GetInfo(ByVal strExpressNO As String) As String

    Dim iWeb As clsXMLHTTPGetHtml
    Set iWeb = New clsXMLHTTPGetHtml

    iWeb.CharSet = "UTF-8"
    iWeb.TimeOut = 20
    iWeb.URL = "http://wwwapps.ups.com/WebTracking/track?loc=zh_CN"

    iWeb.PostData = "loc=zh_CN&tbifl=1&hiddenText=&tracknum=" & strExpressNO & "&track.x=%E8%BF%BD%E8%B8%AA&trackSelectedOption=" ' & strExpressNO 'txtBill=728499564190

    Dim strHtml As String

    Call iWeb.Send

    strHtml = iWeb.ReturnData
    strHtml = convertCRLF(strHtml)
    Debug.Print strHtml
    
    Dim Reg As VBScript_RegExp_55.RegExp
    Set Reg = New VBScript_RegExp_55.RegExp
    
    Dim Mc As VBScript_RegExp_55.MatchCollection
    Dim m As VBScript_RegExp_55.Match
    
    
    
    Reg.Global = True
    Reg.IgnoreCase = True
    Reg.Pattern = "<form[^>]+id=""detailFormid""[^>]+>(.*?)</form>" '�Ȱѹؼ���FORMƥ�������Ȼ��Ҫƥ�������<input type=hidden�ֶ�
    
    Set Mc = Reg.Execute(strHtml)
    
    If Mc.Count = 1 Then
        

        
        Reg.Pattern = "<input[^>]+name=""([^""]+)""[^>]+value=""([^""]*?)""[^>]*?>"
        Set Mc = Reg.Execute(Mc.Item(0).SubMatches(0))
        
        If Mc.Count > 0 Then
        
            Dim strPost As String
            strPost = ""
            For Each m In Mc
            
                strPost = strPost & m.SubMatches(0) & "=" & Replace(Replace(m.SubMatches(1), "/", "%2F"), "+", "%2B") & "&"
            
            Next
            
            strPost = Left(strPost, Len(strPost) - 1)
            
            iWeb.URL = "http://wwwapps.ups.com/WebTracking/detail"
            iWeb.PostData = strPost
            Call iWeb.Send
            strHtml = iWeb.ReturnData
            strHtml = convertCRLF(strHtml)
            
            Reg.Pattern = "<tr[^>]*?>[^<]+<td class=""nowrap"">(.*?)</td>[^<]+<td class=""nowrap"">(.*?)</td>[^<]+<td class=""nowrap"">(.*?)</td>[^<]+<td>(.*?)</td>[^<]+</tr>"
            
            
            Set Mc = Reg.Execute(strHtml)
            
            If Mc.Count > 0 Then
            
        
            Dim SB As clsStringBuilder
        
            Set SB = New clsStringBuilder
            
            Dim i As Integer
            
            For Each m In Mc
                
'                For i = 0 To 5
'
'                    SB.Append modMain.ConvertHTML(m.SubMatches(i)) & vbTab
'                Next
                
                
                '����������CSV��ʽ��ԭʼ���ݣ������ٸ���ģ��ƴ�ӳ�д���SQL
                Dim strtmp As String
                
                strtmp = "[" & modMain.ConvertHTML(m.SubMatches(0)) & "]" & modMain.ConvertHTML(m.SubMatches(3)) & "|Tab|" & modMain.ConvertHTML(m.SubMatches(1)) & " " & modMain.ConvertHTML(m.SubMatches(2)) & "|CrLf|"
                strtmp = Replace(strtmp, "[]", "", 1, -1, vbBinaryCompare)
                SB.Append strtmp
                
                'SB.Append vbCrLf
            
            Next
            
            End If
            '������Ҫ�����������������������������ݽ���ҳ���ύ����������齻��������ȥ���ˡ�
            '����ɾ�������ݣ�д�������ݵȡ�2015-03-04
            
            Dim strResult As String
            
            strResult = Replace(Replace(SB.toString, "|Tab|", vbTab), "|CrLf|", vbCrLf)
            
            If CheckResult(strResult) Then
                '����״̬
            Else
                'ֻ��2����Ϣ���ӵ��͵��ͣ�������Ҫ��������վ��ץȡһ�Σ�ȷ����Ϣ������
                '����Ϊʲô����Ϣ��ȫ�����������ʱûʱ���о��ˡ�
                strResult = GetResultFrom100(strExpressNO) '������ʱ�ȴӿ��100��ץȡ��Ϣ���ƺ��Ƚ��ȶ���
            End If
            
            WriteSQL convertResult("UPS", strExpressNO, strResult)
'            Dim ObjUpload As clsUpLoadData
'            Set ObjUpload = New clsUpLoadData
'            Call ObjUpload.PostExpressData(gstrSite, gstrExpressNO, SB.toString)
'            Set ObjUpload = Nothing
            
        Else
            WriteLog "*NOT MATCH DETAIL LIST"
        End If
    
    Else
        WriteLog "*NOT MATCH CONTENT"
    End If
    
End Function

Private Function CheckResult(ByVal strResult As String) As Boolean
    CheckResult = True
    Dim arr() As String
    arr = Split(strResult, vbCrLf)
    Dim strtmp As String
    
    Dim i As Integer
    
    For i = 0 To UBound(arr)
    
        If arr(i) <> "" Then
            strtmp = strtmp & arr(i) & vbCrLf
        End If
    
    Next
    arr = Split(strtmp, vbCrLf, -1, vbBinaryCompare)
    
    
    If UBound(arr) = 2 Then
    
        If InStr(1, arr(0), "�ѵ���", vbBinaryCompare) > 0 Then
        
            CheckResult = False
        
        Else
        
        End If
    
    Else
      
    End If

End Function

Private Function GetResultFrom100(ByVal strExpressNO As String) As String
    
    Dim iWeb As clsWinHTTPGetHtml
    Set iWeb = New clsWinHTTPGetHtml
    Dim SB As clsStringBuilder
        
    Set SB = New clsStringBuilder
    iWeb.CharSet = "UTF-8"
    iWeb.TimeOut = 15
    iWeb.URL = "http://www.kuaidi100.com/query?type=ups&postid=" & strExpressNO & "&id=1&valicode=&temp=0." & GetRandomNum(15, 15)

    iWeb.PostData = ""

    Dim strHtml As String

    Call iWeb.Send

    strHtml = iWeb.ReturnData
    strHtml = convertCRLF(strHtml)
    Debug.Print strHtml
    
    Dim dicResult As Scripting.Dictionary
    Set dicResult = JSON.Parse(strHtml)
    
    If dicResult.Item("message") = "ok" Then
    
        If dicResult.Item("data").Count > 0 Then
            Dim colResult As VBA.Collection
            
            Set colResult = dicResult.Item("data")
            
            Dim i As Integer
            
            For i = 1 To colResult.Count
            
                SB.Append modMain.ConvertHTML(colResult.Item(i).Item("context")) & "|Tab|" & modMain.ConvertHTML(colResult.Item(i).Item("time")) & "|CrLf|"
            
            Next

            Dim strResult As String
            
            strResult = Replace(Replace(SB.toString, "|Tab|", vbTab), "|CrLf|", vbCrLf)
            GetResultFrom100 = strResult
        Else
        GetResultFrom100 = ""
        End If
    
    Else
    GetResultFrom100 = ""
    End If

End Function

