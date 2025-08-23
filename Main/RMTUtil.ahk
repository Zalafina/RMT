#Requires AutoHotkey v2.0

;资源保存
OnSaveSetting(*) {
    global MySoftData
    MyWorkPool.Clear()
    loop MySoftData.TabNameArr.Length {
        SaveTableItemInfo(A_Index)
    }

    IniWrite(MySoftData.HoldFloatCtrl.Value, IniFile, IniSection, "HoldFloat")
    IniWrite(MySoftData.PreIntervalFloatCtrl.Value, IniFile, IniSection, "PreIntervalFloat")
    IniWrite(MySoftData.IntervalFloatCtrl.Value, IniFile, IniSection, "IntervalFloat")
    IniWrite(MySoftData.CoordXFloatCon.Value, IniFile, IniSection, "CoordXFloat")
    IniWrite(MySoftData.CoordYFloatCon.Value, IniFile, IniSection, "CoordYFloat")
    IniWrite(MySoftData.SuspendHotkeyCtrl.Value, IniFile, IniSection, "SuspendHotkey")
    IniWrite(MySoftData.PauseHotkeyCtrl.Value, IniFile, IniSection, "PauseHotkey")
    IniWrite(MySoftData.KillMacroHotkeyCtrl.Value, IniFile, IniSection, "KillMacroHotkey")
    IniWrite(true, IniFile, IniSection, "LastSaved")
    IniWrite(MySoftData.ShowWinCtrl.Value, IniFile, IniSection, "IsExecuteShow")
    IniWrite(MySoftData.BootStartCtrl.Value, IniFile, IniSection, "IsBootStart")
    IniWrite(MySoftData.MutiThreadNumCtrl.Value, IniFile, IniSection, "MutiThreadNum")
    IniWrite(MySoftData.NoVariableTipCtrl.Value, IniFile, IniSection, "NoVariableTip")
    IniWrite(MySoftData.CMDTipCtrl.Value, IniFile, IniSection, "CMDTip")
    IniWrite(MySoftData.ScreenShotTypeCtrl.Value, IniFile, IniSection, "ScreenShotType")
    IniWrite(ToolCheckInfo.ToolCheckHotKeyCtrl.Value, IniFile, IniSection, "ToolCheckHotKey")
    IniWrite(ToolCheckInfo.ToolRecordMacroHotKeyCtrl.Value, IniFile, IniSection, "RecordMacroHotKey")
    IniWrite(ToolCheckInfo.ToolTextFilterHotKeyCtrl.Value, IniFile, IniSection, "ToolTextFilterHotKey")
    IniWrite(ToolCheckInfo.ScreenShotHotKeyCtrl.Value, IniFile, IniSection, "ScreenShotHotKey")
    IniWrite(ToolCheckInfo.FreePasteHotKeyCtrl.Value, IniFile, IniSection, "FreePasteHotKey")
    IniWrite(ToolCheckInfo.RecordKeyboard, IniFile, IniSection, "RecordKeyboard")
    IniWrite(ToolCheckInfo.RecordMouse, IniFile, IniSection, "RecordMouse")
    IniWrite(ToolCheckInfo.RecordJoy, IniFile, IniSection, "RecordJoy")
    IniWrite(ToolCheckInfo.RecordMouseRelative, IniFile, IniSection, "RecordMouseRelative")
    IniWrite(ToolCheckInfo.RecordMouseTrail, IniFile, IniSection, "RecordMouseTrail")
    IniWrite(ToolCheckInfo.RecordMouseTrailLen, IniFile, IniSection, "RecordMouseTrailLen")
    IniWrite(ToolCheckInfo.RecordMouseTrailSpeed, IniFile, IniSection, "RecordMouseTrailSpeed")
    IniWrite(ToolCheckInfo.RecordHoldMuti, IniFile, IniSection, "RecordHoldMuti")
    IniWrite(ToolCheckInfo.RecordAutoLoosen, IniFile, IniSection, "RecordAutoLoosen")
    IniWrite(ToolCheckInfo.RecordMouseTrailInterval, IniFile, IniSection, "MouseTrailInterval")
    IniWrite(ToolCheckInfo.RecordJoyInterval, IniFile, IniSection, "RecordJoyInterval")
    IniWrite(ToolCheckInfo.OCRTypeCtrl.Value, IniFile, IniSection, "OCRType")
    IniWrite(MySoftData.TabCtrl.Value, IniFile, IniSection, "TableIndex")
    IniWrite(MySoftData.FontTypeCtrl.Text, IniFile, IniSection, "FontType")
    IniWrite(MySoftData.TabCtrl.Value, IniFile, IniSection, "TableIndex")
    IniWrite(true, IniFile, IniSection, "HasSaved")

    MySoftData.CMDPosX := IniWrite(MySoftData.CMDPosX, IniFile, IniSection, "CMDPosX")
    MySoftData.CMDPosY := IniWrite(MySoftData.CMDPosY, IniFile, IniSection, "CMDPosY")
    MySoftData.CMDWidth := IniWrite(MySoftData.CMDWidth, IniFile, IniSection, "CMDWidth")
    MySoftData.CMDHeight := IniWrite(MySoftData.CMDHeight, IniFile, IniSection, "CMDHeight")
    MySoftData.CMDLineNum := IniWrite(MySoftData.CMDLineNum, IniFile, IniSection, "CMDLineNum")
    MySoftData.CMDBGColor := IniWrite(MySoftData.CMDBGColor, IniFile, IniSection, "CMDBGColor")
    MySoftData.CMDTransparency := IniWrite(MySoftData.CMDTransparency, IniFile, IniSection, "CMDTransparency")
    MySoftData.CMDFontColor := IniWrite(MySoftData.CMDFontColor, IniFile, IniSection, "CMDFontColor")
    MySoftData.CMDFontSize := IniWrite(MySoftData.CMDFontSize, IniFile, IniSection, "CMDFontSize")

    Reload()
}

