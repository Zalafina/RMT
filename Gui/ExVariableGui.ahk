#Requires AutoHotkey v2.0

#Requires AutoHotkey v2.0

class ExVariableGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.MacroEditGui := ""
        this.RemarkCon := ""
        this.SetAreaAction := (x1, y1, x2, y2) => this.OnSetSearchArea(x1, y1, x2, y2)

        this.IsGlobalCon := ""
        this.IsIgnoreExistCon := ""
        this.ToggleConArr := []
        this.VariableConArr := []
        this.SelectToggleCon := ""
        this.ExtractStrCon := ""
        this.ExtractTypeCon := ""
        this.StartPosXCon := ""
        this.StartPosYCon := ""
        this.EndPosXCon := ""
        this.EndPosYCon := ""
        this.SearchCountCon := ""
        this.SearchIntervalCon := ""
        this.OCRTypeCon := ""
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
        MyGui := Gui(, "变量创建指令编辑")
        this.Gui := MyGui
        MyGui.SetFont(, "Arial")
        MyGui.SetFont("S10 W550 Q2", "Consolas")

        PosX := 10
        PosY := 10
        this.FocusCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 80, 20), "快捷方式:")
        PosX += 80
        con := MyGui.Add("Hotkey", Format("x{} y{} w{} h{} Center", PosX, PosY - 3, 70, 20), "!l")
        con.Enabled := false

        PosX += 90
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 10, 80, 30), "执行指令")
        btnCon.OnEvent("Click", (*) => this.TriggerMacro())

        PosX += 90
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 50, 30), "备注:")
        PosX += 50
        this.RemarkCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 5, 150), "")

        PosY += 25
        PosX := 20
        con := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY, 25), "F1")
        con.Enabled := false

        PosX += 30
        this.SelectToggleCon := MyGui.Add("Checkbox", Format("x{} y{} w{} h{} Left", PosX, PosY, 150, 25),
        "左键框选搜索范围")
        this.SelectToggleCon.OnEvent("Click", (*) => this.OnClickSelectToggle())

        PosX += 200
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY + 3, 110), "文本识别模型:")
        PosX += 110
        this.OCRTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{} Center", PosX, PosY - 2, 130), ["中文",
            "英文"])
        this.OCRTypeCon.Value := 1

        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 550),
        "使用&&x代替数字变量位置，使用&&c代替文本变量位置`n形如：`"坐标(&&x,&&x)`"可以提取`"坐标(10.5,8.6)`"中的10.5和8.6到变量1和变量2")

        PosY += 45
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "提取文本：")
        this.ExtractStrCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX + 75, PosY - 5, 250), "")
        this.ExtractTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX + 345, PosY - 5, 80), ["屏幕",
            "剪切板"])
        this.ExtractTypeCon.Value := 1

        PosX := 20
        PosY += 30
        this.IsGlobalCon := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 90), "全局变量")

        PosX += 120
        this.IsIgnoreExistCon := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 150), "变量存在忽略操作")

        PosX := 20
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} h{}", PosX, PosY, 20), "  开关      变量名                    开关       变量名")

        PosX := 20
        PosY += 20
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY + 3), "1.")
        PosX += 20
        con := MyGui.Add("Checkbox", Format("x{} y{} w{} h{} Center", PosX, PosY, 30, 20), "")
        this.ToggleConArr.Push(con)

        PosX += 35
        con := MyGui.Add("ComboBox", Format("x{} y{} w{} R5 Center", PosX, PosY - 2, 100), [])
        this.VariableConArr.Push(con)

        PosX += 200
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY + 3), "2.")
        PosX += 20
        con := MyGui.Add("Checkbox", Format("x{} y{} w{} h{} Center", PosX, PosY, 30, 20), "")
        this.ToggleConArr.Push(con)

        PosX += 35
        con := MyGui.Add("ComboBox", Format("x{} y{} w{} R5 Center", PosX, PosY - 2, 100), [])
        this.VariableConArr.Push(con)

        PosX := 20
        PosY += 30
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY + 3), "3.")
        PosX += 20
        con := MyGui.Add("Checkbox", Format("x{} y{} w{} h{} Center", PosX, PosY, 30, 20), "")
        this.ToggleConArr.Push(con)

        PosX += 35
        con := MyGui.Add("ComboBox", Format("x{} y{} w{} R5 Center", PosX, PosY - 2, 100), [])
        this.VariableConArr.Push(con)

        PosX += 200
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY + 3), "4.")
        PosX += 20
        con := MyGui.Add("Checkbox", Format("x{} y{} w{} h{} Center", PosX, PosY, 30, 20), "")
        this.ToggleConArr.Push(con)

        PosX += 35
        con := MyGui.Add("ComboBox", Format("x{} y{} w{} R5 Center", PosX, PosY - 2, 100), [])
        this.VariableConArr.Push(con)

        PosX := 10
        PosY += 30
        MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", PosX, PosY, 310, 90), "搜索范围:")

        PosY += 30
        PosX := 20
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "起始坐标X:")
        PosX += 75
        this.StartPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))

        PosX := 180
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "起始坐标Y:")
        PosX += 75
        this.StartPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))

        PosX := 350
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "搜索次数:")
        PosX += 75
        this.SearchCountCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))

        PosY += 30
        PosX := 20
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "终止坐标X:")
        PosX += 75
        this.EndPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))

        PosX := 180
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "终止坐标Y:")
        PosX += 75
        this.EndPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))

        PosX := 350
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "每次间隔:")
        this.SearchIntervalCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 75, PosY - 5, 50))

        PosY += 40
        PosX := 250
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{} Center", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 600, 400))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : this.GetSerialStr()
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        this.Data := this.GetExVariableData(this.SerialStr)
        macro := this.MacroEditGui.GetFinallyMacroStr()
        VariableObjArr := GetSelectVariableObjArr(macro)

        loop 4 {
            this.ToggleConArr[A_Index].Value := this.Data.ToggleArr[A_Index]
            this.VariableConArr[A_Index].Delete()
            this.VariableConArr[A_Index].Add(VariableObjArr)
            this.VariableConArr[A_Index].Text := this.Data.VariableArr[A_Index]
        }
        this.IsGlobalCon.Value := this.Data.IsGlobal
        this.IsIgnoreExistCon.Value := this.Data.IsIgnoreExist
        this.ExtractStrCon.Value := this.Data.ExtractStr
        this.ExtractTypeCon.Value := this.Data.ExtractType
        this.OCRTypeCon.Value := this.Data.OCRType
        this.StartPosXCon.Value := this.Data.StartPosX
        this.StartPosYCon.Value := this.Data.StartPosY
        this.EndPosXCon.Value := this.Data.EndPosX
        this.EndPosYCon.Value := this.Data.EndPosY
        this.SearchCountCon.Value := this.Data.SearchCount
        this.SearchIntervalCon.Value := this.Data.SearchInterval
    }

    ToggleFunc(state) {
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            Hotkey("!l", MacroAction, "On")
            Hotkey("F1", (*) => this.OnF1(), "On")
        }
        else {
            Hotkey("!l", MacroAction, "Off")
            Hotkey("F1", (*) => this.OnF1(), "Off")
        }
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return
        this.SaveExVariableData()
        this.ToggleFunc(false)
        CommandStr := this.GetCommandStr()
        action := this.SureBtnAction
        action(CommandStr)
        this.Gui.Hide()
    }

    OnClickSelectToggle() {
        state := this.SelectToggleCon.Value
        if (state == 1)
            EnableSelectAerea(this.SetAreaAction)
        else
            DisSelectArea(this.SetAreaAction)
    }

    OnF1() {
        this.SelectToggleCon.Value := 1
        EnableSelectAerea(this.SetAreaAction)
    }

    OnSetSearchArea(x1, y1, x2, y2) {
        this.SelectToggleCon.Value := 0
        this.StartPosXCon.Value := x1
        this.StartPosYCon.Value := y1
        this.EndPosXCon.Value := x2
        this.EndPosYCon.Value := y2
    }

    CheckIfValid() {
        return true
    }

    TriggerMacro() {
        this.SaveExVariableData()
        CommandStr := this.GetCommandStr()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.SuccessClearActionArr[1] := Map()
        tableItem.VariableMapArr[1] := Map()

        ; OnVariable(tableItem, CommandStr, 1)
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "变量提取_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }
        return CommandStr
    }

    GetSerialStr() {
        CurrentDateTime := FormatTime(, "HHmmss")
        return "ExVariable" CurrentDateTime
    }

    GetExVariableData(SerialStr) {
        saveStr := IniRead(ExVariableFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := ExVariableData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    SaveExVariableData() {
        this.Data.ExtractStr := this.ExtractStrCon.Value
        this.Data.ExtractType := this.ExtractTypeCon.Value
        this.Data.OCRType := this.OCRTypeCon.Value
        this.Data.StartPosX := this.StartPosXCon.Value
        this.Data.StartPosY := this.StartPosYCon.Value
        this.Data.EndPosX := this.EndPosXCon.Value
        this.Data.EndPosY := this.EndPosYCon.Value
        this.Data.SearchCount := this.SearchCountCon.Value
        this.Data.SearchInterval := this.SearchIntervalCon.Value
        this.Data.IsGlobal := this.IsGlobalCon.Value
        this.Data.IsIgnoreExist := this.IsIgnoreExistCon.Value
        loop 4 {
            this.Data.ToggleArr[A_Index] := this.ToggleConArr[A_Index].Value
            this.Data.VariableArr[A_Index] := this.VariableConArr[A_Index].Text
        }

        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, ExVariableFile, IniSection, this.Data.SerialStr)
        if (MySoftData.DataCacheMap.Has(this.Data.SerialStr)) {
            MySoftData.DataCacheMap.Delete(this.Data.SerialStr)
        }
    }
}
