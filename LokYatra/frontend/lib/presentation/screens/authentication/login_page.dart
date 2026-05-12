import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/forgot_password.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/register.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_state.dart';
import '../../state_management/Bloc/auth/auth_event.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;

  static const ink     = Color(0xFF2D1B10);
  static const accent  = Color(0xFF4E4E4E);
  static const cream   = Color(0xFFFAF7F2);
  static const brown   = Color(0xFF22150A);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginButtonClicked(emailController.text.trim(), passwordController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb || width > 700;
    return Scaffold(
      backgroundColor: isWeb ? cream : Colors.white,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return isWeb ? _webLayout(context) : _mobileLayout(context);
        },
      ),
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(children: [
              Image.asset('assets/images/lokyatra_logo.png', height: 100,
                  errorBuilder: (_, _, _) =>
                  const Icon(Icons.temple_hindu_rounded, size: 80, color: accent)),
              const SizedBox(height: 16),
              const Text('Welcome Back',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ink)),
              const SizedBox(height: 6),
              Text('Login to continue exploring Nepal',
                  style: TextStyle(fontSize: 15, color: Colors.grey[500])),
              const SizedBox(height: 32),
              _formCard(context),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Don't have an account?",
                    style: TextStyle(color: Colors.grey[600])),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Register())),
                  child: const Text('Register',
                      style: TextStyle(
                          color: accent, fontWeight: FontWeight.bold)),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _formCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(children: [
        _emailField(),
        const SizedBox(height: 18),
        _passwordField(),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ForgotPassword())),
            child: const Text('Forgot password?',
                style: TextStyle(color: accent)),
          ),
        ),
        const SizedBox(height: 12),
        _loginButton(context),
      ]),
    );
  }

  Widget _webLayout(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final isWide = size.width > 1100;
    return isWide ? _webWide(context, size) : _webNarrow(context, size);
  }

  Widget _webWide(BuildContext context, Size size) {
    return Row(children: [
      Expanded(
        flex: 50,
        child: Stack(children: [
          Positioned.fill(
            child: Image.asset('assets/images/onboarding1.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox()),
          ),
          Positioned.fill(
              child: Container(color: ink.withValues(alpha: 0.78))),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 56, vertical: 48),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Image.asset('assets/images/lokyatra_logo.png',
                          color: brown),
                    ),
                    const SizedBox(width: 12),
                    const Text('LokYatra',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                  ]),
                  const Spacer(),
                  const Text('Welcome\nBack',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 54,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          letterSpacing: -1)),
                  const SizedBox(height: 20),
                  Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  const Text(
                      'Continue your journey through Nepal\'s\nancient heritage and culture.',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 17, height: 1.65)),
                  const SizedBox(height: 40),
                  Row(children: [
                    _statChip('700+', 'Heritage Sites'),
                    const SizedBox(width: 20),
                    _statChip('2K+', 'Travellers'),
                    const SizedBox(width: 20),
                    _statChip('4.8', 'Rating'),
                  ]),
                  const Spacer(),
                  Text('New to LokYatra?',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.35))),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const Register())),
                    icon: const Icon(Icons.person_add_outlined, size: 18),
                    label: const Text('Create an Account',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 48),
                ]),
          ),
        ]),
      ),
      Expanded(
        flex: 50,
        child: Container(
          color: Colors.white,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 48),
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sign in',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: ink)),
                        const SizedBox(height: 6),
                        Text('Enter your credentials to continue',
                            style:
                            TextStyle(fontSize: 15, color: Colors.grey[500])),
                        const SizedBox(height: 36),
                        _label('Email address'),
                        _emailField(),
                        const SizedBox(height: 20),
                        _label('Password'),
                        _passwordField(),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ForgotPassword())),
                            style: TextButton.styleFrom(
                                foregroundColor: accent),
                            child: const Text('Forgot password?',
                                style:
                                TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _loginButton(context),
                        const SizedBox(height: 32),
                        Row(children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            child: Text('or',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 13)),
                          ),
                          const Expanded(child: Divider()),
                        ]),
                        const SizedBox(height: 24),
                        Center(
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text("Don't have an account? ",
                                style:
                                TextStyle(color: Colors.grey[500])),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const Register())),
                              child: const Text('Register',
                                  style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                          ]),
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _webNarrow(BuildContext context, Size size) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(children: [
              const Icon(Icons.temple_hindu_rounded,
                  size: 56, color: accent),
              const SizedBox(height: 8),
              const Text('LokYatra',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ink)),
              const SizedBox(height: 32),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Sign in',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ink))),
              const SizedBox(height: 4),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Welcome back!',
                      style: TextStyle(color: Colors.grey[500]))),
              const SizedBox(height: 28),
              _label('Email address'),
              _emailField(),
              const SizedBox(height: 16),
              _label('Password'),
              _passwordField(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPassword())),
                  child: const Text('Forgot password?',
                      style: TextStyle(color: accent)),
                ),
              ),
              const SizedBox(height: 16),
              _loginButton(context),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Don't have an account? ",
                    style: TextStyle(color: Colors.grey[500])),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Register())),
                  child: const Text('Register',
                      style: TextStyle(
                          color: accent, fontWeight: FontWeight.bold)),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _emailField() => TextFormField(
    controller: emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: _inputDeco('youremail@gmail.com', Icons.email_outlined),
    validator: (v) {
      if (v == null || v.isEmpty) return 'Please enter your email';
      if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
      return null;
    },
  );

  Widget _passwordField() => TextFormField(
    controller: passwordController,
    obscureText: !_showPassword,
    decoration: _inputDeco('Password', Icons.lock_outline).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
            _showPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey),
        onPressed: () => setState(() => _showPassword = !_showPassword),
      ),
    ),
    validator: (v) {
      if (v == null || v.isEmpty) return 'Please enter your password';
      if (v.length < 8) return 'Password must be at least 8 characters';
      return null;
    },
  );

  Widget _loginButton(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        elevation: 0,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => _submit(context),
      child: const Text('LOGIN',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1)),
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: ink)),
  );

  Widget _statChip(String value, String label) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      ]);

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
    prefixIcon: Icon(icon, size: 20, color: Colors.grey[400]),
    filled: true,
    fillColor: const Color(0xFFF9F9F9),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 1.5)),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}