-- Updated Database Setup for Agri Sahayak with Role-Based Structure
-- Run this in your Supabase SQL Editor

-- Drop existing tables if they exist
DROP TABLE IF EXISTS agricultural_issues CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create users table with comprehensive fields for all roles
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    role TEXT CHECK (role IN ('farmer', 'advisor', 'policymaker', 'admin')) DEFAULT 'farmer',
    location_latitude DECIMAL(10, 8),
    location_longitude DECIMAL(11, 8),
    location_address TEXT,
    is_verified BOOLEAN DEFAULT false,
    profile_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create farmer_profiles table for farmer-specific information
CREATE TABLE IF NOT EXISTS farmer_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    farm_size_hectares DECIMAL(8, 2),
    primary_crop TEXT,
    secondary_crops TEXT[],
    soil_type TEXT,
    irrigation_type TEXT CHECK (irrigation_type IN ('drip', 'sprinkler', 'flood', 'manual', 'none')),
    experience_years INTEGER DEFAULT 0,
    total_issues_submitted INTEGER DEFAULT 0,
    total_issues_resolved INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create advisor_profiles table for advisor-specific information
CREATE TABLE IF NOT EXISTS advisor_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    specialization TEXT[],
    qualification TEXT,
    years_of_experience INTEGER DEFAULT 0,
    total_issues_handled INTEGER DEFAULT 0,
    total_issues_resolved INTEGER DEFAULT 0,
    rating DECIMAL(3, 2) DEFAULT 0.0,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create policymaker_profiles table for policymaker-specific information
CREATE TABLE IF NOT EXISTS policymaker_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    department TEXT,
    designation TEXT,
    jurisdiction TEXT,
    policy_areas TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create agricultural_issues table with enhanced fields
CREATE TABLE IF NOT EXISTS agricultural_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    issue_type TEXT NOT NULL CHECK (issue_type IN ('pest', 'disease', 'nutrient', 'weather', 'irrigation', 'soil', 'other')),
    severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')) DEFAULT 'medium',
    status TEXT NOT NULL CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')) DEFAULT 'open',
    crop_type TEXT,
    farm_size TEXT,
    location_address TEXT,
    location_latitude DECIMAL(10, 8),
    location_longitude DECIMAL(11, 8),
    assigned_advisor_id UUID REFERENCES users(id),
    resolution_notes TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create chat_messages table for communication
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    message_type TEXT CHECK (message_type IN ('text', 'image', 'voice', 'location')) DEFAULT 'text',
    media_url TEXT,
    location_latitude DECIMAL(10, 8),
    location_longitude DECIMAL(11, 8),
    is_ai_response BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create issue_responses table for advisor responses
CREATE TABLE IF NOT EXISTS issue_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID REFERENCES agricultural_issues(id) ON DELETE CASCADE,
    advisor_id UUID REFERENCES users(id) ON DELETE CASCADE,
    response_text TEXT NOT NULL,
    response_type TEXT CHECK (response_type IN ('advice', 'solution', 'question', 'follow_up')) DEFAULT 'advice',
    is_solution BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create analytics table for tracking metrics
CREATE TABLE IF NOT EXISTS analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_name TEXT NOT NULL,
    metric_value DECIMAL(10, 2),
    metric_unit TEXT,
    category TEXT,
    region TEXT,
    date_recorded DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE farmer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE advisor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE policymaker_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE agricultural_issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE issue_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = auth_id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = auth_id);

CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = auth_id);

CREATE POLICY "Advisors can view all user profiles" ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = auth.uid() 
            AND role = 'advisor'
        )
    );

CREATE POLICY "Policymakers can view all user profiles" ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = auth.uid() 
            AND role = 'policymaker'
        )
    );

-- RLS Policies for farmer_profiles table
CREATE POLICY "Farmers can view own profile" ON farmer_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = farmer_profiles.user_id 
            AND users.auth_id = auth.uid()
        )
    );

CREATE POLICY "Farmers can update own profile" ON farmer_profiles
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = farmer_profiles.user_id 
            AND users.auth_id = auth.uid()
        )
    );

CREATE POLICY "Advisors can view farmer profiles" ON farmer_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = auth.uid() 
            AND role = 'advisor'
        )
    );

