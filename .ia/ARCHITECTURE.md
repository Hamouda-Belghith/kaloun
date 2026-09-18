# Architecture technique

## Décision de stack

- **Framework** : Flutter (Dart), SDK stable le plus récent au démarrage du code.
- **Cible principale** : iOS (App Store). **Cible secondaire future** : Android (Play Store), même codebase.
- **Pas de backend** : application 100% offline. Toutes les données (pages du Mosshaf + métadonnées de navigation) sont embarquées dans le bundle de l'app.

## Rendu du Mosshaf : approche retenue

Le PDF source est un **scan image** (627 pages, ~445 Mo, ~745 Ko/page en moyenne) et non un PDF avec texte structuré fiable. Pour garantir la **fidélité absolue** du texte coranique (aucune erreur d'OCR/recomposition tolérable) :

- Chaque page du PDF est exportée en **image raster** (PNG/WebP), recadrée et optimisée en résolution/poids pour mobile (cible : netteté à l'écran d'un iPhone/iPad, poids par page ≈ 80–150 Ko après compression WebP).
- L'app affiche ces images dans un lecteur de type "pager" (`PageView` Flutter), swipe RTL (page suivante = swipe vers la gauche, comme un livre arabe).
- La navigation (sourate/Juz'/Hizb → page) se fait via une table de métadonnées JSON séparée (voir [DATA_SOURCES.md](DATA_SOURCES.md)), **pas** via OCR du texte des images.
- Recherche texte, copie de verset, audio synchronisé : impossibles avec cette approche en MVP (nécessiteraient un texte source fiable, non disponible à ce stade — cf. question ouverte dans [PLAN.md](PLAN.md)). Reporté à une phase ultérieure si une source texte Qaloun fiable est identifiée/validée.

## Structure de données embarquées

```
assets/
  pages/
    page_0001.webp
    page_0002.webp
    ...
    page_0627.webp
  data/
    navigation.json       # sourates, juz', hizb -> page de début/fin
    meta.json             # infos édition, version des données
```

`navigation.json` (exemple de forme, à valider avec la vraie pagination tunisienne) :

```json
{
  "totalPages": 627,
  "sourates": [
    { "numero": 1, "nom_ar": "الفاتحة", "nom_fr": "Al-Fatiha", "pageDebut": 1 },
    { "numero": 2, "nom_ar": "البقرة", "nom_fr": "Al-Baqara", "pageDebut": 2 }
  ],
  "juz": [
    { "numero": 1, "pageDebut": 1 },
    { "numero": 2, "pageDebut": 22 }
  ],
  "hizb": [
    { "numero": 1, "pageDebut": 1 }
  ]
}
```

## Structure du projet Flutter (cible)

```
lib/
  main.dart
  app.dart
  core/
    models/            # Sourate, Juz, Hizb, Bookmark
    services/          # NavigationDataService (charge navigation.json), BookmarkService (local storage)
  features/
    reader/            # écran lecteur de pages (PageView + zoom)
    sourates/          # liste des sourates
    juz/               # liste des juz'/hizb
    goto_page/         # saisie numéro de page
    bookmarks/         # signets
    settings/          # thème clair/sombre, à propos
  shared/
    widgets/
    theme/
```

## Stockage local

- **Signets / dernière page lue / préférences** : `shared_preferences` (simple, suffisant pour ce besoin) ou `hive` si besoin de structures plus riches. Décision à prendre en Phase 2, pas bloquante pour le cadrage.

## Performance / poids de l'app

- 627 images WebP compressées ≈ 60–100 Mo de bundle → acceptable pour l'App Store (limite de téléchargement cellulaire 200 Mo, au-delà l'utilisateur doit être en Wi-Fi — à surveiller, viser < 150 Mo au total).
- Chargement des images à la demande (le `PageView` Flutter ne construit que les pages visibles/adjacentes) — pas de préchargement de tout le Mosshaf en mémoire.
