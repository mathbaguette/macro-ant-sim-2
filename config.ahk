#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%

; Script de configuration pour personnaliser la macro
Gui, Add, Text,, Configuration de la Macro Roblox Farming
Gui, Add, Text,, === DÉLAIS DE DÉPLACEMENT ===
Gui, Add, Text,, Délai déplacement droite (ms):
Gui, Add, Edit, vRightDelay, 2000
Gui, Add, Text,, Délai déplacement gauche (ms):
Gui, Add, Edit, vLeftDelay, 500
Gui, Add, Text,, Délai navigation champ (ms):
Gui, Add, Edit, vFieldDelay, 3000
Gui, Add, Text,, Délai navigation Hive (ms):
Gui, Add, Edit, vHiveDelay, 2000

Gui, Add, Text,, === DÉTECTION DE COULEUR ===
Gui, Add, Text,, Coordonnée X position 1:
Gui, Add, Edit, vColor1X, 100
Gui, Add, Text,, Coordonnée Y position 1:
Gui, Add, Edit, vColor1Y, 100
Gui, Add, Text,, Coordonnée X position 2:
Gui, Add, Edit, vColor2X, 200
Gui, Add, Text,, Coordonnée Y position 2:
Gui, Add, Edit, vColor2Y, 100

Gui, Add, Text,, === TOUCHES ===
Gui, Add, Text,, Touche farming:
Gui, Add, Edit, vFarmKey, Space
Gui, Add, Text,, Touche conversion:
Gui, Add, Edit, vConvertKey, E

Gui, Add, Text,, === TOLÉRANCE IMAGE ===
Gui, Add, Text,, Tolérance détection image (0-255):
Gui, Add, Edit, vImageTolerance, 50

Gui, Add, Button, w100 h30 gSaveConfig, Sauvegarder
Gui, Add, Button, x+10 w100 h30 gLoadConfig, Charger
Gui, Add, Button, x+10 w100 h30 gApplyToMain, Appliquer au script principal

Gui, Show, w400 h500, Configuration Macro Roblox

return

SaveConfig:
Gui, Submit, NoHide
FileDelete, config.ini
FileAppend, [Delays]`n, config.ini
FileAppend, RightDelay=%RightDelay%`n, config.ini
FileAppend, LeftDelay=%LeftDelay%`n, config.ini
FileAppend, FieldDelay=%FieldDelay%`n, config.ini
FileAppend, HiveDelay=%HiveDelay%`n, config.ini
FileAppend, `n[Colors]`n, config.ini
FileAppend, Color1X=%Color1X%`n, config.ini
FileAppend, Color1Y=%Color1Y%`n, config.ini
FileAppend, Color2X=%Color2X%`n, config.ini
FileAppend, Color2Y=%Color2Y%`n, config.ini
FileAppend, `n[Keys]`n, config.ini
FileAppend, FarmKey=%FarmKey%`n, config.ini
FileAppend, ConvertKey=%ConvertKey%`n, config.ini
FileAppend, `n[Image]`n, config.ini
FileAppend, Tolerance=%ImageTolerance%`n, config.ini
MsgBox, Configuration sauvegardée dans config.ini
return

LoadConfig:
if FileExist("config.ini") {
    IniRead, RightDelay, config.ini, Delays, RightDelay, 2000
    IniRead, LeftDelay, config.ini, Delays, LeftDelay, 500
    IniRead, FieldDelay, config.ini, Delays, FieldDelay, 3000
    IniRead, HiveDelay, config.ini, Delays, HiveDelay, 2000
    IniRead, Color1X, config.ini, Colors, Color1X, 100
    IniRead, Color1Y, config.ini, Colors, Color1Y, 100
    IniRead, Color2X, config.ini, Colors, Color2X, 200
    IniRead, Color2Y, config.ini, Colors, Color2Y, 100
    IniRead, FarmKey, config.ini, Keys, FarmKey, Space
    IniRead, ConvertKey, config.ini, Keys, ConvertKey, E
    IniRead, ImageTolerance, config.ini, Image, Tolerance, 50
    
    GuiControl,, RightDelay, %RightDelay%
    GuiControl,, LeftDelay, %LeftDelay%
    GuiControl,, FieldDelay, %FieldDelay%
    GuiControl,, HiveDelay, %HiveDelay%
    GuiControl,, Color1X, %Color1X%
    GuiControl,, Color1Y, %Color1Y%
    GuiControl,, Color2X, %Color2X%
    GuiControl,, Color2Y, %Color2Y%
    GuiControl,, FarmKey, %FarmKey%
    GuiControl,, ConvertKey, %ConvertKey%
    GuiControl,, ImageTolerance, %ImageTolerance%
    
    MsgBox, Configuration chargée depuis config.ini
} else {
    MsgBox, Aucun fichier config.ini trouvé!
}
return

ApplyToMain:
Gui, Submit, NoHide
MsgBox, Cette fonction appliquera les paramètres au script principal.`n`nVoulez-vous continuer?
; Ici vous pouvez ajouter le code pour modifier automatiquement ant sim2.ahk
return

GuiClose:
ExitApp 