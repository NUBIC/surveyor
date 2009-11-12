class Fixtures
  def delete_existing_fixtures
    # @connection.delete "DELETE FROM #{@connection.quote_table_name(table_name)}", 'Fixture Delete'
    puts "Appending, skipping delete..."
  end
end