require 'csv'

class DiscountSetting < ApplicationRecord

  enum status: [:pending, :succeeded, :failed]

  attr_accessor :customers_list_data_array
  ## ASSOCIATIONS
  belongs_to :shop
  has_attached_file :customers_list
  has_attached_file :customers_list_data_errors
  has_many :customers, dependent: :destroy

  ## VALIDATIONS
  validates_attachment :customers_list, on: :update, presence: true,
    content_type: { content_type: 'text/plain' }
  validates_attachment :customers_list_data_errors, on: :update, content_type: { content_type: 'text/plain' }
  validates :customers_list_error_type, inclusion: [nil, 'invalid_columns', 'invalid_data']

  ## CALLBACKS
  after_commit :enqueue_read_customers_list_job, on: :create, if: :pending?


  def pretty_errors
    errors.full_messages.join(', ')
  end

  def read_customers_list
    @customers_list_data_array = CSV.read(customers_list.path)
  end

  def ensure_customers_list_is_valid
    ensure_customers_list_columns_valid
    if customers_list_error_type.blank?
      ensure_customers_list_data_valid
    end
  end

  def create_associated_customers
    customer_records = @customers_list_data_array[1..@customers_list_data_array.size-1]
    customer_records.map! { |record| { email: record[0], discount_amount: record[1].to_f } }
    customers.create(customer_records)
  end

  def send_invalid_customers_list_email
    case customers_list_error_type
    when 'invalid_columns'
      DiscountSettingMailer.invalid_customers_list_column_email(id).deliver_later
    when 'invalid_data'
      DiscountSettingMailer.invalid_customers_list_data_email(id).deliver_later      
    end
  end


  private

  def ensure_customers_list_columns_valid
    customers_list_column_names = @customers_list_data_array[0]
    if(customers_list_column_names[0] != 'customer_email' || customers_list_column_names[1] != 'discount_amount')
      update(customers_list_error_type: 'invalid_columns', status: 'failed')
    end
  end

  def ensure_customers_list_data_valid
    @customers_list_data_array.each_with_index do |record, index|
      if index == 0
        next
      end
      customer = customers.new(email: record[0], discount_amount: record[1].to_f)

      unless customer.valid?
        if customers_list_data_errors.blank?
          errors_file = File.open("customers_list_data_errors-#{id}.txt", 'a')
        else
          errors_file.open
        end
        errors_file.write("\nline-##{index + 1} - " + customer.pretty_errors)

        customers.clear
        update(customers_list_error_type: 'invalid_data', status: 'failed', customers_list_data_errors: errors_file)
        errors_file.close
      end
    end

  end

  def enqueue_read_customers_list_job
    DiscountSetting::ReadCustomersListJob.perform_later(id)
  end

  
end
