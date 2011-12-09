module Surveyor
  module RenderText
    def render_text(context = nil)
      context ? context.render(text) : text
    end
  end
end
