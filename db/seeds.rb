puts "Clearing existing data..."
Comment.destroy_all
Task.destroy_all

puts "Creating sample tasks..."

t1 = Task.create!(
  title: "Set up the development environment",
  description: "Install Ruby 3.4, Rails 8.1 and configure the SQLite database. Align versions across all team members.",
  status: "done",
  priority: "high"
)
t1.comments.create!(body: "Environment set up on macOS and Ubuntu. Windows requires WSL2.")
t1.comments.create!(body: "README updated with setup instructions.")

t2 = Task.create!(
  title: "Implement user authentication",
  description: "Use the Rails 8 Authentication Generator (rails generate authentication). Include login, logout and password reset.",
  status: "in_progress",
  priority: "very_high"
)
t2.comments.create!(body: "Generated with `rails generate authentication`. Login pages ready.")
t2.comments.create!(body: "Password reset under testing on staging.")

Task.create!(
  title: "Build statistics dashboard",
  description: "Dashboard showing tasks by status, recent activity and an area chart with Chartkick.",
  status: "todo",
  priority: "medium"
)

Task.create!(
  title: "Add email notifications",
  description: "Notify via Action Mailer when a task is assigned or its status advances.",
  status: "todo",
  priority: "low"
)

Task.create!(
  title: "Optimise N+1 queries",
  description: "Analyse with the Bullet gem, add eager loading and missing indexes.",
  status: "todo",
  priority: "high"
)

puts "✓ #{Task.count} tasks and #{Comment.count} comments created."
