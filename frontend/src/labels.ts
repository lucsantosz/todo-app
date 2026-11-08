import type { Priority, Status } from './types'

export const statusLabels: Record<Status, string> = {
  pending: 'Pendente',
  in_progress: 'Em andamento',
  done: 'Concluída',
}

export const priorityLabels: Record<Priority, string> = {
  low: 'Baixa',
  medium: 'Média',
  high: 'Alta',
}
