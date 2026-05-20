import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class HairlineRule extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  const HairlineRule({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Container(
      margin: margin,
      height: 0.5,
      color: cl.rule,
    );
  }
}
