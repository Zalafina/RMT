#Requires AutoHotkey v2.0

class SettingMgrGui {
    __new() {
        this.Gui := ""

        this.SettingList := []
        this.OperSettingCon := ""
        this.OperNameEditCon := ""
    }

    ShowGui() {
        if (this.Gui != "") {
            this.Gui.Show()
        }
        else {
            this.AddGui()
        }
        this.Refresh()
    }

    Refresh() {
        this.SettingList := StrSplit(MySoftData.SettingArrStr, "π")
        this.OperSettingCon.Delete()
        this.OperSettingCon.Add(this.SettingList)
        this.OperSettingCon.Text := this.SettingList[1]
    }

    AddGui() {
        MyGui := Gui(, "配置管理编辑器")
        this.Gui := MyGui
        MyGui.SetFont(, "Arial")
        MyGui.SetFont("S11 W550 Q2", "Consolas")

        PosX := 10
        PosY := 10
        MyGui.Add("GroupBox", Format("x{} y{} w400 h110", PosX, PosY), "配置操作")

        PosX := 70
        PosY += 30
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "配置选项：")

        PosX += 80
        this.OperSettingCon := MyGui.Add("DropDownList", Format("x{} y{} w{} R5", PosX, PosY - 3, 200), [])
        PosX := 80
        PosY += 35
        con := MyGui.Add("Button", Format("x{} y{} w100", PosX, PosY), "加载配置")
        con.OnEvent("Click", this.OnLoadBtnClick.Bind(this))
        PosX := 260
        con := MyGui.Add("Button", Format("x{} y{} w100", PosX, PosY), "删除配置")
        con.OnEvent("Click", this.OnDelBtnClick.Bind(this))

        PosX := 10
        PosY += 60
        MyGui.Add("GroupBox", Format("x{} y{} w400 h110", PosX, PosY), "新增配置操作")

        PosX := 70
        PosY += 30
        MyGui.Add("Text", Format("x{} y{}", PosX, PosY), "新配置名：")

        PosX += 80
        this.OperNameEditCon := MyGui.Add("Edit", Format("x{} y{} w{}", PosX, PosY - 3, 200), "")
        PosX := 70
        PosY += 35
        con := MyGui.Add("Button", Format("x{} y{} w100", PosX, PosY), "新增配置")
        con.OnEvent("Click", this.OnAddBtnClick.Bind(this))
        PosX := 250
        con := MyGui.Add("Button", Format("x{} y{} w120", PosX, PosY), "复制当前配置")
        con.OnEvent("Click", this.OnCopyBtnClick.Bind(this))

        MyGui.Show(Format("w{} h{}", 420, 260))
    }

    OnLoadBtnClick(*) {
        MySoftData.CurSettingName := this.OperSettingCon.Text
        IniWrite(MySoftData.CurSettingName, IniFile, IniSection, "CurSettingName")
        Reload()
    }

    OnDelBtnClick(*) {
        if (this.OperSettingCon.Text == MySoftData.CurSettingName) {
            MsgBox("不可删除当前配置")
            return
        }

        result := MsgBox("是否删除该配置", "提示", 1)
        if (result == "Cancel")
            return
        
        if (DirExist(A_WorkingDir "\Setting\" MySoftData.CurSettingName)) {
            DirDelete(A_WorkingDir "\Setting\" MySoftData.CurSettingName)
        }
        MsgBox("删除配置: " MySoftData.CurSettingName)
    }

    OnAddBtnClick(*) {
        isVaild := this.IsValidFolderName(this.OperNameEditCon.Value)
        if (!isVaild) {
            MsgBox("新配置名不符合文件目录命名规则，请修改新配置名")
            return
        }

        for settingName in this.SettingList {
            if (this.OperNameEditCon.Value == settingName) {
                MsgBox("配置已存在，新增配置失败！！！")
                return false
            }
        }

        MySoftData.SettingArrStr .= "π" this.OperNameEditCon.Value
        IniWrite(MySoftData.SettingArrStr, IniFile, IniSection, "SettingArrStr")
        this.Refresh()
        MsgBox("成功新增配置： " this.OperNameEditCon.Value)
    }

    OnCopyBtnClick(*) {
        MsgBox("复制配置")
    }

    IsValidFolderName(folderName) {
        ; 空名称不合法
        if (folderName == "") {
            return false
        }

        ; Windows 保留名称不合法（使用Map）
        reservedNames := Map(
            "CON", 1, "PRN", 1, "AUX", 1, "NUL", 1,
            "COM1", 1, "COM2", 1, "COM3", 1, "COM4", 1, "COM5", 1, "COM6", 1, "COM7", 1, "COM8", 1, "COM9", 1,
            "LPT1", 1, "LPT2", 1, "LPT3", 1, "LPT4", 1, "LPT5", 1, "LPT6", 1, "LPT7", 1, "LPT8", 1, "LPT9", 1
        )

        if (reservedNames.Has(folderName)) {
            return false
        }

        ; 检查非法字符
        illegalChars := ["\", "/", ":", "*", "?", " ", "<", ">", "|"]
        for char in illegalChars {
            if (InStr(folderName, char)) {
                return false
            }
        }

        ; 不能以空格或点结尾
        if (RegExMatch(folderName, "[ .]$")) {
            return false
        }

        ; 名称长度不能超过255个字符
        if (StrLen(folderName) > 255) {
            return false
        }

        ; 其他情况视为合法
        return true
    }
}
