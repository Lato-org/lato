require 'net/http'
require 'uri'
require 'fileutils'
require 'nokogiri'
require 'json'

# Configurazione
PORT = 3000
BASE_URL = "http://localhost:#{PORT}"
OUTPUT_DIR = "./docs"
SKILL_DIR = "./docs/SKILL.md"
DOCS_DIR = "./docs/documentation.txt"
AUTH_EMAIL = 'admin@mail.com'
AUTH_PASSWORD = 'Password1!'
AUTH_GET_URL = "#{BASE_URL}/lato/authentication/signin"
AUTH_POST_URL = "#{BASE_URL}/lato/authentication/signin_action"
PAGES = [
  { path: '/?generate_docs=1',            name: 'index.html',         title: 'Overview & Installation' },
  { path: '/tutorial?generate_docs=1',     name: 'tutorial.html',      title: 'Tutorial',        auth: true },
  { path: '/configuration?generate_docs=1',name: 'configuration.html', title: 'Configuration',   auth: true },
  { path: '/customization?generate_docs=1',name: 'customization.html', title: 'Customization',   auth: true },
  { path: '/components?generate_docs=1',   name: 'components.html',    title: 'Components',      auth: true },
  { path: '/operations?generate_docs=1',   name: 'operations.html',    title: 'Operations',      auth: true },
  { path: '/actions?generate_docs=1',      name: 'actions.html',       title: 'Actions',         auth: true },
  { path: '/invitations?generate_docs=1',  name: 'invitations.html',   title: 'Invitations',     auth: true },
  { path: '/guide?generate_docs=1',        name: 'guide.html',         title: 'Guide',           auth: true },
  { path: '/crud?generate_docs=1',         name: 'crud.html',          title: 'CRUD Example',    auth: true },
  { path: '/modules/lato_users?generate_docs=1',    name: 'modules/lato_users.html',    title: 'Module: Lato Users',    auth: true },
  { path: '/modules/lato_settings?generate_docs=1', name: 'modules/lato_settings.html', title: 'Module: Lato Settings', auth: true },
  { path: '/modules/lato_storage?generate_docs=1',  name: 'modules/lato_storage.html',  title: 'Module: Lato Storage',  auth: true },
  { path: '/modules/lato_spaces?generate_docs=1',   name: 'modules/lato_spaces.html',   title: 'Module: Lato Spaces',   auth: true },
  { path: '/modules/lato_cms?generate_docs=1',      name: 'modules/lato_cms.html',      title: 'Module: Lato CMS',      auth: true },
  { path: '/products?generate_docs=1',     name: 'products.html',      title: 'Products',        auth: true },
]

SKILL_FRONTMATTER = <<~YAML
  ---
  name: lato
  description: >
    Use this skill when working with the Lato Rails gem (admin panel engine).
    Provides full documentation: installation, configuration, authentication,
    UI components, CRUD patterns, background operations, invitations, modules,
    layout customization and guides. USE FOR: installing lato, configuring lato,
    lato components, lato forms, lato index table, lato operations, lato
    invitations, lato authentication, lato layout, lato customization, lato CRUD,
    lato_users, lato_settings, lato_storage, lato_spaces, lato_cms.
  ---
YAML

# Assicurati che la directory di output esista
FileUtils.mkdir_p(OUTPUT_DIR) if !Dir.exist?(OUTPUT_DIR)

# Svuota la directory di output da tutti i file e cartelle escluso CNAME (generato da github pages per collegamento dominio)
exceptions = ['CNAME']
FileUtils.rm_rf(Dir.glob("#{OUTPUT_DIR}/*").reject { |f| exceptions.include?(File.basename(f)) })

def download_page(page, http = nil, cookies = {})
  url = BASE_URL + page[:path]
  uri = URI.parse(url)

  # Initialize HTTP session if not provided
  http ||= Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == 'https'

  # If the page requires authentication, perform login if no cookies are present
  if page[:auth] && cookies.empty?
    cookies = perform_login(http)
    raise "Login fallito per #{url}" if cookies.empty?
  end

  # Prepare the request
  request = Net::HTTP::Get.new(uri)
  # Add cookies to the request if any
  unless cookies.empty?
    cookie_string = cookies.map { |k, v| "#{k}=#{v}" }.join('; ')
    request['Cookie'] = cookie_string
  end

  # Send the request
  response = http.request(request)

  if response.code == "200"
    return response.body, http, cookies
  else
    puts "Errore durante il download della pagina #{url}: #{response.code} #{response.message}"
    return nil, http, cookies
  end
