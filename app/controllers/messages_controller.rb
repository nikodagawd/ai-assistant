class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = current_user.chats.find(params[:chat_id])

    @message = @chat.messages.create!(
      role: "user",
      content: params[:message][:content]
    )
    if @message.save
     @ruby_llm_chat = RubyLLM.chat(model: "gpt-4.1")
      build_conversation_history
      response = @ruby_llm_chat.ask(@message.content)

      @chat.messages.create(role: "assistant", content: response.content)
    else
      render "chats/show", status: :unprocessable_entity
    end
    redirect_to chat_path(@chat)
  end

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end
end
