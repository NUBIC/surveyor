module TinyCode

  module ClassMethods

    RAND_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + "0123456789" + "abcdefghijklmnopqrstuvwxyz"

    def make_tiny_code
      random_string(10)
    end

    def random_string(len)
      rand_max = RAND_CHARS.size
      ret = "" 
      len.times{ ret << RAND_CHARS[rand(rand_max)] }
      ret 
    end


    def self.to_normalized_string(text)
      words_to_omit = ["a", "to", "the", "of", "has", "have", "it", "is", "in", "on", "or", "but", "when", "be"]

      # strip all the html tags from the text data
      col_text = text.gsub(/(<[^>]*>)|\n|\t/s, ' ')

      # Removing capitalization
      col_text.downcase!
      # Removing potential problem characters
      col_text.gsub!(/\"|\'/, '')
      # Removing text inside parens
      col_text.gsub!(/\(.*?\)/,'')

      # Removing all other non-word characters
      col_text.gsub!(/\W/, ' ')

      column_words = []
      words = col_text.split(' ')
      words.each do |word|
        if !words_to_omit.include?(word)
          column_words << word
        end
      end

      #reducing the word list to limit column length
      if column_words.length > 5
        column_words.slice!(0, column_words.length - 5)
      end

      #re-assemble the string
      column_words.join("_")
    end 

  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

end