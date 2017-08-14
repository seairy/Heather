class CustomForm
  include ActiveModel::Model
  include ActiveModel::AttributeMethods
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Conversion
  include ActiveModel::Serialization

  def initialize attributes = {}
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def persisted?
    false
  end
end
