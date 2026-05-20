import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_utils.dart';
import '../providers/scan_provider.dart';
import '../widgets/face_ar_overlay.dart';

enum _FlashMode { off, warm, cool }

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});
  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _cameraReady = false;
  bool _initializingCamera = false;
  String? _cameraError;
  int _cameraIndex = 0;

  late final FaceDetector _faceDetector;
  List<Face> _faces = [];
  bool _processing = false;
  Size _imageSize = Size.zero;
  InputImageRotation _imageRotation = InputImageRotation.rotation0deg;

  bool get _faceDetected => _faces.isNotEmpty;
  bool _capturing = false;
  _FlashMode _flashMode = _FlashMode.off;

  int _timerSeconds = 0;
  int _countdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(options: FaceDetectorOptions(
      enableContours: true,
      performanceMode: FaceDetectorMode.fast,
    ));
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      if (mounted) setState(() { _cameraReady = false; _controller = null; _faces = []; });
    } else if (state == AppLifecycleState.resumed) {
      _startCamera();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _faceDetector.close();
    if (_flashOn) ScreenBrightness().resetScreenBrightness();
    super.dispose();
  }

  // ── Camera ────────────────────────────────────────────────────────

  Future<void> _initCamera() async {
    setState(() { _initializingCamera = true; _cameraError = null; });
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() { _initializingCamera = false; _cameraError = 'No cameras found'; });
        return;
      }
      final frontIdx = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      _cameraIndex = frontIdx >= 0 ? frontIdx : 0;
      await _startCamera();
    } catch (e) {
      if (mounted) setState(() { _initializingCamera = false; _cameraError = '$e'; });
    }
  }

  Future<void> _startCamera() async {
    if (_cameras.isEmpty) return;
    setState(() { _initializingCamera = true; _cameraReady = false; _faces = []; });
    final ctrl = CameraController(_cameras[_cameraIndex], ResolutionPreset.high,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.nv21);
    _controller = ctrl;
    try {
      await ctrl.initialize();
      if (mounted) setState(() { _cameraReady = true; _initializingCamera = false; });
      ctrl.startImageStream(_processFrame);
    } catch (e) {
      if (mounted) setState(() { _initializingCamera = false; _cameraError = 'Could not start camera'; });
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_processing || !mounted) return;
    _processing = true;
    try {
      final camera = _cameras[_cameraIndex];
      final rotation = _sensorRotation(camera.sensorOrientation);
      final bytes = image.planes[0].bytes;
      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      );
      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);
      final faces = await _faceDetector.processImage(inputImage);
      if (mounted) setState(() {
        _faces = faces;
        _imageSize = Size(image.width.toDouble(), image.height.toDouble());
        _imageRotation = rotation;
      });
    } catch (_) {}
    _processing = false;
  }

  InputImageRotation _sensorRotation(int deg) => switch (deg) {
    90  => InputImageRotation.rotation90deg,
    180 => InputImageRotation.rotation180deg,
    270 => InputImageRotation.rotation270deg,
    _   => InputImageRotation.rotation0deg,
  };

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    _cancelCountdown();
    await _controller?.dispose();
    if (mounted) setState(() { _cameraReady = false; _faces = []; _controller = null; _flashMode = _FlashMode.off; });
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    HapticFeedback.lightImpact();
    await _startCamera();
  }

  bool get _isFrontCamera =>
      _cameras.isNotEmpty && _cameras[_cameraIndex].lensDirection == CameraLensDirection.front;

  // ── Flash ─────────────────────────────────────────────────────────

  void _cycleFlash() {
    HapticFeedback.selectionClick();
    final modes = _FlashMode.values;
    final next = modes[(_flashMode.index + 1) % modes.length];
    setState(() => _flashMode = next);
    if (next == _FlashMode.off) {
      ScreenBrightness().resetScreenBrightness();
    } else {
      ScreenBrightness().setScreenBrightness(1.0);
    }
  }

  bool get _flashOn => _flashMode != _FlashMode.off;

  List<Color> get _flashGradientColors => switch (_flashMode) {
    _FlashMode.warm => [Colors.transparent, const Color(0xCCFFF3E0)],
    _FlashMode.cool => [Colors.transparent, const Color(0xCCEEF7FF)],
    _FlashMode.off  => [Colors.transparent, Colors.transparent],
  };

  Color get _flashIconColor => switch (_flashMode) {
    _FlashMode.off  => Colors.white.withValues(alpha: 0.7),
    _FlashMode.warm => AppColors.legendary,
    _FlashMode.cool => AppColors.teal,
  };

  // ── Timer ─────────────────────────────────────────────────────────

  void _cycleTimer() {
    const opts = [0, 3, 5, 10];
    final i = opts.indexOf(_timerSeconds);
    HapticFeedback.selectionClick();
    setState(() => _timerSeconds = opts[(i + 1) % opts.length]);
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (mounted) setState(() { _countdown = 0; _timerSeconds = 0; });
  }

  // ── Capture ───────────────────────────────────────────────────────

  void _onShutterTap() {
    if (_capturing) return;
    if (_countdown > 0) { _cancelCountdown(); return; }
    HapticFeedback.mediumImpact();
    if (_timerSeconds > 0) {
      setState(() => _countdown = _timerSeconds);
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        if (_countdown <= 1) {
          t.cancel();
          setState(() => _countdown = 0);
          _doCapture();
        } else {
          HapticFeedback.selectionClick();
          setState(() => _countdown--);
        }
      });
    } else {
      _doCapture();
    }
  }

  Future<void> _doCapture() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    setState(() => _capturing = true);
    try {
      try { await ctrl.stopImageStream(); } catch (_) {}
      final xFile = await ctrl.takePicture();
      HapticFeedback.heavyImpact();
      final compressed = await compressImage(File(xFile.path));
      final mood = ref.read(selectedMoodProvider);
      final mode = ref.read(selectedModeProvider);
      if (mounted) {
        setState(() => _capturing = false);
        context.push('/loading', extra: {'imageFile': compressed, 'mood': mood, 'mode': mode});
      }
    } catch (_) {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _pickGallery() async {
    if (_capturing) return;
    HapticFeedback.lightImpact();
    setState(() => _capturing = true);
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 90);
      if (picked == null) { setState(() => _capturing = false); return; }
      final compressed = await compressImage(File(picked.path));
      final mood = ref.read(selectedMoodProvider);
      final mode = ref.read(selectedModeProvider);
      if (mounted) context.push('/loading', extra: {'imageFile': compressed, 'mood': mood, 'mode': mode});
    } catch (_) {
      if (mounted) setState(() => _capturing = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mood = ref.watch(selectedMoodProvider);
    final mode = ref.watch(selectedModeProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera preview ────────────────────────────────────────
          if (_cameraReady && _controller != null)
            _buildPreview()
          else
            ColoredBox(
              color: Colors.black,
              child: _initializingCamera
                  ? const Center(child: SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 1.5)))
                  : _cameraError != null
                      ? _buildError()
                      : const SizedBox.shrink(),
            ),

          // ── Flash ring light — center transparent, edges lit ─────
          if (_flashOn)
            IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.85,
                    colors: _flashGradientColors,
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),
            ),

          // ── Gradients ─────────────────────────────────────────────
          IgnorePointer(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xCC000000), Colors.transparent, Colors.transparent, Color(0xEE000000)],
                  stops: [0.0, 0.18, 0.65, 1.0],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),

          // ── AR face contours ──────────────────────────────────────
          if (_cameraReady && !_flashOn && _faces.isNotEmpty)
            IgnorePointer(
              child: FaceArOverlay(
                faces: _faces,
                imageSize: _imageSize,
                isFrontCamera: _isFrontCamera,
                rotation: _imageRotation,
              ),
            ),

          // ── Countdown overlay ─────────────────────────────────────
          if (_countdown > 0) _buildCountdown(),

          // ── UI chrome ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Back
                      _CamIconBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () { HapticFeedback.lightImpact(); context.pop(); },
                      ),
                      const Spacer(),
                      // Timer indicator chip (when set)
                      if (_timerSeconds > 0 && _countdown == 0)
                        _TimerChip(
                          seconds: _timerSeconds,
                          onTap: _cycleTimer,
                        ),
                      if (_timerSeconds > 0 && _countdown == 0) const SizedBox(width: 8),
                      // Flash
                      _CamIconBtn(
                        icon: _flashMode == _FlashMode.off
                            ? Icons.flash_off_rounded
                            : Icons.flash_on_rounded,
                        color: _flashIconColor,
                        onTap: _cycleFlash,
                      ),
                    ],
                  ),
                ),

                // Face-detected status
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _faceDetected ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.signalGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.signalGreen.withValues(alpha: 0.5), width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5, height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.signalGreen,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Face detected',
                          style: GoogleFonts.dmSans(
                            fontSize: 11, fontWeight: FontWeight.w500,
                            color: AppColors.signalGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Mood + mode selectors
                _MoodRow(
                  current: mood,
                  onChanged: (v) { HapticFeedback.selectionClick(); ref.read(selectedMoodProvider.notifier).state = v; },
                ),
                const SizedBox(height: 10),
                _ModeRow(
                  current: mode,
                  onChanged: (v) { HapticFeedback.selectionClick(); ref.read(selectedModeProvider.notifier).state = v; },
                ),
                const SizedBox(height: 24),

                // Shutter row
                Padding(
                  padding: EdgeInsets.only(bottom: bottomPad + 16, left: 32, right: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Gallery
                      _CamIconBtn(
                        icon: Icons.photo_library_rounded,
                        size: 28,
                        onTap: _pickGallery,
                      ),

                      // Shutter
                      _ShutterButton(
                        capturing: _capturing,
                        countdown: _countdown,
                        onTap: _onShutterTap,
                      ),

                      // Flip
                      _CamIconBtn(
                        icon: Icons.flip_camera_ios_rounded,
                        size: 28,
                        onTap: _cameras.length > 1 ? _flipCamera : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final ctrl = _controller!;
    final ps = ctrl.value.previewSize;
    if (ps == null) return const ColoredBox(color: Colors.black);

    Widget preview = ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(width: ps.height, height: ps.width, child: CameraPreview(ctrl)),
      ),
    );

    return preview;
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.camera_alt_outlined, color: Colors.white30, size: 36),
          const SizedBox(height: 12),
          Text('Camera unavailable',
              style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _initCamera,
            child: Text('Tap to retry',
                style: GoogleFonts.dmSans(
                  color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    return GestureDetector(
      onTap: _cancelCountdown,
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: Tween(begin: 1.4, end: 1.0)
                      .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Text(
                  '$_countdown',
                  key: ValueKey(_countdown),
                  style: GoogleFonts.dmSans(
                    fontSize: 112, fontWeight: FontWeight.w800,
                    color: Colors.white, height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap to cancel',
                style: GoogleFonts.dmSans(
                  fontSize: 13, color: Colors.white54, fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Subwidgets ─────────────────────────────────────────────────────

class _CamIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final double size;

  const _CamIconBtn({
    required this.icon,
    required this.onTap,
    this.color,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: size, color: color ?? Colors.white.withValues(alpha: 0.85)),
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  final int seconds;
  final VoidCallback onTap;
  const _TimerChip({required this.seconds, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_rounded, size: 13, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              '${seconds}s',
              style: GoogleFonts.dmSans(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final bool capturing;
  final int countdown;
  final VoidCallback onTap;
  const _ShutterButton({required this.capturing, required this.countdown, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCountingDown = countdown > 0;
    final ringColor = isCountingDown ? AppColors.accent : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80, height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 3),
              ),
            ),
            // Inner fill
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isCountingDown ? 60 : 64,
              height: isCountingDown ? 60 : 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCountingDown ? AppColors.accent.withValues(alpha: 0.2) : Colors.white,
              ),
              child: capturing
                  ? Center(
                      child: SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          color: isCountingDown ? AppColors.accent : Colors.black,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : isCountingDown
                      ? Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '$countdown',
                              key: ValueKey(countdown),
                              style: GoogleFonts.dmSans(
                                fontSize: 26, fontWeight: FontWeight.w800,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        )
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodRow extends StatelessWidget {
  final String current;
  final void Function(String) onChanged;
  const _MoodRow({required this.current, required this.onChanged});

  static const _moods = [('Tired', 'tired'), ('Steady', 'good'), ('Energized', 'energized')];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _moods.map((m) {
        final active = m.$2 == current;
        return GestureDetector(
          onTap: () => onChanged(m.$2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: active ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: active ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            child: Text(
              m.$1,
              style: GoogleFonts.dmSans(
                fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? Colors.white : Colors.white54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ModeRow extends StatelessWidget {
  final String current;
  final void Function(String) onChanged;
  const _ModeRow({required this.current, required this.onChanged});

  static const _modes = [('Mirror', 'honest'), ('Compass', 'nice')];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _modes.map((m) {
        final active = m.$2 == current;
        return GestureDetector(
          onTap: () => onChanged(m.$2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: active ? AppColors.accent.withValues(alpha: 0.25) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: active ? AppColors.accent.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.2),
                width: active ? 1.0 : 0.5,
              ),
            ),
            child: Text(
              m.$1,
              style: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? AppColors.accent : Colors.white54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
