# Claude Project Selector

Une extension Raycast pour sélectionner et exporter facilement vos projets Claude Code vers Obsidian.

## Fonctionnalités

- 📋 Liste interactive de tous vos projets Claude Code
- 🔍 Recherche rapide par nom de projet
- 📊 Affichage du nombre de sessions par projet
- 📅 Tri par date de dernière modification
- 🚀 Export direct vers Obsidian avec métadonnées
- 📁 Ouverture rapide dans Finder

## Installation

1. Clonez ou copiez ce dossier dans votre répertoire de développement Raycast
2. Naviguez dans le dossier : `cd claude-project-selector`
3. Installez les dépendances : `npm install`
4. Lancez en mode développement : `npm run dev`

## Configuration

Vous pouvez configurer les chemins dans les préférences Raycast :

- **Claude Path** : Chemin vers votre dossier `.claude` (par défaut : `~/.claude`)
- **Obsidian Vault Path** : Chemin vers votre dossier de capture Obsidian (par défaut : `~/Obsidian Vault/00_Capture`)

## Utilisation

1. Ouvrez Raycast
2. Tapez "Select Claude Project"
3. Parcourez ou recherchez votre projet
4. Appuyez sur Entrée pour exporter vers Obsidian
5. La note s'ouvre automatiquement dans Obsidian

## Structure des données exportées

Chaque export inclut :
- Métadonnées du projet (nom, nombre de sessions, date)
- Dernier message de la session la plus récente
- Tags automatiques pour l'organisation
- Horodatage de création

## Développement

- `npm run dev` : Mode développement
- `npm run build` : Construction de l'extension
- `npm run lint` : Vérification du code
- `npm run fix-lint` : Correction automatique du code