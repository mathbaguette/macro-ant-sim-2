#Requires AutoHotkey v2.0

; Variables globales pour les déplacements
global moveSpeed := 220
global antSpeed := 103
global isRunning := true
global isMacroRunning := true

; Fonction pour ajuster le temps selon la vitesse de mouvement
AdjustTime(baseTime, targetSpeed := 220) {
    ratio := targetSpeed / moveSpeed
    return Round(baseTime * ratio)
}

; Fonction pour ajuster le temps d'attente des fourmis
AdjustAntWaitTime(baseTime, targetAntSpeed := 103) {
    ratio := targetAntSpeed / antSpeed
    return Round(baseTime * ratio)
}

; Fonction pour mettre à jour le statut (optionnel pour les tests)
UpdateStatus(message) {
    ; Pour les tests, on peut juste afficher dans la console
    ; ou laisser vide si pas besoin
}

; Fonction pour reset le personnage
ResetCharacter() {
d
    
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

    Sleep(2000)

}

; Reset au début


; Boucle du pattern
while true {
    if (!isRunning || !isMacroRunning) {
        break
    }
    
    Sleep(2000)
    ResetCharacter()
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
}
