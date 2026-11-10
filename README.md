# Equip Rent

Application mobile et web de location d'équipements en Tunisie, développée avec Flutter et Supabase.

> Projet personnel, en cours de développement.

## L'idée

Beaucoup de gens ont du matériel qu'ils utilisent rarement, et d'autres en ont besoin pour quelques jours seulement. Equip Rent met les deux en relation : on publie une annonce, on réserve, on discute et on paie depuis l'application.

## Fonctionnalités

- Inscription et connexion, vérification par code OTP, mot de passe oublié.
- Publication d'annonces avec photos, prix et gouvernorat.
- Recherche et filtres, avec une recherche qui reconnaît les gouvernorats écrits de plusieurs façons (arabe, français, translittération : « Sfax », « صفاقس »…).
- Réservations et suivi des locations.
- Messagerie entre loueur et locataire.
- Portefeuille (wallet) avec historique des transactions.
- Tableau de bord du propriétaire et statistiques.
- Favoris.
- Interface en **arabe, français et anglais**.

## Technologies

- **Flutter / Dart** (Android, iOS, web, desktop)
- **Supabase** (authentification, base PostgreSQL, stockage)
- Internationalisation avec `flutter_localizations` et fichiers `.arb`
- Tests unitaires (`flutter test`)

## Lancer le projet

1. Créer un projet sur [Supabase](https://supabase.com).
2. Copier `env.example.json` en `env.json` et y mettre l'URL et la clé publishable du projet.
3. Lancer :

```bash
flutter pub get
flutter run --dart-define-from-file=env.json
```

## Auteur

Ahmed Zekri, élève ingénieur en Data Science & BI à ESPRIT.
