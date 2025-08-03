#SingleInstance Force
#Requires AutoHotkey v2.0

; Variables globales
global isRunning := false
global bagFull := false
global bagEmpty := false
global currentPosition := "right"
global statusGui := ""
global selectedField := "Rose Field"
global isMacroRunning := false
global FieldChoice := 1
global mainGui := ""
global miniGui := ""

; Créer l'interface principale
CreateMainInterface() {
    global mainGui := Gui()
    mainGui.Opt("+AlwaysOnTop +ToolWindow")
    mainGui.Title := "Ant Sim 2"
    
    mainGui.Add("Text", "x10 y10 w200 h20 cBlue", "Field Selection:")
    mainGui.Add("Radio", "x10 y35 w100 h20 vFieldChoice Checked", "Rose Field")
    mainGui.Add("Radio", "x120 y35 w100 h20", "Cedar Field")
    mainGui.Add("Button", "x10 y70 w80 h30", "Start (F1)").OnEvent("Click", StartMacro)
    mainGui.Add("Button", "x100 y70 w80 h30", "Pause (F2)").OnEvent("Click", PauseMacro)
    mainGui.Add("Button", "x190 y70 w80 h30", "Stop (F3)").OnEvent("Click", StopMacro)
    mainGui.Add("Text", "x10 y110 w260 h20 cGray", "Status: Ready")
    mainGui.Add("Text", "x10 y130 w260 h20 cGray", "Selected Field: Rose Field")
    mainGui.Add("Text", "x10 y160 w260 h40 cGreen", "Hotkeys:`nF1: Start | F2: Pause | F3: Stop")
    
    mainGui.Show("x100 y100 w280 h220")
}

; Fonction pour démarrer la macro
StartMacro(*) {
    global isMacroRunning := true
    global selectedField := FieldChoice = 1 ? "Rose Field" : "Cedar Field"
    CreateMinimizedInterface()
    StartMacroFunction()
}

; Créer l'interface réduite
CreateMinimizedInterface() {
    global miniGui := Gui()
    miniGui.Opt("+AlwaysOnTop +ToolWindow")
    miniGui.Title := "Ant Sim 2"
    
    miniGui.Add("Button", "x5 y5 w60 h25", "Start").OnEvent("Click", StartMacro)
    miniGui.Add("Button", "x70 y5 w60 h25", "Pause").OnEvent("Click", PauseMacro)
    miniGui.Add("Button", "x135 y5 w60 h25", "Stop").OnEvent("Click", StopMacro)
    miniGui.Add("Text", "x5 y35 w190 h15 cGray", "Status: Running")
    miniGui.Add("Text", "x5 y50 w190 h15 cGray", "Field: " . selectedField)
    
    miniGui.Show("x100 y100 w200 h70")
}

; Fonction pour mettre en pause
PauseMacro(*) {
    global isMacroRunning := false
    UpdateStatus("Macro paused")
}

; Fonction pour arrêter
StopMacro(*) {
    global isMacroRunning := false
    global isRunning := false
    Send("{z up}")
    Send("{q up}")
    Send("{s up}")
    Send("{d up}")
    Send("{Space up}")
    
    if (mainGui != "")
        mainGui.Destroy()
    if (miniGui != "")
        miniGui.Destroy()
    DestroyStatusDisplay()
    CreateMainInterface()
    UpdateStatus("Macro stopped immediately")
}

