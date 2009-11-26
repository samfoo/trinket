# TODO: Determine what the best way to pass in the current user is.
module Trinket
  module Badges
    class ConditionError < RuntimeError
    end

    class Definition 
      attr_accessor :user

      def initialize(user)
        self.user = user
      end

      def must_have_acheived(badge, options={})
        if !user.has_acheived?(badge, options)
          raise ConditionError.new("The #{badge} => #{options.inspect} badge hasn't been acheived.")
        end
      end

      def must_not_have_acheived(badge, options={})
        if user.has_acheived(badge, options)
          raise ConditionError.new("The #{badge} => #{options.inspect} badge has already been acheived.")
        end
      end
    end

    def self.run(user, name)
      class_name = name.to_s.camelize
      begin
        definition = Trinket::Badges.const_get(class_name)
      rescue NameError
        raise "#{name} badge is not defined."
      end

      # TODO: Log a warning if user is nil at least.

      # Run the definition and see if this badge should me awarded.
      definition.new(user).check_definition()

      # If there were no condition errors checking the definition it means that
      # this user has been awarded this badge.
      user.badges << Badge.find_by_name(name) unless user.nil?
    rescue ConditionError => e
      # If there was a condition error, the user has not met the criteria to be
      # awarded this badge.
    end

    def self.badge(name, &definition)
      class_name = name.to_s.camelize
      raise "#{name} badge is already defined." if Trinket::Badges.const_defined?(class_name)
      klass = Class.new(Definition)

      # TODO: Move this into a submodule? Move reserved methods to a submodule
      klass.class_eval do
        define_method("check_definition", &definition)
      end

      Trinket::Badges.const_set(class_name, klass)
    end

  end
end
