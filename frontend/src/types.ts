export type Status = 'pending' | 'in_progress' | 'done'
export type Priority = 'low' | 'medium' | 'high'

export interface Category {
  id: number
  name: string
}

export interface Task {
  id: number
  title: string
  description: string | null
  status: Status
  priority: Priority
  due_date: string | null
  category_id: number
  category: Category
}

export interface TaskInput {
  title: string
  description: string
  status: Status
  priority: Priority
  due_date: string | null
  category_id: number | null
}

export interface TaskFilters {
  category_id: number | ''
  status: Status | ''
  priority: Priority | ''
}
