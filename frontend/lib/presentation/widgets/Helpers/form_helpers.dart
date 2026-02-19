import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormHelpers {
  // Section title
  static Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Required text field
  static Widget requiredField(
      TextEditingController controller,
      String label, {
        String? hint,
        TextInputType? keyboardType,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: '$label *',
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (v) =>
      v == null || v.trim().isEmpty ? '$label is required' : null,
    );
  }

  // Email field with format validation
  static Widget emailField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email *',
        hintText: 'Enter your email',
        border: OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required';
        final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
        if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
        return null;
      },
    );
  }

  // Password field with toggle visibility
  static Widget passwordField(
      TextEditingController controller,
      String label, {
        bool Function()? isVisible,
        VoidCallback? onToggle,
        TextEditingController? matchController,
      }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool visible = false;
        return TextFormField(
          controller: controller,
          obscureText: !visible,
          decoration: InputDecoration(
            labelText: '$label *',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => visible = !visible),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return '$label is required';
            if (matchController == null && v.length < 8) {
              return 'At least 8 characters';
            }
            if (matchController != null && v != matchController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        );
      },
    );
  }

  // Phone number — exactly 10 digits, optional
  static Widget phoneField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        hintText: '98XXXXXXXX (Optional)',
        border: OutlineInputBorder(),
        counterText: '',
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return null; // optional
        if (v.length != 10) return 'Phone number must be exactly 10 digits';
        if (!v.startsWith('9')) return 'Nepal number must start with 9';
        return null;
      },
    );
  }

  // Name field — min 3 chars
  static Widget nameField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Full Name *',
        hintText: 'Enter your name',
        border: OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Name is required';
        if (v.trim().length < 3) return 'Name must be at least 3 characters';
        if (RegExp(r'[0-9]').hasMatch(v)) return 'Name cannot contain numbers';
        return null;
      },
    );
  }

  // Textarea
  static Widget textArea(
      TextEditingController controller,
      String label, {
        String? hint,
        bool required = false,
        int maxLength = 500,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
          : null,
    );
  }

  // Number field
  static Widget numberField(
      TextEditingController controller,
      String label, {
        bool required = false,
        bool decimal = false,
        int? min,
        int? max,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          decimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'\d'),
        ),
      ],
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty)) return 'Required';
        if (v != null && v.isNotEmpty) {
          final number = decimal ? double.tryParse(v) : int.tryParse(v);
          if (number == null) return 'Invalid number';
          if (number < 0) return 'Must be positive';
          if (min != null && number < min) return 'Minimum is $min';
          if (max != null && number > max) return 'Maximum is $max';
        }
        return null;
      },
    );
  }

  static void showSnack(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}