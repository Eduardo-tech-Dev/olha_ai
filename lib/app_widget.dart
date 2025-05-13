import 'package:flutter/material.dart';
import 'package:olha_ai/app_controller.dart';
import 'package:olha_ai/home_page.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.instance,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.red,
            brightness:
                AppController.instance.isDartTheme
                    ? Brightness.dark
                    : Brightness.light,
                    useMaterial3: false,
          ),
          home: HomePage(),
        );
      },
    );
  }
}
