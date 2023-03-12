# Batch GBC64

Prérequis: 
- GameBase 64
- Dans le script GBC64.bat, renseigner les chemins:
    - GameBase  ex: set "GB64=C:\GameBase\Commodore 64"
    - Tools     ex: "TOOLS=%GB64%\Emulators" (il faut qu'il pointe vers le dossier ou se trouve l'utilitaire C1541.exe)

Utilisation:
- Copier et exécuter le script batch sur un lecteur/sous-dossier où vous disposez d'au moins de 4 à 5 Go d'espace libre.
- Rem: 
	- Le dossier GameBase original n'est pas modifié par ce script
	- Il sera créé/écrasé un dossier D64 à la racine du script
	- Le traitement dure plusieurs heures
	- Il est important de ne pas modifier l'encodage du fichier batch qui doit rester en ANSI (Windows 1252)
	
