module SurveyorAPIHelpers
  def json_response
    page.source
  end
  def title_modification_module(modifier)
    mod = Module.new
    mod.send(:define_method, :filtered_for_json) do
      dolly = self.clone
      dolly.sections = self.sections
      dolly.title = "#{modifier} #{dolly.title}"
      dolly
    end
    return mod
  end
end