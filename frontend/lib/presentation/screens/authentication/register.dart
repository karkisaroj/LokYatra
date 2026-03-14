import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/data/models/register.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/loginPage.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_state.dart';
import '../../state_management/Bloc/auth/auth_event.dart';
import '../shared/TermsAndConditionsPage.dart';

enum UserRole { tourist, owner }

class Register extends StatefulWidget {
  const Register({super.key});
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  UserRole _selectedRole = UserRole.tourist;
  bool _agreeToTerms        = false;
  bool _showPassword        = false;
  bool _showConfirmPassword = false;

  static const ink    = Color(0xFF2D1B10);
  static const brown  = Color(0xFF22150A);
  static const accent = Color(0xFF595858);
  static const cream  = Color(0xFFFAF7F2);

  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _phoneController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please agree to Terms & Conditions')),
      );
      return;
    }
    context.read<AuthBloc>().add(RegisterButtonClicked(RegisterUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole == UserRole.tourist ? 'tourist' : 'owner',
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      profileImage: '',
    )));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb || width > 700;
    return Scaffold(
      backgroundColor: isWeb ? cream : Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is RegisterSuccess) {
            _nameController.clear();
            _emailController.clear();
            _phoneController.clear();
            _passwordController.clear();
            _confirmController.clear();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                duration: Duration(seconds: 2),
                content:
                Text('Registration Successful! Please login.')));
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const LoginPage()));
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return isWeb
              ? _webLayout(context, loading)
              : _mobileLayout(context, loading);
        },
      ),
    );
  }

  Widget _mobileLayout(BuildContext context, bool loading) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back)),
          const CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage:
              AssetImage('assets/images/lokyatra_logo.png'),
              radius: 20),
        ]),
        leadingWidth: 100,
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Join LokYatra Community',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: ink)),
                const SizedBox(height: 20),
                const Text('I want to:',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                _roleSelector(),
                const SizedBox(height: 20),
                ..._formFields(),
                _termsCheckbox(),
                const SizedBox(height: 16),
                _submitButton(loading),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const LoginPage())),
                    child: Text('Already have an account? Login',
                        style: TextStyle(color: Colors.grey[500])),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
        ),
      ),
    );
  }

  Widget _webLayout(BuildContext context, bool loading) {
    final size   = MediaQuery.of(context).size;
    final isWide = size.width > 1100;
    return isWide
        ? _webWide(context, loading)
        : _webNarrow(context, loading);
  }

  Widget _webWide(BuildContext context, bool loading) {
    return Row(children: [
      Expanded(
        flex: 50,
        child: Container(
          color: ink,
          child: Stack(children: [
            Positioned.fill(
                child: Image.asset('assets/images/Homestay.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox())),
            Positioned.fill(
                child: Container(
                    color: ink.withValues(alpha: 0.80))),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 48, vertical: 48),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Image.asset(
                            'assets/images/lokyatra_logo.png',
                            color: brown),
                      ),
                      const SizedBox(width: 12),
                      const Text('LokYatra',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ]),
                    const Spacer(),
                    const Text('Join the\nCommunity',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                            letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 20),
                    const Text(
                        'Explore Nepal\'s heritage, stay with\nlocal families, and earn rewards.',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.6)),
                    const Spacer(),
                    Text('Already have an account?',
                        style: TextStyle(
                            color:
                            Colors.white.withValues(alpha: 0.5),
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
                              color:
                              Colors.white.withValues(alpha: 0.35))),
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const LoginPage())),
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text('Sign In',
                          style:
                          TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 48),
                  ]),
            ),
          ]),
        ),
      ),
      Expanded(
        flex: 50,
        child: Container(
          color: Colors.white,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 48, vertical: 48),
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Create Account',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: ink)),
                        const SizedBox(height: 4),
                        Text('Fill in your details to get started',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 14)),
                        const SizedBox(height: 28),
                        _label('I want to'),
                        const SizedBox(height: 8),
                        _roleSelector(),
                        const SizedBox(height: 24),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _label('Username *'),
                                        _nameField(),
                                      ])),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _label('Phone (Optional)'),
                                        _phoneField(),
                                      ])),
                            ]),
                        const SizedBox(height: 20),
                        _label('Email Address *'),
                        _emailField(),
                        const SizedBox(height: 20),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _label('Password *'),
                                        _passwordField(),
                                      ])),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _label('Confirm Password *'),
                                        _confirmField(),
                                      ])),
                            ]),
                        const SizedBox(height: 20),
                        _termsCheckbox(),
                        const SizedBox(height: 24),
                        _submitButton(loading),
                        const SizedBox(height: 20),
                        Center(
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Already have an account? ',
                                    style:
                                    TextStyle(color: Colors.grey[500])),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const LoginPage())),
                                  child: const Text('Sign In',
                                      style: TextStyle(
                                          color: accent,
                                          fontWeight: FontWeight.bold)),
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

  Widget _webNarrow(BuildContext context, bool loading) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Center(
                      child: Icon(Icons.temple_hindu_rounded,
                          size: 48, color: accent)),
                  const SizedBox(height: 8),
                  const Center(
                      child: Text('LokYatra',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ink))),
                  const SizedBox(height: 28),
                  const Text('Create Account',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: ink)),
                  const SizedBox(height: 4),
                  Text('Fill in your details to get started',
                      style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 24),
                  _label('I want to'),
                  _roleSelector(),
                  const SizedBox(height: 16),
                  _label('Username *'),
                  _nameField(),
                  const SizedBox(height: 16),
                  _label('Email Address *'),
                  _emailField(),
                  const SizedBox(height: 16),
                  _label('Phone (Optional)'),
                  _phoneField(),
                  const SizedBox(height: 16),
                  _label('Password *'),
                  _passwordField(),
                  const SizedBox(height: 16),
                  _label('Confirm Password *'),
                  _confirmField(),
                  const SizedBox(height: 12),
                  _termsCheckbox(),
                  const SizedBox(height: 20),
                  _submitButton(loading),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const LoginPage())),
                      child: const Text('Already have an account? Sign In',
                          style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ]),
          ),
        ),
      ),
    );
  }

  List<Widget> _formFields() => [
    _label('Username *'), _nameField(), const SizedBox(height: 16),
    _label('Email *'), _emailField(), const SizedBox(height: 16),
    _label('Phone (Optional)'), _phoneField(),
    Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      child: Text(
          'You can add your phone number later from your profile',
          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
    ),
    _label('Password *'), _passwordField(), const SizedBox(height: 16),
    _label('Confirm Password *'), _confirmField(), const SizedBox(height: 4),
  ];

  Widget _nameField() => TextFormField(
    controller: _nameController,
    decoration: _inputDeco('Enter your name', Icons.person_outline),
    validator: (v) {
      if (v == null || v.trim().isEmpty) return 'Name is required';
      if (v.trim().length < 3) return 'At least 3 characters';
      return null;
    },
  );

  Widget _emailField() => TextFormField(
    controller: _emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: _inputDeco('you@example.com', Icons.email_outlined),
    validator: (v) {
      if (v == null || v.trim().isEmpty) return 'Email is required';
      if (!v.contains('@') || !v.contains('.')) {
        return 'Enter a valid email';
      }
      return null;
    },
  );

  Widget _phoneField() => TextFormField(
    controller: _phoneController,
    keyboardType: TextInputType.phone,
    decoration: _inputDeco('+977- 97XXXXXXXX', Icons.phone_outlined),
    validator: (v) {
      if (v != null && v.isNotEmpty && v.length != 10) {
        return 'Enter a valid 10-digit number';
      }
      return null;
    },
  );

  Widget _passwordField() => TextFormField(
    controller: _passwordController,
    obscureText: !_showPassword,
    decoration: _inputDeco('Create password', Icons.lock_outline).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
            _showPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey),
        onPressed: () =>
            setState(() => _showPassword = !_showPassword),
      ),
    ),
    validator: (v) {
      if (v == null || v.isEmpty) return 'Password is required';
      if (v.length < 8) return 'At least 8 characters';
      return null;
    },
  );

  Widget _confirmField() => TextFormField(
    controller: _confirmController,
    obscureText: !_showConfirmPassword,
    decoration:
    _inputDeco('Confirm password', Icons.lock_outline).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
            _showConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey),
        onPressed: () => setState(
                () => _showConfirmPassword = !_showConfirmPassword),
      ),
    ),
    validator: (v) {
      if (v == null || v.isEmpty) return 'Please confirm your password';
      if (v != _passwordController.text) return 'Passwords do not match';
      return null;
    },
  );

  Widget _roleSelector() => Row(children: [
    Expanded(
        child: _roleCard(
            'Explore as Tourist', Icons.backpack_outlined, UserRole.tourist)),
    const SizedBox(width: 12),
    Expanded(
        child: _roleCard(
            'List as Owner', Icons.home_outlined, UserRole.owner)),
  ]);

  Widget _roleCard(String label, IconData icon, UserRole role) {
    final sel = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: sel ? accent.withValues(alpha: 0.08) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: sel ? accent : Colors.grey.shade300,
              width: sel ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(icon, color: sel ? accent : Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: sel
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: sel ? accent : Colors.grey[700])),
          ),
          if (sel)
            const Icon(Icons.check_circle_rounded,
                color: accent, size: 16),
        ]),
      ),
    );
  }

  Widget _termsCheckbox() =>
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          width: 24, height: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (v) => setState(() => _agreeToTerms = v!),
            activeColor: accent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              children: [
                const TextSpan(text: 'I agree to the '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: InkWell(
                    onTap: () async {
                      final accepted = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsAndConditionsPage(
                              isRegistration: true),
                        ),
                      );
                      if (accepted == true && mounted) {
                        setState(() => _agreeToTerms = true);
                      }
                    },
                    child: const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 13,
                        color: accent,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]);

  Widget _submitButton(bool loading) => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton(
      onPressed: loading ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      child: loading
          ? const SizedBox(
          width: 22, height: 22,
          child: CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2))
          : const Text('CREATE ACCOUNT',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 0.5)),
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ink)),
  );

  InputDecoration _inputDeco(String hint, IconData icon) =>
      InputDecoration(
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