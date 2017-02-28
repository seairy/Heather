class SpouseRange < ActiveRecord::Base
  as_enum :type, [:unmarried, :not_accompanied, :accompanied], prefix: true, map: :string
  belongs_to :employee
  validates :type, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true
  validate :ended_at_must_later_than_started_at,
    :started_at_must_later_than_or_equal_to_employees_departured_at,
    :ended_at_must_earlier_than_or_equal_to_employees_returned_at,
    :can_not_be_coincident

  def total_days
    (self.ended_at - self.started_at).to_i + 1
  end

  def self.new_with_date options
    SpouseRange.new.tap do |spouse_range|
      if options[:employee].spouse_ranges.count.zero?
        spouse_range.started_at = options[:employee].departured_at
        spouse_range.ended_at = options[:employee].returned_at
      else
        spouse_range.started_at = options[:started_at]
        spouse_range.ended_at = options[:ended_at]
      end
    end
  end

  protected
    def ended_at_must_later_than_started_at
      errors.add(:base, '结束日期必须晚于开始日期') if self.ended_at <= self.started_at
    end

    def started_at_must_later_than_or_equal_to_employees_departured_at
      errors.add(:base, '开始日期必须晚于或等于教师出国日期') if self.started_at < self.employee.departured_at
    end

    def ended_at_must_earlier_than_or_equal_to_employees_returned_at
      errors.add(:base, '结束日期必须早于或等于教师回国日期') if self.ended_at > self.employee.returned_at
    end

    def can_not_be_coincident
      errors.add(:base, '时间区间不能和已存在配偶信息重合') if self.employee.spouse_ranges.where('started_at <= ? AND ended_at >= ?', self.started_at, self.started_at).first or
        self.employee.spouse_ranges.where('started_at <= ? AND ended_at >= ?', self.ended_at, self.ended_at).first
    end
end
