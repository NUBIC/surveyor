class SurveySectionSweeper < ActionController::Caching::Sweeper
  observe :survey_section
  
  def after_save(section)
    expire_cache(section)
  end
  
  def after_destroy(section)
    expire_cache(section)
  end
  
  def expire_cache(section)
    expire_fregment "section_#{section.id}"
  end
end