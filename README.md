# To-Do List

Sistema de controle de tarefas com categorias. Backend em **Ruby on Rails** (API REST) e frontend em **Vue.js 3** (TypeScript).

## Funcionalidades

- CRUD completo de **categorias** (nome) e de **tarefas** (título, descrição, status, prioridade e data de vencimento).
- Toda tarefa pertence a uma categoria. Ao excluir uma categoria, as tarefas dela são excluídas junto.
- Listagem de tarefas com filtros por **categoria**, **status** e **prioridade**.
- Validações no backend (título e nome obrigatórios, nome de categoria único) com mensagens de erro exibidas na tela.
- Testes automatizados do backend (models e API).

## Tecnologias

- Ruby 3.4 e Rails 8 (modo API), SQLite
- Vue 3, TypeScript e Vite
- rack-cors para liberar o frontend

## Pré-requisitos

- Ruby 3.4 ou superior
- Node.js 22 ou superior (testado com a 26)
- Git

## Como rodar localmente

Clone o repositório:

```bash
git clone git@github.com:lucsantosz/todo-app.git
cd todo-app
```

### 1. Backend (porta 3000)

```bash
cd backend
bundle install
bin/rails db:prepare
bin/rails server
```

O `db:prepare` cria o banco SQLite, roda as migrations e carrega alguns dados de exemplo. Para recarregar os exemplos depois, use `bin/rails db:seed`.

### 2. Frontend (porta 5173)

Em outro terminal:

```bash
cd frontend
npm install
npm run dev
```

Abra **http://localhost:5173** no navegador. O frontend espera a API em `http://localhost:3000/api`. Para usar outro endereço, crie `frontend/.env.local` com `VITE_API_URL=http://seu-endereco/api`.

## Testes

```bash
cd backend
bin/rails test
```

Para conferir os tipos do frontend:

```bash
cd frontend
npm run type-check
```

## Endpoints da API

| Método | Rota | Descrição |
|---|---|---|
| GET | `/api/categories` | Lista categorias |
| POST | `/api/categories` | Cria categoria |
| GET | `/api/categories/:id` | Mostra uma categoria |
| PATCH/PUT | `/api/categories/:id` | Edita categoria |
| DELETE | `/api/categories/:id` | Exclui categoria e suas tarefas |
| GET | `/api/tasks` | Lista tarefas (filtros: `category_id`, `status`, `priority`) |
| POST | `/api/tasks` | Cria tarefa |
| GET | `/api/tasks/:id` | Mostra uma tarefa |
| PATCH/PUT | `/api/tasks/:id` | Edita tarefa |
| DELETE | `/api/tasks/:id` | Exclui tarefa |

Valores aceitos: `status` = `pending`, `in_progress`, `done`; `priority` = `low`, `medium`, `high`.

Exemplo:

```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"task":{"title":"Estudar Rails","priority":"high","due_date":"2026-11-20","category_id":1}}'
```

Erros de validação retornam status `422` com o formato `{ "errors": ["Title can't be blank"] }`.

## Estrutura

```
todo-app/
├── backend/    API Rails (models, controllers em app/controllers/api, testes)
└── frontend/   Vue 3 (src/api.ts concentra as chamadas à API)
```

## Decisões técnicas

- **Duas pastas no mesmo repositório**, para facilitar a avaliação e a execução.
- **SQLite** para o projeto rodar sem instalar um banco.
- **Enums** para status e prioridade: o banco guarda números e a API expõe nomes legíveis.
- **Fora do escopo**: autenticação, paginação e deploy.
