import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _nameFocused = false;
  bool _emailFocused = false;
  bool _passwordFocused = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    final fullName = _fullNameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    if (fullName.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(email, fullName, password),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1E),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF1A1730),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else if (state is AuthAuthenticated) {
            context.go('/home');
          }
        },
        builder: (context, state) {
          return isWeb
              ? _WebLayout(
                  fullNameController: _fullNameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  nameFocused: _nameFocused,
                  emailFocused: _emailFocused,
                  passwordFocused: _passwordFocused,
                  onNameFocus: (v) => setState(() => _nameFocused = v),
                  onEmailFocus: (v) => setState(() => _emailFocused = v),
                  onPasswordFocus: (v) => setState(() => _passwordFocused = v),
                  onRegister: _onRegisterPressed,
                  isLoading: state is AuthLoading,
                )
              : _MobileLayout(
                  fullNameController: _fullNameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  nameFocused: _nameFocused,
                  emailFocused: _emailFocused,
                  passwordFocused: _passwordFocused,
                  onNameFocus: (v) => setState(() => _nameFocused = v),
                  onEmailFocus: (v) => setState(() => _emailFocused = v),
                  onPasswordFocus: (v) => setState(() => _passwordFocused = v),
                  onRegister: _onRegisterPressed,
                  isLoading: state is AuthLoading,
                );
        },
      ),
    );
  }
}

// ─── Web Layout ───────────────────────────────────────────────────────────────

