require 'rails/generators/active_record'
require 'generators/birja_kreditov/orm_helpers'

module ActiveRecord
  module Generators
    class BirjaKreditovGenerator < ActiveRecord::Generators::Base
      include BirjaKreditov::Generators::OrmHelpers
      source_root File.expand_path("../templates", __FILE__)

      argument :name, type: :string, default: BirjaKreditov.model

      desc "Create migration for BirjaKreditov API"

      def copy_migration
        migration_template "migration.rb", "db/migrate/add_birja_kreditov_to_#{table_name}.rb"
      end
    end
  end
end