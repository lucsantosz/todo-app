<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { categoryColor } from '../colors'
import { priorityLabels, statusLabels } from '../labels'
import type { Task } from '../types'
import Icon from './Icon.vue'

const props = defineProps<{ task: Task; today: string }>()
const emit = defineEmits<{ toggle: []; progress: []; edit: []; remove: [] }>()

const open = ref(false)
const root = ref<HTMLElement | null>(null)

function closeOnOutsideClick(event: MouseEvent) {
  if (root.value && !root.value.contains(event.target as Node)) open.value = false
}

onMounted(() => document.addEventListener('click', closeOnOutsideClick))
onBeforeUnmount(() => document.removeEventListener('click', closeOnOutsideClick))

const overdue = computed(
  () => !!props.task.due_date && props.task.due_date < props.today && props.task.status !== 'done',
)

const canStart = computed(() => props.task.status === 'pending')

function dueLabel(date: string) {
  const target = new Date(`${date}T00:00:00`)
  const base = new Date(`${props.today}T00:00:00`)
  const diff = Math.round((target.getTime() - base.getTime()) / 86400000)

  if (diff === 0) return 'Hoje'
  if (diff === 1) return 'Amanhã'
  if (diff === -1) return 'Ontem'
  return target.toLocaleDateString('pt-BR')
}

function start() {
  open.value = false
  emit('progress')
}

function edit() {
  open.value = false
  emit('edit')
}

function remove() {
  open.value = false
  emit('remove')
}
</script>

<template>
  <li ref="root" class="task-row" :class="{ done: task.status === 'done' }">
    <button
      type="button"
      class="check"
      :class="{ checked: task.status === 'done' }"
      :aria-label="task.status === 'done' ? 'Marcar como pendente' : 'Marcar como concluída'"
      @click="emit('toggle')"
    >
      <Icon v-if="task.status === 'done'" name="check" :size="13" />
    </button>

    <div class="task-main">
      <strong>{{ task.title }}</strong>
      <span v-if="task.description" class="muted">{{ task.description }}</span>
    </div>

    <span v-if="task.status === 'in_progress'" class="tag progress">{{ statusLabels.in_progress }}</span>
    <span class="tag" :style="{ '--tag': categoryColor(task.category_id) }">{{ task.category.name }}</span>
    <span class="tag" :class="task.priority">{{ priorityLabels[task.priority] }}</span>

    <span class="due" :class="{ overdue }">
      <template v-if="task.due_date">
        <Icon name="calendar" :size="15" />
        {{ dueLabel(task.due_date) }}
      </template>
    </span>

    <div class="menu-wrap">
      <button type="button" class="icon-btn" aria-label="Mais ações" @click="open = !open">
        <Icon name="more" />
      </button>

      <ul v-if="open" class="menu">
        <li v-if="canStart">
          <button type="button" @click="start"><Icon name="play" :size="15" /> Iniciar</button>
        </li>
        <li>
          <button type="button" @click="edit"><Icon name="edit" :size="15" /> Editar</button>
        </li>
        <li>
          <button type="button" class="danger" @click="remove"><Icon name="trash" :size="15" /> Excluir</button>
        </li>
      </ul>
    </div>
  </li>
</template>
