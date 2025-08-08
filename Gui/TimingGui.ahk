#Requires AutoHotkey v2.0

class TimingGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.Data := ""
        this.IntervalLabelCon := ""
        this.IntervalUnitCon := ""

        this.StartTimeCon := ""
        this.EndTimeCon := ""
        this.TypeCon := ""
        this.CustomIntervalCon := ""
    }

    ShowGui(SerialStr) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }
        this.Init(SerialStr)
        this.OnChangeType()
    }

    Init(SerialStr) {
        this.SerialStr := SerialStr != "" ? SerialStr : GetSerialStr("Timing")
        this.Data := this.GetTimingData(this.SerialStr)

        this.StartTimeCon.Value := this.Data.StartTime
        this.EndTimeCon.Value := this.Data.EndTime
        this.TypeCon.Value := this.Data.Type
        this.CustomIntervalCon.Value := this.Data.CustomInterval
    }

    AddGui() {
        MyGui := Gui(, "定时编辑器")
        this.Gui := MyGui
        MyGui.SetFont("S11 W550 Q2", MySoftData.FontType)

        PosX := 10
        PosY := 15
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "开始时间：")
        PosX += 80
        this.StartTimeCon := MyGui.Add("DateTime", Format("x{} y{} w150", PosX, PosY - 3), "yyyy-MM-dd HH:mm")

        PosX += 170
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "结束时间：")
        PosX += 80
        this.EndTimeCon := MyGui.Add("DateTime", Format("x{} y{} w175 ChooseNone", PosX, PosY - 3), "yyyy-MM-dd HH:mm")

        PosX := 10
        PosY += 40
        con := MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "定时类型：")
        con.Focus()
        PosX += 80
        this.TypeCon := MyGui.Add("DropDownList", Format("x{} y{} w100", PosX, PosY - 3), ["单次", "每小时", "每天", "每周",
            "每月", "自定义"])
        this.TypeCon.OnEvent("Change", (*) => this.OnChangeType())
        PosX += 170
        this.IntervalLabelCon := MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "每次间隔：")
        PosX += 80
        this.CustomIntervalCon := MyGui.Add("Edit", Format("x{} y{} w110", PosX, PosY - 3), "")
        PosX += 110
        this.IntervalUnitCon := MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "分钟")

        PosX := 200
        PosY += 40
        con := MyGui.Add("Button", Format("x{} y{} w100 h40", PosX, PosY), "确定")
        con.OnEvent("Click", (*) => this.OnSureBtnClick())
        MyGui.Show(Format("w{} h{}", 525, 150))
    }

    CheckIfValid() {
        if (this.EndTimeCon.Value != "" && this.EndTimeCon.Value <= this.StartTimeCon.Value) {
            MsgBox("勾选结束时间后，结束时间必须大于开始时间！！！")
            return false
        }

        if (this.TypeCon.Value == 6 && IsFloat(this.CustomIntervalCon.Value)) {
            MsgBox("每次间隔时间只能是整数！！")
            return false
        }

        if (!IsNumber(this.CustomIntervalCon.Value) && this.CustomIntervalCon.Value <= 0) {
            MsgBox("每次间隔需要输入大于零的数字！！！")
            return false
        }

        return true
    }

    OnChangeType() {
        isCustom := this.TypeCon.Value == 6

        this.IntervalLabelCon.Enabled := isCustom
        this.CustomIntervalCon.Enabled := isCustom
        this.IntervalUnitCon.Enabled := isCustom
    }

    OnSureBtnClick() {
        isValid := this.CheckIfValid()
        if (!isValid)
            return

        this.SaveSearchData()
        this.Gui.Hide()
    }

    SaveSearchData() {
        Data := this.Data
        Data.StartTime := FormatTime(this.StartTimeCon.Value, "yyyyMMddHHmm")
        Data.EndTime := this.EndTimeCon.Value == "" ? "" : FormatTime(this.EndTimeCon.Value, "yyyyMMddHHmm")
        Data.Type := this.TypeCon.Value
        Data.CustomInterval := this.CustomIntervalCon.Value
        saveStr := JSON.stringify(Data, 0)
        IniWrite(saveStr, TimingFile, IniSection, Data.SerialStr)
    }

    GetTimingData(SerialStr) {
        saveStr := IniRead(TimingFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := TimingData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }
}
