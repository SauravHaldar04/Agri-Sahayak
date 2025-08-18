import 'package:agri_sahayak/screens/advisor/advisor_dashboard.dart';
import 'package:agri_sahayak/screens/farmer/farmer_home_screen.dart';
import 'package:agri_sahayak/screens/policy/policy_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'widgets/auth_wrapper.dart';
import 'services/chat_service.dart';
import 'services/location_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() async {
  print('App starting...');
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    print('Initializing Supabase...');
    await SupabaseService.initialize();
    print('Supabase initialized successfully');

    // Initialize Chat Service
    print('Initializing Chat Service...');
    ChatService.instance.initializeGemini();
    print('Chat Service initialized');

    // Initialize Location Service (request permissions)
    print('Initializing Location Service...');
    try {
      await LocationService().getCurrentLocation();
      print('Location Service initialized successfully');
    } catch (e) {
      print('Location initialization failed: $e');
      // Continue without location - it's not critical for app startup
    }

    print('All services initialized, starting app...');
  } catch (e) {
    print('Critical error during initialization: $e');
    // You might want to show an error screen here
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider()..initialize(),
      child: MaterialApp(
        title: 'Agri Sahayak',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/farmer-dashboard': (context) => FarmerHomeScreen(),
          '/advisor-dashboard': (context) => AdvisorDashboard(),
          '/policymaker-dashboard': (context) => PolicyDashboardScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('AuthWrapper: isLoading=${authProvider.isLoading}, isAuthenticated=${authProvider.isAuthenticated}');
        
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        if (!authProvider.isAuthenticated) {
          print('AuthWrapper: User not authenticated, showing login');
          return LoginScreen();
        }

        print('AuthWrapper: User authenticated with role: ${authProvider.userRole}');
        
        // Navigate based on user role
        switch (authProvider.userRole) {
          case 'advisor':
            return const AdvisorDashboard();
          case 'policymaker':
            return const PolicyDashboardScreen();
          case 'farmer':
          default:
            return const FarmerHomeScreen();
        }
      },
    );
  }
}
