module Surveyor
  class Base
    def initialize(obj, args, opts)
      self.default_options.merge(parse_opts(opts)).merge(parse_args(args)).each{|k,v| self.send("#{k.to_s}=", v)}
    end
    def default_options
      {}
    end
    def parse_opts(opts)
      opts.reject{|k,v| k == :method_name} # toss the method name by default
    end
    def parse_args(args)
      args[0]
    end
    def yml_attrs
      instance_variables.sort - ["@parser"]
    end
    def to_yml
      out = [ %(#{@data_export_identifier}_#{@id}:) ]
      yml_attrs.each{|a| out << "  #{a[1..-1]}: #{instance_variable_get(a).is_a?(String) ? "\"#{instance_variable_get(a)}\"" : instance_variable_get(a) }"}
      (out << nil ).join("\r\n")
    end
  end
end