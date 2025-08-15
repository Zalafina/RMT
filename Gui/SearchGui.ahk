#Requires AutoHotkey v2.0
#Include MacroEditGui.ahk

class SearchGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.VariableObjArr := []
        this.RemarkCon := ""
        this.PosAction := () => this.RefreshMouseInfo()
        this.SetAreaAction := (x1, y1, x2, y2) => this.OnSetSearchArea(x1, y1, x2, y2)
        this.CheckClipboardAction := () => this.CheckClipboard()
        this.SelectToggleCon := ""
        this.ImageTipCon := ""
        this.ColorTipCon := ""
        this.TextTipCon := ""
        this.Data := ""
        this.MousePosCon := ""
        this.MouseColorCon := ""
        this.MouseColorTipCon := ""
        this.StartPosXCon := ""
        this.StartPosYCon := ""
        this.EndPosXCon := ""
        this.EndPosYCon := ""
        this.ImageCon := ""
        this.ImageBtn := ""
        this.ScreenshotBtn := ""
        this.HexColorCon := ""
        this.HexColorTipCon := ""
        this.TextCon := ""
        this.FoundCommandStrCon := ""
        this.UnFoundCommandStrCon := ""
        this.SearchTypeCon := ""
        this.MouseActionTypeCon := ""
        this.MacroGui := ""
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
        MyGui := Gui(, "搜索指令编辑")
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

        PosY += 25
        PosX := 10
        con := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY, 25), "F1")
        con.Enabled := false

        PosX += 30
        this.SelectToggleCon := MyGui.Add("Checkbox", Format("x{} y{} w{} h{} Left", PosX, PosY, 150, 25), "左键框选搜索范围")
        this.SelectToggleCon.OnEvent("Click", (*) => this.OnClickSelectToggle())

        PosX += 150
        con := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY, 25), "F2")
        con.Enabled := false
        PosX += 30
        MyGui.Add("Text", Format("x{} y{} h{} Center", PosX, PosY + 3, 25), "选取当前颜色")

        PosX += 130
        con := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY, 25), "F3")
        con.Enabled := false
        PosX += 30
        MyGui.Add("Text", Format("x{} y{} h{} Center", PosX, PosY + 3, 25), "截图")

        PosX := 10
        PosY += 25
        this.MousePosCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 230, 20), "当前鼠标坐标:0,0")
        PosX += 330
        this.MouseColorCon := MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 150, 20), "当前鼠标颜色:FFFFFF")
        PosX += 150
        this.MouseColorTipCon := MyGui.Add("Text", Format("x{} y{} w{} Background{}", PosX, PosY, 20, "FF0000"), "")
        PosX := 10
        PosY += 30
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 100), "搜索范围:")

        PosX := 330
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "搜索类型:")
        PosX += 80
        this.SearchTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{} h{}", PosX, PosY - 3, 80, 100), ["图片", "颜色",
            "文本"])
        this.SearchTypeCon.OnEvent("Change", (*) => this.OnChangeSearchType())
        this.SearchTypeCon.Value := 1
        PosY += 30
        PosX := 10
        SplitPosY := PosY
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "起始坐标X:")
        PosX += 75
        this.StartPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        PosX := 150
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "起始坐标Y:")
        PosX += 75
        this.StartPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "终止坐标X:")
        PosX += 75
        this.EndPosXCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        PosX := 150
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "终止坐标Y:")
        PosX += 75
        this.EndPosYCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "鼠标动作:")
        PosX += 75
        this.MouseActionTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{} Center", PosX, PosY - 5, 130), ["无动作",
            "移动至目标", "移动至目标点击1次", "移动至目标点击2次"])
        this.MouseActionTypeCon.Value := 1

        PosY += 35
        PosX := 10
        this.ColorTipCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "搜索颜色:")
        PosX += 80
        this.HexColorCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 80), "FFFFFF")
        PosX += 90
        this.HexColorTipCon := MyGui.Add("Text", Format("x{} y{} w{} Background{}", PosX, PosY, 20, "FF0000"), "")

        PosY := SplitPosY
        PosX := 330
        this.ImageTipCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "搜索图片:")
        PosY += 20
        PosX := 330
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 80, 30), "选择图片")
        btnCon.OnEvent("Click", (*) => this.OnClickSetPicBtn())
        btnCon.Focus()
        this.ImageBtn := btnCon
        PosY += 35
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 80, 30), "截图")
        btnCon.OnEvent("Click", (*) => this.OnScreenShotBtnClick())
        this.ScreenshotBtn := btnCon
        PosY -= 55
        PosX := 415
        this.ImageCon := MyGui.Add("Picture", Format("x{} y{} w{} h{}", PosX, PosY, 80, 80), "")

        PosY += 95
        PosX := 330
        this.TextTipCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "搜索文本:")
        PosX += 80
        this.TextCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 3, 80), "检索文本")
        PosY += 35
        TempPosY := PosY
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 170, 20), "找到后的指令:（可选）")
        PosX += 180
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 5, 80, 20), "编辑指令")
        btnCon.OnEvent("Click", (*) => this.OnEditFoundMacroBtnClick())
        PosY += 20
        PosX := 10
        this.FoundCommandStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 280, 80), "")
        PosY := TempPosY
        PosX := 330
        MyGui.Add("Text", Format("x{} y{} w{} h{}", PosX, PosY, 170, 20), "未找到后的指令:（可选）")
        PosX += 180
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY - 5, 80, 20), "编辑指令")
        btnCon.OnEvent("Click", (*) => this.OnEditUnFoundMacroBtnClick())
        PosY += 20
        PosX := 330
        this.UnFoundCommandStrCon := MyGui.Add("Edit", Format("x{} y{} w{} h{}", PosX, PosY, 280, 80), "")
        TempPosY := PosY
        PosY += 90
        PosX := 270
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())
        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 640, 410))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : GetSerialStr("Search")
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""

        this.Data := this.GetCompareData(this.SerialStr)
        this.SearchTypeCon.Value := this.Data.SearchType
        this.ImageCon.GetPos(&imagePosX, &imagePosY)
        this.ImageCon.Value := this.Data.SearchImagePath
        this.ImageCon.Move(imagePosX, imagePosY, 80, 80)
        this.HexColorCon.Value := this.Data.SearchColor
        this.TextCon.Value := this.Data.SearchText
        this.StartPosXCon.Value := this.Data.StartPosX
        this.StartPosYCon.Value := this.Data.StartPosY
        this.EndPosXCon.Value := this.Data.EndPosX
        this.EndPosYCon.Value := this.Data.EndPosY
        this.MouseActionTypeCon.Value := this.Data.MouseActionType
        this.FoundCommandStrCon.Value := this.Data.TrueMacro
        this.UnFoundCommandStrCon.Value := this.Data.FalseMacro
        this.OnChangeSearchType()
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "搜索_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }
        return CommandStr
    }

    GetCompareData(SerialStr) {
        saveStr := IniRead(SearchFile, IniSection, SerialStr, "")
        if (!saveStr) {
            data := SearchData()
            data.SerialStr := SerialStr
            return data
        }

        data := JSON.parse(saveStr, , false)
        return data
    }

    CheckIfValid() {
        if (!IsNumber(this.StartPosXCon.Value) || !IsNumber(this.StartPosYCon.Value) || !IsNumber(this.EndPosXCon.Value
        ) || !IsNumber(this.EndPosYCon.Value)) {
            MsgBox("坐标中请输入数字")
            return false
        }

        if (Number(this.StartPosXCon.Value) > Number(this.EndPosXCon.Value) || Number(this.StartPosYCon.Value) >
        Number(
            this.EndPosYCon.Value)) {
            MsgBox("起始坐标不能大于终止坐标")
            return false
        }

        ; if (!IsNumber(this.SearchCountCon.Value) || Number(this.SearchCountCon.Value) <= 0) {
        ;     MsgBox("搜索次数请输入大于0的数字")
        ;     return false
        ; }

        if (this.SearchTypeCon.Value == 1 && this.Data.SearchImagePath == "") {
            MsgBox("请设置搜索图片")
            return false
        }

        if (this.SearchTypeCon.Value == 1) {
            searchWidth := this.EndPosXCon.Value - this.StartPosXCon.Value
            searchHeight := this.EndPosYCon.Value - this.StartPosYCon.Value
            size := GetImageSize(this.Data.SearchImagePath)
            if (size[1] > searchWidth || size[2] > searchHeight) {
                MsgBox("搜索范围不能小于图片大小")
                return false
            }
        }

        if (this.SearchTypeCon.Value == 2 && !RegExMatch(this.HexColorCon.Value, "^([0-9A-Fa-f]{6})$")) {
            MsgBox("请输入正确的颜色值")
            return false
        }

        if (this.SearchTypeCon.Value == 3) {
            if (Number(this.StartPosXCon.Value) == Number(this.EndPosXCon.Value) ||
            Number(this.StartPosYCon.Value) == Number(this.EndPosYCon.Value)) {
                MsgBox("搜索文本时：搜索范围中起始坐标不能和终止坐标相同")
                return false
            }
        }

        return true
    }

    ToggleFunc(state) {
        MacroAction := (*) => this.TriggerMacro()
        if (state) {
            SetTimer this.PosAction, 100
            Hotkey("!l", MacroAction, "On")
            Hotkey("F1", (*) => this.OnF1(), "On")
            Hotkey("F2", (*) => this.SureColor(), "On")
            Hotkey("F3", (*) => this.OnScreenShotBtnClick(), "On")
        }
        else {
            SetTimer this.PosAction, 0
            Hotkey("!l", MacroAction, "Off")
            Hotkey("F1", (*) => this.OnF1(), "Off")
            Hotkey("F2", (*) => this.SureColor(), "Off")
            Hotkey("F3", (*) => this.OnScreenShotBtnClick(), "Off")
        }
    }

    RefreshMouseInfo() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY
        this.MousePosCon.Value := "当前鼠标坐标:" mouseX "," mouseY

        CoordMode("Pixel", "Screen")
        Color := PixelGetColor(mouseX, mouseY, "Slow")
        ColorText := StrReplace(Color, "0x", "")
        this.MouseColorCon.Value := "当前鼠标颜色:" ColorText
        this.MouseColorTipCon.Opt(Format("+Background0x{}", ColorText))
        this.MouseColorTipCon.Redraw()
    }

    OnClickSureBtn() {
        valid := this.CheckIfValid()
        if (!valid)
            return
        this.SaveSearchData()
        action := this.SureBtnAction
        action(this.GetCommandStr())
        this.ToggleFunc(false)
        this.Gui.Hide()
    }

    OnClickSetPicBtn() {
        path := FileSelect(, , "选择图片")
        this.ImageCon.Value := path
        this.Data.SearchImagePath := path
    }

    OnScreenShotBtnClick() {
        if (MySoftData.ScreenShotTypeCtrl.Value == 1) {
            A_Clipboard := ""  ; 清空剪贴板
            Run("ms-screenclip:")
            SetTimer(this.CheckClipboardAction, 500)  ; 每 500 毫秒检查一次剪贴板
        }
        else {
            EnableSelectAerea(this.OnScreenShotGetArea.Bind(this))
        }
    }

    CheckClipboard() {
        ; 如果剪贴板中有图像
        if DllCall("IsClipboardFormatAvailable", "uint", 8)  ; 8 是 CF_BITMAP 格式
        {
            ; 获取当前日期和时间，用于生成唯一的文件名
            CurrentDateTime := FormatTime(, "HHmmss")
            filePath := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\Images\ScreenShot\" CurrentDateTime ".png"
            SaveClipToBitmap(filePath)
            this.ImageCon.Value := filePath
            this.Data.SearchImagePath := filePath
            ; 停止监听
            SetTimer(, 0)
        }
    }

    OnScreenShotGetArea(x1, y1, x2, y2) {
        CurrentDateTime := FormatTime(, "HHmmss")
        filePath := A_WorkingDir "\Setting\" MySoftData.CurSettingName "\Images\ScreenShot\" CurrentDateTime ".png"

        ScreenShot(x1, y1, x2, y2, filePath)
        this.ImageCon.Value := filePath
        this.Data.SearchImagePath := filePath
    }

    OnSureFoundMacroBtnClick(CommandStr) {
        this.FoundCommandStr := CommandStr
        this.FoundCommandStrCon.Value := CommandStr
    }

    OnSureUnFoundMacroBtnClick(CommandStr) {
        this.UnFoundCommandStr := CommandStr
        this.UnFoundCommandStrCon.Value := CommandStr
    }

    OnEditFoundMacroBtnClick() {
        if (this.MacroGui == "") {
            this.MacroGui := MacroEditGui()
            this.MacroGui.VariableObjArr := this.VariableObjArr
            this.MacroGui.SureFocusCon := this.MousePosCon
        }

        this.MacroGui.SureBtnAction := (command) => this.OnSureFoundMacroBtnClick(command)
        this.MacroGui.ShowGui(this.FoundCommandStrCon.Value, false)
    }

    OnEditUnFoundMacroBtnClick() {
        if (this.MacroGui == "") {
            this.MacroGui := MacroEditGui()
            this.MacroGui.VariableObjArr := this.VariableObjArr
            this.MacroGui.SureFocusCon := this.MousePosCon
        }
        this.MacroGui.SureBtnAction := (command) => this.OnSureUnFoundMacroBtnClick(command)
        this.MacroGui.ShowGui(this.UnFoundCommandStrCon.Value, false)
    }

    OnChangeSearchType() {
        isImage := this.SearchTypeCon.Value == 1
        isColor := this.SearchTypeCon.Value == 2
        isText := this.SearchTypeCon.Value == 3

        showImageTip := isImage && this.Data.SearchImagePath == ""
        showColorTip := isColor && RegExMatch(this.HexColorCon.Value, "^([0-9A-Fa-f]{6})$")

        this.ImageBtn.Enabled := isImage
        this.ScreenshotBtn.Enabled := isImage
        this.ImageTipCon.Enabled := isImage

        this.HexColorCon.Enabled := isColor
        this.ColorTipCon.Enabled := isColor
        this.HexColorTipCon.Visible := showColorTip
        if (showColorTip) {
            this.HexColorTipCon.Opt(Format("+Background0x{}", this.HexColorCon.Value))
            this.HexColorTipCon.Redraw()
        }

        this.TextCon.Enabled := isText
        this.TextTipCon.Enabled := isText
        this.MousePosCon.Focus()
    }

    TriggerMacro() {
        valid := this.CheckIfValid()
        if (!valid)
            return
        this.SaveSearchData()
        tableItem := MySoftData.SpecialTableItem
        tableItem.CmdActionArr[1] := []
        tableItem.KilledArr[1] := false
        tableItem.PauseArr[1] := 0
        tableItem.ActionCount[1] := 0
        tableItem.VariableMapArr[1] := Map()

        OnSearch(tableItem, this.GetCommandStr(), 1)
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

    SureColor() {
        CoordMode("Mouse", "Screen")
        MouseGetPos &mouseX, &mouseY

        CoordMode("Pixel", "Screen")
        Color := PixelGetColor(mouseX, mouseY, "Slow")
        ColorText := StrReplace(Color, "0x", "")
        this.HexColorCon.Value := ColorText
        this.HexColor := ColorText
        this.HexColorTipCon.Visible := true
        this.HexColorTipCon.Opt(Format("+Background0x{}", this.HexColorCon.Value))
        this.HexColorTipCon.Redraw()
        this.OnSetSearchArea(mouseX, mouseY, mouseX, mouseY)
    }

    SaveSearchData() {
        data := this.Data
        data.SearchType := this.SearchTypeCon.Value
        data.SearchColor := this.HexColorCon.Value
        data.SearchText := this.TextCon.Value
        data.StartPosX := this.StartPosXCon.Value
        data.StartPosY := this.StartPosYCon.Value
        data.EndPosX := this.EndPosXCon.Value
        data.EndPosY := this.EndPosYCon.Value
        data.MouseActionType := this.MouseActionTypeCon.Value
        data.TrueMacro := this.FoundCommandStrCon.Value
        data.FalseMacro := this.UnFoundCommandStrCon.Value
        saveStr := JSON.stringify(data, 0)
        IniWrite(saveStr, SearchFile, IniSection, data.SerialStr)
        if (MySoftData.DataCacheMap.Has(this.Data.SerialStr)) {
            MySoftData.DataCacheMap.Delete(this.Data.SerialStr)
        }
    }
}
