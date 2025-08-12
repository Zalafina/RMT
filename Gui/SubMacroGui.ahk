#Requires AutoHotkey v2.0

class SubMacroGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.RemarkCon := ""

        this.TypeCon := ""
        this.DropDownIndexCon := ""
        this.CallTypeCon := ""
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
        this.OnRefresh()
        this.ToggleFunc(true)
    }

    AddGui() {
        MyGui := Gui(, "宏操作指令编辑")
        this.Gui := MyGui
        MyGui.SetFont("S10 W550 Q2", MySoftData.FontType)

        PosX := 10
        PosY := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 80, 20), "快捷方式:")
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

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 70, 20), "宏类型:")

        PosX += 70
        this.TypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX, PosY - 5, 100), ["当前宏", "按键宏", "字串宏",
            "定时宏",
            "宏"])
        this.TypeCon.Value := 1
        this.TypeCon.OnEvent("Change", (*) => this.OnRefresh())

        PosX += 140
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 70, 20), "宏序号：")

        PosX += 65
        this.DropDownIndexCon := MyGui.Add("DropDownList", Format("x{} y{} w{} R5", PosX, PosY - 5, 185), [])

        PosX := 10
        PosY += 40
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 70, 20), "调用方式:")

        PosX += 70
        this.CallTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{}", PosX, PosY - 5, 100), ["插入", "触发", "终止"])
        this.CallTypeCon.Value := 1

        PosX := 10
        PosY += 25
        MyGui.Add("Text", Format("x{} y{} h{}", PosX, PosY, 20), "插入:插入到当前执行的宏中，该宏的变量操作都是依赖于当前宏环境")

        PosX := 10
        PosY += 25
        MyGui.Add("Text", Format("x{} y{} h{}", PosX, PosY, 20), "触发:与正常的按键触发等效")

        PosY += 30
        PosX := 200
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())

        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 500, 220))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : GetSerialStr("SubMacro")
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        this.Data := this.GetSubMacroData(this.SerialStr)

        this.TypeCon.Value := this.Data.MacroType
        this.CallTypeCon.Value := this.Data.CallType
        tableIndex := this.Data.MacroType - 1

        if (this.Data.MacroType != 1) {
            DropDownArr := []
            for index, Con in MySoftData.TableInfo[tableIndex].RemarkConArr {
                DropDownArr.Push(A_Index ". " Con.Value)
            }
            this.DropDownIndexCon.Delete()
            this.DropDownIndexCon.Add(DropDownArr)
            if (this.Data.Index >= DropDownArr.Length)
                this.DropDownIndexCon.Value := this.Data.Index
        }

        if (this.Data.MacroType != 1) {
            SerialArr := MySoftData.TableInfo[tableIndex].SerialArr
            if (SerialArr.Length < this.Data.Index || SerialArr[this.Data.Index] != this.Data.MacroSerial) {
                loop SerialArr.Length {
                    if (SerialArr[A_Index] == this.Data.MacroSerial) {
                        this.DropDownIndexCon.Value := A_Index
                        break
                    }
                }
            }
        }
    }

    ToggleFunc(state) {
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            Hotkey("!l", MacroAction, "On")
        }
        else {
            Hotkey("!l", MacroAction, "Off")
        }
    }

    OnRefresh() {
        EnableIndex := this.TypeCon.Value != 1  ;类型是1的时候，不能选择序号
        this.DropDownIndexCon.Enabled := EnableIndex
        if (EnableIndex) {
            tableIndex := this.TypeCon.Value - 1
            DropDownArr := []
            for index, Con in MySoftData.TableInfo[tableIndex].RemarkConArr {
                DropDownArr.Push(A_Index ". " Con.Value)
            }
            this.DropDownIndexCon.Delete()
            this.DropDownIndexCon.Add(DropDownArr)
            if (DropDownArr.Length >= 1)
                this.DropDownIndexCon.Value := 1
        }
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return
        this.SaveSubMacroData()
        this.ToggleFunc(false)
        CommandStr := this.GetCommandStr()
        action := this.SureBtnAction
        action(CommandStr)
        this.Gui.Hide()
    }

    CheckIfValid() {
        tableIndex := this.TypeCon.Value - 1
        SerialArr := this.TypeCon.Value == 1 ? "" : MySoftData.TableInfo[tableIndex].SerialArr

        if (SerialArr != "") {
            if (this.DropDownIndexCon.Value > SerialArr.Length || this.DropDownIndexCon.Value == 0) {
                MsgBox("配置无效，序号不正确")
                return false
            }

        }

        return true
    }

    TriggerMacro() {
        this.SaveSubMacroData()
        CommandStr := this.GetCommandStr()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.ActionCount[1] := 0
        tableItem.SuccessClearActionArr[1] := Map()
        tableItem.VariableMapArr[1] := Map()

        OnSubMacro(tableItem, CommandStr, 1)
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "宏操作_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }
        return CommandStr
    }

    GetSubMacroData(SerialStr) {
        saveStr := IniRead(SubMacroFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := SubMacroData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    SaveSubMacroData() {
        this.Data.MacroType := this.TypeCon.Value
        this.Data.Index := this.DropDownIndexCon.value
        this.Data.CallType := this.CallTypeCon.Value

        tableIndex := this.TypeCon.Value - 1
        SerialArr := this.TypeCon.Value == 1 ? "" : MySoftData.TableInfo[tableIndex].SerialArr
        this.Data.MacroSerial := SerialArr != "" ? SerialArr[this.Data.Index] : ""

        saveStr := JSON.stringify(this.Data, 0)
        IniWrite(saveStr, SubMacroFile, IniSection, this.Data.SerialStr)
        if (MySoftData.DataCacheMap.Has(this.Data.SerialStr)) {
            MySoftData.DataCacheMap.Delete(this.Data.SerialStr)
        }
    }
}
