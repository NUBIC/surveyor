class PermittedParams < Struct.new(:params)
  # per http://railscasts.com/episodes/371-strong-parameters
  include Surveyor::Models::PermittedParamsMethods
end