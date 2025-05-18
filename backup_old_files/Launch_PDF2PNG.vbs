Set objShell = CreateObject("WScript.Shell")
strPath = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
strApp = strPath & "\PDF2PNG_Converter.exe"

' Check if the executable exists
Set fso = CreateObject("Scripting.FileSystemObject")
If fso.FileExists(strApp) Then
    ' Launch without console window
    objShell.Run """" & strApp & """", 0, False
Else
    ' Try alternate location
    strApp = strPath & "\dist\PDF2PNG_Converter.exe"
    If fso.FileExists(strApp) Then
        objShell.Run """" & strApp & """", 0, False
    Else
        ' Show a graphical error instead of a console message
        Set objExplorer = CreateObject("InternetExplorer.Application")
        objExplorer.Navigate "about:blank"
        objExplorer.ToolBar = 0
        objExplorer.StatusBar = 0
        objExplorer.Width = 400
        objExplorer.Height = 200
        objExplorer.Left = (Screen.Width - 400) / 2
        objExplorer.Top = (Screen.Height - 200) / 2
        objExplorer.Document.Title = "PDF2PNG Converter Error"
        objExplorer.Visible = True
        
        While objExplorer.Busy
            WScript.Sleep 100
        Wend
        
        objExplorer.Document.Body.innerHTML = "<div style='font-family:Arial; text-align:center; margin-top:30px;'>" & _
            "<h3 style='color:#CC0000'>PDF2PNG Converter Error</h3>" & _
            "<p>Could not find PDF2PNG_Converter.exe.</p>" & _
            "<p>Please ensure the application is properly installed.</p>" & _
            "<button onclick='window.close()' style='padding:5px 20px; margin-top:20px;'>Close</button>" & _
            "</div>"
    End If
End If
