Option Explicit

Dim audioFile, player, fso
Set fso = CreateObject("Scripting.FileSystemObject")
audioFile = WScript.Arguments(0)

If fso.FileExists(audioFile) Then
    Set player = CreateObject("WMPlayer.OCX")
    player.settings.autoStart = True
    player.settings.volume = 80
    player.settings.setMode "loop", False  ' ��ѭ������
    player.uiMode = "none"  ' ����ʾ����
    player.URL = audioFile  ' ������Ƶ
    
    ' �ȴ��������
    Do While player.playState <> 1  ' 1 = ֹͣ״̬
        WScript.Sleep(1000)
    Loop
    
    ' ������ɺ��Զ��˳�
    Set player = Nothing
    WScript.Quit(0)
End If