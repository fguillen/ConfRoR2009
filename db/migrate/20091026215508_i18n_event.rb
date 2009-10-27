class I18nEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :i18n_name, :text
  end

  def self.down
    remove_column :events, :i18n_name
  end
end
