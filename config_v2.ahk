#SingleInstance Force
#Requires AutoHotkey v2.0

; Script de configuration pour personnaliser la macro
configGui := Gui()
configGui.Title := "Configuration Macro Roblox"

configGui.Add("Text",, "Configuration de la Macro Roblox Farming")
configGui.Add("Text",, "=== DÉLAIS DE DÉPLACEMENT ===")
configGui.Add("Text",, "Délai déplacement droite (ms):")
configGui.Add("Edit", "vRightDelay", "2000")
configGui.Add("Text",, "Délai déplacement gauche (ms):")
configGui.Add("Edit", "vLeftDelay", "500")
configGui.Add("Text",, "Délai navigation champ (ms):")
configGui.Add("Edit", "vFieldDelay", "3000")
configGui.Add("Text",, "Délai navigation Hive (ms):")
configGui.Add("Edit", "vHiveDelay", "2000")

configGui.Add("Text",, "=== DÉTECTION DE COULEUR ===")
configGui.Add("Text",, "Coordonnée X position 1:")
configGui.Add("Edit", "vColor1X", "100")
configGui.Add("Text",, "Coordonnée Y position 1:")
configGui.Add("Edit", "vColor1Y", "100")
configGui.Add("Text",, "Coordonnée X position 2:")
configGui.Add("Edit", "vColor2X", "200")
configGui.Add("Text",, "Coordonnée Y position 2:")
configGui.Add("Edit", "vColor2Y", "100")

configGui.Add("Text",, "=== TOUCHES ===")
configGui.Add("Text",, "Touche farming:")
configGui.Add("Edit", "vFarmKey", "Space")
configGui.Add("Text",, "Touche conversion:")
configGui.Add("Edit", "vConvertKey", "E")

configGui.Add("Text",, "=== TOLÉRANCE IMAGE ===")
configGui.Add("Text",, "Tolérance détection image (0-255):")
configGui.Add("Edit", "vImageTolerance", "50")

configGui.Add("Button", "w100 h30", "Sauvegarder").OnEvent("Click", SaveConfig)
configGui.Add("Button", "x+10 w100 h30", "Charger").OnEvent("Click", LoadConfig)
configGui.Add("Button", "x+10 w100 h30", "Appliquer au script principal").OnEvent("Click", ApplyToMain)

configGui.Show("w400 h500")

return

SaveConfig(*) {
    config := configGui.Submit(false)
    
    try {
        FileDelete("config.ini")
        FileAppend("[Delays]`n", "config.ini")
        FileAppend("RightDelay=" . config.RightDelay . "`n", "config.ini")
        FileAppend("LeftDelay=" . config.LeftDelay . "`n", "config.ini")
        FileAppend("FieldDelay=" . config.FieldDelay . "`n", "config.ini")
        FileAppend("HiveDelay=" . config.HiveDelay . "`n", "config.ini")
        FileAppend("`n[Colors]`n", "config.ini")
        FileAppend("Color1X=" . config.Color1X . "`n", "config.ini")
        FileAppend("Color1Y=" . config.Color1Y . "`n", "config.ini")
        FileAppend("Color2X=" . config.Color2X . "`n", "config.ini")
        FileAppend("Color2Y=" . config.Color2Y . "`n", "config.ini")
        FileAppend("`n[Keys]`n", "config.ini")
        FileAppend("FarmKey=" . config.FarmKey . "`n", "config.ini")
        FileAppend("ConvertKey=" . config.ConvertKey . "`n", "config.ini")
        FileAppend("`n[Image]`n", "config.ini")
        FileAppend("Tolerance=" . config.ImageTolerance . "`n", "config.ini")
        
        MsgBox("Configuration sauvegardée dans config.ini")
    } catch Error as e {
        MsgBox("Erreur lors de la sauvegarde: " . e.Message)
    }
}

LoadConfig(*) {
    if (FileExist("config.ini")) {
        try {
            RightDelay := IniRead("config.ini", "Delays", "RightDelay", "2000")
            LeftDelay := IniRead("config.ini", "Delays", "LeftDelay", "500")
            FieldDelay := IniRead("config.ini", "Delays", "FieldDelay", "3000")
            HiveDelay := IniRead("config.ini", "Delays", "HiveDelay", "2000")
            Color1X := IniRead("config.ini", "Colors", "Color1X", "100")
            Color1Y := IniRead("config.ini", "Colors", "Color1Y", "100")
            Color2X := IniRead("config.ini", "Colors", "Color2X", "200")
            Color2Y := IniRead("config.ini", "Colors", "Color2Y", "100")
            FarmKey := IniRead("config.ini", "Keys", "FarmKey", "Space")
            ConvertKey := IniRead("config.ini", "Keys", "ConvertKey", "E")
            ImageTolerance := IniRead("config.ini", "Image", "Tolerance", "50")
            
            configGui["RightDelay"].Value := RightDelay
            configGui["LeftDelay"].Value := LeftDelay
            configGui["FieldDelay"].Value := FieldDelay
            configGui["HiveDelay"].Value := HiveDelay
            configGui["Color1X"].Value := Color1X
            configGui["Color1Y"].Value := Color1Y
            configGui["Color2X"].Value := Color2X
            configGui["Color2Y"].Value := Color2Y
            configGui["FarmKey"].Value := FarmKey
            configGui["ConvertKey"].Value := ConvertKey
            configGui["ImageTolerance"].Value := ImageTolerance
            
            MsgBox("Configuration chargée depuis config.ini")
        } catch Error as e {
            MsgBox("Erreur lors du chargement: " . e.Message)
        }
    } else {
        MsgBox("Aucun fichier config.ini trouvé!")
    }
}

ApplyToMain(*) {
    MsgBox("Cette fonction appliquera les paramètres au script principal.`n`nVoulez-vous continuer?")
    ; Ici vous pouvez ajouter le code pour modifier automatiquement ant sim2.ahk
}

configGui.OnEvent("Close", (*) => ExitApp()) 