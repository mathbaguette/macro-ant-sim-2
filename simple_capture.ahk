#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%

; Script utilitaire simplifié pour capturer les coordonnées
F4::CaptureColor()
F5::ShowInstructions()
F6::CreateTestImages()

ShowInstructions() {
    MsgBox, Script utilitaire de capture`n`nF4: Capturer une couleur (clic gauche)`nF5: Afficher ces instructions`nF6: Créer des images de test
}

; Capture de couleur au clic
CaptureColor() {
    MsgBox, Cliquez sur la zone de couleur à capturer, puis appuyez sur F4
    KeyWait, F4, D
    MouseGetPos, mouseX, mouseY
    PixelGetColor, color, %mouseX%, %mouseY%, RGB
    MsgBox, Couleur capturée: %color%`nCoordonnées: X=%mouseX%, Y=%mouseY%`n`nCopiez ces coordonnées dans le script principal!
}

; Créer des images de test (placeholders)
CreateTestImages() {
    ; Créer un fichier texte avec les instructions
    FileDelete, bag_full.png
    FileDelete, bag_empty.png
    
    ; Créer des fichiers de test
    FileAppend, Test image for bag full, bag_full.png
    FileAppend, Test image for bag empty, bag_empty.png
    
    MsgBox, Images de test créées!`n`nREMARQUE: Ces sont des fichiers texte de test.`nVous devez les remplacer par de vraies captures d'écran PNG.
}

; Instructions au démarrage
ShowInstructions() 