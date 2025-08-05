#Requires AutoHotkey v2.0
#Include MacroEditGui.ahk

class SearchProGui {
    __new() {
        this.Gui := ""
        this.SureBtnAction := ""
        this.RemarkCon := ""
        this.PosAction := () => this.RefreshMouseInfo()
        this.SetAreaAction := (x1, y1, x2, y2) => this.OnSetSearchArea(x1, y1, x2, y2)
        this.CheckClipboardAction := () => this.CheckClipboard()
        this.SelectToggleCon := ""
        this.MacroEditGui := ""
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
        this.SimilarCon := ""
        this.OCRLabelCon := ""
        this.OCRTypeCon := ""
        this.ScreenshotBtn := ""
        this.ImageTipCon := ""
        this.ImageTypeTipCon := ""
        this.ImageTypeCon := ""
        this.ColorTipCon := ""
        this.HexColorCon := ""
        this.HexColorTipCon := ""
        this.TextCon := ""
        this.TextTipCon := ""
        this.SearchCountCon := ""
        this.SearchIntervalCon := ""
        this.FoundCommandStrCon := ""
        this.UnFoundCommandStrCon := ""
        this.SearchTypeCon := ""
        this.MouseActionTypeCon := ""
        this.ClickCountCon := ""
        this.SpeedCon := ""
        this.ResultToggleCon := ""
        this.ResultSaveNameCon := ""
        this.TrueValueCon := ""
        this.FalseValueCon := ""
        this.CoordToogleCon := ""
        this.CoordXNameCon := ""
        this.CoordYNameCon := ""
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
        MyGui := Gui(, "搜索Pro指令编辑")
        this.Gui := MyGui
        MyGui.SetFont(, "Arial")
        MyGui.SetFont("S10 W550 Q2", "Consolas")

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
        PosX := 150
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "相似度(%):")
        PosX += 75
        this.SimilarCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))

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
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "搜索次数:")
        PosX += 75
        this.SearchCountCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        PosX := 150
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "每次间隔:")
        PosX += 75
        this.SearchIntervalCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50))
        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 75), "鼠标动作:")
        PosX += 75
        this.MouseActionTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{} Center", PosX, PosY - 5, 130), ["无动作",
            "移动至目标", "移动至目标点击"])
        this.MouseActionTypeCon.Value := 1
        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 120), "移动速度(0~100):")
        PosX += 120
        this.SpeedCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50), "90")
        PosY += 30
        PosX := 10
        MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 120), "鼠标点击次数:")
        PosX += 120
        this.ClickCountCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 50), "1")

        PosY := SplitPosY
        PosX := 330
        this.ImageTipCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "搜索图片:")
        PosY += 25
        this.ImageTypeTipCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "识别模型:")
        PosX += 80
        this.ImageTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{} Center", PosX, PosY - 3, 80), ["OpenCV",
            "RMT识图"])
        PosY += 25
        PosX := 330
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 70, 25), "截图")
        btnCon.OnEvent("Click", (*) => this.OnScreenShotBtnClick())
        this.ScreenshotBtn := btnCon
        PosX += 80
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 80, 25), "选择图片")
        btnCon.OnEvent("Click", (*) => this.OnClickSetPicBtn())
        btnCon.Focus()
        this.ImageBtn := btnCon
        PosY := SplitPosY
        PosX := 500
        this.ImageCon := MyGui.Add("Picture", Format("x{} y{} w{} h{}", PosX, PosY, 80, 80), "")

        PosY += 90
        PosX := 330
        this.ColorTipCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "搜索颜色:")
        PosX += 80
        this.HexColorCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX, PosY - 5, 80), "FFFFFF")
        PosX += 90
        this.HexColorTipCon := MyGui.Add("Text", Format("x{} y{} w{} Background{}", PosX, PosY, 20, "FF0000"), "")

        PosY += 30
        PosX := 330
        this.TextTipCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "搜索文本:")
        PosX += 80
        this.TextCon := MyGui.Add("Edit", Format("x{} y{} w{} h{} Center", PosX, PosY - 3, 80, 20), "检索文本")
        PosY += 25
        PosX := 330
        this.OCRLabelCon := MyGui.Add("Text", Format("x{} y{} w{}", PosX, PosY, 80), "识别模型:")
        PosX += 80
        this.OCRTypeCon := MyGui.Add("DropDownList", Format("x{} y{} w{} Center", PosX, PosY - 3, 80), ["中文",
            "英文"])

        PosY += 30
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
        PosX := 10
        MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", PosX, PosY, 310, 70), "结果保存到变量中")
        PosY += 20
        PosX := 15
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "开关    选择/输入      真值        假值")
        PosY += 20
        PosX := 20
        this.ResultToggleCon := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        this.ResultSaveNameCon := MyGui.Add("ComboBox", Format("x{} y{} w{} R5", PosX + 30, PosY - 3, 100), [])
        this.TrueValueCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 135, PosY - 4, 70), 0)
        this.FalseValueCon := MyGui.Add("Edit", Format("x{} y{} w{} Center", PosX + 220, PosY - 4, 70), 0)
        PosY := TempPosY
        PosY += 90
        PosX := 330
        MyGui.Add("GroupBox", Format("x{} y{} w{} h{}", PosX, PosY, 290, 70), "找到后目标点保存到变量中")
        PosY += 20
        PosX := 335
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "开关  坐标X选择/输入  坐标Y选择/输入")
        PosY += 20
        PosX := 340
        this.CoordToogleCon := MyGui.Add("Checkbox", Format("x{} y{} w{}", PosX, PosY, 30))
        this.CoordXNameCon := MyGui.Add("ComboBox", Format("x{} y{} w{} R5", PosX + 35, PosY - 3, 100), [])
        this.CoordYNameCon := MyGui.Add("ComboBox", Format("x{} y{} w{} R5", PosX + 150, PosY - 3, 100), [])
        PosY += 40
        PosX := 270
        btnCon := MyGui.Add("Button", Format("x{} y{} w{} h{}", PosX, PosY, 100, 40), "确定")
        btnCon.OnEvent("Click", (*) => this.OnClickSureBtn())
        MyGui.OnEvent("Close", (*) => this.ToggleFunc(false))
        MyGui.Show(Format("w{} h{}", 640, 540))
    }

    Init(cmd) {
        cmdArr := cmd != "" ? StrSplit(cmd, "_") : []
        this.SerialStr := cmdArr.Length >= 2 ? cmdArr[2] : GetSerialStr("Search")
        this.RemarkCon.Value := cmdArr.Length >= 3 ? cmdArr[3] : ""
        macro := this.MacroEditGui.GetFinallyMacroStr()
        VariableArr := GetSelectVariableObjArr(macro)

        this.Data := this.GetCompareData(this.SerialStr)
        this.SearchTypeCon.Value := this.Data.SearchType
        this.SimilarCon.Value := this.Data.Similar
        this.OCRTypeCon.Value := this.Data.OCRType
        this.ImageTypeCon.Value := this.Data.SearchImageType
        this.ImageCon.GetPos(&imagePosX, &imagePosY)
        this.ImageCon.Value := this.Data.SearchImagePath
        this.ImageCon.Move(imagePosX, imagePosY, 80, 80)
        this.HexColorCon.Value := this.Data.SearchColor
        this.TextCon.Value := this.Data.SearchText
        this.StartPosXCon.Value := this.Data.StartPosX
        this.StartPosYCon.Value := this.Data.StartPosY
        this.EndPosXCon.Value := this.Data.EndPosX
        this.EndPosYCon.Value := this.Data.EndPosY
        this.SearchCountCon.Value := this.Data.SearchCount
        this.SearchIntervalCon.Value := this.Data.SearchInterval
        this.MouseActionTypeCon.Value := this.Data.MouseActionType
        this.SpeedCon.Value := this.Data.Speed
        this.ClickCountCon.Value := this.Data.ClickCount
        this.FoundCommandStrCon.Value := this.Data.TrueCommandStr
        this.UnFoundCommandStrCon.Value := this.Data.FalseCommandStr
        this.ResultToggleCon.Value := this.Data.ResultToggle
        this.ResultSaveNameCon.Delete()
        this.ResultSaveNameCon.Add(VariableArr)
        this.ResultSaveNameCon.Text := this.Data.ResultSaveName
        this.TrueValueCon.Value := this.Data.TrueValue
        this.FalseValueCon.Value := this.Data.FalseValue
        this.CoordToogleCon.Value := this.Data.CoordToogle
        this.CoordXNameCon.Delete()
        this.CoordXNameCon.Add(VariableArr)
        this.CoordXNameCon.Text := this.Data.CoordXName
        this.CoordYNameCon.Delete()
        this.CoordYNameCon.Add(VariableArr)
        this.CoordYNameCon.Text := this.Data.CoordYName
        this.OnChangeSearchType()
    }

    GetCommandStr() {
        hasRemark := this.RemarkCon.Value != ""
        CommandStr := "搜索Pro_" this.Data.SerialStr
        if (hasRemark) {
            CommandStr .= "_" this.RemarkCon.Value
        }
        return CommandStr
    }

    GetCompareData(SerialStr) {
        saveStr := IniRead(SearchProFile, IniSection, SerialStr, "")
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

        if (!IsNumber(this.SearchCountCon.Value) || Number(this.SearchCountCon.Value) <= 0) {
            MsgBox("搜索次数请输入大于0的数字")
            return false
        }

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
            filePath := A_WorkingDir "\Images\ScreenShot\" CurrentDateTime ".png"
            ; MyWinClip.SaveBitmap(filePath, "png")
            SaveClipToBitmap(filePath)
            this.ImageCon.Value := filePath
            this.Data.SearchImagePath := filePath
            ; 停止监听
            SetTimer(, 0)
        }
    }

    OnScreenShotGetArea(x1, y1, x2, y2) {
        CurrentDateTime := FormatTime(, "HHmmss")
        filePath := A_WorkingDir "\Images\ScreenShot\" CurrentDateTime ".png"

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
            this.MacroGui.SureFocusCon := this.MousePosCon
        }

        this.MacroGui.SureBtnAction := (command) => this.OnSureFoundMacroBtnClick(command)
        this.MacroGui.ShowGui(this.FoundCommandStrCon.Value, false)
    }

    OnEditUnFoundMacroBtnClick() {
        if (this.MacroGui == "") {
            this.MacroGui := MacroEditGui()
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
        this.ImageTypeCon.Enabled := isImage && A_PtrSize == 8
        this.ImageTipCon.Enabled := isImage
        this.ImageTypeTipCon.Enabled := isImage
        this.ImageCon.Enabled := isImage
        if (A_PtrSize != 8)
            this.ImageTypeCon.Value := 2

        this.HexColorCon.Enabled := isColor
        this.ColorTipCon.Enabled := isColor
        this.HexColorTipCon.Visible := showColorTip
        if (showColorTip) {
            this.HexColorTipCon.Opt(Format("+Background0x{}", this.HexColorCon.Value))
            this.HexColorTipCon.Redraw()
        }

        this.TextCon.Enabled := isText
        this.OCRLabelCon.Enabled := isText
        this.OCRTypeCon.Enabled := isText
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
        tableItem.ActionCount[1] := 0
        tableItem.SuccessClearActionArr[1] := Map()
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
    }

    SaveSearchData() {
        data := this.Data
        data.Similar := this.SimilarCon.Value
        data.OCRType := this.OCRTypeCon.Value
        data.SearchImageType := this.ImageTypeCon.Value
        data.SearchType := this.SearchTypeCon.Value
        data.SearchColor := this.HexColorCon.Value
        data.SearchText := this.TextCon.Value
        data.StartPosX := this.StartPosXCon.Value
        data.StartPosY := this.StartPosYCon.Value
        data.EndPosX := this.EndPosXCon.Value
        data.EndPosY := this.EndPosYCon.Value
        data.SearchCount := this.SearchCountCon.Value
        data.SearchInterval := this.SearchIntervalCon.Value
        data.MouseActionType := this.MouseActionTypeCon.Value
        data.ClickCount := this.ClickCountCon.Value
        data.Speed := this.SpeedCon.Value
        data.TrueCommandStr := this.FoundCommandStrCon.Value
        data.FalseCommandStr := this.UnFoundCommandStrCon.Value
        data.ResultToggle := this.ResultToggleCon.Value
        data.ResultSaveName := this.ResultSaveNameCon.Text
        data.TrueValue := this.TrueValueCon.Value
        data.FalseValue := this.FalseValueCon.Value
        data.CoordToogle := this.CoordToogleCon.Value
        data.CoordXName := this.CoordXNameCon.Text
        data.CoordYName := this.CoordYNameCon.Text
        saveStr := JSON.stringify(data, 0)
        IniWrite(saveStr, SearchProFile, IniSection, data.SerialStr)
    }
}
