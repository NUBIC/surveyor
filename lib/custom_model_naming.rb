module CustomModelNaming
  # https://coderwall.com/p/yijmuq
  extend ActiveSupport::Concern

  included do
    self.class_attribute :singular_route_key, :route_key, :param_key
  end

  module ClassMethods
    def model_name
      @_model_name ||= begin
        namespace = self.parents.detect do |n|
          n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
        end
        Name.new(self, namespace)
      end
    end
  end

  class Name < ::ActiveModel::Name
    def param_key
      @klass.param_key || super
    end

    def singular_route_key
      @klass.singular_route_key || (@klass.route_key && ActiveSupport::Inflector.singularize(@klass.route_key)) || super
    end

    def route_key
      @klass.route_key || super
    end
  end
end