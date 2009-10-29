dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'surveyor/config'
require 'surveyor/acts_as_response'

module Surveyor
  RAND_CHARS = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten.to_s

  def self.make_tiny_code(len = 10)
    len.times.map{|i| RAND_CHARS[rand(RAND_CHARS.size), 1] }.to_s
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