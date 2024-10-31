class DbConnectionsController < ApplicationController
  before_action :authenticate_user
  before_action :set_db_connection, only: %i[ show edit update destroy collection]

  # GET /db_connections or /db_connections.json
  def index
    session[:redirect_url] = request.url
    session[:redirect_to] = request.url
    @db_connections = current_user.db_connections
  end

  # GET /db_connections/1 or /db_connections/1.json
  def show
    @dashboards = @db_connection.dashboards
    client = @db_connection.client
    if @db_connection.database_type == 'mongodb'
      @tables = client.database.collection_names
    else
      @tables = client.query('show tables').to_a.map { |db| db["Tables_in_#{@db_connection.database}"] }
    end
  end

  # GET /db_connections/new
  def new
    session[:redirect_url] = request.url
    @db_connection = current_user.db_connections.new
  end

  # GET /db_connections/1/edit
  def edit
  end

  def create
    if current_user.db_connections.find_by(db_connection_params.to_h).present?
      redirect_to new_db_connection_path, notice: 'This connection already exists' and return
    end

    @db_connection = current_user.db_connections.new(db_connection_params)
    if @db_connection.client && @db_connection.save
      if params[:db_connection][:csv].present?
        uploader = CsvUploader.new
        uploader.store!(params[:db_connection][:csv])
        @db_connection.update(csv: "#{Rails.root}/public#{uploader.url}")
      end
      redirect_to db_connection_url(@db_connection), notice: "Database connection was successfully created."
    else
      redirect_to fail_home_index_path if @db_connection.client&.summary&.include?('Unknown')
    end
  end

  def update
    if params[:db_connection][:csv_reset].present?
      @db_connection.update(csv: nil)
    end

    if current_user.db_connections.find_by(db_connection_params.to_h).present? && params[:db_connection][:csv].blank? && params[:db_connection][:csv_reset].blank?
      redirect_to db_connections_url, notice: 'This connection already exists' and return
    end

    if @db_connection.update(db_connection_params) && @db_connection.reload.client
      if params[:db_connection][:csv].present?
        uploader = CsvUploader.new
        uploader.store!(params[:db_connection][:csv])
        @db_connection.update(csv: "#{Rails.root}/public#{uploader.url}")
      end
      redirect_to db_connections_url, notice: "The connection is successfully updated."
    else
      redirect_to fail_home_index_path if @db_connection.client&.summary&.include?('Unknown')
    end
  rescue => e
    redirect_to fail_home_index_path
  end

  # DELETE /db_connections/1 or /db_connections/1.json
  def destroy
    @db_connection.destroy

    respond_to do |format|
      format.html { redirect_to session[:redirect_to] || db_connections_url, notice: "The connection is successfully removed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_db_connection
      @db_connection = current_user.db_connections.find_by(id: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def db_connection_params
      params.require(:db_connection).permit(:ip, :port, :database, :username, :password, :database_type)
    end

    def check_redirect_url
      session[:delete_redirect_url] = request.url
    end
end
