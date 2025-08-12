#Requires AutoHotkey v2.0

GameWindowTitle := "ahk_exe NFL1-Win64-Shipping.exe"

; GUI callbacks
GameWindow_CheckBtn_Click() {
    GameWindowStatusUpdate()
}

GameWindow_ActivateBtn_Click() {
    GameWindowActivate()
}

GameWindowPixelInfoUpdateToogle() {
    myGui["GameWindow.PixelInfoUpdateChk"].Value := !myGui[
        "GameWindow.PixelInfoUpdateChk"].Value
    GameWindow_PixelInfoUpdateChk_Click()
}

GameWindow_PixelInfoUpdateChk_Click(args*) {
    if (myGui["GameWindow.PixelInfoUpdateChk"].Value) {
        SetTimer(GameWindowPixelInfoUpdate, 100)
        GameWindowPixelInfoUpdate()
    } else {
        SetTimer(GameWindowPixelInfoUpdate, 0)
    }
}

GameWindowPixelInfoUpdate() {
    MouseGetPos(&x, &y)
    color := PixelGetColor(x, y)
    myGui["GameWindow.PixelInfo"].Text := x "," y ",`"" color "`""
}

GameWindowStatusUpdate() {
    if !WinExist(GameWindowTitle) {
        myGui["GameWindow.Status"].Text := "未检测到游戏窗口"
        return
    }
    pid := WinGetPID(GameWindowTitle)
    WinGetClientPos(&x, &y, &w, &h, "ahk_pid " pid)
    text := "PID：" pid "`n"
    text .= "窗口位置：(" x ", " y ")`n"
    if (w = 0 || h = 0) {
        text .= "游戏窗口可能已最小化"
    } else if h/w != 0.5625 {
        text .= "请使用 16:9 分辨率运行"
    } else {
        text .= "游戏窗口大小：" w "x" h "`n"
    }
    text .= "变量对应大小：" VarScaleHandler.GetLastResolution() "`n"
    myGui["GameWindow.Status"].Text := text
}

GameWindowActivate() {
    if !WinExist(GameWindowTitle) {
        throw TargetError("游戏窗口未找到")
    }
    OutputDebug("Debug.game_window.GameWindowActivate: 正在打开游戏窗口")
    WinActivate(GameWindowTitle)
    WinRestore(GameWindowTitle)
    hwnd := WinWaitActive(GameWindowTitle, , 5)
    if (hwnd = 0) {
        throw TargetError("未能打开游戏窗口，可能已最小化")
    }
    OutputDebug("Info.game_window.GameWindowActivate: 游戏窗口已激活")
    UpdateStatusBar("游戏窗口已激活")
}
