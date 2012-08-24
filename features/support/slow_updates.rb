# It appears that rails caches the filter chain after the first request. We
# can't wait and only apply this if any @slow_updates scenarios are executed.
class SurveyorController
  before_filter(:only => :update) do
    if $delay_updates
      Rails.logger.info "Slowing things down."
      sleep 2
    end
  end
end

Before('@slow_updates') do
  $delay_updates = true
end

After('@slow_updates') do
  $delay_updates = false
end
