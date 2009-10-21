class AddCartContactDetails < ActiveRecord::Migration
  def self.up
    add_column :carts, :payment_type, :string, :limit => 10
    add_column :carts, :client_name, :string
    add_column :carts, :client_tax_code, :string
    add_column :carts, :client_address, :string
    add_column :carts, :client_phone, :string, :limit => 30
  end

  def self.down
    remove_column :carts, :payment_type
    remove_column :carts, :client_name
    remove_column :carts, :client_tax_code
    remove_column :carts, :client_address
    remove_column :carts, :client_phone
  end
end
