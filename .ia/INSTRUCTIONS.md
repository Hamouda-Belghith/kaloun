# Instructions pour développer ce projet

Ce fichier contient les conventions et règles à suivre pour toute session de travail (humaine ou IA) sur ce projet. À lire avant de reprendre le développement.

## Règle permanente : tenir `.ia/` à jour à chaque session

**Cette règle s'applique automatiquement, sans que l'utilisateur ait besoin de la redemander.** À chaque session de travail qui modifie le code, les données, ou fait avancer le projet :
1. Mettre à jour [PROGRESS.md](PROGRESS.md) avec une nouvelle entrée datée décrivant ce qui a été fait, ce qui a été décidé, et ce qui reste bloquant.
2. Cocher/mettre à jour les cases pertinentes dans [PLAN.md](PLAN.md).
3. Mettre à jour [ARCHITECTURE.md](ARCHITECTURE.md), [DATA_SOURCES.md](DATA_SOURCES.md) ou [APP_STORE_CHECKLIST.md](APP_STORE_CHECKLIST.md) si une décision technique, une donnée, ou une étape de publication a changé.
4. Committer ces mises à jour de `.ia/` avec le reste du travail de la session (pas de commit séparé nécessaire, mais ne pas les oublier).
5. Si un dépôt distant est configuré (`git remote -v`) et qu'on a déjà poussé dans cette conversation, pousser aussi les mises à jour de `.ia/` — l'utilisateur développe depuis une autre machine (Windows/VS Code) et doit voir l'état à jour en pullant.

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

## Environnement de développement de l'utilisateur

- PC Windows personnel, VS Code connecté à **WSL Ubuntu** (le dépôt vit dans le filesystem WSL, `/home/hamouda/projects/kaloun`).
- Appareil de test : un **iPhone physique**, pas d'appareil Android.
- **Pas de Mac.** Xcode ne fonctionne que sur macOS : il est donc impossible de compiler/exécuter la cible iOS localement (ni depuis Windows, ni depuis WSL). Toute la chaîne de build iOS doit passer par un service tiers (Mac dans le cloud ou CI/CD macOS — voir [ARCHITECTURE.md](ARCHITECTURE.md) section "CI/CD iOS sans Mac"). Ne jamais suggérer `flutter build ios` ou `flutter run` sur un simulateur iOS en local à cet utilisateur — ça ne peut pas fonctionner dans son environnement.
- Pour l'itération rapide sur l'UI/la logique (avant de consommer des minutes de build cloud), Flutter peut tourner en local sur Windows nativement pour les cibles Web (`flutter run -d chrome`), Windows desktop (`flutter run -d windows`), ou un émulateur Android (si Android Studio est installé) — ça valide la mise en page RTL, la navigation, les écrans, même si la cible finale est iOS uniquement.
