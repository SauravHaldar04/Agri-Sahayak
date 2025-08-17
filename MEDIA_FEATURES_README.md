# Media Features for Chat Screen

This document describes the new media functionality added to the Agri Sahayak chat screen.

## Features Added

### 1. Camera Integration
- **Camera Button**: Tap the camera icon to take a photo directly from the device camera
- **Photo Capture**: Automatically captures and sends photos for agricultural analysis
- **Image Quality**: Photos are optimized (80% quality, max 1024x1024) for efficient transmission

### 2. Gallery Integration
- **Gallery Button**: Tap the gallery icon to select existing photos from device gallery
- **Photo Selection**: Browse and select photos from your photo library
- **Multiple Formats**: Supports common image formats (JPEG, PNG, etc.)

### 3. Voice Recording
- **Microphone Button**: Tap the microphone icon to start/stop voice recording
- **Visual Feedback**: Button changes color and icon when recording (red when active)
- **Audio Playback**: Voice messages include a full-featured audio player with:
  - Play/Pause controls
  - Stop button
  - Progress bar
  - Duration display
  - Audio format: AAC-LC, 128kbps, 44.1kHz

### 4. Media Display
- **Image Display**: Images are displayed in chat bubbles with rounded corners and borders
- **Audio Player**: Voice messages show an interactive audio player widget
- **Responsive Layout**: Media content adapts to different screen sizes

## Technical Implementation

### Dependencies Added
```yaml
image_picker: ^1.0.7          # Camera and gallery access
record: ^4.4.4                # Voice recording (compatible version)
permission_handler: ^11.3.0   # Permission management
path_provider: ^2.1.2         # File path handling
audioplayers: ^5.2.1          # Audio playback
```

### New Files Created
- `lib/services/media_service.dart` - Handles all media operations
- `lib/widgets/audio_player_widget.dart` - Audio player UI component

### Modified Files
- `lib/models/chat_message.dart` - Added MediaAttachment support
- `lib/services/chat_service.dart` - Enhanced to handle media messages
- `lib/screens/farmer/chat_screen.dart` - Integrated media functionality
- `lib/widgets/chat_bubble.dart` - Added media display support
- `android/app/src/main/AndroidManifest.xml` - Added required permissions
- `ios/Runner/Info.plist` - Added iOS permission descriptions

### Permission Requirements

#### Android
- `CAMERA` - Camera access
- `RECORD_AUDIO` - Microphone access
- `WRITE_EXTERNAL_STORAGE` - File storage
- `READ_EXTERNAL_STORAGE` - File reading
- `MANAGE_EXTERNAL_STORAGE` - Storage management

#### iOS
- `NSCameraUsageDescription` - Camera usage description
- `NSMicrophoneUsageDescription` - Microphone usage description
- `NSPhotoLibraryUsageDescription` - Photo library access
- `NSPhotoLibraryAddUsageDescription` - Photo saving permission

## Usage Instructions

### Taking Photos
1. Tap the camera icon (📷) in the chat input bar
2. Grant camera permission when prompted
3. Take a photo using the device camera
4. Photo is automatically sent with a caption

### Selecting from Gallery
1. Tap the gallery icon (🖼️) in the chat input bar
2. Grant photo library permission when prompted
3. Browse and select an existing photo
4. Photo is automatically sent with a caption

### Recording Voice Messages
1. Tap the microphone icon (🎤) to start recording
2. The button turns red and shows a stop icon (⏹️)
3. Speak your message
4. Tap the stop icon to finish recording
5. Voice message is automatically sent

### Playing Voice Messages
1. Voice messages appear as audio player widgets
2. Tap the play button (▶️) to start playback
3. Use the stop button (⏹️) to stop playback
4. Progress bar shows playback position
5. Duration is displayed in MM:SS format

## Error Handling

- **Permission Denied**: App gracefully handles permission denials with user-friendly messages
- **File Errors**: Broken images show placeholder icons
- **Audio Errors**: Audio playback errors display in-app notifications
- **Network Issues**: Media uploads fail gracefully with retry options

## Future Enhancements

- **Video Support**: Add video recording and playback capabilities
- **File Sharing**: Support for document attachments (PDFs, etc.)
- **Media Compression**: Advanced image and audio compression options
- **Cloud Storage**: Integration with cloud storage services
- **Media Gallery**: In-app media browser for sent/received content

## Testing

To test the media features:

1. **Camera Test**: Take a photo and verify it appears in chat
2. **Gallery Test**: Select an image and verify it appears in chat
3. **Voice Test**: Record a voice message and verify playback works
4. **Permission Test**: Deny permissions and verify graceful fallback
5. **Error Test**: Test with corrupted files and verify error handling

## Troubleshooting

### Common Issues
- **Camera not working**: Check camera permissions in device settings
- **Microphone not working**: Check microphone permissions in device settings
- **Photos not loading**: Check storage permissions and file paths
- **Audio not playing**: Check audio output settings and volume

### Debug Information
- Check console logs for detailed error messages
- Verify all dependencies are properly installed
- Ensure platform-specific permissions are configured
- Test on both Android and iOS devices
