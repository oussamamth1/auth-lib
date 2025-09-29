import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenify_auth/zenify_auth.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  /// Custom color for SnackBar
  final Color snackBarColor;

  /// Whether to show "Forgot Password" button
  final bool showForgotPassword;

  /// Callback for Forgot Password button
  final VoidCallback? onForgotPassword;

  /// Whether to show "Login with Code" button
  final bool showLoginwithCode;

  /// Callback for Login with Code button
  final VoidCallback? onLoginwithCode;

  /// Background image path (optional)
  final String? backgroundImage;

  /// Whether to show registration option
  final bool canRegister;

  /// Callback for registration
  final VoidCallback? onRegister;

  /// Background image fit
  final BoxFit backgroundImageFit;

  /// Overlay color for background image (to improve text readability)
  final Color? overlayColor;

  // === NEW FIELDS ===

  /// App logo/icon to display at the top
  final Widget? logo;

  /// App title text
  final String? title;

  /// Subtitle or description text
  final String? subtitle;

  /// Custom text style for title
  final TextStyle? titleStyle;

  /// Custom text style for subtitle
  final TextStyle? subtitleStyle;

  /// Whether to show social login options (Google, Facebook, etc.)
  final bool showSocialLogin;

  /// List of social login providers
  final List<SocialLoginProvider>? socialProviders;

  /// Custom login button text
  final String loginButtonText;

  /// Custom register button text
  final String registerButtonText;

  /// Custom forgot password button text
  final String forgotPasswordText;

  /// Custom login with code button text
  final String loginWithCodeText;

  /// Email field label
  final String emailLabel;

  /// Password field label
  final String passwordLabel;

  /// Whether to show "Remember Me" checkbox
  final bool showRememberMe;

  /// Remember me initial value
  final bool rememberMeInitialValue;

  /// Callback when remember me changes
  final ValueChanged<bool>? onRememberMeChanged;

  /// Whether to show login progress indicator
  final bool isLoading;

  /// Custom primary color theme
  final Color? primaryColor;

  /// Custom accent color
  final Color? accentColor;

  /// Custom text field decoration
  final InputDecoration? emailDecoration;
  final InputDecoration? passwordDecoration;

  /// Whether to enable biometric login (fingerprint/face ID)
  final bool enableBiometricLogin;

  /// Biometric login callback
  final VoidCallback? onBiometricLogin;

  /// Custom padding for the form
  final EdgeInsetsGeometry? formPadding;

  /// Whether to auto-focus email field
  final bool autoFocusEmail;

  /// Initial email value
  final String? initialEmail;

  /// Validation callback for email
  final String? Function(String?)? emailValidator;

  /// Validation callback for password
  final String? Function(String?)? passwordValidator;

  /// Custom form key
  final GlobalKey<FormState>? formKey;

  /// Whether to obscure password initially
  final bool obscurePasswordInitially;

  /// Terms and conditions text
  final String? termsText;

  /// Privacy policy text
  final String? privacyPolicyText;

  /// Callback for terms acceptance
  final VoidCallback? onTermsPressed;

  /// Callback for privacy policy
  final VoidCallback? onPrivacyPressed;

  /// Whether registration requires terms acceptance
  final bool requireTermsAcceptance;

  /// Custom divider text between login and social options
  final String dividerText;

  /// Custom button style for login button
  final ButtonStyle? loginButtonStyle;

  /// Custom button style for register button
  final ButtonStyle? registerButtonStyle;

  /// Custom button style for login with code button
  final ButtonStyle? loginWithCodeButtonStyle;

  /// Whether to show password strength indicator
  final bool showPasswordStrength;

  /// Minimum password length
  final int minPasswordLength;

  /// Custom error message for weak password
  final String? weakPasswordMessage;

  const LoginScreen({
    super.key,
    this.snackBarColor = Colors.red,
    this.showForgotPassword = false,
    this.showLoginwithCode = false,
    this.onForgotPassword,
    this.onLoginwithCode,
    this.backgroundImage,
    this.canRegister = false,
    this.onRegister,
    this.backgroundImageFit = BoxFit.cover,
    this.overlayColor,
    // New parameters with defaults
    this.logo,
    this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.showSocialLogin = false,
    this.socialProviders,
    this.loginButtonText = 'Login',
    this.registerButtonText = 'Register',
    this.forgotPasswordText = 'Forgot Password?',
    this.loginWithCodeText = 'Login with Code',
    this.emailLabel = 'Email',
    this.passwordLabel = 'Password',
    this.showRememberMe = false,
    this.rememberMeInitialValue = false,
    this.onRememberMeChanged,
    this.isLoading = false,
    this.primaryColor,
    this.accentColor,
    this.emailDecoration,
    this.passwordDecoration,
    this.enableBiometricLogin = false,
    this.onBiometricLogin,
    this.formPadding,
    this.autoFocusEmail = false,
    this.initialEmail,
    this.emailValidator,
    this.passwordValidator,
    this.formKey,
    this.obscurePasswordInitially = true,
    this.termsText,
    this.privacyPolicyText,
    this.onTermsPressed,
    this.onPrivacyPressed,
    this.requireTermsAcceptance = false,
    this.dividerText = 'OR',
    this.loginButtonStyle,
    this.registerButtonStyle,
    this.loginWithCodeButtonStyle,
    this.showPasswordStrength = false,
    this.minPasswordLength = 8,
    this.weakPasswordMessage,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

// Helper class for social login providers
class SocialLoginProvider {
  final String name;
  final Widget icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const SocialLoginProvider({
    required this.name,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final GlobalKey<FormState> _formKey;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _termsAccepted = false;
  String _passwordStrength = '';

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
    _obscurePassword = widget.obscurePasswordInitially;
    _rememberMe = widget.rememberMeInitialValue;

    // Set initial email if provided
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
  }

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

  String _calculatePasswordStrength(String password) {
    if (password.isEmpty) return '';
    if (password.length < widget.minPasswordLength) return 'Weak';

    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = [
      hasUpper,
      hasLower,
      hasDigit,
      hasSpecial,
    ].where((x) => x).length;

    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Weak';
    }
  }

  Color _getPasswordStrengthColor(String strength) {
    switch (strength) {
      case 'Weak':
        return Colors.red;
      case 'Fair':
        return Colors.orange;
      case 'Good':
        return Colors.yellow;
      case 'Strong':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLogo() {
    if (widget.logo == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Center(child: widget.logo!),
    );
  }

  Widget _buildTitle() {
    if (widget.title == null) {
      return Text(
        "Welcome Back",
        style:
            widget.titleStyle ??
            Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.backgroundImage != null ? Colors.black87 : null,
            ),
        textAlign: TextAlign.center,
      );
    }

    return Text(
      widget.title!,
      style:
          widget.titleStyle ??
          Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: widget.backgroundImage != null ? Colors.black87 : null,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    if (widget.subtitle == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Text(
        widget.subtitle!,
        style:
            widget.subtitleStyle ??
            Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.backgroundImage != null
                  ? Colors.black54
                  : Colors.grey[600],
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: widget.autoFocusEmail,
      decoration:
          widget.emailDecoration ??
          InputDecoration(
            labelText: widget.emailLabel,
            prefixIcon: const Icon(Icons.email_outlined),
            border: const OutlineInputBorder(),
          ),
      validator:
          widget.emailValidator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration:
              (widget.passwordDecoration ??
                      InputDecoration(
                        labelText: widget.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                      ))
                  .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
          validator:
              widget.passwordValidator ??
              (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password is required';
                }
                if (value.length < widget.minPasswordLength) {
                  return widget.weakPasswordMessage ??
                      'Password must be at least ${widget.minPasswordLength} characters';
                }
                return null;
              },
          onChanged: widget.showPasswordStrength
              ? (value) {
                  setState(() {
                    _passwordStrength = _calculatePasswordStrength(value);
                  });
                }
              : null,
        ),
        if (widget.showPasswordStrength && _passwordStrength.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Password strength: ',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                _passwordStrength,
                style: TextStyle(
                  fontSize: 12,
                  color: _getPasswordStrengthColor(_passwordStrength),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRememberMe() {
    if (!widget.showRememberMe) return const SizedBox.shrink();

    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
            widget.onRememberMeChanged?.call(_rememberMe);
          },
        ),
        const Text('Remember me'),
      ],
    );
  }

  Widget _buildForgotPasswordAndLoginWithCode() {
    // Build the right side actions (Forgot Password and/or Login with Code)
    List<Widget> actions = [];

    if (widget.showForgotPassword) {
      actions.add(
        TextButton(
          onPressed: widget.onForgotPassword,
          child: Text(widget.forgotPasswordText),
        ),
      );
    }

    if (widget.showLoginwithCode) {
      actions.add(
        TextButton(
          onPressed: widget.onLoginwithCode,
          style: widget.loginWithCodeButtonStyle,
          child: Text(widget.loginWithCodeText),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    // If both are shown, stack them vertically on the right
    if (actions.length > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: actions,
      );
    }

    // If only one is shown, display it normally
    return actions.first;
  }

  Widget _buildBiometricLogin() {
    if (!widget.enableBiometricLogin) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: OutlinedButton.icon(
        onPressed: widget.onBiometricLogin,
        icon: const Icon(Icons.fingerprint),
        label: const Text('Use Biometric Login'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    if (!widget.showSocialLogin ||
        widget.socialProviders == null ||
        widget.socialProviders!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.dividerText,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.socialProviders!.map(
          (provider) => Padding(
            padding: const EdgeInsets.only(bottom: 12, right: 8, left: 8),
            child: Container(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: provider.onPressed,
                icon: provider.icon,
                label: Text('Continue with ${provider.name}'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: provider.backgroundColor,
                  foregroundColor: provider.textColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAcceptance() {
    if (!widget.requireTermsAcceptance) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _termsAccepted,
            onChanged: (value) {
              setState(() {
                _termsAccepted = value ?? false;
              });
            },
          ),
          Expanded(
            child: Wrap(
              children: [
                const Text('I agree to the '),
                if (widget.termsText != null)
                  GestureDetector(
                    onTap: widget.onTermsPressed,
                    child: Text(
                      widget.termsText!,
                      style: TextStyle(
                        color:
                            widget.primaryColor ??
                            Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                if (widget.termsText != null &&
                    widget.privacyPolicyText != null)
                  const Text(' and '),
                if (widget.privacyPolicyText != null)
                  GestureDetector(
                    onTap: widget.onPrivacyPressed,
                    child: Text(
                      widget.privacyPolicyText!,
                      style: TextStyle(
                        color:
                            widget.primaryColor ??
                            Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
final authState = ref.watch(authProvider);
    final authNotifier = ref.watch(authProvider.notifier);

    return Container(
      padding: widget.formPadding ?? const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundImage != null
            ? Colors.white.withOpacity(0.9)
            : null,
        borderRadius: widget.backgroundImage != null
            ? BorderRadius.circular(16)
            : null,
        boxShadow: widget.backgroundImage != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(),
            _buildTitle(),
            _buildSubtitle(),
            const SizedBox(height: 32),

            // Email Field
            _buildEmailField(),
            const SizedBox(height: 16),

            // Password Field
            _buildPasswordField(),
            const SizedBox(height: 16),

            // Remember Me & Forgot Password/Login with Code Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRememberMe(),
                _buildForgotPasswordAndLoginWithCode(),
              ],
            ),

            const SizedBox(height: 24),

            // Terms Acceptance
            _buildTermsAcceptance(),

            // Login Button
            (widget.isLoading || _loading)
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      if (widget.requireTermsAcceptance && !_termsAccepted) {
                        _showSnackBarError(
                          context,
                          "Please accept the terms and conditions",
                        );
                        return;
                      }

                      setState(() => _loading = true);

                      try {
                        // Clear any existing cached user data before login
                       // await ZenifyAuth.clearUserData();
                        // final success = await authNotifier.login(
                        //   _emailController.text,
                        //   _passwordController.text,
                        // );
                        var success = await ref
                            .read(authProvider.notifier)
                            .login(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );

                        if (!mounted) return;

                        //final authState = ref.read(authProvider);
                       // final user = authState.user;

                        if (success!=null) {
                          // Optionally fetch fresh user profile after successful login
                          // await ref
                          //     .read(authProvider.notifier)
                          //     .fetchUserProfile();
                       //   await ZenifyAuth.saveUser(authState.user);
                        //  await ZenifyAuth.saveAuthToken(authState.user?.token);
                          _showSnackBar(context, "Login Successful!");
                          if (!mounted) return;
                          // Navigator.of(context).pushReplacementNamed('/home');
                        } else {
                          _showSnackBarError(context, "Invalid credentials");
                        }
                      } catch (e) {
                        if (!mounted) return;
                        _showSnackBarError(
                          context,
                          "Login failed: ${e.toString()}",
                        );
                      }

                      setState(() => _loading = false);
                    },
                    style:
                        widget.loginButtonStyle ??
                        ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: widget.primaryColor,
                        ),
                    child: Text(
                      widget.loginButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
            // Biometric Login
            _buildBiometricLogin(),

            // Social Login
            _buildSocialLogin(),

            // Register Option
            if (widget.canRegister) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: widget.backgroundImage != null
                          ? Colors.black87
                          : null,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onRegister,
                    style: widget.registerButtonStyle,
                    child: Text(
                      widget.registerButtonText,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: widget.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.title ?? "Login"),
        backgroundColor: widget.backgroundImage != null
            ? Colors.transparent
            : widget.primaryColor,
        elevation: widget.backgroundImage != null ? 0 : null,
      ),
      extendBodyBehindAppBar: widget.backgroundImage != null,
      body: Stack(
        children: [
          // Background Image
          if (widget.backgroundImage != null) ...[
            Positioned.fill(
              child: Image.network(
                widget.backgroundImage!,
                fit: widget.backgroundImageFit,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Overlay for better text readability
            if (widget.overlayColor != null)
              Positioned.fill(child: Container(color: widget.overlayColor)),
          ],

          // Login Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(child: _buildLoginForm()),
            ),
          ),
        ],
      ),
    );
  }
}
