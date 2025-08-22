// Main JavaScript file for UNISGU website
document.addEventListener('DOMContentLoaded', function() {
    initializeNavigation();
    initializeFAQ();
    initializeContactForm();
    initializeSmoothScrolling();
    initializeAnimations();
    initializeDashboardLearningPath();
});

// Navigation functionality
function initializeNavigation() {
    const mobileToggle = document.getElementById('mobileToggle');
    const navMenu = document.getElementById('navMenu');
    const header = document.getElementById('header');

    if (!header) return; // Exit if no header on page

    const openIcon = document.getElementById('menu-open-icon');
    const closeIcon = document.getElementById('menu-close-icon');
    const navLinks = document.querySelectorAll('.nav-link');

    // Mobile menu toggle
    if (mobileToggle && navMenu) {
        mobileToggle.addEventListener('click', () => {
            navMenu.classList.toggle('hidden');
            openIcon.classList.toggle('hidden');
            closeIcon.classList.toggle('hidden');
        });
    }

    // Active link highlighting
    const currentPath = window.location.pathname.replace(/\/$/, ""); // Remove trailing slash

    if (currentPath.includes('index.html') || currentPath === "") {
        // For the homepage with scrolling sections
        const sections = document.querySelectorAll('main section[id]');
        const observer = new IntersectionObserver((entries) => {
            let visibleSectionId = '';
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    visibleSectionId = entry.target.id;
                }
            });

            navLinks.forEach(link => {
                link.classList.remove('active');
                const href = link.getAttribute('href');
                if (href && href.endsWith(`#${visibleSectionId}`)) {
                    link.classList.add('active');
                }
            });

        }, { rootMargin: "-50% 0px -50% 0px" });

        sections.forEach(section => observer.observe(section));
    } else {
         // For static pages, just highlight the link in the nav
        navLinks.forEach(link => {
            const linkPath = new URL(link.href).pathname.replace(/\/$/, "");
            if (linkPath === currentPath) {
                link.classList.add('active');
            } else {
                link.classList.remove('active');
            }
        });
    }

    // Close mobile menu when clicking on a link
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
             if (navMenu && !navMenu.classList.contains('hidden')) {
                navMenu.classList.add('hidden');
                openIcon.classList.remove('hidden');
                closeIcon.classList.add('hidden');
            }
        });
    });

    // Header scroll effect
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            header.classList.add('bg-primary-navy/95', 'backdrop-blur-sm');
        } else {
            header.classList.remove('bg-primary-navy/95', 'backdrop-blur-sm');
        }
    });
}

// FAQ functionality
function initializeFAQ() {
    const faqItems = document.querySelectorAll('.faq-item');
    
    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        
        if (question) {
            question.addEventListener('click', () => {
                const isActive = item.classList.contains('active');
                
                // Close all other FAQ items for an accordion effect
                faqItems.forEach(otherItem => {
                    if (otherItem !== item) {
                        otherItem.classList.remove('active');
                    }
                });
                
                // Toggle the clicked item
                if (!isActive) {
                    item.classList.add('active');
                } else {
                    item.classList.remove('active');
                }
            });
        }
    });
}

// Contact form functionality
function initializeContactForm() {
    const contactForms = document.querySelectorAll('.contact-form');
    
    contactForms.forEach(form => {
        form.addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const submitButton = form.querySelector('button[type="submit"]');
            const buttonText = submitButton.querySelector('.button-text');
            const buttonLoading = submitButton.querySelector('.button-loading');
            
            // Show loading state
            if(buttonText && buttonLoading) {
                buttonText.classList.add('hidden');
                buttonLoading.classList.remove('hidden');
            }
            submitButton.disabled = true;
            
            // Simulate form submission (replace with actual API call)
            await new Promise(resolve => setTimeout(resolve, 1500));
            
            // Show success message
            alert('Permintaan Anda telah berhasil dikirim! Tim kami akan segera menghubungi Anda.');
            
            // Reset form
            form.reset();
            
            // Reset button state
             if(buttonText && buttonLoading) {
                buttonText.classList.remove('hidden');
                buttonLoading.classList.add('hidden');
            }
            submitButton.disabled = false;
        });
    });
}

// Smooth scrolling for anchor links
function initializeSmoothScrolling() {
    document.querySelectorAll('a[href*="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            const href = this.getAttribute('href');
            const targetId = href.substring(href.lastIndexOf('#') + 1);
            const targetElement = document.getElementById(targetId);

            // Check if the link is on the same page
            const onSamePage = location.pathname.replace(/^\//, '') == this.pathname.replace(/^\//, '');

            if (onSamePage && targetElement) {
                e.preventDefault();
                const headerOffset = document.getElementById('header') ? document.getElementById('header').offsetHeight : 0;
                const elementPosition = targetElement.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - headerOffset;

                window.scrollTo({
                    top: offsetPosition,
                    behavior: "smooth"
                });
            }
        });
    });
}


// Animation on scroll
function initializeAnimations() {
    const animatedElements = document.querySelectorAll('.animate-on-scroll');

    if ("IntersectionObserver" in window) {
        const observer = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('is-visible');
                    observer.unobserve(entry.target);
                }
            });
        }, {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        });

        animatedElements.forEach(el => {
            observer.observe(el);
        });
    } else {
        // Fallback for older browsers
        animatedElements.forEach(el => {
            el.classList.add('is-visible');
        });
    }
}


// Parallax effect for hero section
window.addEventListener('scroll', function() {
    const heroImage = document.querySelector('.hero-image');
    if (heroImage) {
        const scrolled = window.pageYOffset;
        const rate = scrolled * -0.3;
        heroImage.style.transform = `translateY(${rate}px)`;
    }
});

// Dashboard specific JS
function initializeDashboardLearningPath() {
    const courseLinks = document.querySelectorAll('#course-sidebar ul li');
    if (!courseLinks.length) return;

    courseLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            courseLinks.forEach(l => l.classList.remove('active-lesson'));
            link.classList.add('active-lesson');
            // Here you would typically load the new lesson content
            alert(`Memuat pelajaran: ${link.textContent.trim()}`);
        });
    });
}
