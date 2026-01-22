class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: [:show, :update, :reveal, :destroy]

  def index
    @chats = current_user.chats.order(created_at: :desc)
  end

  def show
    @chat = Chat.find(params[:id])
    @messages = @chat.messages.order(:created_at)
    @message = Message.new
    @chats = current_user.chats.order(created_at: :desc)
  end

  def reveal
    
  end

  def update
    if @chat.update(chat_params)
      redirect_to chat_path(@chat), notice: "Feedback sent!"
    else
      render :show, alert: "Could not send feedback"
    end
  end

  def destroy
    @chat.destroy
    redirect_to chats_path, notice: "Presentation deleted"
  end

  private

  def set_chat
    @chat = current_user.chats.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:feedback)
  end
end
