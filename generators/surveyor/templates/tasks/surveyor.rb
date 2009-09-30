$VERBOSE = nil
Dir["#{Gem.searcher.find('surveyor').full_gem_path}/lib/tasks/*.rake"].each { |ext| load ext }