end

def perform_login(http)
  # Download AUTH_GET_URL to get the CSRF token
  auth_get_response = http.get(URI.parse(AUTH_GET_URL).path)
  if auth_get_response.code != "200"
    puts "Errore durante il download della pagina di login: #{auth_get_response.code} #{auth_get_response.message}"
    return {}
  end

  # Parse the CSRF token using Nokogiri
  doc = Nokogiri::HTML(auth_get_response.body)
  csrf_token = doc.at('meta[name="csrf-token"]')&.[]('content') || 
               doc.at('input[name="authenticity_token"]')&.[]('value')
  puts "CSRF Token: #{csrf_token}"
  if csrf_token.nil?
    puts "Impossibile trovare il CSRF token"
    return {}
  end

  # Perform the login POST request
  uri = URI.parse(AUTH_POST_URL)
  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/x-www-form-urlencoded'

  # Include any cookies from the GET request (e.g., session cookie)
  cookies = {}
  if auth_get_response['Set-Cookie']
    auth_get_response['Set-Cookie'].split(/,\s*/).each do |cookie|
      next unless cookie =~ /([^=]+)=([^;]+)/
      key, value = $1.strip, $2.strip
      cookies[key] = value
    end
    request['Cookie'] = cookies.map { |k, v| "#{k}=#{v}" }.join('; ')
  end

  request.body = URI.encode_www_form({
    'user[email]' => AUTH_EMAIL,
    'user[password]' => AUTH_PASSWORD,
    'authenticity_token' => csrf_token
  })

  response = http.request(request)
  puts "Login response code: #{response.code}"

  if response.code == "302"
    # Update cookies with new ones from the response
    if response['Set-Cookie']
      response['Set-Cookie'].split(/,\s*/).each do |cookie|
        next unless cookie =~ /([^=]+)=([^;]+)/
        key, value = $1.strip, $2.strip
        cookies[key] = value
      end
    end
    puts "Cookies: #{cookies.inspect}"
    return cookies
  else
    puts "Errore durante il login: #{response.code}"
    return {}
  end
end

def save_file(path, content)
  full_path = File.join(OUTPUT_DIR, path)
  
  # Assicurati che la directory esista
  FileUtils.mkdir_p(File.dirname(full_path))
  
  File.write(full_path, content)
  puts "Salvato: #{full_path}"
end

def download_asset(url, http, cookies)
  begin
    uri = URI.parse(url)
    
    # Se l'URL è relativo, aggiungi il BASE_URL
    if uri.host.nil?
      full_url = url.start_with?('/') ? BASE_URL + url : BASE_URL + '/' + url
      uri = URI.parse(full_url)
    end
    
    request = Net::HTTP::Get.new(uri)
    # Add cookies to the request if any
    unless cookies.empty?
      cookie_string = cookies.map { |k, v| "#{k}=#{v}" }.join('; ')
      request['Cookie'] = cookie_string
    end

    # Use the existing HTTP session
    response = http.request(request)
    
    if response.code == "200"
      # Determina il percorso locale per il file
      local_path = uri.path

      # Salva il file
      save_file(local_path, response.body)
      
      return true
    else
      puts "Errore durante il download dell'asset #{url}: #{response.code} #{response.message}"
      return false
    end
  rescue => e
    puts "Errore durante il download dell'asset #{url}: #{e.message}"
    return false
  end
end

