## Disclaimer

This application was developed entirely using Claude Code.
No humans wrote any code.
No AI was harmed in the making of this application.

# Task Manager

A Ruby on Rails web application for creating and managing tasks, tracking their progress, adding internal notes, and collaborating with team members.

---

## Stack

| | |
|---|---|
| **Ruby** | 3.4.2+ |
| **Rails** | 8.1.2 |
| **Database** | SQLite 3 (gem `sqlite3 >= 2.1`) |
| **Asset pipeline** | Propshaft |
| **JS** | Importmap + Hotwire (Turbo + Stimulus) |
| **File storage** | Active Storage (local disk) |

---

## Features

### Tasks
- **Full CRUD** on tasks (title, optional description, status, priority)
- **Kanban board** with three columns: To Do · In Progress · Completed
- **Drag and drop** tasks between columns to update their status
- **Unidirectional status advancement**: Todo → In Progress → Done via button
- **Priority levels**: Very Low · Low · Medium · High · Very High
- **Assignee & reporter** — assign tasks to any registered user

### Notes
- **Internal notes / comments** on every task
- Notes are ordered by **most recently updated** (newest first)
- Delete individual notes with a confirmation dialog

### Users & Authentication
- **Registration** with nickname, email, password
- **Login / logout** with secure password hashing (bcrypt)
- **User profile editing** — update first name, last name, nickname, and email
- **Password change** — optional; leave blank to keep the current password
- **Avatar** — choose between:
  - Entering a direct **image URL**
  - **Uploading a photo** from disk (with **drag & drop** support onto the drop zone)
  - Auto-generated **initials badge** with a deterministic colour when no photo is set
- **User dropdown menu** (top-right avatar) — quick access to Edit Profile and Log Out

### UI
- **Dark / light mode** toggle (persisted in `localStorage`)
- **Flash messages** with auto-dismiss (Stimulus)
- Responsive design — adapts to mobile viewports

---

## Setup

```bash
# 1. Enter the project folder
cd task_manager

# 2. Install gems
bundle install

# 3. Create the database, run migrations (including Active Storage)
rails db:create db:migrate

# 4. (Optional) Load sample data
rails db:seed

# 5. Start the server
rails server
```

Open your browser at **http://localhost:3000**

### Docker

```bash
# Build and start
echo "SECRET_KEY_BASE=$(rails secret)" > .env
docker compose up --build
```

---

## Structure

