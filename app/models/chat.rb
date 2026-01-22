class Chat < ApplicationRecord
  belongs_to :user

  has_one_attached :attachment
  has_one_attached :ppt_file    
end
