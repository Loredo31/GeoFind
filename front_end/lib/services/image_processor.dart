import 'dart:html' as html;
import 'dart:async';
import 'dart:typed_data';

class ImageProcessor {
  /// Reduce la calidad y resolución de una imagen en base64
  /// [originalBase64] - Imagen original en base64 (con o sin data:image prefix)
  /// [maxWidth] - Ancho máximo para redimensionar
  /// [quality] - Calidad de compresión (0.1 a 1.0)
  static Future<String> reduceImageQuality(
    String originalBase64, {
    int maxWidth = 800,
    double quality = 0.4,
  }) async {
    try {
      // Limpiar el base64 si viene con data:image prefix
      String cleanBase64 = originalBase64;
      if (originalBase64.contains(',')) {
        cleanBase64 = originalBase64.split(',').last;
      }

      // Convertir base64 a Blob
      final bytes = _base64ToBytes(cleanBase64);
      final originalBlob = html.Blob([bytes]);
      
      // Crear imagen para redimensionar
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
      
      // Calcular nuevas dimensiones - CORREGIDO
      final int imgWidth = loadedImg.width ?? 1;
final int imgHeight = loadedImg.height ?? 1;
final double aspectRatio = imgHeight / imgWidth;

final int newWidth = imgWidth > maxWidth ? maxWidth : imgWidth;
final int newHeight = (newWidth * aspectRatio).round();
      
      // Crear canvas para redimensionar y comprimir
      final canvas = html.CanvasElement()
        ..width = newWidth
        ..height = newHeight;
      
      final context = canvas.context2D as html.CanvasRenderingContext2D;
      context.drawImageScaled(loadedImg, 0, 0, newWidth, newHeight);
      
      // // Convertir a Blob con calidad reducida
      // final compressedBlob = await canvas.toBlob('image/jpeg', quality);
      
      // // Convertir el Blob comprimido a base64
      // final compressedBase64 = await _blobToBase64(compressedBlob!);
      // Convertir a Blob con calidad reducida
final compressedBlob = await canvas.toBlob('image/jpeg', quality);

// Verificar que compressedBlob no sea null
if (compressedBlob == null) {
  throw Exception('No se pudo comprimir la imagen');
}

// Convertir el Blob comprimido a base64
final compressedBase64 = await _blobToBase64(compressedBlob);
      
      // Limpiar URL de objeto - CORREGIDO
html.Url.revokeObjectUrl(img.src!);      
      return compressedBase64;
    } catch (error) {
      print('Error en reduceImageQuality: $error');
      // Si hay error, devolver la original
      return originalBase64;
    }
  }

  /// Convierte base64 a Uint8List
  static Uint8List _base64ToBytes(String base64) {
    try {
      // Decodificar base64 a bytes
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

  /// Convierte Blob a base64
  //static Future<String> _blobToBase64(html.Blob blob) async {
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

  /// Obtiene el tamaño aproximado en KB de un base64
  static double getBase64SizeKB(String base64) {
    try {
      final cleanBase64 = base64.contains(',') ? base64.split(',').last : base64;
      // Fórmula aproximada: (base64_length * 3/4) - padding
      final bytes = (cleanBase64.length * 3 / 4).ceil();
      return bytes / 1024; // Convertir a KB
    } catch (e) {
      return 0;
    }
  }
}