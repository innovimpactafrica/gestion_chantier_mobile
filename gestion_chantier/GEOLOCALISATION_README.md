# Modification du Service de Pointage - Géolocalisation

## Vue d'ensemble

Le service de pointage dans le dossier `ouvrier` a été modifié pour inclure la géolocalisation lors du scan QR. Maintenant, lorsqu'un ouvrier clique sur "Scanner QR Code", l'application récupère automatiquement sa position GPS (latitude et longitude) et l'envoie avec la requête de pointage.

## Modifications apportées

### 1. Dépendances ajoutées

**pubspec.yaml**
```yaml
dependencies:
  geolocator: ^13.0.1
```

### 2. Permissions ajoutées

**Android (android/app/src/main/AndroidManifest.xml)**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS (ios/Runner/Info.plist)**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette application nécessite l'accès à votre position pour le pointage des ouvriers sur le chantier.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Cette application nécessite l'accès à votre position pour le pointage des ouvriers sur le chantier.</string>
```

### 3. Nouveaux services créés

**lib/ouvrier/services/location_service.dart**
- Service singleton pour gérer la géolocalisation
- Méthodes pour vérifier les permissions et récupérer la position
- Gestion des erreurs de géolocalisation

### 4. Service worker modifié

**lib/ouvrier/services/worker_service.dart**
- Méthode `checkInOut` modifiée pour accepter un paramètre `qrCodeText` optionnel
- Récupération automatique de la position GPS
- Envoi des coordonnées avec la requête de pointage

### 5. Bloc et événements modifiés

**lib/ouvrier/bloc/worker/worker_check_event.dart**
- `DoWorkerCheckEvent` modifié pour accepter un `qrCodeText` optionnel

**lib/ouvrier/bloc/worker/worker_check_bloc.dart**
- Passage du QR code au repository

**lib/ouvrier/repository/worker_repository.dart**
- Méthode `checkInOut` modifiée pour passer le QR code

### 6. Interface utilisateur

**lib/ouvrier/pages/pointage_page.dart**
- Ajout d'un widget `LocationTestWidget` pour tester la géolocalisation
- Affichage de la position actuelle
- Boutons pour tester la récupération de position et le pointage

## Format de la requête API

La requête de pointage suit maintenant ce format (comme dans votre exemple Swagger) :

```
POST /api/workers/{workerId}/check?qrCodeText={qrCode}&latitude={lat}&longitude={lng}
```

Exemple :
```
POST /api/workers/1/check?qrCodeText=MYaysI63OH2gF%2BzpZUJ%2BbzYnvxoxxr%2FL3Ac%2BJmw0PG8%3D&latitude=14.682353969052512&longitude=-17.45883369820994
```

## Test de la fonctionnalité

### 1. Widget de test intégré

L'application inclut maintenant un widget de test dans la page de pointage qui permet de :
- Récupérer la position actuelle
- Afficher les coordonnées GPS
- Tester le pointage avec un QR code simulé

### 2. Script de test

Un fichier `test_location.dart` a été créé pour tester la géolocalisation indépendamment de l'application.

Pour l'exécuter :
```bash
dart test_location.dart
```

## Utilisation

1. **Pointage normal** : L'utilisateur clique sur "Scanner QR Code" et l'application récupère automatiquement sa position
2. **Gestion des erreurs** : L'application affiche des messages d'erreur appropriés si la géolocalisation échoue

## Gestion des erreurs

L'application gère les cas suivants :
- Services de localisation désactivés
- Permissions refusées
- Erreurs de récupération de position
- Erreurs de réseau lors du pointage

## Notes importantes

- Les permissions de géolocalisation sont demandées automatiquement lors de la première utilisation
- La précision de la position est configurée sur `LocationAccuracy.high`
- Le QR code est optionnel dans la requête API
- Les coordonnées sont envoyées en tant que paramètres de requête (query parameters)
