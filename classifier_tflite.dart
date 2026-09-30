import 'dart:typed_data';
import 'package:image/image.dart' as img_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'classifier_types.dart';

class PlatformClassifier implements ClassifierBase {
  static const modelAsset = 'assets/models/coconut_mobilenetv2.tflite';
  static const inputSize = 224;

  Interpreter? _interpreter;
  @override
  bool get isModelLoaded => _interpreter != null;
  @override
  Future<void> load() async {
    try {
      _interpreter = await Interpreter.fromAsset(modelAsset);
    } catch (_) {
      _interpreter = null; // model missing -> demo mode
    }
  }
  @override
  Future<Prediction> predict(Uint8List bytes) async {
    final interpreter = _interpreter;
    if (interpreter == null) {
      await Future.delayed(const Duration(seconds: 1));
      final probs = [0.928, 0.03, 0.02, 0.015, 0.007];
      return Prediction(0, probs[0], probs, true);
    }

    final decoded = img_lib.decodeImage(bytes);
    if (decoded == null) throw Exception('Could not read this image.');
    final resized =
        img_lib.copyResize(decoded, width: inputSize, height: inputSize);

    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final p = resized.getPixel(x, y);
          return [p.r / 255.0, p.g / 255.0, p.b / 255.0];
        }),
      ),
    );
    final output =
        List.filled(kClasses.length, 0.0).reshape([1, kClasses.length]);
    interpreter.run(input, output);

    final probs =
        (output[0] as List).map((e) => (e as num).toDouble()).toList();
    var best = 0;
    for (var i = 1; i < probs.length; i++) {
      if (probs[i] > probs[best]) best = i;
    }
    return Prediction(best, probs[best], probs, false);
  }
}