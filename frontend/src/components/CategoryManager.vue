<script setup lang="ts">
import { ref } from 'vue'
import { ApiError, categoriesApi } from '../api'
import { categoryColor } from '../colors'
import type { Category, Task } from '../types'

const props = defineProps<{ categories: Category[]; allTasks: Task[] }>()
const emit = defineEmits<{ changed: [] }>()

const newName = ref('')
const editingId = ref<number | null>(null)
const editingName = ref('')
const errors = ref<string[]>([])

function countFor(categoryId: number) {
  return props.allTasks.filter((task) => task.category_id === categoryId).length
}

function showError(error: unknown) {
  errors.value = error instanceof ApiError ? error.errors : ['Algo deu errado. Tente novamente.']
}

async function create() {
  try {
    await categoriesApi.create(newName.value.trim())
    newName.value = ''
    errors.value = []
    emit('changed')
  } catch (error) {
    showError(error)
  }
}

function startEdit(category: Category) {
  editingId.value = category.id
  editingName.value = category.name
  errors.value = []
}

async function saveEdit(id: number) {
  try {
    await categoriesApi.update(id, editingName.value.trim())
    editingId.value = null
    errors.value = []
    emit('changed')
  } catch (error) {
    showError(error)
  }
}

async function remove(category: Category) {
  if (!confirm(`Excluir "${category.name}"? As tarefas dessa categoria também serão excluídas.`)) return

  try {
    await categoriesApi.remove(category.id)
    errors.value = []
    emit('changed')
  } catch (error) {
    showError(error)
  }
}
</script>

<template>
  <header class="page-header">
    <div>
      <h1>Categorias</h1>
      <p class="muted">Agrupe suas tarefas por assunto.</p>
    </div>
  </header>

  <section class="panel">
    <form class="row" @submit.prevent="create">
      <input v-model="newName" class="fill" placeholder="Nome da nova categoria" />
      <button type="submit" class="primary">Adicionar</button>
    </form>

    <ul v-if="errors.length" class="errors">
      <li v-for="message in errors" :key="message">{{ message }}</li>
    </ul>

    <p v-if="!categories.length" class="muted">Nenhuma categoria ainda. Crie a primeira acima.</p>

    <ul>
      <li v-for="category in categories" :key="category.id" class="category-row">
        <template v-if="editingId === category.id">
          <input v-model="editingName" class="fill" @keyup.enter="saveEdit(category.id)" />
          <button type="button" class="small primary" @click="saveEdit(category.id)">Salvar</button>
          <button type="button" class="small" @click="editingId = null">Cancelar</button>
        </template>
        <template v-else>
          <span class="dot" :style="{ background: categoryColor(category.id) }"></span>
          <span class="fill">{{ category.name }}</span>
          <span class="muted">{{ countFor(category.id) }} tarefa(s)</span>
          <button type="button" class="small" @click="startEdit(category)">Editar</button>
          <button type="button" class="small danger" @click="remove(category)">Excluir</button>
        </template>
      </li>
    </ul>
  </section>
</template>
