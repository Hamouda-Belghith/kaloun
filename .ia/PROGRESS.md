# Journal d'avancement

Nouvelle entrée en haut du fichier, la plus récente en premier.

---

## 2026-09-18 (session 5) — Bug de navigation vers les sourates corrigé + serveur web pour tester l'UI

- L'utilisateur a testé l'UI via le serveur `flutter run -d web-server` (lancé en session précédente) et a signalé : naviguer vers Al-Baqara affichait la 2ᵉ page de la sourate au lieu de la 1ère.
- **Cause trouvée** : voir le détail complet dans [DATA_SOURCES.md](DATA_SOURCES.md) section "Bug trouvé et corrigé". En résumé : Al-Fatiha (7 versets) se termine tôt sur la page 3, et Al-Baqara commence à la suite sur cette même page — mais l'en-tête de page (utilisé pour construire `navigation.json` en session 2) indiquait encore "Al-Fatiha" puisqu'elle occupe le haut de la page. `pageDebut` d'Al-Baqara était donc enregistré à 4 au lieu de 3.
- **Vérification systématique refaite** pour les 113 transitions de sourates (2 à 114) via des planches de vignettes montrant la page précédant chaque `pageDebut` enregistré, à la recherche d'une cartouche de sourate à mi-page. **Seule Al-Baqara était fausse** ; toutes les autres transitions sont confirmées correctes. `navigation.json` régénéré avec la correction (Al-Baqara : pageDebut 4 → 3).
- Ajout d'un test de régression `app/test/navigation_test.dart` qui simule un vrai tap utilisateur (ouvrir la liste des sourates → taper sur une sourate) et vérifie l'image de page réellement affichée. Couvre Al-Baqara (cas du bug) et An-Nas (dernière sourate). `flutter test` : 4/4 passent. `flutter analyze` : toujours 0 erreur.
- Correctif UI supplémentaire (`app/lib/app.dart`) : ajout d'un `ScrollBehavior` personnalisé pour activer le glisser à la souris/trackpad (Flutter n'active que le tactile par défaut) — nécessaire pour tester confortablement au clavier/souris via le serveur web ; sans impact sur iPhone où le swipe tactile fonctionne déjà nativement.
- Serveur `flutter run -d web-server` relancé avec les correctifs, accessible sur `http://localhost:8080` (redirigé automatiquement par WSL2 vers Windows).

### Prochaine session — à faire en priorité
1. Confirmer avec l'utilisateur que la navigation vers Al-Baqara (et idéalement quelques autres sourates) est maintenant correcte visuellement dans le navigateur.
2. Continuer les tests visuels de l'UI (Juz', aller-à-la-page, signets, mode sombre) et remonter tout autre problème.
3. Reste bloquant : toujours pas de build iOS réel (Phase 3.5 — Apple Developer + Codemagic).

---

## 2026-09-18 (session 4) — Flutter installé et projet compilé/testé avec succès

L'utilisateur a explicitement autorisé l'installation de Flutter sur sa machine (WSL Ubuntu). Réalisé par l'assistant :

- **Flutter 3.47.4** installé dans `~/dev/flutter` (tarball officiel, pas de sudo nécessaire). `~/.bashrc` mis à jour pour l'ajouter au PATH.
- `flutter create --org com.hamoudabelghith --project-name mosshaf_qaloun .` lancé dans `app/` : génère les dossiers de plateforme manquants (`ios/`, `android/`, `macos/`, `windows/`, `linux/`, `web/`) sans toucher à `lib/`, `assets/`, `pubspec.yaml`. Bundle identifier obtenu : `com.hamoudabelghith.mosshafQaloun` (iOS).
- `flutter pub get` puis `flutter analyze` → **0 erreur, 0 warning**.
- `flutter test` → 1 échec initial corrigé :
  - Le test par défaut généré par `flutter create` référençait un widget `MyApp` qui n'existe pas dans notre code (`MosshafQalounApp`) → remplacé par deux tests pertinents (démarrage + chargement complet des données/rendu de l'écran lecteur).
  - `pumpAndSettle` restait bloqué indéfiniment : `SharedPreferences.getInstance()` n'a pas de réponse de canal de plateforme dans l'environnement de test unitaire sans `SharedPreferences.setMockInitialValues({})`. **Ce n'est pas un bug de l'app** (fonctionne normalement sur un vrai appareil), juste un prérequis des tests Flutter — ajouté dans `test/widget_test.dart`.
  - Résultat final : **2/2 tests passent**, incluant le chargement réel de `navigation.json`, le parsing des modèles, et le rendu de l'écran lecteur avec la barre de navigation.
