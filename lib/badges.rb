module Trinket
  module Badges
    class ShouldNotBeAwardedError < RuntimeError
    end

    module Rules 
    end

    class Context 
      attr_accessor :user
      attr_accessor :name

      def initialize(name, user)
        self.name = name
        self.user = user
      end

      def is_one_time_only 
        must_not_have_acheived(name)
      end

      def event_must_have_occurred(event, options={})
        if !user.has_done?(event, options)
          raise ShouldNotBeAwardedError.new("The user hasn't performed #{event} => #{options.inspect}.")
        end
      end

      def must_have_acheived(badge, options={})
        if !user.has_acheived?(badge, options)
          raise ShouldNotBeAwardedError.new("The #{badge} => #{options.inspect} badge hasn't been acheived.")
        end
      end

      def must_not_have_acheived(badge, options={})
        if user.has_acheived?(badge, options)
          raise ShouldNotBeAwardedError.new("The #{badge} => #{options.inspect} badge has already been acheived.")
        end
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
      user.badges << Badge.find_by_name(badge) unless user.nil?
    rescue ShouldNotBeAwardedError => e
      # If there was a condition error, the user has not met the criteria to be
      # awarded this badge.
    end

    def self.badge(name, &definition)
      class_name = name.to_s.camelize
      raise "#{name} badge is already defined." if Rules.const_defined?(class_name)
      klass = Class.new(Context)

      # TODO: Move this into a submodule? Move reserved methods to a submodule
      klass.class_eval do
        define_method("check_should_be_awarded", &definition)
      end

      Rules.const_set(class_name, klass)
    end

  end
end
