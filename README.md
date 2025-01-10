

# Application Flutter pour l'extraction de texte et lecture vocale 📱

## Description du projet

Ce projet est une application mobile développée avec **Flutter**, permettant de scanner des documents, d'extraire du texte à l'aide de la technologie **OCR (Reconnaissance Optique de Caractères)**, et de lire ce texte à haute voix grâce à la fonctionnalité **Text-to-Speech (TTS)**. L'application intègre également la **Détection des Bords (Edge Detection)** pour améliorer la qualité des images scannées en ajustant les bords.

### Fonctionnalités principales

- **Scanner intelligent** 📸 : Utilisation de la caméra du téléphone pour capturer des documents, avec ajustement des bords pour une meilleure qualité d'image.
- **OCR (Reconnaissance Optique de Caractères)** 🧠 : Extraction du texte à partir des images scannées grâce à **Google ML Kit**.
- **Text-to-Speech (TTS)** 🗣️ : Lecture vocale du texte extrait pour une accessibilité améliorée.
- **Détection des bords (Edge Detection)** 🔍 : Identification des bords du document pour améliorer la reconnaissance du texte.

### Technologies utilisées

- **Flutter** : Framework mobile pour le développement multiplateforme (Android/iOS).
- **Google ML Kit** : Outil utilisé pour la reconnaissance de texte via OCR.
- **TTS (Text-to-Speech)** : Fonctionnalité de lecture vocale du texte extrait.
- **Edge Detection** : Amélioration de la prise de vue des documents.
- **Dart** : Langage de programmation utilisé avec Flutter.
- **Android Studio / Xcode** : Environnements de développement nécessaires.

## Vidéo démonstrative 🎥

Regardez la vidéo démonstrative de l'application ici :

[Vidéo Démonstrative](https://github.com/user-attachments/assets/5462cec3-ae0d-4901-96c2-12b4a2f65572)

> Cliquez sur l'image pour visionner la vidéo sur YouTube.

## Installation 🚀

### Prérequis

Avant de commencer, assurez-vous d'avoir les outils suivants installés sur votre machine :

- **Flutter** : Suivez les instructions d'installation sur [Flutter.dev](https://flutter.dev/docs/get-started/install).
- **Dart** : Dart est inclus avec Flutter.
- **Android Studio / Xcode** : IDE nécessaires pour exécuter l'application sur Android ou iOS.

### Cloner le projet

Clonez le dépôt Git sur votre machine avec la commande suivante dans votre terminal :

```bash
git clone https://github.com/AssmaeAlida/App-OCR-ScannerText.git
cd App-OCR-ScannerText
```

### Installer les dépendances

Dans le répertoire du projet, exécutez la commande suivante pour installer toutes les dépendances nécessaires :

```bash
flutter pub get
```

### Exécuter l'application

Pour lancer l'application sur un appareil ou un émulateur, utilisez la commande suivante :

```bash
flutter run
```

Cela démarrera l'application sur l'appareil connecté ou l'émulateur.

## Fonctionnalités détaillées ⚙️

1. **Scanner des documents** 📸 : Prenez une photo d'un document à l'aide de la caméra de l'appareil.
2. **OCR (Reconnaissance Optique de Caractères)** 🧠 : L'application extrait automatiquement le texte à partir de l'image scannée en utilisant **Google ML Kit**.
3. **Text-to-Speech (TTS)** 🗣️ : Le texte extrait est ensuite lu à haute voix pour aider les utilisateurs malvoyants ou pour une lecture facile.
4. **Edge Detection** 🔍 : L'application détecte les bords du document pour améliorer la capture de l'image et s'assurer que le texte est bien cadré.

## Défis techniques et solutions 🛠️

### Problèmes rencontrés

- **Qualité de l'image** 📷 : La reconnaissance de texte peut être affectée par une mauvaise qualité d'image ou des angles incorrects.
- **Reconnaissance d'écriture manuscrite** ✍️ : La reconnaissance de texte manuscrit est plus difficile, surtout si l'écriture est illisible.
- **Optimisation de la lecture vocale** 🔊 : Parfois, le texte long ou complexe nécessite des ajustements pour une lecture vocale claire.

### Solutions apportées

- **Amélioration de la qualité de l'image** 🖼️ : Utilisation de techniques de détection des bords pour améliorer l'alignement des documents scannés.
- **Prise en charge des langues multiples** 🌍 : Le modèle OCR a été configuré pour supporter plusieurs langues, notamment l'anglais et le français.
- **Optimisation de la lecture vocale** 🎤 : Le texte est découpé en phrases pour une lecture plus fluide.

## À venir 🚧

- **Mode hors ligne** 🌐 : L'application sera bientôt capable de fonctionner sans connexion Internet.
- **Traduction en temps réel** 🌍 : Ajout de la fonctionnalité de traduction du texte extrait dans différentes langues.
- **Commandes vocales** 🎙️ : Développement de commandes vocales pour contrôler l'application de manière plus interactive.

## Contribuer 🤝

Si vous souhaitez contribuer à ce projet, suivez ces étapes :

1. Fork ce projet.
2. Créez votre branche de fonctionnalité (ex : `git checkout -b feature/ma-fonctionnalité`).
3. Commit vos modifications (ex : `git commit -am 'Ajout de la fonctionnalité X'`).
4. Poussez vos changements (ex : `git push origin feature/ma-fonctionnalité`).
5. Ouvrez une Pull Request.

## Licence 📄

Distribué sous la licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus d'informations.

