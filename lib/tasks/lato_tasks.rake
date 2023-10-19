require 'fileutils'

namespace :lato do
  namespace :install do
    desc 'Install Lato engine and run tasks on main rails application'
    # Usage: rails lato:install:application
    task :application do
      # Copy all "_content.html.erb" parials on layouts/lato from gem to main application
      ##

      gem_layout_path = Lato::Engine.root.join('app', 'views', 'layouts', 'lato').to_s
      app_layout_path = Rails.root.join('app', 'views', 'layouts', 'lato').to_s

      # create app layout path if not exists
      FileUtils.mkdir_p(app_layout_path)

      # list patials inside gem_layout_path
      partials_content_files = Dir.glob("#{gem_layout_path}/*_content.html.erb")

      # copy partials from gem to main app
      partials_content_files.each do |src_file_pathname|
        src_file_path = src_file_pathname.to_s
        dest_file_path = src_file_path.gsub(gem_layout_path, app_layout_path)
        file_name = src_file_path.gsub(gem_layout_path, '')
        next if file_name == '/_content.html.erb'

        FileUtils.copy(src_file_path, dest_file_path) unless File.exist? dest_file_path
      end

      # Copy "lato_user_application.rb" model concern from gem to main application
      ##

      gem_concern_path = Lato::Engine.root.join('app', 'models', 'concerns', 'lato_user_application.rb').to_s
      app_concern_path = Rails.root.join('app', 'models', 'concerns', 'lato_user_application.rb').to_s
      FileUtils.copy(gem_concern_path, app_concern_path) unless File.exist? app_concern_path

      # Generate sample manifest.json file in public folder
      ##

      manifest_path = Rails.root.join('public', 'manifest.json')
      unless File.exist? manifest_path
        manifest = {
          name: "Application",
          short_name: "Application",
          start_url: "/",
          scope: "/",
          display: "standalone",
          orientation: "portrait",
          theme_color: "#000000",
          background_color: "#000000",
          icons: []
        }
        File.open(manifest_path, 'w') { |f| f.write(manifest.to_json) }
      end

      # Generate sample service-worker.js file in public folder
      ##

      service_worker_path = Rails.root.join('public', 'service-worker.js')
      unless File.exist? service_worker_path
        service_worker = <<-JS
        function onInstall(event) {
          console.log('[Serviceworker]', "Installing!", event);
        }
        function onActivate(event) {
          console.log('[Serviceworker]', "Activating!", event);
        }
        function onFetch(event) {
          console.log('[Serviceworker]', "Fetching!", event);
        }
        self.addEventListener('install', onInstall);
        self.addEventListener('activate', onActivate);
        self.addEventListener('fetch', onFetch);
        JS
        File.open(service_worker_path, 'w') { |f| f.write(service_worker) }
      end
    end
  end

  namespace :generate do
    desc "Generate PWA icons from a single icon.png file (512x512) that should be placed inside 'public' folder"
    # Usage: rails lato:generate:pwa
    task :pwa do
      # check if icon.png exists
      icon_path = Rails.root.join('public', 'icon.png')
      unless File.exist? icon_path
        puts 'ERROR: icon.png file not found inside public folder'
        return
      end

      # check MiniMagick is installed
      begin
        require 'mini_magick'
      rescue LoadError
        puts 'ERROR: mini_magick gem not found, please add it to your Gemfile'
        return
      end

      # be sure icon.png is min 512x512
      image = MiniMagick::Image.open(icon_path)
      if image.width < 512 || image.height < 512 || image.width != image.height
        puts 'ERROR: icon.png image size is not valid, it should be square and min 512x512'
        return
      end

      # create icons folder if not exists
      icons_path = Rails.root.join('public', 'icons')
      FileUtils.mkdir_p(icons_path) unless File.exist? icons_path

      # create icons
      sizes = [16, 32, 48, 72, 96, 144, 152, 192, 384, 512]
      sizes.each do |size|
        file_path = "#{icons_path}/icon_#{size}x#{size}.png"
        file_image = MiniMagick::Image.open(icon_path)
        FileUtils.rm(file_path) if File.exist? file_path
        file_image.resize "#{size}x#{size}"
        file_image.write file_path
      end

      # create manifest.json
      manifest_path = Rails.root.join('public', 'manifest.json')
      manifest = {
        name: Lato.config.application_title,
        short_name: Lato.config.application_title,
        start_url: '/',
        scope: '/',
        display: 'standalone',
        orientation: 'portrait',
        theme_color: Lato.config.application_brand_color,
        background_color: Lato.config.application_brand_color,
        icons: []
      }
      sizes.each do |size|
        manifest[:icons] << {
          src: "/icons/icon_#{size}x#{size}.png",
          sizes: "#{size}x#{size}",
          type: 'image/png'
        }
      end
      FileUtils.rm(manifest_path) if File.exist? manifest_path
      File.open(manifest_path, 'w') { |f| f.write(manifest.to_json) }
    end

    desc "Generate favicon.ico from a single icon.png file (512x512) that should be placed inside 'public' folder"
    # Usage: rails lato:generate:favicon
    task :favicon do
      # check if icon.png exists
      icon_path = Rails.root.join('public', 'icon.png')
      unless File.exist? icon_path
        puts 'ERROR: icon.png file not found inside public folder'
        return
      end

      # check MiniMagick is installed
      begin
        require 'mini_magick'
      rescue LoadError
        puts 'ERROR: mini_magick gem not found, please add it to your Gemfile'
        return
      end

      # be sure icon.png is min 512x512
      image = MiniMagick::Image.open(icon_path)
      if image.width < 512 || image.height < 512 || image.width != image.height
        puts 'ERROR: icon.png image size is not valid, it should be square and min 512x512'
        return
      end

      # create favicon.ico
      file_path = Rails.root.join('public', 'favicon.ico')
      file_image = MiniMagick::Image.open(icon_path)
      FileUtils.rm(file_path) if File.exist? file_path
      file_image.resize '48x48'
      file_image.write file_path
    end
  end
end
