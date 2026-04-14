import type { Config } from 'tailwindcss'

export default {
  content: [],
  theme: {
    extend: {
      keyframes: {
        progress: {
          '0%':   { backgroundPosition: '200% 0' },
          '100%': { backgroundPosition: '-200% 0' },
        },
      },
      animation: {
        progress: 'progress 2s linear infinite',
      },
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
      },
      colors: {
        // â”€â”€â”€ Paleta base â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        green: {
          50:  '#f0faf0',
          100: '#d9f2d9',
          200: '#b3e6b3',
          300: '#7dd17d',
          400: '#4db84d',
          500: '#2e9e2e',
          600: '#1f7f1f',
          700: '#165f16',
          800: '#0e3f0e',
          900: '#072007',
        },
        orange: {
          50:  '#fff8f0',
          100: '#feecd8',
          200: '#fdd4a8',
          300: '#fbb46a',
          400: '#f8902f',
          500: '#f07010',
          600: '#d4570a',
          700: '#a83f07',
          800: '#7a2b05',
          900: '#4d1a02',
        },
        navy: {
          50:  '#eef2f8',
          100: '#d5dff0',
          200: '#aabfe0',
          300: '#7095c8',
          400: '#3f6aad',
          500: '#254d8e',
          600: '#1a3b72',
          700: '#112b56',
          800: '#0a1c39',
          900: '#040e1e',
        },

        // â”€â”€â”€ Cores semÃ¢nticas â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        primary: {
          DEFAULT: '#1f7f1f', // green-600
          light:   '#4db84d', // green-400
          dark:    '#0e3f0e', // green-800
          hover:   '#165f16', // green-700
          text:    '#ffffff',
        },
        secondary: {
          DEFAULT: '#f07010', // orange-500
          light:   '#f8902f', // orange-400
          dark:    '#a83f07', // orange-700
          hover:   '#d4570a', // orange-600
          text:    '#ffffff',
        },
        accent: {
          DEFAULT: '#254d8e', // navy-500
          light:   '#3f6aad', // navy-400
          dark:    '#0a1c39', // navy-800
          hover:   '#1a3b72', // navy-600
          text:    '#ffffff',
        },

        // â”€â”€â”€ SuperfÃ­cies / backgrounds â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        bg: {
          DEFAULT:  '#f0faf0', // verde muito claro (green-50)
          surface:  '#ffffff',
          muted:    '#eef2f8', // navy-50
          dark:     '#0a1c39', // navy-800
        },

        // â”€â”€â”€ Textos â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        content: {
          DEFAULT:  '#0e3f0e', // green-800  â€” texto principal
          muted:    '#1a3b72', // navy-600   â€” texto secundÃ¡rio
          inverted: '#ffffff',
          link:     '#1f7f1f', // primary
        },

        // â”€â”€â”€ Bordas â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        border: {
          DEFAULT: '#b3e6b3', // green-200
          muted:   '#d5dff0', // navy-100
          strong:  '#1f7f1f', // primary
        },

        // â”€â”€â”€ Feedback â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        success: '#2e9e2e',
        warning: '#f07010',
        error:   '#c0392b',
        info:    '#254d8e',
      },
    },
  },
  plugins: [],
} satisfies Config
