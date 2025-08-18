-- Database Setup for Agri Sahayak Users Table
-- Run this in your Supabase SQL Editor

-- Create users table with comprehensive fields
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    role TEXT CHECK (role IN ('farmer', 'advisor', 'policymaker')) DEFAULT 'farmer',
    location_latitude DECIMAL(10, 8),
    location_longitude DECIMAL(11, 8),
    location_address TEXT,
    -- Farmer specific fields
    farm_size_hectares DECIMAL(8, 2),
    primary_crop TEXT,
    secondary_crops TEXT[],
    soil_type TEXT,
    irrigation_type TEXT CHECK (irrigation_type IN ('drip', 'sprinkler', 'flood', 'manual', 'none')),
    experience_years INTEGER DEFAULT 0,
    -- Advisor specific fields
    specialization TEXT[],
    certification TEXT,
    advisory_districts TEXT[],
    consultation_rate DECIMAL(10, 2),
    -- Policymaker specific fields
    department TEXT,
    designation TEXT,
    jurisdiction TEXT,
    policy_areas TEXT[],
    is_verified BOOLEAN DEFAULT false,
    profile_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create RLS (Row Level Security) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Advisors can view farmer profiles (explicitly limit to farmers)
DROP POLICY IF EXISTS "Advisors can view farmer profiles" ON users;
CREATE POLICY "Advisors can view farmer profiles" ON users
    FOR SELECT USING (
        (EXISTS (
            SELECT 1 FROM users AS me
            WHERE me.auth_id = auth.uid()
            AND me.role = 'advisor'
        ))
        AND role = 'farmer'
    );

-- Policy: Policymakers can view all profiles
CREATE POLICY "Policymakers can view all profiles" ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = auth.uid() 
            AND role = 'policymaker'
        )
    );

-- Create function to automatically update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insert demo users with all required columns
INSERT INTO users (
    full_name, 
    email, 
    phone, 
    role, 
    location_latitude, 
    location_longitude, 
    location_address,
    farm_size_hectares,
    primary_crop,
    secondary_crops,
    soil_type,
    irrigation_type,
    experience_years,
    specialization,
    certification,
    advisory_districts,
    consultation_rate,
    department,
    designation,
    jurisdiction,
    policy_areas,
    is_verified
) VALUES 
-- Demo Farmers with Issues
(
    'Rajesh Kumar',
    'rajesh.kumar@demo.com',
    '+91-9876543210',
    'farmer',
    28.6139,
    77.2090,
    'Village: Mehrauli, New Delhi, India',
    5.5,
    'Wheat',
    ARRAY['Mustard', 'Potato'],
    'Alluvial',
    'drip',
    8,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    true
),
(
    'Lakshmi Devi',
    'lakshmi.devi@demo.com',
    '+91-8765432109',
    'farmer',
    12.9716,
    77.5946,
    'Village: Hebbal, Bangalore, Karnataka, India',
    3.2,
    'Rice',
    ARRAY['Vegetables', 'Pulses'],
    'Red Soil',
    'sprinkler',
    12,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    true
),
(
    'Mohammed Ali',
    'mohammed.ali@demo.com',
    '+91-7654321098',
    'farmer',
    19.0760,
    72.8777,
    'Village: Thane, Mumbai, Maharashtra, India',
    7.8,
    'Cotton',
    ARRAY['Sugarcane', 'Groundnut'],
    'Black Soil',
    'flood',
    15,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    true
),
(
    'Priya Sharma',
    'priya.sharma@demo.com',
    '+91-6543210987',
    'farmer',
    22.5726,
    88.3639,
    'Village: Howrah, Kolkata, West Bengal, India',
    2.1,
    'Jute',
    ARRAY['Rice', 'Vegetables'],
    'Deltaic',
    'manual',
    6,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    false
),
(
    'Gurpreet Singh',
    'gurpreet.singh@demo.com',
    '+91-5432109876',
    'farmer',
    31.6340,
    74.8723,
    'Village: Amritsar, Punjab, India',
    8.5,
    'Wheat',
    ARRAY['Rice', 'Maize'],
    'Alluvial',
    'drip',
    20,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    true
),
(
    'Anita Patel',
    'anita.patel@demo.com',
    '+91-4321098765',
    'farmer',
    23.0225,
    72.5714,
    'Village: Gandhinagar, Gujarat, India',
    4.3,
    'Groundnut',
    ARRAY['Cotton', 'Wheat'],
    'Red Soil',
    'sprinkler',
    10,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    true
),
(
    'Venkatesh Reddy',
    'venkatesh.reddy@demo.com',
    '+91-3210987654',
    'farmer',
    17.3850,
    78.4867,
    'Village: Secunderabad, Hyderabad, Telangana, India',
    6.7,
    'Rice',
    ARRAY['Maize', 'Pulses'],
    'Red Soil',
    'drip',
    14,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    true
),
(
    'Sunita Verma',
    'sunita.verma@demo.com',
    '+91-2109876543',
    'farmer',
    26.8467,
    80.9462,
    'Village: Lucknow, Uttar Pradesh, India',
    3.9,
    'Wheat',
    ARRAY['Rice', 'Sugarcane'],
    'Alluvial',
    'manual',
    9,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    false
),
(
    'Abdul Rahman',
    'abdul.rahman@demo.com',
    '+91-1098765432',
    'farmer',
    10.8505,
    76.2711,
    'Village: Thrissur, Kerala, India',
    2.8,
    'Coconut',
    ARRAY['Rubber', 'Spices'],
    'Laterite',
    'drip',
    11,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    true
),
(
    'Meera Iyer',
    'meera.iyer@demo.com',
    '+91-0987654321',
    'farmer',
    13.0827,
    80.2707,
    'Village: Chennai, Tamil Nadu, India',
    5.1,
    'Rice',
    ARRAY['Pulses', 'Vegetables'],
    'Red Soil',
    'sprinkler',
    7,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    true
),

