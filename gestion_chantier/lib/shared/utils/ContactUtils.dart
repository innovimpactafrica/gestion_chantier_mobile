import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUtils {
  /// Lance un appel téléphonique
  static Future<void> callPhone(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Impossible de lancer l\'appel vers $phoneNumber');
    }
  }

  /// Ouvre WhatsApp pour discuter avec le numéro donné
  static Future<void> openWhatsApp(String phoneNumber) async {
    // Formater le numéro pour WhatsApp international (ex: +221...)
    final Uri url = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Impossible d\'ouvrir WhatsApp pour $phoneNumber');
    }
  }
}
