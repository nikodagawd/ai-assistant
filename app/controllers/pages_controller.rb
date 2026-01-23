class PagesController < ApplicationController
  before_action :authenticate_user!

  def home
    @chats = current_user.chats.order(created_at: :desc)
    return unless request.post?

    topic         = params[:topic].to_s
    audience      = params[:audience].to_s
    tone          = params[:tone].to_s
    slides_number = params[:slides_number].to_s
    persona       = params[:role].to_s
    persona       = "Presenter" if persona.blank?

    # Clean summary shown to the user (stored as the user message)
    display_prompt = <<~TEXT
      Create a presentation with EXACTLY #{slides_number} slides about: "#{topic}"
      Audience: #{audience}
      Tone: #{tone}
      Persona: #{persona}
    TEXT

    # Hidden strict prompt sent to the LLM
    llm_prompt = build_prompt(topic, audience, tone, slides_number, persona)
    output = generate_presentation(llm_prompt)

    @chat = Chat.create!(
      user: current_user,
      topic: topic,
      audience: audience,
      tone: tone,
      slides_number: slides_number
    )

    @chat.messages.create!(role: "user", content: display_prompt)
    @chat.messages.create!(role: "assistant", content: output)

    html_content = render_to_string(
      template: "chats/reveal_template",
      locals: { chat: @chat },
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

  def build_prompt(topic, audience, tone, slides_number, persona)
    <<~PROMPT
      You are generating content for a web app that renders a Reveal.js slideshow AND shows a Markdown handout below it.

      Create a presentation with EXACTLY #{slides_number} slides about: "#{topic}"
      Audience: #{audience}
      Tone: #{tone}
      Persona: #{persona}

      Persona guidance:
      - Write as if you are the Persona above.
      - Adjust vocabulary, depth, and framing to fit that Persona.
      - Stay appropriate for the stated audience and tone.

      OUTPUT REQUIREMENTS:
      Return exactly TWO sections in this order and with these exact headings:

      ===SLIDES===
      ===HANDOUT===

      Do not output anything before ===SLIDES=== or after the handout.

      SECTION 1: ===SLIDES=== (parsed by code, strict)
      - Each slide MUST start with exactly: Slide X:
      - Next line is the title (one line)
      - Then 3 to 6 short bullet lines (but DO NOT use Markdown symbols like -, *, #)
      - Blank line between slides is allowed

      SECTION 2: ===HANDOUT=== (beautiful Markdown)
      - Start with an H1 title
      - One paragraph executive summary
      - A table of contents (Markdown links)
      - For each slide:
        - H2: Slide X: <Title>
        - Bullets with sub-bullets
        - Optional speaker note as a blockquote
      - End with "Key takeaways" (3 to 5 bullets)
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