-- Demo Advisors
(
    'Dr. Suresh Kumar',
    'dr.suresh.kumar@demo.com',
    '+91-9876543211',
    'advisor',
    28.6139,
    77.2090,
    'Agricultural University, New Delhi, India',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    25,
    ARRAY['Crop Diseases', 'Soil Management'],
    'PhD in Agriculture',
    ARRAY['Delhi', 'Ghaziabad', 'Noida'],
    500.00,
    NULL,
    NULL,
    NULL,
    NULL,
    true
),
(
    'Dr. Priya Desai',
    'dr.priya.desai@demo.com',
    '+91-8765432108',
    'advisor',
    12.9716,
    77.5946,
    'Karnataka Agricultural University, Bangalore, India',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    18,
    ARRAY['Plant Pathology', 'Organic Farming'],
    'PhD in Plant Pathology',
    ARRAY['Bangalore', 'Mysore', 'Hubli'],
    450.00,
    NULL,
    NULL,
    NULL,
    NULL,
    true
),
(
    'Dr. Rajesh Patel',
    'dr.rajesh.patel@demo.com',
    '+91-7654321097',
    'advisor',
    19.0760,
    72.8777,
    'Maharashtra Agricultural University, Mumbai, India',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    22,
    ARRAY['Entomology', 'Integrated Pest Management'],
    'PhD in Entomology',
    ARRAY['Mumbai', 'Pune', 'Nashik'],
    600.00,
    NULL,
    NULL,
    NULL,
    NULL,
    true
),

-- Demo Policymakers
(
    'Shri Rajesh Singh',
    'rajesh.policy@demo.com',
    '+91-9876543212',
    'policymaker',
    28.6139,
    77.2090,
    'Ministry of Agriculture, New Delhi',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Ministry of Agriculture',
    'Joint Secretary',
    'National Level',
    ARRAY['Crop Insurance', 'Farmer Welfare', 'Agricultural Subsidies'],
    true
),
(
    'Smt. Kavitha Nair',
    'kavitha.policy@demo.com',
    '+91-8765432107',
    'policymaker',
    12.9716,
    77.5946,
    'Department of Agriculture, Bangalore',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Department of Agriculture',
    'Director',
    'State Level - Karnataka',
    ARRAY['Water Management', 'Sustainable Farming', 'Rural Development'],
    true
);

-- Create issues table to track agricultural problems
CREATE TABLE IF NOT EXISTS agricultural_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    issue_type TEXT NOT NULL CHECK (issue_type IN ('pest', 'disease', 'nutrient', 'weather', 'irrigation', 'soil', 'other')),
    crop_affected TEXT,
    severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')) DEFAULT 'medium',
    description TEXT NOT NULL,
    location_latitude DECIMAL(10, 8),
    location_longitude DECIMAL(11, 8),
    status TEXT CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')) DEFAULT 'open',
    advisor_id UUID REFERENCES users(id),
    solution_provided TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE
);

-- Enable RLS for issues table
ALTER TABLE agricultural_issues ENABLE ROW LEVEL SECURITY;

-- Policies for issues table
CREATE POLICY "Users can view own issues" ON agricultural_issues
    FOR SELECT USING (user_id IN (
        SELECT id FROM users WHERE auth_id = auth.uid()
    ));

