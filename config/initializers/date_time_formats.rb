Time::DATE_FORMATS.merge!(
  :detail => lambda {|time|
    if time.year == Time.now.year
      time.strftime "%a %B #{time.day.ordinalize} at %I:%M %p"
    else
      time.strftime "%a %B #{time.day.ordinalize}, %Y at %I:%M %p"
    end
  },
  :full => '%B %d, %Y at %I:%M %p',
  :full_short => '%m/%d/%Y at %I:%M %p',
  :md => '%m/%d',
  :mdy => '%m/%d/%y',
  :mdY => '%m/%d/%Y',
  :time => '%I:%M %p',
  :time_date => lambda {|time|
    if time.year == Time.now.year
      time.strftime "%I:%M %p %B #{time.day.ordinalize}"
    else
      time.strftime "%I:%M %p %B #{time.day.ordinalize}, %Y"
    end
  },
  :friendly => lambda { |time|
    if time.year == Time.now.year
      time.strftime "%b #{time.day.ordinalize}"
    else
      time.strftime "%b #{time.day.ordinalize}, %Y"
    end
  },
  :status_fmt => '%a. %I:%M%p %m/%d/%Y'
)