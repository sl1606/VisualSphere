class Dashboard
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  field :name, type: String
  field :description, type: String
  # field :db_connection_id, type: String
  belongs_to :db_connection
  has_many :charts
end