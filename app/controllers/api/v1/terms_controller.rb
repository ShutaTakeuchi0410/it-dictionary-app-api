class Api::V1::TermsController < ApplicationController
  def index
    agent = Mechanize.new
    page = agent.get("https://e-words.jp/w/Web_API.html")
    elements = page.search('#Summary')

    render json: elements.inner_text
  end
end
