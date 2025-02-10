import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Colors.lightGreenAccent),
        home: HomeScreen(),
      );
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double stepCount = 0, stepGoal = 10000;
  int _pageIndex = 1, _quoteIndex = 0;
  Timer? _timer;
  final List<String> quotes = [
    "Keep pushing forward!",
    "Every step counts!",
    "Stay positive and strong!",
    "Believe in yourself!",
    "You can do it!"
  ];

  StreamSubscription<StepCount>? _subscription;
  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _initPedometer();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() => _quoteIndex = (_quoteIndex + 1) % quotes.length);
    });
  }

  Future<void> requestPermissions() async {
    var activityRecognitionStatus = await Permission.activityRecognition.status;
    if (!activityRecognitionStatus.isGranted) {
      await Permission.activityRecognition.request();
    }

    var bodySensorsStatus = await Permission.sensors.status;
    if (!bodySensorsStatus.isGranted) {
      await Permission.sensors.request();
    }
  }

  void _initPedometer() async {
    if (await Permission.activityRecognition.request().isGranted) {
      print("Granted");
    }
    _pedestrianStatusStream = await Pedometer.pedestrianStatusStream;
    _stepCountStream = await Pedometer.stepCountStream;

    _stepCountStream?.listen(_onStepCount).onError(_onStepCountError);
    _pedestrianStatusStream
        ?.listen(_onPedestrianStatusChanged)
        .onError(_onPedestrianStatusError);
  }

  void _onStepCount(StepCount event) {
    print('Step count event received: ${event.steps}');
    setState(() {
      stepCount = event.steps.toDouble();
    });
  }

  void _onStepCountError(error) {
    print('Step Count Error: $error');
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    String status = event.status;
    DateTime timeStamp = event.timeStamp;
  }

  void _onPedestrianStatusError(error) {}

  @override
  void dispose() {
    _subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 16.0),
          _buildHeader(),
          SizedBox(height: 16.0),
          Center(
            child: Column(
              children: [
                _buildGaugeCard(),
                SizedBox(height: 16.0),
                _buildAdditionalInfoCard(),
                SizedBox(height: 16.0),
                _buildMotivatingCard(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.history, size: 30),
          Icon(Icons.home, size: 30),
          Icon(Icons.person, size: 30),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.lightGreenAccent,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) => setState(() => _pageIndex = index),
      ),
    );
  }

  Widget _buildHeader() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
          Text('Step Counter',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600)),
          IconButton(icon: Icon(Icons.directions_walk), onPressed: () {}),
        ],
      );

  Widget _buildGaugeCard() => _buildCard(
        350.0,
        350.0,
        Stack(
          alignment: Alignment.center,
          children: [
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: stepGoal,
                  showLabels: false,
                  showTicks: false,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.2,
                    cornerStyle: CornerStyle.bothCurve,
                    color: Colors.grey,
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: stepCount,
                      cornerStyle: CornerStyle.bothCurve,
                      width: 0.2,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: Colors.lightGreenAccent,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      positionFactor: 0.0,
                      angle: 90,
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${stepCount.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 50, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    GaugeAnnotation(
                      positionFactor: 0.8,
                      angle: 90,
                      widget: Icon(Icons.directions_walk,
                          size: 30, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 70.0, // Adjust this value to position the button
              child: TextButton(
                onPressed: () {
                  _initPedometer();
                  print('Start button pressed');
                },
                child: Text('Start',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
              ),
            ),
          ],
        ),
      );

  Widget _buildAdditionalInfoCard() => _buildCard(
        350.0,
        150.0,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildGaugeWithIcon(
              value: 300,
              maxValue: 500,
              color: Colors.redAccent,
              icon: Icons.local_fire_department,
              label: 'Calories',
            ),
            _buildGaugeWithIcon(
              value: 45,
              maxValue: 60,
              color: Colors.blueAccent,
              icon: Icons.timer,
              label: 'Time',
            ),
            _buildGaugeWithIcon(
              value: 10,
              maxValue: 15,
              color: Colors.greenAccent,
              icon: Icons.speed,
              label: 'Speed',
            ),
          ],
        ),
      );

  Widget _buildGaugeWithIcon({
    required double value,
    required double maxValue,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: maxValue,
                showLabels: false,
                showTicks: false,
                axisLineStyle: AxisLineStyle(
                  thickness: 0.2,
                  cornerStyle: CornerStyle.bothCurve,
                  color: Colors.grey,
                  thicknessUnit: GaugeSizeUnit.factor,
                ),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: value,
                    cornerStyle: CornerStyle.bothCurve,
                    width: 0.2,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: color,
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    positionFactor: 0.4,
                    angle: 90,
                    widget: Icon(icon, color: color, size: 20),
                  ),
                  GaugeAnnotation(
                    positionFactor: 0.8,
                    angle: 90,
                    widget: Text(
                      '${value.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 8.0),
        Text(label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMotivatingCard() => _buildCard(
        350.0,
        150.0,
        AnimatedSwitcher(
          duration: Duration(seconds: 1),
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Text(
            quotes[_quoteIndex],
            key: ValueKey<int>(_quoteIndex),
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
          ),
        ),
      );

  Widget _buildCard(double width, double height, Widget child) => Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0.0,
        child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            child: child),
      );
}
