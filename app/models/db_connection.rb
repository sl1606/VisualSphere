class DbConnection
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  belongs_to :user
  has_many :dashboards, dependent: :destroy

  def client
    database_type == 'mongodb' ? mongodb_client : mysql_client
  end

  def mongodb_client
    if username.present? && password.present?
      mongo_info = "mongodb://#{username}:#{password}@#{ip}:#{port}/#{database}"
    else
      mongo_info = "mongodb://#{ip}:#{port}/#{database}"
    end
    client = Mongo::Client.new(mongo_info)
    return if client.summary.include?('Unknown')

    client
  end

  def mysql_client
    client = Mysql2::Client.new(host: ip, port: port, username: username,
                                      password: password, database: database)
    tables = client.query('show tables').to_a.map { |db| db["Tables_in_#{database}"] }
    return if tables.blank?

    client
  end
end