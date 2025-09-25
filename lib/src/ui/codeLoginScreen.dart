import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zenify_auth/zenify_auth.dart';

// Import your auth provider (adjust path as needed)
// import 'auth_provider.dart';

class CodeLoginScreen extends ConsumerStatefulWidget {
  /// Custom logo/image to display
  final Widget? logo;

  /// App title
  final String? title;

  /// Subtitle or description
  final String? subtitle;

  /// Code field label
  final String codeLabel;

  /// Code field hint text
  final String codeHint;

  /// Note text below the code field
  final String? noteText;

  /// Login with email button text
  final String loginWithEmailText;

  /// Search/Submit button text
  final String searchButtonText;

  /// Custom primary color
  final Color? primaryColor;

  /// Background image path
  final String? backgroundImage;

  /// Background image fit
  final BoxFit backgroundImageFit;

  /// Overlay color for background image
  final Color? overlayColor;

  /// Callback for login with email button
  final VoidCallback? onLoginWithEmail;

  /// Callback when travellers are found
  final Function(List<dynamic> travellers)? onTravellersFound;

  /// Callback when a traveller is selected
  final Function(dynamic traveller)? onTravellerSelected;

  /// Custom code validator
  final String? Function(String?)? codeValidator;

  /// Whether to auto-format code with prefix
  final bool autoFormatCode;

  /// Code prefix (e.g., "XY-")
  final String codePrefix;

  /// Custom form padding
  final EdgeInsetsGeometry? formPadding;

  const CodeLoginScreen({
    super.key,
    this.logo,
    this.title,
    this.subtitle,
    this.codeLabel = 'Entrez votre code',
    this.codeHint = 'ex: XY-12345',
    this.noteText = 'Remarque : saisissez votre code avec le préfixe « XY- »',
    this.loginWithEmailText = 'Se connecter avec email',
    this.searchButtonText = 'Recherche',
    this.primaryColor,
    this.backgroundImage,
    this.backgroundImageFit = BoxFit.cover,
    this.overlayColor,
    this.onLoginWithEmail,
    this.onTravellersFound,
    this.onTravellerSelected,
    this.codeValidator,
    this.autoFormatCode = true,
    this.codePrefix = 'XY-',
    this.formPadding,
  });

  @override
  ConsumerState<CodeLoginScreen> createState() => _CodeLoginScreenState();
}

class _CodeLoginScreenState extends ConsumerState<CodeLoginScreen> {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<dynamic> _selectedTravellers = [];
  bool _showTravellersList = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.red,
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInvalidCodeDialog(String? code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Code invalide'),
          content: Text(
            'Veuillez vérifier le code ou entrer un autre code correct. Code: ${code ?? ""}',
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showTravellersLists(List<dynamic> travellers) {
    setState(() {
      _selectedTravellers = travellers;
      _showTravellersList = true;
    });
  }

  void _handleTravellerSelection(dynamic traveller) async {
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
        final token = ref.read(authProvider);
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome ${traveller.user?.firstName}!v${token.user?.token} Login successful!',
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
          Navigator.pop(context); // Go back to main login

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

  void _handleBackToCodeInput() {
    setState(() {
      _showTravellersList = false;
      _selectedTravellers = [];
    });
  }

  void _handleSearchButton() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String code = _codeController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final travellers = await ref
          .read(authProvider.notifier)
          .fetchTravellersByCode(code);

      if (!mounted) return;

      if (travellers.isEmpty) {
        _showSnackBar('Veuillez vérifier votre code et réessayer. Code: $code');
      } else {
        // Show travellers list in the same screen
        _showTravellersLists(travellers);

        // Call the callback if provided
        if (widget.onTravellersFound != null) {
          widget.onTravellersFound!(travellers);
        }
      }
    } catch (error) {
      if (!mounted) return;

      final authState = ref.read(authProvider);
      _showSnackBar(
        authState.error ??
            'Erreur de connexion. Vérifiez votre connexion Internet et réessayez.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateCode(String? value) {
    if (widget.codeValidator != null) {
      return widget.codeValidator!(value);
    }

    if (value == null || value.trim().isEmpty) {
      return 'Code is required';
    }

    if (widget.autoFormatCode && !value.startsWith(widget.codePrefix)) {
      return 'Code should start with ${widget.codePrefix}';
    }

    return null;
  }

  Widget _buildLogo() {
    if (widget.logo != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Center(child: widget.logo!),
      );
    }

    // Default logo placeholder
    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Center(
        child: Icon(Icons.qr_code_scanner, size: 80, color: Colors.blue),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title ?? 'Login with Code',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: widget.backgroundImage != null ? Colors.white : null,
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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: widget.backgroundImage != null
              ? Colors.white70
              : Colors.grey[600],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
          ],
          decoration: InputDecoration(
            labelText: widget.codeLabel,
            hintText: widget.codeHint,
            prefixIcon: const Icon(Icons.confirmation_number_outlined),
            border: const OutlineInputBorder(),
          ),
          validator: _validateCode,
          textCapitalization: TextCapitalization.characters,
        ),
        if (widget.noteText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.noteText!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildLoginWithEmailButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: widget.onLoginWithEmail,
        child: Text(
          widget.loginWithEmailText,
          style: TextStyle(
            color: widget.primaryColor ?? const Color(0xFF1D5E9B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSearchButton,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.primaryColor ?? const Color(0xFF1D5E9B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.searchButtonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: widget.formPadding ?? const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundImage != null
            ? Colors.white.withOpacity(0.95)
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
            _buildCodeField(),
            const SizedBox(height: 16),
            _buildLoginWithEmailButton(),
            const SizedBox(height: 24),
            _buildSearchButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTravellersListView() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundImage != null
            ? Colors.white.withOpacity(0.95)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with back button
          Row(
            children: [
              IconButton(
                onPressed: _handleBackToCodeInput,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Retour',
              ),
              Expanded(
                child: Text(
                  'Sélectionnez un voyageur',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
          const SizedBox(height: 16),

          // Travellers list
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _selectedTravellers.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final Traveller traveller = _selectedTravellers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        widget.primaryColor ?? const Color(0xFF1D5E9B),
                    child: Text(
                      traveller.user?.firstName?.isNotEmpty == true
                          ? traveller.user!.firstName![0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    traveller.user?.firstName ?? 'Nom non disponible',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (traveller.user?.email?.isNotEmpty == true)
                        Text('Email: ${traveller.user?.email}'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _handleTravellerSelection(traveller),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state for error handling
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        _showSnackBar(next.error!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showTravellersList
              ? 'Sélectionnez un voyageur'
              : widget.title ?? 'Code Login',
        ),
        backgroundColor: widget.backgroundImage != null
            ? Colors.transparent
            : widget.primaryColor,
        foregroundColor: widget.backgroundImage != null ? Colors.white : null,
        elevation: widget.backgroundImage != null ? 0 : null,
        leading: _showTravellersList
            ? IconButton(
                onPressed: _handleBackToCodeInput,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
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
            if (widget.overlayColor != null)
              Positioned.fill(child: Container(color: widget.overlayColor)),
          ],

          // Content
          SafeArea(
            child: _showTravellersList
                ? _buildTravellersListView()
                : Center(child: SingleChildScrollView(child: _buildForm())),
          ),
        ],
      ),
    );
  }
  
void _navigateToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