; Fonction principale de la macro
StartMacroFunction() {
    global isRunning := true
    FocusGameWindow()
    Sleep(1000)
    CreateStatusDisplay("Macro started!")
    Sleep(1000)
    
    Loop {
        if (!isRunning || !isMacroRunning) {
            UpdateStatus("Macro stopped by user")
            break
        }
        
        UpdateStatus("Phase 1: Initial character reset")
        ResetCharacter()
        if (!isRunning || !isMacroRunning) 
            break
        Sleep(2000)
        
        UpdateStatus("Phase 2: Moving right")
        MoveToRight()
        if (!isRunning || !isMacroRunning) 
            break
        Sleep(1000)
        
        UpdateStatus("Phase 3: Adjusting left")
        MoveToLeft()
        if (!isRunning || !isMacroRunning) 
            break
        Sleep(1000)
        
        UpdateStatus("Phase 4: Detecting position")
        cameraDetected := DetectCameraPosition()
        if (!isRunning || !isMacroRunning) 
            break
        
        if (cameraDetected) {
            UpdateStatus("Phase 5: Navigating to " . selectedField)
            NavigateToField()
            if (!isRunning || !isMacroRunning) 
                break
        }
        else {
            UpdateStatus("Position 2 detected - Restarting cycle")
            Sleep(1000)
            continue
        }
        
        UpdateStatus("Phase 6: Farming in progress")
        FarmLoop()
        if (!isRunning || !isMacroRunning) 
            break
        
        UpdateStatus("Phase 7: Navigating to Hive")
        NavigateToHive()
        if (!isRunning || !isMacroRunning) 
            break
        
        UpdateStatus("Phase 8: Waiting for empty bag")
        WaitForEmptyBag()
        if (!isRunning || !isMacroRunning) 
            break
        
        ResetPosition()
    }
}

; Déplacement vers la droite
MoveToRight() {
    UpdateStatus("Moving right...")
    Send("{z down}")
    Sleep(120)
    if (!isRunning || !isMacroRunning) {
        Send("{z up}")
        return
    }
    Send("{z up}")
    Send("{d down}")
    Sleep(4500)
    if (!isRunning || !isMacroRunning) {
        Send("{d up}")
        return
    }
    Send("{d up}")
    UpdateStatus("Movement completed")
}

; Déplacement vers la gauche
MoveToLeft() {
    UpdateStatus("Moving left...")
    Send("{q down}")
    Sleep(170)
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")
    UpdateStatus("Movement completed")
}

; Détection de la position de la caméra par couleur
DetectCameraPosition() {
    color1 := PixelGetColor(1727, 401, "RGB")
    color2 := PixelGetColor(1727, 401, "RGB")
    
    UpdateStatus("Detected color: " . color1)
    Sleep(500)
    
    if (color1 = 0x49372E || color1 = 0x49382E || color1 = 0x47362C || color1 = 0x402E22 || color1 = 0x3E2C21 || color1 = 0x3E2D22) {
        currentPosition := "position1"
        UpdateStatus("Position 1 detected - Navigation allowed")
        return true
    }
    else if (color1 = 0x41AA4D) {
        currentPosition := "position2"
        UpdateStatus("Position 2 detected - Reset to return to position 1")
        ResetCharacter()
        return false
    }
    else {
        currentPosition := "unknown"
        UpdateStatus("Unknown position - Character reset needed")
        ResetCharacter()
        return false
    }
}

