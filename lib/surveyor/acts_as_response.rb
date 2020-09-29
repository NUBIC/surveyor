# frozen_string_literal: true

module Surveyor
  module ActsAsResponse
    extend ActiveSupport::Concern

    # Returns the response as a particular response_class type
    def as(type_symbol)
      case type_symbol.to_sym
      when :string, :text, :integer, :float, :datetime
        send("#{type_symbol}_value".to_sym)
      when :date
        datetime_value.nil? ? nil : datetime_value.to_date
      when :time
        datetime_value.nil? ? nil : datetime_value.to_time
      else # :answer_id
        answer_id
      end
    end
  end
end
