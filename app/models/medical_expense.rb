class MedicalExpense < ActiveRecord::Base
  as_enum :type, [:full, :float], prefix: true, map: :string
  belongs_to :employee
  validates :type, presence: true
  validates :amount, presence: true, numericality: { less_than: 99999 }
  
  def amount_of_reimbursement
    case type
    when :full then self.amount
    when :float
      if self.amount <= 240

      elsif self.amount > 240 

      else

      end
    end
  end
end
