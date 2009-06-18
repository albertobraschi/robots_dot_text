# ==Examples:
# 
# ===Simple example
# 
# <em># in RobotsController</em>
#   def index
#     respond_to do |format|
#       format.text do
#         log_user_agent # adds the crawler's user_agent to user_agents.log
#         @page_content = robots_dot_text do |rules|
#           rules.comment "Tell all crawlers to keep out of these pages"
#           rules.add :all, admin_path, customers_path, log_path
#           rules.br
#           rules.sitemap sitemap_url
#         end
#         render :text => @page_content
#       end
#     end
#   end
#   
# ===Complex Example
# <em># in RobotsController</em>
# 
#   def index
#     respond_to do |format|
#       format.txt do
#         log_user_agent(:short, logger) # :short is the datetime format, logger specifies to use Rails.logger instead
#         @page_content = robots_dot_text do |rules|
#           rules.add :all
#           rules.sitemap sitemap_url, google_news_sitemap_url
#           rules.br
#           rules.comment "Google ignores most directives so here are some rules for Google"
#           rules.add [:google, :google_image, :google_mobile]
#           rules.allow "/articles/*"
#           rules.block articles_path
#           rules.line_break
#           rules.comment "These crawlers respect the Crawl-delay directive"
#           rules.add [:yahoo, :msn, :cuil, :ask], private_path, admin_path
#           rules.rate "1/500s"
#           rules.delay 10
#           rules.comment "Request robots only crawl between 2am and 8am."
#           rules.visit_time "0200", "0800"
#         end
#         render :text => @page_content
#       end
#     end
#   end


require 'robots_dot_text'
require 'robots_dot_text/user_agents'
require 'robots_dot_text/action_controller_methods'

ActionController::Base.send(:include, RobotsDotText::ActionControllerMethods)
