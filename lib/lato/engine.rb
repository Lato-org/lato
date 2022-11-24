module Lato
  class Engine < ::Rails::Engine
    isolate_namespace Lato

    initializer 'lato.importmap', before: 'importmap' do |app|
      app.config.importmap.paths << root.join('config/importmap.rb')
    end

    initializer "lato.precompile" do |app|
      app.config.assets.precompile << "lato_manifest.js"
    end
  end
end
