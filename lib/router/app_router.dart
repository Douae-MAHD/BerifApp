import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/admin/dashboard_admin.dart';
import '../screens/admin/admin_main_layout.dart'; // Importe le Layout

final GoRouter appRouter = GoRouter(
  initialLocation: '/admin',
  routes: [
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminMainLayout(),
    ),
  ],
);
