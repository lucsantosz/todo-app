<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { categoriesApi, tasksApi } from './api'
import type { Category, Task } from './types'
import CategoryManager from './components/CategoryManager.vue'
import Icon from './components/Icon.vue'
import TaskManager from './components/TaskManager.vue'

type View = 'tasks' | 'categories'

const view = ref<View>('tasks')
const theme = ref<'dark' | 'light'>('dark')
const categories = ref<Category[]>([])
const allTasks = ref<Task[]>([])
const version = ref(0)
const loading = ref(true)
const loadError = ref('')

function applyTheme() {
  document.documentElement.dataset.theme = theme.value
}

function toggleTheme() {
  theme.value = theme.value === 'dark' ? 'light' : 'dark'
  applyTheme()

  try {
    localStorage.setItem('theme', theme.value)
  } catch {
    // sem armazenamento disponível: o tema vale só nesta visita
  }
}

async function reload() {
  try {
    const [loadedCategories, loadedTasks] = await Promise.all([categoriesApi.list(), tasksApi.list()])
    categories.value = loadedCategories
    allTasks.value = loadedTasks
    loadError.value = ''
    version.value++
  } catch {
    loadError.value = 'Não foi possível carregar os dados. O servidor Rails está rodando?'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  try {
    const saved = localStorage.getItem('theme')
    if (saved === 'light' || saved === 'dark') theme.value = saved
  } catch {
    // mantém o tema padrão
  }

  applyTheme()
  reload()
})
</script>

<template>
  <div class="layout">
    <aside class="sidebar">
      <div class="brand">
        <span class="logo"><Icon name="check" :size="20" /></span>
        <span>TaskFlow</span>
      </div>

      <nav>
        <button type="button" class="nav-item" :class="{ active: view === 'tasks' }" @click="view = 'tasks'">
          <Icon name="home" /> Início
        </button>
        <button
          type="button"
          class="nav-item"
          :class="{ active: view === 'categories' }"
          @click="view = 'categories'"
        >
          <Icon name="grid" /> Categorias
        </button>
      </nav>

      <div class="sidebar-bottom">
        <svg class="scenery" viewBox="0 0 200 120" preserveAspectRatio="none" aria-hidden="true">
          <circle class="moon" cx="140" cy="38" r="16" />
          <path class="hill-back" d="M0 120 L0 80 L40 50 L70 75 L110 40 L160 80 L200 60 L200 120 Z" />
          <path class="hill-front" d="M0 120 L0 95 L50 70 L90 95 L140 65 L200 100 L200 120 Z" />
        </svg>

        <div class="theme-toggle">
          <Icon :name="theme === 'dark' ? 'moon' : 'sun'" />
          <button
            type="button"
            class="switch"
            role="switch"
            :aria-checked="theme === 'dark'"
            aria-label="Alternar tema"
            @click="toggleTheme"
          ></button>
        </div>
      </div>
    </aside>

    <main class="content">
      <p v-if="loadError" class="error">{{ loadError }}</p>
      <p v-else-if="loading" class="muted">Carregando...</p>
      <template v-else>
        <TaskManager
          v-if="view === 'tasks'"
          :categories="categories"
          :all-tasks="allTasks"
          :version="version"
          @changed="reload"
          @open-categories="view = 'categories'"
        />
        <CategoryManager v-else :categories="categories" :all-tasks="allTasks" @changed="reload" />
      </template>
    </main>
  </div>
</template>
