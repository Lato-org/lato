module Lato
  class Engine < ::Rails::Engine
    isolate_namespace Lato

    initializer 'lato.importmap', before: 'importmap' do |app|
      app.config.importmap.paths << root.join('config/importmap.rb')
    end

    # TODO: Capire se serve
    # initializer "lato.precompile" do |app|
    #   app.config.assets.paths << root.join("app/javascripts")
    #   app.config.assets.precompile << "lato/application.js"
    # end
  end
end
