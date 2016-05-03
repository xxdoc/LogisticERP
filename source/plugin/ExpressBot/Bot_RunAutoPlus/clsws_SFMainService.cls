VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsws_SFMainService"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'(fBytes, 0, UBound(fBytes), FLe.Name, "zxb@fjw")
Public Function SOAPUploadFile(ByRef ar_buffer() As Byte, ByVal lng_offset As Long, ByVal lng_length As Long, ByVal str_strFileName As String, ByVal str_strPWD As String) As Boolean

    Dim strContent As String
    Dim objCfgReader As clsReadConfigFile
    Set objCfgReader = New clsReadConfigFile
    strContent = objCfgReader.ReadCfgFile("SoapContent.config", True)
    
    Dim objBase64 As clsvbBase64
    Set objBase64 = New clsvbBase64
    Dim strBase64Conteng As String
    Dim strBase64Content As String
    strBase64Content = objBase64.Base64Encode(ar_buffer)
    
    strContent = Replace(strContent, "|-buffer-|", strBase64Content, 1, 1, vbBinaryCompare)
    strContent = Replace(strContent, "|-strFileName-|", str_strFileName, 1, 1, vbBinaryCompare)
    strContent = Replace(strContent, "|-strPWD-|", str_strPWD, 1, 1, vbBinaryCompare)
    strContent = Replace(strContent, "|-offset-|", lng_offset, 1, 1, vbBinaryCompare)
    strContent = Replace(strContent, "|-length-|", lng_length, 1, 1, vbBinaryCompare)
    
    
    Set objBase64 = Nothing
    Set objCfgReader = Nothing
    
    Dim iSOAPWeb As clsSOAP_Poster
    Set iSOAPWeb = New clsSOAP_Poster
    
    iSOAPWeb.URL = "http://218.17.224.215:8082/SFMainService.svc"
    iSOAPWeb.SOAPAction = "http://tempuri.org/ISFMainService/UploadFile"
    iSOAPWeb.PostData = strContent
    
    Call iSOAPWeb.Send
    
    Debug.Print iSOAPWeb.ReturnData
    
    If iSOAPWeb.ReturnCode = 200 Then
    
        SOAPUploadFile = True
    
    Else
        SOAPUploadFile = False
    End If
    
    
    Set iSOAPWeb = Nothing
    
End Function


