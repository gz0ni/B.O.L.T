import 'package:bolt/common/context.dart';
import 'package:bolt/state.dart';
import 'package:bolt/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Полноэкранный сканер QR-кодов через камеру.
/// Возвращает строку (rawValue) через [Navigator.pop] либо null при закрытии.
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _torchOn = false;
  bool _resolved = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCapture(BarcodeCapture capture) {
    if (_resolved) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    _resolved = true;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleCapture,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s4,
                  vertical: AppSpace.s2,
                ),
                child: Row(
                  children: [
                    Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () async {
                          final torch = !_torchOn;
                          await _controller.toggleTorch();
                          if (mounted) setState(() => _torchOn = torch);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            _torchOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.s4),
                child: Text(
                  context.appLocalizations.scanQrCode,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: semantic.on, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> showQrScanner() async {
  final navigator = globalState.navigatorKey.currentState;
  if (navigator == null) return null;
  return navigator.push<String>(
    MaterialPageRoute<String>(
      builder: (_) => const QrScannerScreen(),
      fullscreenDialog: true,
    ),
  );
}