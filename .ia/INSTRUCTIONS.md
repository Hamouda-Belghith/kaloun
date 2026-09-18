# Instructions pour développer ce projet

Ce fichier contient les conventions et règles à suivre pour toute session de travail (humaine ou IA) sur ce projet. À lire avant de reprendre le développement.

## Règles non négociables (contenu religieux)

1. **Ne jamais modifier, recomposer ou "corriger" automatiquement le texte du Coran.** Toute page affichée doit être une reproduction fidèle du scan source (image), sauf validation manuelle explicite d'un changement.
2. **Toute table de métadonnées (sourate/Juz'/Hizb → page) doit être vérifiée manuellement** avant d'être committée, en la confrontant page par page au PDF source. Ne pas faire confiance à une table générée automatiquement ou copiée d'une autre édition sans revérification.
3. Ne pas prétendre à une "validation officielle" ou un label religieux sans autorisation réelle. Mentionner honnêtement la source.

## Organisation de la documentation `.ia/`

- [PLAN.md](PLAN.md) : feuille de route, phases, cases à cocher. Mettre à jour les cases au fil de l'avancement.
- [ARCHITECTURE.md](ARCHITECTURE.md) : décisions techniques figées. Ne changer que si une décision structurante change réellement (ex. abandon de Flutter) — documenter le changement et la raison.
- [DATA_SOURCES.md](DATA_SOURCES.md) : tout ce qui concerne le PDF source, l'extraction, les droits.
- [PROGRESS.md](PROGRESS.md) : journal daté, une entrée par session de travail significative. Ne pas réécrire l'historique, seulement ajouter en haut.
- [APP_STORE_CHECKLIST.md](APP_STORE_CHECKLIST.md) : à cocher au moment de la publication.

## Conventions de code (une fois le projet Flutter créé)

- Dart/Flutter, `flutter analyze` sans warning avant tout commit.
- Nommage des fichiers/dossiers en `snake_case`, classes en `PascalCase`, comme c'est l'usage Dart standard.
- Pas de dépendance ajoutée sans raison claire (éviter la sur-ingénierie — app volontairement simple).
- RTL : toujours tester l'UI en configuration arabe/RTL, pas seulement en LTR.
- Pas de connexion réseau requise pour les fonctionnalités de base (app offline-first) ; toute fonctionnalité nécessitant le réseau (si ajoutée plus tard) doit être clairement optionnelle et annoncée.

## Comment reprendre une session de travail

1. Lire [PROGRESS.md](PROGRESS.md) pour connaître le dernier état.
2. Vérifier les cases non cochées dans [PLAN.md](PLAN.md) pour la phase en cours.
3. Avant de committer un changement structurant, mettre à jour le fichier `.ia/` concerné.
4. Ajouter une entrée dans [PROGRESS.md](PROGRESS.md) en fin de session.

## Questions à trancher avec l'utilisateur (ne pas décider seul)

Voir la section "Questions ouvertes" dans [PLAN.md](PLAN.md) — nom de l'app, bundle ID, compte Apple Developer, droits sur l'édition, stratégie texte vs image si elle doit évoluer.
