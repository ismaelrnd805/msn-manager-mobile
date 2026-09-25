/// Partage natif Android/iOS des messages, images et PDF
/// (l'opérateur bascule ensuite vers Messenger/WhatsApp).
library;

import 'package:share_plus/share_plus.dart';

class ShareService {
  const ShareService();

  /// Partage un texte prêt à coller (message client).
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// Partage un fichier (PDF généré, image PNG…).
  Future<void> shareFile(
    String path, {
    String? subject,
    String? text,
  }) async {
    await Share.shareXFiles(
      [XFile(path)],
      subject: subject,
      text: text,
    );
  }
}
