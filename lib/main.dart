import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'features/auth/view/auth_view.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: MaterialApp(
        title: 'Tarım Pazarı',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthView(),
      ),
    );
  }
}