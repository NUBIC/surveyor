$VERBOSE = nil
if surveyor_gem = Gem.searcher.find('surveyor')
  Dir["#{surveyor_gem.full_gem_path}/lib/tasks/*.rake"].each { |ext| load ext }
end