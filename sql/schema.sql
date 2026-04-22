-- ================================================================
-- GREENBIN CONNECT — COMPLETE SUPABASE SETUP
-- Run this entire file in Supabase → SQL Editor
-- Project: greenbin.afrikspark.tech
-- ================================================================


-- ================================================================
-- 1. PICKUP REQUESTS
-- ================================================================
create table if not exists pickup_requests (
  id uuid default gen_random_uuid() primary key,
  first_name text not null,
  last_name text not null,
  phone text not null,
  community text not null,
  address text,
  waste_type text default 'mixed',
  preferred_day text,
  status text default 'pending',
  notes text,
  created_at timestamptz default now()
);
alter table pickup_requests enable row level security;
create policy "Anyone can submit pickup request"
  on pickup_requests for insert with check (true);
create policy "Authenticated team can view pickup requests"
  on pickup_requests for select using (auth.role() = 'authenticated');
create policy "Authenticated team can update pickup status"
  on pickup_requests for update using (auth.role() = 'authenticated');


-- ================================================================
-- 2. CONTACT MESSAGES
-- ================================================================
create table if not exists contact_messages (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  contact text not null,
  message text not null,
  is_read boolean default false,
  created_at timestamptz default now()
);
alter table contact_messages enable row level security;
create policy "Anyone can send contact message"
  on contact_messages for insert with check (true);
create policy "Authenticated team can view messages"
  on contact_messages for select using (auth.role() = 'authenticated');
create policy "Authenticated team can mark messages read"
  on contact_messages for update using (auth.role() = 'authenticated');


-- ================================================================
-- 3. PARTNERS
-- Add partners from Supabase dashboard — logo, name, website
-- ================================================================
create table if not exists partners (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  logo_url text,
  website_url text,
  sort_order int default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);
alter table partners enable row level security;
create policy "Anyone can view active partners"
  on partners for select using (is_active = true);
create policy "Authenticated team can manage partners"
  on partners for all using (auth.role() = 'authenticated');

-- Seed first partner
insert into partners (name, sort_order)
values ('Freetown Innovations Lab', 1);


-- ================================================================
-- 4. WASTE REPORTS (Mobile App)
-- ================================================================
create table if not exists reports (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id),
  report_type text not null,
  description text,
  image_url text,
  voice_url text,
  latitude float8,
  longitude float8,
  location_address text,
  waste_category text,
  risk_level text default 'medium',
  ai_analysis text,
  status text default 'pending',
  is_verified boolean default false,
  created_at timestamptz default now()
);
alter table reports enable row level security;
create policy "Anyone can submit a report"
  on reports for insert with check (true);
create policy "Anyone can view reports"
  on reports for select using (true);
create policy "Users can update own reports"
  on reports for update using (auth.uid() = user_id);
create policy "Authenticated team can update any report"
  on reports for update using (auth.role() = 'authenticated');


-- ================================================================
-- 5. USER PROFILES (Mobile App)
-- ================================================================
create table if not exists profiles (
  id uuid references auth.users(id) primary key,
  full_name text,
  phone text,
  community text,
  created_at timestamptz default now()
);
alter table profiles enable row level security;
create policy "Users can view own profile"
  on profiles for select using (auth.uid() = id);
create policy "Users can update own profile"
  on profiles for update using (auth.uid() = id);
create policy "Users can insert own profile"
  on profiles for insert with check (auth.uid() = id);


-- ================================================================
-- 6. STORAGE BUCKETS
-- ================================================================
insert into storage.buckets (id, name, public)
values ('site-images', 'site-images', true) on conflict do nothing;

insert into storage.buckets (id, name, public)
values ('partner-logos', 'partner-logos', true) on conflict do nothing;

insert into storage.buckets (id, name, public)
values ('report-images', 'report-images', true) on conflict do nothing;

insert into storage.buckets (id, name, public)
values ('report-voice', 'report-voice', true) on conflict do nothing;


-- ================================================================
-- 7. STORAGE POLICIES
-- ================================================================

-- site-images
create policy "Public can view site images"
  on storage.objects for select using (bucket_id = 'site-images');
create policy "Authenticated can upload site images"
  on storage.objects for insert
  with check (bucket_id = 'site-images' and auth.role() = 'authenticated');
create policy "Authenticated can delete site images"
  on storage.objects for delete
  using (bucket_id = 'site-images' and auth.role() = 'authenticated');

-- partner-logos
create policy "Public can view partner logos"
  on storage.objects for select using (bucket_id = 'partner-logos');
create policy "Authenticated can upload partner logos"
  on storage.objects for insert
  with check (bucket_id = 'partner-logos' and auth.role() = 'authenticated');
create policy "Authenticated can delete partner logos"
  on storage.objects for delete
  using (bucket_id = 'partner-logos' and auth.role() = 'authenticated');

-- report-images
create policy "Public can view report images"
  on storage.objects for select using (bucket_id = 'report-images');
create policy "Anyone can upload report images"
  on storage.objects for insert with check (bucket_id = 'report-images');

-- report-voice
create policy "Public can view report voice"
  on storage.objects for select using (bucket_id = 'report-voice');
create policy "Anyone can upload report voice"
  on storage.objects for insert with check (bucket_id = 'report-voice');


-- ================================================================
-- HOW TO ADD A PARTNER:
--
-- Step 1: Upload their logo to Storage → partner-logos bucket
-- Step 2: Copy the public URL of the uploaded logo
-- Step 3: Run this query:
--
-- INSERT INTO partners (name, logo_url, website_url, sort_order)
-- VALUES (
--   'Partner Name',
--   'https://kbkegtethadwpgjjujhg.supabase.co/storage/v1/object/public/partner-logos/logo.png',
--   'https://theirwebsite.com',  -- or NULL if no website
--   2  -- order on the page (1 = first)
-- );
--
-- HOW TO ADD SLIDESHOW IMAGES:
-- Go to Storage → site-images → upload Freetown photos
-- They appear automatically on the website
-- ================================================================
UPDATE partners SET logo_url = 'PASTE_URL_HERE' WHERE name = 'Freetown Innovations Lab';