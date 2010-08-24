module ResultsHelper
  def display_response(r_set,question)
    sets = r_set.responses.select{|r| r.question.display_order == question.display_order}
	  	if sets.size == 0
  			return "-"
  		elsif sets.size == 1
  			return (sets.first.string_value || sets.first.text_value || show_answer(sets.first))
  		else
  		  txt = ""
        sets.each do |set|
          txt << show_answer(set) + "<br/>"
        end
        return txt
		  end
  end
  
  def show_answer(set)
     set.answer.text
  end
end