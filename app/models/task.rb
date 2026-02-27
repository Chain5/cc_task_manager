class Task < ApplicationRecord
  STATUSES = %w[todo in_progress done].freeze

  STATUS_TRANSITIONS = {
    "todo"        => "in_progress",
    "in_progress" => "done",
    "done"        => nil
  }.freeze

  STATUS_LABELS = {
    "todo"        => "To do",
    "in_progress" => "In progress",
    "done"        => "Completed"
  }.freeze

  PRIORITIES = %w[very_low low medium high very_high].freeze

  PRIORITY_LABELS = {
    "very_low"  => "Very Low",
    "low"       => "Low",
    "medium"    => "Medium",
    "high"      => "High",
    "very_high" => "Very High"
  }.freeze

  # Higher number = higher priority (used in SQL ORDER)
  PRIORITY_RANK = {
    "very_high" => 5,
    "high"      => 4,
    "medium"    => 3,
    "low"       => 2,
    "very_low"  => 1
  }.freeze

  belongs_to :creator,  class_name: "User", foreign_key: :creator_id,  optional: true
  belongs_to :assignee, class_name: "User", foreign_key: :assignee_id, optional: true

  has_many :comments, dependent: :destroy

  validates :title,    presence:  { message: "cannot be empty" }
  validates :status,   inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }

  before_validation :set_defaults, on: :create

  scope :by_status, ->(status) { status.present? ? where(status: status) : all }
  scope :ordered, -> {
    order(
      Arel.sql(<<~SQL.squish),
        CASE priority
          WHEN 'very_high' THEN 5
          WHEN 'high'      THEN 4
          WHEN 'medium'    THEN 3
          WHEN 'low'       THEN 2
          WHEN 'very_low'  THEN 1
          ELSE 0
        END DESC
      SQL
      created_at: :asc
    )
  }

  def next_status
    STATUS_TRANSITIONS[status]
  end

  def can_advance?
    next_status.present?
  end

  def advance_status!
    raise "Task is already completed" unless can_advance?
    update!(status: next_status)
  end

  def status_label
    STATUS_LABELS[status]
  end

  def status_css
    status.tr("_", "-")
  end

  def priority_label
    PRIORITY_LABELS[priority]
  end

  def priority_css
    "priority--#{priority.tr('_', '-')}"
  end

  private

  def set_defaults
    self.status   ||= "todo"
    self.priority ||= "medium"
  end
end
