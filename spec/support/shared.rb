# frozen_string_literal: true

%w(favorites feelings lifestyle numbers favorites-ish everything skip_logic).each do |name|
  shared_context name do
    before { Surveyor::Parser.parse_file(File.join(Rails.root, '..', 'spec', 'fixtures', "#{name}.rb"), trace: false) }
  end
end
