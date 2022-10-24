namespace :lato do
  namespace :install do
    desc 'Install lato engine assets on your applicaction'
    task :assets do
      # Copy sass assets to main application
      src = "#{Lato::Engine.root}/app/assets/stylesheets/lato"
      dst = "#{Rails.root}/app/assets/stylesheets"
      FileUtils.copy_entry(src, dst)

      # Copy js assets to main application
      src = "#{Lato::Engine.root}/app/assets/javascript/lato"
      dst = "#{Rails.root}/app/javascript"
      FileUtils.copy_entry(src, dst)
    end
  end
end
