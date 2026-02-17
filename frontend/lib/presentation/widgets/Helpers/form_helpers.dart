import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormHelpers {
  static Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Widget requiredField(
      TextEditingController controller,
      String label, {
        String? hint,
      }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "$label *",
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
      value == null || value.trim().isEmpty ? "Required" : null,
    );
  }

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
        labelText: required ? "$label *" : label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (value) =>
      value == null || value.trim().isEmpty ? "Required" : null
          : null,
    );
  }

  static Widget numberField(
      TextEditingController controller,
      String label, {
        bool required = false,
        bool decimal = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType:
      TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          decimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'\d'),
        ),
      ],
      decoration: InputDecoration(
        labelText: required ? "$label *" : label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return "Required";
        }

        if (value != null && value.isNotEmpty) {
          final number =
          decimal ? double.tryParse(value) : int.tryParse(value);

          if (number == null) return "Invalid number";
          if (number < 0) return "Must be positive";
        }

        return null;
      },
    );
  }

  static void showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}