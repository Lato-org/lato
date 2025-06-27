require 'net/http'
require 'uri'
require 'fileutils'
require 'nokogiri'
require 'json'

# Configurazione
PORT = 3000
BASE_URL = "http://localhost:#{PORT}"
OUTPUT_DIR = "./docs"
LLM_DIR = "./docs/llm.txt"
AUTH_EMAIL = 'admin@mail.com'
AUTH_PASSWORD = 'Password1!'
AUTH_GET_URL = "#{BASE_URL}/lato/authentication/signin"
AUTH_POST_URL = "#{BASE_URL}/lato/authentication/signin_action"
PAGES = [
  { path: '/?generate_docs=1', name: 'index.html' },
  # tutorial
  { path: '/tutorial?generate_docs=1', name: 'tutorial.html', auth: true },
  # configuration
  { path: '/configuration?generate_docs=1', name: 'configuration.html', auth: true },
  # customization
  { path: '/customization?generate_docs=1', name: 'customization.html', auth: true },
  # components
  { path: '/components?generate_docs=1', name: 'components.html', auth: true },
  # operations
  { path: '/operations?generate_docs=1  ', name: 'operations.html', auth: true },
  # actions
  { path: '/actions?generate_docs=1', name: 'actions.html', auth: true },
  # invitations
  { path: '/invitations?generate_docs=1', name: 'invitations.html', auth: true },
  # guide
  { path: '/guide?generate_docs=1', name: 'guide.html', auth: true },
  # products
  { path: '/products?generate_docs=1', name: 'products.html', auth: true },
]

# Assicurati che la directory di output esista
FileUtils.mkdir_p(OUTPUT_DIR) if !Dir.exist?(OUTPUT_DIR)

# Svuota la directory di output da tutti i file e cartelle escluso CNAME (generato da github pages per collegamento dominio)
exceptions = ['CNAME', 'AI.html']
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

def process_html(html_content, http, cookies)
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
  pages_paths = PAGES.map { |page| page[:path] }
  doc.css('a').each do |link|
    href = link['href']
    next if href.nil? || href.empty? || href.start_with?('http://', 'https://', '//')

    # Se l'URL è relativo, aggiungi il BASE_URL
    if href == '/'
      link['href'] = 'index.html'
    elsif href == '/lato/authentication/signin'
      link['href'] = 'tutorial.html'
    elsif href.start_with?('/') && pages_paths.include?(href)
      link['href'] = href[1..-1] + '.html'
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

  processed_html = process_html(html_content, http, cookies)
  save_file(page[:name], processed_html)
end

# Read all .html file on OUTPUT_DIR, for each file export the body content and append on a txt file used to train LLMs
File.open(LLM_DIR, 'w') do |llm_file|
  Dir.glob("#{OUTPUT_DIR}/*.html").each do |file_path|
    next if File.basename(file_path).start_with?('AI.html') # skip AI.html
    next if File.basename(file_path) == 'products.html' # skip products.html

    doc = Nokogiri::HTML(File.read(file_path))
    main = doc.at('main')

    # Rimuovo da main tutti i tag con classe .example
    main.css('.example').each do |example|
      example.remove
    end

    # Rimuovo tutti i tag con classe .llm-ignore
    main.css('.llm-ignore').each do |llm_ignore|
      llm_ignore.remove
    end

    # Sostituisco tutti i link assoluti in testo (esempio <a href="https://google.com">Google</a> -> [Google](https://google.com))
    main.css('a').each do |link|
      href = link['href']
      next unless href&.start_with?('http://', 'https://', '//')

      # Sostituisci il link con il formato Markdown
      link.replace("[#{link.text}](#{href})")
    end

    # Estraggo il contenuto come testo
    content = main.text.strip.gsub(/\s+/, ' ')

    llm_file.puts content
    llm_file.puts "----------------------------------------"
  end
end
