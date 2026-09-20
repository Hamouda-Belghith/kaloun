# À faire à la main — planning

Tout ce qui **ne peut pas être fait par l'assistant** (comptes, paiements, appareils, décisions, vérifications humaines). Le reste du projet est suivi dans [.ia/PLAN.md](.ia/PLAN.md).

Cases à cocher au fur et à mesure. Les durées sont des ordres de grandeur.

## Vue d'ensemble

| Étape | Quoi | Durée (travail) | Délai d'attente |
|---|---|---|---|
| 1 | Vérifier l'app dans le navigateur | 30 min | — |
| 2 | Décisions produit (nom, icône...) | 1 h | — |
| 3 | Compte Apple Developer | 30 min | **1 à 3 jours** (validation Apple) |
| 4 | Codemagic + premier build sur l'iPhone | 2 à 3 h | — |
| 5 | Relecture du texte / des données | 2 à 4 h | — |
| 6 | Droits sur l'édition | variable | **peut être long** (attente de réponse) |
| 7 | Politique de confidentialité + site de support | 1 h | — |
| 8 | Fiche App Store (textes, captures) | 2 à 3 h | — |
| 9 | Soumission et review Apple | 1 h | **1 à 3 jours** de review |

**Lancer les étapes 3 et 6 en premier** : ce sont celles où l'on attend quelqu'un d'autre. Le reste avance pendant ce temps.

---

## Étape 1 — Vérifier l'app dans le navigateur

Le serveur se lance avec `cd app && flutter run -d web-server --web-port=8080` puis http://localhost:8080 (demander à l'assistant de le relancer s'il est arrêté).

- [ ] Le sens des pages est bien droite → gauche (page 2 apparaît en glissant vers la gauche)
- [ ] Naviguer vers **au moins 20 sourates** au hasard et vérifier que la page affichée est bien celle où la sourate commence (cartouche avec le nom de la sourate visible). Cibler en priorité les sourates courtes et celles qui suivent une sourate courte.
- [ ] Navigation par Juz' : vérifier les 30 (le titre de page indique « الجزء ... » en haut)
- [ ] « Aller à la page » : essayer 1, 3, 300, 605, 627 et une valeur invalide (0, 700)
- [ ] Signets : ajouter, supprimer, rouvrir l'app (le signet est conservé, la dernière page lue aussi)
- [ ] Zoom (pincer) sur une page : le texte reste net
- [ ] Noter tout ce qui cloche (capture d'écran + le numéro de page) et le donner à l'assistant

## Étape 2 — Décisions produit

À trancher avant l'étape 4 (le bundle ID est difficile à changer une fois l'app créée dans App Store Connect).

- [ ] **Nom de l'app** (30 caractères max sur l'App Store). Vérifier qu'il n'est pas déjà pris sur l'App Store
- [ ] **Bundle ID définitif**. Actuellement `com.hamoudabelghith.mosshafQaloun`. À garder ou changer, mais **avant** de créer l'app dans App Store Connect
- [ ] **Icône** de l'app : image 1024×1024 px, PNG, sans transparence, sans coins arrondis (Apple les arrondit). Sobre, sans texte coranique
- [ ] **Langues de la fiche App Store** : arabe + français ? + anglais ?
- [ ] **Gratuite ou payante** (recommandation : gratuite, sans publicité)
- [ ] **Pages 606 à 627** (colophon, introduction...) : les garder dans le lecteur ou non. À décider après les avoir regardées (elles ne sont pas encore inspectées en détail)
- [ ] **Email de contact** pour signaler une erreur dans le texte (à afficher dans l'app et sur la fiche)

## Étape 3 — Compte Apple Developer (à faire en premier)

- [ ] Créer un **Apple ID** dédié si besoin (idéalement avec la double authentification activée)
- [ ] S'inscrire sur https://developer.apple.com/programs/enroll/ (**99 USD/an**)
  - Choisir « Individual » (particulier) : le plus simple, pas de numéro D-U-N-S
  - Une pièce d'identité peut être demandée (l'app *Apple Developer* sur iPhone facilite la vérification)
- [ ] Attendre la validation d'Apple (souvent 24 à 48 h, parfois plus)
- [ ] Une fois validé : dans **App Store Connect** → *Users and Access* → *Integrations* → *App Store Connect API* → créer une **clé API** (rôle *App Manager*). Télécharger le fichier `.p8` (**téléchargeable une seule fois**, le ranger en lieu sûr) et noter le *Issuer ID* et le *Key ID*
- [ ] Dans App Store Connect → *Apps* → **créer l'app** (nom, langue principale, bundle ID, SKU au choix)

## Étape 4 — Build sur l'iPhone via Codemagic

Prérequis : étapes 2 et 3 terminées.

- [ ] Créer un compte sur https://codemagic.io (connexion avec GitHub) et autoriser l'accès au dépôt `Hamouda-Belghith/kaloun`
- [ ] Dans Codemagic → *Teams* → *Integrations* → ajouter l'**intégration App Store Connect** avec la clé de l'étape 3
- [ ] Ajouter l'application, choisir le fichier de configuration `codemagic.yaml`
- [ ] Vérifier avec l'assistant que `BUNDLE_ID` dans [codemagic.yaml](codemagic.yaml) correspond à l'étape 2
- [ ] Lancer le premier build (5 à 15 min). **Il peut échouer au premier essai** : c'est normal, transmettre le journal d'erreur à l'assistant
- [ ] Sur l'iPhone : installer **TestFlight** depuis l'App Store
- [ ] Dans App Store Connect → *TestFlight* → ajouter son propre compte comme testeur interne, accepter l'invitation
- [ ] Installer la build depuis TestFlight et **tester réellement** sur l'iPhone (swipe, zoom, navigation, signets, mode sombre, rotation, mode avion)
- [ ] Noter les défauts et les transmettre à l'assistant (boucle : correction → push → nouveau build → test)

