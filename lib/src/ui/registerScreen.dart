import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  /// Custom color for SnackBar
  final Color snackBarColor;

  /// Background image path (optional)
  final String? backgroundImage;

  /// Whether to show login option
  final bool canLogin;

  /// Callback for login
  final VoidCallback? onLogin;

  /// Background image fit
  final BoxFit backgroundImageFit;

  /// Overlay color for background image (to improve text readability)
  final Color? overlayColor;

  /// Whether to require terms acceptance
  final bool requireTermsAcceptance;

  /// Callback for terms and conditions
  final VoidCallback? onTermsPressed;

  // === NEW FIELDS ===

  /// App logo widget (optional)
  final Widget? logo;

  /// Custom title text
  final String title;

  /// Custom subtitle text (optional)
  final String? subtitle;

  /// Primary button color
  final Color primaryButtonColor;

  /// Primary button text color
  final Color primaryButtonTextColor;

  /// Secondary button color (for login button)
  final Color secondaryButtonColor;

  /// Secondary button text color
  final Color secondaryButtonTextColor;

  /// Input field decoration theme
  final InputDecoration? inputDecorationTheme;

  /// Custom text style for title
  final TextStyle? titleStyle;

  /// Custom text style for subtitle
  final TextStyle? subtitleStyle;

  /// Whether to show password strength indicator
  final bool showPasswordStrength;

  /// Minimum password length
  final int minimumPasswordLength;

  /// Whether to require email verification
  final bool requireEmailVerification;

  /// Custom validation for email
  final String? Function(String?)? emailValidator;

  /// Custom validation for password
  final String? Function(String?)? passwordValidator;

  /// Custom validation for confirm password
  final String? Function(String?, String?)? confirmPasswordValidator;

  /// Whether to show additional fields (phone, name, etc.)
  final bool showAdditionalFields;

  /// Whether phone number is required
  final bool requirePhoneNumber;

  /// Whether full name is required
  final bool requireFullName;

  /// Whether to show social login options
  final bool showSocialLogin;

  /// Google sign-in callback
  final VoidCallback? onGoogleSignIn;

  /// Facebook sign-in callback
  final VoidCallback? onFacebookSignIn;

  /// Apple sign-in callback
  final VoidCallback? onAppleSignIn;

  /// Custom social login buttons
  final List<Widget>? customSocialButtons;

  /// Loading state indicator
  final bool isLoading;

  /// Custom loading widget
  final Widget? loadingWidget;

  /// Whether to auto-focus first field
  final bool autoFocusFirstField;

  /// Custom padding for the form
  final EdgeInsetsGeometry? formPadding;

  /// Custom spacing between form fields
  final double fieldSpacing;

  /// Whether to use card layout for form
  final bool useCardLayout;

  /// Card elevation (if using card layout)
  final double cardElevation;

  /// Card border radius (if using card layout)
  final BorderRadius? cardBorderRadius;

  /// Custom error message color
  final Color errorColor;

  /// Success message color
  final Color successColor;

  /// Custom app bar (optional)
  final PreferredSizeWidget? appBar;

  /// Whether to show back button
  final bool showBackButton;

  /// Custom back button callback
  final VoidCallback? onBackPressed;

  /// Footer widget (optional)
  final Widget? footer;

  /// Custom keyboard type for email field
  final TextInputType emailKeyboardType;

  /// Whether to enable auto-complete
  final bool enableAutoComplete;

  /// Registration success callback
  final Function(Map<String, dynamic> userData)? onRegistrationSuccess;

  /// Registration error callback
  final Function(String error)? onRegistrationError;

  /// Privacy policy callback
  final VoidCallback? onPrivacyPolicyPressed;

  /// Custom agreement text
  final String? agreementText;

  /// Whether to require age verification
  final bool requireAgeVerification;

  /// Minimum age requirement
  final int minimumAge;

  const RegisterScreen({
    super.key,
    this.snackBarColor = Colors.green,
    this.backgroundImage,
    this.canLogin = true,
    this.onLogin,
    this.backgroundImageFit = BoxFit.cover,
    this.overlayColor,
    this.requireTermsAcceptance = false,
    this.onTermsPressed,

    // New parameters with default values
    this.logo,
    this.title = 'Create Account',
    this.subtitle,
    this.primaryButtonColor = Colors.blue,
    this.primaryButtonTextColor = Colors.white,
    this.secondaryButtonColor = Colors.grey,
    this.secondaryButtonTextColor = Colors.black,
    this.inputDecorationTheme,
    this.titleStyle,
    this.subtitleStyle,
    this.showPasswordStrength = true,
    this.minimumPasswordLength = 6,
    this.requireEmailVerification = false,
    this.emailValidator,
    this.passwordValidator,
    this.confirmPasswordValidator,
    this.showAdditionalFields = false,
    this.requirePhoneNumber = false,
    this.requireFullName = false,
    this.showSocialLogin = false,
    this.onGoogleSignIn,
    this.onFacebookSignIn,
    this.onAppleSignIn,
    this.customSocialButtons,
    this.isLoading = false,
    this.loadingWidget,
    this.autoFocusFirstField = true,
    this.formPadding,
    this.fieldSpacing = 16.0,
    this.useCardLayout = false,
    this.cardElevation = 4.0,
    this.cardBorderRadius,
    this.errorColor = Colors.red,
    this.successColor = Colors.green,
    this.appBar,
    this.showBackButton = true,
    this.onBackPressed,
    this.footer,
    this.emailKeyboardType = TextInputType.emailAddress,
    this.enableAutoComplete = true,
    this.onRegistrationSuccess,
    this.onRegistrationError,
    this.onPrivacyPolicyPressed,
    this.agreementText,
    this.requireAgeVerification = false,
    this.minimumAge = 13,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();

  bool _loading = false;
  bool _acceptTerms = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.autoFocusFirstField) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.showAdditionalFields && widget.requireFullName) {
          FocusScope.of(context).requestFocus(FocusNode());
        }
      });
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: widget.successColor),
    );
  }

  void _showSnackBarError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: widget.errorColor),
    );
  }

  void _calculatePasswordStrength(String password) {
    if (!widget.showPasswordStrength) return;

    double strength = 0.0;
    String strengthText = '';

    if (password.length >= widget.minimumPasswordLength) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    if (strength < 0.3) {
      strengthText = 'Weak';
    } else if (strength < 0.6) {
      strengthText = 'Fair';
    } else if (strength < 0.8) {
      strengthText = 'Good';
    } else {
      strengthText = 'Strong';
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
    });
  }

  String? _validateEmail(String? value) {
    if (widget.emailValidator != null) {
      return widget.emailValidator!(value);
    }

    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (widget.passwordValidator != null) {
      return widget.passwordValidator!(value);
    }

    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < widget.minimumPasswordLength) {
      return 'Password must be at least ${widget.minimumPasswordLength} characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (widget.confirmPasswordValidator != null) {
      return widget.confirmPasswordValidator!(value, _passwordController.text);
    }

    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (!widget.requirePhoneNumber) return null;

    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[+]?[1-9][\d]{0,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-()]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (!widget.requireAgeVerification) return null;

    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    if (age < widget.minimumAge) {
      return 'You must be at least ${widget.minimumAge} years old';
    }
    return null;
  }

  Widget _buildPasswordStrengthIndicator() {
    if (!widget.showPasswordStrength) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: _passwordStrength,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _passwordStrength < 0.3
                      ? Colors.red
                      : _passwordStrength < 0.6
                      ? Colors.orange
                      : _passwordStrength < 0.8
                      ? Colors.yellow[700]!
                      : Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _passwordStrengthText,
              style: TextStyle(
                fontSize: 12,
                color: _passwordStrength < 0.3
                    ? Colors.red
                    : _passwordStrength < 0.6
                    ? Colors.orange
                    : _passwordStrength < 0.8
                    ? Colors.yellow[700]!
                    : Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    if (!widget.showSocialLogin) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Or continue with"),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (widget.onGoogleSignIn != null)
              _buildSocialButton(
                onPressed: widget.onGoogleSignIn!,
                icon: Icons.g_mobiledata,
                label: "Google",
              ),
            if (widget.onFacebookSignIn != null)
              _buildSocialButton(
                onPressed: widget.onFacebookSignIn!,
                icon: Icons.facebook,
                label: "Facebook",
              ),
            if (widget.onAppleSignIn != null)
              _buildSocialButton(
                onPressed: widget.onAppleSignIn!,
                icon: Icons.apple,
                label: "Apple",
              ),
          ],
        ),
        if (widget.customSocialButtons != null) ...[
          const SizedBox(height: 8),
          ...widget.customSocialButtons!,
        ],
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildRegisterForm() {
    final padding = widget.formPadding ?? const EdgeInsets.all(24);

    Widget form = Container(
      padding: padding,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundImage != null
            ? Colors.white.withOpacity(0.9)
            : widget.useCardLayout
            ? Theme.of(context).cardColor
            : null,
        borderRadius: widget.useCardLayout || widget.backgroundImage != null
            ? (widget.cardBorderRadius ?? BorderRadius.circular(16))
            : null,
        boxShadow: widget.useCardLayout || widget.backgroundImage != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: widget.cardElevation,
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
            // Logo
            if (widget.logo != null) ...[
              Center(child: widget.logo!),
              SizedBox(height: widget.fieldSpacing),
            ],

            // Title
            Text(
              widget.title,
              style:
                  widget.titleStyle ??
                  Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.backgroundImage != null
                        ? Colors.black87
                        : null,
                  ),
              textAlign: TextAlign.center,
            ),

            // Subtitle
            if (widget.subtitle != null) ...[
              SizedBox(height: widget.fieldSpacing / 2),
              Text(
                widget.subtitle!,
                style:
                    widget.subtitleStyle ??
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.backgroundImage != null
                          ? Colors.black54
                          : null,
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            SizedBox(height: widget.fieldSpacing * 2),

            // Name Field
            if (widget.showAdditionalFields || widget.requireFullName) ...[
              TextFormField(
                controller: _nameController,
                validator: widget.requireFullName ? _validateName : null,
                enableSuggestions: widget.enableAutoComplete,
                decoration:
                    (widget.inputDecorationTheme?.copyWith(
                      labelText: "Full Name",
                      prefixIcon: const Icon(Icons.person_outline),
                    ) ??
                    const InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    )),
              ),
              SizedBox(height: widget.fieldSpacing),
            ],

            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: widget.emailKeyboardType,
              validator: _validateEmail,
              enableSuggestions: widget.enableAutoComplete,
              decoration:
                  (widget.inputDecorationTheme?.copyWith(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                  ) ??
                  const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  )),
            ),
            SizedBox(height: widget.fieldSpacing),

            // Phone Field
            if (widget.showAdditionalFields || widget.requirePhoneNumber) ...[
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                decoration:
                    (widget.inputDecorationTheme?.copyWith(
                      labelText: "Phone Number",
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ) ??
                    const InputDecoration(
                      labelText: "Phone Number",
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    )),
              ),
              SizedBox(height: widget.fieldSpacing),
            ],

            // Age Field
            if (widget.requireAgeVerification) ...[
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                validator: _validateAge,
                decoration:
                    (widget.inputDecorationTheme?.copyWith(
                      labelText: "Age",
                      prefixIcon: const Icon(Icons.cake_outlined),
                    ) ??
                    const InputDecoration(
                      labelText: "Age",
                      prefixIcon: Icon(Icons.cake_outlined),
                      border: OutlineInputBorder(),
                    )),
              ),
              SizedBox(height: widget.fieldSpacing),
            ],

            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              validator: _validatePassword,
              onChanged: _calculatePasswordStrength,
              decoration:
                  (widget.inputDecorationTheme?.copyWith(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ) ??
                  InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                    border: const OutlineInputBorder(),
                  )),
            ),
            _buildPasswordStrengthIndicator(),
            SizedBox(height: widget.fieldSpacing),

            // Confirm Password Field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              validator: _validateConfirmPassword,
              decoration:
                  (widget.inputDecorationTheme?.copyWith(
                    labelText: "Confirm Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword,
                      ),
                    ),
                  ) ??
                  InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  )),
            ),
            SizedBox(height: widget.fieldSpacing),

            // Terms and Conditions / Privacy Policy
            if (widget.requireTermsAcceptance) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) =>
                        setState(() => _acceptTerms = value ?? false),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onTermsPressed,
                      child: RichText(
                        text: TextSpan(
                          text: widget.agreementText ?? "I agree to the ",
                          style: TextStyle(
                            color: widget.backgroundImage != null
                                ? Colors.black87
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          children: [
                            if (widget.onTermsPressed != null)
                              TextSpan(
                                text: "Terms and Conditions",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            if (widget.onPrivacyPolicyPressed != null) ...[
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: widget.fieldSpacing),
            ],

            // Social Login Buttons
            _buildSocialLoginButtons(),

            SizedBox(height: widget.fieldSpacing * 1.5),

            // Register Button
            (widget.isLoading || _loading)
                ? Center(
                    child:
                        widget.loadingWidget ??
                        const CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: _handleRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryButtonColor,
                      foregroundColor: widget.primaryButtonTextColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

            // Login Option
            if (widget.canLogin) ...[
              SizedBox(height: widget.fieldSpacing * 1.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: widget.backgroundImage != null
                          ? Colors.black87
                          : null,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onLogin,
                    style: TextButton.styleFrom(
                      foregroundColor: widget.secondaryButtonTextColor,
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],

            // Footer
            if (widget.footer != null) ...[
              SizedBox(height: widget.fieldSpacing),
              widget.footer!,
            ],
          ],
        ),
      ),
    );

    return widget.useCardLayout
        ? Card(
            elevation: widget.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius:
                  widget.cardBorderRadius ?? BorderRadius.circular(16),
            ),
            child: form,
          )
        : form;
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.requireTermsAcceptance && !_acceptTerms) {
      _showSnackBarError(context, "Please accept the terms and conditions");
      return;
    }

    setState(() => _loading = true);

    try {
      // Prepare user data
      Map<String, dynamic> userData = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      };

      if (widget.showAdditionalFields || widget.requireFullName) {
        userData['name'] = _nameController.text.trim();
      }

      if (widget.showAdditionalFields || widget.requirePhoneNumber) {
        userData['phone'] = _phoneController.text.trim();
      }

      if (widget.requireAgeVerification) {
        userData['age'] = int.tryParse(_ageController.text);
      }

      // Call custom success callback if provided
      if (widget.onRegistrationSuccess != null) {
        widget.onRegistrationSuccess!(userData);
        return;
      }

      // Default registration logic
      var success = await ref
          .read(authProvider.notifier)
          .register(
            userData['name'] ?? '',
            userData['email'],
            userData['password'],
          );

      if (!mounted) return;

      if (success) {
        _showSnackBar(context, "Account created successfully!");
        // Navigate to home or login
        // Navigator.of(context).pushReplacementNamed('/home');
      } else {
        if (widget.onRegistrationError != null) {
          widget.onRegistrationError!("Registration failed");
        } else {
          _showSnackBarError(context, "Registration failed");
        }
      }
    } catch (e) {
      if (!mounted) return;
      if (widget.onRegistrationError != null) {
        widget.onRegistrationError!(e.toString());
      } else {
        _showSnackBarError(context, "Registration failed: ${e.toString()}");
      }
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          widget.appBar ??
          (widget.showBackButton
              ? AppBar(
                  title: Text(widget.title),
                  backgroundColor: widget.backgroundImage != null
                      ? Colors.transparent
                      : null,
                  elevation: widget.backgroundImage != null ? 0 : null,
                  leading: widget.onBackPressed != null
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: widget.onBackPressed,
                        )
                      : null,
                )
              : null),
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

          // Register Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(child: _buildRegisterForm()),
            ),
          ),
        ],
      ),
    );
  }
}
