// import 'package:flutter/material.dart';

// class TypingIndicator extends StatefulWidget {
//   const TypingIndicator({super.key});

//   @override
//   State<TypingIndicator> createState() => _TypingIndicatorState();
// }

// class _TypingIndicatorState extends State<TypingIndicator>
//     with TickerProviderStateMixin {
//   late List<AnimationController> _controllers;
//   late List<Animation<double>> _animations;

//   @override
//   void initState() {
//     super.initState();
//     // DEBUG: [ANIMATION] - Initialize 3 dot animations with staggered timing
//     print('⌨️ DEBUG: [TYPING] - Initializing typing indicator animation');

//     _controllers = List.generate(
//       3,
//       (index) => AnimationController(
//         vsync: this,
//         duration: const Duration(milliseconds: 600),
//       ),
//     );

//     _animations = _controllers.map((controller) {
//       return Tween<double>(
//         begin: 0.0,
//         end: -8.0,
//       ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
//     }).toList();

//     // DEBUG: [ANIMATION] - Start animations with 150ms delay between each dot
//     for (int i = 0; i < _controllers.length; i++) {
//       Future.delayed(Duration(milliseconds: i * 150), () {
//         if (mounted) {
//           _controllers[i].repeat(reverse: true);
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     // DEBUG: [ANIMATION] - Disposing typing indicator controllers
//     print('🧹 DEBUG: [TYPING] - Disposing typing indicator');
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: theme.brightness == Brightness.dark
//             ? Colors.grey.shade800
//             : Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: List.generate(3, (index) {
//           return AnimatedBuilder(
//             animation: _animations[index],
//             builder: (context, child) {
//               return Transform.translate(
//                 offset: Offset(0, _animations[index].value),
//                 child: Container(
//                   width: 8,
//                   height: 8,
//                   margin: const EdgeInsets.symmetric(horizontal: 2),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary.withOpacity(0.6),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               );
//             },
//           );
//         }),
//       ),
//     );
//   }
// }