OnTableDelete(tableItem, index) {
    if (tableItem.ModeArr.Length == 0) {
        return
    }
    result := MsgBox("是否删除当前宏", "提示", 1)
    if (result == "Cancel")
        return

    deleteMacro := tableItem.MacroArr.Length >= index ? tableItem.MacroArr[index] : ""

    MySoftData.BtnAdd.Enabled := false
    tableItem.ModeArr.RemoveAt(index)
    tableItem.ForbidArr.RemoveAt(index)
    tableItem.HoldTimeArr.RemoveAt(index)
    if (tableItem.TKArr.Length >= index)
        tableItem.TKArr.RemoveAt(index)
    if (tableItem.MacroArr.Length >= index)
        tableItem.MacroArr.RemoveAt(index)
    if (tableItem.ProcessNameArr.Length >= index)
        tableItem.ProcessNameArr.RemoveAt(index)
    if (tableItem.LoopCountArr.Length >= index)
        tableItem.LoopCountArr.RemoveAt(index)
    if (tableItem.RemarkArr.Length >= index)
        tableItem.RemarkArr.RemoveAt(index)
    if (tableItem.SerialArr.Length >= index)
        tableItem.SerialArr.RemoveAt(index)
    if (tableItem.TimingSerialArr.Length >= index)
        tableItem.TimingSerialArr.RemoveAt(index)
    tableItem.IndexConArr.RemoveAt(index)
    tableItem.ColorConArr.RemoveAt(index)
    tableItem.ColorStateArr.RemoveAt(index)
    tableItem.TriggerTypeConArr.RemoveAt(index)
    tableItem.ModeConArr.RemoveAt(index)
    tableItem.ForbidConArr.RemoveAt(index)
    tableItem.TKConArr.RemoveAt(index)
    tableItem.InfoConArr.RemoveAt(index)
    tableItem.ProcessNameConArr.RemoveAt(index)
    tableItem.LoopCountConArr.RemoveAt(index)
    tableItem.RemarkConArr.RemoveAt(index)

    OnSaveSetting()
}

