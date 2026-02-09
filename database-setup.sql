-- BizzStop Database Setup
-- Run this in your Supabase SQL Editor

-- ==============================================
-- 1. PROFILES TABLE
-- ==============================================

CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    reveals_remaining INTEGER DEFAULT 5,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;

-- Create policies for profiles
CREATE POLICY "Users can view their own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ==============================================
-- 2. BUSINESS IDEAS TABLE
-- ==============================================

CREATE TABLE IF NOT EXISTS business_ideas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    investment_needed TEXT NOT NULL,
    description TEXT NOT NULL,
    looking_for TEXT NOT NULL,
    location TEXT NOT NULL,
    contact_phone TEXT NOT NULL,
    contact_email TEXT NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'closed')),
    views_count INTEGER DEFAULT 0,
    reveals_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS business_ideas_user_id_idx ON business_ideas(user_id);
CREATE INDEX IF NOT EXISTS business_ideas_status_idx ON business_ideas(status);
CREATE INDEX IF NOT EXISTS business_ideas_category_idx ON business_ideas(category);
CREATE INDEX IF NOT EXISTS business_ideas_created_at_idx ON business_ideas(created_at DESC);

-- Enable Row Level Security
ALTER TABLE business_ideas ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can view active business ideas" ON business_ideas;
DROP POLICY IF EXISTS "Users can create business ideas" ON business_ideas;
DROP POLICY IF EXISTS "Users can update their own business ideas" ON business_ideas;
DROP POLICY IF EXISTS "Users can delete their own business ideas" ON business_ideas;

-- Create policies for business_ideas
CREATE POLICY "Anyone can view active business ideas"
    ON business_ideas FOR SELECT
    USING (status = 'active');

CREATE POLICY "Users can create business ideas"
    ON business_ideas FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own business ideas"
    ON business_ideas FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own business ideas"
    ON business_ideas FOR DELETE
    USING (auth.uid() = user_id);

-- ==============================================
-- 3. CONTACT REVEALS TABLE
-- ==============================================

CREATE TABLE IF NOT EXISTS contact_reveals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    business_idea_id UUID REFERENCES business_ideas(id) ON DELETE CASCADE NOT NULL,
    revealed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, business_idea_id) -- Prevent duplicate reveals
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS contact_reveals_user_id_idx ON contact_reveals(user_id);
CREATE INDEX IF NOT EXISTS contact_reveals_business_idea_id_idx ON contact_reveals(business_idea_id);

-- Enable Row Level Security
ALTER TABLE contact_reveals ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own reveals" ON contact_reveals;
DROP POLICY IF EXISTS "Users can insert their own reveals" ON contact_reveals;

-- Create policies for contact_reveals
CREATE POLICY "Users can view their own reveals"
    ON contact_reveals FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own reveals"
    ON contact_reveals FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ==============================================
-- 4. FUNCTIONS & TRIGGERS
-- ==============================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for profiles table
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for business_ideas table
DROP TRIGGER IF EXISTS update_business_ideas_updated_at ON business_ideas;
CREATE TRIGGER update_business_ideas_updated_at
    BEFORE UPDATE ON business_ideas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to increment reveals count when contact is revealed
CREATE OR REPLACE FUNCTION increment_reveals_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE business_ideas
    SET reveals_count = reveals_count + 1
    WHERE id = NEW.business_idea_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to increment reveals count
DROP TRIGGER IF EXISTS increment_reveals_on_reveal ON contact_reveals;
CREATE TRIGGER increment_reveals_on_reveal
    AFTER INSERT ON contact_reveals
    FOR EACH ROW
    EXECUTE FUNCTION increment_reveals_count();

-- ==============================================
-- 5. SAMPLE DATA (OPTIONAL - FOR TESTING)
-- ==============================================

-- Uncomment below to add sample business ideas for testing
/*
INSERT INTO business_ideas (user_id, title, category, investment_needed, description, looking_for, location, contact_phone, contact_email, status)
VALUES 
(
    (SELECT id FROM auth.users LIMIT 1), -- Uses first user in your database
    'Mobile Coffee Cart',
    'Food & Beverage',
    '$5,000 - $10,000',
    'Starting a mobile coffee cart business targeting office buildings and events. We have secured partnerships with local suppliers and have initial funding.',
    'Looking for someone with barista experience and customer service skills who can commit 20+ hours per week.',
    'Austin, TX',
    '+1-512-555-0123',
    'coffee@example.com',
    'active'
),
(
    (SELECT id FROM auth.users LIMIT 1),
    'E-commerce Fitness Equipment',
    'E-commerce',
    '$25,000 - $50,000',
    'Launch an online store selling premium fitness equipment. Market research shows strong demand in the home fitness sector.',
    'Partner with marketing or e-commerce background. Experience with Shopify preferred.',
    'Denver, CO',
    '+1-303-555-0456',
    'fitness@example.com',
    'active'
);
*/

-- ==============================================
-- 6. VERIFICATION QUERIES
-- ==============================================

-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'business_ideas', 'contact_reveals');

-- Check RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('profiles', 'business_ideas', 'contact_reveals');

-- Check policies
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('profiles', 'business_ideas', 'contact_reveals');

-- ==============================================
-- SETUP COMPLETE!
-- ==============================================

-- Your database is now ready to use with BizzStop.
-- Test by:
-- 1. Creating a new user account in your app
-- 2. Posting a business idea
-- 3. Revealing a contact to test the reveal system
