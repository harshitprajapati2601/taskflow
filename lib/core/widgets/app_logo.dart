import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  
  const AppLogo({super.key,this.size =72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.28)
      ),
      child: Icon(Icons.task_alt,color: Colors.white,size: size* 0.55,),
    );
  }
}
