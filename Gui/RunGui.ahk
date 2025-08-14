#Requires AutoHotkey v2.0

class RunGui {
    __new() {
        this.Gui := ""
        this.RemarkCon := ""
        this.SureBtnAction := ""
        this.PathTextCon := ""
        this.MouseProNameCon := ""
        this.BackPlayCon := ""

        this.RefreshAction := () => this.RefreshProcessName()
        this.Data := ""
    }

    ShowGui(cmd) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }

        this.Init(cmd)
        this.ToggleFunc(true)
    }

    AddGui() {
        MyGui := Gui(, "运行指令编辑")
        this.Gui := MyGui
        MyGui.SetFont("S10 W550 Q2", MySoftData.FontType)

        PosX := 10
        PosY := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "快捷方式:")
        PosX += 80
        con := MyGui.Add("Hotkey", Format("x{} y{} w{}", PosX, PosY - 3, 70), "!l")
        con.Enabled := false

        PosX += 90
        btnCon := MyGui.Add("Button", Format("x{} y{} w{}", PosX, PosY - 5, 80), "执行指令")
        btnCon.OnEvent("Click", (*) => this.TriggerMacro())

        PosX += 90
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 50), "备注:")
        PosX += 50
        this.RemarkCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 5, 150), "")

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 400), "F1:确定鼠标下进程")

        PosX := 10
        PosY += 20
        this.MouseProNameCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 380, 20), "鼠标下进程名:Zone.exe")

        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "路径：")
        
        PosX += 40
        this.PathTextCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 3, 350))

        PosX += 355
        btnCon := MyGui.Add("Button", Format("x{} y{}", PosX, PosY - 5), "选择文件")
        btnCon.OnEvent("Click", (*) => this.OnClickFileSelectBtn())
        
        PosY += 25
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} h{}", PosX, PosY, 20), "支持类别：进程、网址、文件等等")

        PosY += 25
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} h{}", PosX, PosY, 20), "支持文件后缀：进程名、网址、exe、txt、bat、mp4、vbs、mp3等等")

        PosX := 10
        PosY += 25
        this.BackPlayCon := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 400), "后台播放mp3文件")

        PosY += 45
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 400, 20), "路径是进程时：该进程务必属于系统软件，或者有系统变量环境")

        PosY += 25
        PosX := 200
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 500, 285))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : GetSerialStr("Run")
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        this.Data := this.GetRunData(this.SerialStr)

        this.PathTextCon.Value := this.Data.RunPath
        this.BackPlayCon.Value := this.Data.BackPlay
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "运行_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }
        return CommandStr
    }

    ToggleFunc(state) {
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            SetTimer this.RefreshAction, 100
            Hotkey("!l", MacroAction, "On")
            Hotkey("F1", (*) => this.SureProcessName(), "On")
        }
        else {
            SetTimer this.RefreshAction, 0
            Hotkey("!l", MacroAction, "Off")
            Hotkey("F1", (*) => this.SureProcessName(), "Off")
        }
    }

    RefreshProcessName() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY, &winId
        processName := WinGetProcessName(winId)
        this.MouseProNameCon.Value := Format("当前鼠标下进程名:{}", processName)
    }

    SureProcessName() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY, &winId
        processName := WinGetProcessName(winId)
    }

    OnClickFileSelectBtn() {
        fileString := FileSelect("S1", "", "选择要运行的文件")
        if (fileString == "")
            return

        this.PathTextCon.Value := fileString
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return
        this.SaveRunData()
        this.ToggleFunc(false)
        action := this.SureBtnAction
        action(this.GetCommandStr())
        this.Gui.Hide()
    }

    CheckIfValid() {
        if (this.PathTextCon.Value == "") {
            MsgBox("路径不能为空！")
            return false
        }
        return true
    }

    TriggerMacro() {
        this.SaveRunData()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.PauseArr[1] := 0
        tableItem.ActionCount[1] := 0
        tableItem.SuccessClearActionArr[1] := Map()
        tableItem.VariableMapArr[1] := Map()

        OnRunFile(tableItem, this.GetCommandStr(), 1)
    }

    GetRunData(SerialStr) {
        saveStr := IniRead(RunFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := FileData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    SaveRunData() {
        this.Data.RunPath := this.PathTextCon.Value
        this.Data.BackPlay := this.BackPlayCon.Value

        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, RunFile, IniSection, this.Data.SerialStr)
        if (MySoftData.DataCacheMap.Has(this.Data.SerialStr)) {
            MySoftData.DataCacheMap.Delete(this.Data.SerialStr)
        }
    }
}