; Navigation vers le champ de farming
NavigateToField() {
    UpdateStatus("Navigating to field...")
    
    Send("{q down}")
    Sleep(500)
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")
    
    Send("{s down}")
    Sleep(200)
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")
    
    Send("{q down}")
    Sleep(500)
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")

    Send("{s down}")
    Sleep(200)
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Send("{q down}")
    Sleep(420)
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")

    Send("{s down}")
    Sleep(520)
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Send("{d down}")
    Sleep(3400)
    if (!isRunning || !isMacroRunning) {
        Send("{d up}")
        return
    }
    Send("{d up}")
    
    Send("{s down}")
    Sleep(700)
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Send("{e}")
    Sleep(4000)

    Send("{d down}")
    Sleep(7400)
    if (!isRunning || !isMacroRunning) {
        Send("{d up}")
        return
    }
    Send("{d up}")

    Send("{s down}")
    Sleep(1520)
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Send("{z down}")
    Sleep(1730)
    if (!isRunning || !isMacroRunning) {
        Send("{z up}")
        return
    }
    Send("{z up}")

    Send("{d down}")
    Sleep(2500)
    if (!isRunning || !isMacroRunning) {
        Send("{d up}")
        return
    }
    Send("{d up}")
    Sleep(12000)

    Send("{s down}")
    Sleep(1400)
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Send("{s down}")
    Sleep(1100)
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")
    Sleep(1700)
    Send("{z down}")
    Sleep(1100)
    if (!isRunning || !isMacroRunning) {
        Send("{z up}")
        return
    }
    Send("{z up}")

    Sleep(1700)

    Send("{s down}")
    Sleep(1100)
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Sleep(1700)

    Send("{z down}")
    Sleep(1100)
    if (!isRunning || !isMacroRunning) {
        Send("{z up}")
        return
    }
    Send("{z up}")

    Sleep(1700)

    Send("{s down}")
    Sleep(1100)
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Sleep(1700)

    Send("{z down}")
    Sleep(1100)
    if (!isRunning || !isMacroRunning) {
        Send("{z up}")
        return
    }
    Send("{z up}")

    Sleep(1700)

    Send("{q down}")
    Sleep(300)
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")

    Send("{s down}")
    Sleep(1100)
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Send("{q down}")
    Sleep(300)
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")

    Send("{z down}")
    Sleep(1100)
    if (!isRunning || !isMacroRunning) {
        Send("{z up}")
        return
    }
    Send("{z up}")
    
    Send("{q down}")
    Sleep(300)
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")

    Send("{s down}")
    Sleep(1800)
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Send("{q down}")
    Sleep(1800)
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")

    Send("{d down}")
    Sleep(2000)
    if (!isRunning || !isMacroRunning) {
        Send("{d up}")
        return
    }
    Send("{d up}")

    Send("{z down}")
    Sleep(1500)
    if (!isRunning || !isMacroRunning) {
        Send("{z up}")
        return
    }
    Send("{z up}")

    UpdateStatus("Arrived at field - Starting pattern")
    Sleep(1000)
}

; Boucle de farming avec détection du sac plein
FarmLoop() {
    global bagFull
    bagFull := false

    UpdateStatus("Starting farming pattern")

    ; Maintenir le clic gauche pour farmer en continu
    Send("{LButton down}")

    ; Pattern de farming complexe anti-drift
    while true {
        if (!isRunning || !isMacroRunning || bagFull) {
            Send("{LButton up}")
            break
        }

        ; Étape 1: Droite + Avance
        UpdateStatus("Pattern: Right + Forward")
        Send("{d down}")
        Sleep(800)
        Send("{d up}")
        Send("{z down}")
        Sleep(600)
        Send("{z up}")
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 2: Gauche + Avance
        UpdateStatus("Pattern: Left + Forward")
        Send("{q down}")
        Sleep(800)
        Send("{q up}")
        Send("{z down}")
        Sleep(600)
        Send("{z up}")
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 3: Droite + Avance
        UpdateStatus("Pattern: Right + Forward")
        Send("{d down}")
        Sleep(800)
        Send("{d up}")
        Send("{z down}")
        Sleep(600)
        Send("{z up}")
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 4: Gauche + Avance
        UpdateStatus("Pattern: Left + Forward")
        Send("{q down}")
        Sleep(800)
        Send("{q up}")
        Send("{z down}")
        Sleep(600)
        Send("{z up}")
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 5: Droite + Avance
        UpdateStatus("Pattern: Right + Forward")
        Send("{d down}")
        Sleep(800)
        Send("{d up}")
        Send("{z down}")
        Sleep(600)
        Send("{z up}")
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 6: Gauche + Avance
        UpdateStatus("Pattern: Left + Forward")
        Send("{q down}")
        Sleep(800)
        Send("{q up}")
        Send("{z down}")
        Sleep(600)
        Send("{z up}")
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Retour symétrique pour éviter le drift
        UpdateStatus("Pattern: Symmetric return")

        ; Étape 7: Recul léger + Gauche
        Send("{s down}")
        Sleep(400)
        Send("{s up}")
        Send("{q down}")
        Sleep(800)
        Send("{q up}")
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 8: Recul + Droite
        Send("{s down}")
        Sleep(600)
        Send("{s up}")
        Send("{d down}")
        Sleep(800)
        Send("{d up}")
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 9: Recul léger + Gauche
        Send("{s down}")
        Sleep(400)
        Send("{s up}")
        Send("{q down}")
        Sleep(800)
        Send("{q up}")
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 10: Recul + Droite
        Send("{s down}")
        Sleep(600)
        Send("{s up}")
        Send("{d down}")
        Sleep(800)
        Send("{d up}")
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Détection si le sac est plein (par image)
        CheckBagFull()

        Sleep(500)
        if (!isRunning || !isMacroRunning) {
            break
        }
    }

    ; Relâcher le clic gauche
    Send("{LButton up}")
    UpdateStatus("Pattern completed - Full bag detected")
}


