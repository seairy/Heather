class WorkCurrency < ActiveRecord::Base
  belongs_to :administrator
  belongs_to :currency

  def self.bulk_create options = {}
    options[:currency_ids].each do |currency_id|
      create!(administrator: options[:administrator], currency_id: currency_id)
    end if options[:administrator].work_currencies.blank?
  end
end
