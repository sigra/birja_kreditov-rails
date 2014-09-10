require 'rails/generators/base'

module BirjaKreditov
  module Generators
    class InitializerGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "Create initializer for BirjaKreditov API"
      def create_initializer_file
        copy_file "initializer.rb", "config/initializers/birja_kreditov.rb"
      end
    end
  end
end