require File.dirname(__FILE__) + '/surveyor/acts_as_response'
module Surveyor
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

# From http://guides.rubyonrails.org/plugins.html#controllers
# Fix for:
# ArgumentError in SurveyorController#edit 
# A copy of ApplicationController has been removed from the module tree but is still active!
# Equivalent of using "unloadable" in SurveyorController (unloadable has been deprecated)

%w{models controllers}.each do |dir|
  path = File.expand_path(File.join(File.dirname(__FILE__), '../app', dir))
  # $LOAD_PATH << path # already here
  # ActiveSupport::Dependencies.load_paths << path # already here too
  ActiveSupport::Dependencies.load_once_paths.delete(path)
  # [$LOAD_PATH, ActiveSupport::Dependencies.load_paths, ActiveSupport::Dependencies.load_once_paths].each{|x| Rails.logger.info x}
end
