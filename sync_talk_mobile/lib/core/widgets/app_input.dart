// import 'package:flutter/material.dart';

// class AppInput extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final bool obscure;

//   const AppInput({
//     super.key,
//     required this.controller,
//     required this.label,
//     this.obscure = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextField(
//         controller: controller,
//         obscureText: obscure,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class AppInput extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final bool isPassword;

//   const AppInput({
//     super.key,
//     required this.controller,
//     required this.hint,
//     this.isPassword = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword,
//       decoration: InputDecoration(
//         hintText: hint,
//         contentPadding: const EdgeInsets.all(14),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class AppInput extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final bool obscure;

//   const AppInput({
//     super.key,
//     required this.controller,
//     required this.label,
//     this.obscure = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextField(
//         controller: controller,
//         obscureText: obscure,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;

  const AppInput({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
