module Surveyor
  module ActsAsResponse
    extend ActiveSupport::Concern
    
    # Returns the response as a particular response_class type
    def as(type_symbol)
      return case type_symbol.to_sym
      when :string, :text, :integer, :float, :datetime
        self.send("#{type_symbol}_value".to_sym)
      when :date
        self.datetime_value.nil? ? nil : self.datetime_value.to_date
      when :time
        self.datetime_value.nil? ? nil : self.datetime_value.to_time
      else # :answer_id
        self.answer_id
      end
    end
  end
end