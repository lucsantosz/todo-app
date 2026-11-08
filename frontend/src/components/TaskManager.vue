<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { tasksApi } from '../api'
import { categoryColor } from '../colors'
import { priorityLabels, statusLabels } from '../labels'
import type { Category, Status, Task, TaskFilters } from '../types'
import TaskForm from './TaskForm.vue'

const props = defineProps<{ categories: Category[]; allTasks: Task[]; version: number }>()
const emit = defineEmits<{ changed: [] }>()

const tasks = ref<Task[]>([])
const loading = ref(true)
const error = ref('')
const search = ref('')
const showForm = ref(false)
const editingTask = ref<Task | null>(null)
const filters = reactive<TaskFilters>({ category_id: '', status: '', priority: '' })
const today = new Date().toLocaleDateString('en-CA')

const statusTabs: { value: Status | ''; label: string }[] = [
  { value: '', label: 'Todas' },
  ...(Object.entries(statusLabels) as [Status, string][]).map(([value, label]) => ({ value, label })),
]

const visibleTasks = computed(() => {
  const term = search.value.trim().toLowerCase()
  if (!term) return tasks.value

  return tasks.value.filter(
    (task) =>
      task.title.toLowerCase().includes(term) || (task.description ?? '').toLowerCase().includes(term),
  )
})

const stats = computed(() => ({
  total: props.allTasks.length,
  inProgress: props.allTasks.filter((task) => task.status === 'in_progress').length,
  done: props.allTasks.filter((task) => task.status === 'done').length,
  highPriority: props.allTasks.filter((task) => task.priority === 'high' && task.status !== 'done').length,
}))

function countFor(categoryId: number) {
  return props.allTasks.filter((task) => task.category_id === categoryId).length
}

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
watch(() => props.version, loadTasks)

