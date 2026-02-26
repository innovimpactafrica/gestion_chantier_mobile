# gestion_chantier

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


/Users/macbookpro/Downloads/flutter3.38.3/bin/flutter pub add rename

flutter pub get
Ensuite TOUJOURS :

bash
Copier le code
dart run rename setBundleId --value com.wakana.btpconnect

/Users/macbookpro/Downloads/flutter3.38.3/bin/flutter  pub run rename setBundleId --value com.wakana.btpconnect
/Users/macbookpro/Downloads/flutter3.38.3/bin/flutter pub run rename setBundleId \
--targets android \
--value com.wakana.btpconnect

ou pour le nom de l’app :

bash
Copier le code
dart run rename setAppName --targets ios,android --value "BTP CONNECT"