CREATE POLICY "Users can create own issues" ON agricultural_issues
    FOR INSERT WITH CHECK (user_id IN (
        SELECT id FROM users WHERE auth_id = auth.uid()
    ));

CREATE POLICY "Advisors can view all issues" ON agricultural_issues
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = auth.uid() 
            AND role = 'advisor'
        )
    );

CREATE POLICY "Advisors can update issues" ON agricultural_issues
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = auth.uid() 
            AND role = 'advisor'
        )
    );

-- Create trigger for issues updated_at
CREATE TRIGGER update_issues_updated_at 
    BEFORE UPDATE ON agricultural_issues 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insert demo agricultural issues
INSERT INTO agricultural_issues (
    user_id,
    issue_type,
    crop_affected,
    severity,
    description,
    location_latitude,
    location_longitude,
    status,
    advisor_id
) VALUES 
-- Issues for Rajesh Kumar
(
    (SELECT id FROM users WHERE email = 'rajesh.kumar@demo.com'),
    'pest',
    'Wheat',
    'high',
    'Yellow rust disease affecting wheat crop. Leaves showing yellow spots and powdery growth.',
    28.6139,
    77.2090,
    'open',
    (SELECT id FROM users WHERE email = 'dr.suresh.kumar@demo.com')
),
(
    (SELECT id FROM users WHERE email = 'rajesh.kumar@demo.com'),
    'nutrient',
    'Mustard',
    'medium',
    'Nitrogen deficiency in mustard crop. Leaves turning pale yellow.',
    28.6139,
    77.2090,
    'in_progress',
    (SELECT id FROM users WHERE email = 'dr.suresh.kumar@demo.com')
),

-- Issues for Lakshmi Devi
(
    (SELECT id FROM users WHERE email = 'lakshmi.devi@demo.com'),
    'irrigation',
    'Rice',
    'critical',
    'Drought conditions affecting rice crop. Need advice on water management.',
    12.9716,
    77.5946,
    'open',
    (SELECT id FROM users WHERE email = 'dr.priya.desai@demo.com')
),
(
    (SELECT id FROM users WHERE email = 'lakshmi.devi@demo.com'),
    'disease',
    'Vegetables',
    'medium',
    'Bacterial wilt in tomato plants. Plants wilting despite adequate water.',
    12.9716,
    77.5946,
    'resolved',
    (SELECT id FROM users WHERE email = 'dr.priya.desai@demo.com')
),

-- Issues for Mohammed Ali
(
    (SELECT id FROM users WHERE email = 'mohammed.ali@demo.com'),
    'pest',
    'Cotton',
    'high',
    'Pink bollworm infestation in cotton crop. Damaging bolls and reducing yield.',
    19.0760,
    72.8777,
    'open',
    (SELECT id FROM users WHERE email = 'dr.rajesh.patel@demo.com')
),

-- Issues for Priya Sharma
(
    (SELECT id FROM users WHERE email = 'priya.sharma@demo.com'),
    'soil',
    'Jute',
    'medium',
    'Soil salinity affecting jute crop growth. Need soil improvement techniques.',
    22.5726,
    88.3639,
    'open',
    NULL
),

-- Issues for Gurpreet Singh
(
    (SELECT id FROM users WHERE email = 'gurpreet.singh@demo.com'),
    'weather',
    'Wheat',
    'high',
    'Untimely rains affecting wheat harvest. Need advice on harvesting timing.',
    31.6340,
    74.8723,
    'in_progress',
    (SELECT id FROM users WHERE email = 'dr.suresh.kumar@demo.com')
),

-- Issues for Anita Patel
(
    (SELECT id FROM users WHERE email = 'anita.patel@demo.com'),
    'nutrient',
    'Groundnut',
    'low',
    'Phosphorus deficiency in groundnut crop. Need fertilizer recommendations.',
    23.0225,
    72.5714,
    'resolved',
    (SELECT id FROM users WHERE email = 'dr.rajesh.patel@demo.com')
),

-- Issues for Venkatesh Reddy
(
    (SELECT id FROM users WHERE email = 'venkatesh.reddy@demo.com'),
    'disease',
    'Rice',
    'critical',
    'Blast disease in rice crop. Severe damage to panicles and grains.',
    17.3850,
    78.4867,
    'open',
    (SELECT id FROM users WHERE email = 'dr.priya.desai@demo.com')
),

-- Issues for Sunita Verma
(
    (SELECT id FROM users WHERE email = 'sunita.verma@demo.com'),
    'irrigation',
    'Sugarcane',
    'medium',
    'Water logging in sugarcane field. Need drainage solutions.',
    26.8467,
    80.9462,
    'open',
    NULL
),

