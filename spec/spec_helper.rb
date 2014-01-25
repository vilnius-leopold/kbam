require_relative '../lib/kbam.rb'
require_relative 'create_schema.rb'

RSpec.configure do |config|
  # Use color in STDOUT
  config.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate
end

Kbam.verbose false

# initial setup of the database
setup_database