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
    p text_response
    p "GENERATING IMAGE"
    image_response = client.images.generate(
      parameters: {
        prompt: "Generate me an explainatory image for the following text: #{text_response}",
        size: "512x512"
      }
    )
    session[:text_response] = Redcarpet::Markdown.new(text_response).to_html.html_safe
    session[:image_response] = image_response.dig("data", 0, "url")
    redirect_to root_path
  end


  private

  def client
    @client ||= OpenAI::Client.new
  end
end
