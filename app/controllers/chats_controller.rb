class ChatsController < ApplicationController
  before_action :authenticate_user!

  def index
    @chats = current_user.chats.order(created_at: :desc)
  end

  def show
    @chat = Chat.find(params[:id])
    @messages = @chat.messages.order(:created_at)
    @message = Message.new
  end
end
