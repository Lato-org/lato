module Lato
  class Engine < ::Rails::Engine
    isolate_namespace Lato

    initializer 'lato.importmap', before: 'importmap' do |app|
      app.config.importmap.paths << Lato::Engine.root.join('config/importmap.rb')
    end
  end
end
