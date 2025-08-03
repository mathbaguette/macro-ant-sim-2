#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
SetKeyDelay, 10, 10

; Variables globales
global isRunning := false
global bagFull := false
global bagEmpty := false
global currentPosition := "right"

; Configuration des touches
F1::StartMacro()
F2::StopMacro()
F3::ExitApp

; Fonction principale pour démarrer la macro
StartMacro() {
    global isRunning := true
    MsgBox, Macro démarrée! Appuyez sur F2 pour arrêter.
    
    Loop {
        if (!isRunning) {
            break
        }
        
        ; Phase 1: Déplacement initial vers la droite
        MoveToRight()
        Sleep, 1000
        
        ; Phase 2: Petit déplacement vers la gauche
        MoveToLeft()
        Sleep, 1000
        
        ; Phase 3: Détection de la position de la caméra
        cameraDetected := DetectCameraPosition()
        
        ; Phase 4: Navigation vers le champ de farming (seulement si bonne position)
        if (cameraDetected) {
            NavigateToField()
        } else {
            ; Si position incorrecte, redétecter après reset
            Sleep, 1000
            cameraDetected := DetectCameraPosition()
            if (cameraDetected) {
                NavigateToField()
            } else {
                ; Si toujours incorrect, recommencer le cycle
                continue
            }
        }
        
        ; Phase 5: Boucle de farming avec détection du sac plein
        FarmLoop()
        
        ; Phase 6: Navigation vers le Hive pour convertir
        NavigateToHive()
        
        ; Phase 7: Boucle d'attente que le sac soit vide
        WaitForEmptyBag()
        
        ; Reset pour recommencer le cycle
        ResetPosition()
    }
}

; Fonction pour arrêter la macro
StopMacro() {
    global isRunning := false
    MsgBox, Macro arrêtée!
}

; Déplacement vers la droite
MoveToRight() {
    Send, {D down}
    Sleep, 2000  ; Ajustez selon la distance nécessaire
    Send, {D up}
}

; Déplacement vers la gauche
MoveToLeft() {
    Send, {A down}
    Sleep, 500   ; Petit déplacement
    Send, {A up}
}

; Détection de la position de la caméra par couleur
DetectCameraPosition() {
    ; Capture d'écran pour détecter la couleur
    PixelGetColor, color1, 100, 100, RGB  ; Position 1
    PixelGetColor, color2, 200, 100, RGB  ; Position 2
    
    ; Comparaison des couleurs pour déterminer la position
    if (color1 = 0xFFFFFF) {  ; Blanc - position 1
        currentPosition := "position1"
        MsgBox, Position 1 détectée - Navigation autorisée
        return true
    } else if (color2 = 0xFFFFFF) {  ; Blanc - position 2
        currentPosition := "position2"
        MsgBox, Position 2 détectée - Navigation autorisée
        return true
    } else {
        currentPosition := "unknown"
        MsgBox, Position inconnue - Reset du personnage nécessaire
        ResetCharacter()
        return false
    }
}

; Navigation vers le champ de farming
NavigateToField() {
    ; Path vers le champ (ajustez selon votre jeu)
    Send, {W down}
    Sleep, 3000
    Send, {W up}
    
    ; Détection d'arrivée au champ
    Sleep, 2000
}

; Boucle de farming avec détection du sac plein
FarmLoop() {
    global bagFull := false
    
    Loop {
        if (!isRunning || bagFull) {
            break
        }
        
        ; Action de farming
        Send, {Space}
        Sleep, 1000
        
        ; Détection si le sac est plein (par image)
        CheckBagFull()
        
        Sleep, 500
    }
}

; Vérification si le sac est plein par détection d'image
CheckBagFull() {
    ; Capture d'écran de la zone du sac
    ImageSearch, foundX, foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 bag_full.png
    
    if (ErrorLevel = 0) {
        global bagFull := true
        MsgBox, Sac plein détecté!
    }
}

; Navigation vers le Hive
NavigateToHive() {
    ; Path vers le Hive
    Send, {S down}
    Sleep, 2000
    Send, {S up}
    
    ; Rotation vers le Hive
    Send, {A down}
    Sleep, 1000
    Send, {A up}
    
    ; Avancer vers le Hive
    Send, {W down}
    Sleep, 1500
    Send, {W up}
    
    ; Action de conversion
    Send, {E}
    Sleep, 2000
}

; Attente que le sac soit vide
WaitForEmptyBag() {
    global bagEmpty := false
    
    Loop {
        if (!isRunning || bagEmpty) {
            break
        }
        
        ; Détection si le sac est vide
        CheckBagEmpty()
        
        Sleep, 1000
    }
}

; Vérification si le sac est vide
CheckBagEmpty() {
    ; Capture d'écran de la zone du sac
    ImageSearch, foundX, foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 bag_empty.png
    
    if (ErrorLevel = 0) {
        global bagEmpty := true
        global bagFull := false
        MsgBox, Sac vide détecté!
    }
}

; Reset du personnage quand position incorrecte
ResetCharacter() {
    MsgBox, Reset du personnage en cours...
    
    ; Retour à la position de départ
    Send, {S down}
    Sleep, 3000
    Send, {S up}
    
    ; Rotation pour se repositionner
    Send, {A down}
    Sleep, 1000
    Send, {A up}
    
    ; Avancer légèrement pour se repositionner
    Send, {W down}
    Sleep, 1000
    Send, {W up}
    
    ; Attendre un peu avant de redétecter
    Sleep, 2000
    
    MsgBox, Reset terminé - Redétection de la position...
}

; Reset de la position pour recommencer
ResetPosition() {
    ; Retour à la position de départ
    Send, {S down}
    Sleep, 3000
    Send, {S up}
    
    ; Reset des variables
    global bagFull := false
    global bagEmpty := false
}

; Instructions d'utilisation
MsgBox, Macro Roblox Farming`n`nF1: Démarrer la macro`nF2: Arrêter la macro`nF3: Quitter`n`nAssurez-vous d'avoir les images bag_full.png et bag_empty.png dans le même dossier!
