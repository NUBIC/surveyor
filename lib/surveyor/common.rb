require 'securerandom'
require 'uuidtools'

module Surveyor
  class Common
    OPERATORS = %w(== != < > <= >= =~)

    class << self
      if SecureRandom.respond_to?(:urlsafe_base64)
        def make_tiny_code
          # 7 random bytes is increased to ~10 characters (sans padding) by
          # base64 encoding
          SecureRandom.urlsafe_base64(7)
        end
      else
        def make_tiny_code
          s = [SecureRandom.random_bytes(7)].pack("m*")
          s.delete!("\n")
          s.tr!("+/", "-_")
          s.delete!("=")
        end
      end

      def to_normalized_string(text)
        words_to_omit = %w(a be but has have in is it of on or the to when)
        col_text = text.to_s.gsub(/(<[^>]*>)|\n|\t/su, ' ') # Remove html tags
        col_text.downcase!                            # Remove capitalization
        col_text.gsub!(/\"|\'/u, '')                   # Remove potential problem characters
        col_text.gsub!(/\(.*?\)/u,'')                  # Remove text inside parens
        col_text.gsub!(/\W/u, ' ')                     # Remove all other non-word characters
        cols = (col_text.split(' ') - words_to_omit)
        (cols.size > 5 ? cols[-5..-1] : cols).join("_")
      end

      alias :normalize :to_normalized_string

      def generate_api_id
        UUIDTools::UUID.random_create.to_s
      end

      ##
      # @private Intended for internal use only.
      #
      # Loads and uses either `FasterCSV` (for Ruby 1.8) or the stdlib `CSV`
      # (for Ruby 1.9+).
      #
      # @return [Class] either `CSV` for `FasterCSV`.
      def csv_impl
        @csv_impl ||= if RUBY_VERSION < '1.9'
                         require 'fastercsv'
                         FasterCSV
                       else
                         require 'csv'
                         CSV
                       end
      end
    end
  end
end
