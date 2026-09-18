# Journal d'avancement

Nouvelle entrée en haut du fichier, la plus récente en premier.

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
