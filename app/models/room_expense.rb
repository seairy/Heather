class RoomExpense < ActiveRecord::Base
  belongs_to :employee
  validates :started_at, presence: true
  validates :ended_at, presence: true
  validates :rent_yuan, numericality: { less_than: 99999 }, unless: 'rent_yuan.blank?'
  validates :rent_dollar, numericality: { less_than: 99999 }, unless: 'rent_dollar.blank?'
  validates :agency_fee_yuan, numericality: { less_than: 99999 }, unless: 'agency_fee_yuan.blank?'
  validates :agency_fee_dollar, numericality: { less_than: 99999 }, unless: 'agency_fee_dollar.blank?'
  validates :remarks, length: { maximum: 1000 }
  validate :ended_at_must_later_than_started_at,
    :rent_must_presence_at_least_one,
    :rent_must_presence_only_one,
    :agency_fee_must_presence_at_least_one,
    :agency_fee_must_presence_only_one,
    :rent_and_agency_fee_must_be_same_currency,

  def rent
    self.rent_yuan || self.rent_dollar
  end

  def rent_currency
    self.rent_yuan.blank? ? :dollar : :yuan
  end

  def agency_fee
    self.agency_fee_yuan || self.agency_fee_dollar
  end

  def agency_fee_currency
    self.agency_fee_yuan.blank? ? :dollar : :yuan
  end

  protected
    def ended_at_must_later_than_started_at
      errors.add(:base, '结束日期必须晚于开始日期') if self.ended_at <= self.started_at
    end

    def rent_must_presence_at_least_one
      errors.add(:base, '至少填写一种房租') if self.rent_yuan.blank? and self.rent_dollar.blank?
    end

    def rent_must_presence_only_one
      errors.add(:base, '只能填写一种房租') if !self.rent_yuan.blank? and !self.rent_dollar.blank?
    end

    def agency_fee_must_presence_at_least_one
      errors.add(:base, '至少填写一种中介费') if self.agency_fee_yuan.blank? and self.agency_fee_dollar.blank?
    end

    def agency_fee_must_presence_only_one
      errors.add(:base, '只能填写一种中介费') if !self.agency_fee_yuan.blank? and !self.agency_fee_dollar.blank?
    end

    def rent_and_agency_fee_must_be_same_currency
      errors.add(:base, '房租和中介费必须使用同一种货币') if (!self.rent_yuan.blank? and !self.agency_fee_dollar.blank?) or
        (!self.rent_dollar.blank? and !self.agency_fee_yuan.blank?)
    end
end
