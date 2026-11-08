<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { categoriesApi } from './api'
import type { Category } from './types'
import CategoryManager from './components/CategoryManager.vue'
import TaskManager from './components/TaskManager.vue'

const categories = ref<Category[]>([])
const loading = ref(true)
const loadError = ref('')

async function loadCategories() {
  try {
    categories.value = await categoriesApi.list()
    loadError.value = ''
  } catch {
    loadError.value = 'Não foi possível carregar as categorias. O servidor Rails está rodando?'
  } finally {
    loading.value = false
  }
}

onMounted(loadCategories)
</script>

<template>
  <h1>To-Do List</h1>
  <p v-if="loadError" class="error">{{ loadError }}</p>
  <p v-else-if="loading" class="muted">Carregando...</p>
  <template v-else>
    <TaskManager :categories="categories" />
    <CategoryManager :categories="categories" @changed="loadCategories" />
  </template>
</template>
