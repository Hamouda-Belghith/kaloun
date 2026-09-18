# Checklist de publication — Apple App Store

À cocher au fur et à mesure, en Phase 4 (voir [PLAN.md](PLAN.md)).

## Compte & configuration

- [ ] Compte Apple Developer Program actif (99 USD/an), individuel ou organisation.
- [ ] Bundle identifier réservé (ex. `com.<nom>.mosshafqaloun`), cohérent avec App ID dans Xcode/App Store Connect.
- [ ] Certificats de signature + profils de provisionnement (ou gestion automatique via Xcode).
- [ ] App créée dans **App Store Connect**.

## Contenu de la fiche App Store

- [ ] Nom de l'app (≤ 30 caractères) — arabe + éventuellement français/anglais en sous-titre.
- [ ] Sous-titre (≤ 30 caractères).
- [ ] Description complète (mettre en avant : lecture Qaloun tunisienne, navigation par sourate/Juz'/page, mode hors-ligne).
- [ ] Mots-clés pertinents (Coran, Quran, Qaloun, Tunisie, Mosshaf...).
- [ ] Catégorie principale : **Références** ou **Éducation** (à choisir selon positionnement).
- [ ] Icône app (1024×1024, sans transparence, sans coins arrondis pré-appliqués).
- [ ] Captures d'écran pour chaque taille d'appareil requise (iPhone 6.9", 6.5", iPad si supporté).
- [ ] Localisation de la fiche (au minimum arabe ; français en secondaire si pertinent).

## Exigences légales / techniques Apple

- [ ] **Politique de confidentialité** (URL publique) — obligatoire même si l'app ne collecte aucune donnée.
- [ ] Réponses au questionnaire **App Privacy** (Nutrition Label) dans App Store Connect — cocher "aucune donnée collectée" si c'est le cas réel.
- [ ] **Content rights** : déclarer que le contenu (texte du Coran, édition tunisienne) est utilisé légitimement (cf. [DATA_SOURCES.md](DATA_SOURCES.md) — droits à vérifier avant cette étape).
- [ ] Âge/classification de contenu : contenu religieux, généralement classé "4+" sans restriction — vérifier les questions du formulaire de classification.
- [ ] Test sur device réel (pas seulement simulateur) avant soumission.
- [ ] Build testé via **TestFlight** (au moins un cycle de test interne).
- [ ] Respect des [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) — sections pertinentes : contenu religieux (pas d'interdiction en soi, mais éviter tout contenu offensant/controversé additionnel), pas de placeholder/contenu non fini, pas de crash, métadonnées exactes.
- [ ] Pas de pub tierce intrusive superposée au contenu du Mosshaf (si des pubs sont envisagées un jour, elles doivent être hors de l'écran de lecture — décision produit à confirmer, absente du MVP actuel).

## Avant soumission finale

- [ ] Version/build number cohérents (`pubspec.yaml` côté Flutter).
- [ ] Vérification finale : toutes les 627 pages s'affichent correctement, navigation sourate/Juz'/page exacte (échantillonnage manuel large).
- [ ] Mention de la source de l'édition visible dans l'app (écran "À propos").
- [ ] Soumission pour review Apple.

## Après publication

- [ ] Surveiller les retours/avis pour toute erreur signalée sur le texte (priorité absolue de correction si c'est le cas — contenu sacré).
- [ ] Prévoir un canal de contact (email) pour signalement d'erreur, affiché dans l'app.
