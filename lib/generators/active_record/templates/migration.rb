class AddBirjaKreditovTo<%= table_name.camelize %> < ActiveRecord::Migration
  def self.up
    change_table(:<%= table_name %>) do |t|
      # Uncomment unexisting fields
      # t.integer :<%= BirjaKreditov.status_field %>
      # t.integer :<%= BirjaKreditov.reason_field %>
      # t.string  :<%= BirjaKreditov.comment_field %>
      # t.string  :<%= BirjaKreditov.uid_field %>

      t.datetime :bk_updated_at
    end

    # Uncomment required indexes
    # add_index :<%= table_name %>, :<%= BirjaKreditov.status_field %>
    # add_index :<%= table_name %>, :<%= BirjaKreditov.reason_field %>
    # add_index :<%= table_name %>, :<%= BirjaKreditov.uid_field %>
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration

    # remove_column :<%= table_name %>, :<%= BirjaKreditov.status_field %>
    # remove_column :<%= table_name %>, :<%= BirjaKreditov.reason_field %>
    # remove_column :<%= table_name %>, :<%= BirjaKreditov.comment_field %>
    # remove_column :<%= table_name %>, :<%= BirjaKreditov.uid_field %>

    # remove_index :<%= table_name %>, :<%= BirjaKreditov.status_field %>
    # remove_index :<%= table_name %>, :<%= BirjaKreditov.reason_field %>
    # remove_index :<%= table_name %>, :<%= BirjaKreditov.uid_field %>
  end
end
