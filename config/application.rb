require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Heather
  class Application < Rails::Application
    config.load_defaults 5.1
    config.time_zone = 'Beijing'
    config.i18n.default_locale = :zh
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| html_tag.html_safe }
  end
end
