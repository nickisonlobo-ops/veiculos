<template>
  <div class="min-h-screen flex items-center justify-center px-4 py-12" style="background: linear-gradient(135deg, #0f0f1a 0%, #0d1117 50%, #0f172a 100%)">
    <!-- Decoração de fundo -->
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
      <div class="absolute -top-40 -right-40 w-96 h-96 rounded-full opacity-10" style="background: radial-gradient(circle, #059669, transparent)"></div>
      <div class="absolute -bottom-40 -left-40 w-96 h-96 rounded-full opacity-10" style="background: radial-gradient(circle, #10b981, transparent)"></div>
    </div>
    <LoginForm class="relative z-10" />
  </div>
</template>

<script setup lang="ts">
import LoginForm from '~/components/LoginForm.vue'

definePageMeta({ layout: false })
</script>
