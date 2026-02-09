# BizzStop - Business Partnership Platform

A complete recreation of your BizzStop website with full authentication, business idea posting, browsing, and contact reveal functionality.

## Features

✅ **User Authentication**
- Sign up / Login / Logout
- Password reset
- User profiles with dashboard

✅ **Business Ideas**
- Post business ideas (free for all users)
- Browse opportunities with filters
- Category and investment range filters
- Search functionality

✅ **Contact Reveal System**
- Hide contact information by default
- Users spend "reveals" to see email & phone
- Reveal credits system
- Purchase more reveals

✅ **Subscription Plans**
- Multiple subscription tiers
- One-time reveal packages
- Profile statistics

## Tech Stack

- **Frontend**: HTML, CSS, JavaScript
- **Backend**: Supabase (PostgreSQL database + Authentication)
- **Hosting**: Works with any static host (Hostinger, Netlify, Vercel, etc.)

## Database Setup

You already have Supabase configured. Make sure you have these tables:

### 1. `profiles` table
```sql
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT,
    full_name TEXT,
    reveals_remaining INTEGER DEFAULT 5,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);
```

### 2. `business_ideas` table
```sql
CREATE TABLE business_ideas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    investment_needed TEXT NOT NULL,
    description TEXT NOT NULL,
    looking_for TEXT NOT NULL,
    location TEXT NOT NULL,
    contact_phone TEXT NOT NULL,
    contact_email TEXT NOT NULL,
    status TEXT DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE business_ideas ENABLE ROW LEVEL SECURITY;

-- Create policies
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
```

### 3. `contact_reveals` table (for tracking)
```sql
CREATE TABLE contact_reveals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    business_idea_id UUID REFERENCES business_ideas(id),
    revealed_at TIMESTAMP DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE contact_reveals ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own reveals"
    ON contact_reveals FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own reveals"
    ON contact_reveals FOR INSERT
    WITH CHECK (auth.uid() = user_id);
```

## Installation Instructions

### Option 1: Upload to Hostinger (Recommended for you)

1. **Download all files** from this folder
2. **Login to Hostinger** control panel
3. **Go to File Manager**
4. Navigate to `public_html` folder
5. **Upload all files** (or create a subfolder like `public_html/bizzstop`)
6. **Access your site** at `yourdomain.com` (or `yourdomain.com/bizzstop`)

### Option 2: Test Locally First

1. **Install a local server** (XAMPP, WAMP, or Live Server VS Code extension)
2. **Copy all files** to your local server directory
3. **Open** `index.html` in browser
4. Everything should work except database features (those need Supabase)

## File Structure

```
bizzstop-clone/
├── index.html                      # Homepage
├── sign-uplogin.html               # Login/Signup page
├── post-idea.html                  # Post business idea
├── browse-opportunities.html       # Browse and reveal contacts
├── profile.html                    # User dashboard
├── about.html                      # About page
├── subscription-plans.html         # Pricing and plans
├── styles.css                      # Main stylesheet
├── auth.js                         # Authentication logic
├── script.js                       # General JavaScript
└── README.md                       # This file
```

## Configuration

Your Supabase credentials are already configured in `auth.js`:
- URL: `https://cbuwojqykvivbojqikrj.supabase.co`
- Key: Your anon key (already in the code)

**⚠️ Important**: For production, never expose your Supabase keys in client-side code for sensitive operations. The current setup is fine for the demo.

## How It Works

### 1. User Sign Up
- User creates account with email/password
- Profile is automatically created with 5 free reveals
- User can start posting ideas immediately

### 2. Posting Business Ideas
- Must be logged in
- Fill out form with idea details
- Idea appears in Browse Opportunities
- Contact info is hidden by default

### 3. Browsing & Revealing Contacts
- Anyone can browse ideas
- Filter by category, investment, location
- Click "Reveal Contact" to spend 1 credit
- Contact info (email & phone) is displayed
- Reveals are tracked in database

### 4. Managing Reveals
- View remaining reveals in status bar
- Buy more through Subscription Plans page
- One-time packages or monthly subscriptions
- (Payment integration needed for production)

## Customization

### Change Colors
Edit `styles.css` - the main color is `#8a728c`

### Change Logo
Replace the logo URL in all HTML files or upload your own to Hostinger

### Add Features
- Payment integration (Stripe, PayPal)
- Email notifications
- Advanced search
- User messaging
- Favorites/bookmarks

## Testing Checklist

✅ Sign up new account
✅ Login/logout
✅ Post a business idea
✅ Browse opportunities
✅ Reveal a contact (check reveals decrease)
✅ View profile dashboard
✅ Check mobile responsiveness

## Known Limitations (Demo Version)

- Payment processing not integrated (shows alerts instead)
- Email verification not enforced
- No email notifications
- Edit idea feature placeholder
- No admin panel

## Production Deployment

For production, you should:
1. ✅ Set up proper domain
2. ✅ Enable SSL/HTTPS
3. ⚠️ Implement payment processing
4. ⚠️ Add email notifications
5. ⚠️ Set up proper error logging
6. ⚠️ Add rate limiting
7. ⚠️ Implement proper SEO
8. ⚠️ Add Google Analytics

## Support & Questions

If you need help:
1. Check Supabase documentation: https://supabase.com/docs
2. Check browser console for errors (F12)
3. Verify database tables are created correctly
4. Make sure Supabase URL and keys are correct

## Next Steps

1. **Test locally or upload to Hostinger**
2. **Create the database tables** in Supabase
3. **Test all features** (signup, post idea, browse, reveal)
4. **Customize design** to your liking
5. **Add payment integration** when ready for production

---

**Built with ❤️ for your BizzStop platform**
