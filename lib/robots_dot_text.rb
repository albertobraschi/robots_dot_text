require "robots_dot_text/user_agents"
module RobotsDotText
  
  # Change the value of this constant if you <b>don't</b> want to log the user-agents.
  SHOULD_CREATE_UA_LOG = true
  
  class RobotsFile

    # Creates a new RobotsFile object
    #
    # In your controller you should use <b>robots_dot_text</b>:
    #
    #   robots_dot_text do |rules|
    #     rules.add :all, admin_path
    #   end
    def initialize(&block)
      @permissions = []
      @rules = String.new
      yield(self)
    end
    
    # Adds a comment to the robots file. 
    # Your comment can also contain line-breaks like so it can be spread over multiple lines
    def comment(comment)
      comment.split("\n").each do |comnt|
        @rules << "# #{comnt}\n"
      end
      nil
    end
    
    # Adds a Sitemap directive. You can pass an array of sitemap paths if you have more than one
    def sitemap(*urls)
      urls.each do |url|
        raise ArgumentError, "Sitemap url #{url.inspect} is invalid. This should be an absolute URL." if url.scan(/^http/).empty?
        @rules << "Sitemap: #{url.to_s}\n"
      end
    end
    
    # Adds an Allow directive. You can pass an array of paths to be allowed.
    # Note - To maximise crawler compatibility you should include Allow directives _before_
    # Disallow directives.
    def allow(*routes)
      routes.each {|route| @rules << "Allow: #{route.to_s}\n" }
    end
    
    # Adds a Disallow directive. Use this when you're also specifying an Allow directive first. Otherwise,
    # it's easier to just add paths to the add method.
    def block(*routes)
      routes.each {|route| @rules << "Disallow: #{route.to_s}\n" }
    end
    
    # Adds a blank line in your robots.txt file to help humans read it a little easier. If you're too
    # lazy to write line_break you could also use the shorter method <b>br</b>.
    def line_break
      @rules << "\n"
    end
    
    # See: *line_break*
    def br
      line_break
    end
    
    # Adds a Visit-time directive. You can use this directive to tell compliant robots when they should 
    # crawl your site.  Time parameters should be written like: 0080 (8am) or 0000 (12am).
    def visit_time(start_time, end_time)
      raise ArgumentError, "start_time #{start_time.inspect} is invalid, format should be \"\\d\\d\\d\\d\"" unless start_time =~ /^\d\d\d\d$/
      raise ArgumentError, "end_time #{start_time.inspect} is invalid, format should be \"\\d\\d\\d\\d\"" unless end_time =~ /^\d\d\d\d$/
      @rules << "Visit-time: #{start_time}-#{end_time}\n"
    end
    
    # Adds a Crawl-delay directive. You can use this directive to tell compliant robots how many seconds 
    # they should leave between requests to the same server. Delay should be expressed as an integer.
    def delay(delay)
      raise ArgumentError, "delay #{delay.inspect} is invalid, format should be \\d+" unless delay.to_s =~ /^\d+$/
      @rules << "Crawl-delay: #{delay.to_s}\n"
    end
    
    # Adds a Request-rate directive. You can use this directive to tell compliant robots the rate at which they
    # should crawl your site. Express this as a fraction. Units <b>s</b>, <b>m</b> or <b>h</b> (seconds, mins, hours) are optional for the denominator. 
    # eg. "1/500s"
    def rate(rate)
      raise ArgumentError, "rate #{rate.inspect} is invalid, this should be a fraction. eg.: 1/864" if rate !~ /^\d{1,2}\/\d+(s|m|h)?$/
      @rules << "Request-rate: #{rate}\n"
    end
    # This method adds the User-agent directive. The <tt>user_agent</tt> parameter can be either a string or a symbol.
    # Any of the USER_AGENTS can also be passed as the <tt>user_agent</tt> parameter.
    def add(user_agent, *paths)
      @rules << Rule.new(user_agent, paths).to_s
    end
    # Returns all of the rules nicely concatenated into one string for output
    def to_s
      @rules.to_s
    end

  end
  
  # A new Rule object is created when adding a rule to RobotsFile object with .add
  class Rule
    include UserAgents
    
    # Creates a new rule instance.
    #
    #
    def initialize(user_agent, *paths)
      raise ArgumentError, "user_agent can't be nil" if user_agent.nil?
      raise ArgumentError, "user_agent can't be blank" if user_agent.is_a?(String) and user_agent.empty?
      @user_agent = user_agent
      @paths = paths.flatten      
      self
    end
  
    # Converts a rule object to a string with linebreaks for the RobotsFile object
    def to_s
      string = String.new
      if @user_agent.is_a?(Array)
        @user_agent.each do |ua|
          string << "User-agent: #{known_agents ua}\n"
        end
      else
        string << "User-agent: #{known_agents @user_agent}\n"
      end
      @paths.each { |path| string << "Disallow: #{path}\n" }
      string
    end
    
    protected
    
    
    # Checks if the user_agent passed to add is one of those listed in USER_AGENTS
    def known_agents(ua)
      USER_AGENTS[ua.to_sym] ? USER_AGENTS[ua.to_sym] : ua.to_s
    end
    
  end
  
  # Logger to log robot user_agents
  class UserAgentLog

    # Creates a new ActiveSupport::BufferedLogger instance and sets the UA_LOGGER contstant as this logger.
    def initialize
      @path = "#{Rails.root}/log/user_agents.log"
      @ua_logger = ActiveSupport::BufferedLogger.new(@path)
      add_first_break if File.read(@path).scan(/\n/).empty?
      silence_warnings {UserAgentLog.const_set "UA_LOGGER", @ua_logger}
    end
    
    protected
    
    # clears away the initial line
    def add_first_break
      File.open(@path, "w") do |file|
        file.write ""
      end
    end
    
  end
  
  # Only create a new logger instance if SHOULD_CREATE_UA_LOG is set to true.
  # You can set SHOULD_CREATE_UA_LOG to false if you don't plan on using the ua_logger
  UserAgentLog.new if SHOULD_CREATE_UA_LOG
  
  
  module ActionControllerMethods

    # when the RobotsDotText module is include, extend self with ClassMethods and InstanceMethods
    def self.included(base)      
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end
  
    # Class methods included in ActionController::Base
    module ClassMethods
      
      include UserAgents
      
      # Call this in your controller if you want to disable sessions for known robots
      # (not required if you're running Rails 2.3 or higher)
      def turn_off_sessions_for_robots
        robots = KNOWN_USER_AGENTS.values
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