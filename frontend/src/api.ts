import type { Category, Task, TaskFilters, TaskInput } from './types'

const BASE_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:3000/api'

export class ApiError extends Error {
  errors: string[]

  constructor(errors: string[]) {
    super(errors.join(', '))
    this.errors = errors
  }
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const response = await fetch(`${BASE_URL}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  })

  if (response.status === 204) {
    return undefined as T
  }

  const data = await response.json().catch(() => null)

  if (!response.ok) {
    throw new ApiError(data?.errors ?? ['Algo deu errado. Tente novamente.'])
  }

  return data as T
}

export const categoriesApi = {
  list: () => request<Category[]>('/categories'),
  create: (name: string) =>
    request<Category>('/categories', {
      method: 'POST',
      body: JSON.stringify({ category: { name } }),
    }),
  update: (id: number, name: string) =>
    request<Category>(`/categories/${id}`, {
      method: 'PATCH',
      body: JSON.stringify({ category: { name } }),
    }),
  remove: (id: number) => request<void>(`/categories/${id}`, { method: 'DELETE' }),
}

export const tasksApi = {
  list: (filters: Partial<TaskFilters> = {}) => {
    const params = new URLSearchParams()
    for (const [key, value] of Object.entries(filters)) {
      if (value !== '' && value !== undefined) params.set(key, String(value))
    }
    const query = params.toString()
    return request<Task[]>(`/tasks${query ? `?${query}` : ''}`)
  },
  create: (task: TaskInput) =>
    request<Task>('/tasks', { method: 'POST', body: JSON.stringify({ task }) }),
  update: (id: number, task: Partial<TaskInput>) =>
    request<Task>(`/tasks/${id}`, { method: 'PATCH', body: JSON.stringify({ task }) }),
  remove: (id: number) => request<void>(`/tasks/${id}`, { method: 'DELETE' }),
}
