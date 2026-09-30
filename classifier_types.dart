import 'dart:typed_data';

class DiseaseInfo {
  final String name;
  final String symptoms;
  final String treatment;
  const DiseaseInfo(this.name, this.symptoms, this.treatment);
}

const List<DiseaseInfo> kClasses = [
  DiseaseInfo(
    'Bud Rot',
    'Paleness and wilting of the central spear leaf, rotting of terminal bud tissue, foul odor.',
    'Remove and destroy infected crown tissue. Apply 1% Bordeaux mixture or copper oxychloride (3 g/L) around the spear leaf axils.',
  ),
  DiseaseInfo(
    'Leaf Rot',
    'Dark brown to black necrotic spots on young fronds; water-soaked lesions producing a shot-hole look.',
    'Improve drainage and sunlight penetration. Apply mancozeb (3 g/L) or carbendazim (1 g/L) early.',
  ),
  DiseaseInfo(
    'Stem Bleeding',
    'Reddish-brown to black liquid oozing from longitudinal cracks on the lower trunk.',
    'Remove infected bark until healthy wood is reached; treat with coal tar or Calixin (tridemorph). Apply neem cake to soil.',
  ),
  DiseaseInfo(
    'Tanjore Wilt / Basal Stem Rot',
    'Yellowing and drooping of lower fronds, bleeding spots near the stem base, root decay.',
    'Isolate affected palms with ~1 m deep trenches; apply 1% Bordeaux mixture or Aureofungin-sol soil treatment.',
  ),
  DiseaseInfo(
    'Healthy',
    'Deep green, uniformly developed fronds with an intact spear leaf and no lesions.',
    'No treatment needed. Maintain NPK nutrition, regular irrigation and seasonal pest monitoring.',
  ),
];

class Prediction {
  final int classIndex;
  final double confidence;
  final List<double> probabilities;
  final bool isDemo;
  Prediction(this.classIndex, this.confidence, this.probabilities, this.isDemo);
}

abstract class ClassifierBase {
  bool get isModelLoaded;
  Future<void> load();
  Future<Prediction> predict(Uint8List bytes);
}