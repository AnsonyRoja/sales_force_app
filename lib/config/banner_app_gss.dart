import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CirclePainterGss extends CustomPainter {
  ui.Image? image;
  CirclePainterGss(this.image, );


  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = Colors.white 
      ..style = PaintingStyle.fill;

    final centerY1 = size.height / 20;

    
    canvas.drawCircle(Offset(350, centerY1), 155, paint);

    
    if (image != null) {

      final Rect imageRect = Rect.fromCircle(center: Offset(size.width * 0.8, size.height * 0.5), radius: size.width * 0.13);
      canvas.drawImageRect(image!, 
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()), 
        imageRect, Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  static Future<CirclePainterGss> load() async {
    final image = await _loadImage('lib/assets/Grupo san simon@3x.png');
    return CirclePainterGss(image);
  }

  static Future<ui.Image> _loadImage(String asset) async {
    final ByteData data = await rootBundle.load(asset);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }
}
