class CreateDiscountSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :discount_settings do |t|
      t.integer :status, default: 0 #[:pending, :succeeded, :failed]
      t.string :customers_list_error_type 

      t.references :shop

      t.timestamps
    end

    add_attachment :discount_settings, :customers_list
    add_attachment :discount_settings, :customers_list_data_errors
  end
end
