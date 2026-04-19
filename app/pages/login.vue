<template>
  <div class="min-h-screen flex items-center justify-center px-4 py-12" style="background: linear-gradient(135deg, #fdf2f8 0%, #fce7f3 40%, #f3e8ff 100%)">
    <!-- Decoração de fundo -->
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
      <div class="absolute -top-40 -right-40 w-96 h-96 rounded-full opacity-30" style="background: radial-gradient(circle, #f9a8d4, transparent)"></div>
      <div class="absolute -bottom-40 -left-40 w-96 h-96 rounded-full opacity-30" style="background: radial-gradient(circle, #d8b4fe, transparent)"></div>
    </div>
    <LoginForm class="relative z-10" />
  </div>
</template>

<script setup lang="ts">
import LoginForm from '~/components/LoginForm.vue'

definePageMeta({ layout: false })
</script>
