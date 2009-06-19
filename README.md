# RobotsDotText

Robots dot text allows you to create a robots.txt file dynamically using Ruby.
This gives you the option to create directives which are updated dynamically as your site's content changes.

...It's also a bit more fun, it allows you to use your routes to specify directives, it saves you from
 having to remember the names of all of the various crawlers and the syntax for robots.txt files.

You also have the option to log every request made to /robots.txt in a separate log file called user_agents.log - Perfect for spider-spotters

The user_agents.log is written in csv(ish) format so you can change the extension and upload it to a database or spreadsheet of your choice.

All feedback welcome: dr_gavin@hotmail.com

## Setup Instructions

1. script/plugin install http://github.com/GavinM/robots dot text.git

2. remove <b>robots.txt</b> from your _/public_ directory

3. create a controller for your robots with an action called index<br />
<tt>script/generate controller robots index</tt>

4. add a route in <b>routes.rb</b> to your robots index action:<br />
<tt>map.connect "robots.txt", :controller => "robots"</tt>

See the examples below for implementation.


## Examples:

### Simple example
<pre>
	<code>
class RobotsController < ActionController::Base

  def	index
    respond_to do |format|
      format.text do
        log_user_agent # adds the crawler's user_agent to user_agents.log
        @page_content = robots dot text do |rules|
          rules.comment "Tell all crawlers to keep out of these pages"
          rules.add :all, admin_path, customers_path, log_path
          rules.br
          rules.sitemap sitemap_url
        end
        render :text => @page_content, :layout => false
      end
    end
  end

end
	</code>
</pre>

	will render:

	# Tell all crawlers to keep out of these pages
	User-agent: *
	Disallow: /admin
	Disallow: /customers
	Disallow: /log

	Sitemap: http://handyrailstips.com/sitemap.xml

### Complex Example
<pre>
	<code>
class RobotsController & ActionController::Base

  def	index
    respond_to do |format|
      format.txt do
        log_user_agent(:short, logger) # :short is the datetime format, logger specifies to use Rails.logger instead
        @page_content = robots dot text do |rules|
          rules.add :all
          rules.sitemap sitemap_url, google_news_sitemap_url
          rules.br
          rules.comment "Google ignores most directives so here are some rules for Google"
          rules.add [:google, :google_image, :google_mobile]
          rules.allow article_path("*")
          rules.block articles_path
          rules.line_break
          rules.comment "These crawlers respect the Crawl-delay directive"
          rules.add [:yahoo, :msn, :cuil, :ask], private_path, admin_path
          rules.rate "1/500s"
          rules.delay 10
          rules.comment <<-END
Request robots only crawl between 2am and 8am.
(Those are our quiet times)
END
          rules.visit_time "0200", "0800"
        end
        render :text => @page_content, :layout => false
      end
    end
  end

end
	</code>
</pre>
</tt>
will render:

	User-agent: *
	Sitemap: http://handyrailstips.com/sitemap.xml
	Sitemap: http://handyrailstips.com/google_news_sitemap.xml

	# Google ignores most directives so here are some rules for Google
	User-agent: Googlebot
	User-agent: Googlebot-Image
	User-agent: Googlebot-Mobile
	Allow: /articles/*
	Disallow: /articles

	# These crawlers respect the Crawl-delay directive
	User-agent: Slurp
	User-agent: MSNBot
	User-agent: Twiceler
	User-agent: Teoma
	Disallow: /private
	Disallow: /admin
	Request-rate: 1/500s
	Crawl-delay: 10
	# Request robots only crawl between 2am and 8am.
	# (Those are our quiet times)
	Visit-time: 0200-0800

## Extras
To turn off sessions for robots, add *turn_off_sessions_for_robots* to your application controller.
(not required from Rails >=2.3)

To log the user-agent in the current request header, call *log_user_agent* in your controller. You can use this in your respond_to block to log the user-agent of any robots hitting /robots.txt

Check out the RDocs - /doc/index.html

For more info on crawler user-agents check out [this page](http://www.user-agents.org/)

Copyright © 2009 Gavin Morrice, released under the MIT license