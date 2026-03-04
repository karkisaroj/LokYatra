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
  bool _agreeToTerms = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  static const _brown      = Color(0xFF22150A);
  static const _dark       = Color(0xFF2D1B10);
  static const _cream      = Color(0xFFFAF7F2);
  static const grey = Color(0xFF6C6969);

  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _phoneController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
        const SnackBar(content: Text('Please agree to Terms & Conditions')),
      );
      return;
    }
    final register = RegisterUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole == UserRole.tourist ? 'tourist' : 'owner',
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      profileImage: '',
    );
    context.read<AuthBloc>().add(RegisterButtonClicked(register));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb || width > 700;

    return Scaffold(
      backgroundColor: isWeb ? _cream : Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is RegisterSuccess) {
            _nameController.clear(); _emailController.clear();
            _phoneController.clear(); _passwordController.clear(); _confirmController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(duration: Duration(seconds: 2),
                  content: Text('Registration Successful! Please login.')),
            );
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return isWeb ? _webLayout(context, isLoading) : _mobileLayout(context, isLoading);
        },
      ),
    );
  }
//mobile layout below one
  Widget _mobileLayout(BuildContext context, bool isLoading) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
          const CircleAvatar(backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/lokyatra_logo.png'), radius: 20),
        ]),
        leadingWidth: 100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Join LokYatra Community',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _dark)),
          const SizedBox(height: 20),
          const Text('I want to:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          _roleSelector(),
          const SizedBox(height: 20),
          ..._formFields(),
          _termsCheckbox(),
          const SizedBox(height: 16),
          _submitButton(isLoading),
          const SizedBox(height: 12),
          Center(child: TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
            child: const Text('Already have an account? Login', style: TextStyle(color: Colors.grey)),
          )),
          const SizedBox(height: 24),
        ])),
      ),
    );
  }

  // web layout is below one
  Widget _webLayout(BuildContext context, bool isLoading) {
    final size   = MediaQuery.of(context).size;
    final isWide = size.width > 1100;

    return isWide ? _webWide(context, isLoading) : _webNarrow(context, isLoading);
  }

  Widget _webWide(BuildContext context, bool isLoading) {
    return Row(children: [
      Expanded(
        flex: 60,
        child: Container(
          color: _dark,
          child: Stack(children: [
            Positioned.fill(child: Image.asset('assets/images/Homestay.png', fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox())),
            Positioned.fill(child: Container(color: _dark.withValues(alpha: 0.80))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 38, height: 38,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child:Image.asset("assets/images/lokyatra_logo.png", color: _brown)),
                  const SizedBox(width: 12),
                  const Text('LokYatra', style: TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold)),
                ]),
                const Spacer(),
                const Text('Join the\nCommunity', style: TextStyle(color: Colors.white,
                    fontSize: 44, fontWeight: FontWeight.w800, height: 1.05, letterSpacing: -0.5)),
                const SizedBox(height: 16),
                Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: grey, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                const Text('Explore Nepal\'s heritage, stay with\nlocal families, and earn rewards.',
                    style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.6)),
                const SizedBox(height: 32),
                ...[
                  ( 'Access 700+ heritage sites'),
                  ( 'Book authentic homestays'),
                  ( 'Earn rewards & discounts'),
                ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),

                )),
                const Spacer(),
                const Text('Already have an account?', style: TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: Colors.white38)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 48),
              ]),
            ),
          ]),
        ),
      ),

      Expanded(
        flex: 60,
        child: Container(
          color: Colors.white,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
                child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Create Account', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: _dark)),
                  const SizedBox(height: 4),
                  const Text('Fill in your details to get started', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 28),

                  _webLabel('I want to'),
                  const SizedBox(height: 8),
                  _roleSelector(),
                  const SizedBox(height: 24),

                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _webLabel('Username *'),
                      _nameField(),
                    ])),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _webLabel('Phone (Optional)'),
                      _phoneField(),
                    ])),
                  ]),
                  const SizedBox(height: 20),

                  _webLabel('Email Address *'),
                  _emailField(),
                  const SizedBox(height: 20),

                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _webLabel('Password *'),
                      _passwordField(),
                    ])),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _webLabel('Confirm Password *'),
                      _confirmField(),
                    ])),
                  ]),
                  const SizedBox(height: 20),

                  _termsCheckbox(),
                  const SizedBox(height: 24),
                  _submitButton(isLoading),
                  const SizedBox(height: 20),
                  Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Already have an account? ', style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                      child: const Text('Sign In', style: TextStyle(color: grey, fontWeight: FontWeight.bold)),
                    ),
                  ])),
                ])),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _webNarrow(BuildContext context, bool isLoading) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16),
            const Center(child: Icon(Icons.temple_hindu_rounded, size: 48, color: _brown)),
            const SizedBox(height: 8),
            const Center(child: Text('LokYatra', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _dark))),
            const SizedBox(height: 28),
            const Text('Create Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _dark)),
            const SizedBox(height: 4),
            const Text('Fill in your details to get started', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            _webLabel('I want to'),
            _roleSelector(),
            const SizedBox(height: 16),
            _webLabel('Username *'),
            _nameField(),
            const SizedBox(height: 16),
            _webLabel('Email Address *'),
            _emailField(),
            const SizedBox(height: 16),
            _webLabel('Phone (Optional)'),
            _phoneField(),
            const SizedBox(height: 16),
            _webLabel('Password *'),
            _passwordField(),
            const SizedBox(height: 16),
            _webLabel('Confirm Password *'),
            _confirmField(),
            const SizedBox(height: 12),
            _termsCheckbox(),
            const SizedBox(height: 20),
            _submitButton(isLoading),
            const SizedBox(height: 16),
            Center(child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
              child: const Text('Already have an account? Sign In',
                  style: TextStyle(color: grey, fontWeight: FontWeight.w600)),
            )),
            const SizedBox(height: 32),
          ])),
        ),
      ),
    );
  }


  List<Widget> _formFields() => [
    _webLabel('Username *'), _nameField(), const SizedBox(height: 16),
    _webLabel('Email *'), _emailField(), const SizedBox(height: 16),
    _webLabel('Phone (Optional)'), _phoneField(),
    const Padding(padding: EdgeInsets.only(top: 4, bottom: 16),
        child: Text('You can add your phone number later from your profile',
            style: TextStyle(fontSize: 12, color: Colors.grey))),
    _webLabel('Password *'), _passwordField(), const SizedBox(height: 16),
    _webLabel('Confirm Password *'), _confirmField(), const SizedBox(height: 4),
  ];

  Widget _nameField() => TextFormField(
    controller: _nameController,
    decoration: _inputDecoration('Enter your name', Icons.person_outline),
    validator: (v) {
      if (v == null || v.trim().isEmpty) return 'Name is required';
      if (v.trim().length < 3) return 'At least 3 characters';
      return null;
    },
  );

  Widget _emailField() => TextFormField(
    controller: _emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: _inputDecoration('you@example.com', Icons.email_outlined),
    validator: (v) {
      if (v == null || v.trim().isEmpty) return 'Email is required';
      if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
      return null;
    },
  );

  Widget _phoneField() => TextFormField(
    controller: _phoneController,
    keyboardType: TextInputType.phone,
    decoration: _inputDecoration('+977 XXXXXXXXXX', Icons.phone_outlined),
    validator: (v) {
      if (v != null && v.isNotEmpty && v.length != 10) return 'Enter a valid 10-digit number';
      return null;
    },
  );

  Widget _passwordField() => TextFormField(
    controller: _passwordController,
    obscureText: !_showPassword,
    decoration: _inputDecoration('Create password', Icons.lock_outline).copyWith(
      suffixIcon: IconButton(
        icon: Icon(_showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
        onPressed: () => setState(() => _showPassword = !_showPassword),
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
    decoration: _inputDecoration('Confirm password', Icons.lock_outline).copyWith(
      suffixIcon: IconButton(
        icon: Icon(_showConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
        onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
      ),
    ),
    validator: (v) {
      if (v == null || v.isEmpty) return 'Please confirm your password';
      if (v != _passwordController.text) return 'Passwords do not match';
      return null;
    },
  );

  Widget _roleSelector() => Row(children: [
    Expanded(child: _roleCard('Explore as Tourist', Icons.backpack_outlined, UserRole.tourist)),
    const SizedBox(width: 12),
    Expanded(child: _roleCard('List as Owner', Icons.home_outlined, UserRole.owner)),
  ]);

  Widget _roleCard(String label, IconData icon, UserRole role) {
    final selected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? grey.withValues(alpha: 0.08) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? grey : Colors.grey.shade300, width: selected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(icon, color: selected ? grey : Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(
            fontSize: 13, fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? grey : Colors.grey[700],
          ))),
          if (selected) const Icon(Icons.check_circle_rounded, color: grey, size: 16),
        ]),
      ),
    );
  }
  Widget _termsCheckbox() => Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
    SizedBox(width: 24, height: 24,
      child: Checkbox(
        value: _agreeToTerms,
        onChanged: (v) => setState(() => _agreeToTerms = v!),
        activeColor: grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                    color: _brown,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ]);

  Widget _submitButton(bool isLoading) => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton(
      onPressed: isLoading ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: grey,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(width: 22, height: 22,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text('CREATE ACCOUNT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
    ),
  );

  Widget _webLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _dark)),
  );

  InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
    prefixIcon: Icon(icon, size: 20, color: Colors.grey[400]),
    filled: true,
    fillColor: const Color(0xFFF9F9F9),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _brown, width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}