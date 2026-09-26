import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // SEND RESET EMAIL
  // ===========================================================================

  Future<void> _sendResetEmail() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    /*
     * ---------------------------------------------------------------
     * FIREBASE AUTHENTICATION
     * ---------------------------------------------------------------
     *
     * When you connect FirebaseAuth, use:
     *
     * await FirebaseAuth.instance.sendPasswordResetEmail(
     *   email: _emailController.text.trim(),
     * );
     *
     * For now the UI simulates the request.
     */

    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _emailSent = true;
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
                  color: _emailSent
                      ? const Color(0xFFDCFCE7)
                      : AppTheme.primarySoft,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  _emailSent
                      ? Icons.mark_email_read_outlined
                      : Icons.lock_reset_rounded,
                  size: 48,
                  color: _emailSent
                      ? const Color(0xFF16A34A)
                      : AppTheme.primaryBlue,
                ),
              ),

              const SizedBox(height: 30),

              // =================================================================
              // TITLE
              // =================================================================

              Text(
                _emailSent
                    ? 'Check Your Email'
                    : 'Forgot Password?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
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
                _emailSent
                    ? 'We have sent a password reset link to your email address.'
                    : 'Enter the email address associated with your account and we will send you a password reset link.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 35),

              // =================================================================
              // EMAIL FORM
              // =================================================================

              if (!_emailSent)
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ---------------------------------------------------------
                      // EMAIL FIELD
                      // ---------------------------------------------------------

                      TextFormField(
                        controller: _emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        textInputAction:
                            TextInputAction.done,
                        onFieldSubmitted: (_) {
                          _sendResetEmail();
                        },
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your email address';
                          }

                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );

                          if (!emailRegex.hasMatch(
                            value.trim(),
                          )) {
                            return 'Please enter a valid email address';
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Email Address',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppTheme.textTertiary,
                          ),
                          filled: true,
                          fillColor:
                              const Color(0xFFF8FAFC),
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 17,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide:
                                const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide:
                                const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide:
                                const BorderSide(
                              color:
                                  AppTheme.primaryBlue,
                              width: 1.8,
                            ),
                          ),
                          errorBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide:
                                const BorderSide(
                              color: Colors.redAccent,
                            ),
                          ),
                          focusedErrorBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide:
                                const BorderSide(
                              color: Colors.redAccent,
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ---------------------------------------------------------
                      // SEND EMAIL BUTTON
                      // ---------------------------------------------------------

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _sendResetEmail,
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.primaryBlue,
                            foregroundColor:
                                Colors.white,
                            disabledBackgroundColor:
                                AppTheme.primaryBlue
                                    .withValues(
                              alpha: 0.5,
                            ),
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 17,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                            ),
                            elevation: 3,
                            shadowColor:
                                AppTheme.primaryBlue
                                    .withValues(
                              alpha: 0.3,
                            ),
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
                              : const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Icon(
                                      Icons
                                          .send_rounded,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Send Reset Email',
                                      style:
                                          TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

              // =================================================================
              // EMAIL SENT STATE
              // =================================================================

              if (_emailSent) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration:
                            const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF16A34A),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reset email sent',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    Color(0xFF166534),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _emailController.text
                                  .trim(),
                              style: const TextStyle(
                                fontSize: 13,
                                color:
                                    Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ---------------------------------------------------------------
                // INSTRUCTIONS
                // ---------------------------------------------------------------

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What to do next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildStep(
                        number: '1',
                        text:
                            'Open the password reset email.',
                      ),
                      _buildStep(
                        number: '2',
                        text:
                            'Tap the reset password link.',
                      ),
                      _buildStep(
                        number: '3',
                        text:
                            'Create your new password.',
                      ),
                      _buildStep(
                        number: '4',
                        text:
                            'Return to the app and log in.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------------------------------------------------------
                // RESEND
                // ---------------------------------------------------------------

                TextButton(
                  onPressed: _isLoading
                      ? null
                      : _sendResetEmail,
                  child: const Text(
                    'Resend Email',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // =================================================================
              // BACK TO LOGIN
              // =================================================================

              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Back to Login',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor:
                      AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // STEP WIDGET
  // ===========================================================================

  Widget _buildStep({
    required String number,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color:
                      AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}