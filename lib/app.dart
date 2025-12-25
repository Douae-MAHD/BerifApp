import 'package:flutter/material.dart';
import 'router/app_router.dart';

class BerifMVPApp extends StatelessWidget {
  const BerifMVPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Berif MVP',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE53935)),
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
      ),
      routerConfig: appRouter,
    );
  }
}
