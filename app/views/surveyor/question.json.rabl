attributes :api_id => :uuid
node(:help_text, :if => lambda { |q| !q.help_text.blank? }){ |q| q.help_text }
node(:type, :if => lambda { |q| q.display_type != "default" }){ |q| q.display_type }
node(:reference_identifier, :if => lambda { |q| !q.reference_identifier.blank? }){ |q| q.reference_identifier }
node(:pick, :if => lambda { |q| q.pick != "none" }){ |q| q.pick }
node(:text){ |q| q.split_text(:pre) }
node(:post_text, :if => lambda { |q| !q.split_text(:post).blank? }){ |q| q.split_text(:post) }
