import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'main_shell.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isLoading = false;

  String _verificationId = '';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // SEND OTP
  // ===========================================================================

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    /*
     * ---------------------------------------------------------------
     * FIREBASE PHONE AUTH
     * ---------------------------------------------------------------
     *
     * This is where Firebase Phone Authentication will be connected.
     *
     * Firebase will provide a verificationId.
     *
     * Example:
     *
     * await FirebaseAuth.instance.verifyPhoneNumber(
     *   phoneNumber: '+91${_phoneController.text.trim()}',
     *
     *   verificationCompleted: (PhoneAuthCredential credential) {
     *     // Automatic verification
     *   },
     *
     *   verificationFailed: (FirebaseAuthException e) {
     *     // Handle error
     *   },
     *
     *   codeSent: (String verificationId, int? resendToken) {
     *     _verificationId = verificationId;
     *   },
     *
     *   codeAutoRetrievalTimeout: (String verificationId) {
     *     _verificationId = verificationId;
     *   },
     * );
     *
     * ---------------------------------------------------------------
     *
     * For now this simulates sending the OTP.
     */

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isOtpSent = true;
    });

    _showMessage(
      'OTP Sent',
      'A verification code has been sent to +91 ${_phoneController.text.trim()}.',
    );
  }

  // ===========================================================================
  // VERIFY OTP
  // ===========================================================================

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (_otpController.text.trim().length != 6) {
      _showError('Please enter the 6-digit OTP.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    /*
     * ---------------------------------------------------------------
     * FIREBASE OTP VERIFICATION
     * ---------------------------------------------------------------
     *
     * When Firebase is connected:
     *
     * final credential =
     *     PhoneAuthProvider.credential(
     *       verificationId: _verificationId,
     *       smsCode: _otpController.text.trim(),
     *     );
     *
     * await FirebaseAuth.instance.signInWithCredential(
     *   credential,
     * );
     *
     * ---------------------------------------------------------------
     */

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Move to application after successful verification.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  // ===========================================================================
  // RESEND OTP
  // ===========================================================================

  Future<void> _resendOtp() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    _showMessage(
      'OTP Resent',
      'A new verification code has been sent to your mobile number.',
    );
  }

  // ===========================================================================
  // CHANGE PHONE NUMBER
  // ===========================================================================

  void _changePhoneNumber() {
    setState(() {
      _isOtpSent = false;
      _otpController.clear();
    });
  }

  // ===========================================================================
  // ERROR MESSAGE
  // ===========================================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ===========================================================================
  // NORMAL MESSAGE
  // ===========================================================================

  void _showMessage(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
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

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 45),

              // =================================================================
              // ICON
              // =================================================================
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: _isOtpSent
                      ? const Color(0xFFEFF6FF)
                      : AppTheme.primarySoft,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  _isOtpSent ? Icons.sms_outlined : Icons.phone_android_rounded,
                  size: 48,
                  color: AppTheme.primaryBlue,
                ),
              ),

              const SizedBox(height: 30),

              // =================================================================
              // TITLE
              // =================================================================
              Text(
                _isOtpSent ? 'Enter Verification Code' : 'Continue with Phone',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // =================================================================
              // DESCRIPTION
              // =================================================================
              Text(
                _isOtpSent
                    ? 'Enter the 6-digit verification code sent to your mobile number.'
                    : 'Enter your details and we will send you a verification code.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 35),

              // =================================================================
              // PHONE NUMBER FORM
              // =================================================================
              if (!_isOtpSent) _buildPhoneForm(),

              // =================================================================
              // OTP FORM
              // =================================================================
              if (_isOtpSent) _buildOtpForm(),

              const SizedBox(height: 30),

              // =================================================================
              // BACK TO LOGIN
              // =================================================================
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text(
                  'Back to Login',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PHONE FORM
  // ===========================================================================

  Widget _buildPhoneForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // ---------------------------------------------------------------------
          // NAME
          // ---------------------------------------------------------------------

          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }

              if (value.trim().length < 2) {
                return 'Please enter a valid name';
              }

              return null;
            },
            decoration: _inputDecoration(
              hintText: 'Full Name',
              icon: Icons.person_outline_rounded,
            ),
          ),

          const SizedBox(height: 15),

          // ---------------------------------------------------------------------
          // PHONE
          // ---------------------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COUNTRY CODE
              Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    '+91',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // PHONE FIELD
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter mobile number';
                    }

                    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

                    if (digits.length != 10) {
                      return 'Enter a valid 10-digit number';
                    }

                    return null;
                  },
                  decoration: _inputDecoration(
                    hintText: 'Mobile Number',
                    icon: Icons.phone_outlined,
                  ).copyWith(counterText: ''),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ---------------------------------------------------------------------
          // SEND OTP BUTTON
          // ---------------------------------------------------------------------
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.primaryBlue.withValues(
                  alpha: 0.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sms_outlined, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Send OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'By continuing, you agree to receive an SMS verification code.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // OTP FORM
  // ===========================================================================

  Widget _buildOtpForm() {
    return Column(
      children: [
        // -----------------------------------------------------------------------
        // PHONE DISPLAY
        // -----------------------------------------------------------------------

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.phone_rounded,
                size: 20,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '+91 ${_phoneController.text.trim()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: _changePhoneNumber,
                child: const Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // -----------------------------------------------------------------------
        // OTP FIELD
        // -----------------------------------------------------------------------
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            letterSpacing: 10,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '••••••',
            hintStyle: TextStyle(color: Colors.grey.shade300, letterSpacing: 8),
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 1.8,
              ),
            ),
          ),
          onSubmitted: (_) {
            _verifyOtp();
          },
        ),

        const SizedBox(height: 22),

        // -----------------------------------------------------------------------
        // VERIFY BUTTON
        // -----------------------------------------------------------------------
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.primaryBlue.withValues(
                alpha: 0.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Verify & Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        // -----------------------------------------------------------------------
        // RESEND
        // -----------------------------------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Didn't receive the code?",
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            TextButton(
              onPressed: _isLoading ? null : _resendOtp,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(left: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Resend OTP',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // INPUT DECORATION
  // ===========================================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: AppTheme.textTertiary),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
      ),
    );
  }
}
