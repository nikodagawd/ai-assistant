class PagesController < ApplicationController
  before_action :authenticate_user!

  def home
    return unless request.post?

    topic         = params[:topic]
    audience      = params[:audience]
    tone          = params[:tone]
    slides_number = params[:slides_number]

      prompt = build_prompt(topic, audience, tone, slides_number)
      output = generate_presentation(prompt)

    chat = Chat.create!(
      user: current_user,
      topic: topic,
      audience: audience,
      tone: tone,
      slides_number: slides_number,
      prompt: prompt,
      output: output
    )
    redirect_to chat_path(chat)
  end

private

  def build_prompt(topic, audience, tone, slides_number)
    <<~PROMPT
      Create a presentation outline on the topic "#{topic}".
      Audience: #{audience}
      Tone: #{tone}
      Number of slides: #{slides_number}
      Output in plain text.
    PROMPT
  end

  def generate_presentation(prompt)
    unless ENV["GITHUB_TOKEN"].present?
      return ":warning: GitHub token not configured yet. Add it to the .env file."
    end

    chat = RubyLLM.chat(model: "gpt-4.1")
    response = chat.ask(prompt)
    response.content
  rescue => e
    ":x: Error generating presentation: #{e.message}"
  end
end
