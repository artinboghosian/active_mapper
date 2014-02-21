require 'active_record'
require 'active_mapper'

Dir['./spec/support/**/*.rb'].each { |f| require f }

# stop deprecation message
I18n.enforce_available_locales = false