class User < ApplicationRecord
  has_secure_password
  has_one_attached :photo

  has_many :created_tasks,  class_name: "Task", foreign_key: :creator_id,  dependent: :nullify
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assignee_id, dependent: :nullify
  has_many :comments, dependent: :nullify

  validates :email,      presence: true,
                         uniqueness: { case_insensitive: true },
                         format: { with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/, message: "is not a valid address" }
  validates :nickname,   presence: { message: "cannot be empty" },
                         length: { in: 2..30 }
  validates :first_name, length: { maximum: 50 }, allow_blank: true
  validates :last_name,  length: { maximum: 50 }, allow_blank: true
  validates :password,   length: { minimum: 6, message: "must be at least 6 characters" },
                         allow_nil: true

  before_save :downcase_email

  # Full name when first/last are set, otherwise fall back to nickname
  def display_name
    full = [ first_name, last_name ].compact_blank.join(" ")
    full.present? ? full : nickname
  end

  # Initials: prefer first/last name, fall back to nickname words
  def initials
    parts = [ first_name, last_name ].compact_blank
    parts = nickname.split if parts.empty?
    parts.map { |w| w[0].upcase }.first(2).join
  end

  # Deterministic colour from id so the same user always gets the same avatar colour
  AVATAR_PALETTE = %w[#4a8fd4 #4aad74 #d4a843 #9b6dd4 #d45252 #4accc4 #e67e22 #16a085].freeze

  def avatar_color
    AVATAR_PALETTE[id % AVATAR_PALETTE.size]
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
