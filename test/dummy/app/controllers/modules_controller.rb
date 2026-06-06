require "net/http"
require "uri"

class ModulesController < ApplicationController
  before_action :authenticate_session
  before_action { active_sidebar(:modules) }

  def show
    @module_key = params[:id]
    @module_config = lato_modules[@module_key]

    return redirect_to main_app.root_path, alert: "Module documentation not found." unless @module_config

    active_sidebar(@module_key.to_sym)

    @module_documentation_html = fetch_module_documentation(@module_config[:raw_url])
  end

  private

  def lato_modules
    LATO_MODULES
  end

  def fetch_module_documentation(raw_url)
    uri = URI.parse(raw_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 5
    http.read_timeout = 10

    response = http.get(uri.request_uri)
    return strip_erb(response.body) if response.code == "200"

    @module_documentation_error = "Documentation download failed: #{response.code} #{response.message}"
    nil
  rescue StandardError => e
    @module_documentation_error = "Documentation download failed: #{e.message}"
    nil
  end

  def strip_erb(content)
    content
      .gsub(/<%=\s*lato_page_head[\s\S]*?%>/, "")
      .gsub(/<%[\s\S]*?%>/, "")
  end
end
