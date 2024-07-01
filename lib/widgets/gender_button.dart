import 'package:animator/animator.dart';
import 'package:flutter/material.dart';

class GenderButton extends StatefulWidget {
  const GenderButton({
    super.key,
    required this.isMale,
    required this.genderDesc,
    //required this.icon,
    required this.onTap,
    required this.path,
  });

  final bool isMale;
  final String path;
  final String genderDesc;
  //final IconData icon;
  final Function() onTap;

  @override
  State<GenderButton> createState() => _GenderButtonState();
}

class _GenderButtonState extends State<GenderButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onTap();
        },
        child: Container(
          height: 150,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Animator<double>(
                duration: const Duration(milliseconds: 1000),
                cycles: 0,
                curve: Curves.easeInOut,
                tween: Tween<double>(begin: 15, end: 20),
                builder: (context, animatorState, child) {
                  return Image.asset(
                    opacity: widget.isMale
                        ? const AlwaysStoppedAnimation(1)
                        : const AlwaysStoppedAnimation(0.3),
                    widget.path,
                    width: widget.isMale ? animatorState.value * 4 : 60,
                  );
                },
              ),
              Text(
                widget.genderDesc,
                style: TextStyle(
                  color: widget.isMale
                      ? Colors.black
                      : Colors.transparent.withOpacity(0.3),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