## Étape 5 — Relecture du texte et des données (obligatoire, texte sacré)

L'assistant a construit la table de navigation (114 sourates, 30 Juz') en lisant les images, avec des contrôles automatiques, et a déjà dû corriger deux séries d'erreurs. **Une relecture humaine est indispensable avant publication.**

- [ ] Relire **les 114 sourates** : depuis la liste, ouvrir chaque sourate et vérifier que la cartouche du nom est bien sur la page affichée
- [ ] Vérifier les **30 Juz'** de la même façon
- [ ] Parcourir **toutes les pages** au moins une fois en défilement rapide : aucune page manquante, tournée, floue, coupée ou en double
- [ ] Faire relire par **une personne qui connaît la lecture de Qaloun** (idéalement un récitant ou un enseignant) : l'assistant ne peut pas juger du rasm ni du tajwid
- [ ] Vérifier la conformité avec l'édition papier de référence si vous en avez une (nombre de pages, pagination)
- [ ] Vérifier les pages 606 à 627 (contenu, à garder ou non)

## Étape 6 — Droits sur l'édition (à lancer tôt)

Le PDF vient d'une édition tunisienne du Mosshaf dont l'éditeur n'est pas identifié dans le projet. Apple peut demander de justifier les droits sur le contenu.

- [ ] Identifier l'**éditeur / l'organisme responsable** (la page 606 « التعريف بهذا المصحف الشريف » et les dernières pages peuvent en donner le nom)
- [ ] Vérifier d'où vient exactement le PDF et s'il est diffusé librement
- [ ] **Demander une autorisation écrite** de diffusion dans une application (email, garder la réponse). Sans réponse, décider en connaissance de cause
- [ ] Prévoir la mention de la source dans l'écran « À propos » de l'app
- [ ] Ne pas présenter l'app comme « officielle » sans accord de l'organisme

## Étape 7 — Documents légaux et support (obligatoires pour Apple)

- [ ] **Politique de confidentialité** publiée à une URL publique. L'app ne collecte aucune donnée (tout est stocké sur l'appareil) : un texte court suffit. L'assistant peut le rédiger, le publier reste à faire (par exemple GitHub Pages sur ce dépôt, gratuit)
- [ ] **URL de support** (page ou email) : obligatoire dans App Store Connect
- [ ] Remplir le questionnaire **App Privacy** dans App Store Connect (« aucune donnée collectée »)
- [ ] Répondre au questionnaire d'**âge** (contenu religieux, aucune violence ni achat)
- [ ] Déclaration **d'exportation / chiffrement** : l'app n'utilise pas de chiffrement propre, répondre « non » ou « exempté » selon les questions posées

## Étape 8 — Fiche App Store

- [ ] Texte de description (arabe, + français/anglais si choisis) : demander un brouillon à l'assistant, puis le relire
- [ ] Sous-titre (30 caractères), mots-clés (100 caractères, séparés par des virgules)
- [ ] **Captures d'écran** : au minimum la taille iPhone 6,9 pouces. Les prendre depuis TestFlight sur l'iPhone, ou demander à l'assistant de préparer un guide. 3 à 5 captures : lecteur, liste des sourates, liste des Juz', mode sombre
- [ ] Icône 1024×1024 (voir étape 2)
- [ ] Catégorie : *Livres* ou *Références*
- [ ] Notes pour l'équipe de review : préciser que l'app est une reproduction fidèle d'une édition imprimée, sans compte ni réseau

## Étape 9 — Soumission

- [ ] Toutes les cases de [.ia/APP_STORE_CHECKLIST.md](.ia/APP_STORE_CHECKLIST.md) sont cochées
- [ ] Dernière build testée sur l'iPhone via TestFlight, sans défaut connu
- [ ] Dans App Store Connect : choisir la build, remplir les infos, **Submit for Review**
- [ ] Attendre la review (souvent 24 à 48 h). Si refus : lire le motif, en parler à l'assistant, corriger et resoumettre
- [ ] Publication (manuelle ou automatique après approbation, au choix)

## Après la publication

- [ ] Surveiller les avis et les emails : **toute erreur signalée dans le texte est à traiter en priorité**
- [ ] Renouveler le compte Apple Developer chaque année (99 USD), sinon l'app est retirée de l'App Store
- [ ] (Optionnel) Publication Android avec le même code

---

## Ce que fait l'assistant en parallèle (pas à faire à la main)

- Correction des défauts remontés aux étapes 1 et 4
- Rédaction de la politique de confidentialité, de la description et des mots-clés de la fiche
- Écran « À propos » (source, contact)
- Mode sombre et petits réglages d'interface
- Mise à jour de `.ia/` et poussée sur GitHub à chaque session

## Quand l'assistant a besoin de toi

- Un build Codemagic échoue : envoyer le journal d'erreur (copier-coller)
- Une page ou une sourate est mauvaise : envoyer le numéro de page et une capture
- Un choix produit est demandé (nom, icône, langues)
