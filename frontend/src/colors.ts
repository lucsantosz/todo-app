const palette = ['#a78bfa', '#60a5fa', '#4ade80', '#fb923c', '#f472b6', '#facc15', '#2dd4bf', '#f87171']

export function categoryColor(id: number) {
  return palette[id % palette.length]
}