def process_html(html_content, http, cookies, page = nil)
  doc = Nokogiri::HTML(html_content)
  
  # Processa i file CSS
  doc.css('link[rel="stylesheet"]').each do |link|
    href = link['href']
    next if href.nil? || href.empty? || href.start_with?('http://', 'https://', '//')
    download_asset(href, http, cookies)
  end
  
  # Processa i file JavaScript
  doc.css('script').each do |script|
    src = script['src']
    next if src.nil? || src.empty? || src.start_with?('http://', 'https://', '//')
    download_asset(src, http, cookies)
  end
  
  # Processa le immagini
  doc.css('img').each do |img|
    src = img['src']
    next if src.nil? || src.empty? || src.start_with?('http://', 'https://', '//')
    download_asset(src, http, cookies)
  end

  # Processa i <link rel="modulepreload" href="#">
  doc.css('link[rel="modulepreload"]').each do |link|
    href = link['href']
    next if href.nil? || href.empty? || href.start_with?('http://', 'https://', '//')
    download_asset(href, http, cookies)
  end

  # Sostituisci tutti i data-turbo-method con il metodo corretto (GET)
  doc.css('a[data-turbo-method]').each do |link|
    method = link['data-turbo-method']
    next if method.nil? || method.empty?
    
    # Sostituisci il metodo con GET
    link['data-turbo-method'] = 'GET'
  end

  # Sostituisci tutti i form con il metodo corretto (GET)
  doc.css('form').each do |form|
    method = form['method']
    next if method.nil? || method.empty?

    form['method'] = 'GET'
  end

  # Sostituisci tutti i link relativi con i percorsi locali corrispondenti
  # Esempio: /customization -> ./customization.html
  # Altrimenti forza messaggio di errore
  pages_paths = PAGES.map { |page| page[:path].sub(/\?generate_docs=1$/, '') }
  relative_prefix = page ? '../' * (File.dirname(page[:name]).split('/').reject { |part| part == '.' }.length) : ''
  doc.css('a').each do |link|
    href = link['href']
    next if href.nil? || href.empty? || href.start_with?('http://', 'https://', '//')

    # Se l'URL è relativo, aggiungi il BASE_URL
    if href == '/'
      link['href'] = "#{relative_prefix}index.html"
    elsif href.start_with?('/') && pages_paths.include?(href)
      link['href'] = "#{relative_prefix}#{href[1..-1]}.html"
    else
      link['href'] = 'javascript:alert("This link is not available in the documentation. To test the full functionality of Lato, install and run the gem locally.")'
    end
  end

  return doc.to_html
end

# Export pages
http = nil
cookies = {}
PAGES.each do |page|
  html_content, http, cookies = download_page(page, http, cookies)
  raise "Impossibile scaricare la pagina #{page[:path]}" unless html_content

  processed_html = process_html(html_content, http, cookies, page)
  save_file(page[:name], processed_html)
end

# Generate SKILL.md from all HTML pages
File.open(SKILL_DIR, 'w') do |skill_file|
  skill_file.print SKILL_FRONTMATTER
  skill_file.puts
  skill_file.puts '# Lato Rails Gem'
  skill_file.puts
  skill_file.puts 'Lato is a Rails engine that provides a fully-featured admin panel with '\
                  'authentication, responsive UI (Bootstrap), background job operations, '\
                  'invitation system, and rich UI components ready to use in any Rails 7+ app.'
  skill_file.puts

  pages = PAGES.reject { |p| %w[products.html].include?(p[:name]) }

  pages.each do |page|
    file_path = File.join(OUTPUT_DIR, page[:name])
    next unless File.exist?(file_path)

    doc = Nokogiri::HTML(File.read(file_path))
    main = doc.at('main')
    next unless main

    main.css('.example, .llm-ignore').each(&:remove)

    section_title = page[:title] || page[:name].sub('.html', '').capitalize
    content = main.text.strip.gsub(/\s+/, ' ')

    skill_file.puts "\n## #{section_title}\n"
    skill_file.puts content
    skill_file.puts
  end
end
puts "Salvato: #{SKILL_DIR}"

# Generate documentation.txt (plain text, one section per page separated by -)
File.open(DOCS_DIR, 'w') do |docs_file|
  pages = PAGES.reject { |p| %w[products.html].include?(p[:name]) }

  pages.each do |page|
    file_path = File.join(OUTPUT_DIR, page[:name])
    next unless File.exist?(file_path)

    doc = Nokogiri::HTML(File.read(file_path))
    main = doc.at('main')
    next unless main

    main.css('.example, .llm-ignore').each(&:remove)

    main.css('a').each do |link|
      href = link['href']
      next unless href&.start_with?('http://', 'https://', '//')
      link.replace("[#{link.text}](#{href})")
    end

    content = main.text.strip.gsub(/\s+/, ' ')
    docs_file.puts content
    docs_file.puts "-"
  end
end
puts "Salvato: #{DOCS_DIR}"
