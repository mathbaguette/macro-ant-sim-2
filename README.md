# Macro Roblox Farming - AutoHotkey

## Description
Cette macro automatise le processus de farming dans Roblox avec détection de couleurs et d'images pour gérer le sac.

## Fonctionnalités
- Déplacement automatique (droite/gauche)
- Détection de position de caméra par couleur
- Navigation automatique vers le champ de farming
- Détection du sac plein par image
- Navigation vers le Hive pour conversion
- Détection du sac vide pour recommencer le cycle
- Boucle infinie avec reset automatique

## Installation

### 1. Prérequis
- AutoHotkey v1.1 installé sur votre système
- Roblox ouvert en mode fenêtré

### 2. Images requises
Créez deux images dans le même dossier que le script :
- `bag_full.png` : Capture d'écran de votre sac quand il est plein
- `bag_empty.png` : Capture d'écran de votre sac quand il est vide

### 3. Configuration des images
1. Ouvrez Roblox et allez à votre sac
2. Faites une capture d'écran quand le sac est plein
3. Faites une capture d'écran quand le sac est vide
4. Sauvegardez ces images avec les noms exacts

## Utilisation

### Touches de contrôle
- **F1** : Démarrer la macro
- **F2** : Arrêter la macro
- **F3** : Quitter complètement

### Étapes d'utilisation
1. Ouvrez Roblox et connectez-vous
2. Placez-vous à votre position de départ
3. Appuyez sur **F1** pour démarrer
4. La macro s'exécutera automatiquement en boucle
5. Appuyez sur **F2** pour arrêter à tout moment

## Personnalisation

### Ajustement des délais
Modifiez les valeurs `Sleep` dans le script selon votre jeu :
- `Sleep, 2000` = 2 secondes
- Ajustez selon la vitesse de votre personnage

### Détection de couleur
Modifiez les coordonnées dans `DetectCameraPosition()` :
```autohotkey
PixelGetColor, color1, 100, 100, RGB  ; Position 1
PixelGetColor, color2, 200, 100, RGB  ; Position 2
```

### Navigation
Ajustez les chemins dans :
- `NavigateToField()` : Path vers le champ
- `NavigateToHive()` : Path vers le Hive

## Dépannage

### La macro ne détecte pas les images
1. Vérifiez que les images `bag_full.png` et `bag_empty.png` existent
2. Assurez-vous que les images correspondent exactement à l'écran
3. Ajustez la tolérance dans `ImageSearch` (actuellement `*50`)

### Détection de couleur incorrecte
1. Utilisez un outil de capture de couleur pour identifier les bonnes coordonnées
2. Modifiez les coordonnées dans `DetectCameraPosition()`

### Navigation incorrecte
1. Ajustez les délais dans les fonctions de navigation
2. Modifiez les touches utilisées selon votre configuration

## Sécurité
- Cette macro est pour usage personnel uniquement
- Respectez les conditions d'utilisation de Roblox
- Utilisez à vos propres risques

## Support
Pour toute question ou problème, vérifiez :
1. Que AutoHotkey est correctement installé
2. Que les images sont dans le bon dossier
3. Que Roblox est en mode fenêtré
4. Que les coordonnées de couleur correspondent à votre écran 