'============================== �������ϣ�@ 2015-09-06 by wulf ==================================
'=============================== ��Ϊʵ���ǲ���õ��� ~~~~ ==================================
''*****************************************************************
''�������� Microsoft Office 2003 Web Services Toolkit �����ġ�
''
''����ʱ��: 8/6/2015 08:40:44 AM
''
''˵��:
''������ Web ����
'' �� Visual Basic for Applications ���ʾ��ʽ�������� http://218.17.224.215:8082/SFMainService.svc?wsdl ����ġ�
''
''ʹ��:
''����������Ϊ�µ� clsws_SFMainService��Ȼ���д������
''ʹ�ø������ṩ�ķ�����
''ʾ��:
'' Dim ExampleVar as New clsws_SFMainService
'' debug.print ExampleVar.wsm_UploadFile(��ʾ�����롱)
''
''�йظ�����Ϣ������� Microsoft Office 2003
''Web Services Toolkit �����еġ��������͡���
''
''�Դ����еĴ��������ĸ��Ŀ��ܵ��´������Ϊ��
''
''*****************************************************************
'
''����ר���������
'Private sc_SFMainService As SoapClient30
'Private Const c_WSDL_URL As String = "http://218.17.224.215:8082/SFMainService.svc?wsdl"
'Private Const c_SERVICE As String = "SFMainService"
'Private Const c_PORT As String = "BasicHttpBinding_ISFMainService"
'Private Const c_SERVICE_NAMESPACE As String = "http://tempuri.org/"
'
'Private Sub Class_Initialize()
'    '*****************************************************************
'    'ÿ��ʵ��������ʱ�������ô������̡�
'    '�� sc_ComplexTypes ����Ϊ�µ� SoapClient30��Ȼ��
'    '����
'    'http://218.17.224.215:8082/SFMainService.svc?wsdl ���ҵ��� WSDL �ļ�ʵ���� sc_ComplexTypes.mssoapinit2��
'    '*****************************************************************
'
'    Dim str_WSML As String
'    str_WSML = ""
'
'    Set sc_SFMainService = New SoapClient30
'
'    sc_SFMainService.MSSoapInit2 c_WSDL_URL, str_WSML, c_SERVICE, c_PORT, c_SERVICE_NAMESPACE
'    'ʹ�� Internet Explorer �� LAN �����ж���Ĵ�����������������
'    '�� ProxyServer ����Ϊ <CURRENT_USER>
'    sc_SFMainService.ConnectorProperty("ProxyServer") = "<CURRENT_USER>"
'    '��� Internet Explorer ������Ϊ�Զ���⣬���Զ����������ã�
'    '�����ǽ� EnableAutoProxy ����Ϊ��
'    sc_SFMainService.ConnectorProperty("EnableAutoProxy") = True
'
'
'End Sub
'
'Private Sub Class_Terminate()
'    '*****************************************************************
'    '����ÿ����������ʱ���ô������̡�
'    '�� sc_ComplexTypes ����Ϊ Nothing��
'    '*****************************************************************
'
'    '���󲶻�
'    On Error GoTo Class_TerminateTrap
'
'    Set sc_SFMainService = Nothing
'
'Exit Sub
'
'Class_TerminateTrap:
'    SFMainServiceErrorHandler ("Class_Terminate")
'End Sub
'
'Private Sub SFMainServiceErrorHandler(str_Function As String)
'    '*****************************************************************
'    '��������������������򡣵��κ��������̻���
'    '��������ʱ�������ԴӸ������̻������ô������̡�Ȼ���������������ṩ
'    '���������̻��������ơ�
'    '*****************************************************************
'
'    'SOAP ����
'    If sc_SFMainService.FaultCode <> "" Then
'        Err.Raise vbObjectError, str_Function, sc_SFMainService.FaultString
'    '�� SOAP ����
'    Else
'        Err.Raise Err.Number, str_Function, Err.Description
'    End If
'
'End Sub
'
'Public Function wsm_UploadFile(ByVal ar_buffer As Variant, ByVal lng_offset As Long, ByVal lng_length As Long, ByVal str_strFileName As String, ByVal str_strPWD As String) As Boolean
'    '*****************************************************************
'    '�� http://218.17.224.215:8082/SFMainService.svc?wsdl �����Ĵ���������
'    '
'    '��ar_buffer����һ����Ԫ�ر�����Ϊ Byte ������
'    '�й�ʵ���������ϸ��Ϣ��
'    '����� Microsoft Office 2003 Web Services Toolkit �����еġ��������ͣ����顱��
'    '*****************************************************************
'
'    '���󲶻�
'    On Error GoTo wsm_UploadFileTrap
'
'    wsm_UploadFile = sc_SFMainService.UploadFile(ar_buffer, lng_offset, lng_length, str_strFileName, str_strPWD)
'
'Exit Function
'wsm_UploadFileTrap:
'    SFMainServiceErrorHandler "wsm_UploadFile"
'End Function
'
'Public Function wsm_UploadBigFile(ByVal ar_buffer As Variant, ByVal lng_offset As Long, ByVal lng_length As Long, ByVal dcml_totalLength As Double, ByVal str_strFileName As String, ByVal str_strPWD As String) As Boolean
'    '*****************************************************************
'    '�� http://218.17.224.215:8082/SFMainService.svc?wsdl �����Ĵ���������
'    '
'    '��ar_buffer����һ����Ԫ�ر�����Ϊ Byte ������
'    '�й�ʵ���������ϸ��Ϣ��
'    '����� Microsoft Office 2003 Web Services Toolkit �����еġ��������ͣ����顱��
'    '*****************************************************************
'
'    '���󲶻�
'    On Error GoTo wsm_UploadBigFileTrap
'
'    wsm_UploadBigFile = sc_SFMainService.UploadBigFile(ar_buffer, lng_offset, lng_length, dcml_totalLength, str_strFileName, str_strPWD)
'
'Exit Function
'wsm_UploadBigFileTrap:
'    SFMainServiceErrorHandler "wsm_UploadBigFile"
'End Function
'
'Public Function wsm_GetFileList(ByVal str_strPWD As String) As Variant
'    '*****************************************************************
'    '�� http://218.17.224.215:8082/SFMainService.svc?wsdl �����Ĵ���������
'    '
'    '��wsm_GetFileList����һ����Ԫ�ر�����Ϊ String ������
'    '�й�ʵ���������ϸ��Ϣ��
'    '����� Microsoft Office 2003 Web Services Toolkit �����еġ��������ͣ����顱��
'    '*****************************************************************
'
'    '���󲶻�
'    On Error GoTo wsm_GetFileListTrap
'
'    wsm_GetFileList = sc_SFMainService.GetFileList(str_strPWD)
'
'Exit Function
'wsm_GetFileListTrap:
'    SFMainServiceErrorHandler "wsm_GetFileList"
'End Function
'
'Public Function wsm_GetFileLength(ByVal str_strFileName As String, ByVal str_strPWD As String) As Double
'    '*****************************************************************
'    '�� http://218.17.224.215:8082/SFMainService.svc?wsdl �����Ĵ���������
'    '*****************************************************************
'
'    '���󲶻�
'    On Error GoTo wsm_GetFileLengthTrap
'
'    wsm_GetFileLength = sc_SFMainService.GetFileLength(str_strFileName, str_strPWD)
'
'Exit Function
'wsm_GetFileLengthTrap:
'    SFMainServiceErrorHandler "wsm_GetFileLength"
'End Function
'
'Public Function wsm_DownloadFile(ByVal str_strFileName As String, ByVal lng_offset As Long, ByVal lng_length As Long, ByVal str_strPWD As String) As Variant
'    '*****************************************************************
'    '�� http://218.17.224.215:8082/SFMainService.svc?wsdl �����Ĵ���������
'    '
'    '��wsm_DownloadFile����һ����Ԫ�ر�����Ϊ Byte ������
'    '�й�ʵ���������ϸ��Ϣ��
'    '����� Microsoft Office 2003 Web Services Toolkit �����еġ��������ͣ����顱��
'    '*****************************************************************
'
'    '���󲶻�
'    On Error GoTo wsm_DownloadFileTrap
'
'    wsm_DownloadFile = sc_SFMainService.DownLoadFile(str_strFileName, lng_offset, lng_length, str_strPWD)
'
'Exit Function
'wsm_DownloadFileTrap:
'    SFMainServiceErrorHandler "wsm_DownloadFile"
'End Function
'
'Public Function wsm_delFile(ByVal str_strFileName As String, ByVal str_strPWD As String) As Boolean
'    '*****************************************************************
'    '�� http://218.17.224.215:8082/SFMainService.svc?wsdl �����Ĵ���������
'    '*****************************************************************
'
'    '���󲶻�
'    On Error GoTo wsm_delFileTrap
'
'    wsm_delFile = sc_SFMainService.delFile(str_strFileName, str_strPWD)
'
'Exit Function
'wsm_delFileTrap:
'    SFMainServiceErrorHandler "wsm_delFile"
'End Function
'
'Public Function wsm_IsUploadFile(ByVal str_strPWD As String) As Boolean
'    '*****************************************************************
'    '�� http://218.17.224.215:8082/SFMainService.svc?wsdl �����Ĵ���������
'    '*****************************************************************
'
'    '���󲶻�
'    On Error GoTo wsm_IsUploadFileTrap
'
'    wsm_IsUploadFile = sc_SFMainService.IsUploadFile(str_strPWD)
'
'Exit Function
'wsm_IsUploadFileTrap:
'    SFMainServiceErrorHandler "wsm_IsUploadFile"
'End Function
'
'Public Function wsm_GetUploadTime(ByVal str_strPWD As String) As Long
'    '*****************************************************************
'    '�� http://218.17.224.215:8082/SFMainService.svc?wsdl �����Ĵ���������
'    '*****************************************************************
'
'    '���󲶻�
'    On Error GoTo wsm_GetUploadTimeTrap
'
'    wsm_GetUploadTime = sc_SFMainService.GetUploadTime(str_strPWD)
'
'Exit Function
'wsm_GetUploadTimeTrap:
'    SFMainServiceErrorHandler "wsm_GetUploadTime"
'End Function
'
'
'