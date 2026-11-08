<script setup lang="ts">
import { onMounted, reactive, ref, watch } from 'vue'
import { tasksApi } from '../api'
import { priorityLabels, statusLabels } from '../labels'
import type { Category, Status, Task, TaskFilters } from '../types'
import TaskForm from './TaskForm.vue'

const props = defineProps<{ categories: Category[] }>()

const tasks = ref<Task[]>([])
const loading = ref(true)
const error = ref('')
const showForm = ref(false)
const editingTask = ref<Task | null>(null)
const filters = reactive<TaskFilters>({ category_id: '', status: '', priority: '' })
const today = new Date().toLocaleDateString('en-CA')

async function loadTasks() {
  try {
    tasks.value = await tasksApi.list(filters)
    error.value = ''
  } catch {
    error.value = 'Não foi possível carregar as tarefas.'
  } finally {
    loading.value = false
  }
}

onMounted(loadTasks)
watch(filters, loadTasks)

watch(
  () => props.categories,
  (categories) => {
    if (filters.category_id !== '' && !categories.some((c) => c.id === filters.category_id)) {
      filters.category_id = ''
    }
    loadTasks()
  },
)

function openNew() {
  editingTask.value = null
  showForm.value = true
}

function openEdit(task: Task) {
  editingTask.value = task
  showForm.value = true
}

function closeForm() {
  showForm.value = false
  editingTask.value = null
}

async function onSaved() {
  closeForm()
  await loadTasks()
}

async function changeStatus(task: Task, status: Status) {
  try {
    await tasksApi.update(task.id, { status })
    await loadTasks()
  } catch {
    error.value = 'Não foi possível atualizar o status.'
  }
}

async function remove(task: Task) {
  if (!confirm(`Excluir a tarefa "${task.title}"?`)) return

  try {
    await tasksApi.remove(task.id)
    await loadTasks()
  } catch {
    error.value = 'Não foi possível excluir a tarefa.'
  }
}

function formatDate(date: string) {
  return new Date(`${date}T00:00:00`).toLocaleDateString('pt-BR')
}

function isOverdue(task: Task) {
  return !!task.due_date && task.due_date < today && task.status !== 'done'
}
</script>

<template>
  <section>
    <div class="card">
      <div class="row">
        <h2 class="grow">Tarefas</h2>
        <button type="button" :disabled="!categories.length" @click="openNew">Nova tarefa</button>
      </div>

      <p v-if="!categories.length" class="muted">Crie uma categoria antes de adicionar tarefas.</p>

      <div class="filters">
        <select v-model="filters.category_id">
          <option value="">Todas as categorias</option>
          <option v-for="category in categories" :key="category.id" :value="category.id">
            {{ category.name }}
          </option>
        </select>

        <select v-model="filters.status">
          <option value="">Todos os status</option>
          <option v-for="(label, key) in statusLabels" :key="key" :value="key">{{ label }}</option>
        </select>

        <select v-model="filters.priority">
          <option value="">Todas as prioridades</option>
          <option v-for="(label, key) in priorityLabels" :key="key" :value="key">{{ label }}</option>
        </select>
      </div>
    </div>

    <TaskForm
      v-if="showForm"
      :key="editingTask?.id ?? 'new'"
      :categories="categories"
      :task="editingTask"
      @saved="onSaved"
      @cancel="closeForm"
    />

    <p v-if="error" class="error">{{ error }}</p>
    <p v-else-if="loading" class="muted">Carregando tarefas...</p>
    <p v-else-if="!tasks.length" class="muted">Nenhuma tarefa encontrada.</p>

    <ul class="list">
      <li v-for="task in tasks" :key="task.id" class="card task">
        <div class="row">
          <strong class="grow">{{ task.title }}</strong>
          <button type="button" class="secondary" @click="openEdit(task)">Editar</button>
          <button type="button" class="danger" @click="remove(task)">Excluir</button>
        </div>

        <p v-if="task.description" class="muted">{{ task.description }}</p>

        <div class="row meta">
          <span class="badge">{{ task.category.name }}</span>
          <span class="badge">Prioridade: {{ priorityLabels[task.priority] }}</span>
          <span v-if="task.due_date" class="badge" :class="{ overdue: isOverdue(task) }">
            Vence em {{ formatDate(task.due_date) }}
          </span>
          <select
            :value="task.status"
            @change="changeStatus(task, ($event.target as HTMLSelectElement).value as Status)"
          >
            <option v-for="(label, key) in statusLabels" :key="key" :value="key">{{ label }}</option>
          </select>
        </div>
      </li>
    </ul>
  </section>
</template>
