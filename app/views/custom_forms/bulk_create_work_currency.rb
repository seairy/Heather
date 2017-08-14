class BulkCreateWorkCurrency < CustomForm
  attr_accessor :currency_ids
  validate :currency_at_least_have_one

  def attributes
    { currency_ids: nil }
  end

  def currency_at_least_have_one
    errors.add(:base, '至少选择一种货币') if self.currency_ids.blank?
  end
end
