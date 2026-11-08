work, study, personal = %w[Trabalho Estudos Pessoal].map do |name|
  Category.find_or_create_by!(name: name)
end

[
  { title: "Preparar relatório mensal", description: "Consolidar os números do mês",
    status: :in_progress, priority: :high, due_date: Date.current + 3, category: work },
  { title: "Revisar pull requests", description: nil,
    status: :pending, priority: :medium, due_date: Date.current + 1, category: work },
  { title: "Estudar Ruby on Rails", description: "Models, controllers e testes",
    status: :in_progress, priority: :high, due_date: Date.current + 5, category: study },
  { title: "Praticar Vue 3", description: "Componentes e composition API",
    status: :pending, priority: :low, due_date: nil, category: study },
  { title: "Marcar consulta de rotina", description: nil,
    status: :pending, priority: :medium, due_date: Date.current + 7, category: personal },
  { title: "Organizar a mesa", description: nil,
    status: :done, priority: :low, due_date: Date.current - 1, category: personal }
].each do |attributes|
  Task.find_or_create_by!(title: attributes[:title]) { |task| task.assign_attributes(attributes) }
end
