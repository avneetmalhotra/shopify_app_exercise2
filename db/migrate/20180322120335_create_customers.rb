class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string :email
      t.decimal :discount_amount, precision: 8, scale: 2
      t.bigint :shopify_customer_id
      t.string :advance_discount_code

      t.bigint :shopify_price_rule_id
      t.bigint :shopify_discount_code_id

      t.references :discount_setting

      t.timestamps
    end

    # add_index :customers, :advance_discount_code, unique: true
  end
end
