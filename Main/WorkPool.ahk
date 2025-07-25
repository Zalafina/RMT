#Requires AutoHotkey v2.0
class WorkPool {
    __New() {
        this.maxSize := MySoftData.MutiThread ? MySoftData.MutiThreadNum : 0
        this.pool := []              ; 对象池数组
        this.hwndMap := Map()
        this.pidMap := Map()
        loop this.maxSize {
            workPath := A_ScriptDir "\Thread\Work" A_Index ".exe"
            Run (Format("{} {} {}", workPath, MySoftData.MyGui.Hwnd, A_Index))
        }
        OnMessage(WM_LOAD_WORK, this.OnFinishLoad.Bind(this))  ; 工作器完成工作回调
        OnMessage(WM_RELEASE_WORK, this.OnRelease.Bind(this))  ; 工作器完成工作回调
        OnMessage(WM_STOP_MACRO, this.OnStopMacro.Bind(this))  ;终止其他宏
        OnMessage(WM_TR_MACRO, this.OnTriggerMacro.Bind(this)) ;触发宏
        OnMessage(WM_COPYDATA, this.OnGetCmd.Bind(this)) ;接收到命令
    }

    __Delete() {
        this.Clear()
    }

    CheckHasWork() {
        return this.pool.Length >= 1
    }

    ; 从池中获取一个对象
    Get() {
        workPath := ""
        if (this.pool.Length >= 1) {
            workPath := this.pool.Pop()
        }
        return workPath
    }

    GetWorkPath(workIndex) {
        return A_ScriptDir "\Thread\Work" workIndex ".exe"
    }

    GetWorkIndex(workPath) {
        workIndex := StrReplace(workPath, A_ScriptDir "\Thread\Work")
        workIndex := StrReplace(workIndex, ".exe")
        return workIndex
    }

    GetWorkHwnd(workPath) {
        if (!this.hwndMap.Has(workPath)) {
            workIndex := StrReplace(workPath, A_ScriptDir "\Thread\Work")
            workIndex := StrReplace(workIndex, ".exe")
            try {
                hwnd := WinGetID("RMTWork" workIndex)
                this.hwndMap.Set(workPath, hwnd)
            }
        }
        return this.hwndMap.Get(workPath, 0)
    }

    ; 清空对象池
    Clear() {
        loop this.maxSize {
            workPath := A_ScriptDir "\Thread\Work" A_Index ".exe"
            this.PostMessage(WM_CLEAR_WORK, workPath, 0, 0)
        }
        this.pool := []
    }

    PostMessage(type, workPath, wParam, lParam) {
        hwnd := this.GetWorkHwnd(workPath)
        try {
            PostMessage(type, wParam, lParam, , "ahk_id " hwnd)
        }
        catch {
            MsgBox("error")
        }
    }

    SendMessage(type, workPath, str) {
        CopyDataStruct := Buffer(3 * A_PtrSize)  ; 分配结构的内存区域.
        ; 首先设置结构的 cbData 成员为字符串的大小, 包括它的零终止符:
        SizeInBytes := (StrLen(str) + 1) * 2
        NumPut("Ptr", SizeInBytes  ; 操作系统要求这个需要完成.
            , "Ptr", StrPtr(str)  ; 设置 lpData 为到字符串自身的指针.
            , CopyDataStruct, A_PtrSize)
        hwnd := this.GetWorkHwnd(workPath)
        try {
            SendMessage(type, 0, CopyDataStruct, , "ahk_id " hwnd)
        }
    }

    OnRelease(wParam, lParam, msg, hwnd) {
        tableIndex := wParam
        itemIndex := lParam
        tableItem := MySoftData.TableInfo[tableIndex]
        workIndex := tableItem.IsWorkArr[itemIndex]
        workPath := A_ScriptDir "\Thread\Work" workIndex ".exe"
        this.pool.Push(workPath)
        tableItem.IsWorkArr[itemIndex] := false
    }

    OnFinishLoad(wParam, lParam, msg, hwnd) {
        workPath := A_ScriptDir "\Thread\Work" wParam ".exe"
        this.pool.Push(workPath)
    }

    OnStopMacro(wParam, lParam, msg, hwnd) {
        tableIndex := wParam
        itemIndex := lParam
        tableItem := MySoftData.TableInfo[tableIndex]
        isWork := tableItem.IsWorkArr[itemIndex]
        if (isWork) {
            workPath := MyWorkPool.GetWorkPath(tableItem.IsWorkArr[itemIndex])
            MyWorkPool.PostMessage(WM_STOP_MACRO, workPath, 0, 0)
            return
        }

        KillTableItemMacro(tableItem, itemIndex)
    }

    OnTriggerMacro(wParam, lParam, msg, hwnd) {
        TriggerSubMacro(wParam, lParam)
    }

    OnGetCmd(wParam, lParam, msg, hwnd) {
        StringAddress := NumGet(lParam, 2 * A_PtrSize, "Ptr")  ; 检索 CopyDataStruct 的 lpData 成员.
        Cmd := StrGet(StringAddress)  ; 从结构中复制字符串.
        paramArr := StrSplit(cmd, "_")
        isSetVari := StrCompare(paramArr[1], "SetVari", false) == 0
        isDelVari := StrCompare(paramArr[1], "DelVari", false) == 0
        if (isSetVari) {
            SetGlobalVariable(paramArr[2], paramArr[3], false)
        }
        else if (isDelVari) {
            DelGlobalVariable(paramArr[2])
        }
    }
}
