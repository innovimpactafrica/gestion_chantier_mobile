import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../bloc/worker/worker_check_bloc.dart';
import '../bloc/worker/worker_check_event.dart';
import '../bloc/worker/worker_check_state.dart';

class QRScannerPage extends StatefulWidget {
  final int workerId;

  const QRScannerPage({Key? key, required this.workerId}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isProcessing = false;
  bool _dialogShown = false;

  // =============================
  /// 📍 GPS
  // =============================
  Future<Position?> _getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (_) {
      return null;
    }
  }

  // =============================
  /// 📷 Scan QR (UNE SEULE FOIS)
  // =============================
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final qrCode = capture.barcodes.first.rawValue;
    if (qrCode == null || qrCode.isEmpty) return;

    setState(() => _isProcessing = true);

    // Stop scanner immédiatement
    await _scannerController.stop();

    _showLoading();

    final position = await _getCurrentPosition();
    if (position == null) {
      _closeLoading();
      _showError('Impossible de récupérer la position GPS');
      _resetScanner();
      return;
    }

    context.read<WorkerCheckBloc>().add(
      DoWorkerCheckEvent(
        widget.workerId,
        qrCodeText: qrCode,
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }

  // =============================
  /// UI helpers
  // =============================
  void _showLoading() {
    _dialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Traitement du pointage...'),
          ],
        ),
      ),
    );
  }

  void _closeLoading() {
    if (_dialogShown) {
      Navigator.of(context, rootNavigator: true).pop();
      _dialogShown = false;
    }
  }



  /// =============================
  /// ✅ SUCCÈS
  /// =============================
  void _showSuccess(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Succès'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5C02),
            ),
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  /// =============================
  /// ❌ ERREUR
  /// =============================
  void _showError(String message) {
    setState(() {
    //  errorMessage = message;
    });

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Erreur'),
          ],
        ),
        content: Text(message),
        actions: [
         /* TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
               // isScanning = true;
              //  errorMessage = null;
              });
            },
            child: Text('Réessayer', style: TextStyle(color: Colors.white)),
          ),*/
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5C02),
            ),
            child: const Text(
              'Retour',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _resetScanner() async {
    setState(() => _isProcessing = false);
    await _scannerController.start();
  }

  // =============================
  /// UI
  // =============================
  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkerCheckBloc, WorkerCheckState>(
      listener: (context, state) {
        if (state is WorkerCheckSuccess) {
         _closeLoading();

    // _showSuccess(result['message']);

          // ⬅️ Retour COMPLET à la page 1
          Future.microtask(() {
            Navigator.of(context).pop(true); // ⬅️ retour à la page précédente
          });
        }

        if (state is WorkerCheckError) {
          _closeLoading();
         _showError(state.message);
         // _resetScanner();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pointer'),
          backgroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _isProcessing
                      ? 'Traitement en cours...'
                      : 'Placez le code QR dans le cadre',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}
