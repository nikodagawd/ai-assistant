class AddPromptAndOutputToChats < ActiveRecord::Migration[7.1]
  def change
    add_column :chats, :prompt, :text
    add_column :chats, :output, :text
    add_column :chats, :topic, :string
    add_column :chats, :audience, :string
    add_column :chats, :tone, :string
    add_column :chats, :slides_number, :integer
  end
end