-- Issues for Abdul Rahman
(
    (SELECT id FROM users WHERE email = 'abdul.rahman@demo.com'),
    'pest',
    'Coconut',
    'high',
    'Rhinoceros beetle attacking coconut palms. Damaging growing points.',
    10.8505,
    76.2711,
    'in_progress',
    (SELECT id FROM users WHERE email = 'dr.priya.desai@demo.com')
),

-- Issues for Meera Iyer
(
    (SELECT id FROM users WHERE email = 'meera.iyer@demo.com'),
    'disease',
    'Pulses',
    'medium',
    'Root rot in pulse crops. Plants showing stunted growth.',
    13.0827,
    80.2707,
    'open',
    (SELECT id FROM users WHERE email = 'dr.rajesh.patel@demo.com')
);

-- Create chat_messages table for storing chat history
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    message_text TEXT NOT NULL,
    sender_type TEXT CHECK (sender_type IN ('user', 'ai', 'advisor')) NOT NULL,
    message_type TEXT CHECK (message_type IN ('text', 'image', 'voice', 'location')) DEFAULT 'text',
    media_url TEXT,
    location_latitude DECIMAL(10, 8),
    location_longitude DECIMAL(11, 8),
    location_address TEXT,
    ai_response_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for chat_messages table
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Policies for chat_messages table
CREATE POLICY "Users can view own messages" ON chat_messages
    FOR SELECT USING (user_id IN (
        SELECT id FROM users WHERE auth_id = auth.uid()
    ));

CREATE POLICY "Users can create own messages" ON chat_messages
    FOR INSERT WITH CHECK (user_id IN (
        SELECT id FROM users WHERE auth_id = auth.uid()
    ));

CREATE POLICY "Advisors can view all messages" ON chat_messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = auth.uid() 
            AND role = 'advisor'
        )
    );

-- Create indexes for better performance
CREATE INDEX idx_users_auth_id ON users(auth_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_location ON users(location_latitude, location_longitude);
CREATE INDEX idx_issues_user_id ON agricultural_issues(user_id);
CREATE INDEX idx_issues_status ON agricultural_issues(status);
CREATE INDEX idx_issues_type ON agricultural_issues(issue_type);
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);

-- Create view for user statistics
CREATE VIEW user_statistics AS
SELECT 
    u.id,
    u.full_name,
    u.role,
    u.farm_size_hectares,
    u.primary_crop,
    u.experience_years,
    COUNT(ai.id) as total_issues,
    COUNT(CASE WHEN ai.status = 'open' THEN 1 END) as open_issues,
    COUNT(CASE WHEN ai.status = 'resolved' THEN 1 END) as resolved_issues,
    COUNT(cm.id) as total_messages
FROM users u
LEFT JOIN agricultural_issues ai ON u.id = ai.user_id
LEFT JOIN chat_messages cm ON u.id = cm.user_id
GROUP BY u.id, u.full_name, u.role, u.farm_size_hectares, u.primary_crop, u.experience_years;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- Add missing SQL functions for community service
CREATE OR REPLACE FUNCTION increment_post_like_count(post_uuid UUID)
RETURNS void AS $$
BEGIN
    UPDATE community_posts 
    SET like_count = like_count + 1 
    WHERE id = post_uuid;
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION decrement_post_like_count(post_uuid UUID)
RETURNS void AS $$
BEGIN
    UPDATE community_posts 
    SET like_count = GREATEST(like_count - 1, 0) 
    WHERE id = post_uuid;
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION increment_response_helpful_count(response_uuid UUID)
RETURNS void AS $$
BEGIN
    UPDATE community_responses 
    SET helpful_count = helpful_count + 1 
    WHERE id = response_uuid;
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION decrement_response_helpful_count(response_uuid UUID)
RETURNS void AS $$
BEGIN
    UPDATE community_responses 
    SET helpful_count = GREATEST(helpful_count - 1, 0) 
    WHERE id = response_uuid;
END;
$$ language 'plpgsql';

-- Create community_posts table
CREATE TABLE IF NOT EXISTS community_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  author_name TEXT NOT NULL,
  author_email TEXT,
  author_phone TEXT,
  category TEXT NOT NULL,
  tags TEXT[],
  location TEXT,
  crop_type TEXT,
  urgency_level TEXT DEFAULT 'medium' CHECK (urgency_level IN ('low', 'medium', 'high')),
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'resolved', 'closed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  view_count INTEGER DEFAULT 0,
  like_count INTEGER DEFAULT 0,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create community_responses table
