<template>
  <div class="login-bg min-h-screen flex items-center justify-center px-4 py-12">
    <!-- Pista / grade de perspectiva -->
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
      <!-- Grade de perspectiva estilo piso de garagem -->
      <div class="absolute inset-0 grid-perspective" />
      <!-- Faróis vindos do horizonte (luz central) -->
      <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-[900px] h-[500px]" style="background: radial-gradient(ellipse at 50% 100%, rgba(56,189,248,0.12) 0%, rgba(29,78,216,0.06) 40%, transparent 70%)" />
      <!-- Faixa de luz lateral esquerda — farol -->
      <div class="absolute top-0 left-0 w-1 h-full" style="background: linear-gradient(to bottom, transparent, rgba(56,189,248,0.25), transparent)" />
      <!-- Faixa de luz lateral direita -->
      <div class="absolute top-0 right-0 w-1 h-full" style="background: linear-gradient(to bottom, transparent, rgba(56,189,248,0.25), transparent)" />
      <!-- Brilho superior (efeito headlight) -->
      <div class="absolute -top-20 left-1/2 -translate-x-1/2 w-[600px] h-[300px]" style="background: radial-gradient(ellipse at 50% 0%, rgba(148,163,184,0.07) 0%, transparent 70%)" />
    </div>
    <LoginForm class="relative z-10" />
  </div>
</template>

<script setup lang="ts">
import LoginForm from '~/components/LoginForm.vue'

definePageMeta({ layout: false })
</script>

<style scoped>
.login-bg {
  background-color: #080c12;
  background-image:
    /* Reflexo metálico diagonal */
    linear-gradient(135deg, rgba(15,23,42,1) 0%, rgba(8,12,18,1) 50%, rgba(15,23,42,1) 100%);
  position: relative;
}

/* Grade de perspectiva tipo pista/garagem */
.grid-perspective {
  background-image:
    /* Linhas horizontais da grade */
    repeating-linear-gradient(
      0deg,
      transparent,
      transparent 59px,
      rgba(56, 189, 248, 0.04) 59px,
      rgba(56, 189, 248, 0.04) 60px
    ),
    /* Linhas verticais convergindo ao centro — perspectiva */
    repeating-linear-gradient(
      90deg,
      transparent,
      transparent 79px,
      rgba(56, 189, 248, 0.04) 79px,
      rgba(56, 189, 248, 0.04) 80px
    );
  /* Máscara: some na parte superior, aparece na inferior (perspectiva de pista) */
  -webkit-mask-image: linear-gradient(to bottom, transparent 0%, rgba(0,0,0,0.6) 40%, rgba(0,0,0,1) 100%);
  mask-image: linear-gradient(to bottom, transparent 0%, rgba(0,0,0,0.6) 40%, rgba(0,0,0,1) 100%);
  width: 100%;
  height: 100%;
  transform: perspective(600px) rotateX(20deg);
  transform-origin: bottom center;
}
</style>