- `flutter build web --release` → build réussi (validation supplémentaire, catch les erreurs de build que l'analyseur statique peut manquer).
- Nettoyage : `app/build/` (374 Mo d'artefacts de build web, régénérable) supprimé, jamais commité (`.gitignore` déjà correct).
- `codemagic.yaml` : placeholder `BUNDLE_ID` remplacé par la vraie valeur générée (`com.hamoudabelghith.mosshafQaloun`).
- [PLAN.md](PLAN.md) : Phase 2.5 cochée comme faite.

**Conclusion : le code Flutter écrit en session 2 compile et fonctionne correctement du premier coup** (une fois le test corrigé) — pas de bug applicatif trouvé dans `lib/`.

### Prochaine session — à faire en priorité
1. Toujours pas de build iOS réel testé (bloqué sans Mac) — passer à la Phase 3.5 : compte Apple Developer + Codemagic + premier build TestFlight.
2. Si l'utilisateur veut voir l'UI visuellement avant Codemagic : installer Flutter sur Windows (ou utiliser le Flutter de WSL avec un serveur X/VNC, plus compliqué) pour lancer `flutter run -d chrome`.
3. Trancher nom de l'app définitif + bundle ID (actuel : `com.hamoudabelghith.mosshafQaloun`, généré automatiquement, changeable).

---

## 2026-09-18 (session 3) — Dépôt GitHub + plan de mise en route (Windows/WSL, sans Mac)

- Dépôt public créé et poussé : **https://github.com/Hamouda-Belghith/kaloun** (branche `main`). `gh` CLI installé localement (pas de sudo dans cet environnement, binaire téléchargé dans `~/.local/bin`), authentification faite par l'utilisateur via le flux web device-code.
- Le PDF source (445 Mo) est exclu du repo via `.gitignore` (`*.pdf`) — reste uniquement en local.
- Contexte précisé par l'utilisateur : développement sur PC Windows perso, VS Code connecté à WSL Ubuntu, test prévu sur un **iPhone physique**. **Pas de Mac** → impossible de compiler/exécuter la cible iOS en local (Xcode = macOS uniquement). Noté dans [INSTRUCTIONS.md](INSTRUCTIONS.md) pour que les sessions futures ne suggèrent pas `flutter run` sur simulateur iOS à cet utilisateur.
- Décision d'architecture : contourner l'absence de Mac avec un CI/CD géré — **Codemagic** (palier gratuit, spécialisé Flutter, signe et publie sur TestFlight automatiquement). Ajout de [`codemagic.yaml`](../codemagic.yaml) à la racine du repo (workflow de départ, bundle ID encore en placeholder).
- [PLAN.md](PLAN.md) réorganisé avec deux nouvelles étapes concrètes : **Phase 2.5** (mise en route locale : Flutter sur Windows, `flutter create .`, `flutter analyze`, itération rapide via Chrome/émulateur Android avant de consommer des minutes de build cloud) et **Phase 3.5** (tests réels sur l'iPhone via Codemagic + TestFlight, en boucle jusqu'à satisfaction avant la Phase 4 de publication).
- **Règle permanente ajoutée** dans [INSTRUCTIONS.md](INSTRUCTIONS.md) : mettre à jour `.ia/` (PROGRESS/PLAN/ARCHITECTURE/DATA_SOURCES/APP_STORE_CHECKLIST selon pertinence) à chaque session sans que l'utilisateur ait à le redemander, et pousser sur GitHub si un remote est déjà configuré.
- Aucun code applicatif modifié cette session (uniquement doc + config CI).

### Prochaine session — à faire en priorité
1. Utilisateur : installer Flutter sur Windows, lancer `flutter create .` dans `app/`, `flutter pub get`, `flutter analyze` — remonter les erreurs de compilation trouvées (le code Dart n'a jamais été compilé).
2. Corriger les éventuelles erreurs de compilation trouvées à l'étape 1.
3. Créer le compte Apple Developer + compte Codemagic, brancher le repo, faire un premier build de test.
4. Trancher le nom de l'app + bundle identifier définitif (actuellement placeholder `com.hamoudabelghith.mosshafqaloun` dans `codemagic.yaml`).

---

## 2026-09-18 (session 2) — Extraction des données + squelette Flutter

Environnement : pas de Flutter SDK installé sur cette machine (Linux/WSL), pas de `poppler-utils`, pas de `sudo`. Contournement : création d'un venv Python (`python3 -m venv`) avec `pip` fonctionnel, installation de `pymupdf` + `pillow` pour traiter le PDF directement.

**Extraction des pages** : les 627 pages du PDF ont été extraites (image JPEG embarquée par page, pas de calque texte — confirme l'approche "image" de [ARCHITECTURE.md](ARCHITECTURE.md)), redimensionnées à 1080px de large et compressées en WebP qualité 76 → **145 Mo au total**, copiées dans `app/assets/pages/`.

**Table de navigation construite et vérifiée manuellement** (`app/assets/data/navigation.json`) :
- Généré des "planches de contact" (crops de l'en-tête de chaque page : nom de sourate + numéro de Juz' en toutes lettres) et relu visuellement l'intégralité des 627 pages via ces planches.
- Pour les sourates courtes de la fin (Joz' 30) qui ne remontent jamais en haut de page, vérification page par page directement sur l'image complète (cartouche "سورة ... N").
- Résultat : **114 sourates** et **30 Juz'** avec page de début exacte, validés par deux recoupements indépendants :
  - Somme des `nombreAyat` = **6236**, qui correspond exactement au nombre annoncé dans le colophon interne du Mosshaf (page 606 : "عدد آي القرآن على طريقة الكوفيين: 6236 آية").
  - Les débuts de Juz' suivent un motif parfaitement régulier (+20 pages entre chaque Juz', de la page 3 à la page 583, avec un Juz' 30 étendu à 23 pages) — cohérent avec une mise en page volontairement calibrée à 20 pages/Juz'.
- Pages 1–2 : couverture/page ornementale sans numérotation (hors texte coranique).
- Pages 3–605 : texte coranique (Al-Fatiha → An-Nas).
- Pages 606–627 : pages de fin (colophon "التعريف بهذا المصحف الشريف" confirmant la rivāya Qaloun/Nafi' al-Madani ; contenu des pages suivantes non inspecté en détail, probablement index/dou'a de clôture).
- ⚠️ Cette table n'a été relue qu'une fois par moi (l'assistant) sur les images ; une seconde relecture humaine (l'utilisateur ou une autre personne) reste recommandée avant publication, en particulier pour les Juz'/Hizb secondaires (non implémentés : le tableau `hizb` est vide dans le JSON).

**Squelette Flutter créé** dans `app/` :
- `pubspec.yaml` (Flutter + `flutter_localizations`, `shared_preferences`).
- Modèles : `Sourate`, `Juz`/`Hizb`, `Bookmark`, `NavigationData`.
- Services : `NavigationDataService` (charge `navigation.json`), `BookmarkService` (dernière page lue + signets via `shared_preferences`).
- Écrans : `ReaderScreen` (PageView RTL plein écran avec zoom, barre du bas), `SouratesScreen`, `JuzScreen`, `GotoPageScreen`, `BookmarksScreen`.
- Thème clair/sombre sobre (`AppTheme`).
- **Non testé** : pas de Flutter SDK ici pour lancer `flutter pub get` / `flutter analyze` / build. Le code n'a donc pas été compilé. Prochaine étape indispensable : ouvrir `app/` sur une machine avec Flutter installé, lancer `flutter create .` si les dossiers `ios/`/`android/` manquent encore, puis `flutter pub get` et `flutter run`.

### Prochaine session — à faire en priorité
1. Sur une machine avec Flutter installé : générer les dossiers de plateforme (`flutter create .` dans `app/`, en conservant `lib/`/`assets/`/`pubspec.yaml` déjà écrits), puis `flutter pub get` et tester sur simulateur/appareil.
2. Relecture humaine de `navigation.json` (au moins un échantillon de sourates/Juz' + tous les Juz' 27-30 qui contiennent beaucoup de sourates courtes).
3. Décider nom de l'app, bundle ID, icône (questions ouvertes dans [PLAN.md](PLAN.md)).
4. Vérifier les droits sur l'édition (voir [DATA_SOURCES.md](DATA_SOURCES.md)) avant toute publication.

---

## 2026-09-18 (session 1) — Cadrage initial

- Création du README.md et du dossier `.ia/` (PLAN, ARCHITECTURE, DATA_SOURCES, INSTRUCTIONS, APP_STORE_CHECKLIST, PROGRESS).
- Inspection préliminaire du PDF source `مصحف قالون (الطبعة التونسية).pdf` :
  - Taille ≈ 445,9 Mo.
  - Métadonnées de linéarisation indiquent **627 pages**.
  - Fichier trop volumineux pour extraction texte directe par les outils d'analyse (limite 100 Mo) et `poppler-utils` (`pdfinfo`) non installé sur la machine actuelle → inspection détaillée du contenu (table des matières, repérage exact des débuts de sourate/Juz') reste à faire.
- Décisions prises avec l'utilisateur :
  - L'app Android existante sur le Play Store n'est **pas** de nous et sa techno est inconnue → **pas de réutilisation de code**, on repart de zéro.
  - Stack retenue : **Flutter**, pour cibler iOS en priorité et Android potentiellement plus tard sans réécriture.
  - Approche de rendu retenue : pages du Mosshaf affichées comme **images** (pas de recomposition texte), pour garantir l'exactitude du contenu — cf. [ARCHITECTURE.md](ARCHITECTURE.md).
- Aucun code applicatif écrit à ce stade. Aucune image extraite du PDF.

### Prochaine session — à faire en priorité
1. Installer un outil PDF capable de traiter ce fichier de 445 Mo (`poppler-utils` ou équivalent) et extraire un échantillon de pages (1–20) pour valider qualité/poids.
2. Localiser/extraire la table des matières du PDF si elle existe.
3. Trancher les questions ouvertes listées dans [PLAN.md](PLAN.md) (nom d'app, bundle ID, compte Apple Developer, droits sur l'édition).
