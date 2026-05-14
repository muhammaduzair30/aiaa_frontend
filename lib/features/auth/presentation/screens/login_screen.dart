import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _emailFocused = false;
  bool _passwordFocused = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final email = _emailController.text;
    final password = _passwordController.text;
    if (email.isNotEmpty && password.isNotEmpty) {
      context.read<AuthBloc>().add(AuthLoginRequested(email, password));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 768;

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
                  emailController: _emailController,
                  passwordController: _passwordController,
                  emailFocused: _emailFocused,
                  passwordFocused: _passwordFocused,
                  onEmailFocus: (v) => setState(() => _emailFocused = v),
                  onPasswordFocus: (v) => setState(() => _passwordFocused = v),
                  onLogin: _onLoginPressed,
                  isLoading: state is AuthLoading,
                  context: context,
                )
              : _MobileLayout(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  emailFocused: _emailFocused,
                  passwordFocused: _passwordFocused,
                  onEmailFocus: (v) => setState(() => _emailFocused = v),
                  onPasswordFocus: (v) => setState(() => _passwordFocused = v),
                  onLogin: _onLoginPressed,
                  isLoading: state is AuthLoading,
                  context: context,
                );
        },
      ),
    );
  }
}

// ─── Web Layout: Two-panel split ─────────────────────────────────────────────

class _WebLayout extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool emailFocused;
  final bool passwordFocused;
  final ValueChanged<bool> onEmailFocus;
  final ValueChanged<bool> onPasswordFocus;
  final VoidCallback onLogin;
  final bool isLoading;
  final BuildContext context;

  const _WebLayout({
    required this.emailController,
    required this.passwordController,
    required this.emailFocused,
    required this.passwordFocused,
    required this.onEmailFocus,
    required this.onPasswordFocus,
    required this.onLogin,
    required this.isLoading,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return Stack(
      children: [
        // Background glows
        Positioned(
          top: -150,
          left: -100,
          child: _GlowCircle(
              size: 500, color: const Color(0xFF534AB7), opacity: 0.18),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _GlowCircle(
              size: 400, color: const Color(0xFF1D9E75), opacity: 0.12),
        ),
        Row(
          children: [
            // LEFT PANEL — branding
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withOpacity(0.06),
                      width: 1,
                    ),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                        child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
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
                              'Your AI-powered\njob application\nassistant.',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEEEDFE),
                                height: 1.2,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Track applications, get AI resume feedback,\nand land your dream job faster.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B7089),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 48),
                            // Feature pills
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _FeaturePill(
                                    icon: Icons.track_changes_rounded,
                                    label: 'Job Tracker'),
                                _FeaturePill(
                                    icon: Icons.smart_toy_outlined,
                                    label: 'AI Resume'),
                                _FeaturePill(
                                    icon: Icons.insights_rounded,
                                    label: 'Analytics'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ));
                  },
                ),
              ),
            ),

            // RIGHT PANEL — form
            Expanded(
              flex: 4,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: _FormContent(
                      emailController: emailController,
                      passwordController: passwordController,
                      emailFocused: emailFocused,
                      passwordFocused: passwordFocused,
                      onEmailFocus: onEmailFocus,
                      onPasswordFocus: onPasswordFocus,
                      onLogin: onLogin,
                      isLoading: isLoading,
                      isWeb: true,
                    ),
                  ),
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
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool emailFocused;
  final bool passwordFocused;
  final ValueChanged<bool> onEmailFocus;
  final ValueChanged<bool> onPasswordFocus;
  final VoidCallback onLogin;
  final bool isLoading;
  final BuildContext context;

  const _MobileLayout({
    required this.emailController,
    required this.passwordController,
    required this.emailFocused,
    required this.passwordFocused,
    required this.onEmailFocus,
    required this.onPasswordFocus,
    required this.onLogin,
    required this.isLoading,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: 0,
          right: 0,
          child: Center(
            child: _GlowCircle(
                size: 350, color: const Color(0xFF534AB7), opacity: 0.28),
          ),
        ),
        Positioned(
          bottom: 80,
          right: -80,
          child: _GlowCircle(
              size: 250, color: const Color(0xFF1D9E75), opacity: 0.15),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  // Logo + heading
                  Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF6C63E0), Color(0xFF534AB7)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF534AB7).withOpacity(0.45),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 30),
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
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D9E75).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF1D9E75).withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.smart_toy_outlined,
                                size: 13, color: Color(0xFF1D9E75)),
                            SizedBox(width: 5),
                            Text(
                              'AI-powered job assistant',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1D9E75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Welcome back 👋',
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
                        'Sign in to continue your AI job hunt',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF6B7089)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _FormContent(
                    emailController: emailController,
                    passwordController: passwordController,
                    emailFocused: emailFocused,
                    passwordFocused: passwordFocused,
                    onEmailFocus: onEmailFocus,
                    onPasswordFocus: onPasswordFocus,
                    onLogin: onLogin,
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
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool emailFocused;
  final bool passwordFocused;
  final ValueChanged<bool> onEmailFocus;
  final ValueChanged<bool> onPasswordFocus;
  final VoidCallback onLogin;
  final bool isLoading;
  final bool isWeb;

  const _FormContent({
    required this.emailController,
    required this.passwordController,
    required this.emailFocused,
    required this.passwordFocused,
    required this.onEmailFocus,
    required this.onPasswordFocus,
    required this.onLogin,
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
            'Sign in',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEEEDFE),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Welcome back — good to see you again.',
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
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
                isFocused: passwordFocused,
                onFocusChange: onPasswordFocus,
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(
                  child: SizedBox(
                    height: 52,
                    child: CircularProgressIndicator(color: Color(0xFF534AB7)),
                  ),
                )
              else
                _GradientButton(onPressed: onLogin, label: 'Sign in'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                        color: Colors.white.withOpacity(0.08), thickness: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('New here? ',
                style: TextStyle(fontSize: 13, color: Color(0xFF4A4E6A))),
            TextButton(
              onPressed: () => context.push('/register'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Create an account →',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7C74E0),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

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

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF8B82D4)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8B82D4),
                fontWeight: FontWeight.w500),
          ),
        ],
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
            const Icon(Icons.arrow_forward_rounded,
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
