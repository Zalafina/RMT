#Requires AutoHotkey v2.0

class ToolRecordSettingGui {
    __new() {
        this.Gui := ""

        this.AutoLoosenCon := ""
        this.HoldMutiCon := ""
        this.KeyboardTogCon := ""
        this.MouseTogCon := ""
        this.MouseRelativeTogCon := ""
        this.MouseTrailTogCon := ""
        this.MouseTrailIntervalCon := ""
        this.MouseTrailLenCon := ""
        this.MouseTrailSpeedCon := ""
        this.JoyTogCon := ""
        this.JoyIntervalCon := ""

        this.TrailTipCon1 := ""
        this.TrailTipCon2 := ""
        this.TrailTipCon3 := ""
        this.JoyTipCon := ""
    }

    ShowGui() {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }
        this.Init()
    }

    Init() {
        this.AutoLoosenCon.Value := ToolCheckInfo.RecordAutoLoosen
        this.HoldMutiCon.Value := ToolCheckInfo.RecordHoldMuti
        this.KeyboardTogCon.Value := ToolCheckInfo.RecordKeyboard
        this.MouseTogCon.Value := ToolCheckInfo.RecordMouse
        this.MouseRelativeTogCon.Value := ToolCheckInfo.RecordMouseRelative
        this.MouseTrailTogCon.Value := ToolCheckInfo.RecordMouseTrail
        this.MouseTrailIntervalCon.Value := ToolCheckInfo.RecordMouseTrailInterval
        this.MouseTrailLenCon.Value := ToolCheckInfo.RecordMouseTrailLen
        this.MouseTrailSpeedCon.Value := ToolCheckInfo.RecordMouseTrailSpeed
        this.JoyTogCon.Value := ToolCheckInfo.RecordJoy
        this.JoyIntervalCon.Value := ToolCheckInfo.RecordJoyInterval
        this.OnTogClick()
    }

    AddGui() {
        MyGui := Gui(, "录制选项编辑器")
        this.Gui := MyGui
        MyGui.SetFont("S11 W550 Q2", MySoftData.FontType)

        PosX := 5
        PosY := 10
        MyGui.Add("GroupBox", Format("x{} y{} w510 h315", PosX, PosY), "通用选项")

        PosX := 20
        PosY += 25
        this.AutoLoosenCon := MyGui.Add("Checkbox", Format("x{} y{}", PosX, PosY), "结束自动添加松开指令")

        PosX += 245
        this.HoldMutiCon := MyGui.Add("Checkbox", Format("x{} y{}", PosX, PosY), "长按多次录制")

        PosX := 10
        PosY += 35
        MyGui.Add("GroupBox", Format("x{} y{} w500 h50", PosX, PosY), "键盘选项")

        PosX += 10
        PosY += 25
        this.KeyboardTogCon := MyGui.Add("Checkbox", Format("x{} y{}", PosX, PosY), "录制开关")

        PosX := 10
        PosY += 40
        MyGui.Add("GroupBox", Format("x{} y{} w500 h120", PosX, PosY), "鼠标选项")

        PosX := 20
        PosY += 25
        this.MouseTogCon := MyGui.Add("Checkbox", Format("x{} y{}", PosX, PosY), "录制开关")
        this.MouseTogCon.OnEvent("Click", (*) => this.OnTogClick())

        PosX += 245
        this.MouseRelativeTogCon := MyGui.Add("Checkbox", Format("x{} y{}", PosX, PosY), "相对位移")

        PosX := 20
        PosY += 30
        this.MouseTrailTogCon := MyGui.Add("Checkbox", Format("x{} y{}", PosX, PosY), "鼠标轨迹")
        this.MouseTrailTogCon.OnEvent("Click", (*) => this.OnTogClick())

        PosX += 245
        this.TrailTipCon1 := MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "轨迹点间隔(ms)：")
        PosX += 130
        this.MouseTrailIntervalCon := MyGui.Add("Edit", Format("x{} y{} w60 h25", PosX, PosY - 3), "300")

        PosX := 20
        PosY += 30
        this.TrailTipCon2 := MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "轨迹点距离(px)：")
        PosX += 130
        this.MouseTrailLenCon := MyGui.Add("Edit", Format("x{} y{} w60 h25", PosX, PosY - 3), "100")

        PosX += 115
        this.TrailTipCon3 := MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "轨迹速度(0~100)：")
        PosX += 130
        this.MouseTrailSpeedCon := MyGui.Add("Edit", Format("x{} y{} w60 h25", PosX, PosY - 3), "95")

        PosX := 10
        PosY += 45
        MyGui.Add("GroupBox", Format("x{} y{} w500 h55", PosX, PosY), "手柄选项")

        PosX += 10
        PosY += 25
        this.JoyTogCon := MyGui.Add("Checkbox", Format("x{} y{}", PosX, PosY), "录制开关")
        this.JoyTogCon.OnEvent("Click", (*) => this.OnTogClick())

        PosX += 245
        this.JoyTipCon := MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "检测间隔(ms)：")
        PosX += 130
        this.JoyIntervalCon := MyGui.Add("Edit", Format("x{} y{} w60 h25", PosX, PosY - 3), "50")

        PosX := 100
        PosY += 45
        con := MyGui.Add("Button", Format("x{} y{} w100 h40", PosX, PosY), "恢复默认")
        con.OnEvent("Click", (*) => this.OnRevertBtnClick())

        PosX := 300
        con := MyGui.Add("Button", Format("x{} y{} w100 h40", PosX, PosY), "确定")
        con.OnEvent("Click", (*) => this.OnSureBtnClick())

        MyGui.Show(Format("w{} h{}", 525, 390))
    }

    CheckIfValid() {
        return true
    }

    OnTogClick() {
        IsMouse := this.MouseTogCon.Value
        IsTrail := IsMouse && this.MouseTrailTogCon.Value
        IsJoy := this.JoyTogCon.Value
        this.MouseRelativeTogCon.Enabled := IsMouse
        this.MouseTrailTogCon.Enabled := IsMouse
        this.MouseTrailIntervalCon.Enabled := IsTrail
        this.MouseTrailLenCon.Enabled := IsTrail
        this.MouseTrailSpeedCon.Enabled := IsTrail
        this.TrailTipCon1.Enabled := IsTrail
        this.TrailTipCon2.Enabled := IsTrail
        this.TrailTipCon3.Enabled := IsTrail
        this.JoyIntervalCon.Enabled := IsJoy
        this.JoyTipCon.Enabled := IsTrail
    }

    OnRevertBtnClick() {
        this.AutoLoosenCon.Value := true
        this.HoldMutiCon.Value := false
        this.KeyboardTogCon.Value := true
        this.MouseTogCon.Value := true
        this.MouseRelativeTogCon.Value := false
        this.MouseTrailTogCon.Value := false
        this.MouseTrailIntervalCon.Value := 300
        this.MouseTrailLenCon.Value := 100
        this.MouseTrailSpeedCon.Value := 95
        this.JoyTogCon.Value := false
        this.JoyIntervalCon.Value := 50
    }

    OnSureBtnClick() {
        isValid := this.CheckIfValid()
        if (!isValid)
            return

        this.SaveData()
        this.Gui.Hide()
    }

    SaveData() {
        ToolCheckInfo.RecordAutoLoosen := this.AutoLoosenCon.Value
        ToolCheckInfo.RecordHoldMuti := this.HoldMutiCon.Value
        ToolCheckInfo.RecordKeyboard := this.KeyboardTogCon.Value
        ToolCheckInfo.RecordMouse := this.MouseTogCon.Value
        ToolCheckInfo.RecordMouseRelative := this.MouseRelativeTogCon.Value
        ToolCheckInfo.RecordMouseTrailInterval := this.MouseTrailIntervalCon.Value
        ToolCheckInfo.RecordMouseTrail := this.MouseTrailTogCon.Value
        ToolCheckInfo.RecordMouseTrailLen := this.MouseTrailLenCon.Value
        ToolCheckInfo.RecordMouseTrailSpeed := this.MouseTrailSpeedCon.Value
        ToolCheckInfo.RecordJoy := this.JoyTogCon.Value
        ToolCheckInfo.RecordJoyInterval := this.JoyIntervalCon.Value
    }
}
