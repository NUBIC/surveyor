require 'active_record'

module Surveyor
  module Response
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def acts_as_response
        include Surveyor::Response::InstanceMethods
      end    
    end
    
    module InstanceMethods
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
end

ActiveRecord::Base.send(:include, Surveyor::Response)