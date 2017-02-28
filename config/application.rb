require File.expand_path('../boot', __FILE__)
require 'rails/all'
Bundler.require(*Rails.groups)

module Heather
  class Application < Rails::Application
    config.time_zone = 'Beijing'
    config.i18n.default_locale = :zh
    config.active_record.raise_in_transactional_callbacks = true
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| html_tag.html_safe }
  end
end
