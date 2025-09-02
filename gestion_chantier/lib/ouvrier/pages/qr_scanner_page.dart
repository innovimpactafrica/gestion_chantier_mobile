import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  bool hasCameraPermission = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      // Pause camera on hot reload
      controller!.pauseCamera();
      // Resume camera after hot reload
      controller!.resumeCamera();
    }
  }

  Future<void> _checkCameraPermission() async {
    // Pour l'instant, on suppose que la permission est accordée
    // Le plugin qr_code_scanner gère automatiquement les permissions
    setState(() {
      hasCameraPermission = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        backgroundColor: const Color(0xFF1A365D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          hasCameraPermission
              ? Stack(
                children: [
                  QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                      borderColor: const Color(0xFFFF5C02),
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: MediaQuery.of(context).size.width * 0.8,
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Placez le code QR dans le cadre pour le scanner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!isScanning)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Code QR détecté ! Traitement en cours...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              )
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      size: 80,
                      color: Color(0xFF8A98A8),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Permission caméra requise',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A365D),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Cette application nécessite l\'accès à la caméra pour scanner les codes QR.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xFF8A98A8)),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _checkCameraPermission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5C02),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        'Autoriser la caméra',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen(
      (scanData) {
        if (isScanning && scanData.code != null) {
          setState(() {
            isScanning = false;
          });

          // Traiter le code QR scanné
          _processQRCode(scanData.code!);
        }
      },
      onError: (error) {
        // Gérer les erreurs de permission ou autres erreurs
        print('Erreur QR Scanner: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur caméra: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }

  void _processQRCode(String qrCode) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Traitement du pointage...'),
              ],
            ),
          );
        },
      );

      // Récupérer la position actuelle
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Déclencher le pointage avec le code QR et la position
      BlocProvider.of<WorkerCheckBloc>(context).add(
        DoWorkerCheckEvent(
          widget.workerId,
          qrCodeText: qrCode,
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      // Écouter le résultat du pointage
      await for (final state
          in BlocProvider.of<WorkerCheckBloc>(context).stream) {
        if (state is WorkerCheckSuccess) {
          Navigator.of(context).pop(); // Fermer le dialog de chargement

          // Afficher le succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pointage réussi à ${state.time}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Retourner à la page précédente
          Navigator.of(context).pop();
          break;
        } else if (state is WorkerCheckError) {
          Navigator.of(context).pop(); // Fermer le dialog de chargement

          // Afficher l'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );

          // Réactiver le scan
          setState(() {
            isScanning = true;
          });
          break;
        }
      }
    } catch (e) {
      Navigator.of(context).pop(); // Fermer le dialog de chargement

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      // Réactiver le scan
      setState(() {
        isScanning = true;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
