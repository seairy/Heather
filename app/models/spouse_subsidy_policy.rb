class SpouseSubsidyPolicy < ActiveRecord::Base
  include Rangeable
  as_enum :type, [:unmarried, :not_accompanied, :accompanied], prefix: true, map: :string
  validates :type, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true
  validates :amount, presence: true
end
