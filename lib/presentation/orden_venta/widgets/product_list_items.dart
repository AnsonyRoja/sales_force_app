import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductListItem extends StatelessWidget {
  final Map<String, dynamic> product;
  final int index;
  final double mediaScreen;
  final VoidCallback onRemove;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final double Function(String, String) calcularSaldoTotalProducts;

  const ProductListItem({
    Key? key,
    required this.product,
    required this.index,
    required this.mediaScreen,
    required this.onRemove,
    required this.onDecrease,
    required this.onIncrease,
    required this.calcularSaldoTotalProducts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
        final formatter = NumberFormat('#,##0.0000', 'es_ES');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: SizedBox(
            width: mediaScreen * 0.95,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onRemove,
                    child: Image.asset('lib/assets/Eliminar.png'),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 70,
                    child: Text(product['name']),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (product['quantity'] <= 0) {
                        return;
                      }
                      onDecrease();
                    },
                    child: Image.asset(
                      'lib/assets/menos.png',
                      width: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(product['quantity'].toString()),
                  ),
                  GestureDetector(
                    onTap: onIncrease,
                    child: Image.asset(
                      'lib/assets/Más-2.png',
                      width: 16,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.13,
                  ),
                  SizedBox(
                    width: mediaScreen * 0.25,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Flexible(
                        //   child: Text(
                        //     '\$${calcularSaldoTotalProducts(product['price'].toString(), product['quantity'].toString()).toStringAsFixed(4)}',
                        //   ),
                        // ),
                        Flexible(
                          child: Text(
                            '\$${formatter.format(double.parse(product['price'].toStringAsFixed(4)))}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
