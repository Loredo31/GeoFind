import 'dart:html' as html;
import 'dart:async';
import 'dart:typed_data';

class ImageProcessor {
  static Future<String> reduceImageQuality(
    String originalBase64, {
    int maxWidth = 800,
    double quality = 0.4,
  }) async {
    try {
      String cleanBase64 = originalBase64;
      if (originalBase64.contains(',')) {
        cleanBase64 = originalBase64.split(',').last;
      }

      final bytes = _base64ToBytes(cleanBase64);
      final originalBlob = html.Blob([bytes]);

      final completer = Completer<html.ImageElement>();
      final img = html.ImageElement();

      img.onLoad.listen((e) {
        completer.complete(img);
      });

      img.onError.listen((e) {
        completer.completeError('Error al cargar imagen');
      });

      img.src = html.Url.createObjectUrl(originalBlob);

      final loadedImg = await completer.future;

      final int imgWidth = loadedImg.width ?? 1;
      final int imgHeight = loadedImg.height ?? 1;
      final double aspectRatio = imgHeight / imgWidth;

      final int newWidth = imgWidth > maxWidth ? maxWidth : imgWidth;
      final int newHeight = (newWidth * aspectRatio).round();

      final canvas = html.CanvasElement()
        ..width = newWidth
        ..height = newHeight;

      final context = canvas.context2D as html.CanvasRenderingContext2D;
      context.drawImageScaled(loadedImg, 0, 0, newWidth, newHeight);

      final compressedBlob = await canvas.toBlob('image/jpeg', quality);

      if (compressedBlob == null) {
        throw Exception('No se pudo comprimir la imagen');
      }

      final compressedBase64 = await _blobToBase64(compressedBlob);

      html.Url.revokeObjectUrl(img.src!);
      return compressedBase64;
    } catch (error) {
      print('Error en reduceImageQuality: $error');
      return originalBase64;
    }
  }

  static Uint8List _base64ToBytes(String base64) {
    try {
      final byteString = html.window.atob(base64);
      final bytes = Uint8List(byteString.length);
      for (var i = 0; i < byteString.length; i++) {
        bytes[i] = byteString.codeUnitAt(i);
      }
      return bytes;
    } catch (e) {
      throw Exception('Error convirtiendo base64 a bytes: $e');
    }
  }

  static Future<String> _blobToBase64(html.Blob blob) async {
    final completer = Completer<String>();
    final reader = html.FileReader();

    reader.onLoadEnd.listen((e) {
      if (reader.result != null) {
        final String base64 = reader.result as String;
        final String pureBase64 = base64.split(',').last;
        completer.complete(pureBase64);
      } else {
        completer.completeError('Error leyendo blob');
      }
    });

    reader.onError.listen((e) {
      completer.completeError('Error en FileReader: $e');
    });

    reader.readAsDataUrl(blob);
    return completer.future;
  }

  static double getBase64SizeKB(String base64) {
    try {
      final cleanBase64 = base64.contains(',')
          ? base64.split(',').last
          : base64;
      final bytes = (cleanBase64.length * 3 / 4).ceil();
      return bytes / 1024;
    } catch (e) {
      return 0;
    }
  }
}
