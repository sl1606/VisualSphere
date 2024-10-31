class VariableAvailableChart
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :variable_id, type: String
  field :chart_type, type: String
end