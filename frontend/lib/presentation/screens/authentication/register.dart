import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/data/models/register.dart';
import 'package:lokyatra_frontend/presentation/screens/authentication/loginPage.dart';
enum UserRole{tourist,host}


class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  UserRole _selectedRole=UserRole.tourist;
  bool _agreeToTerms = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  final nameController=TextEditingController();
  final emailController =TextEditingController();
  final phoneController=TextEditingController();
  final passwordController=TextEditingController();
  final confirmPasswordController=TextEditingController();
  final formKey=GlobalKey<FormState>();



  @override void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
          children: [
            IconButton(
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
        child: Form(
          key: formKey,
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
              RadioGroup<UserRole>(
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                child: Column(
                  children: [
                    RadioListTile<UserRole>(
                      title: Text("Explore as Tourist"),
                      value: UserRole.tourist,
                    ),
                    RadioListTile<UserRole>(
                      title: Text("Explore as Host"),
                      value: UserRole.host,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text("Username *"),
                TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                  validator:(value){
                    if(value ==null || value.isEmpty){
                      return "Please enter your name";
                    }
                    if(value.length<3){
                      return "Name must be at least 3 characters";
                    }
                    return null;
                  },

              ),

              const SizedBox(height: 20),
              const Text("Email *"),
              TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                validator: (value){
                    if(value==null || value.isEmpty){
                      return "Please enter your email";
                      }
                    if(!value.contains("@")||!value.contains(".com")){
                      return "Please enter a valid email";
                    }
                    return null;
                },
                ),


              const SizedBox(height: 20),
              const Text("Phone Number: +977 - (Optional)"),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Enter your phone number',

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                validator: (value){
                  if(value!=null && value.length!=10 && value!=""){
                    return "Please enter a valid phone number";
                  }
                  else if(value!.isEmpty) {
                    return null;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text(
                "You can add your phone number later from your profile to get verified",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Text("Password *"),
              TextFormField(
                controller: passwordController,
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
                validator: (value){
                  if(value==null || value.isEmpty){
                    return "Please enter a password";
                  }
                  if(value.length<8){
                    return "Password must be at least 8 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text("Confirm Password *"),
              TextFormField(
                obscureText: !_showConfirmPassword,
                controller: confirmPasswordController,
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
                validator: (value){
                  if(value ==null || value.isEmpty){
                    return "Please confirm your password";
                  }
                  if(value!=passwordController.text){
                    return "Password donot match";
                  }
                  return null;
                },
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
                activeColor: Colors.greenAccent,
                contentPadding: EdgeInsets.zero,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if(formKey.currentState!.validate()){
                      formKey.currentState!.save();
                    }
                    if(!_agreeToTerms){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please agree to Terms & Conditions"),
                        ),
                      );
                    }
                    final register=RegisterUser(
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      password: passwordController.text,
                      role: _selectedRole.toString(),
                    );
                    setState(() {
                        nameController.clear();
                        emailController.clear();
                        phoneController.clear();
                        passwordController.clear();
                        confirmPasswordController.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Registration Successful"),
                      ),

                    );

                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const LoginPage()),
                    // );
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
      ),
    );
  }
}
