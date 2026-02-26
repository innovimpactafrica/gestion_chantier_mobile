import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
class QrCodeModal extends StatelessWidget {
  QrCodeModal({Key? key, required this.text}) : super(key: key);

  final String text;
  final GlobalKey repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'QR Code de pointage',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            textAlign: TextAlign.center,
            'Vos employés doivent scanner ce QR code pour marquer leur présence. '
                'Pour activer le pointage, scannez le QR code depuis l’onglet "Adresse" afin de le lier à un point de présence.',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),

          const SizedBox(height: 20),

          /// QR CODE
          RepaintBoundary(
            key: repaintKey,
            child: QrImageView(
              data: text,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          /// ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _saveQrCode(context),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareQrCode,
              ),
             /* IconButton(
                icon: const Icon(Icons.print),
                onPressed: _printQrCode,
              ),*/
            ],
          ),
        ],
      ),
    );
  }

  /// 📸 Capture QR
  Future<Uint8List> _captureQrCode() async {
    final boundary =
    repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// 📥 Télécharger
  Future<void> _saveQrCode(BuildContext context) async {
    final bytes = await _captureQrCode();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/qrcode.png');
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code enregistré')),
    );
  }

  /// 📤 Partager
  Future<void> _shareQrCode() async {
    final bytes = await _captureQrCode();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/qrcode.png');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)]);
  }

  /// 🖨 Imprimer
  Future<void> _printQrCode() async {
    final bytes = await _captureQrCode();
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }
}
