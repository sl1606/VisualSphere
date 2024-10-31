class ChartsController < ApplicationController
  before_action :set_dashboard
  before_action :set_chart, only: %i[ update destroy ]

  def index
    @charts = @dashboard.charts
    @db_connection = @dashboard.db_connection
    client = @db_connection.client
    if @db_connection.database_type == 'mongodb'
      @tables = client.database.collection_names
    else
      @tables = client.query('show tables').to_a.map { |db| db["Tables_in_#{@db_connection.database}"] }
    end
  end

  def create
    @chart = @dashboard.charts.create(chart_params)
    redirect_to charts_path(db_connection_id: params[:db_connection_id], dashboard_id: @dashboard.id), notice: 'Chart was successfully created.'
  end

  def update
    @chart = Chart.find(params[:id])
    @chart.update(chart_params)
    redirect_to charts_path(db_connection_id: @db_connection.id, dashboard_id: @related_dashboard.id), notice: 'Chart was successfully updated.'
  end

  def destroy
    @chart.destroy
    redirect_to charts_path(db_connection_id: @db_connection.id, dashboard_id: @related_dashboard.id), notice: 'Chart was successfully destroyed.'
  end

  def get_chart_type
    chart = Chart.new(number: params[:number], variable_x: params[:variable_x], variable_y: params[:variable_y], variable_z: params[:variable_z], table_name: params[:table_name], dashboard_id: params[:dashboard_id])
    @chart_type = chart.get_chart_type
    render json: @chart_type
  end

  private

  def chart_params
    params.require(:chart).permit(:name, :description, :number, :variable_x, :variable_y, :variable_z, :chart_type, :table_name)
  end

  def set_chart
    @chart = Chart.find(params[:id])
    @related_dashboard = @chart.dashboard
    @db_connection = @related_dashboard.db_connection
  end

  def set_dashboard
    @dashboard = Dashboard.find_by(id: params[:dashboard_id])
  end
end
