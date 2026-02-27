# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

- **Ruby** 3.4.2+ / **Rails** 8.1.2
- **Database**: SQLite 3 (gem `sqlite3 >= 2.1`)
- **Asset pipeline**: Propshaft (not Sprockets)
- **JS**: Importmap + Hotwire (Turbo + Stimulus) — no Node/npm/webpack

## Common Commands

```bash
bundle install
rails db:create db:migrate
rails db:seed          # load sample data
rails server       # start at http://localhost:3000

rubocop            # linting (rubocop-rails-omakase style)
brakeman           # security static analysis
bundler-audit      # gem vulnerability audit
ci                 # run all CI checks
```

Run a single test file:
```bash
rails test test/path/to/test_file.rb
```

## Architecture

### Models

- **Task** (`app/models/task.rb`): Central model. Has `STATUSES`, `STATUS_TRANSITIONS`, and `STATUS_LABELS` constants. Status is unidirectional: `todo → in_progress → done`. Key methods: `advance_status!` (raises if already done), `can_advance?`, `next_status`, `status_label`, `status_css`. Scopes: `by_status` (no-op when blank), `ordered` (asc by `created_at`).
- **Comment** (`app/models/comment.rb`): Belongs to Task, has a required `body`. Tasks `dependent: :destroy` their comments.

### Controllers

- **TasksController**: Standard CRUD + custom `advance_status` member action (`PATCH /tasks/:id/advance_status`). The `index` action computes per-status counts for the filter UI.
- **CommentsController**: Nested under tasks (`/tasks/:task_id/comments`). Only `create` and `destroy` actions.

### Frontend

- Flash messages auto-dismiss after 4 seconds via the Stimulus `flash_controller.js`.
- No custom JS beyond that — all interactivity uses Turbo Drive/Forms.
- Styles live in `app/assets/stylesheets/application.css` (dark industrial theme).

### Database Schema

```
tasks:    id, title (string, NOT NULL), description (text), status (string, default "todo"), created_at, updated_at
comments: id, body (text, NOT NULL), task_id (FK), created_at, updated_at
```

Indexes on `tasks.status`, `tasks.created_at`, and `comments.task_id`.
