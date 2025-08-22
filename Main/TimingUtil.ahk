#Requires AutoHotkey v2.0

TimingCheck() {
    hasTiming := CheckIfHasTiming(&tableIndex)
    if (!hasTiming)
        return

    tableItem := MySoftData.TableInfo[tableIndex]
    SetTimingNextTime(tableItem)
    if (A_Sec == 0)
        InitTimingChecker()
    else {
        StartLeftTime := (-(60 - A_Sec)) * 1000
        SetTimer(InitTimingChecker, StartLeftTime)
    }
}

CheckIfHasTiming(&tableIndex) {
    tableIndex := GetTimingTableIndex()
    if (tableIndex == "")
        return false

    tableItem := MySoftData.TableInfo[tableIndex]
    for index, value in tableItem.ModeArr {
        if ((Integer)(tableItem.ForbidArr[index]))
            continue

        if (tableItem.MacroArr.Length < index || tableItem.MacroArr[index] == "")
            continue

        Data := GetMacroCMDData(TimingFile, tableItem.TimingSerialArr[index])
        if (Data == "" || ObjOwnPropCount(Data) == 0)
            continue

        return true
    }
    return false
}

SetTimingNextTime(tableItem) {
    for index, value in tableItem.ModeArr {
        if ((Integer)(tableItem.ForbidArr[index]))
            continue

        if (tableItem.MacroArr.Length < index || tableItem.MacroArr[index] == "")
            continue

        Data := GetMacroCMDData(TimingFile, tableItem.TimingSerialArr[index])
        CurTime := FormatTime(A_Now, "yyyyMMddHHmm")
        if (Data == "" || ObjOwnPropCount(Data) == 0)
            continue
        if (Data.EndTime != "" && Data.EndTime >= CurTime)
            continue

        span := DateDiff(CurTime, Data.StartTime, "Minutes")
        if (Data.Type == 1)
            Data.NextTriggerTime := span < 0 ? Data.StartTime : ""
        else if (Data.Type == 2 || Data.Type == 3 || Data.Type == 4 || Data.Type == 6) {
            interval := GetTimingInterval(Data)
            if (span < 0)  ;时间还没到
                Data.NextTriggerTime := Data.StartTime
            else {
                count := (Integer)(span / interval)
                newTime := FormatTime(DateAdd(Data.StartTime, (count + 1) * interval, "Minutes"), "yyyyMMddHHmm")
                Data.NextTriggerTime := newTime
            }
        }
        else {
            if (span < 0)  ;时间还没到
                Data.NextTriggerTime := Data.StartTime
            else {
                newTime := SubStr(CurTime, 1, 6) SubStr(Data.StartTime, 7)
                Data.NextTriggerTime := newTime
                if (CurTime > newTime) {
                    newMonth := Format("{:02}", A_Mon + 1)
                    Data.NextTriggerTime := A_Year newMonth SubStr(Data.StartTime, 7)
                    if (A_Mon == 12) {
                        newYear := Format("{:04}", A_Year + 1)
                        newMonth := Format("{:02}", 1)
                        Data.NextTriggerTime := newYear newMonth SubStr(Data.StartTime, 7)
                    }
                }
            }
        }
    }
}

InitTimingChecker() {
    TimingChecker() ;立刻检测一次
    SetTimer(TimingChecker, 60000) ;然后一分钟轮询一次
}

TimingChecker() {
    tableIndex := GetTimingTableIndex()
    tableItem := MySoftData.TableInfo[tableIndex]
    for index, value in tableItem.ModeArr {
        if ((Integer)(tableItem.ForbidArr[index]))
            continue

        if (tableItem.MacroArr.Length < index || tableItem.MacroArr[index] == "")
            continue

        Data := GetMacroCMDData(TimingFile, tableItem.TimingSerialArr[index])
        CurTime := FormatTime(A_Now, "yyyyMMddHHmm")
        if (Data == "" || ObjOwnPropCount(Data) == 0)
            continue
        if (Data.NextTriggerTime == "" || CurTime < Data.NextTriggerTime)
            continue

        ProcessName := tableItem.ProcessNameArr.Length >= index ? tableItem.ProcessNameArr[index] : ""
        if (ProcessName != "") {
            infoStr := GetParamsWinInfoStr(ProcessName)
            if (!WinActivate(infoStr))
                return
        }

        UpdateTimingNextTime(Data)
        TriggerSubMacro(tableIndex, index)
    }
}

UpdateTimingNextTime(Data) {
    if (Data.Type == 1)
        Data.NextTriggerTime := ""
    else if (Data.Type == 2 || Data.Type == 3 || Data.Type == 4 || Data.Type == 6) {
        interval := GetTimingInterval(Data)
        newTime := FormatTime(DateAdd(Data.NextTriggerTime, interval, "Minutes"), "yyyyMMddHHmm")
        Data.NextTriggerTime := newTime
    }
    else {
        year := FormatTime(Data.NextTriggerTime, "yyyy")
        month := FormatTime(Data.NextTriggerTime, "MM")
        newMonth := Format("{:02}", month + 1)
        Data.NextTriggerTime := year newMonth SubStr(Data.StartTime, 7)
        if (month == 12) {
            newYear := Format("{:04}", year + 1)
            newMonth := Format("{:02}", 1)
            Data.NextTriggerTime := newYear newMonth SubStr(Data.StartTime, 7)
        }
    }
}

GetTimingInterval(Data) {
    if (Data.Type == 2)
        return 60
    else if (Data.Type == 3)
        return 60 * 24
    else if (Data.Type == 4)
        return 60 * 24 * 7

    return Data.CustomInterval
}
