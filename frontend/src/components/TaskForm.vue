<script setup lang="ts">
import { reactive, ref } from 'vue'
import { ApiError, tasksApi } from '../api'
import { priorityLabels, statusLabels } from '../labels'
import type { Category, Task, TaskInput } from '../types'

const props = defineProps<{ categories: Category[]; task: Task | null }>()
const emit = defineEmits<{ saved: []; cancel: [] }>()

const form = reactive<TaskInput>({
  title: props.task?.title ?? '',
  description: props.task?.description ?? '',
  status: props.task?.status ?? 'pending',
  priority: props.task?.priority ?? 'medium',
  due_date: props.task?.due_date ?? '',
  category_id: props.task?.category_id ?? props.categories[0]?.id ?? null,
})

const errors = ref<string[]>([])
const saving = ref(false)

async function submit() {
  saving.value = true

  const payload: TaskInput = {
    ...form,
    title: form.title.trim(),
    due_date: form.due_date || null,
  }

  try {
    if (props.task) {
      await tasksApi.update(props.task.id, payload)
    } else {
      await tasksApi.create(payload)
    }
    emit('saved')
  } catch (error) {
    errors.value = error instanceof ApiError ? error.errors : ['Algo deu errado. Tente novamente.']
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <form class="modal" @submit.prevent="submit">
    <h2>{{ task ? 'Editar tarefa' : 'Nova tarefa' }}</h2>

    <div class="field">
      <label for="title">Título</label>
      <input id="title" v-model="form.title" />
    </div>

    <div class="field">
      <label for="description">Descrição</label>
      <textarea id="description" v-model="form.description" rows="3"></textarea>
    </div>

    <div class="grid">
      <div class="field">
        <label for="category">Categoria</label>
        <select id="category" v-model.number="form.category_id">
          <option v-for="category in categories" :key="category.id" :value="category.id">
            {{ category.name }}
          </option>
        </select>
      </div>

      <div class="field">
        <label for="status">Status</label>
        <select id="status" v-model="form.status">
          <option v-for="(label, key) in statusLabels" :key="key" :value="key">{{ label }}</option>
        </select>
      </div>

      <div class="field">
        <label for="priority">Prioridade</label>
        <select id="priority" v-model="form.priority">
          <option v-for="(label, key) in priorityLabels" :key="key" :value="key">{{ label }}</option>
        </select>
      </div>

      <div class="field">
        <label for="due_date">Vencimento</label>
        <input id="due_date" v-model="form.due_date" type="date" />
      </div>
    </div>

    <ul v-if="errors.length" class="errors">
      <li v-for="message in errors" :key="message">{{ message }}</li>
    </ul>

    <div class="row">
      <button type="submit" class="primary" :disabled="saving">
        {{ task ? 'Salvar alterações' : 'Criar tarefa' }}
      </button>
      <button type="button" @click="emit('cancel')">Cancelar</button>
    </div>
  </form>
</template>
