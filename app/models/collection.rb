class Collection
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :name, type: String
  # field :db_connection_id, type: String
  # field :created_at, type: String
  # field :updated_at, type: String

  belongs_to :db_connection
end