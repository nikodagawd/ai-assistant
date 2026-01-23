class PagesController < ApplicationController
  before_action :authenticate_user!

def home
  @chats = current_user.chats.order(created_at: :desc)

  return unless request.post?

  topic         = params[:topic]
  audience      = params[:audience]
  tone          = params[:tone]
  slides_number = params[:slides_number]

  prompt = build_prompt(topic, audience, tone, slides_number)
  output = generate_presentation(prompt)

  @chat = Chat.create!(
    user: current_user,
    topic: topic,
    audience: audience,
    tone: tone,
    slides_number: slides_number
  )

  @chat.messages.create!(role: "user", content: prompt)
  @chat.messages.create!(role: "assistant", content: output)

  html_content = render_to_string(
    template: "chats/reveal_template",
    locals: { chat: @chat }, # then use `chat` in the template
    layout: false
  )

  @chat.ppt_file.attach(
    io: StringIO.new(html_content),
    filename: "presentation_#{@chat.id}.html",
    content_type: "text/html"
  )

  redirect_to chat_path(@chat)
end

  private

  def build_prompt(topic, audience, tone, slides_number)
    <<~PROMPT
      Create a presentation outline and populate each slide with content on the topic "#{topic}".
      The content for each of the slides shouldnt be exhaustive but should include the key points that should be mentioned along with sub-bullets on each point.
      Audience: #{audience}
      Tone: #{tone}
      Number of slides: #{slides_number}
      Output in Markdown.
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
