<template>
  <div class="login-root min-h-screen flex items-center justify-center px-4 py-12 relative overflow-hidden">

    <!-- Fundo escuro com textura de carbono -->
    <div class="absolute inset-0" style="background:#07090f"/>

    <!-- Gradiente radial de luz — farol no topo -->
    <div class="absolute inset-0 pointer-events-none"
         style="background:radial-gradient(ellipse 80% 55% at 50% -5%, rgba(30,64,175,0.22) 0%, transparent 70%)"/>

    <!-- Reflexo de chão -->
    <div class="absolute bottom-0 left-0 right-0 h-56 pointer-events-none"
         style="background:linear-gradient(to top, rgba(30,64,175,0.07), transparent)"/>

    <!-- Linha horizontal fina — horizonte -->
    <div class="absolute pointer-events-none" style="top:48%;left:0;right:0;height:1px;background:linear-gradient(90deg,transparent,rgba(56,189,248,0.12),transparent)"/>

    <!-- Grade perspectiva sutil -->
    <div class="grid-bg absolute inset-0 pointer-events-none"/>

    <LoginForm class="relative z-10"/>
  </div>
</template>

<script setup lang="ts">
import LoginForm from '~/components/LoginForm.vue'
definePageMeta({ layout: false })
</script>

<style scoped>
.grid-bg {
  background-image:
    repeating-linear-gradient(0deg, transparent, transparent 79px, rgba(56,189,248,0.03) 79px, rgba(56,189,248,0.03) 80px),
    repeating-linear-gradient(90deg, transparent, transparent 79px, rgba(56,189,248,0.03) 79px, rgba(56,189,248,0.03) 80px);
  -webkit-mask-image: radial-gradient(ellipse 70% 70% at 50% 50%, rgba(0,0,0,0.6), transparent);
  mask-image: radial-gradient(ellipse 70% 70% at 50% 50%, rgba(0,0,0,0.6), transparent);
}
</style>
