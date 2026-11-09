<script setup lang="ts">
import { computed, ref } from 'vue'
import type { Task } from '../types'
import Icon from './Icon.vue'

const props = defineProps<{ tasks: Task[] }>()

const now = new Date()
const cursor = ref(new Date(now.getFullYear(), now.getMonth(), 1))
const weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']

function pad(value: number) {
  return String(value).padStart(2, '0')
}

const todayIso = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`

const monthLabel = computed(() => {
  const label = cursor.value.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' })
  return label.charAt(0).toUpperCase() + label.slice(1)
})

const monthName = computed(() => cursor.value.toLocaleDateString('pt-BR', { month: 'long' }))

const tasksByDay = computed(() => {
  const map = new Map<string, Task[]>()

  for (const task of props.tasks) {
    if (!task.due_date) continue
    const list = map.get(task.due_date) ?? []
    list.push(task)
    map.set(task.due_date, list)
  }

  return map
})

const cells = computed(() => {
  const year = cursor.value.getFullYear()
  const month = cursor.value.getMonth()
  const offset = new Date(year, month, 1).getDay()
  const total = new Date(year, month + 1, 0).getDate()
  const result: ({ day: number; iso: string; tasks: Task[] } | null)[] = Array(offset).fill(null)

  for (let day = 1; day <= total; day++) {
    const iso = `${year}-${pad(month + 1)}-${pad(day)}`
    result.push({ day, iso, tasks: tasksByDay.value.get(iso) ?? [] })
  }

  return result
})

function shift(delta: number) {
  cursor.value = new Date(cursor.value.getFullYear(), cursor.value.getMonth() + delta, 1)
}
</script>

<template>
  <section class="panel">
    <h2>Calendário</h2>

    <div class="cal-nav">
      <button type="button" class="icon-btn" aria-label="Mês anterior" @click="shift(-1)">
        <Icon name="chevron-left" />
      </button>
      <strong>{{ monthLabel }}</strong>
      <button type="button" class="icon-btn" aria-label="Próximo mês" @click="shift(1)">
        <Icon name="chevron-right" />
      </button>
    </div>

    <div class="cal-grid">
      <span v-for="weekday in weekdays" :key="weekday" class="cal-week">{{ weekday }}</span>

      <template v-for="(cell, index) in cells" :key="index">
        <span v-if="!cell"></span>
        <span
          v-else
          class="cal-day"
          :class="{
            today: cell.iso === todayIso,
            'has-task': cell.tasks.length > 0,
            'tip-left': index % 7 <= 1,
            'tip-right': index % 7 >= 5,
          }"
          :tabindex="cell.tasks.length ? 0 : undefined"
        >
          {{ cell.day }}
          <span v-if="cell.tasks.length" class="cal-tip" role="tooltip">
            <strong>{{ cell.day }} de {{ monthName }}</strong>
            <span v-for="task in cell.tasks" :key="task.id" :class="{ 'tip-done': task.status === 'done' }">
              • {{ task.title }}
            </span>
          </span>
        </span>
      </template>
    </div>
  </section>
</template>
