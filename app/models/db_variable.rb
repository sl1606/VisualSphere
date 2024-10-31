class DbVariable
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :chart_type, type: String

  def field_type
    collection = Collection.find_by(id: collection_id)
    db_connection = DbConnection.find_by(id: collection.db_connection_id)
    db_connection.client.query("show full columns from #{collection.table}").to_a.select { |x| x['Field'] == name }.first['Type']
  end

  def available_chart_types
    if !(field_type =~ /int/).nil?
      ['Box Plot', 'Histogram', 'Violin Plot']
    elsif !(field_type =~ /varchar/).nil?
      ['Bar Chart', 'Donut Chart', 'Pie Chart']
    else
      ['Line Chart', 'Scatter Plot']
    end
  end

end
