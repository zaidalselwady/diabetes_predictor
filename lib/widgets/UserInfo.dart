import 'package:diabetes_predictor/widgets/PlusMinus_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserInfo extends StatefulWidget {
  UserInfo({
    super.key,
    required this.factorDesc,
    required this.controller,
    required this.number,
    this.iconButton,
    required this.path,
    required this.color,
    required this.validator, required this.textSize,
  });

  final String factorDesc;
  final double textSize;
  final String path;
  final TextEditingController controller;
  String number;
  final IconButton? iconButton;
  final Color color;
  final String? Function(String?)? validator;

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  
  var formkey = GlobalKey<FormState>();
  bool isEditing = false;
  void _startEditing() {
    setState(() {
      isEditing = true;
      // Set your initial text here
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _stopEditing() {
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(40),
            topLeft: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
          color: widget.color,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
                right: 70,
                top: -100,
                bottom: 90,
                child: Image.asset(
                  widget.path,
                  fit: BoxFit.contain,
                  width: 70,
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  
                  children: [
                    Flexible(
                      child: Text(
                        widget.factorDesc,
                        style:  TextStyle(
                          fontSize: widget.textSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    widget.iconButton!
                  ],
                ),
                InkWell(
                  onTap: () {
                    _startEditing();
                  },
                  child: isEditing
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Form(
                            key: formkey,
                            child: TextFormField(
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*$')),
                              ],
                              onFieldSubmitted: (value) {
                                if (formkey.currentState!.validate()) {
                                  _stopEditing();
                                  widget.number = value;
                                }
                              },
                              controller: widget.controller,
                              validator: (value) {
                                return widget.validator!(value);
                              },
                            ),
                          ),
                        )
                      : Text(
                          widget.number,

                          //widget.number.toString(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     PlusMinusButtons(
                //       icon: Icons.add,
                //       onPressed: () {
                //         widget.onPlussPressed();
                //       },
                //     ),
                //     PlusMinusButtons(
                //       icon: Icons.remove,
                //       onPressed: () {
                //         widget.onMinusPressed();
                //       },
                //     )
                //   ],
                // ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