OnTableEditMacro(tableItem, index) {
    macro := tableItem.InfoConArr[index].Value
    MyMacroGui.SureBtnAction := (sureMacro) => tableItem.InfoConArr[index].Value := sureMacro
    MyMacroGui.ShowGui(macro, true)
}

OnTableEditReplaceKey(tableItem, index) {
    replaceKey := tableItem.InfoConArr[index].Value
    MyReplaceKeyGui.SureBtnAction := (sureReplaceKey) => tableItem.InfoConArr[index].Value := sureReplaceKey
    MyReplaceKeyGui.ShowGui(replaceKey)
}

OnTableEditTriggerKey(tableItem, index) {
    triggerKey := tableItem.TKConArr[index].Value
    MyTriggerKeyGui.SureBtnAction := (sureTriggerKey) => tableItem.TKConArr[index].Value := sureTriggerKey
    args := TriggerKeyGuiArgs()
    args.IsToolEdit := false
    args.tableItem := tableItem
    args.tableIndex := index
    MyTriggerKeyGui.ShowGui(triggerKey, args)
}

OnTableEditTiming(tableItem, index) {
    SerialStr := tableItem.TimingSerialArr[index]
    MyTimingGui.ShowGui(SerialStr)
}

OnTableEditTriggerStr(tableItem, index) {
    triggerStr := tableItem.TKConArr[index].Value
    MyTriggerStrGui.SureBtnAction := (sureTriggerStr) => tableItem.TKConArr[index].Value := sureTriggerStr
    args := TriggerKeyGuiArgs()
    args.IsToolEdit := false
    MyTriggerStrGui.ShowGui(triggerStr, args)
}

OnEditCMDTipGui() {
    MyCMDTipSettingGui.ShowGui()
}

OnItemEditFrontInfo(tableItem, index, *) {
    MyFrontInfoGui.ShowGui(tableItem, index)
}

OnTableMoveUp(tableItem, index, *) {
    if (index == 1) {
        MsgBox("上面没有元素，无法上移！！！")
        return
    }
    SwapTableContent(tableItem, index, index - 1)
}

OnTableMoveDown(tableItem, index, *) {
    lastIndex := tableItem.ModeArr.length
    if (lastIndex == index) {
        MsgBox("下面没有元素，无法下移！！！")
        return
    }
    SwapTableContent(tableItem, index, index + 1)
}

SwapTableContent(tableItem, indexA, indexB) {
    SwapArrValue(tableItem.ModeConArr, indexA, indexB, 2)
    SwapArrValue(tableItem.ForbidConArr, indexA, indexB, 2)
    SwapArrValue(tableItem.HoldTimeArr, indexA, indexB)
    SwapArrValue(tableItem.TKConArr, indexA, indexB, 2)
    SwapArrValue(tableItem.InfoConArr, indexA, indexB, 2)
    SwapArrValue(tableItem.TriggerTypeConArr, indexA, indexB, 2)
    SwapArrValue(tableItem.SerialArr, indexA, indexB)
    SwapArrValue(tableItem.LoopCountConArr, indexA, indexB, 3)
    SwapArrValue(tableItem.RemarkConArr, indexA, indexB, 2)
    SwapArrValue(tableItem.ProcessNameConArr, indexA, indexB, 2)
}

SwapArrValue(Arr, indexA, indexB, valueType := 1) {
    if (valueType == 3) {
        temp := Arr[indexA].Text
        Arr[indexA].Text := Arr[indexB].Text
        Arr[indexB].Text := temp
    }
    else if (valueType == 2) {
        temp := Arr[indexA].Value
        Arr[indexA].Value := Arr[indexB].Value
        Arr[indexB].Value := temp
    }
    else {
        temp := Arr[indexA]
        Arr[indexA] := Arr[indexB]
        Arr[indexB] := temp
    }
}

BindSave() {
    MyTriggerKeyGui.SaveBtnAction := OnSaveSetting
    MyTriggerStrGui.SaveBtnAction := OnSaveSetting
    MyMacroGui.SaveBtnAction := OnSaveSetting
}

