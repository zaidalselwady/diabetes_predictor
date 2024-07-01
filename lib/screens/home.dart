import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:diabetes_predictor/screens/result.dart';
import 'package:flutter/services.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:diabetes_predictor/widgets/gender_button.dart';
import 'package:flutter/material.dart';
import '../widgets/UserInfo.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MainScreen> {
  @override
  Color color = const Color(0xEB4288);
  bool isMale = true;
  bool isFemale = false;
  int hdSelectedValue = 1;
  int hypSelectedValue = 1;
  int smkSelectedValue = 1;

  double bmi = 0;
  TextEditingController agetextEditingController =
      TextEditingController(text: "30");
  TextEditingController bgtextEditingController =
      TextEditingController(text: "80");
  TextEditingController a1ctextEditingController =
      TextEditingController(text: "5");
  TextEditingController heighttextEditingController = TextEditingController();
  TextEditingController weighttextEditingController = TextEditingController();

  ButtonState stateOnlyText = ButtonState.idle;
  ButtonState stateTextWithIcon = ButtonState.idle;

  void onPressedIconWithText() {
    switch (stateTextWithIcon) {
      case ButtonState.idle:
        stateTextWithIcon = ButtonState.loading;
        predict();
        Future.delayed(
          const Duration(seconds: 3),
          () {
            setState(
              () {
                stateTextWithIcon = ButtonState.success;
              },
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ResultScreen(
                    age: int.parse(agetextEditingController.text),
                    bmi: bmi,
                    prediction: prediction,
                    bmiValue: bmi,
                    glucoseValue: double.parse(bgtextEditingController.text),
                    hba1cValue: double.parse(a1ctextEditingController.text),
                    smokingValue: smkSelectedValue,
                    height: double.parse(heighttextEditingController.text),
                    weight: double.parse(weighttextEditingController.text),
                  );
                },
              ),
            );
          },
        );

        break;
      case ButtonState.loading:
        stateTextWithIcon = ButtonState.success;
        break;
      case ButtonState.success:
        stateTextWithIcon = ButtonState.idle;
        break;
      case ButtonState.fail:
        stateTextWithIcon = ButtonState.idle;
        break;
    }
    setState(
      () {
        stateTextWithIcon = stateTextWithIcon;
      },
    );
  }

  @override
  void initState() {
    stateTextWithIcon = ButtonState.idle;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/diabetes_logo.png"),
        leadingWidth: 100,
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GenderButton(
                    path: "assets/male.png",
                    isMale: isMale,
                    genderDesc: "male",
                    onTap: () {
                      setState(() {
                        isMale = true;
                        isFemale = false;
                      });
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  GenderButton(
                    path: "assets/female.png",
                    isMale: isFemale,
                    genderDesc: "female",
                    onTap: () {
                      setState(() {
                        isFemale = true;
                        isMale = false;
                      });
                    },
                  )
                ],
              ),
            ),
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          bmiCalculator(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(40),
                                topLeft: Radius.circular(5),
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                              ),
                              color: Colors.orangeAccent.shade100),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              Positioned(
                                  right: 70,
                                  top: -100,
                                  bottom: 90,
                                  child: Image.asset(
                                    "assets/bmi.png",
                                    fit: BoxFit.contain,
                                    width: 70,
                                  )),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Flexible(
                                    child: Text(
                                      "BMI",
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    bmi != 0 ? bmi.toStringAsFixed(1) : "",
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    UserInfo(
                      validator: (value) {
                        if (int.parse(value!) > 100) {
                          return "invalid age";
                        }
                        return null;
                      },
                      color: Colors.orangeAccent.shade100,
                      path: "assets/age.png",
                      iconButton:
                          IconButton(onPressed: () {}, icon: const Icon(null)),
                      number: agetextEditingController.text,
                      controller: agetextEditingController,
                      //number: age,
                      factorDesc: "Age",
                      textSize: 22,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    UserInfo(
                      color: Colors.redAccent.shade100,
                      path: "assets/analysis.png",
                      iconButton: IconButton(
                        onPressed: () {
                          help(context, "Cumulative\nSugar",
                              "HbA1c (Hemoglobin A1c) level is a measure of a person's average blood sugar level over the past 2-3 months. Higher levels indicate a greater risk of developing diabetes. Mostly more than 6.5% of HbA1c Level indicates diabetes.");
                        },
                        icon: const Icon(Icons.help_outline),
                      ),
                      controller: a1ctextEditingController,
                      number: num.parse(a1ctextEditingController.text)
                          .toStringAsFixed(1),
                      factorDesc: "Cumulative\nsuger",
                      textSize: 16,
                      validator: (value) {
                        if (double.parse(value!) < 3.5) {
                          return "too small value";
                        } else if (double.parse(value) > 9) {
                          return "too big value";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    UserInfo(
                      color: Colors.redAccent.shade100,
                      path: "assets/sugar-blood-level.png",
                      iconButton: IconButton(
                        onPressed: () {
                          help(context, "Glucose",
                              "Blood glucose level refers to the amount of glucose in the bloodstream at a given time. High blood glucose levels are a key indicator of diabetes.");
                        },
                        icon: const Icon(Icons.help_outline),
                      ),
                      controller: bgtextEditingController,
                      number: num.parse(bgtextEditingController.text)
                          .toStringAsFixed(1),
                      factorDesc: "Glucose",
                      textSize: 20,
                      validator: (value) {
                        if (double.parse(value!) < 80.0) {
                          // ScaffoldMessenger.of(context)
                          //     .showSnackBar(SnackBar(content: Text("gggg")));
                          return "too small value";
                        } else if (double.parse(value) > 300) {
                          return "too big value";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CardWithRadio(
                      path: "assets/heart-disease.png",
                      groupValue: hdSelectedValue,
                      desc: "Heart\nDisease",
                      onPressed: () {
                        help(context, "Heart Disease",
                            "Heart disease is another medical condition that is associated with an increased risk of developing diabetes.");
                      },
                      onRadioSelected: (value) {
                        setState(() {
                          hdSelectedValue = value!;
                          print(value);
                        });
                      },
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    CardWithRadio(
                      path: "assets/hypertension.png",
                      groupValue: hypSelectedValue,
                      desc: "Hype",
                      onPressed: () {
                        help(context, "Hypertension",
                            "Hypertension is a medical condition in which the blood pressure in the arteries is persistently elevated.");
                      },
                      onRadioSelected: (value) {
                        setState(() {
                          hypSelectedValue = value!;
                          print(value);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(40),
                            topLeft: Radius.circular(5),
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                          color: Colors.yellowAccent.shade100,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned(
                                right: 240,
                                top: -125,
                                bottom: 90,
                                child: Image.asset(
                                  "assets/cigarette.png",
                                  fit: BoxFit.contain,
                                  width: 70,
                                )),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                  "Smoking",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Column(
                                        children: [
                                          const Text("Yes"),
                                          Radio(
                                            activeColor:
                                                const Color(0xffFFFFFF),
                                            value: 1,
                                            groupValue: smkSelectedValue,
                                            onChanged: (value) {
                                              setState(() {
                                                smkSelectedValue = value!;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Column(
                                        children: [
                                          const Text("No"),
                                          Radio(
                                            activeColor:
                                                const Color(0xffFFFFFF),
                                            value: 0,
                                            groupValue: smkSelectedValue,
                                            onChanged: (value) {
                                              setState(() {
                                                smkSelectedValue = value!;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                width: double.infinity,
                child: ProgressButton.icon(
                    iconedButtons: {
                      ButtonState.idle: IconedButton(
                          text: 'Predict',
                          icon: const Icon(Icons.send, color: Colors.white),
                          color: Colors.teal.shade900),
                      ButtonState.loading: IconedButton(
                          text: 'Loading', color: Colors.teal.shade900),
                      ButtonState.fail: IconedButton(
                          text: 'Failed',
                          icon: const Icon(Icons.cancel, color: Colors.white),
                          color: Colors.red.shade300),
                      ButtonState.success: IconedButton(
                          text: 'Success',
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          color: Colors.green.shade400)
                    },
                    onPressed: () {
                      onPressedIconWithText();
                    },
                    state: stateTextWithIcon),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  double prediction = 0;
  Future<void> predict() async {
    final interpreter =
        await Interpreter.fromAsset('assets/diabetes_model.tflite');
    // Input tensor shape [1, 8] and type is float32
    var inputValuesMap = [
      {
        "gender": isMale ? 0 : 1,
        "age": num.parse(agetextEditingController.text),
        "hypertension": hypSelectedValue,
        "heart_disease": hdSelectedValue,
        "smoking_history": smkSelectedValue,
        "bmi": bmi,
        "HbA1c_level": num.parse(a1ctextEditingController.text),
        "blood_glucose_level": num.parse(bgtextEditingController.text),
      }
    ];

    var normalizedInput = [
      (inputValuesMap[0]["gender"]! - 0.0) /
          (1.0 - 0.0), // Gender: Min=0, Max=1
      (inputValuesMap[0]["age"]! - 1.0) / (80 - 0.08), // Age: Min=1, Max=122
      (inputValuesMap[0]["hypertension"]! - 0.0) /
          (1.0 - 0.0), // Hypertension: Min=0, Max=1
      (inputValuesMap[0]["heart_disease"]! - 0.0) /
          (1.0 - 0.0), // Heart Disease: Min=0, Max=1
      (inputValuesMap[0]["smoking_history"]! - 0.0) /
          (4 - 0), // Smoking History: Min=0, Max=1
      (inputValuesMap[0]["bmi"]! - 0.0) /
          (95.69 - 10.01), // BMI: Min=0, Max=100
      (inputValuesMap[0]["HbA1c_level"]! - 4.0) /
          (9 - 3.5), // HbA1c Level: Min=4, Max=16
      (inputValuesMap[0]["blood_glucose_level"]! - 50.0) /
          (300.0 - 80.0) // Blood Glucose Level: Min=50, Max=250
    ];
    // Reshape input for TensorFlow Lite model
    var input = [normalizedInput];

    // Output tensor shape [1, 2] and type is float32
    var output = List.filled(1 * 1, 0).reshape([1, 1]);
    // Perform inference
    interpreter.run(input, output);

    prediction = output[0][0];

    // Close the interpreter when done
    interpreter.close();
  }

  Future<dynamic> help(BuildContext context, String title, String info) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AlertDialog(
              elevation: 10,
              title: Text(title),
              content: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/diabetes_logo.png"),
                    opacity: 0.3,
                  ),
                ),
                child: Text(info),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"))
              ],
              shape: const OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                  borderSide: BorderSide.none),
            ),
          ),
        );
      },
    );
  }

  var formkey = GlobalKey<FormState>();
  Future<dynamic> bmiCalculator(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Calculate BMI"),
          content: SizedBox(
            height: 150,
            child: Form(
              key: formkey,
              child: Column(children: [
                TextFormField(
                  controller: heighttextEditingController,
                  decoration: const InputDecoration(hintText: "height"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "This field is required";
                    } else if (num.parse(value!) < 0) {
                      return "can't be minus";
                    } else if (num.parse(value) > 230) {
                      return "invalid value";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: weighttextEditingController,
                  decoration: const InputDecoration(hintText: "weight"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "This field is required";
                    } else if (num.parse(value!) < 0) {
                      return "can't be minus";
                    } else if (num.parse(value) > 150) {
                      return "invalid value";
                    }
                    return null;
                  },
                )
              ]),
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      setState(() {
                        bmi = double.parse(weighttextEditingController.text) /
                            pow(
                                (double.parse(
                                        heighttextEditingController.text) /
                                    100),
                                2);
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text("calculate")),
            )
          ],
        );
      },
    );
  }
}

class CardWithRadio extends StatefulWidget {
  const CardWithRadio({
    super.key,
    required this.groupValue,
    required this.desc,
    required this.onPressed,
    required this.path,
    required this.onRadioSelected,
  });

  final int groupValue;
  final String desc;
  final Function onPressed;
  final String path;
  final Function(int?) onRadioSelected;

  @override
  State<CardWithRadio> createState() => _CardWithRadioState();
}

class _CardWithRadioState extends State<CardWithRadio> {
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
          color: Colors.blueAccent.shade100,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.desc,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            widget.onPressed();
                          },
                          icon: const Icon(Icons.help_outline))
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text("Yes"),
                        Radio(
                          activeColor: const Color(0xffFFFFFF),
                          value: 1,
                          groupValue: widget.groupValue,
                          onChanged: (value) {
                            widget.onRadioSelected(value);
                            // setState(() {
                            //   widget.groupValue = value!;
                            //   print(value);
                            // });
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text("No"),
                        Radio(
                          activeColor: const Color(0xffFFFFFF),
                          value: 0,
                          groupValue: widget.groupValue,
                          onChanged: (value) {
                            widget.onRadioSelected(value);
                            // setState(() {
                            //   widget.groupValue = value!;
                            //   print(value);
                            // });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
