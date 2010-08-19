module SurveyParser
  class Base
    
    # Class level instance variable, because class variable are shared with subclasses
    class << self
      attr_accessor :children
    end
    
    @children = []
    
    # Class methods
    def self.inherited(subclass)
      # set the class level instance variable default on subclasses
      subclass.instance_variable_set(:@children, self.instance_variable_get(:@children))
    end
    
    def self.has_children(*args)
      args.each{|model| attr_accessor model}
      self.instance_variable_set(:@children, args)
    end
    
    # Instance methods
    def initialize(obj, args, opts)
      # inherit the parser from parent (obj)
      self.parser = (obj.nil? ? nil : obj.class == SurveyParser::Parser ? obj : obj.parser)
      # get a new id from the parser
      self.id = parser.nil? ? nil : parser.send("new_#{self.class.name.demodulize.underscore}_id")
      # set [parent]_id to obj.id, if we have that attribute
      self.send("#{obj.class.name.demodulize.underscore}_id=", obj.nil? ? nil : obj.id) if self.respond_to?("#{obj.class.name.demodulize.underscore}_id=") 
      # initialize descendant models
      self.class.children.each{|model| self.send("#{model}=", [])}
      # combine default options, parsed opts, parsed args, and initialize instance variables
      self.default_options.merge(parse_opts(opts)).merge(parse_args(args)).each{|k,v| self.send("#{k.to_s}=", v)}
      # print to the log
      print "#{self.class.name.demodulize.gsub(/[a-z]/, "")[-1,1]}#{self.id} "
    end
    def default_options
      {}
    end
    def parse_opts(opts)
      opts.reject{|k,v| k == :method_name} # toss the method name by default
    end
    def parse_args(args)
      args[0] || {}
    end
    
    # Filter out attributes that shouldn't be in fixtures, including children, parser, placeholders
    def yml_attrs
      instance_variables.sort.map(&:to_s) - self.class.children.map{|model| "@#{model.to_s}"} - %w(@id @parser @dependency @validation @question_reference @answer_reference)
    end
    
    def to_yml
      out = [ %(#{self.parser.salt}_#{self.class.name.demodulize.underscore}_#{@id}:) ]
      yml_attrs.each{|a| out << associate_and_format(a)}
      (out << nil ).join("\r\n")
    end
    
    def associate_and_format(a)
      if a =~ /_id$/ # a foreign key, e.g. survey_id
        "  #{property_name_map(a[1..-4])}: " + (instance_variable_get(a).nil? ? "" : "#{self.parser.salt}_#{a[1..-4]}_#{instance_variable_get(a)}")
      else # quote strings
        "  #{property_name_map(a[1..-1])}: #{instance_variable_get(a).is_a?(String) ? "\"#{instance_variable_get(a)}\"" : instance_variable_get(a) }"
      end
    end
    
    def property_name_map(property)
      return property
    end
    
    def to_file
      File.open(self.parser.send("#{self.class.name.demodulize.underscore.pluralize}_yml"), File::CREAT|File::APPEND|File::WRONLY) {|f| f << to_yml}
      self.class.children.each{|model| self.send(model).compact.map(&:to_file)}
    end
  end
end