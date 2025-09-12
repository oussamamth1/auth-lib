import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  /// Custom color for SnackBar
  final Color snackBarColor;

  /// Whether to show "Forgot Password" button
  final bool showForgotPassword;

  /// Callback for Forgot Password button
  final VoidCallback? onForgotPassword;

  const LoginScreen({
    super.key,
    this.snackBarColor = Colors.red, // default red
    this.showForgotPassword = false,
    this.onForgotPassword,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: widget.snackBarColor),
    );
  }
  void _showSnackBarError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 24),

            // Forgot Password Button
            if (widget.showForgotPassword)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onForgotPassword,
                  child: const Text("Forgot Password?"),
                ),
              ),

            const SizedBox(height: 16),

            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => _loading = true);

                 var success = await ref
                          .read(authProvider.notifier)
                          .login(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );

                      if (!mounted) return;

                      final authState = ref.read(authProvider);
                      final user = authState.user;

                      if (success ) {
                        _showSnackBar(context, "Login Successful!");
                        if (!mounted) return;
                       // Navigator.of(context).pushReplacementNamed('/');
                      } else {
                        _showSnackBarError(context, "Invalid credentials");
                      }

                      setState(() => _loading = false);
                    },
                    child: const Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}
