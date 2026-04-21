# GreenBin Connect

AI-powered waste reporting platform for Sierra Leone.

## Setup Instructions

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Environment Variables**
   - Copy `.env.local` and add your Supabase credentials:
   ```
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Database Setup**
   - Create a new Supabase project
   - Run the SQL schema from `sql/schema.sql` in your Supabase SQL editor
   - This will create all tables, policies, and storage buckets

4. **Storage Setup**
   - Upload hero images to the `hero-images` bucket
   - Upload partner logos to the `partner-logos` bucket
   - Update the `hero_images` and `partners` tables with the file URLs

5. **Development**
   ```bash
   npm run dev
   ```

6. **Production Build**
   ```bash
   npm run build
   npm start
   ```

## Admin Dashboard

Access the admin dashboard at `/admin` to:
- Upload and manage hero slider images
- Add/remove partners
- Edit FAQs
- Export waitlist submissions as CSV

## Features

- Responsive design optimized for mobile
- Auto-scrolling hero image slider
- Dynamic partners section
- Collapsible FAQ accordion
- Waitlist modal form with Supabase integration
- Admin-ready data management

## Tech Stack

- Next.js 14
- React 18
- Supabase (Database & Storage)
- Framer Motion (Animations)
- TailwindCSS (Styling)