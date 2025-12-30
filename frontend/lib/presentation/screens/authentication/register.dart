import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/loginPage.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String _selectedRole = 'tourist'; 
  bool _agreeToTerms = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  void _onRoleChanged(String? value) {
    setState(() {
      _selectedRole = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 100,
        toolbarHeight: 70,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.arrow_back),
          ),

      const Padding(
        padding: EdgeInsets.symmetric( horizontal: 0,vertical: 0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: AssetImage(
            "assets/images/lokyatra_logo.png",
          ),
          radius: 25,
        ),)
          ],

        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Join LokYatra Community",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "I want to:",
              style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.w500
              ),

            ),
            RadioGroup<String>(
              groupValue: _selectedRole,
              onChanged: _onRoleChanged,
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Explore as Tourist'),
                    value: 'tourist',
                  ),
                  RadioListTile<String>(
                    title: const Text('Explore as host'),
                    value: 'host',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("First Name *"),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Email *"),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Phone Number (Optional)"),
            TextFormField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '+977-9812345678',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "You can add your phone number later from your profile to get verified",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text("Password *"),
            TextFormField(
              obscureText: !_showPassword,
              decoration: InputDecoration(
                hintText: 'Create password',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Confirm Password *"),
            TextFormField(
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                hintText: 'Confirm password',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _agreeToTerms,
              onChanged: (value) {
                setState(() {
                  _agreeToTerms = value!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text("I agree to Terms & Conditions"),
              activeColor: Colors.orange,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "REGISTER",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  "Back to Login",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}