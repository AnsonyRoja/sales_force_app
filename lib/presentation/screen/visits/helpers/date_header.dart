import 'package:flutter/material.dart';
import 'package:intl/intl.dart';




class DateHeader extends StatefulWidget {
   final DateTime focusedDay;
  final Function(DateTime) onDateChanged;
  const DateHeader({super.key, required this.focusedDay, required this.onDateChanged});

  @override
  State<DateHeader> createState() => _DateHeaderState();
}

class _DateHeaderState extends State<DateHeader> {
    late DateTime _focusedDay;

String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  void initState() {
    _focusedDay = widget.focusedDay;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(
                                _focusedDay.year, _focusedDay.month - 1);
                          });
                           widget.onDateChanged(_focusedDay);
                        },
                        icon: Image.asset('lib/assets/Izq.png'),
                      ),
                      Text(
                        capitalize(
                            DateFormat('MMMM yyyy', 'es').format(_focusedDay)),
                        style: const TextStyle(
                            fontSize: 18, fontFamily: 'Poppins Bold'),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(
                                _focusedDay.year, _focusedDay.month + 1);
                          });
                          widget.onDateChanged(_focusedDay);

                        },
                        icon: Image.asset('lib/assets/Der.png'),
                      )
                    ],
                  );
  }
}



