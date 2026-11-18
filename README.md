# Lab Perf — guide d'installation (version gratuite)

L'application se compose de 4 fichiers :

| Fichier | Rôle |
|---|---|
| `index.html` | l'application |
| `config.js` | l'adresse et la clé de votre base de données |
| `supabase.sql` | le script qui crée la base de données |
| `README.md` | ce guide |

Deux services gratuits, sans carte bancaire :

- **Supabase** : comptes des coachs et base de données
- **GitHub** : hébergement du site, avec un lien `https://…github.io/…`

Comptez environ 20 minutes.

---

## Étape 1 : la base de données (Supabase)

1. Allez sur **supabase.com**, puis cliquez sur **Start your project**. Vous pouvez vous inscrire avec votre compte GitHub.
2. Cliquez sur **New project** et remplissez :
   - **Name** : `lab-perf`
   - **Database password** : choisissez un mot de passe et gardez-le de côté
   - **Region** : *West EU (Paris)*, ou la région la plus proche de vous

   Cliquez sur **Create**, puis attendez 1 à 2 minutes.
3. Dans le menu de gauche, ouvrez **SQL Editor**, puis **New query**.
4. Collez **tout le contenu** du fichier `supabase.sql` et cliquez sur **Run**. Le message attendu est « Success. No rows returned ».
5. Désactivez la confirmation par e-mail, sinon les coachs ne pourront pas se connecter :
   1. Ouvrez **Authentication**, puis **Sign In / Providers** (ou **Providers**), puis **Email**.
   2. Désactivez **Confirm email** et enregistrez.

   Ce n'est pas un risque de sécurité : dans l'application, chaque nouveau compte reste **en attente** tant qu'un administrateur ne l'a pas validé.
6. Récupérez l'adresse et la clé du projet :
   1. Ouvrez **Project Settings**, puis **API** (ou **Data API** / **API Keys**).
   2. Copiez la **Project URL** (`https://xxxx.supabase.co`).
   3. Copiez la clé **anon public** (ou *publishable key*).
   4. Donnez ces deux valeurs à Claude, ou collez-les vous-même dans `config.js`.

   La clé « anon » est faite pour être publique. La protection des données est assurée par la base elle-même. Ne communiquez **jamais** la clé « service_role » ni le mot de passe de la base.

## Étape 2 : le site (GitHub Pages)

1. Créez un compte sur **github.com**.
2. Créez un dépôt : cliquez sur **+** en haut à droite, puis sur **New repository**.
   - Nom : `lab-perf`
   - Visibilité : **Public**

   Le dépôt doit être public pour que l'hébergement soit gratuit. Seul le code est visible : les données des joueurs restent dans Supabase et sont protégées.
3. Mettez les fichiers dans le dépôt. Deux possibilités :
   - **Recommandée :** reliez GitHub à Claude (claude.ai : **Paramètres**, puis **Connecteurs**, puis **GitHub**) et donnez à Claude le nom du dépôt. Claude y dépose les fichiers, puis s'occupe des mises à jour futures.
   - **Manuelle :** dans le dépôt, cliquez sur **Add file**, puis **Upload files**, glissez les 4 fichiers et cliquez sur **Commit changes**.
4. Activez l'hébergement :
   1. Dans le dépôt, ouvrez **Settings**, puis **Pages**.
   2. Dans **Source**, choisissez *Deploy from a branch*.
   3. Dans **Branch**, choisissez `main` et `/ (root)`, puis cliquez sur **Save**.

   Après 1 à 2 minutes, le lien apparaît en haut de la page, par exemple `https://votre-nom.github.io/lab-perf/`.

## Étape 3 : premier lancement

1. Ouvrez le lien et cliquez sur **Créer un compte**. **Le premier compte créé devient administrateur** : créez donc le vôtre en premier.
2. Envoyez le lien aux coachs. Ils créent leur compte et arrivent sur un écran « en attente ».
3. Dans l'application, ouvrez **Accès des coachs** et donnez à chacun un rôle :
   - **Lecteur** : consulte sans modifier
   - **Coach** : ajoute et modifie
   - **Administrateur** : comme un coach, et gère aussi les accès

## Les vidéos

Les vidéos restent sur l'ordinateur de chacun (disque, clé USB) et s'ouvrent dans l'application **sans limite de taille**. Seuls le calage et les annotations sont enregistrés en ligne, donc partagés avec tous les coachs.

- Avec **Chrome** ou **Edge**, l'application se souvient du fichier : il suffit ensuite de cliquer sur « Rouvrir ».
- Pour qu'un coach ait la vidéo, collez un lien de téléchargement (Google Drive, WeTransfer…) dans la séance, rubrique **Données & synchronisation**.
- Si un coach ouvre un fichier différent de celui de la séance (nom ou taille différents), l'application l'avertit.
- Pour alléger une vidéo 4K, convertissez-la en 1080p avec **HandBrake**, un logiciel gratuit (préréglage « Fast 1080p30 »).

## Bon à savoir

- **Mise en veille :** sur l'offre gratuite, Supabase met le projet en veille après 7 jours sans aucune utilisation. Les données sont conservées. Pour relancer, ouvrez supabase.com, choisissez votre projet et cliquez sur **Restore project**.
- **Mot de passe oublié :** dans Supabase, ouvrez **Authentication**, puis **Users**, et supprimez le compte de la personne. Elle recrée son compte avec le même e-mail et vous revalidez son rôle. Ses données (séances, annotations) ne sont pas touchées.
- **Capacité :** l'offre gratuite donne 500 Mo de base de données. Une séance d'une heure (cardio + accéléromètre) occupe environ 0,15 Mo.

## Ajouter des fonctionnalités

Ouvrez une conversation avec Claude, donnez le lien du dépôt GitHub (`https://github.com/votre-nom/lab-perf`) et décrivez ce que vous voulez. Vous pouvez aussi écrire « applique les demandes en attente de la page Évolutions ». Claude modifie le code dans le dépôt et le site se met à jour tout seul, au même lien, sans perte de données.
