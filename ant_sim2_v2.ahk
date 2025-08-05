#SingleInstance Force
#Requires AutoHotkey v2.0

; Include JSON library
#Include JSON.ahk

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
global moveSpeed := 220 ; Vitesse de mouvement par défaut (%)
global antSpeed := 103 ; Vitesse des fourmis par défaut (%)
global selectedAnthillSlot := 1 ; Slot d'anthill sélectionné par défaut
global AnthillSlot := "1" ; Slot d'anthill pour l'interface

; Variables pour la configuration JSON
global config := {}
global settingsFile := "settings.json"

; Charger la configuration AVANT de déclarer les autres variables globales
LoadConfig()

; Fonction pour ajuster les temps selon la vitesse de mouvement
AdjustTime(baseTime, targetSpeed := 220) {
    ratio := targetSpeed / moveSpeed
    return Round(baseTime * ratio)
}

; Fonction pour charger la configuration depuis le fichier JSON
LoadConfig() {
    try {
        if (FileExist(settingsFile)) {
            fileContent := FileRead(settingsFile)
            config := JSON.Parse(fileContent)
            

            
            ; Appliquer les valeurs par défaut
            try {
                ; Accéder aux propriétés avec la syntaxe correcte pour AHK v2
                defaults := config["defaults"]
                global moveSpeed := defaults["moveSpeed"]
                global antSpeed := defaults["antSpeed"]
                global selectedAnthillSlot := defaults["selectedAnthillSlot"]
                global FieldChoice := defaults["selectedField"]
                global selectedField := FieldChoice = 1 ? "Rose Field" : "Cedar Field"
                

            } catch Error as e {
                ; Utiliser les valeurs par défaut si la propriété n'existe pas
            }
        } else {
            ; Créer un fichier de configuration par défaut
            SaveConfig()
        }
    } catch Error as e {
        MsgBox("Erreur lors du chargement de la configuration: " . e.Message)
    }
}

; Fonction pour sauvegarder la configuration dans le fichier JSON
SaveConfig() {
    global FieldChoice, moveSpeed, antSpeed, selectedAnthillSlot
    
    try {
        ; S'assurer que les variables ont des valeurs par défaut
        FieldChoice := FieldChoice ? FieldChoice : 1
        moveSpeed := moveSpeed ? moveSpeed : 220
        antSpeed := antSpeed ? antSpeed : 103
        selectedAnthillSlot := selectedAnthillSlot ? selectedAnthillSlot : 1
        
        ; Créer l'objet config étape par étape
        config := {}
        config.defaults := {}
        config.defaults.selectedField := FieldChoice
        config.defaults.moveSpeed := moveSpeed
        config.defaults.antSpeed := antSpeed
        config.defaults.selectedAnthillSlot := selectedAnthillSlot
        config.anthillSlots := ["1", "3"]
        
        jsonString := JSON.Stringify(config, 4)
        FileDelete(settingsFile)
        FileAppend(jsonString, settingsFile)
        

    } catch Error as e {
        MsgBox("Erreur lors de la sauvegarde de la configuration: " . e.Message)
    }
}



; Créer l'interface principale
CreateMainInterface() {
    global mainGui := Gui()
    global ddl  ; Variable globale pour stocker le contrôle DropDownList
    global antSpeedEdit  ; Variable globale pour stocker le contrôle AntSpeed
    global moveSpeedEdit  ; Variable globale pour stocker le contrôle MoveSpeed
    global roseFieldRadio  ; Variable globale pour stocker le contrôle Rose Field
    global cedarFieldRadio  ; Variable globale pour stocker le contrôle Cedar Field
    
    mainGui.Opt("+AlwaysOnTop +ToolWindow")
    mainGui.Title := "Ant Sim 2"
    
    mainGui.Add("Text", "x10 y10 w200 h20 cBlue", "Field Selection:")
    
    ; Créer les boutons radio avec la sélection depuis la config
    if (FieldChoice = 1) {
        roseFieldRadio := mainGui.Add("Radio", "x10 y35 w100 h20 Checked", "Rose Field")
        cedarFieldRadio := mainGui.Add("Radio", "x120 y35 w100 h20", "Cedar Field")
    } else {
        roseFieldRadio := mainGui.Add("Radio", "x10 y35 w100 h20", "Rose Field")
        cedarFieldRadio := mainGui.Add("Radio", "x120 y35 w100 h20 Checked", "Cedar Field")
    }
    
    mainGui.Add("Text", "x10 y70 w200 h20 cBlue", "Move Speed (%):")
    moveSpeedEdit := mainGui.Add("Edit", "x10 y95 w80 h20", moveSpeed)
    mainGui.Add("Text", "x100 y95 w100 h20 cGray", "Default: 220%")
    
    mainGui.Add("Text", "x10 y125 w200 h20 cBlue", "Ant Speed (%):")
    antSpeedEdit := mainGui.Add("Edit", "x10 y150 w80 h20", antSpeed)
    mainGui.Add("Text", "x100 y150 w100 h20 cGray", "Default: 103%")
    
    mainGui.Add("Text", "x10 y175 w200 h20 cBlue", "Anthill Slot:")
    try {
        ddl := mainGui.Add("DropDownList", "x10 y200 w60 h50", config.anthillSlots)
    } catch {
        ddl := mainGui.Add("DropDownList", "x10 y200 w60 h50", ["1", "3"])
    }
    
    ; Sélectionner la valeur par défaut (convertir en index)
    if (selectedAnthillSlot = 1) {
        ddl.Choose(1)
    } else if (selectedAnthillSlot = 3) {
        ddl.Choose(2)
    } else {
        ddl.Choose(1) ; Par défaut
    }
    
    mainGui.Add("Button", "x10 y260 w80 h30", "Start (F1)").OnEvent("Click", StartMacro)
    mainGui.Add("Button", "x100 y260 w80 h30", "Pause (F2)").OnEvent("Click", PauseMacro)
    mainGui.Add("Button", "x190 y260 w80 h30", "Stop (F3)").OnEvent("Click", StopMacro)
    mainGui.Add("Text", "x10 y300 w260 h20 cGray", "Status: Ready")
    mainGui.Add("Text", "x10 y320 w260 h20 cGray", "Selected Field: Rose Field")
    mainGui.Add("Text", "x10 y340 w260 h40 cGreen", "Hotkeys:`nF1: Start | F2: Pause | F3: Stop")
    
    mainGui.Show("x100 y100 w280 h380")
}

