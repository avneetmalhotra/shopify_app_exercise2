class CreateDiscountUploads < ActiveRecord::Migration[5.1]
  def change
    create_table :discount_uploads do |t|
      t.integer :status, default: 0 #[:pending, :succeeded, :failed]
      t.string :error_type 

      t.references :setting

      t.timestamps
    end

    add_attachment :discount_uploads, :discount
    add_attachment :discount_uploads, :discount_data_errors

  end
end
