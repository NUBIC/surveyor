# frozen_string_literal: true

class Response < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include Surveyor::Models::ResponseMethods
end
