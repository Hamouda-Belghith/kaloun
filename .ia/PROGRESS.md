# Journal d'avancement

Nouvelle entrée en haut du fichier, la plus récente en premier.

---

## 2026-09-22 (session 8) — Connexion Git↔Vercel + logo/icône PWA

- **Connexion GitHub↔Vercel finalisée.** Le blocage de session 7 (erreur 400) venait de l'app GitHub de Vercel non installée sur le dépôt (confirmé via l'API : `"action": "Install GitHub App"`). L'utilisateur l'a installée sur https://github.com/apps/vercel, puis `vercel git connect --yes` a fonctionné. **Chaque push sur `main` redéploie désormais automatiquement.**
- **Logo fourni par l'utilisateur** (couverture de Mosshaf bleu et blanc, "القرآن الكريم" avec mention "برواية قالون") appliqué comme icône de l'app web/PWA — le logo par défaut ("un logo qui n'a pas de sens") remplacé :
  - `app/web/icons/Icon-192.png`, `Icon-512.png` : logo tel quel.
  - `app/web/icons/Icon-maskable-*.png` : logo avec ~15% de marge (couleur de fond échantillonnée sur le coin de l'image) pour survivre à un recadrage circulaire Android.
  - `app/web/favicon.png` régénéré à partir du même logo.
  - `app/web/manifest.json` et `app/web/index.html` : nom "mosshaf_qaloun" (générique, avec underscore) remplacé par "Mosshaf Qaloun" partout (nom sous l'icône, titre d'onglet, description), couleur de thème alignée sur le bleu du logo (`#0B32D8`).
  - Logo source conservé dans `app/branding/logo-source.png` (hors pipeline pubspec/web, juste pour réemploi futur — ex. icône iOS App Store, actuellement des icônes Flutter par défaut, voir [MANUEL.md](../MANUEL.md) étape 2).
- Redéployé (push → déploiement auto Vercel).

### Prochaine session — à faire en priorité
1. L'utilisateur revérifie l'icône sur l'écran d'accueil iPhone (il faudra retirer puis réajouter le raccourci existant : iOS ne recharge pas toujours l'icône d'un raccourci déjà installé).
2. Si ce logo convient aussi pour l'App Store plus tard : générer le jeu d'icônes iOS (`app/ios/Runner/Assets.xcassets/AppIcon.appiconset/`) à partir de `app/branding/logo-source.png` (actuellement les icônes par défaut Flutter, non remplacées).
3. Reste de la Phase 3.5 / MANUEL.md inchangé (Apple Developer, Codemagic — toujours en attente, l'utilisateur a choisi le web en solution temporaire).

---

## 2026-09-22 (session 7) — Déploiement web temporaire (Vercel, gratuit)

L'utilisateur a décidé de ne pas payer les 99 USD/an Apple Developer pour l'instant, et veut une version testable/utilisable dès maintenant. Demande explicite : déployer comme site web sur Vercel (gratuit), avec Supabase seulement si besoin, **sans écraser le code ni la doc existants** (le projet iOS reste tel quel, à reprendre plus tard).

- **Pas de Supabase** : inutile, l'app n'a ni compte ni données partagées (signets en stockage local uniquement) — même logique que la partie offline de `what_to_eat`, mais ici *tout* est offline, pas seulement la liste de courses.
- **Pas de deuxième codebase** : c'est le même Flutter (`app/lib/`, `app/assets/`) qui sert iOS et le web — c'est la raison d'être de Flutter. Créer une doc séparée avait du sens (fait : [WEB_DEPLOY.md](../WEB_DEPLOY.md)), dupliquer le code n'en avait pas.
- Ajout de `app/vercel.json` + `app/vercel-build.sh` : Vercel n'a pas Flutter préinstallé, le script télécharge le SDK dans `/tmp` à chaque build et lance `flutter build web --release`. Piège rencontré : les builds Vercel tournent en `root`, ce que Git refuse sur le dossier Flutter téléchargé (`detected dubious ownership`) → fixé avec `git config --global --add safe.directory /tmp/flutter`.
- Déployé via `vercel` CLI (déjà authentifié `hamoudabelghith197@gmail.com` / équipe `hbe-projects`, la même que `what_to_eat`). Projet renommé `mosshaf-qaloun-web` (au départ nommé `app` par défaut).
- **Piège découvert** : Vercel protège par défaut les URLs `*-hbe-projects.vercel.app` derrière une authentification SSO (redirection 302 vers `vercel.com/sso-api`) — vérifié que `what_to_eat` a exactement le même comportement. Seule l'URL "vanity" sans nom d'équipe (`app-seven-tau-28.vercel.app`, générée automatiquement) est publique. **C'est celle-ci qu'il faut utiliser/partager.**
- Connexion Git→Vercel pour déploiement auto au push tentée mais échouée (erreur 400 de l'API Vercel) : nécessite probablement une autorisation via navigateur (installation de l'app GitHub de Vercel) qu'un assistant ne peut pas faire seul. Redéploiement pour l'instant **manuel** : `cd app && vercel --prod --yes`.
- Vérifié que les assets se chargent bien en production (`main.dart.js`, `assets/assets/data/navigation.json` — Flutter web double le préfixe `assets/`, comportement normal, pas un bug).
- Nouveau fichier **[WEB_DEPLOY.md](../WEB_DEPLOY.md)** à la racine : doc dédiée au déploiement web, séparée de `.ia/` et `MANUEL.md` qui restent inchangés (toujours valables pour la publication iOS plus tard).

### Prochaine session — à faire en priorité
1. L'utilisateur teste l'URL publique https://app-seven-tau-28.vercel.app sur son iPhone (Safari) et remonte les problèmes.
2. Si usage régulier : envisager d'activer le service worker PWA (comme `what_to_eat` avec Serwist) pour un vrai offline complet et une icône d'écran d'accueil.
3. Si souhaité : finaliser la connexion Git→Vercel depuis le dashboard (Settings → Git → Connect) pour ne plus redéployer à la main.

---

## 2026-09-20 (session 6) — 38 débuts de sourate corrigés, sens des pages RTL, MANUEL.md

- **Al-Kahf (et 37 autres sourates) mal placées** : la cartouche d'une sourate peut se trouver **en bas de la page précédente**, pas seulement en haut d'une page. Mon contrôle de session 5 (vignettes à l'œil) avait raté ces cas. Correction par **détection automatique** des cartouches de sourate sur les 603 pages de texte (bandes denses d'ornement rose dans la zone de texte) : 114 cartouches attendues, 114 trouvées après retrait de 1 faux positif (verset page 457) et ajout de 1 cartouche non détectée (page 416, vérifiée à l'œil, en haut de page). Les 114 recadrages ont ensuite été relus visuellement avec le nom de la sourate attendue. Résultat : **38 `pageDebut` décalés d'une page** (ex. Al-Kahf 295 → 294, Al-Ma'ida 108 → 107, Hud 223 → 222) ; les autres inchangés. `navigation.json` régénéré.
- Points sensibles restants : les **Juz'** ont été relevés par le texte « الجزء ... » de l'en-tête, avec la même limite théorique (un Juz' commencé en milieu de page). Ils suivent un motif de 20 pages exactement, ce qui suggère un alignement sur le début des pages, mais **non vérifié page par page** — à confirmer à l'étape 5 de [MANUEL.md](../MANUEL.md).
- **Sens des pages** : `reverse: true` combiné au `Directionality` RTL inversait deux fois, ce qui redonnait du gauche → droite. `reverse` retiré ; le `Directionality` RTL suffit (page 1 à droite, on avance vers la gauche).
- Test de régression ajouté pour Al-Kahf (`navigation_test.dart`). `flutter analyze` : 0 erreur ; `flutter test` : 5/5.
- Nouveau fichier **[MANUEL.md](../MANUEL.md)** à la racine : planning de tout ce qui reste à faire à la main (compte Apple, Codemagic, TestFlight, relecture humaine du texte, droits sur l'édition, documents légaux, fiche App Store, soumission).
- Serveur de test : les processus lancés avec `nohup`/`setsid` sont tués à la fin de chaque appel d'outil ; il faut le lancer via le mode arrière-plan de l'outil. Et ne jamais utiliser `pkill -f <motif>` dans la même commande que le motif (le shell se tue lui-même).

### Prochaine session — à faire en priorité
1. L'utilisateur reteste Al-Kahf, quelques autres sourates et le sens des pages, puis suit [MANUEL.md](../MANUEL.md) (commencer par le compte Apple Developer, à cause du délai de validation).
2. Vérifier les débuts de Juz' page par page (même méthode que pour les sourates si un défaut apparaît).
3. Rédiger la politique de confidentialité et l'écran « À propos ».

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
