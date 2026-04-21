-- GreenBin Connect Database Schema

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- hero_images table
CREATE TABLE hero_images (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    image_url TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- partners table
CREATE TABLE partners (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    logo_url TEXT NOT NULL,
    website_url TEXT NOT NULL,
    description TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- faqs table
CREATE TABLE faqs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- waitlist_submissions table
CREATE TABLE waitlist_submissions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    full_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT NOT NULL,
    user_type TEXT NOT NULL,
    area TEXT,
    bins_needed INTEGER,
    service_interest TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default FAQs
INSERT INTO faqs (question, answer, sort_order) VALUES
('What is GreenBin Connect?', 'GreenBin Connect is a smart platform that helps citizens report waste issues quickly using photos, voice, or text.', 1),
('Is the app free to use?', 'Yes. Citizens can use GreenBin Connect for free.', 2),
('How do I report waste?', 'You can report by uploading a photo, recording voice, or typing details.', 3),
('Which areas will launch first?', 'Initial launch focuses on Freetown.', 4),
('Can organizations partner with GreenBin Connect?', 'Yes. NGOs, schools, councils, and businesses can partner with us.', 5),
('How do I join the waitlist?', 'Use the Join Waitlist form below.', 6);

-- Row Level Security Policies

-- hero_images: Public read access
ALTER TABLE hero_images ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for hero_images" ON hero_images
    FOR SELECT USING (active = true);

-- partners: Public read access
ALTER TABLE partners ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for partners" ON partners
    FOR SELECT USING (active = true);

-- faqs: Public read access
ALTER TABLE faqs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for faqs" ON faqs
    FOR SELECT USING (active = true);

-- waitlist_submissions: Public insert only
ALTER TABLE waitlist_submissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public insert access for waitlist_submissions" ON waitlist_submissions
    FOR INSERT WITH CHECK (true);

-- Storage Buckets

-- Create hero-images bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('hero-images', 'hero-images', true);

-- Create partner-logos bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('partner-logos', 'partner-logos', true);

-- Storage Policies

-- hero-images bucket: Authenticated admin upload access
CREATE POLICY "Authenticated users can upload hero images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'hero-images' AND auth.role() = 'authenticated');

CREATE POLICY "Public read access for hero images" ON storage.objects
    FOR SELECT USING (bucket_id = 'hero-images');

-- partner-logos bucket: Authenticated admin upload access
CREATE POLICY "Authenticated users can upload partner logos" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'partner-logos' AND auth.role() = 'authenticated');

CREATE POLICY "Public read access for partner logos" ON storage.objects
    FOR SELECT USING (bucket_id = 'partner-logos');