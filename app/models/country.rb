class Country < ActiveRecord::Base
  belongs_to :continent
  has_many :employees
  has_many :country_level_policies

  def self.create_with_levels! array
    array.each do |hash|
      create!(name: hash[:name], continent: hash[:continent]).tap do |country|
        country.country_level_policies.create!(if hash[:p1] == hash[:p2] and hash[:p2] == hash[:p3]
          { started_at: '2001-01-01', ended_at: '2020-12-31', number: hash[:p1] }
        elsif hash[:p1] == hash[:p2] and hash[:p2] != hash[:p3]
          [{ started_at: '2001-01-01', ended_at: '2015-12-31', number: hash[:p1] },
          { started_at: '2016-01-01', ended_at: '2020-12-31', number: hash[:p3] }]
        elsif hash[:p1] != hash[:p2] and hash[:p2] == hash[:p3]
          [{ started_at: '2001-01-01', ended_at: '2011-06-30', number: hash[:p1] },
          { started_at: '2011-07-01', ended_at: '2020-12-31', number: hash[:p2] }]
        else
          [{ started_at: '2001-01-01', ended_at: '2011-06-30', number: hash[:p1] },
          { started_at: '2011-07-01', ended_at: '2015-12-31', number: hash[:p2] },
          { started_at: '2016-01-01', ended_at: '2020-12-31', number: hash[:p3] }]
        end)
      end
    end
  end
end
