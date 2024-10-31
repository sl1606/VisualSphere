class Chart
  include Mongoid::Document
  # include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  field :name, type: String
  field :description, type: String
  field :table_name, type: String
  field :number, type: String
  field :variable_x, type: String
  field :variable_y, type: String
  field :variable_z, type: String
  field :chart_type, type: String
  # field :dashboard_id, type: String
  belongs_to :dashboard

  def variables
    number = self.number.to_i
    variables = []
    if number == 1
      variables << self.variable_x
    elsif number == 2
      variables << self.variable_x
      variables << self.variable_y
    elsif number == 3
      variables << self.variable_x
      variables << self.variable_y
      variables << self.variable_z
    end
    variables
  end

  def get_variables
    if db_connection.database_type == 'mongodb'
      tmp_variables = []
      db_connection.client.database[params[:table]].find.each do |document|
        tmp_variables += document.keys
      end
      tmp_variables = tmp_variables.uniq
    else
      tmp_variables = db_connection.client.query("show full columns from #{table_name}").to_a.map { |x| x["Field"] }
    end
  end

  def x_field_type
    puts variable_x
    db_connection.client.query("show full columns from #{table_name}").to_a.select { |x| x['Field'] == variable_x }.first['Type']
  end

  def y_field_type
    db_connection.client.query("show full columns from #{table_name}").to_a.select { |x| x['Field'] == variable_y }.first['Type']
  end

  def z_field_type
    db_connection.client.query("show full columns from #{table_name}").to_a.select { |x| x['Field'] == variable_z }.first['Type']
  end

  def get_chart_type
    puts x_field_type
    case number
    when '1'
      if !(x_field_type =~ /int/).nil?
        ['Box Plot', 'Histogram', 'Violin Plot']
      elsif !(x_field_type =~ /varchar/).nil?
        ['Bar Chart', 'Donut Chart', 'Pie Chart']
      elsif !(x_field_type =~ /date/).nil?
        ['Line Chart', 'Scatter Plot']
      end
    when '2'
      if !(x_field_type =~ /varchar/).nil? && !(y_field_type =~ /varchar/).nil?
        ['Stacked Bar Chart', 'Grouped Bar Chart']
      elsif !(x_field_type =~ /int/).nil? && !(y_field_type =~ /int/).nil?
        ['Scatter Plot']
      elsif (!(x_field_type =~ /int/).nil? && !(y_field_type =~ /varchar/).nil?) || (!(x_field_type =~ /varchar/).nil? && !(y_field_type =~ /int/).nil?)
        ['Box Plot']
      elsif (!(x_field_type =~ /date/).nil? && !(y_field_type =~ /int/).nil?) || (!(x_field_type =~ /int/).nil? && !(y_field_type =~ /date/).nil?)
        ['Line Chart']
      elsif (!(x_field_type =~ /date/).nil? && !(y_field_type =~ /varchar/).nil?) || (!(x_field_type =~ /varchar/).nil? && !(y_field_type =~ /date/).nil?)
        ['Line Chart']
      else
        []
      end
    when '3'
      ['Box Plot', 'Histogram', 'Violin Plot', 'Bar Chart', 'Donut Chart', 'Pie Chart', 'Line Chart', 'Scatter Plot']
    end
  end

  def db_connection
    self.dashboard.db_connection
  end
end
