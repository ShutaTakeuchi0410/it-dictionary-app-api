class Api::V1::TermsController < ApplicationController
  def index
    agent = Mechanize.new
    agent.user_agent = 'Mac Mozilla'

    # Google検索
    agent.get('https://www.google.co.jp/')
    agent.page.form_with(name: 'f') do |form|
        form.q = "site:https://e-words.jp #{params[:keyword]}"
    end.submit
    
    # 検索結果のリンク
    google_links = agent.page.links

    status = false
    data = nil

    google_links.each do |google_link|
      if google_link.uri.to_s.start_with?('/url?q=https://e-words.jp/w/')
        # 最初にヒットした「e-Words」のリンクをクリック
        e_words_page = google_link.click

        # 各種情報を取得
        # NOTE: stripメソッドで特殊文字が存在してる場合に取りぞいています。
        url = e_words_page.uri.to_s
        name = e_words_page.search('//*[@id="content"]/article/h1/span[1]').inner_text.strip
        summary = e_words_page.search('//*[@id="Summary"]').inner_text.strip
        detail = e_words_page.search('//*[@id="content"]/article/p[1]').inner_text.strip

        status = true
        data = { url: url, name: name, summary: summary, detail: detail }

        break
      end
    end

    render json: { status: status, data: data }
  end
end