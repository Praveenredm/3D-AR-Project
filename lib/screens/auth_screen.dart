import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'forgot_password_screen.dart';
import 'phone_auth_screen.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // LOGIN / SIGN UP
  // ===========================================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    /*
     * IMPORTANT:
     * Replace this section with your Firebase Authentication logic.
     *
     * Currently this only validates the form and opens MainShell.
     */

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const MainShell(),
      ),
    );
  }

  // ===========================================================================
  // FORGOT PASSWORD
  // ===========================================================================

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ForgotPasswordScreen(),
      ),
    );
  }

  // ===========================================================================
  // PHONE AUTH
  // ===========================================================================

  void _openPhoneAuth() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PhoneAuthScreen(),
      ),
    );
  }

  // ===========================================================================
  // SOCIAL LOGIN
  // ===========================================================================

  void _googleLogin() {
    _showProviderMessage(
      'Google',
      'Connect Google Authentication to enable Google Sign-In.',
    );
  }

  void _appleLogin() {
    _showProviderMessage(
      'Apple',
      'Connect Apple Authentication to enable Apple Sign-In.',
    );
  }

  void _facebookLogin() {
    _showProviderMessage(
      'Facebook',
      'Connect Facebook Authentication to enable Facebook Login.',
    );
  }

  void _showProviderMessage(
    String provider,
    String message,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('$provider Sign-In'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // TOGGLE LOGIN / SIGNUP
  // ===========================================================================

  void _toggleAuthMode() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // =================================================================
                // BACK BUTTON
                // =================================================================

                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                      color: AppTheme.textPrimary,
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================================
                // LOGO
                // =================================================================

                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primarySoft,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(48, 48),
                      painter: IsometricCubePainter(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================================
                // TITLE
                // =================================================================

                Text(
                  _isSignUp
                      ? 'Create Account'
                      : 'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _isSignUp
                      ? 'Join the 3D augmented learning platform'
                      : 'Login to continue your learning journey',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // =================================================================
                // SIGNUP - FULL NAME
                // =================================================================

                if (_isSignUp) ...[
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }

                      if (value.trim().length < 2) {
                        return 'Enter a valid name';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),
                ],

                // =================================================================
                // EMAIL
                // =================================================================

                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your email';
                    }

                    final emailRegex = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    );

                    if (!emailRegex.hasMatch(
                      value.trim(),
                    )) {
                      return 'Enter a valid email address';
                    }

                    return null;
                  },
                ),

                // =================================================================
                // SIGNUP - PHONE
                // =================================================================

                if (_isSignUp) ...[
                  const SizedBox(height: 14),

                  _buildTextField(
                    controller: _phoneController,
                    hintText: 'Mobile Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter your mobile number';
                      }

                      final digits = value.replaceAll(
                        RegExp(r'[^0-9]'),
                        '',
                      );

                      if (digits.length < 10) {
                        return 'Enter a valid mobile number';
                      }

                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 14),

                // =================================================================
                // PASSWORD
                // =================================================================

                _buildPasswordField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: _obscurePassword,
                  onToggle: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword;
                    });
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Please enter your password';
                    }

                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }

                    return null;
                  },
                ),

                // =================================================================
                // SIGNUP - CONFIRM PASSWORD
                // =================================================================

                if (_isSignUp) ...[
                  const SizedBox(height: 14),

                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: _obscureConfirmPassword,
                    onToggle: () {
                      setState(() {
                        _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Please confirm your password';
                      }

                      if (value !=
                          _passwordController.text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                  ),
                ],

                // =================================================================
                // FORGOT PASSWORD
                // =================================================================

                if (!_isSignUp) ...[
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _openForgotPassword,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // =================================================================
                // LOGIN / SIGN UP BUTTON
                // =================================================================

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppTheme.primaryBlue
                              .withValues(alpha: 0.5),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      shadowColor:
                          AppTheme.primaryBlue
                              .withValues(alpha: 0.35),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isSignUp
                                ? 'Sign Up'
                                : 'Login',
                            style:
                                const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 28),

                // =================================================================
                // DIVIDER
                // =================================================================

                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Text(
                        'or continue with',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w500,
                          color:
                              Colors.grey.shade500,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // =================================================================
                // PROVIDERS
                // =================================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    // GOOGLE
                    _buildSocialButton(
                      child: const GoogleLogo(),
                      tooltip: 'Google',
                      onTap: _googleLogin,
                    ),

                    const SizedBox(width: 12),

                    // APPLE
                    _buildSocialButton(
                      child: const Icon(
                        Icons.apple_rounded,
                        color: Colors.black,
                        size: 29,
                      ),
                      tooltip: 'Apple',
                      onTap: _appleLogin,
                    ),

                    const SizedBox(width: 12),

                    // FACEBOOK
                    _buildSocialButton(
                      child: const FacebookLogo(),
                      tooltip: 'Facebook',
                      onTap: _facebookLogin,
                    ),

                    const SizedBox(width: 12),

                    // PHONE
                    _buildSocialButton(
                      child: const Icon(
                        Icons.phone_rounded,
                        color: AppTheme.primaryBlue,
                        size: 25,
                      ),
                      tooltip: 'Phone',
                      onTap: _openPhoneAuth,
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // =================================================================
                // LOGIN / SIGNUP TOGGLE
                // =================================================================

                GestureDetector(
                  onTap: _toggleAuthMode,
                  child: RichText(
                    text: TextSpan(
                      text: _isSignUp
                          ? 'Already have an account? '
                          : "Don't have an account? ",
                      style: const TextStyle(
                        color:
                            AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: _isSignUp
                              ? 'Log In'
                              : 'Sign Up',
                          style: const TextStyle(
                            color:
                                AppTheme.primaryBlue,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TEXT FIELD
  // ===========================================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      decoration: _inputDecoration(
        hintText: hintText,
        icon: icon,
      ),
    );
  }

  // ===========================================================================
  // PASSWORD FIELD
  // ===========================================================================

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
      validator: validator,
      decoration: _inputDecoration(
        hintText: hintText,
        icon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppTheme.textTertiary,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // INPUT DECORATION
  // ===========================================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        icon,
        color: AppTheme.textTertiary,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppTheme.primaryBlue,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.8,
        ),
      ),
    );
  }

  // ===========================================================================
  // SOCIAL BUTTON
  // ===========================================================================

  Widget _buildSocialButton({
    required Widget child,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),
        child: Container(
          width: 60,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// GOOGLE LOGO
// =============================================================================

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(
            text: 'G',
            style: TextStyle(
              color: Color(0xFF4285F4),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FACEBOOK LOGO
// =============================================================================

class FacebookLogo extends StatelessWidget {
  const FacebookLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 27,
      height: 27,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ISOMETRIC CUBE LOGO
// =============================================================================

class IsometricCubePainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final double w = size.width;
    final double h = size.height;

    final Paint topPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;

    final Paint leftPaint = Paint()
      ..color = const Color(0xFF0EA5E9)
      ..style = PaintingStyle.fill;

    final Paint rightPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;

    final Path top = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..lineTo(w * 0.88, h * 0.27)
      ..lineTo(w * 0.5, h * 0.49)
      ..lineTo(w * 0.12, h * 0.27)
      ..close();

    final Path left = Path()
      ..moveTo(w * 0.12, h * 0.27)
      ..lineTo(w * 0.5, h * 0.49)
      ..lineTo(w * 0.5, h * 0.94)
      ..lineTo(w * 0.12, h * 0.72)
      ..close();

    final Path right = Path()
      ..moveTo(w * 0.5, h * 0.49)
      ..lineTo(w * 0.88, h * 0.27)
      ..lineTo(w * 0.88, h * 0.72)
      ..lineTo(w * 0.5, h * 0.94)
      ..close();

    canvas.drawPath(top, topPaint);
    canvas.drawPath(left, leftPaint);
    canvas.drawPath(right, rightPaint);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}