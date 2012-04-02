module Surveyor
  module Models
    def self.generate_api_id
      require 'uuidtools'

      UUIDTools::UUID.random_create.to_s
    end
  end
end