CREATE TABLE IF NOT EXISTS community_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE,
  responder_name TEXT NOT NULL,
  responder_email TEXT,
  responder_type TEXT DEFAULT 'user' CHECK (responder_type IN ('user', 'expert', 'farmer')),
  response_content TEXT NOT NULL,
  helpful_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_verified BOOLEAN DEFAULT FALSE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create post_attachments table
CREATE TABLE IF NOT EXISTS post_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE,
  file_path TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_size BIGINT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_interactions table for likes and helpful votes
CREATE TABLE IF NOT EXISTS user_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE,
  response_id UUID REFERENCES community_responses(id) ON DELETE CASCADE,
  interaction_type TEXT NOT NULL CHECK (interaction_type IN ('like', 'helpful', 'view')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, post_id, interaction_type),
  UNIQUE(user_id, response_id, interaction_type)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_community_posts_category ON community_posts(category);
CREATE INDEX IF NOT EXISTS idx_community_posts_status ON community_posts(status);
CREATE INDEX IF NOT EXISTS idx_community_posts_created_at ON community_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_community_responses_post_id ON community_responses(post_id);
CREATE INDEX IF NOT EXISTS idx_user_interactions_user_id ON user_interactions(user_id);

-- Enable Row Level Security (RLS)
ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_interactions ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Community posts policies
DROP POLICY IF EXISTS "Anyone can view community posts" ON community_posts;
CREATE POLICY "Anyone can view community posts" ON community_posts FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated users can create posts" ON community_posts;
CREATE POLICY "Authenticated users can create posts" ON community_posts FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Users can update their own posts" ON community_posts;
CREATE POLICY "Users can update their own posts" ON community_posts FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own posts" ON community_posts;
CREATE POLICY "Users can delete their own posts" ON community_posts FOR DELETE USING (auth.uid() = user_id);

-- Community responses policies
DROP POLICY IF EXISTS "Anyone can view responses" ON community_responses;
CREATE POLICY "Anyone can view responses" ON community_responses FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated users can create responses" ON community_responses;
CREATE POLICY "Authenticated users can create responses" ON community_responses FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Users can update their own responses" ON community_responses;
CREATE POLICY "Users can update their own responses" ON community_responses FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own responses" ON community_responses;
CREATE POLICY "Users can delete their own responses" ON community_responses FOR DELETE USING (auth.uid() = user_id);

-- Post attachments policies
DROP POLICY IF EXISTS "Anyone can view attachments" ON post_attachments;
CREATE POLICY "Anyone can view attachments" ON post_attachments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can create attachments for their posts" ON post_attachments;
CREATE POLICY "Users can create attachments for their posts" ON post_attachments FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_posts WHERE id = post_id AND user_id = auth.uid())
);

-- User interactions policies
DROP POLICY IF EXISTS "Anyone can view interactions" ON user_interactions;
CREATE POLICY "Anyone can view interactions" ON user_interactions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated users can manage their interactions" ON user_interactions;
CREATE POLICY "Authenticated users can manage their interactions" ON user_interactions FOR ALL USING (auth.uid() = user_id);

-- Create triggers for updated_at
CREATE TRIGGER update_community_posts_updated_at BEFORE UPDATE ON community_posts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_community_responses_updated_at BEFORE UPDATE ON community_responses 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to increment view count
CREATE OR REPLACE FUNCTION increment_post_view_count(post_uuid UUID)
RETURNS void AS $$
BEGIN
    UPDATE community_posts 
    SET view_count = view_count + 1 
    WHERE id = post_uuid;
END;
$$ language 'plpgsql';

-- Create function to get popular posts
CREATE OR REPLACE FUNCTION get_popular_posts(days_limit INTEGER DEFAULT 7)
RETURNS TABLE (
    id UUID,
    title TEXT,
    content TEXT,
    author_name TEXT,
    category TEXT,
    view_count INTEGER,
    like_count INTEGER,
    response_count BIGINT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.title,
        p.content,
        p.author_name,
        p.category,
        p.view_count,
        p.like_count,
        COUNT(r.id) as response_count,
        p.created_at
    FROM community_posts p
    LEFT JOIN community_responses r ON p.id = r.post_id
    WHERE p.created_at >= NOW() - INTERVAL '%s days' % days_limit
    GROUP BY p.id, p.title, p.content, p.author_name, p.category, p.view_count, p.like_count, p.created_at
    ORDER BY (p.view_count + p.like_count + COUNT(r.id)) DESC;
END;
$$ language 'plpgsql';