; Vérification si le sac est plein par détection d'image
CheckBagFull() {
    try {
        if (ImageSearch(&foundX, &foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*50 " . A_ScriptDir . "\bag_full.png")) {
            global bagFull := true
            MsgBox("Full bag detected!")
        }
    } catch Error as e {
        ; Gestion silencieuse des erreurs de recherche d'image
    }
}

; Navigation vers le Hive
NavigateToHive() {
    Send("{s down}")
    Sleep(2000)
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")
    
    Send("{q down}")
    Sleep(1000)
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")
    
    Send("{z down}")
    Sleep(1500)
    if (!isRunning || !isMacroRunning) {
        Send("{z up}")
        return
    }
    Send("{z up}")
    
    Send("{e}")
    Sleep(2000)
}

; Attente que le sac soit vide
WaitForEmptyBag() {
    global bagEmpty := false
    
    Loop {
        if (!isRunning || !isMacroRunning || bagEmpty) {
            break
        }
        
        CheckBagEmpty()
        
        Sleep(1000)
    }
}

; Vérification si le sac est vide
CheckBagEmpty() {
    try {
        if (ImageSearch(&foundX, &foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*50 " . A_ScriptDir . "\bag_empty.png")) {
            global bagEmpty := true
            global bagFull := false
            MsgBox("Empty bag detected!")
        }
    } catch Error as e {
        ; Gestion silencieuse des erreurs de recherche d'image
    }
}

; Reset du personnage quand position incorrecte
ResetCharacter() {
    UpdateStatus("Resetting character...")
    
    Send("{Escape down}")
    Sleep(200)
    Send("{Escape up}")
    
    Send("{r down}")
    Sleep(100)
    Send("{r up}")
    
    Send("{Enter down}")
    Sleep(100)
    Send("{Enter up}")
    
    Sleep(2000)
    if (!isRunning || !isMacroRunning) 
        return
    
    UpdateStatus("Reset completed - Redetecting position...")
}

; Reset de la position pour recommencer
ResetPosition() {
    Send("{s down}")
    Sleep(3000)
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")
    
    global bagFull := false
    global bagEmpty := false
}

; Focus sur la fenêtre du jeu
FocusGameWindow() {
    WinActivate("Roblox")
    Sleep(1000)
    return
}

; Créer l'affichage de statut
CreateStatusDisplay(initialText := "Ready") {
    global statusGui
    
    if (statusGui != "") {
        statusGui.Destroy()
    }
    
    statusGui := Gui()
    statusGui.Opt("+AlwaysOnTop +ToolWindow -Caption +E0x20")
    statusGui.Add("Text", "x10 y10 w300 h30 cWhite", initialText)
    statusGui.BackColor := "000000"
    statusGui.Show("x10 y10 w320 h50 NoActivate")
}

; Mettre à jour le statut affiché
UpdateStatus(text) {
    global statusGui
    
    if (statusGui != "") {
        statusGui["Static1"].Value := text
    }
}

; Détruire l'affichage de statut
DestroyStatusDisplay() {
    global statusGui
    
    if (statusGui != "") {
        statusGui.Destroy()
        statusGui := ""
    }
}

; Démarrer l'interface au lancement
CreateMainInterface()

; Raccourcis clavier pour l'interface
F1::StartMacro()
F2::PauseMacro()
F3::StopMacro() 