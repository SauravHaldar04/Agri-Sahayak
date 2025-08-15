# Agri-Sahayak

A Flutter application for agricultural assistance and support.

## Setup

### Gemini API Integration

1. Get your Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Update `lib/services/secrets.dart` with your actual API key:
   ```dart
   static const String geminiApiKey = 'your_actual_api_key_here';
   ```
3. The `secrets.dart` file is already added to `.gitignore` to keep your API key secure

### Dependencies

Run the following command to install dependencies:
```bash
flutter pub get
```

## Features

- AI-powered chat assistance using Gemini API
- Smart component detection for charts, policy cards, diagnosis, and community prompts
- Typing indicators and error handling
- Secure API key management

## Usage

Initialize the chat service in your app:
```dart
// In your app initialization
ChatService.instance.initializeGemini();

// Send messages
await ChatService.instance.sendMessage("What's the current price of wheat?");
```

The chat service will automatically detect the type of query and provide appropriate responses with relevant UI components.
