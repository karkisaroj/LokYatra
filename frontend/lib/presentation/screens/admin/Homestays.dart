import 'package:flutter/material.dart';

class Homestays extends StatelessWidget {
  final ValueNotifier subtitleNotifier;
  const Homestays({super.key,required this.subtitleNotifier});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Homestays"),
    );
  }
}
