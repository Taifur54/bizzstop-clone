// Mobile Menu Toggle
document.addEventListener('DOMContentLoaded', function() {
    const mobileMenuToggle = document.getElementById('mobileMenuToggle');
    const navMenu = document.getElementById('navMenu');
    
    if (mobileMenuToggle && navMenu) {
        mobileMenuToggle.addEventListener('click', function() {
            navMenu.classList.toggle('active');
        });

        // Close menu when clicking outside
        document.addEventListener('click', function(event) {
            if (!mobileMenuToggle.contains(event.target) && !navMenu.contains(event.target)) {
                navMenu.classList.remove('active');
            }
        });
    }
});

// Form submissions for join forms
document.addEventListener('DOMContentLoaded', function() {
    const joinForm = document.getElementById('joinForm');
    const footerForm = document.getElementById('footerForm');

    if (joinForm) {
        joinForm.addEventListener('submit', handleJoinSubmit);
    }

    if (footerForm) {
        footerForm.addEventListener('submit', handleJoinSubmit);
    }
});

async function handleJoinSubmit(e) {
    e.preventDefault();
    const input = e.target.querySelector('input');
    const name = input.value.trim();

    if (!name) {
        alert('Please enter your name');
        return;
    }

    // Check if user is logged in
    const user = await checkAuth();
    
    if (!user) {
        // Not logged in - redirect to signup with name pre-filled
        sessionStorage.setItem('joinName', name);
        window.location.href = '/sign-uplogin.html';
        return;
    }

    // User is logged in - could save interest or redirect
    alert('Thank you for your interest, ' + name + '! We\'ll be in touch.');
    input.value = '';
}

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Auto-hide messages after 5 seconds
function autoHideMessage() {
    const messages = document.querySelectorAll('.message.show');
    messages.forEach(msg => {
        setTimeout(() => {
            msg.classList.remove('show');
        }, 5000);
    });
}

// Call on page load
document.addEventListener('DOMContentLoaded', autoHideMessage);