-- RLS Policies for advisor_profiles table
CREATE POLICY "Advisors can view own profile" ON advisor_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = advisor_profiles.user_id 
            AND users.auth_id = auth.uid()
        )
    );

CREATE POLICY "Advisors can update own profile" ON advisor_profiles
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = advisor_profiles.user_id 
            AND users.auth_id = auth.uid()
        )
    );

CREATE POLICY "All users can view advisor profiles" ON advisor_profiles
    FOR SELECT USING (true);

-- RLS Policies for policymaker_profiles table
CREATE POLICY "Policymakers can view own profile" ON policymaker_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = policymaker_profiles.user_id 
            AND users.auth_id = auth.uid()
        )
    );

CREATE POLICY "Policymakers can update own profile" ON policymaker_profiles
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = policymaker_profiles.user_id 
            AND users.auth_id = auth.uid()
        )
    );

-- RLS Policies for agricultural_issues table
CREATE POLICY "Users can view own issues" ON agricultural_issues
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = agricultural_issues.user_id 
            AND users.auth_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own issues" ON agricultural_issues
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = agricultural_issues.user_id 
            AND users.auth_id = auth.uid()
        )
    );

CREATE POLICY "Advisors can view all issues" ON agricultural_issues
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = auth.uid() 
            AND role = 'advisor'
        )
    );

CREATE POLICY "Advisors can update assigned issues" ON agricultural_issues
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = auth.uid() 
            AND role = 'advisor'
        )
    );

CREATE POLICY "Policymakers can view all issues" ON agricultural_issues
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = auth.uid() 
            AND role = 'policymaker'
        )
    );

-- RLS Policies for chat_messages table
CREATE POLICY "Users can view own messages" ON chat_messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = chat_messages.user_id 
            AND users.auth_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own messages" ON chat_messages
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = chat_messages.user_id 
            AND users.auth_id = auth.uid()
        )
    );

-- RLS Policies for issue_responses table
CREATE POLICY "Users can view responses to their issues" ON issue_responses
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM agricultural_issues 
            JOIN users ON users.id = agricultural_issues.user_id
            WHERE agricultural_issues.id = issue_responses.issue_id 
            AND users.auth_id = auth.uid()
        )
    );

CREATE POLICY "Advisors can insert responses" ON issue_responses
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = issue_responses.advisor_id 
            AND users.auth_id = auth.uid()
            AND role = 'advisor'
        )
    );

-- RLS Policies for analytics table
CREATE POLICY "Advisors can view analytics" ON analytics
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = auth.uid() 
            AND role = 'advisor'
        )
    );

CREATE POLICY "Policymakers can view analytics" ON analytics
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = auth.uid() 
            AND role = 'policymaker'
        )
    );

