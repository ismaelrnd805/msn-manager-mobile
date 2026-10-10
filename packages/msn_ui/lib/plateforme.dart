// Détection de plateforme pour la navigation adaptative.
// Centralisée ici : plus AUCUN import de main.dart dans la bibliothèque.
import 'package:flutter/foundation.dart';

/// Vrai sur téléphone (Android/iOS) : barre de navigation en bas.
/// Faux sur desktop (Windows) : rail de navigation à gauche.
bool get isMobile =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// Nom de plateforme stocké côté base locale et envoyé au serveur
/// (appareils : un compte Android + un compte Windows, spéc. §3).
String get plateformeCourante => isMobile ? 'android' : 'windows';
