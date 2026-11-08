<script setup lang="ts">
import { ref } from 'vue'
import { ApiError, categoriesApi } from '../api'
import type { Category } from '../types'

defineProps<{ categories: Category[] }>()
const emit = defineEmits<{ changed: [] }>()

const newName = ref('')
const editingId = ref<number | null>(null)
const editingName = ref('')
const errors = ref<string[]>([])

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
  <section class="card">
    <h2>Categorias</h2>

    <form class="row" @submit.prevent="create">
      <input v-model="newName" placeholder="Nome da nova categoria" />
      <button type="submit">Adicionar</button>
    </form>

    <ul v-if="errors.length" class="errors">
      <li v-for="message in errors" :key="message">{{ message }}</li>
    </ul>

    <p v-if="!categories.length" class="muted">Nenhuma categoria ainda. Crie a primeira acima.</p>

    <ul class="list">
      <li v-for="category in categories" :key="category.id" class="row">
        <template v-if="editingId === category.id">
          <input v-model="editingName" @keyup.enter="saveEdit(category.id)" />
          <button type="button" @click="saveEdit(category.id)">Salvar</button>
          <button type="button" class="secondary" @click="editingId = null">Cancelar</button>
        </template>
        <template v-else>
          <span class="grow">{{ category.name }}</span>
          <button type="button" class="secondary" @click="startEdit(category)">Editar</button>
          <button type="button" class="danger" @click="remove(category)">Excluir</button>
        </template>
      </li>
    </ul>
  </section>
</template>
