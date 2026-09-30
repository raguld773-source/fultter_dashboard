import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'classifier_types.dart';
import 'classifier_stubs.dart'
    if (dart.library.io) 'classifier_tflite.dart';
void main() => runApp(const CoconutCareApp());
class AppColors {
  static const leafGreen = Color(0xFF2E7D32);
  static const freshGreen = Color(0xFF66BB6A);
  static const cream = Color(0xFFF6F8F0);
  static const cardWhite = Color(0xFFFFFFFF);
  static const warnAmber = Color(0xFFF9A825);
  static const dangerRed = Color(0xFFC62828);
  static const healthyGreen = Color(0xFF43A047);
}
ThemeData buildPlantTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.leafGreen)
      .copyWith(primary: AppColors.leafGreen, secondary: AppColors.freshGreen);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.leafGreen,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.leafGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.leafGreen,
        side: const BorderSide(color: AppColors.leafGreen, width: 1.4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
class CoconutCareApp extends StatelessWidget {
  const CoconutCareApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'CoconutCare',
        debugShowCheckedModeBanner: false,
        theme: buildPlantTheme(),
        home: const HomePage(),
      );
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final _picker = ImagePicker();
  final ClassifierBase _classifier = PlatformClassifier();
  Uint8List? _imageBytes;
  Prediction? _prediction;
  bool _analyzing = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _classifier.load().then((_) => mounted ? setState(() {}) : null);
  }
  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, maxWidth: 1600);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _prediction = null;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Could not open the image: $e');
    }
  }
  Future<void> _analyze() async {
    final bytes = _imageBytes;
    if (bytes == null) return;
    setState(() {
      _analyzing = true;
      _error = null;
    });
    try {
      final result = await _classifier.predict(bytes);
      if (mounted) setState(() => _prediction = result);
    } catch (e) {
      if (mounted) setState(() => _error = 'Analysis failed: $e');
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, size: 22),
            SizedBox(width: 8),
            Text('CoconutCare')
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'AI Coconut Disease Detection',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.leafGreen),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Capture or upload a coconut leaf photo to diagnose',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  _LeafPreview(bytes: _imageBytes),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: const Text('Gallery'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text('Camera'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed:
                        (_imageBytes != null && !_analyzing) ? _analyze : null,
                    icon: _analyzing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.search, size: 18),
                    label: Text(_analyzing ? 'Analyzing…' : 'Analyze Leaf'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(
                            color: AppColors.dangerRed, fontSize: 12.5)),
                  ],
                  if (_prediction != null) ...[
                    const SizedBox(height: 20),
                    _ResultCard(prediction: _prediction!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class _LeafPreview extends StatelessWidget {
  final Uint8List? bytes;
  const _LeafPreview({required this.bytes});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.leafGreen.withOpacity(0.5), width: 1.4),
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes == null
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 48, color: AppColors.leafGreen),
                SizedBox(height: 8),
                Text('No leaf image selected',
                    style: TextStyle(color: AppColors.leafGreen, fontSize: 13)),
              ],
            )
          : Image.memory(bytes!, fit: BoxFit.cover, width: double.infinity),
    );
  }
}
class _ResultCard extends StatelessWidget {
  final Prediction prediction;
  const _ResultCard({required this.prediction});
  static const lowConfidence = 0.60;
  @override
  Widget build(BuildContext context) {
    final info = kClasses[prediction.classIndex];
    final isHealthy = info.name == 'Healthy';
    final lowConf = prediction.confidence < lowConfidence;
    final color = lowConf
        ? AppColors.warnAmber
        : (isHealthy ? AppColors.healthyGreen : AppColors.dangerRed);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (prediction.isDemo)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warnAmber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DEMO RESULT — the TFLite model is not loaded, so this is a '
                  'placeholder and NOT a real diagnosis.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            Row(children: [
              Icon(
                lowConf
                    ? Icons.help_outline
                    : (isHealthy
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_rounded),
                color: color,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: color)),
                    Text(
                        'Confidence: ${(prediction.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                            fontSize: 12.5, color: Colors.black54)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: prediction.confidence,
                minHeight: 6,
                backgroundColor: AppColors.cream,
                color: color,
              ),
            ),
            if (lowConf) ...[
              const SizedBox(height: 12),
              const Text(
                'Low confidence — please retake the photo in good light with the '
                'affected area filling the frame before applying any treatment.',
                style: TextStyle(fontSize: 12.5, height: 1.4),
              ),
            ] else ...[
              const Divider(height: 28),
              _Info(
                  icon: Icons.visibility_outlined,
                  title: 'Symptoms',
                  text: info.symptoms),
              const SizedBox(height: 14),
              _Info(
                  icon: Icons.eco_outlined,
                  title: 'Recommended Treatment',
                  text: info.treatment),
            ],
            const Divider(height: 28),
            const Text('Class probabilities',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            for (var i = 0; i < kClasses.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  SizedBox(
                    width: 130,
                    child: Text(kClasses[i].name,
                        style: const TextStyle(fontSize: 11.5),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: prediction.probabilities[i].clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: AppColors.cream,
                      color: AppColors.freshGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                      '${(prediction.probabilities[i] * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 11.5)),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}
class _Info extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _Info({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.leafGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 3),
                Text(text,
                    style: const TextStyle(
                        fontSize: 12.5, height: 1.4, color: Colors.black87)),
              ],
            ),
          ),
        ],
      );
}