; Fonction pour démarrer la macro
StartMacro(*) {
    global isMacroRunning := true
    global selectedField := FieldChoice = 1 ? "Rose Field" : "Cedar Field"
    global mainGui
    global moveSpeed
    global antSpeed
    global selectedAnthillSlot
    global ddl
    global antSpeedEdit
    global moveSpeedEdit
    global roseFieldRadio
    global cedarFieldRadio
    global FieldChoice
    
    ; Met à jour toutes les variables vXXX de l'interface si elle existe
    if (mainGui != "") {
        ; Mettre à jour les variables de l'interface
        mainGui.Submit(false)
        
        ; Récupérer directement la valeur du DropDownList via ddl.Text
        selectedAnthillSlot := Integer(ddl.Text)
        
        ; Si aucune valeur n'est sélectionnée, utiliser la première (1)
        if (!selectedAnthillSlot || selectedAnthillSlot = "")
            selectedAnthillSlot := 1
        
        ; Mettre à jour les autres variables
        moveSpeed := Integer(moveSpeedEdit.Text)
        antSpeed := Integer(antSpeedEdit.Text)
        
        ; Récupérer le FieldChoice depuis les boutons radio
        if (roseFieldRadio.Value = 1) {
            FieldChoice := 1
        } else if (cedarFieldRadio.Value = 1) {
            FieldChoice := 2
        }
        

        
        ; Sauvegarder la configuration avec les nouvelles valeurs
        SaveConfig()
        

    }
    
    ; Fermer l'interface principale si elle existe
    If (mainGui != "")
    {
        mainGui.Destroy()
        mainGui := ""
    }
    
    CreateMinimizedInterface()
    StartMacroFunction()
}

; Créer l'interface réduite
CreateMinimizedInterface() {
    global miniGui := Gui()
    global selectedAnthillSlot
    miniGui.Opt("+AlwaysOnTop +ToolWindow")
    miniGui.Title := "Ant Sim 2"
    
    miniGui.Add("Button", "x5 y5 w60 h25", "Start").OnEvent("Click", StartMacro)
    miniGui.Add("Button", "x70 y5 w60 h25", "Pause").OnEvent("Click", PauseMacro)
    miniGui.Add("Button", "x135 y5 w60 h25", "Stop").OnEvent("Click", StopMacro)
    miniGui.Add("Text", "x5 y35 w190 h15 cGray", "Status: Running")
    miniGui.Add("Text", "x5 y50 w190 h15 cGray", "Field: " . selectedField)
    miniGui.Add("Text", "x5 y65 w190 h15 cGray", "Speed: " . moveSpeed . "%")
    miniGui.Add("Text", "x5 y80 w190 h15 cGray", "Ant Speed: " . antSpeed . "%")
    miniGui.Add("Text", "x5 y95 w190 h15 cGray", "Anthill Slot: " . selectedAnthillSlot)
    
    miniGui.Show("x100 y100 w200 h115")
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
        if (FarmLoop()) {
            ; Si FarmLoop retourne true, recommencer depuis le début
            UpdateStatus("Restarting complete cycle from beginning")
            continue
        }
        if (!isRunning || !isMacroRunning) 
            break
        
        
        
        UpdateStatus("Phase 8: Character reset - Ready for next cycle")
        if (!isRunning || !isMacroRunning) 
            break
        
        ResetPosition()
    }
}

