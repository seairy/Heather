class CountryLevelPolicy < ActiveRecord::Base
  include Rangeable
  belongs_to :country
end
