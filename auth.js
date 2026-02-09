// Supabase Configuration
const SUPABASE_URL = 'https://cbuwojqykvivbojqikrj.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNidXdvanF5a3ZpdmJvanFpa3JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0OTMzNDgsImV4cCI6MjA4NjA2OTM0OH0.gvEqUiPx_XhSxWXBOus1JhEUDlc2wXgNuJhQOexiXsk';
const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

// Load User Status Bar
async function loadUserStatus() {
    const statusContent = document.getElementById('user-status-content');
    if (!statusContent) return;
    
    const { data: { user } } = await supabaseClient.auth.getUser();
    
    if (user) {
        const { data: profile } = await supabaseClient
            .from('profiles')
            .select('email, reveals_remaining')
            .eq('id', user.id)
            .single();
        
        const reveals = profile ? profile.reveals_remaining : 0;
        const email = profile ? profile.email : user.email;
        
        statusContent.innerHTML = `
            <span style="color: #666;">👤 ${email}</span>
            <span style="color: #8a728c; font-weight: bold;">Reveals: ${reveals}</span>
            <button onclick="handleStatusLogout()" style="background: #dc3545; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer; font-size: 13px; font-weight: bold;">Logout</button>
        `;
    } else {
        statusContent.innerHTML = `
            <span style="color: #666;">Not logged in</span>
            <a href="/sign-uplogin.html" style="background: #8a728c; color: white; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-size: 13px; font-weight: bold;">Login</a>
        `;
    }
}

// Logout Function
window.handleStatusLogout = async function() {
    await supabaseClient.auth.signOut();
    window.location.href = '/';
};

// Check if user is authenticated (for protected pages)
async function checkAuth() {
    const { data: { user } } = await supabaseClient.auth.getUser();
    return user;
}

// Redirect to login if not authenticated
async function requireAuth() {
    const user = await checkAuth();
    if (!user) {
        window.location.href = '/sign-uplogin.html';
        return null;
    }
    return user;
}

// Get user profile
async function getUserProfile(userId) {
    const { data, error } = await supabaseClient
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();
    
    if (error) {
        console.error('Error fetching profile:', error);
        return null;
    }
    return data;
}

// Update reveals remaining
async function updateReveals(userId, revealsRemaining) {
    const { data, error } = await supabaseClient
        .from('profiles')
        .update({ reveals_remaining: revealsRemaining })
        .eq('id', userId);
    
    if (error) {
        console.error('Error updating reveals:', error);
        return false;
    }
    return true;
}

// Initialize auth on page load
document.addEventListener('DOMContentLoaded', function() {
    loadUserStatus();
});
