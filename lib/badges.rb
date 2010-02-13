module Trinket
  module Badges
    class ShouldNotBeAwardedError < RuntimeError
    end

    # This module contains all the dynamically generated badge classes.
    module Rules 
    end

    # Documentation is a base class that gets extended by automatically 
    # generated badge classes. It generates a human readable description of the
    # requirements to achieve each badge.
    class Documentation
      def emit(requirement)
        @requirements ||= []
        @requirements << requirement
      end

      def to_s
        parse_requirements_in_words

        @requirements.join(". ") + "."
      end

      def is_one_time_only
        emit "Can only be awarded once"
      end

      def value(options)
        options.has_key?(:value) ? "with the value #{options[:value]}" : ""
      end

      def times(options)
        options.has_key?(:times) ? "#{options[:times]} times" : ""
      end

      def within(options)
        # TODO: friendly format this time interval
        options.has_key?(:within) ? "within the last #{options[:within]}" : ""
      end

      def event_must_have_occurred(event, options={})
        emit "The user must have performed the #{event} event #{value(options)} #{times(options)} #{within(options)}".strip
      end

      def must_have_achieved(badge, options={})
        emit "The user must have achieved the #{badge.to_s.titleize} badge #{times(options)} #{within(options)}".strip
      end
    end

    # Context is a base class that gets extended by automatically generated
    # badge classes. The methods that are implemented here are the methods that
    # are available to the badge description language.
    #
    # Context wraps the methods that appear within the badge definition in a 
    # user context. This means that you don't have to try and pass "user" as a
    # stated argument to every method. When context is evaluated for anything
    # it's instantiated with a user object that's used implicitely.
    #
    # e.g.
    #
    # <tt>
    # badge "Sam's henchman" do
    #   is_one_time_only # <-- This method gets implemented here.
    # end
    # </tt>
    class Context 
      attr_accessor :user, :name

      def initialize(name, user)
        self.name = name
        self.user = user
      end

      # This badge can only be awarded one time. 
      def is_one_time_only 
        must_not_have_achieved(name)
      end

      # A particular event or set of events must have occured. For options see
      # <tt>Badge.has_done?</tt>.
      def event_must_have_occurred(event, options={})
        if !Badges.has_done?(user, event, options)
          raise ShouldNotBeAwardedError.new("The user hasn't performed #{event} => #{options.inspect}.")
        end
      end

      # A particular badge must have already been achieved. For options see
      # <tt>Badge.has_achieved?</tt>
      def must_have_achieved(badge, options={})
        if !Badges.has_achieved?(user, badge, options)
          raise ShouldNotBeAwardedError.new("The #{badge} => #{options.inspect} badge hasn't been achieved.")
        end
      end

      # A particular badge must not have already been achieved. For options see
      # <tt>Badge.has_achieved?</tt>
      def must_not_have_achieved(badge, options={})
        if Badges.has_achieved?(user, badge, options)
          raise ShouldNotBeAwardedError.new("The #{badge} => #{options.inspect} badge has already been achieved.")
        end
      end
    end

    # Check to see if a user has already achieved one or more of a particular 
    # badge with some constraints.
    #
    # Options:
    # * <tt>within</tt> - A time (e.g. "24.hours" or "15.minutes") span within which the badge must have been earned within from the time of querying to count.
    # * <tt>times</tt> - The number of times the badge must have been achieved to count. If the badge has been achieved more times than this, it still counts.
    #
    # Examples:
    # <tt>has_achieved? :playa # The user has ever achieved the "playa" badge</tt>
    # <tt>has_achieved? :playa, :times => 10 # The user has achieved the "playa" badge ten or more times</tt>
    # <tt>has_achieved? :playa, :within => 24.hours # The user has achieved the "playa" badge within the last 24 hours</tt>
    def self.has_achieved?(user, badge, options={})
      if options.has_key?(:within)
        conditions = ["badges.name = ? and badges_users.created_at >= ?", badge.to_s, options[:within].ago]
      else
        conditions = ["badges.name = ?", badge.to_s]
      end

      achieved = user.badges.count(:conditions => conditions)
      threshold = options[:times] || 1

      return achieved >= threshold
    end

    # Check to see if a user has performed some criteria of events.
    #
    # Options:
    # * <tt>within</tt> - A time (e.g. "24.hours" or "15.minutes") span within which the event must have been earned within from the time of querying to count.
    # * <tt>times</tt> - The number of times the event must have occurred to count. If the badge has been achieved more times than this, it still counts.
    # * <tt>value</tt> - The value of the event must match to count. 
    #
    # Examples:
    # <tt>has_done? :status # The user has changed the status of an issue</tt>
    # <tt>has_done? :status, :value => "resolved" # The user has changed the status of an issue to be "resolved"</tt>
    def self.has_done?(user, event, options={})
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
      achieved = user.events.count(:conditions => conditions)
      threshold = options[:times] || 1

      return achieved >= threshold
    end

    # Award a user any badges that they've qualified for.
    def self.award(user)
      Rules.constants.each do |badge|
        award_if_qualified(user, badge.underscore)
      end
    end

    # Award a user a badge if they're qualified. The badge definition criteria
    # must be satisfied for the user for them to be qualified.
    def self.award_if_qualified(user, badge)
      badge = badge.to_s
      class_name = badge.camelize
      begin
        definition = Rules.const_get(class_name)
      rescue NameError
        raise "#{badge} badge is not defined."
      end

      raise ArgumentError.new("You must provide a user to check if a badge should be awarded") if user.nil?

      # Run the definition and see if this badge should me awarded.
      definition.new(badge, user).check_should_be_awarded()

      # If there were no condition errors checking the definition it means that
      # this user has been awarded this badge.
      user.badges << Badge.find_by_name(badge) 
    rescue ShouldNotBeAwardedError => e
      # If there was a condition error, the user has not met the criteria to be
      # awarded this badge.
    end

    # This is the heart of the badge defintion DSL. Calling badge takes a block
    # and creates several new classes which each implement some named method
    # that executes that block in their own context. Essentially each new class
    # that's implemented takes the same language, and does something different
    # with it (generate documentation or determine whether a user has satisfied
    # the badge requirements)
    #
    # e.g.
    #
    # <tt>
    # badge "Captain, we have visual" do
    #   is_one_time_only
    #   must_have_achieved(:temporal_distortion)
    # end
    # </tt>
    #
    # This creates the new class CaptainWeHaveVisual and binds the block to the
    # instance method "<tt>check_should_be_awarded</tt>". The newly created
    # class implements the methods in the block that are necessary to determine
    # if a user has achieved this badge.
    def self.badge(name, &definition)
      class_name = name.to_s.camelize
      raise "#{name} badge is already defined." if Rules.const_defined?(class_name)

      context_klass = Class.new(Context)
      context_klass.class_eval do
        # Bind the documentation class to the class variable.
        @@documentation_class = Class.new(Documentation)
        @@documentation_class.class_eval do
          define_method("parse_requirements_in_words", &definition)
        end

        # Turn the badge definition into english for displaying to the user.
        def self.requirements_in_words
          @@documentation_class.new.to_s
        end

        define_method("check_should_be_awarded", &definition)
      end
      Rules.const_set(class_name, context_klass)
    end

  end
end
