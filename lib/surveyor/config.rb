module Surveyor
  #
  # The Surveyor::Config object emulates a hash with simple bracket methods
  # which allow you to get and set values in the configuration table:
  #
  #   Surveyor::Config['setting.name'] = 'value'
  #   Surveyor::Config['setting.name'] #=> "value"
  #
  # Currently, there is not a way to edit configuration through the admin
  # system so it must be done manually. The console script is probably the
  # easiest way to this:
  #
  #   % script/console production
  #   Loading production environment.
  #   >> Surveyor::Config['setting.name'] = 'value'
  #   => "value"
  #   >>
  #
  # Surveyor currently uses the following settings:
  #
  # defaults.title               :: the title of the survey system
  # defaults.layout              :: the layout used by the survey system

  class Config
    @@config_hash = {}

    class << self
      def [](key)
        @@config_hash[key]
      end

      def []=(key, value)
        @@config_hash[key] = value
      end

      def to_hash
        @@config_hash
      end
    end
  end
end
