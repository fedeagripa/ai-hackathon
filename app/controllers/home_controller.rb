# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
  end

  def generate
    text = params["content"]["text"]
    p "GENERATING TEXT"
    response = client.chat(
      parameters: {
          model: "gpt-4",
          messages: [{ role: 'user', content: text }],
          temperature: 0.7
      }
    )
    p "RESPONSE WAS DONE"
    text_response = response.dig("choices", 0, "message", "content")
    p "GENERATING IMAGE"
    image_response = client.images.generate(
      parameters: {
        prompt: "#{image_prompt} #{text_response}",
        size: "512x512"
      }
    )
    p "GENERATING STORY"
    story = client.chat(
      parameters: {
          model: "gpt-4",
          messages: [{ role: 'user', content: text_response }],
          temperature: 0.7
      }
    )
    storytell_response = story.dig("choices", 0, "message", "content")
    session[:text_response] = text_response
    session[:image_response] = image_response.dig("data", 0, "url")
    session[:storytell] = storytell_response
    redirect_to root_path
  end


  private

  def client
    @client ||= OpenAI::Client.new
  end

  def image_prompt
    "Generate me an explainatory image for the following text: "
  end

  def storytell
    "The following markdown is for an educational article for school students in grade 6. I want you to story tell to one student it in plain text in a funny and interesting way. be creative Here are some important rules to follow: - always use full sentences in a story told way, and never use bullet lists, tables, or anything similar that can make things less listenable. here is the markdown: "
  end
end
