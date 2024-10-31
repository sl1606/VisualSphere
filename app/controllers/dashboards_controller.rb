class DashboardsController < ApplicationController
  def new
    params[:db_connection_id]
  end

  def create
    @dashboard = Dashboard.new(db_connection_id: params[:dashboard][:db_connection_id], name: params[:dashboard][:name], description: params[:dashboard][:description])
    @dashboard.save
    redirect_to db_connection_url(id: @dashboard.db_connection_id), notice: "Dashboard was successfully created."
  end

  def update
    @dashboard = Dashboard.find_by(id: params[:id])
    @dashboard.update(name: params[:name], description: params[:description])
    @dashboard.save
    redirect_to db_connection_url(id: @dashboard.db_connection_id), notice: "Dashboard was successfully updated."
  end

  def destroy
    @dashboard = Dashboard.find_by(id: params[:id])
    @dashboard.destroy
    redirect_to db_connection_url(id: @dashboard.db_connection_id), notice: "Dashboard was successfully destroyed."
  end

  def show
    @dashboard = Dashboard.find_by(id: params[:id])
  end
end
