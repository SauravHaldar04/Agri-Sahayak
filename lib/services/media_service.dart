import 'dart:io';
import 'dart:math';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/chat_message.dart';

class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  FlutterSoundRecorder? _audioRecorder;

  bool _isRecording = false;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  // Initialize the audio recorder
  Future<void> _initializeRecorder() async {
    if (_audioRecorder == null) {
      _audioRecorder = FlutterSoundRecorder();
      await _audioRecorder!.openRecorder();
    }
  }

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

  // Start voice recording (using flutter_sound)
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

      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        debugPrint('MediaService: Microphone permission denied');
        return false;
      }

      // Initialize recorder if needed
      await _initializeRecorder();

      debugPrint('MediaService: Starting recording...');
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/voice_$timestamp.aac';
      debugPrint('MediaService: Recording path: $_currentRecordingPath');

      // Start recording
      await _audioRecorder!.startRecorder(
        toFile: _currentRecordingPath!,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );

      // Record start time for duration calculation
      _recordingStartTime = DateTime.now();
      _isRecording = true;
      
      debugPrint('MediaService: Voice recording started successfully');
      return true;
    } catch (e) {
      debugPrint('MediaService: Error starting voice recording: $e');
      _isRecording = false;
      return false;
    }
  }

  // Stop voice recording
  Future<File?> stopVoiceRecording() async {
    try {
      if (!_isRecording || _currentRecordingPath == null || _audioRecorder == null) {
        debugPrint('MediaService: Not recording or no recorder available');
        return null;
      }

      debugPrint('MediaService: Stopping recording...');

      // Stop the recording
      final recordPath = await _audioRecorder!.stopRecorder();
      _isRecording = false;

      // Calculate recording duration
      final duration = _recordingStartTime != null
          ? DateTime.now().difference(_recordingStartTime!)
          : const Duration(seconds: 1);

      _recordingStartTime = null;

      if (recordPath != null) {
        final file = File(recordPath);
        if (await file.exists()) {
          final fileSize = await file.length();
          debugPrint(
            'MediaService: Voice recording saved to: $recordPath (${duration.inSeconds}s, ${fileSize} bytes)',
          );
          _currentRecordingPath = null;
          return file;
        } else {
          debugPrint('MediaService: Recording file does not exist: $recordPath');
        }
      } else {
        debugPrint('MediaService: No recording path returned from recorder');
      }

      _currentRecordingPath = null;
      return null;
    } catch (e) {
      debugPrint('MediaService: Error stopping voice recording: $e');
      _isRecording = false;
      _currentRecordingPath = null;
      return null;
    }
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
    if (_audioRecorder != null) {
      _audioRecorder!.closeRecorder();
      _audioRecorder = null;
    }
  }
}