-- Create triggers for updated_at columns
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_farmer_profiles_updated_at 
    BEFORE UPDATE ON farmer_profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_advisor_profiles_updated_at 
    BEFORE UPDATE ON advisor_profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_policymaker_profiles_updated_at 
    BEFORE UPDATE ON policymaker_profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agricultural_issues_updated_at 
    BEFORE UPDATE ON agricultural_issues 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create function to handle new user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert into users table
    INSERT INTO users (auth_id, full_name, email, role)
    VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name', NEW.email, NEW.raw_user_meta_data->>'role');
    
    -- Insert into role-specific profile table
    IF NEW.raw_user_meta_data->>'role' = 'farmer' THEN
        INSERT INTO farmer_profiles (user_id)
        SELECT id FROM users WHERE auth_id = NEW.id;
    ELSIF NEW.raw_user_meta_data->>'role' = 'advisor' THEN
        INSERT INTO advisor_profiles (user_id)
        SELECT id FROM users WHERE auth_id = NEW.id;
    ELSIF NEW.raw_user_meta_data->>'role' = 'policymaker' THEN
        INSERT INTO policymaker_profiles (user_id)
        SELECT id FROM users WHERE auth_id = NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for new user registration
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Insert demo users with different roles
INSERT INTO users (
    full_name, 
    email, 
    phone, 
    role, 
    location_latitude, 
    location_longitude, 
    location_address,
    is_verified
) VALUES 
-- Demo Farmers
('Rajesh Kumar', 'rajesh.kumar@demo.com', '+91-9876543210', 'farmer', 28.6139, 77.2090, 'Village: Mehrauli, New Delhi, India', true),
('Lakshmi Devi', 'lakshmi.devi@demo.com', '+91-8765432109', 'farmer', 12.9716, 77.5946, 'Village: Hebbal, Bangalore, Karnataka, India', true),
('Mohammed Ali', 'mohammed.ali@demo.com', '+91-7654321098', 'farmer', 19.0760, 72.8777, 'Village: Thane, Mumbai, Maharashtra, India', true),
('Priya Sharma', 'priya.sharma@demo.com', '+91-6543210987', 'farmer', 22.5726, 88.3639, 'Village: Howrah, Kolkata, West Bengal, India', false),
('Gurpreet Singh', 'gurpreet.singh@demo.com', '+91-5432109876', 'farmer', 31.6340, 74.8723, 'Village: Amritsar, Punjab, India', true),
('Anita Patel', 'anita.patel@demo.com', '+91-4321098765', 'farmer', 23.0225, 72.5714, 'Village: Gandhinagar, Gujarat, India', true),
('Venkatesh Reddy', 'venkatesh.reddy@demo.com', '+91-3210987654', 'farmer', 17.3850, 78.4867, 'Village: Secunderabad, Hyderabad, Telangana, India', true),
('Sunita Verma', 'sunita.verma@demo.com', '+91-2109876543', 'farmer', 26.8467, 80.9462, 'Village: Lucknow, Uttar Pradesh, India', false),
('Abdul Rahman', 'abdul.rahman@demo.com', '+91-1098765432', 'farmer', 10.8505, 76.2711, 'Village: Thrissur, Kerala, India', true),
('Meera Iyer', 'meera.iyer@demo.com', '+91-0987654321', 'farmer', 13.0827, 80.2707, 'Village: Chennai, Tamil Nadu, India', true),

-- Demo Advisors
('Dr. Suresh Kumar', 'dr.suresh.kumar@demo.com', '+91-9876543211', 'advisor', 28.6139, 77.2090, 'Agricultural University, New Delhi, India', true),
('Dr. Priya Desai', 'dr.priya.desai@demo.com', '+91-8765432108', 'advisor', 12.9716, 77.5946, 'Karnataka Agricultural University, Bangalore, India', true),
('Dr. Rajesh Patel', 'dr.rajesh.patel@demo.com', '+91-7654321097', 'advisor', 19.0760, 72.8777, 'Maharashtra Agricultural University, Mumbai, India', true),

-- Demo Policymakers
('Shri Amit Shah', 'amit.shah@demo.com', '+91-9876543212', 'policymaker', 28.6139, 77.2090, 'Ministry of Agriculture, New Delhi, India', true),
('Smt. Nirmala Sitharaman', 'nirmala.sitharaman@demo.com', '+91-8765432107', 'policymaker', 12.9716, 77.5946, 'Ministry of Finance, Bangalore, India', true),
('Dr. Harsh Vardhan', 'harsh.vardhan@demo.com', '+91-7654321096', 'policymaker', 19.0760, 72.8777, 'Ministry of Science & Technology, Mumbai, India', true);

