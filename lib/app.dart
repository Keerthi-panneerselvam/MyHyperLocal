import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_storefronts/config/routes.dart';
import 'package:unified_storefronts/config/theme.dart';
import 'package:unified_storefronts/presentation/providers/auth_provider.dart';
import 'package:unified_storefronts/presentation/screens/onboarding/register_screen.dart';
import 'package:unified_storefronts/presentation/screens/store_management/dashboard_screen.dart';

class UnifiedStorefrontsApp extends StatelessWidget {
  const UnifiedStorefrontsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unified Storefronts',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: AppRoutes.routes,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Check if the user is authenticated
          if (authProvider.isAuthenticated) {
            return const DashboardScreen();
          } else {
            return const RegisterScreen();
          }
        },
      ),
    );
  }
}