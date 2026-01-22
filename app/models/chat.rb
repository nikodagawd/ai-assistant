class Chat < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :destroy

  has_one_attached :attachment
  has_one_attached :ppt_file    
end
