class PagesController < ApplicationController
  def home
    if request.post?
      topic = params[:topic]
      audience = params[:audience]
      tone = params[:tone]
      slides_number = params[:slides_number]

      @output = generate_presentation(topic, audience, tone, slides_number)
    end
  end

  private

  def generate_presentation(topic, audience, tone, slides_number)
    require "openai"

    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    prompt = <<~PROMPT
      Create a presentation outline on the topic "#{topic}".
      Audience: #{audience}
      Tone: #{tone}
      Number of slides: #{slides_number}
      Output in plain text.
    PROMPT

    response = client.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          { role: "user", content: prompt }
        ],
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")
  rescue => e
    "Error generating presentation: #{e.message}"
  end
end
