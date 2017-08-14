class WorkLocalCurrency < ActiveRecord::Base
  belongs_to :administrator
  belongs_to :currency
end
