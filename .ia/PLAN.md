# Plan de développement — Mosshaf Qaloun

## Objectif

Publier sur l'App Store une application iOS simple et fiable de lecture du Coran (lecture Qaloun, édition tunisienne), avec navigation par page / sourate / Juz'. Codebase Flutter pour permettre une publication Android ultérieure sans réécriture.

## Contraintes particulières (contenu religieux)

- **Exactitude absolue du texte** : toute erreur de rasm, de pagination ou d'attribution sourate/page/Juz' est inacceptable. Aucune retouche automatique (OCR, recomposition de texte) du Mosshaf sans vérification manuelle.
- Respect des règles Apple sur le contenu religieux (pas de pub intrusive dans le contenu sacré, respect des consignes App Store liées aux apps religieuses — cf. [.ia/APP_STORE_CHECKLIST.md](APP_STORE_CHECKLIST.md)).
- Attribution/mention de la source de l'édition si requis (vérifier droits sur l'édition tunisienne — cf. [.ia/DATA_SOURCES.md](DATA_SOURCES.md)).

## Phases

### Phase 0 — Cadrage (en cours)
- [x] Rédaction README + documentation `.ia/`.
- [ ] Confirmer le nom de l'application, bundle ID, identité visuelle (icône, couleurs).
- [ ] Confirmer la stratégie de rendu des pages (image du scan vs texte recomposé) — voir [ARCHITECTURE.md](ARCHITECTURE.md).
- [ ] Obtenir/valider la table de correspondance page ↔ sourate ↔ Juz' ↔ Hizb pour cette édition précise (la pagination tunisienne peut différer de l'édition Médine).

### Phase 1 — Préparation des données ✅ (à confirmer par relecture humaine)
- [x] Extraire les 627 pages du PDF en images optimisées (145 Mo, voir [DATA_SOURCES.md](DATA_SOURCES.md)).
- [x] Construire le fichier de métadonnées de navigation (JSON) : 114 sourates + 30 Juz' avec pages de début exactes.
- [x] Vérification (par l'assistant) de la table contre le PDF, page par page, via planches de contact + relecture directe pour les sourates courtes. Recoupée avec le colophon interne (6236 versets) et la régularité des Juz' (20 pages/Juz').
- [ ] Relecture humaine finale de `app/assets/data/navigation.json` avant publication (au moins un échantillon).
- [ ] Table Hizb/Rub' (actuellement vide, non prioritaire).

### Phase 2 — Application Flutter (MVP) — code écrit, non testé
- [x] Setup projet Flutter (`app/pubspec.yaml`, structure `lib/`, thème RTL).
- [x] Écran lecteur de pages (pager plein écran, zoom, swipe RTL).
- [x] Écran liste des sourates → va à la bonne page.
- [x] Écran liste des Juz' → va à la bonne page.
- [x] Aller à une page précise (saisie numéro).
- [x] Signet automatique (dernière page lue) + signets manuels.
- [x] Mode hors-ligne complet (assets embarqués dans `app/assets/`).
- [ ] **Bloquant** : aucun Flutter SDK disponible dans cet environnement de développement (Linux/WSL sans Flutter, sans Xcode). Le code n'a jamais été compilé ni exécuté. Prochaine étape obligatoire : ouvrir `app/` sur une machine avec Flutter installé, lancer `flutter create .` pour générer `ios/`/`android/` (en gardant `lib/`, `assets/`, `pubspec.yaml`), puis `flutter pub get`, `flutter analyze`, `flutter run`.

### Phase 3 — Polish
- [ ] Mode nuit / thème sombre.
- [ ] Recherche (sourate, page, Juz').
- [ ] Écran "À propos" (édition, mentions légales/religieuses).
- [ ] Tests sur plusieurs tailles d'écran iPhone/iPad.
- [ ] Accessibilité de base (VoiceOver sur les écrans de navigation, pas nécessairement sur le rendu image du Mosshaf).

### Phase 4 — Publication App Store
- [ ] Compte Apple Developer (99$/an) créé.
- [ ] Icônes, captures d'écran, fiche App Store (description FR/AR/EN).
- [ ] Politique de confidentialité (obligatoire même sans collecte de données).
- [ ] Build release, TestFlight, tests internes.
- [ ] Soumission App Store Connect (voir [APP_STORE_CHECKLIST.md](APP_STORE_CHECKLIST.md)).

### Phase 5 (optionnelle, plus tard)
- [ ] Publication Android (même codebase Flutter) sur Play Store.
- [ ] Audio (récitation), partage, favoris avancés.

## Questions ouvertes à trancher avec l'utilisateur

1. Nom définitif de l'app + bundle identifier (ex. `com.<toi>.mosshafqaloun`).
2. Rendu des pages : images du scan (fidélité garantie, poids app plus lourd) vs texte Unicode recomposé (app légère et permet recherche/copie de texte, mais **risque d'erreurs sur un texte sacré** et nécessite une police + un jeu de données texte fiable pour la lecture Qaloun tunisienne — à ce stade aucune source texte de ce type n'a été identifiée).
3. Compte Apple Developer : existe-t-il déjà, ou à créer ?
4. Droits/licence sur cette édition PDF spécifique (à vérifier avant publication commerciale, même si l'app est gratuite).
