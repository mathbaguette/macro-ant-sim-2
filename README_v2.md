# Conversion AutoHotkey v1 vers v2

Ce dossier contient les versions converties de vos scripts AutoHotkey de la v1 vers la v2.

## Fichiers convertis

### Scripts principaux
- `ant_sim2_v2.ahk` - Version v2 du script principal de farming
- `capture_helper_v2.ahk` - Version v2 du script de capture d'images et couleurs
- `config_v2.ahk` - Version v2 du script de configuration
- `simple_capture_v2.ahk` - Version v2 du script de capture simplifié

## Principales différences entre v1 et v2

### 1. Déclarations et directives
**v1:**
```autohotkey
#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
```

**v2:**
```autohotkey
#SingleInstance Force
#Requires AutoHotkey v2.0
```

### 2. Variables globales
**v1:**
```autohotkey
global variable := value
```

**v2:**
```autohotkey
global variable := value
```
(La syntaxe reste la même)

### 3. Fonctions et paramètres
**v1:**
```autohotkey
FunctionName() {
    ; code
}
```

**v2:**
```autohotkey
FunctionName(*) {
    ; code
}
```
(Le `*` est nécessaire pour les fonctions sans paramètres)

### 4. Interface graphique (GUI)
**v1:**
```autohotkey
Gui, Main:New, +AlwaysOnTop +ToolWindow, Ant Sim 2
Gui, Main:Add, Button, x10 y70 w80 h30 gStartMacro, Start (F1)
Gui, Main:Show
```

**v2:**
```autohotkey
mainGui := Gui()
mainGui.Opt("+AlwaysOnTop +ToolWindow")
mainGui.Title := "Ant Sim 2"
mainGui.Add("Button", "x10 y70 w80 h30", "Start (F1)").OnEvent("Click", StartMacro)
mainGui.Show()
```

### 5. Gestion des événements
**v1:**
```autohotkey
StartMacro:
    ; code
return
```

**v2:**
```autohotkey
StartMacro(*) {
    ; code
}
```

### 6. Messages et boîtes de dialogue
**v1:**
```autohotkey
MsgBox, Message
```

**v2:**
```autohotkey
MsgBox("Message")
```

### 7. Récupération de position de souris
**v1:**
```autohotkey
MouseGetPos, mouseX, mouseY
```

**v2:**
```autohotkey
MouseGetPos(&mouseX, &mouseY)
```

### 8. Couleurs de pixels
**v1:**
```autohotkey
PixelGetColor, color, x, y, RGB
```

**v2:**
```autohotkey
color := PixelGetColor(x, y, "RGB")
```

### 9. Envoi de touches
**v1:**
```autohotkey
Send, {z down}
Send, {z up}
```

**v2:**
```autohotkey
Send("{z down}")
Send("{z up}")
```

### 10. Recherche d'images
**v1:**
```autohotkey
ImageSearch, foundX, foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 image.png
```

**v2:**
```autohotkey
if (ImageSearch(&foundX, &foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*50 image.png")) {
    ; image trouvée
}
```

## Notes importantes

### 1. Capture d'écran
Les fonctions de capture d'écran utilisant GDI+ peuvent nécessiter des bibliothèques tierces en v2. Vous devrez peut-être :
- Utiliser une bibliothèque comme Gdip_All.ahk
- Ou utiliser les méthodes natives de Windows

### 2. Gestion des erreurs
La v2 utilise un système de gestion d'erreurs plus robuste avec `try/catch` :
```autohotkey
try {
    ; code qui peut échouer
} catch Error as e {
    MsgBox("Erreur: " . e.Message)
}
```

### 3. Variables par référence
En v2, les variables passées par référence utilisent `&` :
```autohotkey
MouseGetPos(&x, &y)
```

## Installation et utilisation

1. **Installer AutoHotkey v2** depuis le site officiel
2. **Remplacer les anciens scripts** par les versions v2
3. **Tester chaque script** pour s'assurer qu'il fonctionne correctement
4. **Adapter les captures d'écran** si nécessaire

## Compatibilité

- Les scripts v2 ne fonctionnent **PAS** avec AutoHotkey v1
- Les scripts v1 ne fonctionnent **PAS** avec AutoHotkey v2
- Il faut installer la version appropriée d'AutoHotkey

## Support

Si vous rencontrez des problèmes avec la conversion :
1. Vérifiez que vous utilisez AutoHotkey v2
2. Consultez la documentation officielle d'AutoHotkey v2
3. Testez les scripts un par un pour identifier les problèmes 