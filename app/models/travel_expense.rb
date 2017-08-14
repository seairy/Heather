class TravelExpense < ActiveRecord::Base
  as_enum :role, [:self, :spouse], prefix: true, map: :string
  as_enum :type, [:vacation, :business, :private, :round], prefix: true, map: :string
  belongs_to :employee
  belongs_to :departure_flight_fare, class_name: 'Fare'
  belongs_to :return_flight_fare, class_name: 'Fare'
  validates :departured_at, presence: true
  validates :returned_at, presence: true
  validates :departure_flight_fare_yuan, numericality: { less_than: 99999 }, unless: 'departure_flight_fare_yuan.blank?'
  validates :departure_flight_fare_dollar, numericality: { less_than: 99999 }, unless: 'departure_flight_fare_dollar.blank?'
  validates :return_flight_fare_yuan, numericality: { less_than: 99999 }, unless: 'return_flight_fare_yuan.blank?'
  validates :return_flight_fare_dollar, numericality: { less_than: 99999 }, unless: 'return_flight_fare_dollar.blank?'
  validate :returned_at_must_later_than_departured_at,
    :departure_flight_fare_must_presence_at_least_one,
    :departure_flight_fare_must_presence_only_one,
    :return_flight_fare_must_presence_at_least_one,
    :return_flight_fare_must_presence_only_one,
    :type_round_must_be_unique

  def departure_flight_fare
    self.departure_flight_fare_yuan || self.departure_flight_fare_dollar
  end

  def departure_flight_fare_currency
    self.departure_flight_fare_yuan.blank? ? :dollar : :yuan
  end

  def return_flight_fare
    self.return_flight_fare_yuan || self.return_flight_fare_dollar
  end

  def return_flight_fare_currency
    self.return_flight_fare_yuan.blank? ? :dollar : :yuan
  end

  def departed_days
    (self.returned_at - self.departured_at).to_i + 1 unless self.type_round?
  end

  protected
    def returned_at_must_later_than_departured_at
      errors.add(:base, '返程日期必须晚于离境日期') if self.returned_at <= self.departured_at
    end

    def departure_flight_fare_must_presence_at_least_one
      errors.add(:base, '至少填写一种离境航班费用') if self.departure_flight_fare_yuan.blank? and self.departure_flight_fare_dollar.blank?
    end

    def departure_flight_fare_must_presence_only_one
      errors.add(:base, '只能填写一种离境航班费用') if !self.departure_flight_fare_yuan.blank? and !self.departure_flight_fare_dollar.blank?
    end

    def return_flight_fare_must_presence_at_least_one
      errors.add(:base, '至少填写一种返程航班费用') if self.return_flight_fare_yuan.blank? and self.return_flight_fare_dollar.blank?
    end

    def return_flight_fare_must_presence_only_one
      errors.add(:base, '只能填写一种返程航班费用') if !self.return_flight_fare_yuan.blank? and !self.return_flight_fare_dollar.blank?
    end

    def type_round_must_be_unique
      errors.add(:base, '已经存在赴离任类型的旅费记录') if self.type_round? and !self.employee.travel_expenses.type_rounds.blank?
    end
end
