import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  define: {
    // Identifiant de build injecte dans le bundle : affiche dans la console
    // admin pour verifier que le navigateur sert bien la derniere version.
    __BUILD_ID__: JSON.stringify(
      new Date().toISOString().replace('T', ' ').slice(0, 16) + ' UTC',
    ),
  },
})
