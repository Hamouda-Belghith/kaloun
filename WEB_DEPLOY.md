# Déploiement web (solution temporaire, gratuite)

Ce document décrit le déploiement de Mosshaf Qaloun **en tant que site web** sur Vercel, en attendant de lancer la publication iOS (qui nécessite le compte Apple Developer à 99 USD/an — voir [MANUEL.md](MANUEL.md)).

**Ceci ne remplace pas le projet iOS.** C'est le même code Flutter (`app/lib/`, `app/assets/`) qui sert les deux cibles — c'est tout l'intérêt de Flutter. Rien dans `.ia/` ni dans `MANUEL.md` n'a été modifié ou n'est affecté par ce déploiement : quand tu voudras reprendre la publication App Store, tout est resté en l'état.

## URL en ligne

**https://app-seven-tau-28.vercel.app**

Nom sans signification particulière (comme `whattoeat-inky.vercel.app` pour l'autre projet) — Vercel l'attribue automatiquement, gratuit, pas de configuration DNS nécessaire.

⚠️ Les autres URL affichées par Vercel (celles qui contiennent `-hbe-projects.vercel.app`) sont protégées par une authentification Vercel (SSO) et ne s'ouvrent pas pour un visiteur normal. **Seule l'URL ci-dessus est publique.** C'est le même comportement que pour `what_to_eat` — vérifié en comparant les deux projets.

## Pourquoi Vercel peut construire une app Flutter (et pas Supabase)

- **Pas besoin de Supabase.** L'app n'a ni compte utilisateur ni données partagées entre appareils : les signets sont stockés localement dans le navigateur (`shared_preferences` → `localStorage` en web), exactement comme prévu pour l'iPhone. Rien à synchroniser, donc rien à héberger côté base de données.
- **Vercel ne connaît pas Flutter nativement** (contrairement à Next.js pour `what_to_eat`). Le build est donc piloté par un script maison :
  - [`app/vercel.json`](app/vercel.json) : indique à Vercel d'exécuter `bash vercel-build.sh`, sans étape d'installation Node, et de servir le dossier `build/web` généré.
  - [`app/vercel-build.sh`](app/vercel-build.sh) : télécharge le SDK Flutter (tarball officiel Linux) dans `/tmp` à chaque build, puis lance `flutter build web --release`. Ajoute `git config --global --add safe.directory /tmp/flutter` car les builds Vercel tournent en `root`, ce que Git refuse par défaut sur un dossier téléchargé.
- Palier gratuit Vercel (Hobby) : largement suffisant pour ce trafic (aucune limite réaliste pour un usage personnel/famille).

## Comment redéployer après un changement de code

Le projet Vercel **n'est pas encore connecté à GitHub pour le déploiement automatique** (la connexion nécessite une autorisation via navigateur — installation de l'app GitHub de Vercel sur le dépôt — qu'un assistant ne peut pas faire seul). En attendant, redéployer manuellement :

```bash
cd app
vercel --prod --yes
```

Ça prend 1 à 2 minutes (téléchargement du SDK Flutter inclus à chaque fois, pas de cache entre builds pour l'instant).

### Pour activer le déploiement automatique à chaque push (optionnel)

1. Sur https://vercel.com, ouvrir le projet **mosshaf-qaloun-web**.
2. Settings → Git → Connect Git Repository → choisir `Hamouda-Belghith/kaloun`.
3. Vérifier que **Root Directory** est bien réglé sur `app` (déjà fait côté projet, mais à confirmer visuellement).
4. Une fois connecté, chaque `git push` sur `main` redéploiera automatiquement.

## Config technique du projet Vercel

- Nom du projet : `mosshaf-qaloun-web` (équipe `hbe-projects`, la même que `what_to_eat`)
- Root Directory : `app`
- Build Command : `bash vercel-build.sh`
- Install Command : `echo skip` (pas de dépendances Node)
- Output Directory : `build/web`
- Framework preset : aucun (« Other »)

## Limites connues de cette version web

- **Pas d'installation "app" au sens app-store** — mais utilisable comme PWA : ouvrir le lien sur iPhone (Safari) → partager → "Sur l'écran d'accueil", pour une icône et un lancement en plein écran, comme pour `what_to_eat`. Le support offline/PWA n'a pas été spécifiquement activé ici (pas de service worker configuré, contrairement à `what_to_eat` qui utilise Serwist) — à ajouter si besoin.
- Chargement initial plus lourd que l'app iOS native : les 627 pages (145 Mo) sont resservies par le navigateur à la demande (pas de préchargement), mais rien n'est mis en cache offline pour l'instant — nécessite une connexion à chaque session, sauf pages déjà visitées dans le cache navigateur classique.
- Swipe au doigt fonctionne nativement sur mobile (testé sur navigateur de bureau avec la souris via le `ScrollBehavior` déjà en place dans le code).

## Historique

- 2026-09-22 : premier déploiement (voir [.ia/PROGRESS.md](.ia/PROGRESS.md) pour le détail de session).
