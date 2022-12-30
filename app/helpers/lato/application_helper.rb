module Lato
  module ApplicationHelper
    include Lato::ComponentsHelper

    def locale_to_flag(locale)
      locale = locale.to_s.upcase
      locale = 'GB' if locale == 'EN'

      locale.tr('A-Z', "\u{1F1E6}-\u{1F1FF}")
    end
  end
end
