<template>
  <div class="w-full max-w-[420px]">

    <!-- ── Logo / Brand ───────────────────────────────────────── -->
    <div class="flex items-center gap-4 mb-10">
      <div class="w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0"
           style="background:linear-gradient(145deg,#1e40af,#0ea5e9);box-shadow:0 0 24px rgba(14,165,233,0.35)">
        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 18.75a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 01-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 00-3.213-9.193 2.056 2.056 0 00-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 00-10.026 0 1.106 1.106 0 00-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12"/>
        </svg>
      </div>
      <div>
        <p class="text-xs font-bold tracking-[0.18em] uppercase" style="color:#38bdf8">Auto Gestão</p>
        <h1 class="text-2xl font-black text-white leading-tight tracking-tight mt-0.5">
          {{ activeTab === 'login' ? 'Bem-vindo de volta' : 'Criar conta' }}
        </h1>
      </div>
    </div>

    <!-- ── Card Glassmorphism ─────────────────────────────────── -->
    <div class="card-glass rounded-3xl p-8 space-y-6">

      <!-- Tab switcher minimalista -->
      <div class="flex gap-1 p-1 rounded-xl" style="background:rgba(255,255,255,0.05)">
        <button
          v-for="tab in tabs"
          :key="tab.key"
          type="button"
          class="flex-1 py-2 rounded-lg text-sm font-semibold transition-all duration-200"
          :style="activeTab === tab.key
            ? 'background:rgba(14,165,233,0.18);color:#38bdf8;box-shadow:0 0 0 1px rgba(56,189,248,0.3)'
            : 'color:rgba(148,163,184,0.7)'"
          @click="activeTab = tab.key"
        >
          {{ tab.label }}
        </button>
      </div>

      <!-- ── Form Entrar ── -->
      <form v-if="activeTab === 'login'" class="space-y-5" @submit.prevent="handleLogin">
        <div class="space-y-1.5">
          <label class="field-label">E-mail</label>
          <input
            v-model="login.email"
            type="email"
            placeholder="seu@email.com"
            class="field-input"
            required
          />
          <p v-if="formErrors.email" class="text-xs text-red-400 mt-1">{{ formErrors.email }}</p>
        </div>

        <div class="space-y-1.5">
          <label class="field-label">Senha</label>
          <div class="relative">
            <input
              v-model="login.password"
              :type="showPassword ? 'text' : 'password'"
              placeholder="••••••••"
              class="field-input pr-11"
              required
            />
            <button type="button" class="eye-btn" @click="showPassword = !showPassword">
              <svg v-if="showPassword" class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88"/></svg>
              <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
            </button>
          </div>
          <p v-if="formErrors.password" class="text-xs text-red-400 mt-1">{{ formErrors.password }}</p>
        </div>

        <p v-if="authError" class="text-sm text-red-400 bg-red-500/10 border border-red-500/20 rounded-xl px-4 py-2.5 text-center">
          {{ authError }}
        </p>

        <button type="submit" class="submit-btn" :disabled="authLoading">
          <svg v-if="authLoading" class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
          </svg>
          <span>{{ authLoading ? 'Entrando…' : 'Entrar' }}</span>
          <svg v-if="!authLoading" class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"/>
          </svg>
        </button>
      </form>

      <!-- ── Form Criar Conta ── -->
      <form v-else class="space-y-4" @submit.prevent="handleRegister">
        <div class="space-y-1.5">
          <label class="field-label">Nome completo</label>
          <input v-model="register.name" type="text" placeholder="João da Silva" class="field-input" required />
          <p v-if="registerErrors.name" class="text-xs text-red-400 mt-1">{{ registerErrors.name }}</p>
        </div>

        <div class="space-y-1.5">
          <label class="field-label">Nome da empresa</label>
          <input v-model="register.nomeEmpresa" type="text" placeholder="Minha Concessionária" class="field-input" required />
          <p v-if="registerErrors.nomeEmpresa" class="text-xs text-red-400 mt-1">{{ registerErrors.nomeEmpresa }}</p>
        </div>

        <div class="space-y-1.5">
          <label class="field-label">E-mail</label>
          <input v-model="register.email" type="email" placeholder="seu@email.com" class="field-input" required />
          <p v-if="registerErrors.email" class="text-xs text-red-400 mt-1">{{ registerErrors.email }}</p>
        </div>

        <div class="space-y-1.5">
          <label class="field-label">Senha</label>
          <div class="relative">
            <input v-model="register.password" :type="showRegisterPassword ? 'text' : 'password'" placeholder="••••••••" class="field-input pr-11" required />
            <button type="button" class="eye-btn" @click="showRegisterPassword = !showRegisterPassword">
              <svg v-if="showRegisterPassword" class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88"/></svg>
              <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
            </button>
          </div>
          <p v-if="registerErrors.password" class="text-xs text-red-400 mt-1">{{ registerErrors.password }}</p>
        </div>

        <div class="space-y-1.5">
          <label class="field-label">Confirmar senha</label>
          <input v-model="register.confirmPassword" :type="showRegisterPassword ? 'text' : 'password'" placeholder="••••••••" class="field-input" required />
          <p v-if="registerErrors.confirmPassword" class="text-xs text-red-400 mt-1">{{ registerErrors.confirmPassword }}</p>
        </div>

        <p v-if="authError" class="text-sm text-red-400 bg-red-500/10 border border-red-500/20 rounded-xl px-4 py-2.5 text-center">
          {{ authError }}
        </p>
        <p v-if="registerSuccess" class="text-sm text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 rounded-xl px-4 py-2.5 text-center">
          Cadastro realizado! Verifique seu e-mail.
        </p>

        <button type="submit" class="submit-btn" :disabled="authLoading">
          <svg v-if="authLoading" class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
          </svg>
          <span>{{ authLoading ? 'Criando conta…' : 'Criar conta' }}</span>
          <svg v-if="!authLoading" class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"/>
          </svg>
        </button>
      </form>
    </div>

    <!-- rodapé -->
    <p class="text-center text-xs mt-6" style="color:rgba(100,116,139,0.7)">
      Plataforma de Gestão Automotiva
    </p>
  </div>
