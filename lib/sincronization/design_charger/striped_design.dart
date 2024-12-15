import 'package:flutter/material.dart';

class StripedContainer extends StatelessWidget {
  final double syncPercentages;

  const StripedContainer({super.key, required this.syncPercentages});

  @override
  Widget build(BuildContext context) {
    bool isComplete = syncPercentages == 100;

    return SizedBox(
      width: 150 * (syncPercentages / 100),
      height: 50, // Puedes ajustar la altura según tus necesidades
      child: CustomPaint(
        painter: StripedPainter(isComplete: isComplete),
      ),
    );
  }
}

class StripedPainter extends CustomPainter {
  final bool isComplete;

  StripedPainter({required this.isComplete});

  @override
  void paint(Canvas canvas, Size size) {


    Paint paint = Paint()
      ..color = Color(0XFF00722D).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    double stripeWidth = 10; 
    for (double x = 0; x < size.width; x += 1 * stripeWidth) {
     isComplete == false ? canvas.drawRect(Rect.fromLTWH(x, 0, stripeWidth, size.height), paint) : null ;

    }

    if (isComplete) {
      
      paint.color = Color(0XFF00722D);
      paint.style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is StripedPainter) {
      return oldDelegate.isComplete != isComplete;
    }
    return false;
  }
}
