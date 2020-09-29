# frozen_string_literal: true

PermittedParams = Struct.new(:params) do
  # per http://railscasts.com/episodes/371-strong-parameters
  include Surveyor::Models::PermittedParamsMethods
end
