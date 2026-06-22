# MyTunes 🎵

Une appli "façon Spotify" mais 100% perso : tu importes tes propres musiques et vidéos
(depuis Fichiers/Photos de ton iPhone) et tu les écoutes/regardes dans l'app, avec des playlists.

## Ce que fait l'app
- Import de fichiers audio (mp3, m4a, wav, aac, flac) et vidéo (mp4, mov, m4v)
- Bibliothèque locale (les fichiers sont copiés dans le dossier privé de l'app)
- Lecteur audio et vidéo avec piste suivante/précédente
- Création de playlists et organisation des morceaux

## Pourquoi pas de compilation directe sur Windows ?
Apple impose que la compilation finale d'une app iOS (`.ipa`) passe par Xcode, qui ne tourne
que sur macOS. Comme tu es sur Windows, on contourne ça avec **GitHub Actions** : un Mac virtuel
gratuit dans le cloud qui compile le projet à ta place.

## Étapes pour compiler et installer

### 1. Mets le projet sur GitHub
- Crée un compte GitHub (gratuit) si tu n'en as pas.
- Crée un nouveau repository (public ou privé, peu importe).
- Upload tout le contenu de ce dossier `mytunes/` dans le repo
  (via l'interface web "Add file > Upload files", ou via `git push` si tu as Git installé).

### 2. Lance le build
- Va dans l'onglet **Actions** de ton repo GitHub.
- Tu devrais voir le workflow **"Build iOS IPA"**.
- Clique sur **"Run workflow"** (bouton vert) pour le lancer manuellement.
- Attends ~5-10 minutes que ça compile.

### 3. Récupère le fichier .ipa
- Une fois le workflow terminé (coche verte ✅), clique sur le run.
- En bas de la page, section **Artifacts**, télécharge **MyTunes-ipa** (un .zip contenant le .ipa).
- Dézippe pour récupérer `MyTunes.ipa`.

### 4. Installe sur ton iPhone (sans compte développeur payant)
Utilise **Sideloadly** (gratuit, Windows/Mac) :
1. Télécharge Sideloadly : https://sideloadly.io/
2. Branche ton iPhone en USB à ton PC.
3. Ouvre Sideloadly, glisse le fichier `MyTunes.ipa` dedans.
4. Connecte-toi avec ton Apple ID (un compte gratuit suffit, pas besoin du programme payant).
5. Clique sur "Start" — l'app s'installe sur ton iPhone.
6. Sur l'iPhone : va dans **Réglages > Général > VPN et gestion des appareils**, et fais confiance
   au profil développeur lié à ton Apple ID.

⚠️ **Limite du compte gratuit** : l'app expire après **7 jours**, il faudra refaire l'étape 4
chaque semaine (rebrancher le téléphone et relancer Sideloadly, pas besoin de recompiler).
Si un jour tu prends le compte Apple Developer payant (99$/an), l'app dure 1 an.

## Modifier l'app
Le code est dans `lib/` :
- `lib/main.dart` : point d'entrée
- `lib/screens/library_screen.dart` : écran principal (bibliothèque)
- `lib/screens/player_screen.dart` : lecteur audio/vidéo
- `lib/screens/playlists_screen.dart` : gestion des playlists
- `lib/services/library_service.dart` : logique d'import/stockage
- `lib/models/media_item.dart` : structures de données

Après modification, repush sur GitHub et relance le workflow Actions pour recompiler.
