import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenify_auth/src/ui/codeLoginScreen.dart';
import 'package:zenify_auth/src/ui/login.dart';
import 'package:zenify_auth/src/ui/travellerList.dart';
import 'package:zenify_auth/zenify_auth.dart';
import '../providers/auth_provider.dart';

class AuthFlowScreen extends ConsumerStatefulWidget {
  const AuthFlowScreen({super.key});

  @override
  ConsumerState<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends ConsumerState<AuthFlowScreen> {
  List<Traveller> _selectedTravellers = [];

  void _showMainLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          title: 'Welcome Back',
          subtitle: 'Sign in to your account',
          logo: const FlutterLogo(size: 80),
          showLoginwithCode: true,
          showForgotPassword: true,
          canRegister: true,
          showSocialLogin: true,
          primaryColor: const Color(0xFF1D5E9B),
          socialProviders: [
            SocialLoginProvider(
              name: 'Google',
              icon: const Icon(Icons.g_mobiledata, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Google login not implemented')),
                );
              },
              backgroundColor: Colors.red,
              textColor: Colors.white,
            ),
            SocialLoginProvider(
              name: 'Facebook',
              icon: const Icon(Icons.facebook, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Facebook login not implemented'),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              textColor: Colors.white,
            ),
          ],
          onLoginwithCode: _showCodeLogin,
          onForgotPassword: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Forgot password not implemented')),
            );
          },
          onRegister: _showRegistrationScreen,
        ),
      ),
    );
  }

  void _showCodeLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CodeLoginScreen(
          title: 'Login with Code',
          subtitle: 'Enter your traveller code to continue',
          logo: const Icon(Icons.qr_code_scanner, size: 80, color: Colors.blue),
          primaryColor: const Color(0xFF1D5E9B),
          onLoginWithEmail: _showMainLogin,
          // onTravellersFound: _showTravellersList,
          codeLabel: "SV-",
          codePrefix: "SV-",
        ),
      ),
    );
  }

  // void _showTravellersList(List<dynamic> travellers) {
  //   setState(() {
  //     _selectedTravellers = travellers.cast<Traveller>();
  //   });

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => TravellersListScreen(
  //         travellers: _selectedTravellers,
  //         onTravellerSelected: _handleTravellerSelection,
  //         onBackPressed: () {
  //           // Navigator.pop(context); // Go back to code login
  //         },
  //       ),
  //     ),
  //   );
  // }

  void _handleTravellerSelection(Traveller traveller) async {
    try {
      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Logging in...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );

      final success = await ref
          .read(authProvider.notifier)
          .loginWithTraveller(traveller);

      if (success) {
        if (!mounted) return;

        // Clear the loading snackbar
        ScaffoldMessenger.of(context).clearSnackBars();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome ${traveller.user?.firstName}! Login successful!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );

        // Use WidgetsBinding to ensure navigation happens after current frame
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          await Future.delayed(const Duration(milliseconds: 800));
          if (!mounted) return;
          _navigateToHome();
        });
      }
    } catch (e) {
      if (!mounted) return;

      // Clear loading snackbar and show error
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _navigateToHome() {
    // Navigate back to the first page and clear all previous routes
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          title: 'Welcome Back',
          subtitle: 'Sign in to your account',
          logo: const FlutterLogo(size: 80),
          showLoginwithCode: true,
          showForgotPassword: true,
          canRegister: true,
          showSocialLogin: true,
          primaryColor: const Color(0xFF1D5E9B),
          socialProviders: [
            SocialLoginProvider(
              name: 'Google',
              icon: const Icon(Icons.g_mobiledata, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Google login not implemented')),
                );
              },
              backgroundColor: Colors.red,
              textColor: Colors.white,
            ),
            SocialLoginProvider(
              name: 'Facebook',
              icon: const Icon(Icons.facebook, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Facebook login not implemented'),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              textColor: Colors.white,
            ),
          ],
          onLoginwithCode: _showCodeLogin,
          onForgotPassword: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Forgot password not implemented')),
            );
          },
          onRegister: _showRegistrationScreen,
        ),
      ), // Back to first page
      // Remove all previous routes
    );
  }

  void _showRegistrationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(
          onBackPressed: () {
            Navigator.pop(context); // Go back to main login
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is already authenticated
    final authState = ref.watch(authProvider);

    // if (authState.isAuthenticated) {
    //   // If already authenticated, go directly to home
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _navigateToHome();
    //   });
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    // Start with code login screen (Step 1)
    return CodeLoginScreen(
      title: 'Login with Code',
      subtitle: 'Enter your traveller code to continue',
      logo: const Icon(Icons.qr_code_scanner, size: 80, color: Colors.blue),
      primaryColor: const Color(0xFF1D5E9B),
      onLoginWithEmail: _showMainLogin,
      // onTravellersFound: _showTravellersList,
      codeLabel: "SV-",
      codePrefix: "SV-",
    );
  }
}

// Placeholder for your actual home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF1D5E9B),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 80, color: Color(0xFF1D5E9B)),
            SizedBox(height: 16),
            Text(
              'Welcome to the App!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D5E9B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
