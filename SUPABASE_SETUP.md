# Supabase Setup for Agri Sahayak

## Overview

This document explains how to set up Supabase for the Agri Sahayak Flutter application, including authentication and database configuration.

## Prerequisites

- A Supabase account (free tier available at [supabase.com](https://supabase.com))
- Flutter development environment
- Android Studio / VS Code

## Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Choose your organization
4. Enter project details:
   - **Name**: `agri-sahayak` (or your preferred name)
   - **Database Password**: Generate a strong password
   - **Region**: Choose closest to your users
5. Click "Create new project"
6. Wait for the project to be created (usually takes 2-3 minutes)

## Step 2: Get Project Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://your-project-id.supabase.co`)
   - **anon public** key
   - **service_role** key (keep this secret!)

## Step 3: Update secrets.dart

Update `lib/services/secrets.dart` with your Supabase credentials:

```dart
class Secrets {
  static const String geminiApiKey = 'your-gemini-api-key';
  static const String openWeatherApiKey = 'your-openweather-api-key';
  static const String SUPABASE_URL = "https://your-project-id.supabase.co";
  static const String SUPABASE_ANON_KEY = "your-anon-key";
  static const String SUPABASE_SERVICE_KEY = "your-service-role-key";
}
```

## Step 4: Configure Authentication

1. In Supabase dashboard, go to **Authentication** → **Settings**
2. Configure the following:

### Email Templates
- **Confirm signup**: Customize the email template for account verification
- **Reset password**: Customize the password reset email template

### OAuth Providers (Optional)
- **Google**: Add Google OAuth for social login
- **GitHub**: Add GitHub OAuth if needed

### Email Settings
- **Enable email confirmations**: Turn ON for production
- **Enable secure email change**: Turn ON for security

## Step 5: Create Database Tables

### Profiles Table
Create a `profiles` table to store user profile information:

```sql
-- Create profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  phone TEXT,
  role TEXT DEFAULT 'farmer',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policy for users to read their own profile
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Create policy for users to update their own profile
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Create policy for users to insert their own profile
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Create function to handle new user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, full_name, role)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'role');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

### Chat Messages Table (Optional)
If you want to store chat messages in Supabase:

```sql
-- Create chat_messages table
CREATE TABLE chat_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  response TEXT,
  media_attachment JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own messages" ON chat_messages
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own messages" ON chat_messages
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

## Step 6: Test the Integration

1. Run the Flutter app: `flutter run`
2. Try to create a new account
3. Verify that the user is created in Supabase Auth
4. Check that the profile is automatically created in the profiles table
5. Test sign in/sign out functionality

## Step 7: Environment Variables (Production)

For production, consider using environment variables instead of hardcoded secrets:

1. Create a `.env` file (don't commit to version control)
2. Use a package like `flutter_dotenv` to load environment variables
3. Update your CI/CD pipeline to include the environment variables

## Troubleshooting

### Common Issues

1. **"Invalid API key" error**
   - Verify your anon key is correct
   - Check that the key is not the service role key

2. **"Project not found" error**
   - Verify your project URL is correct
   - Check that your project is active

3. **Authentication not working**
   - Verify email confirmations are configured correctly
   - Check that OAuth providers are properly configured

4. **Database connection issues**
   - Verify your database is active
   - Check that RLS policies are correctly configured

### Debug Tips

1. Check the Flutter console for error messages
2. Use Supabase dashboard logs to see authentication attempts
3. Verify your database policies allow the operations you're trying to perform

## Security Best Practices

1. **Never expose service role key** in client-side code
2. **Use Row Level Security (RLS)** for all tables
3. **Validate user input** on both client and server
4. **Enable email confirmations** for production apps
5. **Regularly rotate API keys**
6. **Monitor authentication logs** for suspicious activity

## Next Steps

1. **Add more OAuth providers** (Facebook, Apple, etc.)
2. **Implement user roles and permissions**
3. **Add real-time subscriptions** for chat features
4. **Set up backup and monitoring**
5. **Implement rate limiting** for API calls

## Support

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Community](https://github.com/supabase/supabase/discussions)
- [Flutter Documentation](https://flutter.dev/docs)