watch(
  () => props.categories,
  (categories) => {
    if (filters.category_id !== '' && !categories.some((category) => category.id === filters.category_id)) {
      filters.category_id = ''
    }
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

function onSaved() {
  closeForm()
  emit('changed')
}

async function toggleDone(task: Task) {
  try {
    await tasksApi.update(task.id, { status: task.status === 'done' ? 'pending' : 'done' })
    emit('changed')
  } catch {
    error.value = 'Não foi possível atualizar a tarefa.'
  }
}

async function changeStatus(task: Task, status: Status) {
  try {
    await tasksApi.update(task.id, { status })
    emit('changed')
  } catch {
    error.value = 'Não foi possível atualizar o status.'
  }
}

async function remove(task: Task) {
  if (!confirm(`Excluir a tarefa "${task.title}"?`)) return

  try {
    await tasksApi.remove(task.id)
    emit('changed')
  } catch {
    error.value = 'Não foi possível excluir a tarefa.'
  }
}

function dueLabel(date: string) {
  const target = new Date(`${date}T00:00:00`)
  const base = new Date(`${today}T00:00:00`)
  const diff = Math.round((target.getTime() - base.getTime()) / 86400000)

  if (diff === 0) return 'Hoje'
  if (diff === 1) return 'Amanhã'
  if (diff === -1) return 'Ontem'
  return target.toLocaleDateString('pt-BR')
}

function isOverdue(task: Task) {
  return !!task.due_date && task.due_date < today && task.status !== 'done'
}
</script>

<template>
  <header class="page-header">
    <div>
      <h1>Minhas tarefas</h1>
      <p class="muted">Organize suas tarefas e mantenha-se produtivo.</p>
    </div>

    <div class="header-actions">
      <input v-model="search" class="search" type="search" placeholder="Buscar tarefas..." />
      <button type="button" class="primary" :disabled="!categories.length" @click="openNew">+ Nova tarefa</button>
    </div>
  </header>

  <section class="stats">
    <div class="stat stat-total"><strong>{{ stats.total }}</strong><span>Total de tarefas</span></div>
    <div class="stat stat-progress"><strong>{{ stats.inProgress }}</strong><span>Em andamento</span></div>
    <div class="stat stat-done"><strong>{{ stats.done }}</strong><span>Concluídas</span></div>
    <div class="stat stat-high"><strong>{{ stats.highPriority }}</strong><span>Alta prioridade</span></div>
  </section>

  <div class="columns">
    <section class="panel">
      <div class="panel-header">
        <h2>Tarefas</h2>
        <div class="pills">
          <button
            v-for="tab in statusTabs"
            :key="tab.value"
            type="button"
            class="pill"
            :class="{ active: filters.status === tab.value }"
            @click="filters.status = tab.value"
          >
            {{ tab.label }}
          </button>
        </div>
      </div>

      <div class="filters">
        <select v-model="filters.category_id">
          <option value="">Todas as categorias</option>
          <option v-for="category in categories" :key="category.id" :value="category.id">
            {{ category.name }}
          </option>
        </select>

        <select v-model="filters.priority">
          <option value="">Todas as prioridades</option>
          <option v-for="(label, key) in priorityLabels" :key="key" :value="key">{{ label }}</option>
        </select>
      </div>

      <p v-if="!categories.length" class="muted">Crie uma categoria antes de adicionar tarefas.</p>
      <p v-if="error" class="error">{{ error }}</p>
      <p v-else-if="loading" class="muted">Carregando tarefas...</p>
      <p v-else-if="!visibleTasks.length" class="muted">Nenhuma tarefa encontrada.</p>

      <ul>
        <li v-for="task in visibleTasks" :key="task.id" class="task-row" :class="{ done: task.status === 'done' }">
          <input
            type="checkbox"
            :checked="task.status === 'done'"
            aria-label="Marcar como concluída"
            @change="toggleDone(task)"
          />

          <div class="task-main">
            <strong>{{ task.title }}</strong>
            <span v-if="task.description" class="muted">{{ task.description }}</span>
          </div>

          <span class="tag" :style="{ '--tag': categoryColor(task.category_id) }">{{ task.category.name }}</span>
          <span class="tag" :class="task.priority">{{ priorityLabels[task.priority] }}</span>
          <span v-if="task.due_date" class="due" :class="{ overdue: isOverdue(task) }">
            📅 {{ dueLabel(task.due_date) }}
          </span>

          <select
            class="status-select"
            :value="task.status"
            @change="changeStatus(task, ($event.target as HTMLSelectElement).value as Status)"
          >
            <option v-for="(label, key) in statusLabels" :key="key" :value="key">{{ label }}</option>
          </select>

          <button type="button" class="small" @click="openEdit(task)">Editar</button>
          <button type="button" class="small danger" @click="remove(task)">Excluir</button>
        </li>
      </ul>
    </section>

    <aside class="panel">
      <h2>Categorias</h2>
      <ul>
        <li>
          <button
            type="button"
            class="category-item"
            :class="{ active: filters.category_id === '' }"
            @click="filters.category_id = ''"
          >
            <span class="dot" style="background: #9b9dc4"></span>
            <span class="fill">Todas</span>
            <span class="muted">{{ allTasks.length }}</span>
          </button>
        </li>
        <li v-for="category in categories" :key="category.id">
          <button
            type="button"
            class="category-item"
            :class="{ active: filters.category_id === category.id }"
            @click="filters.category_id = category.id"
          >
            <span class="dot" :style="{ background: categoryColor(category.id) }"></span>
            <span class="fill">{{ category.name }}</span>
            <span class="muted">{{ countFor(category.id) }}</span>
          </button>
        </li>
      </ul>
    </aside>
  </div>

  <div v-if="showForm" class="modal-backdrop" @click.self="closeForm">
    <TaskForm
      :key="editingTask?.id ?? 'new'"
      :categories="categories"
      :task="editingTask"
      @saved="onSaved"
      @cancel="closeForm"
    />
  </div>
</template>
