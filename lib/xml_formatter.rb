module XmlFormatter
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.tag!(self.class.name.downcase.to_sym, self.attributes) do
      self.class.reflect_on_all_associations.to_a.each do |assoc|
        xml.tag!(assoc.name)
      end
    end
  end
end