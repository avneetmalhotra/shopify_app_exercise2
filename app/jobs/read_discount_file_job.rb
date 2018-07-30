class ReadDiscountFileJob < ApplicationJob

  def perform(discount_upload_id)
    @discount_upload = DiscountUpload.find_by id: discount_upload_id
    @discount_upload.read_discount
    @discount_upload.ensure_discount_file_is_valid

    if @discount_upload.error_type.present?
      @discount_upload.send_invalid_discount_file_email
    else
      @discount_upload.create_associated_customers
      DiscountUploadMailer.success_email(discount_upload_id).deliver_later  
    end
  end
end
