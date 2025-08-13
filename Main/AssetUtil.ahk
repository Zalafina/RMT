#Requires AutoHotkey v2.0
global WM_COPYDATA := 0x4a ;传递字符串，系统信息

global WM_LOAD_WORK := 0x500  ;资源加载完成事件
global WM_RELEASE_WORK := 0x501  ;资源释放事件
global WM_CLEAR_WORK := 0x502  ;资源释放事件
global WM_TR_MACRO := 0x503 ;触发宏事件
global WM_STOP_MACRO := 0x504 ;停止宏事件
global WM_SET_VARI := 0x505    ;设置变量
global WM_DEL_VARI := 0x506    ;删除变量

; 功能函数
GetFloatTime(oriTime, floatValue) {
    oriTime := Integer(oriTime)
    floatValue := Integer(floatValue)
    value := Abs(oriTime * (floatValue * 0.01))
    maxValue := oriTime + value
    minValue := oriTime - value
    result := Max(0, Random(minValue, maxValue))
    return result
}

GetFloatValue(oriValue, floatValue) {
    oriValue := Integer(oriValue)
    value := Abs(floatValue)
    max := oriValue + value
    min := oriValue - value
    return Random(min, max)
}

GetCurMSec() {
    return A_Hour * 3600 * 1000 + A_Min * 60 * 1000 + A_Sec * 1000 + A_mSec
}

GetProcessName() {
    MouseGetPos &mouseX, &mouseY, &winId
    name := WinGetProcessName(winId)
    return name
}

SaveClipToBitmap(filePath) {
    ; 保存位图到文件; 检查剪切板中是否有位图
    if !DllCall("IsClipboardFormatAvailable", "uint", 2)  ; 2 是 CF_BITMAP
    {
        MsgBox("剪切板中没有位图")
    }

    ; 打开剪切板
    if !DllCall("OpenClipboard", "ptr", 0) {
        MsgBox("无法打开剪切板")
        return
    }

    ; 获取剪切板中的位图句柄
    hBitmap := DllCall("GetClipboardData", "uint", 2, "ptr")  ; 2 是 CF_BITMAP
    if !hBitmap {
        MsgBox("无法获取位图句柄")
        DllCall("CloseClipboard")
        return
    }

    ; 关闭剪切板
    DllCall("CloseClipboard")

    ; 创建 GDI+ 位图对象
    pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
    if !pBitmap {
        MsgBox("无法创建 GDI+ 位图对象")
        return
    }

    ; 保存位图到文件
    Gdip_SaveBitmapToFile(pBitmap, filePath)

    ; 释放 GDI+ 位图对象
    Gdip_DisposeImage(pBitmap)
}

GetImageSize(imageFile) {
    pBm := Gdip_CreateBitmapFromFile(imageFile)
    width := Gdip_GetImageWidth(pBm)
    height := Gdip_GetImageHeight(pBm)

    Gdip_DisposeImage(pBm)
    return [width, height]
}

SplitMacro(info) {
    resultArr := []
    lastSymbolIndex := 0

    loop parse info {

        if (A_LoopField == ",") {
            curCmd := SubStr(info, lastSymbolIndex + 1, A_Index - lastSymbolIndex - 1)
            if (curCmd != "")
                resultArr.Push(curCmd)
            lastSymbolIndex := A_Index
        }

        if (A_Index == StrLen(info)) {
            curCmd := SubStr(info, lastSymbolIndex + 1, A_Index - lastSymbolIndex)
            resultArr.Push(curCmd)
        }

    }
    return resultArr
}

SplitCommand(macro) {
    splitIndex := RegExMatch(macro, "(\(.*\))", &match)
    if (splitIndex == 0) {
        return [macro, "", ""]
    }
    else {
        macro1 := SubStr(macro, 1, splitIndex - 1)
        result := [macro1]
        lastSymbolIndex := 0
        leftBracket := 0
        loop parse match[1] {
            if (A_LoopField == "(") {
                leftBracket += 1
                if (leftBracket == 1)
                    lastSymbolIndex := A_Index
            }

            if (A_LoopField == ")") {
                leftBracket -= 1
                if (leftBracket == 0) {
                    curMacro := SubStr(match[1], lastSymbolIndex + 1, A_Index - lastSymbolIndex - 1)
                    result.Push(curMacro)
                }
            }
        }
        if (result.Length == 2) {
            result.Push("")
        }
        return result
    }
}

SplitKeyCommand(macro) {
    realKey := ""
    for key, value in MySoftData.SpecialKeyMap {
        newMacro := StrReplace(macro, key, "flagSymbol")
        if (newMacro != macro) {
            realKey := key
            break
        }
    }

    result := StrSplit(newMacro, "_")
    loop result.Length {
        if (InStr(result[A_Index], "flagSymbol")) {
            result[A_Index] := StrReplace(result[A_Index], "flagSymbol", realKey)
            break
        }
    }

    return result
}

GetComboKeyArr(ComboKey) {
    KeyArr := []
    ModifyKeyMap := Map("LAlt", "<!", "RAlt", ">!", "Alt", "!", "LWin", "<#", "RWin", ">#", "Win", "#",
        "LCtrl", "<^", "RCtrl", ">^", "Ctrl", "^", "LShift", "<+", "RShift", ">+", "Shift", "+")

    loop {
        hasModifyKey := false
        for key, value in ModifyKeyMap {
            length := StrLen(value)
            subComboKey := SubStr(ComboKey, 1, length)
            if (subComboKey == value) {
                KeyArr.Push(key)
                ComboKey := SubStr(ComboKey, length + 1)
                hasModifyKey := true
                break
            }
        }

        if (!hasModifyKey)
            break
    }

    if (ComboKey != "")
        KeyArr.Push(ComboKey)
    return KeyArr
}

EditListen() {
    OnMessage(0x020A, WM_MOUSEWHEEL)  ; 0x020A 是 WM_MOUSEWHEEL
}