</template>

<style scoped>
.card-glass {
  background: rgba(255,255,255,0.04);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 1px solid rgba(255,255,255,0.07);
  box-shadow: 0 32px 64px rgba(0,0,0,0.5), inset 0 1px 0 rgba(255,255,255,0.06);
}

.field-label {
  display: block;
  font-size: 0.75rem;
  font-weight: 600;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: rgba(148,163,184,0.8);
}

.field-input {
  width: 100%;
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.09);
  border-radius: 0.75rem;
  padding: 0.7rem 1rem;
  font-size: 0.9rem;
  color: #f1f5f9;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
}
.field-input::placeholder { color: rgba(100,116,139,0.55); }
.field-input:focus {
  border-color: rgba(56,189,248,0.5);
  box-shadow: 0 0 0 3px rgba(56,189,248,0.08);
}

.eye-btn {
  position: absolute;
  right: 0.75rem;
  top: 50%;
  transform: translateY(-50%);
  color: rgba(100,116,139,0.6);
  transition: color 0.15s;
}
.eye-btn:hover { color: #94a3b8; }

.submit-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.8rem 1.5rem;
  border-radius: 0.875rem;
  font-size: 0.95rem;
  font-weight: 700;
  color: #ffffff;
  background: linear-gradient(135deg, #1e40af, #0ea5e9);
  box-shadow: 0 4px 24px rgba(14,165,233,0.3);
  border: none;
  cursor: pointer;
  transition: opacity 0.2s, transform 0.15s, box-shadow 0.2s;
  margin-top: 0.5rem;
}
.submit-btn:hover:not(:disabled) {
  opacity: 0.92;
  transform: translateY(-1px);
  box-shadow: 0 6px 32px rgba(14,165,233,0.4);
}
.submit-btn:active:not(:disabled) { transform: translateY(0); }
.submit-btn:disabled { opacity: 0.6; cursor: not-allowed; }
</style>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '~/composables/useAuth'

defineOptions({ name: 'LoginForm' })

const router = useRouter()
const { login: authLogin, register: authRegister, loading: authLoading, error: authError } = useAuth()

const tabs: { key: 'login' | 'register'; label: string }[] = [
  { key: 'login',    label: 'Entrar' },
  { key: 'register', label: 'Criar conta' },
]

const activeTab = ref<'login' | 'register'>('login')
const showPassword = ref(false)
const showRegisterPassword = ref(false)

const login = reactive({ email: '', password: '' })
const register = reactive({ name: '', nomeEmpresa: '', email: '', password: '', confirmPassword: '' })

const formErrors = reactive({ email: '', password: '' })
const registerErrors = reactive({ name: '', nomeEmpresa: '', email: '', password: '', confirmPassword: '' })

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

function validateLogin(): boolean {
  formErrors.email = ''
  formErrors.password = ''

  if (!login.email) {
    formErrors.email = 'O e-mail é obrigatório.'
  } else if (!emailRegex.test(login.email)) {
    formErrors.email = 'Informe um e-mail válido.'
  }

  if (!login.password) {
    formErrors.password = 'A senha é obrigatória.'
  }

  return !formErrors.email && !formErrors.password
}

function validateRegister(): boolean {
  registerErrors.name = ''
  registerErrors.nomeEmpresa = ''
  registerErrors.email = ''
  registerErrors.password = ''
  registerErrors.confirmPassword = ''

  if (!register.name.trim()) {
    registerErrors.name = 'O nome é obrigatório.'
  }

  if (!register.nomeEmpresa.trim()) {
    registerErrors.nomeEmpresa = 'O nome da empresa é obrigatório.'
  }

  if (!register.email) {
    registerErrors.email = 'O e-mail é obrigatório.'
  } else if (!emailRegex.test(register.email)) {
    registerErrors.email = 'Informe um e-mail válido.'
  }

  if (!register.password) {
    registerErrors.password = 'A senha é obrigatória.'
  } else if (register.password.length < 6) {
    registerErrors.password = 'A senha deve ter no mínimo 6 caracteres.'
  }

  if (!register.confirmPassword) {
    registerErrors.confirmPassword = 'Confirme sua senha.'
  } else if (register.password !== register.confirmPassword) {
    registerErrors.confirmPassword = 'As senhas não coincidem.'
  }

  return !registerErrors.name && !registerErrors.nomeEmpresa && !registerErrors.email && !registerErrors.password && !registerErrors.confirmPassword
}

async function handleLogin() {
  if (!validateLogin()) return
  const ok = await authLogin(login.email, login.password)
  if (ok) {
    await router.push('/')
  }
}

const registerSuccess = ref(false)

async function handleRegister() {
  if (!validateRegister()) return
  const { ok, needsConfirmation } = await authRegister(register.name, register.email, register.password, register.nomeEmpresa)
  if (ok) {
    if (needsConfirmation) {
      registerSuccess.value = true
    } else {
      // Limpa tema do usuário anterior para não herdar cores de outra empresa
      try { localStorage.removeItem('empresa_tema') } catch {}
      await router.push('/')
    }
  }
}
</script>
