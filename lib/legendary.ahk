#Requires AutoHotkey v2.0

DebugLegendary := false
_MapDebugID := 5

Legendary_CheckMapBtn_Click() {
    if (!UIIsInMap()) {
        throw ValueError("当前不在地图界面")
    }
    LegendaryCheckMap()
}

Legendary_RefreshMapBtn_Click() {
    if (!UIIsInMap()) {
        throw ValueError("当前不在地图界面")
    }
    MySend("Escape", , 500)  ; 退出地图
    LegendaryRefreshMap()
    if (myGui["Legendary.AutoCheckChk"].Value) {
        LegendaryCheckMap()
    }
}

Legendary_LoopRefreshBtn_Click() {
    if (!UIIsInMap()) {
        throw ValueError("当前不在地图界面")
    }
    loopCount := myGui["Legendary.MaxLoopTimes"].Value
    infiniteLoop := (loopCount == 0)  ; 0表示无限循环
    currentLoop := 0

    while (currentLoop < loopCount || infiniteLoop) {
        currentLoop++
        result := 0

        ; 更新状态栏
        if (infiniteLoop) {
            UpdateStatusBar("无限刷新中: 第 " currentLoop " 次")
        }
        else {
            UpdateStatusBar("循环刷新中: " currentLoop "/" loopCount)
        }
        Sleep(500) ; 确保循环次数可见

        MySend("Escape", , 500)  ; 退出地图
        LegendaryRefreshMap()
        result := LegendaryCheckMap()
        if (result != 0) {
            break
        }
    }

    if (result = 0) {
        UpdateStatusBar("循环完毕，未找到指定传奇任务")
        return
    }

}


_LegendaryQuestType := ["Enemy", "Tree", "Diamond", "Fish", "Potato"]
_LegendaryQuestBlueColor := 0x13A6CD  ; 传奇任务蓝色
_LegendaryQuestList := [
    ["龙瞳山地", 1, 960, 152, _LegendaryQuestBlueColor],
    ["龙鼻山地", 1, 336, 749, _LegendaryQuestBlueColor],
    ["蜿蜒山峰", 1, 1146, 153, _LegendaryQuestBlueColor],
    ["落羽之森", 2, 1775, 589, _LegendaryQuestBlueColor],
    ["菇菇秘境", 2, 1630, 314, _LegendaryQuestBlueColor],
    ["翼尖峡谷", 2, 1538, 260, _LegendaryQuestBlueColor],
    ["干涸沙漠西部", 3, 1200, 947, _LegendaryQuestBlueColor],
    ["干涸沙漠东部", 3, 1546, 845, _LegendaryQuestBlueColor],
    ["龙牙群岛", 4, 1233, 170, 0x089ACA],
    ["绿意台地", 5, 1733, 687, 0x3BE2AE],
    ["巨腹大平原南部", 5, 1861, 944, 0xF2A057],  ; 胡萝卜颜色
    ["巨腹大平原西部", 5, 1544, 264, _LegendaryQuestBlueColor]
]
VarScaleHandler.Register("_LegendaryQuestList", [
    [1, 3], [1, 4],
    [2, 3], [2, 4],
    [3, 3], [3, 4],
    [4, 3], [4, 4],
    [5, 3], [5, 4],
    [6, 3], [6, 4],
    [7, 3], [7, 4],
    [8, 3], [8, 4],
    [9, 3], [9, 4],
    [10, 3], [10, 4],
    [11, 3], [11, 4],
    [12, 3], [12, 4],
])

/**
 * @description 识别地图上是否有传奇任务
 * @returns {Integer} 传奇任务类型（0:无任务, 1:找到任务, 2:冲突的任务）
 */
LegendaryCheckMap() {
    posRange := 20
    colorRange := 15
    foundQuestList := []
    anyIncludedAndFound := false
    for index, quest in _LegendaryQuestList {
        included := myGui["Legendary.Include" _LegendaryQuestType[quest[2]] "Chk"
            ].Value
        xs := quest[3]
        ys := quest[4]
        color := quest[5]
        found := PixelSearch(&x, &y,
            xs - posRange, ys - posRange,
            xs + posRange, ys + posRange,
            color, colorRange)
        anyIncludedAndFound := anyIncludedAndFound || (included && found)
        if (found) {
            foundQuestList.Push(index)
        }
        MyToolTip(
            included found " " quest[1],
            xs, ys, _MapDebugID + index, DebugLegendary)
    }
    if (!anyIncludedAndFound) {
        UpdateStatusBar("未找到指定传奇任务")
        return 0 ; 无任务
    }
    else if (foundQuestList.Length == 1) {
        UpdateStatusBar("在" _LegendaryQuestList[foundQuestList[1]][1] "找到传奇任务")
        return 1 ; 找到任务
    }
    else {
        UpdateStatusBar("找到" foundQuestList.Length "个冲突的传奇任务")
        return 2 ; 冲突的任务
    }
}

; "区域"位置
_LegendaryText1Pos := [1327, 337]
VarScaleHandler.Register("_LegendaryText1Pos", [[1], [2]])
; "区域"颜色
_LegendaryTextColor := "0xF8F0DC"
; 等级标识位置
_LegendaryLevelPos := [151, 295]
VarScaleHandler.Register("_LegendaryLevelPos", [[1], [2]])
; 等级标识未解锁颜色
_LegendaryLevelLockedColor := "0x978056"
; 等级标识已选中颜色
_LegendaryLevelSelectedColor := "0x086400"
; 等级标识有效颜色
_LegendaryLevelValidColor := "0x3C2918"

/**
 * @description 使用更换等级法刷新一次地图
 */
LegendaryRefreshMap() {
    OutputDebug("Info.legendary.RefreshMap: 开始刷新地图")
    MySend("f", , 500)
    MySend("Space", , 500)
    found := SearchColorMatch(
        _LegendaryText1Pos[1], _LegendaryText1Pos[2], _LegendaryTextColor)
    MySend("Space", , 1000)
    count := 1
    maxCount := 7
    while (count <= maxCount) {
        if SearchColorMatch(_LegendaryLevelPos[1], _LegendaryLevelPos[2], _LegendaryLevelLockedColor) {
            OutputDebug("Debug.legendary.RefreshMap: " count "/" maxCount " 未解锁")

        } else if SearchColorMatch(_LegendaryLevelPos[1], _LegendaryLevelPos[2], _LegendaryLevelSelectedColor) {
            OutputDebug("Debug.legendary.RefreshMap: " count "/" maxCount " 已选中")

        } else if SearchColorMatch(_LegendaryLevelPos[1], _LegendaryLevelPos[2], _LegendaryLevelValidColor, , 0) {
            OutputDebug("Debug.legendary.RefreshMap: " count "/" maxCount " 可选择")
            break

        } else {
            throw ValueError("等级检测异常")
        }

        MySend("e", , 100)  ; 切换等级
        if (count == maxCount) {
            throw ValueError("未找到可选择的等级")
        }
        count++
    }
    MySend("Space", , 500)  ; 确认选择
    MySend("Space", , 1000)  ; 确认切换
    MySend("Escape", , 500)  ; 退出对话
    MySend("m", , 800)  ; 打开地图并等待地图加载
    OutputDebug("Info.legendary.RefreshMap: 地图刷新完成")
}
