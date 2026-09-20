# Données source

## Fichier source

`مصحف قالون (الطبعة التونسية).pdf`
- Taille : ≈ 445,9 Mo.
- Pages détectées (métadonnées de linéarisation PDF) : **627 pages**.
- Nature : PDF linéarisé, contenu très probablement composé d'images scannées haute résolution par page (poids moyen ≈ 745 Ko/page), pas de calque texte fiable exploitable pour de l'OCR de qualité "texte sacré".
- ⚠️ Le fichier est trop volumineux pour une extraction/lecture directe par les outils d'analyse de texte automatique utilisés pendant le cadrage (limite 100 Mo) — l'inspection détaillée page par page reste à faire avec des outils PDF dédiés (voir "Prochaines étapes" ci-dessous).

## Droits / licence — À VÉRIFIER avant publication

Avant toute publication sur l'App Store (même gratuite) :
- Identifier l'éditeur/l'organisme responsable de cette édition tunisienne (souvent une administration religieuse officielle, ex. équivalent local du Ministère des Affaires religieuses).
- Vérifier s'il existe une autorisation/licence explicite de diffusion numérique, ou une pratique établie de diffusion libre pour ce type d'édition.
- Prévoir une mention claire dans l'app ("À propos") citant la source de l'édition.
- Ne pas présenter l'app comme "officielle" sans validation par l'organisme concerné.

## Extraction des pages en images (Phase 1)

Étapes prévues (à exécuter sur une machine avec outils PDF, ex. `pdftoppm`/`mutool`/`ImageMagick`, ou une lib Python type `pypdfium2` capable de gérer un fichier de cette taille) :

1. Rendre chaque page en image (résolution cible : suffisante pour lecture nette sur écran Retina, ex. 1200–1600 px de large).
2. Recadrer les marges scanner si nécessaire (à vérifier visuellement sur un échantillon de pages).
3. Compresser en WebP (qualité ~80) pour réduire le poids total du bundle app.
4. Nommer les fichiers `page_0001.webp` → `page_0627.webp` (zero-padding sur 4 chiffres).
5. Contrôle qualité : vérifier visuellement un échantillon (première page, dernière page, pages de début de chaque Juz', pages avec bismillah) avant intégration dans l'app.

## Table de correspondance page ↔ sourate ↔ Juz' ↔ Hizb

**Point critique** : la pagination d'une édition tunisienne (Qaloun) ne correspond **pas forcément** à la pagination de l'édition "Médine" (Hafs) utilisée par la plupart des apps/sites de référence occidentaux. Il ne faut donc **pas** réutiliser une table page↔sourate trouvée pour une autre édition sans vérification.

Sources possibles pour construire/valider cette table :
- Table des matières (souvent présente en début ou fin de ce type de Mosshaf) — à extraire une fois le PDF ouvrable avec des outils adaptés.
- Repérage manuel des débuts de sourate en parcourant les pages (têtes de sourate typographiquement distinctes — bandeau/cartouche avec le nom de la sourate).
- Repérage manuel des débuts de Juz' (mention "الجزء" en marge/en-tête, une par Juz', 30 au total) et de Hizb/Rub' (souvent des symboles en marge).

Cette table doit être **vérifiée manuellement**, entrée par entrée, avant intégration — voir tâche correspondante dans [PLAN.md](PLAN.md) Phase 1.

## État réel constaté (session du 2026-09-18)

