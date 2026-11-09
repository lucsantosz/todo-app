<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { ApiError, categoriesApi } from '../api'
import type { Category, Task } from '../types'
import CategoryCard from './CategoryCard.vue'

const props = defineProps<{ categories: Category[]; allTasks: Task[] }>()
const emit = defineEmits<{ changed: [] }>()

const newName = ref('')
const createErrors = ref<string[]>([])

const editing = ref<Category | null>(null)
const editName = ref('')
const editErrors = ref<string[]>([])

const deleting = ref<Category | null>(null)
const confirmText = ref('')
const deleteError = ref('')

const busy = ref(false)

function errorsFrom(error: unknown) {
  return error instanceof ApiError ? error.errors : ['Algo deu errado. Tente novamente.']
}

function tasksOf(categoryId: number) {
  return props.allTasks.filter((task) => task.category_id === categoryId)
}

function doneOf(categoryId: number) {
  return tasksOf(categoryId).filter((task) => task.status === 'done').length
}

const deletingCount = computed(() => (deleting.value ? tasksOf(deleting.value.id).length : 0))

const canDelete = computed(() => {
  if (!deleting.value) return false
  if (deletingCount.value === 0) return true
  return confirmText.value.trim().toLowerCase() === deleting.value.name.trim().toLowerCase()
})

async function create() {
  busy.value = true

  try {
    await categoriesApi.create(newName.value.trim())
    newName.value = ''
    createErrors.value = []
    emit('changed')
  } catch (error) {
    createErrors.value = errorsFrom(error)
  } finally {
    busy.value = false
  }
}

function openEdit(category: Category) {
  editing.value = category
  editName.value = category.name
  editErrors.value = []
}

async function saveEdit() {
  if (!editing.value) return
  busy.value = true

  try {
    await categoriesApi.update(editing.value.id, editName.value.trim())
    editing.value = null
    emit('changed')
  } catch (error) {
    editErrors.value = errorsFrom(error)
  } finally {
    busy.value = false
  }
}

function openDelete(category: Category) {
  deleting.value = category
  confirmText.value = ''
  deleteError.value = ''
}

async function confirmDelete() {
  if (!deleting.value || !canDelete.value) return
  busy.value = true

  try {
    await categoriesApi.remove(deleting.value.id)
    deleting.value = null
    emit('changed')
  } catch (error) {
    deleteError.value = errorsFrom(error).join(', ')
  } finally {
    busy.value = false
  }
}

function closeModals() {
  editing.value = null
  deleting.value = null
}

function onKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape') closeModals()
}

onMounted(() => window.addEventListener('keydown', onKeydown))
onBeforeUnmount(() => window.removeEventListener('keydown', onKeydown))
</script>

<template>
  <header class="page-header">
    <div>
      <h1>Categorias</h1>
      <p class="muted">
        {{ categories.length }} {{ categories.length === 1 ? 'categoria' : 'categorias' }} ·
        {{ allTasks.length }} {{ allTasks.length === 1 ? 'tarefa' : 'tarefas' }} no total
      </p>
    </div>

    <form class="cat-form" @submit.prevent="create">
      <input v-model="newName" placeholder="Nome da nova categoria" />
      <button type="submit" class="primary" :disabled="busy">+ Adicionar</button>
    </form>
  </header>

  <ul v-if="createErrors.length" class="errors">
    <li v-for="message in createErrors" :key="message">{{ message }}</li>
  </ul>

  <p v-if="!categories.length" class="cat-empty">Nenhuma categoria ainda. Crie a primeira no campo acima.</p>

  <section class="cat-grid">
    <CategoryCard
      v-for="category in categories"
      :key="category.id"
      :category="category"
      :total="tasksOf(category.id).length"
      :done="doneOf(category.id)"
      @edit="openEdit(category)"
      @remove="openDelete(category)"
    />
  </section>

  <div v-if="editing" class="modal-backdrop" @click.self="closeModals">
    <form class="modal" @submit.prevent="saveEdit">
      <h2>Editar categoria</h2>

      <div class="field">
        <label for="edit-name">Nome</label>
        <input id="edit-name" v-model="editName" autofocus />
      </div>

      <ul v-if="editErrors.length" class="errors">
        <li v-for="message in editErrors" :key="message">{{ message }}</li>
      </ul>

      <div class="modal-actions">
        <button type="button" @click="closeModals">Cancelar</button>
        <button type="submit" class="primary" :disabled="busy">Salvar</button>
      </div>
    </form>
  </div>

  <div v-if="deleting" class="modal-backdrop" @click.self="closeModals">
    <form class="modal" @submit.prevent="confirmDelete">
      <h2>Excluir "{{ deleting.name }}"?</h2>

      <div class="warn">
        <template v-if="deletingCount > 0">
          Esta categoria tem <strong>{{ deletingCount }}</strong>
          {{ deletingCount === 1 ? 'tarefa' : 'tarefas' }}, que também
          {{ deletingCount === 1 ? 'será excluída' : 'serão excluídas' }}. Essa ação não pode ser desfeita.
        </template>
        <template v-else>Essa categoria não tem tarefas. A ação não pode ser desfeita.</template>
      </div>

      <div v-if="deletingCount > 0" class="field">
        <label for="confirm-name">Para confirmar, digite <strong>{{ deleting.name }}</strong></label>
        <input id="confirm-name" v-model="confirmText" autocomplete="off" autofocus />
      </div>

      <p v-if="deleteError" class="error">{{ deleteError }}</p>

      <div class="modal-actions">
        <button type="button" @click="closeModals">Cancelar</button>
        <button type="submit" class="danger-solid" :disabled="!canDelete || busy">Excluir categoria</button>
      </div>
    </form>
  </div>
</template>
