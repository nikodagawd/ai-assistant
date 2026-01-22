
class ChatsController < ApplicationController
  def show
    @chat = Chat.find(params[:id])
  end


  def index
    @chats = current_user.chats.order(created_at: :desc)
  end
end
