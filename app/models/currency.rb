class Currency < ActiveRecord::Base
  scope :important, -> { where(important: true) }
end
