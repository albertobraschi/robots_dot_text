module RobotsDotText
    
  # These are the methods that are availble to you in the controller.
  module ActionControllerMethods

    def self.included(base)
      base.extend(ClassMethods)
    end
    
    # Class methods included in ActionController::Base
    module ClassMethods
      
      # Call this in your controller if you want to disable sessions for known robots
      def turn_off_sessions_for_robots
        robots = RobotsDotText::UserAgents::KNOWN_USER_AGENTS.values
        session :off, :if => lambda {|req| req.user_agent =~ /(#{robots.join("|")})/i}
      end
    end
    
    # Instance methods included in ActionController::Base
    module InstanceMethods
      
      # Creates a new RobotsFile object and passes the to_s method (so you don't have to).
      # See the methods for RobotsFile for usage.
      def robots_dot_text(&block)
        RobotsDotText::RobotsFile.new(&block).to_s
      end

      # Call this method in your controller if you'd like to log the user_agent for the current request.
      #
      # By default, a new log file is created in <em>/log</em> called <b>user_agents.log</b>. The user-agents and time
      # will be stored here. 
      #
      # The default time format is :long, if you'd like to change this you can specify your own format with
      # the format parameter. See http://handyrailstips.com/tips/1-keeping-your-dates-and-times-dry-with-to_formatted_s
      # for more info on date/time formats.
      #
      # If you'd like to use a different log, the Rails logger for example, you can
      # specify this with the log_to parameter.
      def log_user_agent(format = :long, log_to = ua_logger)
        raise "Cannot log user agents, SHOULD_CREATE_UA_LOG = false
  See RobotsDotText README for more info" unless SHOULD_CREATE_UA_LOG
        log_to.info "\"#{request.user_agent}\", \"#{DateTime.now.to_s(format)}\""
      end

      protected
    
      # Provides access to user_agents.log
      def ua_logger
        RobotsDotText::UserAgentLog::UA_LOGGER
      end
    
    end
    
  end
end
ActionController::Base.send(:include, RobotsDotText::ActionControllerMethods)