WM_MOUSEWHEEL(wParam, lParam, msg, hwnd) {
    try {
        ctrl := GuiCtrlFromHwnd(hwnd)
        if (ctrl.Type == "DDL" || ctrl.Type == "ComboBox") {
            ; 检查下拉列表是否展开（通过发送 CB_GETDROPPEDSTATE 消息）
            isDropped := CheckIfDrop(0x0157, 0, 0, hwnd)  ; 0x0157 是 CB_GETDROPPEDSTATE
            if (!isDropped || !ctrl.Focused) {
                return 0  ; 阻止处理未展开状态下的滚轮事件
            }
            ; 如果下拉列表是展开的，允许滚轮滚动选项
        }
    }
    ; 其他控件允许正常处理
    return
}

CheckIfDrop(Msg, wParam, lParam, hWnd) {
    ; 辅助函数：发送 Windows 消息
    static WM_USER := 0x400
    if (Msg >= WM_USER) {
        return DllCall("SendMessage", "Ptr", hWnd, "UInt", Msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
    }
    return DllCall("User32.dll\SendMessage", "Ptr", hWnd, "UInt", Msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

;初始化数据
InitData() {
    InitTableItemState()
    InitJoyAxis()
}

;手柄轴未使用时，状态会变为0，而非中间值
InitJoyAxis() {
    if (!CheckIfInstallVjoy())
        return
    joyAxisNum := 8
    tableItem := MySoftData.SpecialTableItem
    tableItem.HoldKeyArr[1] := Map()
    loop joyAxisNum {
        SendJoyAxisClick("JoyAxis" A_Index "Max", 30, tableItem, 1, 1)
    }
}

;资源读取
LoadMainSetting() {
    global ToolCheckInfo, MySoftData
    global IniSection := "UserSettings"
    MySoftData.CurSettingName := IniRead(IniFile, IniSection, "CurSettingName", "RMT默认配置")
    MySoftData.SettingArrStr := IniRead(IniFile, IniSection, "SettingArrStr", "RMT默认配置")
    MySoftData.HasSaved := IniRead(IniFile, IniSection, "HasSaved", false)
    MySoftData.NormalPeriod := IniRead(IniFile, IniSection, "NormalPeriod", 50)
    MySoftData.HoldFloat := IniRead(IniFile, IniSection, "HoldFloat", 0)
    MySoftData.PreIntervalFloat := IniRead(IniFile, IniSection, "PreIntervalFloat", 0)
    MySoftData.IntervalFloat := IniRead(IniFile, IniSection, "IntervalFloat", 0)
    MySoftData.CoordXFloat := IniRead(IniFile, IniSection, "CoordXFloat", 0)
    MySoftData.CoordYFloat := IniRead(IniFile, IniSection, "CoordYFloat", 0)
    MySoftData.IsLastSaved := IniRead(IniFile, IniSection, "LastSaved", false)
    MySoftData.PauseHotkey := IniRead(IniFile, IniSection, "PauseHotkey", "!p")
    MySoftData.KillMacroHotkey := IniRead(IniFile, IniSection, "KillMacroHotkey", "!k")
    ToolCheckInfo.IsToolCheck := IniRead(IniFile, IniSection, "IsToolCheck", false)
    ToolCheckInfo.ToolCheckHotKey := IniRead(IniFile, IniSection, "ToolCheckHotKey", "!o")
    ToolCheckInfo.ToolRecordMacroHotKey := IniRead(IniFile, IniSection, "RecordMacroHotKey", "!r")
    ToolCheckInfo.ToolTextFilterHotKey := IniRead(IniFile, IniSection, "ToolTextFilterHotKey", "!u")
    ToolCheckInfo.ScreenShotHotKey := IniRead(IniFile, IniSection, "ScreenShotHotKey", "!l")
    ToolCheckInfo.FreePasteHotKey := IniRead(IniFile, IniSection, "FreePasteHotKey", "!m")
    ToolCheckInfo.RecordKeyboard := IniRead(IniFile, IniSection, "RecordKeyboard", true)
    ToolCheckInfo.RecordMouse := IniRead(IniFile, IniSection, "RecordMouse", true)
    ToolCheckInfo.RecordJoy := IniRead(IniFile, IniSection, "RecordJoy", false)
    ToolCheckInfo.RecordMouseRelative := IniRead(IniFile, IniSection, "RecordMouseRelative", false)
    ToolCheckInfo.RecordMouseTrail := IniRead(IniFile, IniSection, "RecordMouseTrail", false)
    ToolCheckInfo.RecordMouseTrailLen := IniRead(IniFile, IniSection, "RecordMouseTrailLen", 100)
    ToolCheckInfo.RecordMouseTrailSpeed := IniRead(IniFile, IniSection, "RecordMouseTrailSpeed", 95)
    ToolCheckInfo.RecordHoldMuti := IniRead(IniFile, IniSection, "RecordHoldMuti", false)
    ToolCheckInfo.RecordAutoLoosen := IniRead(IniFile, IniSection, "RecordAutoLoosen", true)
    ToolCheckInfo.RecordMouseTrailInterval := IniRead(IniFile, IniSection, "MouseTrailInterval", 300)
    ToolCheckInfo.RecordJoyInterval := IniRead(IniFile, IniSection, "RecordJoyInterval", 50)
    ToolCheckInfo.OCRTypeValue := IniRead(IniFile, IniSection, "OCRType", 1)
    MySoftData.IsExecuteShow := IniRead(IniFile, IniSection, "IsExecuteShow", true)
    MySoftData.IsBootStart := IniRead(IniFile, IniSection, "IsBootStart", false)
    MySoftData.MutiThreadNum := IniRead(IniFile, IniSection, "MutiThreadNum", 3)
    MySoftData.NoVariableTip := IniRead(IniFile, IniSection, "NoVariableTip", true)
    MySoftData.CMDTip := IniRead(IniFile, IniSection, "CMDTip", false)
    MySoftData.ScreenShotType := IniRead(IniFile, IniSection, "ScreenShotType", 1)
    MySoftData.AgreeAgreement := IniRead(IniFile, IniSection, "AgreeAgreement", false)
    MySoftData.WinPosX := IniRead(IniFile, IniSection, "WinPosX", 0)
    MySoftData.WinPosY := IniRead(IniFile, IniSection, "WinPosY", 0)
    MySoftData.TableIndex := IniRead(IniFile, IniSection, "TableIndex", 1)
    MySoftData.FontType := IniRead(IniFile, IniSection, "FontType", "微软雅黑")

    MySoftData.CMDPosX := IniRead(IniFile, IniSection, "CMDPosX", A_ScreenWidth - 225)
    MySoftData.CMDPosY := IniRead(IniFile, IniSection, "CMDPosY", 0)
    MySoftData.CMDWidth := IniRead(IniFile, IniSection, "CMDWidth", 225)
    MySoftData.CMDHeight := IniRead(IniFile, IniSection, "CMDHeight", 100)
    MySoftData.CMDLineNum := IniRead(IniFile, IniSection, "CMDLineNum", 5)
    MySoftData.CMDBGColor := IniRead(IniFile, IniSection, "CMDBGColor", "FFFFFF")
    MySoftData.CMDTransparency := IniRead(IniFile, IniSection, "CMDTransparency", 50)
    MySoftData.CMDFontColor := IniRead(IniFile, IniSection, "CMDFontColor", "000000")
    MySoftData.CMDFontSize := IniRead(IniFile, IniSection, "CMDFontSize", 12)

    MySoftData.TableInfo := CreateTableItemArr()
    SetFontList()
}

SetFontList() {
    MySoftData.FontList := []
    callback := CallbackCreate(EnumFontFamilies)
    DllCall("gdi32\EnumFontFamilies", "uint", DllCall("GetDC", "uint", 0), "uint", 0, "uint", callback, "ptr", 0)
    CallbackFree(callback)

    ; Font enumeration callback
    EnumFontFamilies(lpelf, lpntm, FontType, lP) {
        if (SubStr(StrGet(lpelf + 28), 1, 1) != "@")
            MySoftData.FontList.push(StrGet(lpelf + 28))
        return 1
    }
}

LoadCurMacroSetting() {
    loop MySoftData.TabNameArr.Length {
        ReadTableItemInfo(A_Index)
    }
}

ReadTableItemInfo(index) {
    global MySoftData
    symbol := GetTableSymbol(index)
    defaultInfo := GetTableItemDefaultInfo(index)
    savedTKArrStr := IniRead(MacroFile, IniSection, symbol "TKArr", "")
    savedModeArrStr := IniRead(MacroFile, IniSection, symbol "ModeArr", "")
    savedForbidArrStr := IniRead(MacroFile, IniSection, symbol "ForbidArr", "")
    savedProcessNameStr := IniRead(MacroFile, IniSection, symbol "ProcessNameArr", "")
    savedRemarkArrStr := IniRead(MacroFile, IniSection, symbol "RemarkArr", "")
    savedLoopCountStr := IniRead(MacroFile, IniSection, symbol "LoopCountArr", "")
    savedHoldTimeArrStr := IniRead(MacroFile, IniSection, symbol "HoldTimeArr", "")
    savedTriggerTypeArrStr := IniRead(MacroFile, IniSection, symbol "TriggerTypeArr", "")
    savedSerialStr := IniRead(MacroFile, IniSection, symbol "SerialArr", "")
    savedTimingSerialStr := IniRead(MacroFile, IniSection, symbol "TimingSerialArr", "")

    if (!MySoftData.HasSaved) {
        if (savedTKArrStr == "")
            savedTKArrStr := defaultInfo[1]
        if (savedHoldTimeArrStr == "")
            savedHoldTimeArrStr := defaultInfo[2]
        if (savedModeArrStr == "")
            savedModeArrStr := defaultInfo[3]
        if (savedForbidArrStr == "")
            savedForbidArrStr := defaultInfo[4]
        if (savedProcessNameStr == "")
            savedProcessNameStr := defaultInfo[5]
        if (savedRemarkArrStr == "")
            savedRemarkArrStr := defaultInfo[6]
        if (savedLoopCountStr == "")
            savedLoopCountStr := defaultInfo[7]
        if (savedTriggerTypeArrStr == "")
            savedTriggerTypeArrStr := defaultInfo[8]
        if (savedSerialStr == "")
            savedSerialStr := defaultInfo[9]
    }

    tableItem := MySoftData.TableInfo[index]
    SetArr(savedTKArrStr, "π", tableItem.TKArr)
    SetArr(savedModeArrStr, "π", tableItem.ModeArr)
    SetArr(savedForbidArrStr, "π", tableItem.ForbidArr)
    SetArr(savedProcessNameStr, "π", tableItem.ProcessNameArr)
    SetArr(savedRemarkArrStr, "π", tableItem.RemarkArr)
    SetIntArr(savedLoopCountStr, "π", tableItem.LoopCountArr)
    SetArr(savedHoldTimeArrStr, "π", tableItem.HoldTimeArr)
    SetArr(savedTriggerTypeArrStr, "π", tableItem.TriggerTypeArr)
    SetArr(savedSerialStr, "π", tableItem.SerialArr)
    SetArr(savedTimingSerialStr, "π", tableItem.TimingSerialArr)

    loop tableItem.ModeArr.length {
        str := IniRead(MacroFile, IniSection, symbol "MacroArr" A_Index, "")
        if (str == "" && !MySoftData.HasSaved && A_Index == 1)
            str := GetGetTableItemDefaultMacro(index)
        tableItem.MacroArr.Push(str)
    }
}

SetArr(str, symbol, Arr) {
    for index, value in StrSplit(str, symbol) {
        if (Arr.Length < index) {
            Arr.Push(value)
        }
        else {
            Arr[index] = value
        }
    }
}

SetIntArr(str, symbol, Arr) {
    for index, value in StrSplit(str, symbol) {
        curValue := value
        if (value == "")
            curValue := 1
        if (Arr.Length < index) {
            Arr.Push(Integer(curValue))
        }
        else {
            Arr[index] = Integer(curValue)
        }
    }
}

GetGetTableItemDefaultMacro(index) {
    symbol := GetTableSymbol(index)
    if (symbol == "Normal") {
        return "按键_a_30_1_30_50,间隔_3000"
    }
    else if (symbol == "String")
        return "按键_LButton_50,间隔_50,移动_100_100_90"
    else if (symbol == "SubMacro")
        return "按键_a_30_1_30_50,间隔_3000"
    else if (symbol == "Replace")
        return "Left,a"
    return ""
}

GetTableItemDefaultInfo(index) {
    savedTKArrStr := ""
    savedModeArrStr := ""
    savedForbidArrStr := ""
    savedProcessNameStr := ""
    savedRemarkArrStr := ""
    savedLoopCountStr := ""
    savedHoldTimeArrStr := ""
    savedTriggerTypeStr := ""
    savedSerialeArrStr := ""
    symbol := GetTableSymbol(index)

    if (symbol == "Normal") {
        savedTKArrStr := "k"
        savedHoldTimeArrStr := "500"
        savedModeArrStr := "0"
        savedForbidArrStr := "1"
        savedProcessNameStr := ""
        savedRemarkArrStr := "取消禁止配置才能生效"
        savedLoopCountStr := "1"
        savedTriggerTypeStr := "1"
        savedSerialeArrStr := "000001"
    }
    else if (symbol == "String") {
        savedTKArrStr := ":?*:AA"
        savedHoldTimeArrStr := "0"
        savedModeArrStr := "0"
        savedForbidArrStr := "1"
        savedProcessNameStr := ""
        savedRemarkArrStr := "按两次a触发"
        savedLoopCountStr := "1"
        savedTriggerTypeStr := "1"
        savedSerialeArrStr := "000002"
    }
    else if (symbol == "SubMacro") {
        savedTKArrStr := ""
        savedHoldTimeArrStr := "500"
        savedModeArrStr := "0"
        savedForbidArrStr := "1"
        savedProcessNameStr := ""
        savedRemarkArrStr := "插入时循环无效"
        savedLoopCountStr := "1"
        savedTriggerTypeStr := "1"
        savedSerialeArrStr := "000003"
    }
    else if (symbol == "Replace") {
        savedTKArrStr := "l"
        savedHoldTimeArrStr := "500"
        savedModeArrStr := "0"
        savedForbidArrStr := "1"
        savedProcessNameStr := ""
        savedTriggerTypeStr := "1"
        savedSerialeArrStr := "000004"
    }
    return [savedTKArrStr, savedHoldTimeArrStr, savedModeArrStr, savedForbidArrStr,
        savedProcessNameStr, savedRemarkArrStr,
        savedLoopCountStr, savedTriggerTypeStr, savedSerialeArrStr]
}

SaveTableItemInfo(index) {
    SavedInfo := GetSavedTableItemInfo(index)
    symbol := GetTableSymbol(index)
    IniWrite(SavedInfo[1], MacroFile, IniSection, symbol "TKArr")
    IniWrite(SavedInfo[2], MacroFile, IniSection, symbol "ModeArr")
    IniWrite(SavedInfo[3], MacroFile, IniSection, symbol "HoldTimeArr")
    IniWrite(SavedInfo[4], MacroFile, IniSection, symbol "ForbidArr")
    IniWrite(SavedInfo[5], MacroFile, IniSection, symbol "ProcessNameArr")
    IniWrite(SavedInfo[6], MacroFile, IniSection, symbol "RemarkArr")
    IniWrite(SavedInfo[7], MacroFile, IniSection, symbol "LoopCountArr")
    IniWrite(SavedInfo[8], MacroFile, IniSection, symbol "TriggerTypeArr")
    IniWrite(SavedInfo[9], MacroFile, IniSection, symbol "SerialArr")
    IniWrite(SavedInfo[10], MacroFile, IniSection, symbol "TimingSerialArr")
    SaveTableItemMacro(index)
}

SaveTableItemMacro(index) {
    tableItem := MySoftData.TableInfo[index]
    symbol := GetTableSymbol(index)
    loop tableItem.ModeArr.Length {
        MacroStr := tableItem.InfoConArr.Has(A_Index) ? tableItem.InfoConArr[A_Index].Value : ""
        MacroStr := Trim(MacroStr, "`n")
        MacroStr := Trim(MacroStr, ",")
        MacroStr := StrReplace(MacroStr, "`n", ",")
        IniWrite(MacroStr, MacroFile, IniSection, symbol "MacroArr" A_Index)
    }
}

GetSavedTableItemInfo(index) {
    Saved := MySoftData.MyGui.Submit()
    TKArrStr := ""
    MacroArrStr := ""
    ModeArrStr := ""
    HoldTimeArrStr := ""
    ForbidArrStr := ""
    ProcessNameArrStr := ""
    RemarkArrStr := ""
    LoopCountArrStr := ""
    TriggerTypeArrStr := ""
    SerialArrStr := ""
    TimingSerialArrStr := ""

    tableItem := MySoftData.TableInfo[index]
    symbol := GetTableSymbol(index)

    loop tableItem.ModeArr.Length {
        TKArrStr .= tableItem.TKConArr.Has(A_Index) ? tableItem.TKConArr[A_Index].Value : ""
        ModeArrStr .= tableItem.ModeConArr[A_Index].Value
        ForbidArrStr .= tableItem.ForbidConArr[A_Index].Value
        HoldTimeArrStr .= tableItem.HoldTimeArr[A_Index]
        ProcessNameArrStr .= tableItem.ProcessNameConArr[A_Index].Value
        RemarkArrStr .= tableItem.RemarkConArr.Length >= A_Index ? tableItem.RemarkConArr[A_Index].Value : ""
        TriggerTypeArrStr .= tableItem.TriggerTypeConArr.Length >= A_Index ? tableItem.TriggerTypeConArr[A_Index].Value :
            ""
        LoopCountArrStr .= GetItemSaveCountValue(tableItem.Index, A_Index)
        SerialArrStr .= tableItem.SerialArr.Length >= A_Index ? tableItem.SerialArr[A_Index] : "000000"
        TimingSerialArrStr .= tableItem.TimingSerialArr.Length >= A_Index ? tableItem.TimingSerialArr[A_Index] :
            "Timing000000"
        if (tableItem.ModeArr.Length > A_Index) {
            TKArrStr .= "π"
            ModeArrStr .= "π"
            HoldTimeArrStr .= "π"
            ForbidArrStr .= "π"
            ProcessNameArrStr .= "π"
            RemarkArrStr .= "π"
            LoopCountArrStr .= "π"
            TriggerTypeArrStr .= "π"
            SerialArrStr .= "π"
            TimingSerialArrStr .= "π"
        }
    }

    return [TKArrStr, ModeArrStr, HoldTimeArrStr, ForbidArrStr, ProcessNameArrStr, RemarkArrStr,
        LoopCountArrStr, TriggerTypeArrStr, SerialArrStr, TimingSerialArrStr]
}

;Table信息相关
CreateTableItemArr() {
    Arr := []
    loop MySoftData.TabNameArr.Length {
        newTableItem := TableItem()
        newTableItem.Index := A_Index
        if (Arr.Length < A_Index) {
            Arr.Push(newTableItem)
        }
        else {
            Arr[A_Index] := newTableItem
        }
    }
    return Arr
}

InitTableItemState() {
    loop MySoftData.TabNameArr.Length {
        tableItem := MySoftData.TableInfo[A_Index]
        InitSingleTableState(tableItem)
    }

    tableItem := MySoftData.SpecialTableItem
    tableItem.ModeArr := [0]
    InitSingleTableState(tableItem)
}

InitSingleTableState(tableItem) {
    tableItem.CmdActionArr := []
    tableItem.KilledArr := []
    tableItem.ActionCount := []
    tableItem.SuccessClearActionArr := []
    tableItem.HoldKeyArr := []
    tableItem.ToggleStateArr := []
    tableItem.ToggleActionArr := []
    tableItem.VariableMapArr := []
    tableItem.IsWorkArr := []
    for index, value in tableItem.ModeArr {
        tableItem.KilledArr.Push(false)
        tableItem.CmdActionArr.Push([])
        tableItem.ActionCount.Push(0)
        tableItem.SuccessClearActionArr.Push(Map())
        tableItem.HoldKeyArr.Push(Map())
        tableItem.ToggleStateArr.Push(false)
        tableItem.ToggleActionArr.Push("")
        tableItem.IsWorkArr.Push(false)

        VariableMap := Map()
        VariableMap["当前循环次数"] := 0
        tableItem.VariableMapArr.Push(VariableMap)
    }
}

KillSingleTableMacro(tableItem) {
    for index, value in tableItem.ModeArr {
        KillTableItemMacro(tableItem, index)
    }
}

KillTableItemMacro(tableItem, index) {
    if (tableItem.KilledArr.Length < index)
        return
    tableItem.KilledArr[index] := true

    for key, value in tableItem.HoldKeyArr[index] {
        if (value == "Game") {
            SendGameModeKey(key, 0, tableItem, index)
        }
        else if (value == "Normal") {
            SendNormalKey(key, 0, tableItem, index)
        }
        else if (value == "Joy") {
            SendJoyBtnKey(key, 0, tableItem, index)
        }
        else if (value == "JoyAxis") {
            SendJoyAxisKey(key, 0, tableItem, index)
        }
        else if (value == "GameMouse") {
            SendGameMouseKey(key, 0, tableItem, index)
        }
    }

    loop tableItem.CmdActionArr[index].Length {
        action := tableItem.CmdActionArr[index][A_Index]
        SetTimer action, 0
    }
    tableItem.CmdActionArr[index] := []

    for key, value in tableItem.SuccessClearActionArr[index] {
        loop value.Length {
            action := value[A_Index]
            SetTimer action, 0
        }
    }
    tableItem.SuccessClearActionArr[index] := Map()

    ; 如果是开关型按键宏，重置其开关状态
    if (tableItem.TriggerTypeArr.Length >= index && tableItem.TriggerTypeArr[index] == 4) {
        if (tableItem.ToggleStateArr.Length >= index)
            tableItem.ToggleStateArr[index] := false
    }
}

GetTabHeight() {
    maxY := 0
    loop MySoftData.TabNameArr.Length {
        posY := MySoftData.TableInfo[A_Index].UnderPosY
        if (posY > maxY)
            maxY := posY
    }

    height := maxY - MySoftData.TabPosY
    return height
    ; return Max(height, 500)
}

UpdateUnderPosY(tableIndex, value) {
    table := MySoftData.TableInfo[tableIndex]
    table.UnderPosY += value
}

GetTableSymbol(index) {
    return MySoftData.TabSymbolArr[index]
}

GetItemSaveCountValue(tableIndex, Index) {
    itemtable := MySoftData.TableInfo[tableIndex]
    if (itemtable.LoopCountConArr.Length >= Index) {
        value := itemtable.LoopCountConArr[Index].Text
        if (value == "无限")
            return -1
        if (IsInteger(value)) {
            if (Integer(value) < 0)
                return -1
            else
                return value
        }
    }
    return 1
}

GetRecordMacroEditStr(macro) {
    CommandArr := SplitMacro(macro)
    macroEditStr := ""
    processedIndex := 0
    for index, value in CommandArr {
        if (processedIndex >= index)
            continue
        processedIndex := index
        isInterval := StrCompare(SubStr(value, 1, 2), "间隔", false) == 0
        if (isInterval) {
            SubCommandArr := StrSplit(value, "_")
            intervalValue := Integer(SubCommandArr[2])
            loop {
                curIndex := index + A_Index
                if (curIndex > CommandArr.Length)
                    break

                SubCommandArr := StrSplit(CommandArr[curIndex], "_")
                isIntervalAgain := StrCompare(SubStr(SubCommandArr[1], 1, 2), "间隔", false) == 0
                if (!isIntervalAgain)
                    break
                intervalValue += Integer(SubCommandArr[2])
                processedIndex := curIndex
            }
            macroEditStr := index == 1 ? macroEditStr : macroEditStr ","
            macroEditStr .= "间隔_" intervalValue "`n"
            continue
        }

        isPressKey := StrCompare(SubStr(value, 1, 2), "按键", false) == 0
        if (isPressKey) {
            macroEditStr .= value
            loop {
                curIndex := index + A_Index
                if (curIndex > CommandArr.Length)
                    break

                SubCommandArr := StrSplit(CommandArr[curIndex], "_")
                isPressKeyAgain := StrCompare(SubStr(SubCommandArr[1], 1, 2), "按键", false) == 0
                if (!isPressKeyAgain)
                    break
                macroEditStr .= "," CommandArr[curIndex]
                processedIndex := curIndex
            }
        }

        isMouseMove := StrCompare(SubStr(value, 1, 2), "移动", false) == 0
        if (isMouseMove) {
            macroEditStr .= value
        }

        nextIndex := processedIndex + 1
        isNextInterval := nextIndex <= CommandArr.Length
        isNextInterval := isNextInterval && StrCompare(SubStr(CommandArr[nextIndex], 1, 2), "间隔", false) == 0
        if (!isNextInterval) {
            macroEditStr .= "`n"
        }
    }
    return macroEditStr
}

GetTimingTableIndex() {
    loop MySoftData.TabNameArr.Length {
        symbol := GetTableSymbol(A_Index)
        if (symbol == "Timing")
            return A_Index
    }
    return ""
}

CheckIsNormalTable(index) {
    symbol := GetTableSymbol(index)
    if (symbol == "Normal")
        return true
    return false
}

CheckIsMacroTable(index) {
    symbol := GetTableSymbol(index)
    if (symbol == "Normal")
        return true
    if (symbol == "String")
        return true
    if (symbol == "SubMacro")
        return true
    if (symbol == "Timing")
        return true
    return false
}

CheckIfAddSetTable(index) {
    symbol := GetTableSymbol(index)
    if (symbol == "Normal")
        return true
    if (symbol == "String")
        return true
    if (symbol == "Timing")
        return true
    if (symbol == "SubMacro")
        return true
    if (symbol == "Replace")
        return true
    return false
}

CheckIsStringMacroTable(index) {
    symbol := GetTableSymbol(index)
    if (symbol == "String")
        return true
    return false
}

CheckIsTimingMacroTable(index) {
    symbol := GetTableSymbol(index)
    if (symbol == "Timing")
        return true
    return false
}

CheckIsNoTriggerKey(index) {
    symbol := GetTableSymbol(index)
    if (symbol == "SubMacro")
        return true
    if (symbol == "Timing")
        return true
    return false
}

CheckIsSubMacroTable(index) {
    symbol := GetTableSymbol(index)
    if (symbol == "SubMacro")
        return true
    return false
}

CheckIsHotKey(key) {
    if (SubStr(key, 1, 1) == ":")
        return false

    if (SubStr(key, 1, 3) == "Joy")
        return false

    if (SubStr(key, 1, 7) == "XButton")
        return false

    if (SubStr(key, 1, 5) == "Wheel")
        return false

    if (MySoftData.SpecialKeyMap.Has(key))
        return false

    return true
}

GetHotKeyCtrlType(key) {
    isHotKey := CheckIsHotKey(key)
    CtrlType := isHotKey ? "Hotkey" : "Text"
    return CtrlType
}

CheckIfInstallVjoy() {
    vJoyFolder := RegRead(
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{8E31F76F-74C3-47F1-9550-E041EEDC5FBB}_is1",
        "InstallLocation", "")
    if (!vJoyFolder)
        return false
    return true
}

CheckAutoStart() {
    regPath := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
    try {
        ; 尝试读取注册表项
        RegRead(regPath, "ButtonAssist")
        return true
    } catch {
        return false
    }
}

CheckContainText(source, text) {
    ; 返回布尔值：true 表示包含，false 表示不包含
    return RegExMatch(source, text)
}

GetScreenTextObjArr(X1, Y1, X2, Y2, mode) {
    global MyChineseOcr, MyEnglishOcr
    width := X2 - X1
    height := Y2 - Y1
    pBitmap := Gdip_BitmapFromScreen(X1 "|" Y1 "|" width "|" height)

    ; 获取位图的宽度和高度
    Width := Gdip_GetImageWidth(pBitmap)
    Height := Gdip_GetImageHeight(pBitmap)

    ; 锁定位图以获取位图数据
    Gdip_LockBits(pBitmap, 0, 0, Width, Height, &Stride, &Scan0, &BitmapData)

    if (A_PtrSize == 8) {
        ; 64位系统结构
        BITMAP_DATA := Buffer(24)  ; 64位下结构总大小为24字节
        NumPut("ptr", Scan0, BITMAP_DATA, 0)   ; bits (8字节)
        NumPut("uint", Stride, BITMAP_DATA, 8)  ; pitch (4字节)
        NumPut("int", Width, BITMAP_DATA, 12)   ; width (4字节)
        NumPut("int", Height, BITMAP_DATA, 16)  ; height (4字节)
        NumPut("int", 4, BITMAP_DATA, 20)      ; bytespixel (4字节)
    } else {
        ; 32位系统结构
        BITMAP_DATA := Buffer(20)  ; 32位下结构总大小为20字节
        NumPut("ptr", Scan0, BITMAP_DATA, 0)   ; bits (4字节)
        NumPut("uint", Stride, BITMAP_DATA, 4)  ; pitch (4字节)
        NumPut("int", Width, BITMAP_DATA, 8)    ; width (4字节)
        NumPut("int", Height, BITMAP_DATA, 12)  ; height (4字节)
        NumPut("int", 4, BITMAP_DATA, 16)       ; bytespixel (4字节)
    }

    ; 调用 ocr_from_bitmapdata 方法
    ocr := mode == 1 ? MyChineseOcr : MyEnglishOcr
    result := ocr.ocr_from_bitmapdata(BITMAP_DATA, , true)

    ; 解锁位图
    Gdip_UnlockBits(pBitmap, &BitmapData)
    ; 释放位图
    Gdip_DisposeImage(pBitmap)
    return result
}

CheckScreenContainText(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, text, mode) {
    result := GetScreenTextObjArr(X1, Y1, X2, Y2, mode)
    if (result == "" || !result)
        return false
    for index, value in result {
        isContain := CheckContainText(value.text, text)
        if (isContain) {
            pos := GetMatchCoord(value, X1, Y1)
            OutputVarX := pos[1]
            OutputVarY := pos[2]
            break
        }
    }
    return isContain
}

GetMatchCoord(screenTextObj, x1, y1) {
    value := screenTextObj
    pointX := value.boxPoint[1].x + value.boxPoint[2].x + value.boxPoint[3].x + value.boxPoint[4].x
    pointY := value.boxPoint[1].y + value.boxPoint[2].y + value.boxPoint[3].y + value.boxPoint[4].y
    OutputVarX := x1 + pointX / 4
    OutputVarY := y1 + pointY / 4
    return [OutputVarX, OutputVarY]
}

IsClipboardText() {
    ; 检查是否存在文本格式
    if DllCall("IsClipboardFormatAvailable", "UInt", 1)  ; CF_TEXT = 1
        return true
    if DllCall("IsClipboardFormatAvailable", "UInt", 13) ; CF_UNICODETEXT = 13
        return true
    return false
}

;没必要删除
ClearUselessSetting(deleteMacro) {
    if (deleteMacro == "")
        return
    RegExMatch(deleteMacro, "(Compare\d+)", &match)
    match := match != "" ? match : []
    for id, value in match {
        if (value == "")
            continue
        IniDelete(CompareFile, IniSection, value)
    }

    RegExMatch(deleteMacro, "(Coord\d+)", &match)
    match := match != "" ? match : []
    for id, value in match {
        if (value == "")
            continue
        IniDelete(MMPROFile, IniSection, value)
    }
}

LoosenModifyKey(keyCombo) {
    modifiers := []
    modPrefixes := ["^", "<^", ">^", "!", "<!", ">!", "+", "<+", ">+", "#", "<#", ">#"]
    ; 检查是否以修饰键开头
    for prefix in modPrefixes {
        if (SubStr(keyCombo, 1, StrLen(prefix)) == prefix) {
            modifiers.Push(prefix)
            keyCombo := SubStr(keyCombo, StrLen(prefix) + 1)
            break
        }
    }

    ; 检查所有修饰键是否按下
    for mod in modifiers {
        key := ""
        switch mod {
            case "^":
                key := "Ctrl"
            case "<^":
                key := "LCtrl"
            case ">^":
                key := "RCtrl"
            case "!":
                key := "Alt"
            case "<!":
                key := "LAlt"
            case ">!":
                key := "RAlt"
            case "+":
                key := "Shift"
            case "<+":
                key := "LShift"
            case ">+":
                key := "RShift"
            case "#":
                key := "Win"
            case "<#":
                key := "LWin"
            case ">#":
                key := "RWin"
        }
        if (key != "") {
            VK := GetKeyVK(key)
            SC := GetKeySC(key)
            DllCall("keybd_event", "UChar", VK, "UChar", SC, "UInt", 0x2, "UPtr", 0)
        }
    }

}

AreKeysPressed(keyCombo) {
    ; 初始化存储修饰键的数组
    modifiers := []
    modPrefixes := ["^", "<^", ">^", "!", "<!", ">!", "+", "<+", ">+", "#", "<#", ">#"]
    ; 检查是否以修饰键开头
    for prefix in modPrefixes {
        if (SubStr(keyCombo, 1, StrLen(prefix)) == prefix) {
            modifiers.Push(prefix)
            keyCombo := SubStr(keyCombo, StrLen(prefix) + 1)
            break
        }
    }
    ; 剩余部分是主键
    mainKey := keyCombo

    ; 检查所有修饰键是否按下
    for mod in modifiers {
        switch mod {
            case "^": if (!GetKeyState("Ctrl"))
                return false
            case "<^": if !GetKeyState("LCtrl")
                return false
            case ">^": if !GetKeyState("RCtrl")
                return false

            case "!": if !(GetKeyState("Alt"))
                return false
            case "<!": if !GetKeyState("LAlt")
                return false
            case ">!": if !GetKeyState("RAlt")
                return false
            case "+": if !(GetKeyState("Shift"))
                return false
            case "<+": if !GetKeyState("LShift")
                return false
            case ">+": if !GetKeyState("RShift")
                return false
            case "#": if !(GetKeyState("Win"))
                return false
            case "<#": if !GetKeyState("LWin")
                return false
            case ">#": if !GetKeyState("RWin")
                return false

            default: return false  ; 未知修饰键
        }
    }

    isJoyKey := RegExMatch(mainKey, "Joy")
    if (mainKey == "") {
        return true
    }
    if (isJoyKey) {
        isJoyAxis := RegExMatch(mainKey, "Min") || RegExMatch(mainKey, "Max")
        joyName := isJoyAxis ? SubStr(mainKey, 1, 4) : mainKey

        loop 4 {
            state := GetKeyState(A_Index joyName)
            if (state)
                return true
        }
    }
    else if (GetKeyState(mainKey, "P")) {  ; 检查主键（如果有）
        return true
    }

    return false
}

GetSelectVariableObjArr(macro) {
    VariableMap := Map()
    cmdArr := SplitMacro(macro)
    loop cmdArr.Length {
        paramArr := StrSplit(cmdArr[A_Index], "_")
        IsVariable := StrCompare(paramArr[1], "变量", false) == 0
        IsExVariable := StrCompare(paramArr[1], "变量提取", false) == 0
        IsSearchPro := StrCompare(paramArr[1], "搜索Pro", false) == 0
        IsOperation := StrCompare(paramArr[1], "运算", false) == 0
        IsIf := StrCompare(paramArr[1], "如果", false) == 0
        IsSubMacro := StrCompare(paramArr[1], "宏操作", false) == 0
        if (!IsVariable && !IsExVariable && !IsSearchPro && !IsOperation && !IsIf && !IsSubMacro)
            continue

        if (IsVariable) {
            saveStr := IniRead(VariableFile, IniSection, paramArr[2], "")
            Data := JSON.parse(saveStr, , false)
            loop 4 {
                if (Data.ToggleArr[A_Index])
                    VariableMap[Data.VariableArr[A_Index]] := true
            }
        }
        else if (IsExVariable) {
            saveStr := IniRead(ExVariableFile, IniSection, paramArr[2], "")
            Data := JSON.parse(saveStr, , false)
            loop 4 {
                if (Data.ToggleArr[A_Index])
                    VariableMap[Data.VariableArr[A_Index]] := true
            }
        }
        else if (IsSearchPro) {
            saveStr := IniRead(SearchProFile, IniSection, paramArr[2], "")
            Data := JSON.parse(saveStr, , false)
            if (Data.ResultToggle)
                VariableMap[Data.ResultSaveName] := true

            if (Data.CoordToogle) {
                VariableMap[Data.CoordXName] := true
                VariableMap[Data.CoordYName] := true
            }
        }
        else if (IsOperation) {
            saveStr := IniRead(OperationFile, IniSection, paramArr[2], "")
            Data := JSON.parse(saveStr, , false)
            loop 4 {
                if (Data.ToggleArr[A_Index])
                    VariableMap[Data.UpdateNameArr[A_Index]] := true
            }
        }
        else if (IsIf) {
            saveStr := IniRead(CompareFile, IniSection, paramArr[2], "")
            Data := JSON.parse(saveStr, , false)
            if (Data.SaveToggle) {
                VariableMap[Data.SaveName] := true
            }
        }
        else if (IsSubMacro) {
            saveStr := IniRead(SubMacroFile, IniSection, paramArr[2], "")
            Data := JSON.parse(saveStr, , false)
            if (Data.CallType == 1) {
                macro := ""
                if (Data.Type == 2) {
                    macroItem := MySoftData.TableInfo[1]
                    macro := macroItem.MacroArr[Data.Index]
                }
                else if (Data.Type == 3) {
                    macroItem := MySoftData.TableInfo[2]
                    macro := macroItem.MacroArr[Data.Index]
                }
                else if (Data.Type == 4) {
                    macroItem := MySoftData.TableInfo[3]
                    macro := macroItem.MacroArr[Data.Index]
                }

                if (macro != "") {
                    Arr := GetSelectVariableObjArr(macro)
                    loop arr.Length {
                        VariableMap[Arr[A_Index]] := true
                    }
                }
            }
        }
    }

    VariableArr := []
    for key in VariableMap {
        VariableArr.Push(key)
    }
    VariableArr.Push("当前循环次数")
    return VariableArr
}

GetOperationResult(BaseValue, SymbolArr, ValueArr) {
    sum := baseValue
    for index, Symbol in SymbolArr {
        if (Symbol == "+")
            sum += Number(ValueArr[index])
        if (Symbol == "-")
            sum -= Number(ValueArr[index])
        if (Symbol == "*")
            sum *= Number(ValueArr[index])
        if (Symbol == "/")
            sum /= Number(ValueArr[index])
        if (Symbol == "^")
            sum := sum ** Number(ValueArr[index])
        if (Symbol == "..")
            sum .= ValueArr[index]
    }
    return sum
}

GetVariableOperationResult(tableItem, tableIndex, Name, SymbolArr, ValueArr) {
    hasValue := TryGetVariableValue(&sum, tableItem, tableIndex, Name)
    if (!hasValue)
        return

    for index, Symbol in SymbolArr {
        Variable := ValueArr[index]
        hasValue := TryGetVariableValue(&Value, tableItem, tableIndex, Variable)
        if (!hasValue)
            return

        if (Symbol == "+")
            sum += Value
        if (Symbol == "-")
            sum -= Value
        if (Symbol == "*")
            sum *= Value
        if (Symbol == "/")
            sum /= Value
        if (Symbol == "^")
            sum := sum ** Value
        if (Symbol == "..")
            sum .= Value
    }
    return sum
}

StrToHex(str) {
    hex := ""
    loop parse str {
        hex .= Format("{:02X}", Ord(A_LoopField))
    }
    return hex
}

GetWinPos() {
    DllCall("SetProcessDPIAware")
    CoordMode("Mouse", "Screen")
    MouseGetPos &mouseX, &mouseY

    ; 获取鼠标下窗口句柄
    winId := DllCall("User32\WindowFromPoint", "int64", (mouseY << 32) | (mouseX & 0xFFFFFFFF), "ptr")

    ; 获取该窗口的主窗口（避免偏移）
    GA_ROOT := 2
    rootHwnd := DllCall("GetAncestor", "ptr", winId, "uint", GA_ROOT, "ptr")

    ; 创建结构体 POINT
    pt := Buffer(8, 0)
    NumPut("int", mouseX, pt, 0)  ; X
    NumPut("int", mouseY, pt, 4)  ; Y

    ; 屏幕坐标转客户区
    DllCall("User32\ScreenToClient", "ptr", rootHwnd, "ptr", pt)

    xClient := NumGet(pt, 0, "int")
    yClient := NumGet(pt, 4, "int")
    return [xClient, yClient]
}

GetMacroCMDData(fileName, serialStr) {
    global MySoftData
    if (MySoftData.DataCacheMap.Has(serialStr)) {
        return MySoftData.DataCacheMap[serialStr]
    }

    saveStr := IniRead(fileName, IniSection, serialStr, "")
    Data := JSON.parse(saveStr, , false)
    MySoftData.DataCacheMap.Set(serialStr, Data)
    return Data
}

TryGetVariableValue(&Value, tableItem, index, variableName, variTip := true) {
    if (IsNumber(variableName)) {
        Value := variableName
        return true
    }

    if (variableName == "当前鼠标坐标X" || variableName == "当前鼠标坐标Y") {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        Value := variableName == "当前鼠标坐标X" ? mouseX : mouseY
        return true
    }

    TableVariableMap := tableItem.VariableMapArr[index]
    if (TableVariableMap.Has(variableName)) {
        Value := TableVariableMap[variableName]
        return true
    }

    GlobalVariableMap := MySoftData.VariableMap
    if (GlobalVariableMap.Has(variableName)) {
        Value := GlobalVariableMap[variableName]
        return true
    }

    if (variTip)
        ShowNoVariableTip(variableName)
    return false
}

ShowNoVariableTip(variableName) {
    if (MySoftData.NoVariableTip)
        MsgBox("当前环境不存在变量 " variableName)
}

GetSerialStr(CmdStr) {
    currentDateTime := FormatTime(, "HHmmss")
    randomNum := Random(0, 9)
    return CmdStr CurrentDateTime randomNum
}
