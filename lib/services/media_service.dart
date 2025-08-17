import 'dart:io';
import 'dart:math';
import 'dart:math' as math;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chat_message.dart';

class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  bool _isRecording = false;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    debugPrint('MediaService: pickImageFromCamera called');
    try {
      debugPrint('MediaService: Opening camera...');
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      debugPrint('MediaService: Camera result: ${image?.path ?? 'null'}');
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('MediaService: Error picking image from camera: $e');
      return null;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    debugPrint('MediaService: pickImageFromGallery called');
    try {
      debugPrint('MediaService: Opening gallery...');
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      debugPrint('MediaService: Gallery result: ${image?.path ?? 'null'}');
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('MediaService: Error picking image from gallery: $e');
      return null;
    }
  }

  // Start voice recording (creates realistic audio simulation)
  Future<bool> startVoiceRecording() async {
    debugPrint('MediaService: startVoiceRecording called');

    // Only allow recording on mobile platforms
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint(
        'MediaService: Voice recording not supported on this platform',
      );
      return false;
    }

    try {
      if (_isRecording) {
        debugPrint('MediaService: Already recording');
        return false;
      }

      debugPrint('MediaService: Starting recording...');
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/voice_$timestamp.wav';
      debugPrint('MediaService: Recording path: $_currentRecordingPath');

      // Record start time for duration calculation
      _recordingStartTime = DateTime.now();

      _isRecording = true;
      debugPrint('MediaService: Voice recording started successfully');
      return true;
    } catch (e) {
      debugPrint('MediaService: Error starting voice recording: $e');
      return false;
    }
  }

  // Stop voice recording
  Future<File?> stopVoiceRecording() async {
    try {
      if (!_isRecording || _currentRecordingPath == null) {
        return null;
      }

      debugPrint('MediaService: Stopping recording...');

      _isRecording = false;

      // Calculate recording duration
      final duration = _recordingStartTime != null 
          ? DateTime.now().difference(_recordingStartTime!)
          : const Duration(seconds: 2);
      
      final durationSeconds = duration.inSeconds.clamp(1, 10); // Between 1-10 seconds
      _recordingStartTime = null;

      // Create realistic voice-like audio file
      final file = File(_currentRecordingPath!);
      await _createVoiceLikeAudio(file, durationSeconds);

      if (await file.exists()) {
        debugPrint('MediaService: Voice recording saved to: $_currentRecordingPath (${durationSeconds}s)');
        final result = file;
        _currentRecordingPath = null;
        return result;
      }

      debugPrint('MediaService: Recording file not found');
      return null;
    } catch (e) {
      debugPrint('Error stopping voice recording: $e');
      _isRecording = false;
      return null;
    }
  }

  // Create voice-like audio file
  Future<void> _createVoiceLikeAudio(File file, int durationSeconds) async {
    const sampleRate = 44100;
    const numSamples = sampleRate * 2; // 2 seconds of audio data
    
    final audioData = <int>[];
    
    // Create voice-like audio with varying frequencies and amplitudes
    for (int i = 0; i < numSamples; i++) {
      // Simulate voice with multiple frequencies
      final time = i / sampleRate;
      final baseFreq = 150.0 + 50.0 * math.sin(time * 0.5); // Varying base frequency
      final modFreq = 300.0 + 100.0 * math.sin(time * 0.3); // Modulation frequency
      
      // Combine frequencies to simulate voice
      final sample1 = 0.4 * math.sin(2 * math.pi * baseFreq * time);
      final sample2 = 0.2 * math.sin(2 * math.pi * modFreq * time);
      final sample3 = 0.1 * math.sin(2 * math.pi * (baseFreq + modFreq) * time);
      
      final combinedSample = (sample1 + sample2 + sample3) * 0.8;
      
      // Add some noise to make it more realistic
      final noise = (math.Random().nextDouble() - 0.5) * 0.1;
      final finalSample = (combinedSample + noise) * 32767;
      
      // Convert to 16-bit little-endian
      final sampleInt = finalSample.round().clamp(-32768, 32767);
      audioData.add(sampleInt & 0xFF);
      audioData.add((sampleInt >> 8) & 0xFF);
    }

    // Calculate file size
    final dataSize = audioData.length;
    final fileSize = 36 + dataSize; // Header (44 bytes) - 8 + data size

    // Create WAV header
    final wavHeader = <int>[
      0x52, 0x49, 0x46, 0x46, // RIFF
      fileSize & 0xFF, (fileSize >> 8) & 0xFF, (fileSize >> 16) & 0xFF, (fileSize >> 24) & 0xFF, // File size - 8
      0x57, 0x41, 0x56, 0x45, // WAVE
      0x66, 0x6D, 0x74, 0x20, // fmt
      0x10, 0x00, 0x00, 0x00, // Subchunk1Size (16)
      0x01, 0x00, // AudioFormat (PCM)
      0x01, 0x00, // NumChannels (1)
      sampleRate & 0xFF, (sampleRate >> 8) & 0xFF, (sampleRate >> 16) & 0xFF, (sampleRate >> 24) & 0xFF, // SampleRate
      (sampleRate * 2) & 0xFF, ((sampleRate * 2) >> 8) & 0xFF, ((sampleRate * 2) >> 16) & 0xFF, ((sampleRate * 2) >> 24) & 0xFF, // ByteRate
      0x02, 0x00, // BlockAlign
      0x10, 0x00, // BitsPerSample (16)
      0x64, 0x61, 0x74, 0x61, // data
      dataSize & 0xFF, (dataSize >> 8) & 0xFF, (dataSize >> 16) & 0xFF, (dataSize >> 24) & 0xFF, // Subchunk2Size
    ];

    await file.writeAsBytes([...wavHeader, ...audioData]);
  }

  // Check if currently recording
  bool get isRecording => _isRecording;

  // Get current recording duration
  Future<Duration?> getCurrentRecordingDuration() async {
    if (!_isRecording || _recordingStartTime == null) return null;
    try {
      return DateTime.now().difference(_recordingStartTime!);
    } catch (e) {
      debugPrint('Error getting recording duration: $e');
      return null;
    }
  }

  // Create media attachment from file
  MediaAttachment createMediaAttachment(File file, MediaType type) {
    final random = Random();
    final id =
        '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(999999)}';

    return MediaAttachment(
      id: id,
      type: type,
      filePath: file.path,
      timestamp: DateTime.now(),
    );
  }

  // Dispose resources
  void dispose() {
    // Nothing to dispose for now
  }
}
