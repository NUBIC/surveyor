module Surveyor
  module RenderText
    def render_question_text(context = nil)
      render_text(text, context)
    end
    
    def render_help_text(context = nil)
      render_text(help_text, context)
    end
    
    def render_answer_text(text, context = nil)
      render_text(text, context)
    end
    
    def render_text(text, context = nil)
      context ? context.render(text) : text
    end
  end
end