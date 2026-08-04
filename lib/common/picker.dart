import 'dart:io';
import 'dart:typed_data';

import 'package:bolt/common/common.dart';
import 'package:bolt/widgets/qr_scanner_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

class Picker {
  Future<PlatformFile?> pickerFile() async {
    return FilePicker.pickFile(initialDirectory: await appPath.downloadDirPath);
  }

  Future<String?> saveFile(String fileName, Uint8List bytes) async {
    final path = await FilePicker.saveFile(
      fileName: fileName,
      initialDirectory: await appPath.downloadDirPath,
      bytes: bytes,
    );
    if (!system.isAndroid && path != null) {
      final file = File(path);
      await file.safeWriteAsBytes(bytes);
    }
    return path;
  }

  Future<String?> saveFileWithPath(String fileName, String localPath) async {
    final localFile = File(localPath);
    if (!await localFile.exists()) {
      await localFile.create(recursive: true);
    }
    final bytes = await localFile.readAsBytes();
    final path = await FilePicker.saveFile(
      fileName: fileName,
      initialDirectory: await appPath.downloadDirPath,
      bytes: bytes,
    );
    await localFile.safeDelete();
    return path;
  }

  Future<String?> pickerConfigQRCode() async {
    final result = system.isAndroid
        ? await showQrScanner()
        : await _qrFromImage();
    if (result == null) {
      return null;
    }
    if (!result.isUrl) {
      throw currentAppLocalizations.pleaseUploadValidQrcode;
    }
    return result;
  }

  Future<String?> _qrFromImage() async {
    final file = await FilePicker.pickFile(
      type: FileType.image,
      initialDirectory: await appPath.downloadDirPath,
    );
    if (file == null) {
      return null;
    }
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return null;
    }
    final pixels = Int32List(decoded.width * decoded.height);
    var index = 0;
    for (final pixel in decoded) {
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      final a = pixel.a.toInt();
      pixels[index++] = (a << 24) | (r << 16) | (g << 8) | b;
    }
    try {
      final source = RGBLuminanceSource(decoded.width, decoded.height, pixels);
      final bitmap = BinaryBitmap(HybridBinarizer(source));
      final result = QRCodeReader().decode(bitmap);
      return result.text;
    } on ReaderException {
      return null;
    }
  }
}

extension PlatformFileExt on PlatformFile {
  Future<Uint8List> readBytes() {
    return readAsBytes();
  }
}

final picker = Picker();
