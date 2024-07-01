// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'dart:async';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen(
      {super.key,
      required this.prediction,
      required this.smokingValue,
      required this.glucoseValue,
      required this.hba1cValue,
      required this.bmiValue,
      required this.height,
      required this.weight,
      required this.age,
      required this.bmi});
  final double prediction;
  final int smokingValue;
  final double glucoseValue;
  final double hba1cValue;
  final double bmiValue;
  final double height;
  final double weight;
  final int age;
  final double bmi;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late int smokingValue;
  late double glucoseValue;
  late double hba1cValue;
  late double bmiValue;
  late double height;
  late num weight;
  late int age;
  late double bmi;
  double same = 0;
  double changedcs = 0;
  double changedbs = 0;
  double changedbmi = 0;
  List sameFactorsPredictions = [];
  List changingCumulativeSuger = [];
  List changingBloodSuger = [];
  List changingBmi = [];
  List<FlSpot> spots = [];
  double randomVal = 0;
  late int numOfFuturePredictions;

  num calculateWeight(height) {
    weight = (25 * ((height / 100) * (height / 100)));
    return weight;
  }

  Future<void> predict(isMale, age, hypSelectedValue, hdSelectedValue,
      smkSelectedValue, bmi, cumulative, glucose) async {
    final interpreter =
        await Interpreter.fromAsset('assets/diabetes_model.tflite');
    // Input tensor shape [1, 8] and type is float32
    var inputValuesMap = [
      {
        "gender": isMale ? 0 : 1,
        "age": age,
        "hypertension": hypSelectedValue,
        "heart_disease": hdSelectedValue,
        "smoking_history": smkSelectedValue,
        "bmi": bmi,
        "HbA1c_level": cumulative,
        "blood_glucose_level": glucose,
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

    same = output[0][0];

    // Close the interpreter when done
    interpreter.close();
  }

  Future<void> futurePrediction() async {
    for (var v = 0; v < (10 - numOfFuturePredictions); v++) {
      print(v);
      predict(true, age += 10, 0, 0, smokingValue, bmi, hba1cValue,
              glucoseValue)
          .whenComplete(() {
        sameFactorsPredictions.add(same);
        print("sf$sameFactorsPredictions");
      });
    }
    age = widget.age;
    for (var i = 0; i < (10 - numOfFuturePredictions); i++) {
      randomVal = 1.5 + Random().nextDouble();
      print(randomVal);
      hba1cValue = widget.hba1cValue;
      predict(true, age += 10, 0, 0, smokingValue, bmi, hba1cValue + randomVal,
              glucoseValue)
          .whenComplete(() {
        changingCumulativeSuger.add(same);
        print("cs$changingCumulativeSuger");
      });
    }

    // age = widget.age;
    // for (var x = 0; x < 5; x++) {
    //   predict(true, age += 10, 0, 0, smokingValue, bmi, hba1cValue,
    //           glucoseValue += 25)
    //       .whenComplete(() {
    //     changingBloodSuger.add(same);
    //     print("bs$changingBloodSuger");
    //   });
    // }
    hba1cValue = widget.hba1cValue;
    age = widget.age;
    for (var y = 0; y < (10 - numOfFuturePredictions); y++) {
      predict(true, age += 10, 0, 0, smokingValue, bmi += 3, hba1cValue,
              glucoseValue)
          .whenComplete(() {
        changingBmi.add(same);
        print("bmi$changingBmi");
      });
    }
  }

  @override
  void initState() {
    print("object");
    smokingValue = widget.smokingValue;
    glucoseValue = widget.glucoseValue;
    hba1cValue = widget.hba1cValue;
    bmiValue = widget.bmiValue;
    height = widget.height;
    weight = widget.weight;
    age = widget.age;
    bmi = widget.bmi;
    numOfFuturePredictions = (widget.age ~/ 10);
    calculateWeight(height);
    // Future.microtask(() async {
    //   await futurePrediction();
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/diabetes_logo.png"),
            opacity: 0.5,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 90, left: 20, right: 20),
                child: Card(
                  elevation: 10,
                  color: widget.prediction <= 0.25
                      ? Colors.greenAccent.shade200
                      : widget.prediction > 0.25 && widget.prediction <= 0.5
                          ? Colors.yellowAccent.shade200
                          : widget.prediction > 0.5 && widget.prediction <= 0.75
                              ? Colors.orangeAccent.shade200
                              : Colors.redAccent.shade200,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  )),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ResultAnimatedText(
                              text:
                                  "%${(widget.prediction * 100).toStringAsFixed(4)} :نسبة الاصابة",
                              text2: widget.prediction <= 0.25
                                  ? "excellent health indecators don't forget to do sports"
                                  : widget.prediction > 0.25 &&
                                          widget.prediction <= 0.5
                                      ? "Prety good health indecators"
                                      : widget.prediction > 0.5 &&
                                              widget.prediction <= 0.75
                                          ? "You must monitor yourself and its better to visit doctor to make full check up"
                                          : "You should visit doctor as soon as possible",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(
                        widget.prediction <= 0.25
                            ? "وضعك بالسليم ان شاء الله\nمية وردة"
                            : widget.prediction > 0.25 &&
                                    widget.prediction <= 0.5
                                ? "ايوااا بدنا ندير بالنا\nصحتك مش لعبة"
                                : widget.prediction > 0.5 &&
                                        widget.prediction <= 0.75
                                    ? "حب انت داخل مرحلة الخطر\nلحق حالك"
                                    : "والله ما انا عارف شو بدي اقلك\nوضعك بالمرة مش مطمئن",
                        duration: const Duration(milliseconds: 4000),
                        textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700),
                      ),
                    ],
                    isRepeatingAnimation: false,
                    repeatForever: false,
                    displayFullTextOnTap: true,
                    stopPauseOnTap: false,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SlideFadeTransition(
                  curve: Curves.elasticOut,
                  delayStart: const Duration(milliseconds: 500),
                  animationDuration: const Duration(milliseconds: 1200),
                  offset: 2.5,
                  direction: Direction.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Details",
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      DetailsTextWidget(
                          text:
                              "- ${hba1cValue >= 4.0 && hba1cValue <= 5.6 ? "Natural Cumulative blood suger" : hba1cValue < 4.0 ? "Low cumulative blood suger, consider monitoring yourself, and if you experience dizziness, consume something to raise your blood sugar" : hba1cValue >= 5.7 && hba1cValue <= 6.4 ? "Cumulative sugar is somewhat high, and this is considered a prelude to infection." : "High cumulative blood suger this is a strong indicator to infection of diabetes you should visit a doctor as soon as possible"}"),
                      DetailsTextWidget(
                          text:
                              "- ${glucoseValue >= 70.0 && glucoseValue <= 120.0 ? "Natural blood suger" : glucoseValue < 70.0 ? "Low blood sugar levels, monitor yourself; you might feel dizzy, so eat something to raise your blood sugar." : "High blood suger!! that may be indicator for diabetes infection...Measure again,make sure that you measure after two hours of eating and if it is high, you should visit the doctor"}"),
                      DetailsTextWidget(
                          text:
                              "- ${bmiValue <= 25.0 ? "Your body mass index below the upper limit means that your height and weight are somewhat proportionate." : "Your body mass index exceeds the upper limit, and this increase the infection rate and has other risks, such as heart and blood pressure diseases.\nDepending on your height $height your weight should be less than ${weight.truncate()}"}"),
                      DetailsTextWidget(
                          text:
                              "- ${smokingValue == 1 ? "Smoking may increase the infection rate, and it also causes many other damages." : "Well done!! you are not a smoker..keep going"}"),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  const Text(
                    "Future look:",
                    style: TextStyle(fontSize: 20),
                  ),
                  FutureBuilder(
                    future: futurePrediction(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          height: 400,
                          child: LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: 100,
                              minY: 0,
                              maxY: 100,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    for (int index = 0;
                                        index < (10 - numOfFuturePredictions);
                                        index++)
                                      FlSpot(
                                          ((widget.age ~/ 10) * 10) +
                                              (10.0 * (index + 1)),
                                          sameFactorsPredictions[index] * 100),
                                  ],
                                  color: Colors.green,
                                ),
                                LineChartBarData(
                                  spots: [
                                    for (int index = 0;
                                        index < (10 - numOfFuturePredictions);
                                        index++)
                                      FlSpot(
                                          ((widget.age ~/ 10) * 10) +
                                              (10.0 * (index + 1)),
                                          changingCumulativeSuger[index] * 100),
                                  ],
                                  color: Colors.red,
                                ),
                                LineChartBarData(
                                  spots: [
                                    for (int index = 0;
                                        index < (10 - numOfFuturePredictions);
                                        index++)
                                      FlSpot(
                                          ((widget.age ~/ 10) * 10) +
                                              (10.0 * (index + 1)),
                                          changingBmi[index] * 100),
                                  ],
                                  color: Colors.yellow,
                                ),
                              ],
                              titlesData: const FlTitlesData(
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  axisNameWidget: Text("Percentage"),
                                  sideTitles: SideTitles(
                                      showTitles: true, reservedSize: 40),
                                  axisNameSize: 30,
                                ),
                                bottomTitles: AxisTitles(
                                  axisNameWidget: Text("Age"),
                                  sideTitles: SideTitles(
                                      showTitles: true, reservedSize: 30),
                                  axisNameSize: 30,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                  const CatalogWidget(
                      desc: " If you take care of your body",
                      color: Colors.green),
                  const CatalogWidget(
                      desc: "Increasing of BMI ", color: Colors.yellow),
                  // const CatalogWidget(
                  //     desc: "Blood suger increasing", color: Colors.orange),
                  const CatalogWidget(
                      desc: "Increasing of cumulative suger ",
                      color: Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CatalogWidget extends StatelessWidget {
  const CatalogWidget({
    super.key,
    required this.desc,
    required this.color,
  });
  final String desc;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 5),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            color: color,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(desc),
          )
        ],
      ),
    );
  }
}

