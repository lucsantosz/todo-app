<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { categoryColor } from '../colors'
import type { Category } from '../types'
import Icon from './Icon.vue'

const props = defineProps<{ category: Category; total: number; done: number }>()
const emit = defineEmits<{ edit: []; remove: [] }>()

const open = ref(false)
const root = ref<HTMLElement | null>(null)

function closeOnOutsideClick(event: MouseEvent) {
  if (root.value && !root.value.contains(event.target as Node)) open.value = false
}

onMounted(() => document.addEventListener('click', closeOnOutsideClick))
onBeforeUnmount(() => document.removeEventListener('click', closeOnOutsideClick))

const percent = computed(() => (props.total ? Math.round((props.done / props.total) * 100) : 0))

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
  <article ref="root" class="cat-card" :style="{ '--cat': categoryColor(category.id) }">
    <div class="cat-top">
      <span class="cat-avatar">{{ category.name.charAt(0).toUpperCase() }}</span>

      <div class="cat-title">
        <strong class="cat-name">{{ category.name }}</strong>
        <span class="cat-count">{{ total }} {{ total === 1 ? 'tarefa' : 'tarefas' }}</span>
      </div>

      <div class="menu-wrap">
        <button type="button" class="icon-btn" aria-label="Mais ações" @click="open = !open">
          <Icon name="more" />
        </button>

        <ul v-if="open" class="menu">
          <li>
            <button type="button" @click="edit"><Icon name="edit" :size="15" /> Editar</button>
          </li>
          <li>
            <button type="button" class="danger" @click="remove"><Icon name="trash" :size="15" /> Excluir</button>
          </li>
        </ul>
      </div>
    </div>

    <div class="cat-bar"><span :style="{ width: percent + '%' }"></span></div>

    <div class="cat-foot">
      <span>{{ done }} de {{ total }} concluída(s)</span>
      <span>{{ percent }}%</span>
    </div>
  </article>
</template>
