class Employee < ActiveRecord::Base
  attr_accessor :title
  attr_accessor :spouse
  as_enum :type, [:instructor, :ci_instructor, :ci_president], prefix: true, map: :string
  belongs_to :country
  has_many :travel_expenses, dependent: :destroy
  has_many :room_expenses, dependent: :destroy
  has_many :medical_expenses, dependent: :destroy
  has_many :title_ranges, dependent: :destroy
  has_many :spouse_ranges, dependent: :destroy
  before_create :set_rate_of_exchange
  after_create :set_title_and_spouse
  validates :name, presence: true, length: { maximum: 100 }
  validates :country, presence: true
  validates :title, presence: true, on: :create
  validates :spouse, presence: true, on: :create
  validates :domestic_organization, presence: true, length: { maximum: 500 }
  validates :foreign_organization, presence: true, length: { maximum: 500 }
  validates :departured_at, presence: true
  validates :returned_at, presence: true
  validates :subsidy, presence: true, numericality: { less_than: 99999 }
  validates :household_allowance, presence: true, numericality: { less_than: 99999 }
  validate :returned_at_must_later_than_departured_at

  def percentage_of_ranges_as_array type
    Array.new.tap do |result|
      self.send("#{type}_ranges").order(:started_at).each_with_index do |range, i|
        result << { type: :empty, days: (range.started_at - self.departured_at).to_i, started_at: self.departured_at, ended_at: range.ended_at } if i.zero? and range.started_at != self.departured_at
        result << { type: :empty, days: (range.started_at - result.last[:ended_at]).to_i, started_at: result.last[:ended_at] + 1.day, ended_at: range.started_at - 1.day } if !result.blank? and (range.started_at - result.last[:ended_at] > 1)
        result << { type: range.type, days: range.total_days, started_at: range.started_at, ended_at: range.ended_at }
        result << { type: :empty, days: (self.returned_at - range.ended_at).to_i, started_at: range.ended_at + 1.day, ended_at: self.returned_at } if i == (self.send("#{type}_ranges").count - 1) and range.ended_at != self.returned_at
      end
      result.map{|item| item.merge!(percentage: (item[:days].to_f / self.actual_total_days * 100).round)}
      if (total_percentage = result.map{|item| item[:percentage]}.reduce(:+)) > 100
        result.sort{|x, y| x[:percentage] <=> y[:percentage]}.last[:percentage] -= 1
      elsif total_percentage < 100
        result.sort{|x, y| x[:percentage] <=> y[:percentage]}.first[:percentage] += 1
      end unless result.blank?
    end
  end

  def actual_total_days
    (self.returned_at - self.departured_at).to_i + 1
  end

  def working_total_fragmentary_months
    days = departure_month_days + return_month_days
    ((days / 15.5).floor + ((days % 15.5).zero? ? 0 : 1)) * 0.5
  end

  def working_total_months
    months = (self.returned_at.strftime('%Y').to_i - self.departured_at.strftime('%Y').to_i - 1) * 12
    months += 12 - self.departured_at.strftime('%m').to_i if self.departured_at.strftime('%m') != '12'
    months += self.returned_at.strftime('%m').to_i - 1
    months += working_total_fragmentary_months
  end

  def departure_month_days
    self.departured_at.end_of_month.strftime('%d').to_i - self.departured_at.strftime('%d').to_i + 1
  end

  def return_month_days
    self.returned_at.strftime('%d').to_i
  end

  def handle_fragmentary_months type
    (case working_total_fragmentary_months
    when 0.5
      [nil, 0.5]
    when 1.0
      departure_month_days >= return_month_days ? [0.5, 0.5] : [nil, 1]
    when 1.5
      departure_month_days > return_month_days ? [1, 0.5] : [0.5, 1]
    when 2.0
      [1, 1]
    end)[(type == :departure ? 0 : 1)]
  end

  def working_departure_months
    handle_fragmentary_months(:departure)
  end

  def working_return_months
    handle_fragmentary_months(:return)
  end

  def total_departured_ranges
    self.travel_expenses.map{|travel_expense| { started_at: travel_expense.departured_at, ended_at: travel_expense.returned_at }}
  end

  def deduction_departured_ranges
    self.travel_expenses.map do |travel_expense|
      case travel_expense.type
      when :vacation
        { started_at: travel_expense.departured_at + 61.days, ended_at: travel_expense.returned_at } if travel_expense.departed_days > 61
      when :private then { started_at: travel_expense.departured_at, ended_at: travel_expense.returned_at }
      end
    end.compact
  end

  def range_statement options = {}
    started_at = options[:range].started_at >= options[:policy].started_at ? options[:range].started_at : options[:policy].started_at
    started_at = self.departured_at if started_at < self.departured_at
    ended_at = options[:range].ended_at <= options[:policy].ended_at ? options[:range].ended_at : options[:policy].ended_at
    ended_at = self.returned_at if ended_at > self.returned_at
    discard_last_month = ((ended_at == ended_at.end_of_month and ended_at != self.returned_at) ? false : true)
    { type: options[:type], title: options[:title], policy: options[:policy], started_at: started_at, ended_at: ended_at, months: "#{Array.new.tap do |months|
      if started_at == self.departured_at
        months << working_departure_months
        started_at += 1.month
      end
      if started_at.year == ended_at.year
        months << (discard_last_month ? ended_at.month - started_at.month : ended_at.month - started_at.month + 1)
      else
        months << (12 - started_at.month + 1)
        (ended_at.year - started_at.year - 1).times{months << 12}
        months << (discard_last_month ? ended_at.month - 1 : ended_at.month)
      end
      months << working_return_months if ended_at == self.returned_at
    end.compact.join(' + ')}", amount: options[:policy].amount.round }
  end

  def salary_statement
    self.title_ranges.map do |title_range|
      SalaryPolicy.send("type_#{title_range.type.to_s.pluralize}").ranged(title_range.started_at, title_range.ended_at).map do |salary_policy|
        range_statement(range: title_range, policy: salary_policy, type: :salary, title: title_range.type)
      end
    end.flatten
  end

  def spouse_subsidy_statement
    self.spouse_ranges.map do |spouse_range|
      SpouseSubsidyPolicy.send("type_#{spouse_range.type.to_s.pluralize}").ranged(spouse_range.started_at, spouse_range.ended_at).map do |spouse_subsidy_policy|
        range_statement(range: spouse_range, policy: spouse_subsidy_policy, type: :spouse_subsidy, title: spouse_range.type)
      end
    end.flatten
  end

  def travel_subsidy_statement
    self.country.country_level_policies.ranged(self.departured_at, self.returned_at).map do |country_level_policy|
      TravelSubsidyPolicy.where(level: country_level_policy.number).ranged(country_level_policy.started_at, country_level_policy.ended_at).map do |travel_subsidy_policy|
        range_statement(range: country_level_policy, policy: travel_subsidy_policy, type: :travel_subsidy, title: travel_subsidy_policy.level)
      end
    end.flatten
  end

  def country_subsidy_statement
    self.country.country_level_policies.ranged(self.departured_at, self.returned_at).map do |country_level_policy|
      CountrySubsidyPolicy.where(level: country_level_policy.number).ranged(country_level_policy.started_at, country_level_policy.ended_at).map do |country_subsidy_policy|
        range_statement(range: country_level_policy, policy: country_subsidy_policy, type: :country_subsidy, title: country_subsidy_policy.level)
      end
    end.flatten
  end

  def travel_reimbursement_statement
    self.travel_expenses.each do |travel_expense|

    end
  end

  def deduction_statement options = {}
    options[:pay_statement].map do |item|
      included_ranges(item, options[:date_ranges]).map do |range|
        days = (range[:ended_at] - range[:started_at]).to_i + 1
        { type: :deduction, title: days, started_at: range[:started_at], ended_at: range[:ended_at], days: days, amount: item[:policy].amount }
      end
    end.flatten
  end

  def salary_deduction_statement
    deduction_statement(pay_statement: salary_statement, date_ranges: deduction_departured_ranges)
  end

  def travel_subsidy_deduction_statement
    deduction_statement(pay_statement: travel_subsidy_statement, date_ranges: deduction_departured_ranges)
  end

  def country_subsidy_deduction_statement
    deduction_statement(pay_statement: country_subsidy_statement, date_ranges: total_departured_ranges)
  end

  protected
    def set_title_and_spouse
      self.title_ranges.create!(type: self.title, started_at: self.departured_at, ended_at: self.returned_at) if self.title != 'not_now'
      self.spouse_ranges.create!(type: self.spouse, started_at: self.departured_at, ended_at: self.returned_at) if self.spouse != 'not_now'
    end

    def set_rate_of_exchange
      begin
        uri = URI.parse("http://srh.bankofchina.com/search/whpj/search.jsp?erectDate=#{self.returned_at}&nothing=#{self.returned_at}&pjname=1316")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)
        response = http.request(request)
        content = response.body.force_encoding('UTF-8')
        content = content.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
        table = content.split('<div class="BOC_main publish">')[1]
        self.rate_of_exchange = table.scan(/<td>美元<\/td>\s+<td>[0-9\.]*<\/td>\s+<td>[0-9\.]*<\/td>\s+<td>[0-9\.]*<\/td>\s+<td>[0-9\.]*<\/td>\s+<td>([0-9\.]*)<\/td>/)[0][0].to_f
      rescue Exception
      end
    end

    def returned_at_must_later_than_departured_at
      errors.add(:base, '回国日期必须晚于出国日期') if self.returned_at <= self.departured_at
    end

    def included_ranges wrapper_range, inner_ranges
      inner_ranges.map do |inner_range|
        if inner_range[:started_at] >= wrapper_range[:started_at] and inner_range[:ended_at] <= wrapper_range[:ended_at]
          { started_at: inner_range[:started_at], ended_at: inner_range[:ended_at] }
        elsif inner_range[:started_at] < wrapper_range[:started_at] and inner_range[:ended_at] > wrapper_range[:ended_at]
          { started_at: inner_range[:started_at], ended_at: inner_range[:ended_at] }
        elsif inner_range[:started_at] < wrapper_range[:started_at] and inner_range[:ended_at] > wrapper_range[:started_at]
          { started_at: wrapper_range[:started_at], ended_at: inner_range[:ended_at] }
        elsif inner_range[:ended_at] > wrapper_range[:ended_at] and inner_range[:started_at] < wrapper_range[:ended_at]
          { started_at: inner_range[:started_at], ended_at: wrapper_range[:ended_at] }
        end
      end.compact || []
    end
end
