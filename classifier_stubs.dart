import 'dart:typed_data';
import 'classifier_types.dart';

class PlatformClassifier implements ClassifierBase {
  @override
  bool get isModelLoaded => false;

  @override
  Future<void> load() async {}

  @override
  Future<Prediction> predict(Uint8List bytes) async {
    // DEMO ONLY: web build has no TFLite, so this is a placeholder result.
    await Future.delayed(const Duration(seconds: 1));
    final probs = [0.928, 0.03, 0.02, 0.015, 0.007];
    return Prediction(0, probs[0], probs, true);
  }
}