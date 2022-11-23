require 'fileutils'

namespace :lato do
  namespace :install do
    desc 'Install Lato engine and run tasks on main rails application'
    task :application do
      # Copy all "_content.html.erb" parials on layouts/lato from gem to main application
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
    end
  end
end
