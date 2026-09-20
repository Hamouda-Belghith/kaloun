# Mosshaf Qaloun — Édition Tunisienne 📖

Application mobile (iOS d'abord, potentiellement Android plus tard) présentant le **Coran selon la lecture de Qaloun, édition tunisienne**, à partir du PDF source :

> `مصحف قالون (الطبعة التونسية).pdf` (≈ 445 Mo, ≈ 627 pages, scan haute résolution)

Une application équivalente existe déjà sur le Play Store (pas développée par nous, technologie inconnue). Ce projet part **de zéro**, sans réutilisation de code, pour livrer une version iOS publiée sur l'App Store — et pourra être étendue à Android via le même codebase si besoin.

## Fonctionnalités visées

- Lecture du Mosshaf page par page (rendu fidèle au scan original, rasm tunisien).
- Navigation rapide :
  - par **numéro de page**,
  - par **sourate** (liste des 114 sourates),
  - par **Juz'** (les 30 Juz') et **Hizb/Rub'**,
  - retour au dernier signet (dernière page lue).
- Signets / favoris et reprise de lecture.
- Recherche (par nom de sourate, numéro de page, numéro de Juz').
- Fonctionnement 100% hors-ligne après installation.
- (Optionnel, phase ultérieure) Lecture audio, mode nuit, zoom, partage de page/verset.

## État du projet

Voir [.ia/PROGRESS.md](.ia/PROGRESS.md) pour l'avancement détaillé.

## Documentation projet

Tous les documents de pilotage (plan, architecture, instructions de dev, checklist App Store) sont dans le dossier [.ia/](.ia/) :

- [MANUEL.md](MANUEL.md) — planning de ce qui reste à faire à la main (comptes, TestFlight, relecture, publication).
- [.ia/PLAN.md](.ia/PLAN.md) — feuille de route et découpage en phases.
- [.ia/ARCHITECTURE.md](.ia/ARCHITECTURE.md) — choix techniques et structure de l'app.
- [.ia/DATA_SOURCES.md](.ia/DATA_SOURCES.md) — traitement du PDF source et données de navigation (sourates/Juz'/pages).
- [.ia/INSTRUCTIONS.md](.ia/INSTRUCTIONS.md) — conventions et instructions pour développer ce projet.
- [.ia/APP_STORE_CHECKLIST.md](.ia/APP_STORE_CHECKLIST.md) — checklist de publication sur l'App Store.
- [.ia/PROGRESS.md](.ia/PROGRESS.md) — journal d'avancement (mis à jour à chaque session de travail).

## Stack technique (décidé)

**Flutter** (Dart) — un seul codebase pour iOS (cible principale) et Android (cible future), bon support RTL/arabe, écosystème mature pour ce type d'app.

## Structure du dépôt

- [app/](app/) — projet Flutter (code source `lib/`, données `assets/data/navigation.json`, pages du Mosshaf `assets/pages/`). Écrit mais **jamais compilé** (pas de Flutter SDK disponible dans l'environnement de développement utilisé jusqu'ici).
- [.ia/](.ia/) — documentation de pilotage du projet.

## Statut

🚧 Données extraites et vérifiées (627 pages, 114 sourates + 30 Juz' avec pages de début exactes), squelette Flutter complet écrit. **Prochaine étape obligatoire : ouvrir `app/` sur une machine avec Flutter installé** pour générer les dossiers de plateforme (`flutter create .`) et tester. Voir [.ia/PROGRESS.md](.ia/PROGRESS.md) pour le détail.
