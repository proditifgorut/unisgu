/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
    "./main.js",
  ],
  theme: {
    extend: {
      colors: {
        'primary-navy': '#0A1931',
        'accent-orange': '#FF7A00',
        'accent-teal': '#00C49A',
        'text-light': '#F0F0F0',
        'text-dark': '#333333',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        display: ['Poppins', 'sans-serif'],
      },
      keyframes: {
        fadeInUp: {
          'from': { 
            opacity: '0',
            transform: 'translateY(30px)' 
          },
          'to': { 
            opacity: '1',
            transform: 'translateY(0)' 
          },
        },
      },
      animation: {
        'fade-in-up': 'fadeInUp 0.6s ease-out',
      },
    },
  },
  plugins: [],
}
