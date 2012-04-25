module Surveyor
  module ActsAsResponse
    # Returns the response as a particular type
    def as(response_class)
      case response_class.to_s
      when "string", "text", "integer", "float", "datetime"
        self.send("#{response_class}_value")
      when "date"
        self.datetime_value.nil? ? nil : self.datetime_value.to_date
      when "time"
        self.datetime_value.nil? ? nil : self.datetime_value.to_time
      else # :answer_id
        self.answer_id
      end
    end

    def value
      a = answer

      as(a.response_class) unless a.response_class == 'answer'
    end
  end
end
