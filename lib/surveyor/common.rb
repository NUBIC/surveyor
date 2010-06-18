module Surveyor
  class Common
    RAND_CHARS = [('a'..'z'), ('A'..'Z'), (0..9)].map{|r| r.to_a}.flatten.to_s

    def self.make_tiny_code(len = 10)
      if RUBY_VERSION < "1.8.7"
        (1..len).to_a.map{|i| RAND_CHARS[rand(RAND_CHARS.size), 1] }.to_s
      else
        len.times.map{|i| RAND_CHARS[rand(RAND_CHARS.size), 1] }.to_s
      end
    end

    def self.to_normalized_string(text)
      words_to_omit = %w(a be but has have in is it of on or the to when)
      col_text = text.gsub(/(<[^>]*>)|\n|\t/s, ' ') # Remove html tags
      col_text.downcase!                            # Remove capitalization
      col_text.gsub!(/\"|\'/, '')                   # Remove potential problem characters
      col_text.gsub!(/\(.*?\)/,'')                  # Remove text inside parens
      col_text.gsub!(/\W/, ' ')                     # Remove all other non-word characters      
      cols = (col_text.split(' ') - words_to_omit)
      (cols.size > 5 ? cols[-5..-1] : cols).join("_")
    end
  end
end