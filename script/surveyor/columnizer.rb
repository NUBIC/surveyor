module Columnizer
   def self.to_normalized_column(text)
      words_to_omit = %w(a to the of has have it is in on or but when be)
      col_text = text.gsub(/(<[^>]*>)|\n|\t/s, ' ') # Remove html tags
      col_text.downcase!                            # Remove capitalization
      col_text.gsub!(/\"|\'/, '')                   # Remove potential problem characters
      col_text.gsub!(/\(.*?\)/,'')                  # Remove text inside parens
      col_text.gsub!(/\W/, ' ')                     # Remove all other non-word characters      
      cols = (col_text.split(' ') - words_to_omit)
      (cols.size > 5 ? cols[-5..-1] : cols).join("_")
   end 
end