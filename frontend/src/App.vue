<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { categoriesApi, tasksApi } from './api'
import type { Category, Task } from './types'
import CategoryManager from './components/CategoryManager.vue'
import TaskManager from './components/TaskManager.vue'

type View = 'tasks' | 'categories'

const view = ref<View>('tasks')
const categories = ref<Category[]>([])
const allTasks = ref<Task[]>([])
const version = ref(0)
const loading = ref(true)
const loadError = ref('')

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

onMounted(reload)
</script>

<template>
  <div class="layout">
    <aside class="sidebar">
      <div class="brand">
        <span class="logo">✓</span>
        <span>To-Do List</span>
      </div>

      <nav>
        <button type="button" class="nav-item" :class="{ active: view === 'tasks' }" @click="view = 'tasks'">
          📋 Tarefas
        </button>
        <button type="button" class="nav-item" :class="{ active: view === 'categories' }" @click="view = 'categories'">
          🏷️ Categorias
        </button>
      </nav>
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
        />
        <CategoryManager v-else :categories="categories" :all-tasks="allTasks" @changed="reload" />
      </template>
    </main>
  </div>
</template>
