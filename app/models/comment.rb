class Comment < ApplicationRecord
  belongs_to :task
  belongs_to :user, optional: true

  validates :body, presence: true
end