class ResultAnimatedText extends StatelessWidget {
  const ResultAnimatedText({
    super.key,
    required this.text,
    required this.text2,
  });

  final String text;
  final String text2;

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          "$text\n$text2",
          speed: const Duration(milliseconds: 100),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
      isRepeatingAnimation: false,
      repeatForever: false,
      displayFullTextOnTap: true,
      stopPauseOnTap: false,
    );
  }
}

class DetailsTextWidget extends StatelessWidget {
  const DetailsTextWidget({
    super.key,
    required this.text,
  });

  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

enum Direction { vertical, horizontal }

class SlideFadeTransition extends StatefulWidget {
  final Widget child;

  final double offset;

  final Curve curve;

  final Direction direction;

  final Duration delayStart;

  final Duration animationDuration;

  const SlideFadeTransition({
    super.key,
    required this.child,
    this.offset = 1.0,
    this.curve = Curves.easeIn,
    this.direction = Direction.vertical,
    this.delayStart = const Duration(seconds: 0),
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  _SlideFadeTransitionState createState() => _SlideFadeTransitionState();
}

class _SlideFadeTransitionState extends State<SlideFadeTransition>
    with SingleTickerProviderStateMixin {
  late Animation<Offset> _animationSlide;

  late AnimationController _animationController;

  late Animation<double> _animationFade;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    if (widget.direction == Direction.vertical) {
      _animationSlide = Tween<Offset>(
              begin: Offset(0, widget.offset), end: const Offset(0, 0))
          .animate(CurvedAnimation(
        curve: widget.curve,
        parent: _animationController,
      ));
    } else {
      _animationSlide = Tween<Offset>(
              begin: Offset(widget.offset, 0), end: const Offset(0, 0))
          .animate(CurvedAnimation(
        curve: widget.curve,
        parent: _animationController,
      ));
    }

    _animationFade =
        Tween<double>(begin: -1.0, end: 1.0).animate(CurvedAnimation(
      curve: widget.curve,
      parent: _animationController,
    ));

    Timer(widget.delayStart, () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationFade,
      child: SlideTransition(
        position: _animationSlide,
        child: widget.child,
      ),
    );
  }
}

// Padding(
//   padding: const EdgeInsets.all(20),
//   child: SlideFadeTransition(
//     curve: Curves.elasticOut,
//     delayStart: const Duration(milliseconds: 500),
//     animationDuration: const Duration(milliseconds: 1200),
//     offset: 2.5,
//     direction: Direction.horizontal,
//     child: Text(
// widget.prediction <= 0.25
//     ? ""
//     : widget.prediction > 0.25 && widget.prediction <= 0.5
//         ? ""
//         : widget.prediction > 0.5 && widget.prediction <= 0.75
//             ? ""
//             : "",
//       style: Theme.of(context).textTheme.displaySmall,
//     ),
//   ),
// ),

// FutureBuilder(
              //   future: futurePrediction(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.done) {
              //     return GridView.custom(
              //       shrinkWrap: true,
              //       gridDelegate:
              //           const SliverGridDelegateWithFixedCrossAxisCount(
              //               crossAxisCount: 2),
              //       childrenDelegate: SliverChildListDelegate.fixed(
              //         [
              //           Container(
              //             padding: const EdgeInsets.all(20),
              //             width: double.infinity,
              //             height: 400,
              //             child: LineChart(
              //               LineChartData(
              //                 minX: 0,
              //                 maxX: 100,
              //                 minY: 0,
              //                 maxY: 100,
              //                 lineBarsData: [
              //                   LineChartBarData(
              //                     spots: [
              //                       FlSpot(widget.age + 10.0,
              //                           sameFactorsPredictions[0] * 100),
              //                       FlSpot(widget.age + 20.0,
              //                           sameFactorsPredictions[1] * 100),
              //                       FlSpot(widget.age + 30.0,
              //                           sameFactorsPredictions[2] * 100),
              //                       FlSpot(widget.age + 40.0,
              //                           sameFactorsPredictions[3] * 100),
              //                       FlSpot(widget.age + 50.0,
              //                           sameFactorsPredictions[4] * 100),
              //                     ],
              //                     color: Colors.green,
              //                   ),
              //                 ],
              //                 titlesData: const FlTitlesData(
              //                   topTitles: AxisTitles(
              //                     sideTitles: SideTitles(showTitles: false),
              //                   ),
              //                   rightTitles: AxisTitles(
              //                     sideTitles: SideTitles(showTitles: false),
              //                   ),
              //                   leftTitles: AxisTitles(
              //                     axisNameWidget: Text("Percentage"),
              //                     sideTitles: SideTitles(
              //                         showTitles: true, reservedSize: 40),
              //                     axisNameSize: 30,
              //                   ),
              //                   bottomTitles: AxisTitles(
              //                     axisNameWidget: Text("Age"),
              //                     sideTitles: SideTitles(
              //                         showTitles: true, reservedSize: 30),
              //                     axisNameSize: 30,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //           Container(
              //             padding: const EdgeInsets.all(20),
              //             width: double.infinity,
              //             height: 400,
              //             child: LineChart(
              //               LineChartData(
              //                 minX: 0,
              //                 maxX: 100,
              //                 minY: 0,
              //                 maxY: 100,
              //                 lineBarsData: [
              //                   LineChartBarData(
              //                     spots: [
              //                       FlSpot(widget.age + 10.0,
              //                           changingBmi[0] * 100),
              //                       FlSpot(widget.age + 20.0,
              //                           changingBmi[1] * 100),
              //                       FlSpot(widget.age + 30.0,
              //                           changingBmi[2] * 100),
              //                       FlSpot(widget.age + 40.0,
              //                           changingBmi[3] * 100),
              //                       FlSpot(widget.age + 50.0,
              //                           changingBmi[4] * 100),
              //                     ],
              //                     color: Colors.yellow,
              //                   ),
              //                 ],
              //                 titlesData: const FlTitlesData(
              //                   topTitles: AxisTitles(
              //                     sideTitles: SideTitles(showTitles: false),
              //                   ),
              //                   rightTitles: AxisTitles(
              //                     sideTitles: SideTitles(showTitles: false),
              //                   ),
              //                   leftTitles: AxisTitles(
              //                     axisNameWidget: Text("Percentage"),
              //                     sideTitles: SideTitles(
              //                         showTitles: true, reservedSize: 40),
              //                     axisNameSize: 30,
              //                   ),
              //                   bottomTitles: AxisTitles(
              //                     axisNameWidget: Text("Age"),
              //                     sideTitles: SideTitles(
              //                         showTitles: true, reservedSize: 30),
              //                     axisNameSize: 30,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //           Container(
              //             padding: const EdgeInsets.all(20),
              //             width: double.infinity,
              //             height: 400,
              //             child: LineChart(
              //               LineChartData(
              //                 minX: 0,
              //                 maxX: 100,
              //                 minY: 0,
              //                 maxY: 100,
              //                 lineBarsData: [
              //                   LineChartBarData(
              //                     spots: [
              //                       FlSpot(widget.age + 10.0,
              //                           changingBloodSuger[0] * 100),
              //                       FlSpot(widget.age + 20.0,
              //                           changingBloodSuger[1] * 100),
              //                       FlSpot(widget.age + 30.0,
              //                           changingBloodSuger[2] * 100),
              //                       FlSpot(widget.age + 40.0,
              //                           changingBloodSuger[3] * 100),
              //                       FlSpot(widget.age + 50.0,
              //                           changingBloodSuger[4] * 100),
              //                     ],
              //                     color: Colors.orange,
              //                   ),
              //                 ],
              //                 titlesData: const FlTitlesData(
              //                   topTitles: AxisTitles(
              //                     sideTitles: SideTitles(showTitles: false),
              //                   ),
              //                   rightTitles: AxisTitles(
              //                     sideTitles: SideTitles(showTitles: false),
              //                   ),
              //                   leftTitles: AxisTitles(
              //                     axisNameWidget: Text("Percentage"),
              //                     sideTitles: SideTitles(
              //                         showTitles: true, reservedSize: 40),
              //                     axisNameSize: 30,
              //                   ),
              //                   bottomTitles: AxisTitles(
              //                     axisNameWidget: Text("Age"),
              //                     sideTitles: SideTitles(
              //                         showTitles: true, reservedSize: 30),
              //                     axisNameSize: 30,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //           Container(
              //             padding: const EdgeInsets.all(20),
              //             width: double.infinity,
              //             height: 400,
              //             child: LineChart(
              //               LineChartData(
              //                 minX: 0,
              //                 maxX: 100,
              //                 minY: 0,
              //                 maxY: 100,
              //                 lineBarsData: [
              //                   LineChartBarData(
              //                     spots: [
              //                       FlSpot(widget.age + 10.0,
              //                           changingCumulativeSuger[0] * 100),
              //                       FlSpot(widget.age + 20.0,
              //                           changingCumulativeSuger[1] * 100),
              //                       FlSpot(widget.age + 30.0,
              //                           changingCumulativeSuger[2] * 100),
              //                       FlSpot(widget.age + 40.0,
              //                           changingCumulativeSuger[3] * 100),
              //                       FlSpot(widget.age + 50.0,
              //                           changingCumulativeSuger[4] * 100),
              //                     ],
              //                     color: Colors.red,
              //                   ),
              //                 ],
              //                 titlesData: const FlTitlesData(
              //                   topTitles: AxisTitles(
              //                     sideTitles: SideTitles(showTitles: false),
              //                   ),
              //                   rightTitles: AxisTitles(
              //                     sideTitles: SideTitles(showTitles: false),
              //                   ),
              //                   leftTitles: AxisTitles(
              //                     axisNameWidget: Text("Percentage"),
              //                     sideTitles: SideTitles(
              //                         showTitles: true, reservedSize: 40),
              //                     axisNameSize: 30,
              //                   ),
              //                   bottomTitles: AxisTitles(
              //                     axisNameWidget: Text("Age"),
              //                     sideTitles: SideTitles(
              //                         showTitles: true, reservedSize: 30),
              //                     axisNameSize: 30,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     );
              //     }
              //     else {
              //           return const SizedBox();
              //         }
              //   },
              // ),