-- Insert farmer profiles
INSERT INTO farmer_profiles (user_id, farm_size_hectares, primary_crop, secondary_crops, soil_type, irrigation_type, experience_years) VALUES
((SELECT id FROM users WHERE email = 'rajesh.kumar@demo.com'), 5.5, 'Wheat', ARRAY['Mustard', 'Potato'], 'Alluvial', 'drip', 8),
((SELECT id FROM users WHERE email = 'lakshmi.devi@demo.com'), 3.2, 'Rice', ARRAY['Vegetables', 'Pulses'], 'Red Soil', 'sprinkler', 12),
((SELECT id FROM users WHERE email = 'mohammed.ali@demo.com'), 7.8, 'Cotton', ARRAY['Sugarcane', 'Groundnut'], 'Black Soil', 'flood', 15),
((SELECT id FROM users WHERE email = 'priya.sharma@demo.com'), 2.1, 'Jute', ARRAY['Rice', 'Vegetables'], 'Deltaic', 'manual', 6),
((SELECT id FROM users WHERE email = 'gurpreet.singh@demo.com'), 8.5, 'Wheat', ARRAY['Rice', 'Maize'], 'Alluvial', 'drip', 20),
((SELECT id FROM users WHERE email = 'anita.patel@demo.com'), 4.3, 'Groundnut', ARRAY['Cotton', 'Wheat'], 'Red Soil', 'sprinkler', 10),
((SELECT id FROM users WHERE email = 'venkatesh.reddy@demo.com'), 6.7, 'Rice', ARRAY['Maize', 'Pulses'], 'Red Soil', 'drip', 14),
((SELECT id FROM users WHERE email = 'sunita.verma@demo.com'), 3.9, 'Wheat', ARRAY['Rice', 'Sugarcane'], 'Alluvial', 'manual', 9),
((SELECT id FROM users WHERE email = 'abdul.rahman@demo.com'), 2.8, 'Coconut', ARRAY['Rubber', 'Spices'], 'Laterite', 'drip', 11),
((SELECT id FROM users WHERE email = 'meera.iyer@demo.com'), 5.1, 'Rice', ARRAY['Pulses', 'Vegetables'], 'Red Soil', 'sprinkler', 7);

-- Insert advisor profiles
INSERT INTO advisor_profiles (user_id, specialization, qualification, years_of_experience) VALUES
((SELECT id FROM users WHERE email = 'dr.suresh.kumar@demo.com'), ARRAY['Crop Management', 'Soil Science'], 'PhD in Agriculture', 25),
((SELECT id FROM users WHERE email = 'dr.priya.desai@demo.com'), ARRAY['Plant Pathology', 'Pest Management'], 'PhD in Plant Sciences', 18),
((SELECT id FROM users WHERE email = 'dr.rajesh.patel@demo.com'), ARRAY['Irrigation Systems', 'Water Management'], 'PhD in Agricultural Engineering', 22);

-- Insert policymaker profiles
INSERT INTO policymaker_profiles (user_id, department, designation, jurisdiction, policy_areas) VALUES
((SELECT id FROM users WHERE email = 'amit.shah@demo.com'), 'Ministry of Agriculture', 'Minister', 'National', ARRAY['Agricultural Policy', 'Farmer Welfare']),
((SELECT id FROM users WHERE email = 'nirmala.sitharaman@demo.com'), 'Ministry of Finance', 'Minister', 'National', ARRAY['Agricultural Finance', 'Subsidies']),
((SELECT id FROM users WHERE email = 'harsh.vardhan@demo.com'), 'Ministry of Science & Technology', 'Minister', 'National', ARRAY['Agricultural Research', 'Innovation']);

