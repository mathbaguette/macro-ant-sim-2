#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%

; Script utilitaire pour capturer les coordonnées et images
F4::CaptureColor()
F5::CaptureBagFull()
F6::CaptureBagEmpty()
F7::ShowInstructions()

ShowInstructions() {
    MsgBox, Script utilitaire de capture`n`nF4: Capturer une couleur (clic gauche)`nF5: Capturer l'image du sac plein`nF6: Capturer l'image du sac vide`nF7: Afficher ces instructions
}

; Capture de couleur au clic
CaptureColor() {
    MsgBox, Cliquez sur la zone de couleur à capturer, puis appuyez sur F4
    KeyWait, F4, D
    MouseGetPos, mouseX, mouseY
    PixelGetColor, color, %mouseX%, %mouseY%, RGB
    MsgBox, Couleur capturée: %color%`nCoordonnées: X=%mouseX%, Y=%mouseY%
}

; Capture d'image du sac plein
CaptureBagFull() {
    MsgBox, Placez votre souris sur le coin supérieur gauche de la zone du sac plein, puis appuyez sur F5
    KeyWait, F5, D
    MouseGetPos, startX, startY
    
    MsgBox, Maintenant placez votre souris sur le coin inférieur droit de la zone du sac plein, puis appuyez sur F5
    KeyWait, F5, D
    MouseGetPos, endX, endY
    
    ; Capture d'écran de la zone
    width := endX - startX
    height := endY - startY
    
    ; Sauvegarde de l'image
    pToken := Gdip_Startup()
    pBitmap := Gdip_BitmapFromScreen(startX "|" startY "|" width "|" height)
    Gdip_SaveBitmapToFile(pBitmap, "bag_full.png")
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
    
    MsgBox, Image du sac plein sauvegardée: bag_full.png
}

; Capture d'image du sac vide
CaptureBagEmpty() {
    MsgBox, Placez votre souris sur le coin supérieur gauche de la zone du sac vide, puis appuyez sur F6
    KeyWait, F6, D
    MouseGetPos, startX, startY
    
    MsgBox, Maintenant placez votre souris sur le coin inférieur droit de la zone du sac vide, puis appuyez sur F6
    KeyWait, F6, D
    MouseGetPos, endX, endY
    
    ; Capture d'écran de la zone
    width := endX - startX
    height := endY - startY
    
    ; Sauvegarde de l'image
    pToken := Gdip_Startup()
    pBitmap := Gdip_BitmapFromScreen(startX "|" startY "|" width "|" height)
    Gdip_SaveBitmapToFile(pBitmap, "bag_empty.png")
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
    
    MsgBox, Image du sac vide sauvegardée: bag_empty.png
}

; Instructions au démarrage
ShowInstructions() 