; Déplacement vers la droite
MoveToRight() {
    UpdateStatus("Moving right...")
    Send("{z down}")
    Sleep(AdjustTime(120))
    if (!isRunning || !isMacroRunning) {
        Send("{z up}")
        return
    }
    Send("{z up}")
    Send("{d down}")
    Sleep(AdjustTime(4500))
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
    Sleep(AdjustTime(680))
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")
        Send("{q down}")
    Sleep(AdjustTime(340))
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
    
    ; Nouvelles couleurs ajoutées avec leurs nuances
    ; Couleurs principales: 0x4F3C32, 0x503D32, 0x4B392F
    ; Nuances plus foncées: -10 à -30 pour chaque composante RGB
    ; Nuances plus claires: +10 à +30 pour chaque composante RGB
    
    ; Fonction pour créer des nuances d'une couleur
    CreateColorVariations(baseColor) {
        variations := []
        
        ; Extraire les composantes RGB
        r := (baseColor >> 16) & 0xFF
        g := (baseColor >> 8) & 0xFF
        b := baseColor & 0xFF
        
        ; Ajouter la couleur de base
        variations.Push(baseColor)
        
        ; Nuances plus foncées (-10, -20, -30 pour chaque composante)
        Loop 3 {
            offset := A_Index * 10
            newR := Max(0, r - offset)
            newG := Max(0, g - offset)
            newB := Max(0, b - offset)
            variations.Push((newR << 16) | (newG << 8) | newB)
        }
        
        ; Nuances plus claires (+10, +20, +30 pour chaque composante)
        Loop 3 {
            offset := A_Index * 10
            newR := Min(255, r + offset)
            newG := Min(255, g + offset)
            newB := Min(255, b + offset)
            variations.Push((newR << 16) | (newG << 8) | newB)
        }
        
        return variations
    }
    
    ; Créer les variations pour les nouvelles couleurs
    colorVariations1 := CreateColorVariations(0x4F3C32)
    colorVariations2 := CreateColorVariations(0x503D32)
    colorVariations3 := CreateColorVariations(0x4B392F)
    
    ; Nouvelles couleurs ajoutées par l'utilisateur
    colorVariations4 := CreateColorVariations(0x4D3B31)
    colorVariations5 := CreateColorVariations(0x4A382E)
    colorVariations6 := CreateColorVariations(0x4C3A30)
    colorVariations7 := CreateColorVariations(0x4B392F)
    colorVariations8 := CreateColorVariations(0x4E3C32)
    colorVariations9 := CreateColorVariations(0x513E33)
    colorVariations10 := CreateColorVariations(0x46352B)
    colorVariations11 := CreateColorVariations(0x49372E)
    colorVariations12 := CreateColorVariations(0x503D32)
    colorVariations13 := CreateColorVariations(0x47362C)
    colorVariations14 := CreateColorVariations(0x554136)
    colorVariations15 := CreateColorVariations(0x544035)
    colorVariations16 := CreateColorVariations(0x49372D)
    colorVariations17 := CreateColorVariations(0x4F3C32)
    colorVariations18 := CreateColorVariations(0x48362D)
    colorVariations19 := CreateColorVariations(0x513E34)
    colorVariations20 := CreateColorVariations(0x47352B)
    colorVariations21 := CreateColorVariations(0x4B3A30)
    colorVariations22 := CreateColorVariations(0x4D3B30)
    colorVariations23 := CreateColorVariations(0x523F35)
    colorVariations24 := CreateColorVariations(0x4A382F)
    colorVariations25 := CreateColorVariations(0x523E34)
    colorVariations26 := CreateColorVariations(0x503D33)
    colorVariations27 := CreateColorVariations(0x48372D)
    colorVariations28 := CreateColorVariations(0x523F34)
    
    ; Nouvelles couleurs ajoutées par l'utilisateur (25 nouvelles couleurs)
    colorVariations29 := CreateColorVariations(0x3E2C21)
    colorVariations30 := CreateColorVariations(0x3F2D22)
    colorVariations31 := CreateColorVariations(0x3D2C20)
    colorVariations32 := CreateColorVariations(0x423024)
    colorVariations33 := CreateColorVariations(0x402E23)
    colorVariations34 := CreateColorVariations(0x3D2B20)
    colorVariations35 := CreateColorVariations(0x412F23)
    colorVariations36 := CreateColorVariations(0x3C2B20)
    colorVariations37 := CreateColorVariations(0x402E22)
    colorVariations38 := CreateColorVariations(0x433125)
    colorVariations39 := CreateColorVariations(0x3E2D22)
    colorVariations40 := CreateColorVariations(0x433124)
    colorVariations41 := CreateColorVariations(0x463327)
    colorVariations42 := CreateColorVariations(0x412E23)
    colorVariations43 := CreateColorVariations(0x443125)
    colorVariations44 := CreateColorVariations(0x3B2A1F)
    colorVariations45 := CreateColorVariations(0x3F2D21)
    colorVariations46 := CreateColorVariations(0x453326)
    colorVariations47 := CreateColorVariations(0x3C2B1F)
    colorVariations48 := CreateColorVariations(0x3E2D21)
    colorVariations49 := CreateColorVariations(0x443225)
    colorVariations50 := CreateColorVariations(0x453226)
    colorVariations51 := CreateColorVariations(0x433024)
    colorVariations52 := CreateColorVariations(0x3C2A1F)
    colorVariations53 := CreateColorVariations(0x463326)
    
    ; Nouvelles couleurs ajoutées par l'utilisateur (100 nouvelles couleurs)
    colorVariations54 := CreateColorVariations(0x4A382E)
    colorVariations55 := CreateColorVariations(0x49372E)
    colorVariations56 := CreateColorVariations(0x49372D)
    colorVariations57 := CreateColorVariations(0x49382E)
    colorVariations58 := CreateColorVariations(0x45342A)
    colorVariations59 := CreateColorVariations(0x48372D)
    colorVariations60 := CreateColorVariations(0x4B392F)
    colorVariations61 := CreateColorVariations(0x4D3B31)
    colorVariations62 := CreateColorVariations(0x4F3C32)
    colorVariations63 := CreateColorVariations(0x48362D)
    colorVariations64 := CreateColorVariations(0x46352B)
    colorVariations65 := CreateColorVariations(0x4A382D)
    colorVariations66 := CreateColorVariations(0x48362C)
    colorVariations67 := CreateColorVariations(0x4A382F)
    colorVariations68 := CreateColorVariations(0x4C3A30)
    colorVariations69 := CreateColorVariations(0x47362C)
    colorVariations70 := CreateColorVariations(0x48372C)
    colorVariations71 := CreateColorVariations(0x4F3D32)
    colorVariations72 := CreateColorVariations(0x49382D)
    colorVariations73 := CreateColorVariations(0x4D3B30)
    colorVariations74 := CreateColorVariations(0x4E3C32)
    colorVariations75 := CreateColorVariations(0x47362D)
    colorVariations76 := CreateColorVariations(0x47352B)
    colorVariations77 := CreateColorVariations(0x533F35)
    colorVariations78 := CreateColorVariations(0x503D33)
    colorVariations79 := CreateColorVariations(0x4C3A2F)
    colorVariations80 := CreateColorVariations(0x523F35)
    colorVariations81 := CreateColorVariations(0x4E3C31)
    colorVariations82 := CreateColorVariations(0x46352C)
    colorVariations83 := CreateColorVariations(0x433229)
    colorVariations84 := CreateColorVariations(0x4A392F)
    colorVariations85 := CreateColorVariations(0x423228)
    colorVariations86 := CreateColorVariations(0x4C392F)
    colorVariations87 := CreateColorVariations(0x44342A)
    colorVariations88 := CreateColorVariations(0x48372E)
    colorVariations89 := CreateColorVariations(0x4B3A30)
    colorVariations90 := CreateColorVariations(0x503D32)
    colorVariations91 := CreateColorVariations(0x534036)
    colorVariations92 := CreateColorVariations(0x433228)
    colorVariations93 := CreateColorVariations(0x47362B)
    colorVariations94 := CreateColorVariations(0x4F3D33)
    colorVariations95 := CreateColorVariations(0x534035)
    colorVariations96 := CreateColorVariations(0x46342B)
    colorVariations97 := CreateColorVariations(0x47352C)
    colorVariations98 := CreateColorVariations(0x4B392E)
    colorVariations99 := CreateColorVariations(0x4B3930)
    colorVariations100 := CreateColorVariations(0x4B3A2F)
    colorVariations101 := CreateColorVariations(0x513E34)
    colorVariations102 := CreateColorVariations(0x45342B)
    colorVariations103 := CreateColorVariations(0x433329)
    colorVariations104 := CreateColorVariations(0x49372C)
    colorVariations105 := CreateColorVariations(0x4F3C31)
    colorVariations106 := CreateColorVariations(0x4C3B31)
    colorVariations107 := CreateColorVariations(0x423128)
    colorVariations108 := CreateColorVariations(0x4F3C33)
    colorVariations109 := CreateColorVariations(0x544036)
    colorVariations110 := CreateColorVariations(0x4C3B30)
    colorVariations111 := CreateColorVariations(0x44332A)
    colorVariations112 := CreateColorVariations(0x4A392E)
    colorVariations113 := CreateColorVariations(0x4C3A31)
    colorVariations114 := CreateColorVariations(0x4C3930)
    colorVariations115 := CreateColorVariations(0x4A372E)
    colorVariations116 := CreateColorVariations(0x4B382F)
    colorVariations117 := CreateColorVariations(0x443329)
    colorVariations118 := CreateColorVariations(0x4E3B31)
    colorVariations119 := CreateColorVariations(0x4F3D31)
    colorVariations120 := CreateColorVariations(0x4D3B32)
    colorVariations121 := CreateColorVariations(0x45332A)
    colorVariations122 := CreateColorVariations(0x46342A)
    colorVariations123 := CreateColorVariations(0x503E33)
    colorVariations124 := CreateColorVariations(0x523F34)
    colorVariations125 := CreateColorVariations(0x45352B)
    colorVariations126 := CreateColorVariations(0x503D34)
    colorVariations127 := CreateColorVariations(0x533F34)
    colorVariations128 := CreateColorVariations(0x544035)
    colorVariations129 := CreateColorVariations(0x4D3C31)
    colorVariations130 := CreateColorVariations(0x503C32)
    colorVariations131 := CreateColorVariations(0x47372D)
    colorVariations132 := CreateColorVariations(0x49362D)
    colorVariations133 := CreateColorVariations(0x46352A)
    colorVariations134 := CreateColorVariations(0x45352A)
    colorVariations135 := CreateColorVariations(0x523E34)
    colorVariations136 := CreateColorVariations(0x4B382E)
    colorVariations137 := CreateColorVariations(0x46342C)
    colorVariations138 := CreateColorVariations(0x49382F)
    colorVariations139 := CreateColorVariations(0x4E3B30)
    colorVariations140 := CreateColorVariations(0x503E34)
    colorVariations141 := CreateColorVariations(0x503C33)
    colorVariations142 := CreateColorVariations(0x4C392E)
    colorVariations143 := CreateColorVariations(0x4A372D)
    colorVariations144 := CreateColorVariations(0x47372C)
    colorVariations145 := CreateColorVariations(0x4D3C32)
    colorVariations146 := CreateColorVariations(0x4E3B32)
    colorVariations147 := CreateColorVariations(0x4D3A31)
    colorVariations148 := CreateColorVariations(0x513D34)
    colorVariations149 := CreateColorVariations(0x443229)
    colorVariations150 := CreateColorVariations(0x4D3A30)
    colorVariations151 := CreateColorVariations(0x46362B)
    colorVariations152 := CreateColorVariations(0x513E33)
    colorVariations153 := CreateColorVariations(0x48382E)
    
    ; Couleurs supplémentaires ajoutées par l'utilisateur
    colorVariations154 := CreateColorVariations(0x49372E)
    colorVariations155 := CreateColorVariations(0x4A382E)
    colorVariations156 := CreateColorVariations(0x45342A)
    colorVariations157 := CreateColorVariations(0x49372D)
    colorVariations158 := CreateColorVariations(0x48372D)
    colorVariations159 := CreateColorVariations(0x4B392F)
    colorVariations160 := CreateColorVariations(0x49382E)
    colorVariations161 := CreateColorVariations(0x46352B)
    colorVariations162 := CreateColorVariations(0x48362D)
    colorVariations163 := CreateColorVariations(0x4A382D)
    colorVariations164 := CreateColorVariations(0x4F3C32)
    colorVariations165 := CreateColorVariations(0x4D3B31)
    colorVariations166 := CreateColorVariations(0x48362C)
    colorVariations167 := CreateColorVariations(0x49382D)
    colorVariations168 := CreateColorVariations(0x4A382F)
    colorVariations169 := CreateColorVariations(0x48372C)
    colorVariations170 := CreateColorVariations(0x47362C)
    colorVariations171 := CreateColorVariations(0x4C3A30)
    colorVariations172 := CreateColorVariations(0x4D3B30)
    colorVariations173 := CreateColorVariations(0x4E3C32)
    colorVariations174 := CreateColorVariations(0x47352B)
    colorVariations175 := CreateColorVariations(0x47362D)
    colorVariations176 := CreateColorVariations(0x4F3D32)
    colorVariations177 := CreateColorVariations(0x4F3C31)
    colorVariations178 := CreateColorVariations(0x533F35)
    
    ; Anciennes couleurs avec leurs variations
    oldColorVariations1 := CreateColorVariations(0x49372E)
    oldColorVariations2 := CreateColorVariations(0x49382E)
    oldColorVariations3 := CreateColorVariations(0x47362C)
    oldColorVariations4 := CreateColorVariations(0x402E22)
    oldColorVariations5 := CreateColorVariations(0x3E2C21)
    oldColorVariations6 := CreateColorVariations(0x3E2D22)
    
    ; Vérifier si la couleur détectée correspond à l'une des variations
    isPosition1 := false
    
    ; Vérifier les nouvelles couleurs
    for variation in colorVariations1 {
        if (color1 = variation) {
            isPosition1 := true
            break
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations2 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations3 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    ; Vérifier les nouvelles couleurs ajoutées par l'utilisateur
    if (!isPosition1) {
        for variation in colorVariations4 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations5 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations6 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations7 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations8 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations9 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations10 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations11 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations12 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations13 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations14 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations15 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations16 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations17 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations18 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations19 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations20 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations21 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations22 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations23 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations24 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations25 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations26 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations27 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations28 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    ; Vérifier les nouvelles couleurs ajoutées par l'utilisateur (29-53)
    if (!isPosition1) {
        for variation in colorVariations29 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations30 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations31 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations32 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations33 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations34 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations35 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations36 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations37 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations38 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations39 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations40 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations41 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations42 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations43 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations44 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations45 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations46 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations47 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations48 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations49 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations50 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations51 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations52 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations53 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    ; Vérifier les nouvelles couleurs ajoutées par l'utilisateur (54-153)
    if (!isPosition1) {
        for variation in colorVariations54 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations55 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations56 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations57 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations58 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations59 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations60 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations61 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations62 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations63 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations64 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations65 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations66 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations67 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations68 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations69 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations70 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations71 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations72 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations73 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations74 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations75 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations76 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations77 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations78 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations79 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations80 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations81 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations82 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations83 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations84 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations85 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations86 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations87 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations88 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations89 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations90 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations91 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations92 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations93 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations94 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations95 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations96 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations97 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations98 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations99 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations100 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations101 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations102 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations103 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations104 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations105 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations106 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations107 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations108 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations109 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations110 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations111 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations112 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations113 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations114 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations115 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations116 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations117 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations118 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations119 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations120 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations121 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations122 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations123 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations124 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations125 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations126 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations127 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations128 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations129 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations130 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations131 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations132 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations133 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations134 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations135 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations136 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations137 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations138 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations139 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations140 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations141 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations142 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations143 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations144 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations145 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations146 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations147 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations148 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations149 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations150 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations151 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations152 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations153 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    ; Vérifier les couleurs supplémentaires ajoutées par l'utilisateur (154-178)
    if (!isPosition1) {
        for variation in colorVariations154 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations155 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations156 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations157 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations158 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations159 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations160 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations161 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations162 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations163 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations164 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations165 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations166 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations167 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations168 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations169 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations170 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations171 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations172 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations173 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations174 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations175 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations176 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations177 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in colorVariations178 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    ; Vérifier les anciennes couleurs
    if (!isPosition1) {
        for variation in oldColorVariations1 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in oldColorVariations2 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in oldColorVariations3 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in oldColorVariations4 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in oldColorVariations5 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (!isPosition1) {
        for variation in oldColorVariations6 {
            if (color1 = variation) {
                isPosition1 := true
                break
            }
        }
    }
    
    if (isPosition1) {
        currentPosition := "position1"
        UpdateStatus("Position 1 detected - Navigation allowed")
        return true
    }
    else {
        ; Si ce n'est pas la caméra 1, c'est forcément la caméra 2 (grâce à toutes les couleurs ajoutées)
        currentPosition := "position2"
        UpdateStatus("Position 2 detected - Rotating camera to align with position 1")
        
        ; Rotation légère vers la gauche pour aligner la caméra 2 comme la caméra 1
        Loop 2 {
            Send("{Left down}")
            Sleep(70) ; Pression plus longue pour rotation progressive
            Send("{Left up}")
            Sleep(100) ; Pause entre chaque pression
        }
        
        UpdateStatus("Camera aligned - Navigation allowed")
        return true ; Retourner true pour continuer vers le champ
    }
}

; Navigation vers le champ de farming
NavigateToField() {
    UpdateStatus("Navigating to field...")
    
    Send("{q down}")
    Sleep(AdjustTime(500))
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")
    
    Send("{s down}")
    Sleep(AdjustTime(200))
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")
    
    Send("{q down}")
    Sleep(AdjustTime(500))
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")

    Send("{s down}")
    Sleep(AdjustTime(200))
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Send("{q down}")
    Sleep(AdjustTime(420))
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")

    Send("{s down}")
    Sleep(AdjustTime(600))
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Send("{d down}")
    Sleep(AdjustTime(3300))
    if (!isRunning || !isMacroRunning) {
        Send("{d up}")
        return
    }
    Send("{d up}")
    
    Send("{s down}")
    Sleep(AdjustTime(700))
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Send("{e}")
    Sleep(4000)

    Send("{d down}")
    Sleep(AdjustTime(7400))
    if (!isRunning || !isMacroRunning) {
        Send("{d up}")
        return
    }
    Send("{d up}")

    Send("{s down}")
    Sleep(AdjustTime(1520))
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Send("{z down}")
    Sleep(AdjustTime(1730))
    if (!isRunning || !isMacroRunning) {
        Send("{z up}")
        return
    }
    Send("{z up}")

    Send("{d down}")
    Sleep(AdjustTime(2500))
    if (!isRunning || !isMacroRunning) {
        Send("{d up}")
        return
    }
    Send("{d up}")

    ; Délai adaptatif selon l'ant speed
    if (antSpeed > 150) {
        Sleep(5000) ; 5 secondes si ant speed > 150%
    } else {
        Sleep(16000) ; 16 secondes par défaut
    }

    Send("{s down}")
    Sleep(AdjustTime(1400))
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    ; Pattern selon l'ant speed
    if (antSpeed > 150) {
        ; Pour ant speed > 150% : directement sleep 7sec après le bloc 1134-1147
        Sleep(7000) ; Sleep de 7 secondes puis direct à ligne 1286
    } else {
        ; Pattern complet (lignes 1035 à 1091) - lignes 1149-1155 et 1173-1179
    Sleep(1700)
        
        
    Send("{s down}")
    Sleep(AdjustTime(1100))
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")
    
        Send("{z down}")
        Sleep(AdjustTime(1100))
        if (!isRunning || !isMacroRunning) {
            Send("{z up}")
            return
        }
        Send("{z up}")

        Sleep(1700)

        Send("{s down}")
        Sleep(AdjustTime(1100))
        if (!isRunning || !isMacroRunning) {
            Send("{s up}")
            return
        }
        Send("{s up}")

        Sleep(1700)

        Send("{z down}")
        Sleep(AdjustTime(1100))
        if (!isRunning || !isMacroRunning) {
            Send("{z up}")
            return
        }
        Send("{z up}")

        Sleep(1700)

        Send("{s down}")
        Sleep(AdjustTime(1100))
        if (!isRunning || !isMacroRunning) {
            Send("{s up}")
            return
        }
        Send("{s up}")

        Sleep(1700)

        Send("{z down}")
        Sleep(AdjustTime(1100))
        if (!isRunning || !isMacroRunning) {
            Send("{z up}")
            return
        }
        Send("{z up}")

        Sleep(1700)
    }

    Send("{q down}")
    Sleep(AdjustTime(300))
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")

    Send("{s down}")
    Sleep(AdjustTime(1100))
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Send("{q down}")
    Sleep(AdjustTime(300))
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")

    Send("{z down}")
    Sleep(AdjustTime(1100))
    if (!isRunning || !isMacroRunning) {
        Send("{z up}")
        return
    }
    Send("{z up}")
    
    Send("{q down}")
    Sleep(AdjustTime(300))
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")

    Send("{s down}")
    Sleep(AdjustTime(1800))
    if (!isRunning || !isMacroRunning) {
        Send("{s up}")
        return
    }
    Send("{s up}")

    Send("{q down}")
    Sleep(AdjustTime(1800))
    if (!isRunning || !isMacroRunning) {
        Send("{q up}")
        return
    }
    Send("{q up}")

    Send("{d down}")
    Sleep(AdjustTime(1150))
    if (!isRunning || !isMacroRunning) {
        Send("{d up}")
        return
    }
    Send("{d up}")

    Send("{z down}")
    Sleep(AdjustTime(180))
    if (!isRunning || !isMacroRunning) {
        Send("{z up}")
        return
    }
    Send("{z up}")

    UpdateStatus("Arrived at field - Starting pattern")
    Sleep(1000)
}

; Navigation vers le slot d'anthill spécifique
NavigateToAnthillSlot(slotNumber) {
    UpdateStatus("Navigating to Anthill Slot " . slotNumber . "...")
    
    ; Navigation spécifique selon le slot
    switch slotNumber {
        case 1:
            ; Slot 1 - Chemin complet : base + diagonale
            UpdateStatus("Slot 1 - Base path + diagonal movement")
            
            ; Chemin de base vers la droite (comme dans MoveToRight)
            Send("{z down}")
            Sleep(AdjustTime(120))
            if (!isRunning || !isMacroRunning) {
                Send("{z up}")
                return
            }
            Send("{z up}")
            Send("{d down}")
            Sleep(AdjustTime(4500))
            if (!isRunning || !isMacroRunning) {
                Send("{d up}")
                return
            }
            Send("{d up}")
            
            ; Final diagonal movement
            UpdateStatus("Slot 1 - Final diagonal movement")
            Send("{q down}")
            Send("{z down}")
            Sleep(AdjustTime(500))
            Send("{q up}")
            Send("{z up}")
            
        case 2:
            ; Slot 2 - Chemin alternatif
            UpdateStatus("Slot 2 - Alternative path")
            Send("{q down}")
            Sleep(AdjustTime(300))
            Send("{q up}")
            Send("{z down}")
            Sleep(AdjustTime(400))
            Send("{z up}")
            
        case 3:
            ; Slot 3 - Chemin simple : avancer droit puis gauche (pas de chemin de base)
            UpdateStatus("Slot 3 - Forward then left")
           Send("{z down}")
           Sleep(AdjustTime(2400)) ; Avancer tout droit pendant 2400ms
            Send("{z up}")
            sleep (200)
            Send("{q down}")
            Sleep(AdjustTime(250)) ; Aller à gauche pendant 250ms
            Send("{q up}")
            sleep (200)
            Send("{z down}")
            Sleep(AdjustTime(1500)) ; Avancer tout droit pendant 1500ms
            Send("{z up}")
            sleep (200)
            Send("{d down}{z down}")
            Sleep(AdjustTime(2000)) ; Aller à droite pendant 2000ms
            Send("{d up}{z up}")
            sleep (200)
            Send("{s down}")
            Sleep(AdjustTime(1000)) ; Reculer pendant 1000ms
            Send("{s up}")
            sleep (200)
            Send("{q down}")
            Sleep(AdjustTime(500)) ; Aller à gauche pendant 500ms
            Send("{q up}")
            sleep (200)
            
        case 4:
            ; Slot 4 - Chemin alternatif
            UpdateStatus("Slot 4 - Alternative path")
            Send("{q down}")
            Sleep(AdjustTime(400))
            Send("{q up}")
            Send("{d down}")
            Sleep(AdjustTime(200))
            Send("{d up}")
            Send("{z down}")
            Sleep(AdjustTime(500))
            Send("{z up}")
            
        case 5:
            ; Slot 5 - Chemin alternatif
            UpdateStatus("Slot 5 - Alternative path")
            Send("{d down}")
            Sleep(AdjustTime(300))
            Send("{d up}")
            Send("{q down}")
            Sleep(AdjustTime(300))
            Send("{q up}")
            Send("{z down}")
            Sleep(AdjustTime(400))
            Send("{z up}")
            
        default:
            ; Slot par défaut (1) - Chemin complet
            UpdateStatus("Default slot - Base path + diagonal movement")
            
            ; Chemin de base vers la droite
            Send("{z down}")
            Sleep(AdjustTime(120))
            if (!isRunning || !isMacroRunning) {
                Send("{z up}")
                return
            }
            Send("{z up}")
            Send("{d down}")
            Sleep(AdjustTime(4500))
            if (!isRunning || !isMacroRunning) {
                Send("{d up}")
                return
            }
            Send("{d up}")
            
            ; Final diagonal movement
            UpdateStatus("Default slot - Final diagonal movement")
            Send("{q down}")
            Send("{z down}")
            Sleep(AdjustTime(500))
            Send("{q up}")
            Send("{z up}")
    }
    
    UpdateStatus("Arrived at Anthill Slot " . slotNumber)
}

; Boucle de farming avec détection du sac plein
FarmLoop() {
    global bagFull
    bagFull := false

    UpdateStatus("Starting farming pattern")

    ; Rotation de caméra avec flèches de droite (plus fiable que la souris)
    UpdateStatus("Pattern: Camera rotation with arrow keys")
    
    ; Rotation progressive avec flèche droite (équivalent à ~15°)
    Loop 4 {
        Send("{Right down}")
        Sleep(50) ; Pression courte pour rotation progressive
        Send("{Right up}")
        Sleep(100) ; Pause entre chaque pression
    }
    
    Sleep(AdjustTime(300)) ; Pause après rotation

    ; Maintenir le clic gauche pour farmer en continu
    Send("{LButton down}")
    Sleep(500) ; Petite pause pour s'assurer que le clic est bien activé
    
    if (!isRunning || !isMacroRunning) {
        Send("{LButton up}")
        return
    }

    ; Pattern de farming complexe anti-drift
    while true {
        if (!isRunning || !isMacroRunning || bagFull) {
            break
        }
        
        ; Vérification de la productivité du backpack (toutes les 10 secondes après le début du pattern)
        static patternStartTime := 0
        static lastBagProgressCheck := 0
        
        ; Marquer le début du pattern si pas encore fait
        if (patternStartTime = 0) {
            patternStartTime := A_TickCount
        }
        
        ; Vérifier toutes les 10 secondes après le début du pattern
        if (A_TickCount - patternStartTime > 10000 && A_TickCount - lastBagProgressCheck > 10000) { ; 10 secondes
            try {
                ; Vérifier le début de la barre du backpack (même position que la détection vide)
                bagProgressColor := PixelGetColor(1619, 17, "RGB")
                
                ; Si la couleur du début de la barre est vide ET qu'on a déjà farmé un peu
                ; On attend plus longtemps avant de considérer qu'il n'y a pas de progression
                if (bagProgressColor = 0x282828 && A_TickCount - patternStartTime > 30000) { ; 30 secondes
                    UpdateStatus("Backpack ne progresse pas après 30s - Retour au début du cycle")
                    ResetCharacter()
                    Sleep(2000)
                    if (!DetectCameraPosition()) {
                        UpdateStatus("Position toujours incorrecte - Arrêt de la macro")
                        return false
                    }
                    ; Retourner true pour sortir de FarmLoop et recommencer depuis le début
                    return true
                }
            } catch Error as e {
                ; Ignorer les erreurs de détection
            }
            lastBagProgressCheck := A_TickCount
        }

        ; Étape 1: Droite + Avance
        UpdateStatus("Pattern: Right + Forward")
        Send("{d down}")
        Sleep(AdjustTime(800)) ; Distance latérale encore réduite
        Send("{d up}")
        Send("{z down}")
        Sleep(AdjustTime(200)) ; Distance vers l'avant réduite
        Send("{z up}")
        Sleep(AdjustTime(50)) ; Pause très courte entre les étapes
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 2: Gauche + Avance
        UpdateStatus("Pattern: Left + Forward")
        Send("{q down}")
        Sleep(AdjustTime(800)) ; Distance latérale réduite
        Send("{q up}")
        Send("{z down}")
        Sleep(AdjustTime(200)) ; Distance vers l'avant réduite
        Send("{z up}")
        Sleep(AdjustTime(50)) ; Pause très courte entre les étapes
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 3: Droite + Avance
        UpdateStatus("Pattern: Right + Forward")
        Send("{d down}")
        Sleep(AdjustTime(800)) ; Distance latérale réduite
        Send("{d up}")
        Send("{z down}")
        Sleep(AdjustTime(200)) ; Distance vers l'avant réduite
        Send("{z up}")
        Sleep(AdjustTime(50)) ; Pause très courte
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 4: Gauche + Avance
        UpdateStatus("Pattern: Left + Forward")
        Send("{q down}")
        Sleep(AdjustTime(800)) ; Distance latérale réduite
        Send("{q up}")
        Send("{z down}")
        Sleep(AdjustTime(200)) ; Distance vers l'avant réduite
        Send("{z up}")
        Sleep(AdjustTime(50)) ; Pause très courte
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 5: Droite + Avance
        UpdateStatus("Pattern: Right + Forward")
        Send("{d down}")
        Sleep(AdjustTime(800)) ; Distance latérale réduite
        Send("{d up}")
        Send("{z down}")
        Sleep(AdjustTime(200)) ; Distance vers l'avant réduite
        Send("{z up}")
        Sleep(AdjustTime(50)) ; Pause très courte
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 6: Gauche + Avance
        UpdateStatus("Pattern: Left + Forward")
        Send("{q down}")
        Sleep(AdjustTime(800)) ; Distance latérale réduite
        Send("{q up}")
        Send("{z down}")
        Sleep(AdjustTime(200)) ; Distance vers l'avant réduite
        Send("{z up}")
        Sleep(AdjustTime(50)) ; Pause très courte
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Retour en sens inverse (même chemin mais inversé)
        UpdateStatus("Pattern: Return Path")

        ; Étape 7: Droite + Recul (inverse de Gauche + Avance)
        UpdateStatus("Pattern: Right + Backward")
        Send("{d down}")
        Sleep(AdjustTime(800)) ; Distance latérale réduite
        Send("{d up}")
        Send("{s down}")
        Sleep(AdjustTime(200)) ; Distance vers l'arrière réduite
        Send("{s up}")
        Sleep(AdjustTime(50)) ; Pause très courte
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 8: Gauche + Recul (inverse de Droite + Avance)
        UpdateStatus("Pattern: Left + Backward")
        Send("{q down}")
        Sleep(AdjustTime(800)) ; Distance latérale réduite
        Send("{q up}")
        Send("{s down}")
        Sleep(AdjustTime(200)) ; Distance vers l'arrière réduite
        Send("{s up}")
        Sleep(AdjustTime(50)) ; Pause très courte
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 9: Droite + Recul (inverse de Gauche + Avance)
        UpdateStatus("Pattern: Right + Backward")
        Send("{d down}")
        Sleep(AdjustTime(800)) ; Distance latérale réduite
        Send("{d up}")
        Send("{s down}")
        Sleep(AdjustTime(200)) ; Distance vers l'arrière réduite
        Send("{s up}")
        Sleep(AdjustTime(50)) ; Pause très courte
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 10: Gauche + Recul (inverse de Droite + Avance)
        UpdateStatus("Pattern: Left + Backward")
        Send("{q down}")
        Sleep(AdjustTime(800)) ; Distance latérale réduite
        Send("{q up}")
        Send("{s down}")
        Sleep(AdjustTime(200)) ; Distance vers l'arrière réduite
        Send("{s up}")
        Sleep(AdjustTime(50)) ; Pause très courte
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 11: Droite + Recul (inverse de Gauche + Avance)
        UpdateStatus("Pattern: Right + Backward")
        Send("{d down}")
        Sleep(AdjustTime(800)) ; Distance latérale réduite
        Send("{d up}")
        Send("{s down}")
        Sleep(AdjustTime(200)) ; Distance vers l'arrière réduite
        Send("{s up}")
        Sleep(AdjustTime(50)) ; Pause très courte
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Étape 12: Gauche + Recul (inverse de Droite + Avance)
        UpdateStatus("Pattern: Left + Backward")
        Send("{q down}")
        Sleep(AdjustTime(800)) ; Distance latérale réduite
        Send("{q up}")
        Send("{s down}")
        Sleep(AdjustTime(200)) ; Distance vers l'arrière réduite
        Send("{s up}")
        Sleep(AdjustTime(50)) ; Pause très courte
        if (!isRunning || !isMacroRunning) {
            break
        }

        ; Détection si le sac est plein (par image)
        if (CheckBagFull()) {
            ; Relâcher le clic gauche
            Send("{LButton up}")
            UpdateStatus("Pattern completed - Full bag detected, restarting cycle")
            return true ; Signal pour recommencer depuis le début
        }

        Sleep(500)
        if (!isRunning || !isMacroRunning) {
            break
        }
    }

    ; Relâcher le clic gauche
    Send("{LButton up}")
    UpdateStatus("Pattern completed")
    return false
}


; Vérification si le sac est plein par détection de couleur
CheckBagFull() {
    try {
        color := PixelGetColor(1807, 10, "RGB")
        if (color = 0xC83838) {
            global bagFull := true
            UpdateStatus("Full bag detected - Resetting character for conversion")
            ResetCharacterForConversion()
            
            ; Navigation vers le slot d'anthill sélectionné
NavigateToAnthillSlot(selectedAnthillSlot)

    Sleep(1000)

; Commencer la conversion
UpdateStatus("Starting conversion process")
    Send("{e}")
    Sleep(2000)
            
            ; Attendre que le sac soit vide
            WaitForEmptyBag()
            
            ; Retourner au début du cycle complet
            UpdateStatus("Bag empty - Restarting complete cycle")
            return true ; Signal pour sortir de FarmLoop et recommencer depuis le début
        }
    } catch Error as e {
        ; Gestion silencieuse des erreurs de détection de couleur
    }
}



; Attente que le sac soit vide
WaitForEmptyBag() {
    global bagEmpty := false
    
    UpdateStatus("Waiting for bag to empty...")
    
    Loop {
        if (!isRunning || !isMacroRunning || bagEmpty) {
            break
        }
        
        CheckBagEmpty()
        
        Sleep(1000)
    }
    
    ; Bag vide détecté - prêt pour le prochain cycle
    UpdateStatus("Bag empty - Waiting 10 seconds for ants to finish...")
    Sleep(10000) ; Attendre 10 secondes pour que les fourmis finissent
    UpdateStatus("Bag empty - Ready for next cycle")
}

; Vérification si le sac est vide
CheckBagEmpty() {
    try {
        color := PixelGetColor(1619, 17, "RGB")
        if (color = 0x282828) {
            global bagEmpty := true
            global bagFull := false
            UpdateStatus("Empty bag detected!")
        }
    } catch Error as e {
        ; Gestion silencieuse des erreurs de détection de couleur
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
    
    ; Délai supplémentaire pour laisser le temps au jeu de se charger
    Sleep(800)
    
    UpdateStatus("Reset completed - Redetecting position...")
}

; Reset du personnage pour la conversion (délai plus long)
ResetCharacterForConversion() {
    UpdateStatus("Resetting character for conversion...")
    
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
    
    ; Délai plus long pour la conversion
    Sleep(2000)
    
    UpdateStatus("Reset completed for conversion...")
}

; Reset de la position pour recommencer
ResetPosition() {
    Send("{s down}")
    Sleep(AdjustTime(3000))
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