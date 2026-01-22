class AddAttachmentToChats < ActiveRecord::Migration[7.1]
  def change
    add_column :chats, :attachment, :string
  end
end
