import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/storage/secure_token_storage.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/dashboard/presentation/providers/dashboard_provider.dart';

class PixelMobileApp extends StatelessWidget {
  const PixelMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => const SecureTokenStorage()),
        Provider(
          create: (context) =>
              ApiClient(tokenStorage: context.read<SecureTokenStorage>()),
        ),
        Provider(
          create: (context) => AuthRepository(
            apiClient: context.read<ApiClient>(),
            tokenStorage: context.read<SecureTokenStorage>(),
          ),
        ),
        Provider(
          create: (context) =>
              DashboardRepository(apiClient: context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AuthProvider(repository: context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => DashboardProvider(
            repository: context.read<DashboardRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'PIXEL Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const LoginScreen(),
      ),
    );
  }
}
