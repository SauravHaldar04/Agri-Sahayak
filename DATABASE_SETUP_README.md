# Database Setup for Agri Sahayak

This guide explains how to set up the Supabase database with demo users, agricultural issues, and chat functionality.

## 🗄️ Database Structure

The database includes three main tables:

### 1. `users` Table
Stores comprehensive user information including:
- **Basic Info**: Name, email, phone, role
- **Location**: Latitude, longitude, address
- **Farm Details**: Farm size, primary/secondary crops, soil type, irrigation
- **Experience**: Years of farming experience, verification status

### 2. `agricultural_issues` Table
Tracks agricultural problems with:
- **Issue Details**: Type, severity, description, affected crop
- **Location**: Where the issue occurred
- **Status**: Open, in progress, resolved, closed
- **Advisor Assignment**: Which advisor is handling the issue

### 3. `chat_messages` Table
Stores chat history with:
- **Message Content**: Text, media, location data
- **Sender Info**: User, AI, or advisor
- **AI Response Data**: Structured response data from Gemini

## 🚀 Setup Instructions

### Step 1: Access Supabase Dashboard
1. Go to [supabase.com](https://supabase.com)
2. Sign in to your account
3. Open your Agri Sahayak project

### Step 2: Run Database Script
1. Go to **SQL Editor** in your Supabase dashboard
2. Copy the entire content from `database_setup.sql`
3. Paste it into the SQL editor
4. Click **Run** to execute the script

### Step 3: Verify Setup
After running the script, you should see:
- ✅ `users` table created with 13 demo users
- ✅ `agricultural_issues` table created with 12 demo issues
- ✅ `chat_messages` table created
- ✅ Row Level Security (RLS) policies configured
- ✅ Indexes created for performance
- ✅ `user_statistics` view created

## 👥 Demo Users Created

### Farmers (10 users)
1. **Rajesh Kumar** - New Delhi - Wheat farmer with rust disease
2. **Lakshmi Devi** - Bangalore - Rice farmer with drought issues
3. **Mohammed Ali** - Mumbai - Cotton farmer with bollworm infestation
4. **Priya Sharma** - Kolkata - Jute farmer with soil salinity
5. **Gurpreet Singh** - Punjab - Wheat farmer with weather issues
6. **Anita Patel** - Gujarat - Groundnut farmer with nutrient deficiency
7. **Venkatesh Reddy** - Hyderabad - Rice farmer with blast disease
8. **Sunita Verma** - Lucknow - Wheat farmer with water logging
9. **Abdul Rahman** - Kerala - Coconut farmer with beetle infestation
10. **Meera Iyer** - Chennai - Rice farmer with root rot

### Advisors (3 users)
1. **Dr. Suresh Kumar** - New Delhi Agricultural University
2. **Dr. Priya Desai** - Karnataka Agricultural University
3. **Dr. Rajesh Patel** - Maharashtra Agricultural University

## 🌾 Demo Agricultural Issues

The script creates 12 realistic agricultural issues:

### Pest Issues
- Yellow rust disease in wheat
- Pink bollworm in cotton
- Rhinoceros beetle in coconut

### Disease Issues
- Bacterial wilt in tomatoes
- Blast disease in rice
- Root rot in pulses

### Nutrient Issues
- Nitrogen deficiency in mustard
- Phosphorus deficiency in groundnut

### Environmental Issues
- Drought affecting rice
- Untimely rains affecting wheat
- Water logging in sugarcane
- Soil salinity in jute

## 📍 Location Data

All demo users have realistic Indian locations:
- **Coordinates**: Latitude and longitude for each user
- **Addresses**: Village names and city information
- **Regional Diversity**: Covers different states and soil types

## 🔐 Security Features

### Row Level Security (RLS)
- Users can only view their own profiles and issues
- Advisors can view all farmer profiles and issues
- Chat messages are private to each user
- Advisors can access all chat messages

### Data Validation
- Role constraints (farmer, advisor, admin)
- Issue type constraints (pest, disease, nutrient, etc.)
- Severity levels (low, medium, high, critical)
- Status tracking (open, in_progress, resolved, closed)

## 📊 Analytics Features

### User Statistics View
The `user_statistics` view provides:
- Total issues per user
- Open vs resolved issues
- Total chat messages
- Farm size and experience data

### Performance Indexes
- Fast queries on user roles and locations
- Efficient issue filtering by status and type
- Quick chat message retrieval

## 🔄 Integration with Flutter App

The updated `SupabaseService` class provides methods for:

### User Management
```dart
// Create user profile
await supabaseService.createUserProfile(...)

// Get current user profile
final profile = await supabaseService.getCurrentUserProfile()

// Update user location
await supabaseService.updateUserLocation(...)
```

### Issue Management
```dart
// Create agricultural issue
await supabaseService.createAgriculturalIssue(...)

// Get user's issues
final issues = await supabaseService.getUserIssues(userId)

// Update issue status
await supabaseService.updateIssueStatus(...)
```

### Chat Management
```dart
// Save chat message
await supabaseService.saveChatMessage(...)

// Get chat history
final messages = await supabaseService.getUserChatMessages(userId)
```

## 🧪 Testing the Setup

### Test User Login
You can test with any demo user:
- **Email**: `rajesh.kumar@demo.com`
- **Password**: (create password during signup)

### Test Issue Creation
1. Login as a farmer
2. Create a new agricultural issue
3. Verify it appears in the database

### Test Advisor Access
1. Login as an advisor
2. View all farmer profiles
3. Access and update issues

## 🔧 Customization

### Adding More Demo Users
Edit the `database_setup.sql` file and add more INSERT statements:

```sql
INSERT INTO users (
    full_name, email, phone, role, 
    location_latitude, location_longitude, location_address,
    farm_size_hectares, primary_crop, secondary_crops,
    soil_type, irrigation_type, experience_years, is_verified
) VALUES (
    'New Farmer Name',
    'new.farmer@demo.com',
    '+91-1234567890',
    'farmer',
    20.5937, 78.9629,
    'Village: New Location, India',
    4.5, 'Corn', ARRAY['Soybeans', 'Wheat'],
    'Black Soil', 'drip', 5, true
);
```

### Adding More Issues
```sql
INSERT INTO agricultural_issues (
    user_id, issue_type, crop_affected, severity,
    description, location_latitude, location_longitude
) VALUES (
    (SELECT id FROM users WHERE email = 'new.farmer@demo.com'),
    'pest', 'Corn', 'medium',
    'Corn earworm affecting crop yield',
    20.5937, 78.9629
);
```

## 🚨 Troubleshooting

### Common Issues

1. **Permission Denied**
   - Ensure RLS policies are correctly configured
   - Check if user is authenticated

2. **Table Not Found**
   - Verify the SQL script ran completely
   - Check table names in Supabase dashboard

3. **Data Not Appearing**
   - Refresh the Supabase dashboard
   - Check for any error messages in the SQL editor

### Support
If you encounter issues:
1. Check the Supabase logs in the dashboard
2. Verify all SQL statements executed successfully
3. Ensure your Flutter app has the correct Supabase credentials

## 📈 Next Steps

After setup, you can:
1. **Test the Flutter app** with demo users
2. **Add real users** through the app
3. **Create real agricultural issues**
4. **Implement advisor features**
5. **Add more analytics and reporting**

The database is now ready for the Agri Sahayak application! 🎉
