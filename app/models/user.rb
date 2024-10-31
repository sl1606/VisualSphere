class User
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  has_many :db_connections, dependent: :destroy
end