class _WebLayout extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool nameFocused, emailFocused, passwordFocused;
  final ValueChanged<bool> onNameFocus, onEmailFocus, onPasswordFocus;
  final VoidCallback onRegister;
  final bool isLoading;

  const _WebLayout({
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.nameFocused,
    required this.emailFocused,
    required this.passwordFocused,
    required this.onNameFocus,
    required this.onEmailFocus,
    required this.onPasswordFocus,
    required this.onRegister,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background glows
        Positioned(
          top: -150,
          right: -100,
          child: _GlowCircle(
              size: 500, color: const Color(0xFF534AB7), opacity: 0.16),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: _GlowCircle(
              size: 380, color: const Color(0xFF1D9E75), opacity: 0.12),
        ),
        Row(
          children: [
            // LEFT — form panel
            Expanded(
              flex: 4,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: _FormContent(
                      fullNameController: fullNameController,
                      emailController: emailController,
                      passwordController: passwordController,
                      nameFocused: nameFocused,
                      emailFocused: emailFocused,
                      passwordFocused: passwordFocused,
                      onNameFocus: onNameFocus,
                      onEmailFocus: onEmailFocus,
                      onPasswordFocus: onPasswordFocus,
                      onRegister: onRegister,
                      isLoading: isLoading,
                      isWeb: true,
                    ),
                  ),
                ),
              ),
            ),
            // RIGHT — branding panel
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.white.withOpacity(0.06),
                      width: 1,
                    ),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(60),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF6C63E0),
                                      Color(0xFF534AB7)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF534AB7)
                                          .withOpacity(0.5),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.auto_awesome,
                                    color: Colors.white, size: 30),
                              ),
                              const SizedBox(height: 40),
                              const Text(
                                'Start your journey\ntoward your\ndream job.',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEEEDFE),
                                  height: 1.2,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Join thousands of job seekers using AI\nto accelerate their careers.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF6B7089),
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 48),
                              // Steps
                              _OnboardingStep(
                                number: '01',
                                title: 'Create your account',
                                subtitle:
                                    'Quick setup, no credit card required.',
                              ),
                              const SizedBox(height: 20),
                              _OnboardingStep(
                                number: '02',
                                title: 'Upload your resume',
                                subtitle:
                                    'AI scans and optimizes it instantly.',
                              ),
                              const SizedBox(height: 20),
                              _OnboardingStep(
                                number: '03',
                                title: 'Start applying smarter',
                                subtitle:
                                    'Track, analyze, and land interviews.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Mobile Layout ────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool nameFocused, emailFocused, passwordFocused;
  final ValueChanged<bool> onNameFocus, onEmailFocus, onPasswordFocus;
  final VoidCallback onRegister;
  final bool isLoading;

  const _MobileLayout({
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.nameFocused,
    required this.emailFocused,
    required this.passwordFocused,
    required this.onNameFocus,
    required this.onEmailFocus,
    required this.onPasswordFocus,
    required this.onRegister,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: 0,
          right: 0,
          child: Center(
            child: _GlowCircle(
                size: 350, color: const Color(0xFF534AB7), opacity: 0.26),
          ),
        ),
        Positioned(
          bottom: 60,
          left: -80,
          child: _GlowCircle(
              size: 260, color: const Color(0xFF1D9E75), opacity: 0.14),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  // Logo + heading
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6C63E0), Color(0xFF534AB7)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF534AB7).withOpacity(0.45),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AIAA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                      color: Color(0xFF8B82D4),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Create your account',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEEEDFE),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Start your AI-powered job hunt today',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7089)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _FormContent(
                    fullNameController: fullNameController,
                    emailController: emailController,
                    passwordController: passwordController,
                    nameFocused: nameFocused,
                    emailFocused: emailFocused,
                    passwordFocused: passwordFocused,
                    onNameFocus: onNameFocus,
                    onEmailFocus: onEmailFocus,
                    onPasswordFocus: onPasswordFocus,
                    onRegister: onRegister,
                    isLoading: isLoading,
                    isWeb: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared form content ──────────────────────────────────────────────────────

class _FormContent extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool nameFocused, emailFocused, passwordFocused;
  final ValueChanged<bool> onNameFocus, onEmailFocus, onPasswordFocus;
  final VoidCallback onRegister;
  final bool isLoading;
  final bool isWeb;

  const _FormContent({
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.nameFocused,
    required this.emailFocused,
    required this.passwordFocused,
    required this.onNameFocus,
    required this.onEmailFocus,
    required this.onPasswordFocus,
    required this.onRegister,
    required this.isLoading,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isWeb) ...[
          const Text(
            'Get started',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEEEDFE),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create your free account in seconds.',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7089)),
          ),
          const SizedBox(height: 28),
        ],
        // Form card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PremiumField(
                controller: fullNameController,
                label: 'Full name',
                hint: 'John Doe',
                icon: Icons.person_outline_rounded,
                isFocused: nameFocused,
                onFocusChange: onNameFocus,
              ),
              const SizedBox(height: 16),
              _PremiumField(
                controller: emailController,
                label: 'Email address',
                hint: 'you@example.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                isFocused: emailFocused,
                onFocusChange: onEmailFocus,
              ),
              const SizedBox(height: 16),
              _PremiumField(
                controller: passwordController,
                label: 'Password',
                hint: 'Min. 8 characters',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
                isFocused: passwordFocused,
                onFocusChange: onPasswordFocus,
              ),
              const SizedBox(height: 8),
              // Password strength hint
              const Text(
                'Use 8+ characters with a mix of letters & numbers.',
                style: TextStyle(fontSize: 11, color: Color(0xFF4A4E6A)),
              ),
              const SizedBox(height: 24),
              if (isLoading)
                const Center(
                  child: SizedBox(
                    height: 52,
                    child: CircularProgressIndicator(color: Color(0xFF534AB7)),
                  ),
                )
              else
                _GradientButton(onPressed: onRegister, label: 'Create account'),
              const SizedBox(height: 16),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account? ',
              style: TextStyle(fontSize: 13, color: Color(0xFF4A4E6A)),
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Sign in →',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7C74E0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Onboarding step (web only) ───────────────────────────────────────────────

class _OnboardingStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _OnboardingStep({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF534AB7).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF534AB7).withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8B82D4),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEEEDFE),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7089), height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared reusable widgets ──────────────────────────────────────────────────

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowCircle(
      {required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }
}

class _PremiumField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool isFocused;
  final ValueChanged<bool> onFocusChange;

  const _PremiumField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    required this.isFocused,
    required this.onFocusChange,
  });

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Color(0xFF6B7089),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: widget.isFocused
                ? const Color(0xFF534AB7).withOpacity(0.08)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isFocused
                  ? const Color(0xFF534AB7).withOpacity(0.7)
                  : Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Focus(
            onFocusChange: widget.onFocusChange,
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText && _obscure,
              keyboardType: widget.keyboardType,
              style: const TextStyle(color: Color(0xFFEEEDFE), fontSize: 15),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle:
                    const TextStyle(color: Color(0xFF4A4E6A), fontSize: 15),
                prefixIcon:
                    Icon(widget.icon, size: 18, color: const Color(0xFF534AB7)),
                suffixIcon: widget.obscureText
                    ? IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                          color: const Color(0xFF6B7089),
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )
                    : null,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const _GradientButton({required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63E0), Color(0xFF534AB7)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF534AB7).withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add_outlined,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