```
task_manager/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb   # auth guard + current_user
│   │   ├── tasks_controller.rb         # CRUD + advance_status + move
│   │   ├── comments_controller.rb      # nested under tasks
│   │   ├── profiles_controller.rb      # edit / update current user
│   │   ├── sessions_controller.rb      # login / logout
│   │   └── registrations_controller.rb # sign-up
│   ├── models/
│   │   ├── task.rb                     # statuses, priorities, transitions
│   │   ├── comment.rb
│   │   └── user.rb                     # has_one_attached :photo, display_name, initials
│   ├── helpers/
│   │   └── application_helper.rb       # avatar_tag (photo > url > initials)
│   ├── views/
│   │   ├── tasks/
│   │   │   ├── index.html.erb          # kanban board
│   │   │   ├── show.html.erb           # detail + comments + progress bar
│   │   │   ├── new.html.erb
│   │   │   ├── edit.html.erb
│   │   │   └── _form.html.erb
│   │   ├── profiles/
│   │   │   └── edit.html.erb           # profile form (name, email, password, avatar)
│   │   ├── sessions/
│   │   │   └── new.html.erb            # login
│   │   ├── registrations/
│   │   │   └── new.html.erb            # sign-up
│   │   └── layouts/
│   │       └── application.html.erb    # header with dropdown user menu
│   ├── javascript/controllers/
│   │   ├── flash_controller.js         # auto-dismiss notifications
│   │   ├── drag_controller.js          # drag and drop between kanban columns
│   │   ├── dropdown_controller.js      # header user-menu dropdown
│   │   ├── photo_upload_controller.js  # avatar upload + drag & drop preview
│   │   ├── theme_controller.js         # dark / light mode toggle
│   │   ├── collapse_controller.js      # collapsible kanban columns
│   │   ├── application.js
│   │   └── index.js
│   └── assets/stylesheets/
│       └── application.css             # dark industrial theme + light mode
├── config/
│   ├── routes.rb
│   ├── importmap.rb
│   ├── database.yml
│   ├── storage.yml                     # Active Storage — local disk
│   ├── cable.yml                       # Solid Cable
│   ├── cache.yml                       # Solid Cache
│   └── queue.yml                       # Solid Queue
├── db/
│   ├── migrate/
│   │   ├── 20250101000001_create_tasks.rb
│   │   ├── 20250101000002_create_comments.rb
│   │   ├── 20250201000001_add_priority_to_tasks.rb
│   │   ├── 20250201000002_create_users.rb
│   │   ├── 20250201000003_add_user_references_to_tasks.rb
│   │   ├── 20250201000004_add_user_id_to_comments.rb
│   │   ├── 20260227000001_add_names_to_users.rb
│   │   └── 20260227000002_create_active_storage_tables.rb
│   └── seeds.rb
├── Dockerfile
├── docker-compose.yml
└── test/
    ├── models/
    │   ├── user_test.rb
    │   ├── task_test.rb
    │   └── comment_test.rb
    └── controllers/
        ├── sessions_controller_test.rb
        ├── registrations_controller_test.rb
        ├── tasks_controller_test.rb
        ├── comments_controller_test.rb
        └── profiles_controller_test.rb
```

---

## Routes

| Method | Path | Action |
|--------|------|--------|
| `GET` | `/` | Task board (kanban) |
| `GET` | `/tasks/new` | New task form |
| `POST` | `/tasks` | Create task |
| `GET` | `/tasks/:id` | Task detail + notes |
| `GET` | `/tasks/:id/edit` | Edit task form |
| `PATCH` | `/tasks/:id` | Update task |
| `DELETE` | `/tasks/:id` | Delete task |
| `PATCH` | `/tasks/:id/advance_status` | Advance to next status |
| `PATCH` | `/tasks/:id/move` | Move to any status (drag & drop) |
| `POST` | `/tasks/:task_id/comments` | Add note |
| `DELETE` | `/tasks/:task_id/comments/:id` | Delete note |
| `GET` | `/profile/edit` | Edit user profile |
| `PATCH` | `/profile` | Save profile changes |
| `GET` | `/login` | Login form |
| `POST` | `/login` | Authenticate |
| `DELETE` | `/logout` | Log out |
| `GET` | `/signup` | Registration form |
| `POST` | `/signup` | Create account |

---

## Business rules

### Task model

```ruby
STATUSES = %w[todo in_progress done]

STATUS_TRANSITIONS = {
  "todo"        => "in_progress",
  "in_progress" => "done",
  "done"        => nil          # terminal
}

PRIORITIES = %w[very_low low medium high very_high]
```

- Title is required; priority defaults to `"medium"`, status to `"todo"`
- `advance_status!` raises an exception if the task is already `done`
- `move` accepts any valid status, enabling drag & drop in any direction

### User model

- Email is required, unique (case-insensitive via `downcase_email` before save), and validated by format
- Nickname is required (2–30 characters)
- `first_name` and `last_name` are optional (max 50 characters each)
- Password must be ≥ 6 characters; `allow_nil: true` allows profile updates without changing it
- `display_name` returns `"First Last"` when set, falls back to `nickname`
- `initials` prefers first/last name letters, falls back to the first two words of `nickname`
- `avatar_color` is deterministic from `user.id` — always the same colour per user
- Avatar priority: uploaded photo (Active Storage) → `avatar_url` → initials badge

### Notes (comments)

- Body is required
- Displayed newest-first (ordered by `updated_at DESC`)
