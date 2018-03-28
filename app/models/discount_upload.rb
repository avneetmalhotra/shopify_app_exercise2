require 'csv'

class DiscountUpload < ApplicationRecord

  delegate :shop, to: :setting
  enum status: [:pending, :succeeded, :failed]

  attr_accessor :discount_file_data_array
  ## ASSOCIATIONS
  belongs_to :setting
  has_attached_file :discount
  has_attached_file :discount_data_errors
  has_many :customers, dependent: :destroy

  ## VALIDATIONS
  validates_attachment :discount, on: :update, presence: true,
    content_type: { content_type: 'text/plain' }
  validates_attachment :discount_data_errors, on: :update, content_type: { content_type: 'text/plain' }
  validates :error_type, inclusion: [nil, 'invalid_columns', 'invalid_data']

  ## CALLBACKS
  after_commit :enqueue_read_discount_job, on: :create, if: :pending?


  def pretty_errors
    errors.full_messages.join(', ')
  end

  def read_discount
    @discount_file_data_array = CSV.read(discount.path)
  end

  def ensure_discount_file_is_valid
    ensure_discount_file_columns_valid
    if error_type.blank?
      ensure_discount_file_data_valid
    end
  end

  def create_associated_customers
    customer_records = @discount_file_data_array[1..@discount_file_data_array.size-1]
    customer_records.map! { |record| { email: record[0], discount_amount: record[1].to_f } }
    customers.create(customer_records)
  end

  def send_invalid_discount_file_email
    case error_type
    when 'invalid_columns'
      DiscountUploadMailer.invalid_discount_file_column_email(id).deliver_later
    when 'invalid_data'
      DiscountUploadMailer.invalid_discount_file_data_email(id).deliver_later      
    end
  end


  private

  def ensure_discount_file_columns_valid
    discount_file_column_names = @discount_file_data_array[0]
    if(discount_file_column_names[0] != 'customer_email' || discount_file_column_names[1] != 'discount_amount')
      update(error_type: 'invalid_columns', status: 'failed')
    end
  end

  def ensure_discount_file_data_valid
    @discount_file_data_array.each_with_index do |record, index|
      if index == 0
        next
      end
      customer = customers.build(email: record[0], discount_amount: record[1].to_f)

      unless customer.valid?
        errors_file = File.open("discount_data_errors-#{id}.txt", 'a')

        errors_file.write("\nline-##{index + 1} - " + customer.pretty_errors)

        customers.clear
        update(error_type: 'invalid_data', status: 'failed', discount_data_errors: errors_file)
        errors_file.close
      end
    end

  end

  def enqueue_read_discount_job
    ReadDiscountFileJob.perform_later(id)
  end

  
end
