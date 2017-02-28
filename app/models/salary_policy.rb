class SalaryPolicy < ActiveRecord::Base
  include Rangeable
  as_enum :type, [:assistant, :instructor, :associate_professor, :professor], prefix: true, map: :string
  validates :type, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true
  validates :amount, presence: true
end
