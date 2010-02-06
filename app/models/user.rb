class User < ActiveRecord::Base
  acts_as_authentic 

  has_and_belongs_to_many :badges
  has_many :events
  validates_uniqueness_of :email
  validates_presence_of :first_name, :last_name

  # Check to see if a user has already acheived one or more of a particular 
  # badge with some constraints.
  #
  # Options:
  # * <tt>within</tt> - A time (e.g. "24.hours" or "15.minutes") span within which the badge must have been earned within from the time of querying to count.
  # * <tt>times</tt> - The number of times the badge must have been acheived to count. If the badge has been acheived more times than this, it still counts.
  #
  # Examples:
  # <tt>has_acheived? :playa # The user has ever acheived the "playa" badge</tt>
  # <tt>has_acheived? :playa, :times => 10 # The user has acheived the "playa" badge ten or more times</tt>
  # <tt>has_acheived? :playa, :within => 24.hours # The user has acheived the "playa" badge within the last 24 hours</tt>
  def has_acheived?(badge, options={})
    if options.has_key?(:within)
      conditions = ["badges.name = ? and badges_users.created_at >= ?", badge.to_s, options[:within].ago]
    else
      conditions = ["badges.name = ?", badge.to_s]
    end

    acheived = self.badges.count(:conditions => conditions)
    threshold = options[:times] || 1

    return acheived >= threshold
  end

  # Check to see if a user has performed some criteria of events.
  #
  # Options:
  # * <tt>within</tt> - A time (e.g. "24.hours" or "15.minutes") span within which the event must have been earned within from the time of querying to count.
  # * <tt>times</tt> - The number of times the event must have occurred to count. If the badge has been acheived more times than this, it still counts.
  # * <tt>value</tt> - The value of the event must match to count. 
  #
  # Examples:
  # <tt>has_done? :status # The user has changed the status of an issue</tt>
  # <tt>has_done? :status, :value => "resolved" # The user has changed the status of an issue to be "resolved"</tt>
  def has_done?(event, options={})
    sql = []
    values = []
    if options.has_key?(:within)
      sql << "events.name = ? and events.created_at >= ?"
      values += [event.to_s, options[:within].ago]
    else
      sql << "events.name = ?"
      values << event.to_s
    end

    if options.has_key?(:value)
      sql << "events.value = ?"
      values << options[:value]
    end

    conditions = [sql.join(" and ")] + values
    acheived = self.events.count(:conditions => conditions)
    threshold = options[:times] || 1

    return acheived >= threshold
  end
end
