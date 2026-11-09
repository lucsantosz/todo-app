const palette = ['#2dd4bf', '#f59e0b', '#fb7185', '#a3e635', '#f97316', '#94a3b8', '#facc15', '#4ade80']

export function categoryColor(id: number) {
  return palette[id % palette.length]
}
