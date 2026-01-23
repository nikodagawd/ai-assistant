class Message < ApplicationRecord
  belongs_to :chat

  # optional but recommended
  validates :role, presence: true
  validates :content, presence: true
end
