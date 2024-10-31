class CollectionsController < ApplicationController
  before_action :authenticate_user
  before_action :set_db_connection, except: %i[update_chart_type]
  before_action :set_collection, only: %i[ show destroy update_variables ]
  before_action :check_repeat_collection, only: %i[ save_variables update_variables ]

  def get_variables
    if @db_connection.database_type == 'mongodb'
      @variables = []
      @db_connection.client.database[params[:table]].find.each do |document|
        @variables += document.keys
      end
      @variables = @variables.uniq
    else
      @variables = @db_connection.client.query("show full columns from #{params[:table]}").to_a.map { |x| x["Field"] }
    end
    render json: @variables
  end

  def save_variables
    @collection = @db_connection.collections.new(table: params[:table], name: params[:name])
    if @collection.save
      params[:variables].each do |variable_name|
        if @db_connection.database_type == 'mysql'
          db_variable = DbVariable.find_or_create_by(collection_id: @collection.id, name: variable_name)
          VariableAvailableChart.find_or_create_by(db_variable_id: db_variable&.id, chart_type: db_variable.available_chart_types.join(','))
          db_variable.update(chart_type: db_variable.available_chart_types.first) if db_variable.chart_type.blank?
        else
          db_variable = DbVariable.find_or_create_by(collection_id: @collection.id, name: variable_name)
          VariableAvailableChart.find_or_create_by(db_variable_id: db_variable&.id)
        end
      end
      render json: { success: true }
    else
      render json: { success: false, message: 'Invalid collection' }
    end
  end

  def update_variables
    if @collection.update(table: params[:table], name: params[:name])
      if params[:variables].present?
        params[:variables].each do |variable_name|
          if @db_connection.database_type == 'mysql'
            db_variable = DbVariable.find_or_create_by(collection_id: @collection.id, name: variable_name)
            VariableAvailableChart.find_or_create_by(db_variable_id: db_variable&.id, chart_type: db_variable.available_chart_types.join(','))
            db_variable.update(chart_type: db_variable.available_chart_types.first) if db_variable.chart_type.blank?
          else
            db_variable = DbVariable.find_or_create_by(collection_id: @collection.id, name: variable_name)
            VariableAvailableChart.find_or_create_by(db_variable_id: db_variable&.id)
          end
        end
        db_variables = []
        DbVariable.where(collection_id: @collection.id).each do |db_variable|
          db_variables << db_variable unless params[:variables].include?(db_variable.name)
        end

        db_variables.each do |db_variable|
          VariableAvailableChart.where(db_variable_id: db_variable.id).destroy_all
          db_variable.destroy
        end
      else
        db_variables = DbVariable.where(collection_id: @collection.id)
        VariableAvailableChart.where(db_variable_id: db_variables.pluck(:id)).destroy_all
        db_variables.destroy_all
      end

      render json: { success: true }
    else
      render json: { success: false, message: 'Invalid collection' }
    end
  end

  def update_chart_type
    @db_variable = DbVariable.find_by(id: params[:db_variable_id])
    p '----------'
    p @db_variable.id
    p params[:chart_type]
    if params[:chart_type].present? && @db_variable&.update!(chart_type: params[:chart_type])
      render json: { success: true }
    else
      render json: { success: false, message: 'Invalid chart type.' }
    end
  end

  def show
  end

  def destroy
    @collection.destroy

    respond_to do |format|
      format.html { redirect_to db_connection_url(@db_connection), notice: "Collection was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_db_connection
      @db_connection = current_user.db_connections.find(params[:db_connection_id])
    end

    def set_collection
      @collection = @db_connection.collections.find(params[:id])
    end

    def check_repeat_collection
      @collection1 = @db_connection.collections.find_by(table: params[:table])
      return if @collection1.present? && DbVariable.where(collection_id: @collection1&.id).pluck(:name).sort == DbVariable.where(collection_id: @collection&.id).pluck(:name).sort

      @repeat_collection = DbVariable.where(collection_id: @collection1.id).pluck(:name).sort == params[:variables].sort if @collection1.present?
      render json: { success: false, message: 'Repeat collection' } and return if @repeat_collection.present?
    end
end
