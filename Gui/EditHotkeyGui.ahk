#Requires AutoHotkey v2.0

class EditHotkeyGui {
    __new() {
        this.Gui := ""
        this.ShowCon := ""
        this.KeyCon := ""
        this.OnlyTriggerKey := false
        this.TriggerStrBtnCon := ""
    }

    ShowGui(ShowCon, KeyCon, OnlyTriggerKey) {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }
        this.ShowCon := ShowCon
        this.KeyCon := KeyCon
        this.OnlyTriggerKey := OnlyTriggerKey
        this.TriggerStrBtnCon.Enabled := !this.OnlyTriggerKey
    }

    AddGui() {
        MyGui := Gui(, "快捷方式编辑")
        this.Gui := MyGui
        MyGui.SetFont("S12 W550 Q2", MySoftData.FontType)

        PosX := 75
        PosY := 30
        con := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 50), "快捷键")
        con.OnEvent("Click", (*) => this.OnEditHotKey(MyTriggerKeyGui))

        PosX += 150
        con := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 50), "字串")
        con.OnEvent("Click", (*) => this.OnEditHotKey(MyTriggerStrGui))
        this.TriggerStrBtnCon := con

        MyGui.Show(Format("w{} h{}", 420, 120))
    }

    OnEditHotKey(gui) {
        triggerKey := this.KeyCon.Value
        gui.SureBtnAction := this.OnSubSureBtn.Bind(this)
        args := TriggerKeyGuiArgs()
        args.IsToolEdit := true
        gui.ShowGui(triggerKey, args)
        this.Gui.Hide()
    }

    OnSubSureBtn(sureTriggerStr) {
        if (sureTriggerStr != "" && SubStr(sureTriggerStr, 1, 1) == "~") {
            sureTriggerStr := SubStr(sureTriggerStr, 2)
        }
        this.KeyCon.Value := sureTriggerStr
        this.KeyCon.Enabled := false
        this.KeyCon.Visible := true
        this.ShowCon.Visible := false
    }
}

OnOpenEditHotkeyGui(showCon, keyCon, OnlyTriggerKey, *) {
    MyEditHotkeyGui.ShowGui(showCon, keyCon, OnlyTriggerKey)
}
