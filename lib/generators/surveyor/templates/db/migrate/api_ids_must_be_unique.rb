class ApiIdsMustBeUnique < ActiveRecord::Migration
  API_ID_TABLES = %w(surveys questions question_groups answers responses response_sets)

  class << self
    def up
      API_ID_TABLES.each do |table|
        add_index table, 'api_id', :unique => true, :name => api_id_index_name(table)
      end
    end

    def down
      API_ID_TABLES.each do |table|
        remove_index table, :name => api_id_index_name(table)
      end
    end

    private

    def api_id_index_name(table)
      "uq_#{table}_api_id"
    end
  end
end
