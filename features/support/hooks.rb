GLOBAL_CONFIG = File.expand_path(File.dirname(__FILE__) + '/../../testbed/config/data/test_global_config.yml')
Before do
   File.open(GLOBAL_CONFIG, 'w') do |f|
      f.write <<-STRING
        center: Northwestern
      STRING
   end
end

After do
  File.delete(GLOBAL_CONFIG) if File.exists? GLOBAL_CONFIG
end