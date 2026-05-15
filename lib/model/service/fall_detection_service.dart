import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

const int BUFFER_SIZE = 100;

const double MEAN = 0.3949;
const double STD = 0.6638;

class FallDetectionService {

  Interpreter? _interpreter;

  final List<List<double>> _buffer = [];

  int _fallCounter = 0;

  bool _modelLoaded = false;

  StreamSubscription? _sensorSubscription;

  Future<void> loadModel() async {



    try {

      _interpreter = await Interpreter.fromAsset(
        'assets/model/fall_model_final.tflite',
      );

      _modelLoaded = true;

      print("Model Loaded Successfully ");

    } catch (e) {

      print("MODEL LOADING ERROR:");
      print(e);
    }
  }

  void startDetection({
    required Function() onFallDetected,
  }) {

    print("Starting accelerometer listener...");

    _sensorSubscription =
        accelerometerEvents.listen((event) {


          if (!_modelLoaded) {

            print("Model not loaded yet.");

            return;
          }

          _updateBuffer(event);

          print(
            "Buffer Size: ${_buffer.length}/$BUFFER_SIZE",
          );

          if (_buffer.length == BUFFER_SIZE) {

            print("Running AI model...");

            _runModel(onFallDetected);
          }
        });
  }

  void _updateBuffer(
      AccelerometerEvent event,
      ) {

    double x =
        (event.x - MEAN) / STD;

    double y =
        (event.y - MEAN) / STD;

    double z =
        ((event.z - MEAN) / STD) - 9.8;

    _buffer.add([
      x / 10,
      y / 10,
      z / 10,
    ]);

    if (_buffer.length > BUFFER_SIZE) {

      _buffer.removeAt(0);
    }
  }

  void _runModel(
      Function() onFallDetected,
      ) {

    try {

      var input = [_buffer];

      var output = List.generate(
        1,
            (_) => List.filled(1, 0.0),
      );

      _interpreter!.run(input, output);

      double pred = output[0][0];



      if (pred > 0.5) {

        _fallCounter++;

        print(
          "Fall Counter Increased => $_fallCounter",
        );

      } else {

        _fallCounter = 0;


      }

      if (_fallCounter >= 1) {

        print("FALL DETECTED !!!!!");

        _fallCounter = 0;

        onFallDetected();
      }

    } catch (e) {

      print("MODEL RUN ERROR:");
      print(e);
    }
  }

  void stopDetection() {

    print("Stopping detection...");

    _sensorSubscription?.cancel();
  }

  void dispose() {

    print("Disposing Fall Detection Service...");

    _sensorSubscription?.cancel();

    _interpreter?.close();
  }
}