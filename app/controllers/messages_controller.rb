class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = current_user.chats.find(params[:chat_id])

    user_text = params.dig(:message, :content).to_s.strip

    @message = @chat.messages.new(role: "user", content: user_text)

    unless @message.save
      @messages = @chat.messages.order(:created_at)
      @chats    = current_user.chats.order(created_at: :desc)
      flash.now[:alert] = "Could not send message"
      return render "chats/show", status: :unprocessable_entity
    end

    last_assistant = @chat.messages.where(role: "assistant").order(:created_at).last&.content.to_s
    slide_count = extract_slide_count(last_assistant)

    llm_prompt = build_followup_prompt(
      user_text: user_text,
      previous_output: last_assistant,
      slide_count: slide_count,
      chat: @chat
    )

    ruby_llm_chat = RubyLLM.chat(model: "gpt-4.1")
    response = ruby_llm_chat.ask(llm_prompt)

    @chat.messages.create!(role: "assistant", content: response.content.to_s)

    redirect_to chat_path(@chat)
  end

  private

  def extract_slide_count(output)
    slides_block = output.split("===HANDOUT===")[0].to_s
    slides_block.scan(/Slide\s+\d+\s*:/i).size
  end

  def build_followup_prompt(user_text:, previous_output:, slide_count:, chat:)
    persona = chat.respond_to?(:persona) ? chat.persona.to_s : ""
    persona = "Presenter" if persona.blank?

    # If user says "add another slide", we enforce exactly +1 slide
    wants_add_slide = user_text.match?(/\b(add|insert)\b.*\bslide\b/i)

    target_slides = slide_count
    target_slides = slide_count + 1 if wants_add_slide && slide_count > 0

    <<~PROMPT
      You are editing an existing presentation. You MUST preserve format and numbering exactly.

      IMPORTANT OUTPUT RULES:
      - Output EXACTLY two sections with these headings, in this order:
        ===SLIDES===
        ===HANDOUT===
      - Do NOT output any extra text before ===SLIDES=== or after the handout.
      - Do NOT say things like "Certainly" or "Here is the updated presentation".
      - In ===SLIDES===:
        - Each slide MUST start with exactly: Slide X:
        - Next line is the title (one line)
        - Then 3 to 6 short bullet lines
        - DO NOT use Markdown symbols in slides (no -, *, #, **)
      - In ===HANDOUT===: Use polished Markdown with a TOC and per-slide sections.

      CONTEXT:
      Audience: #{chat.audience}
      Tone: #{chat.tone}
      Persona: #{persona}

      PREVIOUS OUTPUT (you must edit this, not restart from scratch):
      #{previous_output}

      USER REQUEST:
      #{user_text}

      EDITING REQUIREMENTS:
      - Keep the original slide titles and content unless the user explicitly asked to change them.
      - If the user asked to add a slide, add EXACTLY ONE new slide at the end, continuing numbering.
      - Total slides must be EXACTLY #{target_slides}.

      Now output the updated presentation in the required two-section format.
    PROMPT
  end
end
