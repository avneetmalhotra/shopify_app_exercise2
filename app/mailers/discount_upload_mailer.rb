class DiscountUploadMailer < ApplicationMailer

  def invalid_discount_file_columns_email(discount_upload_id)
    @discount_upload = DiscountUpload.find_by id: discount_upload_id
    @shop = @discount_upload.shop

    mail(to: @shop.shopify_email, subject: "Incorrect <%= @discount_upload.discount_file_name %> file.", from: 'notification@development-store-a2.com')
  end

  def invalid_discount_file_data_email(discount_upload_id)
    @discount_upload = DiscountUpload.find_by id: discount_upload_id
    @shop = @discount_upload.shop
    attachments['file-data-issues.txt'] = File.read(@discount_upload.discount_data_errors.path)

    mail(to: @shop.shopify_email, subject: "Incorrect <%= @discount_upload.discount_file_name %> file.", from: 'notification@development-store-a2.com')
  end

  def success_email(discount_upload_id)
    @discount_upload = DiscountUpload.find_by id: discount_upload_id
    @shop = @discount_upload.shop

    mail(to: @shop.shopify_email, subject: "<%= @discount_upload.discount_file_name %> file successfulle uploaded", from: 'notification@development-store-a2.com')    
  end

end