PluginInit() {
    global MyWorkPool := WorkPool()
    global MyChineseOcr := RapidOcr(A_ScriptDir)
    global MyEnglishOcr := RapidOcr(A_ScriptDir, 2)
    global MyPToken := Gdip_Startup()

    dllpath := A_ScriptDir "\Plugins\OpenCV\x64\ImageFinder.dll"
    ; 构建包含 DLL 文件的目录路径
    dllDir := A_ScriptDir "\Plugins\OpenCV\x64"
    ; 使用 SetDllDirectory 将 dllDir 添加到 DLL 搜索路径中
    DllCall("SetDllDirectory", "Str", dllDir)
    DllCall('LoadLibrary', 'str', dllpath, "Ptr")
}

OnToolAlwaysOnTop(*) {
    global MySoftData, ToolCheckInfo
    state := ToolCheckInfo.AlwaysOnTopCtrl.Value
    if (state) {
        MySoftData.MyGui.Opt("+AlwaysOnTop")
    }
    else {
        MySoftData.MyGui.Opt("-AlwaysOnTop")
    }
}

InitFilePath() {
    if (!DirExist(A_WorkingDir "\Setting")) {
        DirCreate(A_WorkingDir "\Setting")
    }
    if (!DirExist(A_WorkingDir "\Setting\" MySoftData.CurSettingName)) {
        DirCreate(A_WorkingDir "\Setting\" MySoftData.CurSettingName)
    }

    if (!DirExist(A_WorkingDir "\Setting\" MySoftData.CurSettingName "\Images\ScreenShot")) {
        DirCreate(A_WorkingDir "\Setting\" MySoftData.CurSettingName "\Images\ScreenShot")
    }

    if (!DirExist(A_WorkingDir "\Images")) {
        DirCreate(A_WorkingDir "\Images")
    }
    if (!DirExist(A_WorkingDir "\Images\Soft")) {
        DirCreate(A_WorkingDir "\Images\Soft")
    }

    if (!DirExist(A_WorkingDir "\Images\ScreenShot")) {
        DirCreate(A_WorkingDir "\Images\ScreenShot")
    }

    if (!DirExist(A_WorkingDir "\Images\FreePaste")) {
        DirCreate(A_WorkingDir "\Images\FreePaste")
    }

    FileInstall("Images\Soft\WeiXin.png", "Images\Soft\WeiXin.png", 1)
    FileInstall("Images\Soft\ZhiFuBao.png", "Images\Soft\ZhiFuBao.png", 1)
    FileInstall("Images\Soft\rabit.ico", "Images\Soft\rabit.ico", 1)
    FileInstall("Images\Soft\IcoPause.ico", "Images\Soft\IcoPause.ico", 1)
    FileInstall("Images\Soft\GreenColor.png", "Images\Soft\GreenColor.png", 1)
    FileInstall("Images\Soft\RedColor.png", "Images\Soft\RedColor.png", 1)
    FileInstall("Images\Soft\YellowColor.png", "Images\Soft\YellowColor.png", 1)

    global VBSPath := A_WorkingDir "\VBS\PlayAudio.vbs"
    global MacroFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\MacroFile.ini"
    global SearchFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\SearchFile.ini"
    global SearchProFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\SearchProFile.ini"
    global CompareFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\CompareFile.ini"
    global MMProFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\MMProFile.ini"
    global TimingFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\TimingFile.ini"
    global RunFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\RunFile.ini"
    global OutputFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\OutputFile.ini"
    global StopFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\StopFile.ini"
    global VariableFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\VariableFile.ini"
    global ExVariableFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\ExVariableFile.ini"
    global SubMacroFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\SubMacroFile.ini"
    global OperationFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\OperationFile.ini"
    global BGMouseFile := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\BGMouseFile.ini"
}

SubMacroStopAction(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    workPath := MyWorkPool.GetWorkPath(tableItem.IsWorkIndexArr[itemIndex])
    ; tableItem.IsWorkIndexArr[itemIndex] := false
    MyWorkPool.PostMessage(WM_STOP_MACRO, workPath, 0, 0)
}

TriggerSubMacro(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    macro := tableItem.MacroArr[itemIndex]
    hasWork := MyWorkPool.CheckHasWork()

    if (tableItem.IsWorkIndexArr[itemIndex])     ;正在执行不能再次触发
        return

    if (hasWork) {
        workPath := MyWorkPool.Get()
        workIndex := MyWorkPool.GetWorkIndex(workPath)
        tableItem.IsWorkIndexArr[itemIndex] := workIndex
        MyWorkPool.PostMessage(WM_TR_MACRO, workPath, tableIndex, itemIndex)
    }
    else {
        action := OnTriggerMacroKeyAndInit.Bind(tableItem, macro, itemIndex)
        SetTimer(action, -1)
    }
}

SetGlobalVariable(Name, Value, ignoreExist) {
    global MySoftData
    if (ignoreExist && MySoftData.VariableMap.Has(Name))
        return
    MySoftData.VariableMap[Name] := Value
    hasWork := MyWorkPool.CheckHasWork()
    if (hasWork) {
        loop MyWorkPool.maxSize {
            workPath := A_ScriptDir "\Thread\Work" A_Index ".exe"
            str := Format("SetVari_{}_{}", Name, Value)
            MyWorkPool.SendMessage(WM_COPYDATA, workPath, str)
        }
    }
}

DelGlobalVariable(Name) {
    global MySoftData
    if (MySoftData.VariableMap.Has(Name))
        MySoftData.VariableMap.Delete(Name)
    hasWork := MyWorkPool.CheckHasWork()
    if (hasWork) {
        loop MyWorkPool.maxSize {
            workPath := A_ScriptDir "\Thread\Work" A_Index ".exe"
            str := Format("DelVari_{}", Name)
            MyWorkPool.SendMessage(WM_COPYDATA, workPath, str)
        }
    }
}

SetCMDTipValue(value) {
    hasWork := MyWorkPool.CheckHasWork()
    if (hasWork) {
        loop MyWorkPool.maxSize {
            workPath := A_ScriptDir "\Thread\Work" A_Index ".exe"
            str := Format("CMDTip_{}", value)
            MyWorkPool.SendMessage(WM_COPYDATA, workPath, str)
        }
    }
}

CMDReport(CMDStr) {
    MyCMDTipGui.ShowGui(CMDStr)
}

;0默认状态 1运行 2暂停 3取消暂停 4终止
SetTableItemState(tableIndex, itemIndex, state) {
    tableItem := MySoftData.TableInfo[tableIndex]
    LastColorState := tableItem.ColorStateArr[itemIndex]
    ColorCon := tableItem.ColorConArr[itemIndex]
    isVisible := state != 0
    tableItem.ColorStateArr[itemIndex] := state
    if (state == 1) {
        ColorCon.Value := "Images\Soft\GreenColor.png"
    }
    else if (state == 2) {
        if (!ColorCon.Visible || LastColorState != 1) { ;非运行状态忽略
            tableItem.ColorStateArr[itemIndex] := LastColorState
            return
        }

        ColorCon.Value := "Images\Soft\YellowColor.png"
    }
    else if (state == 3) {
        if (!ColorCon.Visible || LastColorState == 3) { ;终止状态忽略
            tableItem.ColorStateArr[itemIndex] := LastColorState
            return
        }

        ColorCon.Value := "Images\Soft\RedColor.png"
        SetTimer(CancelTableItemStopState.Bind(tableIndex, itemIndex), -5000)
    }
    ColorCon.Visible := isVisible
}

CancelTableItemStopState(tableIndex, itemIndex) {
    tableItem := MySoftData.TableInfo[tableIndex]
    ColorState := tableItem.ColorStateArr[itemIndex]
    ColorCon := tableItem.ColorConArr[itemIndex]
    if (ColorCon.Visible && ColorState == 3) {
        ColorCon.Visible := false
        tableItem.ColorStateArr[itemIndex] := 0
    }
}

SetItemPauseState(tableIndex, itemIndex, state) {
    tableItem := MySoftData.TableInfo[tableIndex]
    tableItem.PauseArr[itemIndex] := state
    isWork := tableItem.IsWorkIndexArr[itemIndex]

    LastColorState := tableItem.ColorStateArr[itemIndex]
    if (LastColorState == 1 && state == 1)
        SetTableItemState(tableIndex, itemIndex, 2)
    else if (LastColorState == 2 && state == 0)
        SetTableItemState(tableIndex, itemIndex, 1)

    if (isWork) {
        workPath := MyWorkPool.GetWorkPath(tableItem.IsWorkIndexArr[itemIndex])
        str := Format("PauseState_{}_{}_{}", tableIndex, itemIndex, state)
        MyWorkPool.SendMessage(WM_COPYDATA, workPath, str)
    }
}

MsgBoxContent(content) {
    MySoftData.MyGui.Flash()
    SoundPlay "*-1"
    MsgBox(content)
}

ToolTipContent(content) {
    MySoftData.ToolTipText := content
    MySoftData.ToolTipEndTime := A_TickCount + 5000  ; 设置5秒后结束的时间戳
    SetTimer(ToolTipTimer, 100)  ; 启动/重置定时器，每100ms执行一次
}

ToolTipTimer() {
    if (A_TickCount >= MySoftData.ToolTipEndTime) {
        ; 超过显示时间，隐藏ToolTip并停止定时器
        ToolTip
        SetTimer(ToolTipTimer, 0)
    } else {
        ; 仍在显示时间内，更新ToolTip
        ToolTip(MySoftData.ToolTipText)
    }
}

ExcuteRMTCMDAction(cmdStr) {
    if (cmdStr == "截图") {
        OnToolScreenShot()
    }
    else if (cmdStr == "截图提取文本") {
        OnToolTextFilterScreenShot()
    }
    else if (cmdStr == "自由贴") {
        OnToolFreePaste()
    }
    else if (cmdStr == "开启指令显示") {
        MySoftData.CMDTipCtrl.Value := true
        MySoftData.CMDTip := true
        SetCMDTipValue(true)
        MyCMDTipGui.Gui.Hide()
    }
    else if (cmdStr == "关闭指令显示") {
        MySoftData.CMDTipCtrl.Value := false
        MySoftData.CMDTip := false
        SetCMDTipValue(false)
        style := WinGetStyle(MyCMDTipGui.Gui.Hwnd)
        isVisible := (style & 0x10000000)  ; 0x10000000 = WS_VISIBLE
        if (isVisible)
            MyCMDTipGui.Gui.Hide()
    }
    else if (cmdStr == "启用键鼠") {
        BlockInput false
    }
    else if (cmdStr == "禁用键鼠") {
        BlockInput true
    }
    else if (cmdStr == "休眠") {
        OnSuspendHotkey()
    }
    else if (cmdStr == "暂停所有宏") {
        SetPauseState(true)
    }
    else if (cmdStr == "恢复所有宏") {
        SetPauseState(false)
    }
    else if (cmdStr == "终止所有宏") {
        OnKillAllMacro()
    }
    else if (cmdStr == "重载") {
        MenuReload()
    }
}

ScreenShot(X1, Y1, X2, Y2, FileName) {
    width := X2 - X1
    height := Y2 - Y1
    pBitmap := Gdip_BitmapFromScreen(X1 "|" Y1 "|" width "|" height)
    Gdip_SaveBitmapToFile(pBitmap, FileName)
    ; 释放位图资源
    Gdip_DisposeImage(pBitmap)
}

OnToolTextFilterGetArea(x1, y1, x2, y2) {
    filePath := A_WorkingDir "\Images\ScreenShot\TextFilter.png"
    ScreenShot(x1, y1, x2, y2, filePath)
    ocr := ToolCheckInfo.OCRTypeCtrl.Value == 1 ? MyChineseOcr : MyEnglishOcr
    result := ocr.ocr_from_file(filePath)
    ToolCheckInfo.ToolTextCtrl.Value := result
    A_Clipboard := result
}

OnToolTextCheckScreenShot() {
    ; 如果剪贴板中有图像
    if DllCall("IsClipboardFormatAvailable", "uint", 8)  ; 8 是 CF_BITMAP 格式
    {
        filePath := A_WorkingDir "\Images\ScreenShot\TextFilter.png"
        SaveClipToBitmap(filePath)
        ocr := ToolCheckInfo.OCRTypeCtrl.Value == 1 ? MyChineseOcr : MyEnglishOcr
        result := ocr.ocr_from_file(filePath)
        ToolCheckInfo.ToolTextCtrl.Value := result
        A_Clipboard := result
        ; 停止监听
        SetTimer(, 0)
    }
}

EnableSelectAerea(action) {
    Hotkey("LButton", (*) => SelectArea(action), "On")
    Hotkey("LButton Up", (*) => DisSelectArea(action), "On")
}

DisSelectArea(action) {
    Hotkey("LButton", (*) => SelectArea(action), "Off")
    Hotkey("LButton Up", (*) => DisSelectArea(action), "Off")
}

SelectArea(action) {
    ; 获取起始点坐标
    startX := startY := endX := endY := 0
    CoordMode("Mouse", "Screen")
    MouseGetPos(&startX, &startY)

    ; 创建 GUI 用于绘制矩形框
    MyGui := Gui("+ToolWindow -Caption +AlwaysOnTop -DPIScale")
    MyGui.BackColor := "Red"
    WinSetTransColor(" 150", MyGui)
    MyGui.Opt("+LastFound")
    GuiHwnd := WinExist()

    ; 显示初始 GUI
    MyGui.Show("NA x" startX " y" startY " w1 h1")

    ; 跟踪鼠标移动
    while GetKeyState("LButton", "P") {
        CoordMode("Mouse", "Screen")
        MouseGetPos(&endX, &endY)
        width := Abs(endX - startX)
        height := Abs(endY - startY)
        x := Min(startX, endX)
        y := Min(startY, endY)

        MyGui.Show("NA x" x " y" y " w" width " h" height)
    }
    ; 销毁 GUI
    MyGui.Destroy()
    ; 返回坐标

    x1 := Min(startX, endX)
    y1 := Min(startY, endY)
    x2 := Max(startX, endX)
    y2 := Max(startY, endY)
    action(x1, y1, x2, y2)
}

;DataType 1:SearchData
RepairPath(FilePath, DataType) {
    SymbolArr := ["Search"]
    Symbol := SymbolArr[DataType]
    if (!FileExist(FilePath))
        return false

    hasRepair := false
    loop read, FilePath {
        LineStr := A_LoopReadLine
        if (SubStr(LineStr, 1, StrLen(Symbol)) != Symbol)
            continue

        SerialStr := SubStr(LineStr, 1, StrLen(Symbol) + 7)
        Data := ""
        if (DataType == 1) {
            saveStr := IniRead(FilePath, IniSection, SerialStr, "")
            Data := JSON.parse(saveStr, , false)
        }

        if (Data == "")
            continue

        if (DataType == 1 && Data.SearchImagePath != "") {
            StartPos := InStr(Data.SearchImagePath, "Setting", 1)
            SubPath := SubStr(Data.SearchImagePath, StartPos)
            NewPath := A_WorkingDir "\" SubPath
            if (!FileExist(Data.SearchImagePath) && FileExist(NewPath)) {
                Data.SearchImagePath := NewPath
                saveStr := JSON.stringify(Data, 0)
                IniWrite(saveStr, SearchProFile, IniSection, Data.SerialStr)
                if (MySoftData.DataCacheMap.Has(Data.SerialStr)) {
                    MySoftData.DataCacheMap.Delete(Data.SerialStr)
                }
                hasRepair := true
            }
        }
    }
    return hasRepair
}