- Chaque page du PDF est une image JPEG unique embarquée (confirmé via PyMuPDF : `page.get_images()` retourne une seule image DCTDecode par page, `page.get_text()` vide). Pas de calque texte du tout — l'approche "image" est donc la seule possible pour le rendu, pas seulement un choix de prudence.
- Résolution source ≈ 1900×2730 px/page. Extraction faite à 1080 px de large, WebP qualité 76 → **145 Mo pour les 627 pages** (`app/assets/pages/page_0001.webp` … `page_0627.webp`), sous la limite visée de 150 Mo.
- **Pagination réelle de cette édition** (numérotation interne = position dans le fichier, utilisée comme numéro de page dans l'app) :
  - Pages 1–2 : couverture + page ornementale, non numérotées, hors texte coranique.
  - Pages 3–605 : texte coranique complet (sourate 1 Al-Fatiha à la page 3, sourate 114 An-Nas commence page 605).
  - Pages 606–627 : pages de fin. Page 606 = colophon "التعريف بهذا المصحف الشريف" confirmant que cette édition suit **la lecture de Qaloun via Nassif, transmise par Nafi' al-Madani** ("رواية قالون من طريق أبي نشيط عن نافع المدني"), rasm et arrêts conformes aux mosahef imprimés de référence, décompte selon l'école coufie (6236 versets). Contenu des pages 607–627 non inspecté en détail (probablement index des sourates / dou'a de clôture / mentions légales de l'imprimeur) — à vérifier si l'app doit les afficher ou les exclure du "livre".
  - ⚠️ Le numéro imprimé visible en bas de chaque page dans le Mosshaf est décalé de -1 par rapport à la position dans le fichier (page-fichier 5 → numéro imprimé "4"). L'app utilise la position dans le fichier comme référence (cohérent avec les noms de fichiers `page_XXXX.webp`), pas le numéro imprimé. Ce décalage est normal et sans conséquence, mais bon à savoir si quelqu'un compare visuellement avec le livre papier.
- **Table de navigation** (`app/assets/data/navigation.json`) : 114 sourates + 30 Juz' avec page de début exacte, construite par relecture visuelle systématique de l'en-tête de chaque page (nom de sourate + "الجزء ..." en toutes lettres, très lisible) via des planches de contact générées par script, complétée par une inspection directe des pages pour les sourates courtes de fin de Coran (Juz' 30) qui ne remontent jamais en tête de page.
  - Double vérification : somme des `nombreAyat` = 6236 (= chiffre du colophon page 606) ; les 30 Juz' démarrent à un intervalle parfaitement régulier de 20 pages (page 3, 23, 43, ... 583), avec un Juz' 30 étendu à 23 pages — cohérent avec une mise en page délibérément calibrée à 20 pages par Juz'.
  - Le tableau `hizb` est présent dans le schéma mais **vide** : les marqueurs de Hizb/Rub'/Thumn visibles en marge des pages (roundels numérotés) n'ont pas été décodés (numérotation peu claire à distance, non prioritaire par rapport à sourate/Juz').
- Scripts de traitement (non commités dans `app/`, à conserver si besoin de régénérer) : extraction PDF→WebP et génération des planches de contact, écrits en Python (PyMuPDF + Pillow) dans un venv local, réutilisables si le PDF source change.

## Bug trouvé et corrigé (2026-09-18, session 5) : une sourate peut commencer au milieu d'une page

**Symptôme rapporté par l'utilisateur** : en naviguant vers Al-Baqara depuis la liste des sourates, l'app affichait la 2e page de la sourate au lieu de la 1ère.

**Cause réelle** : la méthode de vérification initiale (session 2) s'appuyait sur l'en-tête répété en haut de chaque page ("سورة البقرة ..."). Cet en-tête indique la sourate **présente en haut de la page**, pas forcément celle qui commence sur cette page. Comme Al-Fatiha ne fait que 7 versets, elle se termine tôt sur la page 3, et **Al-Baqara commence à la suite, sur la même page 3** — mais l'en-tête de la page 3 affiche encore "الفاتحة" puisque c'est elle qui occupe le haut de page. La page 4 est donc en réalité la **2ᵉ page** d'Al-Baqara, pas la 1ère. `pageDebut` d'Al-Baqara était donc enregistré à 4 au lieu de 3.

Ce même piège avait déjà été identifié et correctement traité pour les sourates courtes de la fin du Coran (Juz' 30, voir plus haut) mais n'avait pas été vérifié pour le reste du livre.

**Vérification corrective faite** : génération de planches de vignettes montrant, pour chacune des 114 sourates, la page précédant son `pageDebut` enregistré — pour repérer visuellement toute cartouche de nouvelle sourate apparaissant à mi-page. Les 113 transitions (sourate 2 à 114) ont été repassées en revue une par une. **Une seule erreur trouvée : Al-Baqara** (corrigée : `pageDebut` 4 → 3). Toutes les autres transitions sont confirmées correctes.

**Leçon retenue** : l'en-tête de page n'est fiable que pour dire "quelle sourate est en haut de cette page", jamais pour dire "quelle page commence cette sourate". Toute vérification future de pagination doit inspecter le contenu réel de la page (présence d'une cartouche), pas seulement l'en-tête. Un test de régression (`app/test/navigation_test.dart`) vérifie maintenant que la navigation vers Al-Baqara affiche bien `page_0003.webp`.


### Mise à jour (2026-09-20) : la correction de session 5 était incomplète

Le contrôle par vignettes avait laissé passer 37 autres cas (dont Al-Kahf) où la cartouche de la sourate est **en bas de la page précédente**. Corrigé par détection automatique des cartouches (script Python : bandes de pixels roses denses dans la zone de texte, une par cartouche) puis relecture visuelle des 114 recadrages : **38 sourates avaient un `pageDebut` trop élevé de 1**. Le nombre de cartouches détectées (114) et l'ordre des sourates (fixe) donnent directement la page de chaque sourate. **Règle : ne plus jamais déduire un début de sourate de l'en-tête de page ; utiliser la cartouche.**

Les débuts de Juz' restent basés sur le texte de l'en-tête (motif régulier de 20 pages) et sont à vérifier (voir [MANUEL.md](../MANUEL.md) étape 5).

## Prochaines étapes concrètes

- [ ] Relecture humaine de `navigation.json` avant publication (au moins un échantillon aléatoire de sourates/Juz', en particulier le Juz' 30 qui a le plus de sourates par page).
- [ ] Décider si les pages 606–627 doivent être incluses dans le lecteur ou masquées (actuellement incluses : les 627 pages sont toutes dans `assets/pages/`).
- [ ] Compléter le tableau `hizb` si la navigation par Hizb/Rub' est jugée nécessaire.
- [ ] Vérifier les droits sur cette édition précise avant publication (voir section "Droits / licence" ci-dessus).
