## Disclaimer

This application was developed entirely using Claude Code.
No humans wrote any code.
No AI was harmed in the making of this application.

# Task Manager

A Ruby on Rails web application for creating and managing tasks, tracking their progress, and adding internal notes via comments.

---

## Stack

| | |
|---|---|
| **Ruby** | 3.4.2+ |
| **Rails** | 8.1.2 |
| **Database** | SQLite 3 (gem `sqlite3 >= 2.1`) |
| **Asset pipeline** | Propshaft |
| **JS** | Importmap + Hotwire (Turbo + Stimulus) |

---

## Features

- **Full CRUD** on tasks (title, optional description, status)
- **Kanban board** with three columns: To Do · In Progress · Completed
- **Drag and drop** tasks between columns to update their status
- **Unidirectional status advancement**: Todo → In Progress → Done
- **Comments / internal notes** on every task
- **Dark / light mode** toggle (persisted in localStorage)
- **Flash messages** with auto-dismiss (Stimulus)

---

## Setup

```bash
# 1. Enter the project folder
cd task_manager

# 2. Install gems
bundle install

# 3. Create the database and run migrations
rails db:create db:migrate

# 4. (Optional) Load sample data
rails db:seed

# 5. Start the server
rails server
```

Open your browser at **http://localhost:3000**

---

## Structure

```
task_manager/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── tasks_controller.rb       # CRUD + advance_status + move
│   │   └── comments_controller.rb
│   ├── models/
│   │   ├── task.rb                   # statuses, validations, transitions
│   │   └── comment.rb
│   ├── views/tasks/
│   │   ├── index.html.erb            # kanban board
│   │   ├── show.html.erb             # detail + comments + progress bar
│   │   ├── new.html.erb
│   │   ├── edit.html.erb
│   │   └── _form.html.erb
│   ├── javascript/controllers/
│   │   ├── flash_controller.js       # auto-dismiss notifications
│   │   ├── drag_controller.js        # drag and drop between columns
│   │   ├── theme_controller.js       # dark / light mode toggle
│   │   ├── application.js
│   │   └── index.js
│   └── assets/stylesheets/
│       └── application.css           # dark industrial theme + light mode
├── config/
│   ├── routes.rb
│   ├── importmap.rb
│   └── database.yml
└── db/
    ├── migrate/
    │   ├── 20250101000001_create_tasks.rb
    │   └── 20250101000002_create_comments.rb
    └── seeds.rb
```

## Main routes

| Method | Path | Action |
|--------|------|--------|
| `GET` | `/` | Task board |
| `GET` | `/tasks/new` | New task |
| `POST` | `/tasks` | Create task |
| `GET` | `/tasks/:id` | Task detail |
| `GET` | `/tasks/:id/edit` | Edit task |
| `PATCH` | `/tasks/:id` | Update task |
| `DELETE` | `/tasks/:id` | Delete task |
| `PATCH` | `/tasks/:id/advance_status` | Advance status |
| `PATCH` | `/tasks/:id/move` | Move to any status (drag & drop) |
| `POST` | `/tasks/:task_id/comments` | Add note |
| `DELETE` | `/tasks/:task_id/comments/:id` | Delete note |

---

## Business rules (Task model)

```ruby
STATUSES = %w[todo in_progress done]

STATUS_TRANSITIONS = {
  "todo"        => "in_progress",
  "in_progress" => "done",
  "done"        => nil          # terminal
}
```

- Title is required
- New tasks always start with `status: "todo"`
- `advance_status!` raises an exception if the task is already `done`
- `move` accepts any valid status, enabling drag & drop in any direction