-- Insert demo agricultural issues
INSERT INTO agricultural_issues (user_id, title, description, issue_type, severity, crop_type, farm_size, location_address, location_latitude, location_longitude) VALUES
((SELECT id FROM users WHERE email = 'rajesh.kumar@demo.com'), 'Yellow Rust in Wheat', 'Wheat plants showing yellow spots and rust-like symptoms on leaves', 'disease', 'high', 'Wheat', '5.5 hectares', 'Village: Mehrauli, New Delhi, India', 28.6139, 77.2090),
((SELECT id FROM users WHERE email = 'lakshmi.devi@demo.com'), 'Rice Stem Borer Infestation', 'Rice plants wilting and showing holes in stems', 'pest', 'critical', 'Rice', '3.2 hectares', 'Village: Hebbal, Bangalore, Karnataka, India', 12.9716, 77.5946),
((SELECT id FROM users WHERE email = 'mohammed.ali@demo.com'), 'Cotton Nutrient Deficiency', 'Cotton leaves turning yellow and stunted growth', 'nutrient', 'medium', 'Cotton', '7.8 hectares', 'Village: Thane, Mumbai, Maharashtra, India', 19.0760, 72.8777),
((SELECT id FROM users WHERE email = 'priya.sharma@demo.com'), 'Jute Water Logging', 'Jute field flooded due to heavy rains', 'weather', 'high', 'Jute', '2.1 hectares', 'Village: Howrah, Kolkata, West Bengal, India', 22.5726, 88.3639),
((SELECT id FROM users WHERE email = 'gurpreet.singh@demo.com'), 'Wheat Irrigation Problem', 'Drip irrigation system not working properly', 'irrigation', 'medium', 'Wheat', '8.5 hectares', 'Village: Amritsar, Punjab, India', 31.6340, 74.8723),
((SELECT id FROM users WHERE email = 'anita.patel@demo.com'), 'Groundnut Soil Erosion', 'Soil being washed away from groundnut field', 'soil', 'high', 'Groundnut', '4.3 hectares', 'Village: Gandhinagar, Gujarat, India', 23.0225, 72.5714),
((SELECT id FROM users WHERE email = 'venkatesh.reddy@demo.com'), 'Rice Pest Attack', 'Unknown insects eating rice leaves', 'pest', 'critical', 'Rice', '6.7 hectares', 'Village: Secunderabad, Hyderabad, Telangana, India', 17.3850, 78.4867),
((SELECT id FROM users WHERE email = 'sunita.verma@demo.com'), 'Wheat Disease Outbreak', 'Wheat plants showing black spots and wilting', 'disease', 'high', 'Wheat', '3.9 hectares', 'Village: Lucknow, Uttar Pradesh, India', 26.8467, 80.9462),
((SELECT id FROM users WHERE email = 'abdul.rahman@demo.com'), 'Coconut Root Rot', 'Coconut trees showing signs of root disease', 'disease', 'critical', 'Coconut', '2.8 hectares', 'Village: Thrissur, Kerala, India', 10.8505, 76.2711),
((SELECT id FROM users WHERE email = 'meera.iyer@demo.com'), 'Rice Nutrient Deficiency', 'Rice plants showing pale green leaves', 'nutrient', 'medium', 'Rice', '5.1 hectares', 'Village: Chennai, Tamil Nadu, India', 13.0827, 80.2707);

-- Insert demo analytics data
INSERT INTO analytics (metric_name, metric_value, metric_unit, category, region) VALUES
('Total Farmers', 10, 'count', 'user_metrics', 'All India'),
('Total Advisors', 3, 'count', 'user_metrics', 'All India'),
('Total Policymakers', 3, 'count', 'user_metrics', 'All India'),
('Open Issues', 10, 'count', 'issue_metrics', 'All India'),
('Critical Issues', 3, 'count', 'issue_metrics', 'All India'),
('High Priority Issues', 4, 'count', 'issue_metrics', 'All India'),
('Medium Priority Issues', 3, 'count', 'issue_metrics', 'All India'),
('Average Response Time', 24, 'hours', 'performance_metrics', 'All India'),
('Issue Resolution Rate', 0, 'percentage', 'performance_metrics', 'All India');

-- Create indexes for better performance
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_location ON users(location_latitude, location_longitude);
CREATE INDEX idx_agricultural_issues_status ON agricultural_issues(status);
CREATE INDEX idx_agricultural_issues_severity ON agricultural_issues(severity);
CREATE INDEX idx_agricultural_issues_type ON agricultural_issues(issue_type);
CREATE INDEX idx_agricultural_issues_user ON agricultural_issues(user_id);
CREATE INDEX idx_chat_messages_user ON chat_messages(user_id);
CREATE INDEX idx_issue_responses_issue ON issue_responses(issue_id);

-- Create views for easier data access
CREATE OR REPLACE VIEW user_statistics AS
SELECT 
    u.role,
    COUNT(*) as total_users,
    COUNT(CASE WHEN u.is_verified = true THEN 1 END) as verified_users,
    AVG(CASE WHEN fp.experience_years IS NOT NULL THEN fp.experience_years END) as avg_experience_years
FROM users u
LEFT JOIN farmer_profiles fp ON u.id = fp.user_id
GROUP BY u.role;

CREATE OR REPLACE VIEW issue_statistics AS
SELECT 
    ai.issue_type,
    ai.severity,
    ai.status,
    COUNT(*) as count,
    AVG(EXTRACT(EPOCH FROM (NOW() - ai.created_at))/3600) as avg_age_hours
FROM agricultural_issues ai
GROUP BY ai.issue_type, ai.severity, ai.status;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
