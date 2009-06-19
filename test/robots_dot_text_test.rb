#:enddoc:
require 'test_helper'
require "#{File.dirname(__FILE__)}/../lib/robots_dot_text/user_agents"
class RobotsDotTextTest < ActiveSupport::TestCase
  include UserAgents
  
  test "eskimos should be cold" do
    @eskimos = "cold"
    assert_equal @eskimos, "cold"
  end
  
  test "should add user agent line and paths with add" do
    new_robot do |rules|
      rules.add :google, "/", "/users/"
    end
    file_equals? "User-agent: Googlebot\nDisallow: /\nDisallow: /users/\n"
  end
  
  test "should raise an error if user-agent isn't valid" do
    assert_raise ArgumentError do
      new_robot do |rules|
        rules.add nil, "/", "index.html"
      end
    end
  end
  
  test "should accept a symbol for user_agent" do
    new_robot do |rules|
      rules.add :all, "/"
      rules.add :google, "/index.html"
    end
    file_equals? "User-agent: *\nDisallow: /\nUser-agent: Googlebot\nDisallow: /index.html\n"
  end
  
  test "should accept an array for user_agent" do
    new_robot do |rules|
      rules.add [:google, :yahoo], "/index.html", "/rude_pics/*.jpg"
    end
    file_equals? "User-agent: #{USER_AGENTS[:google]}
User-agent: #{USER_AGENTS[:yahoo]}
Disallow: /index.html
Disallow: /rude_pics/*.jpg
"
  end
  
  test "should add a comment with comment" do
    new_robot do |rules|
      rules.comment <<-END
This is a comment
Over two lines
END
    end
    file_equals? "# This is a comment\n# Over two lines\n"
  end
  
  test "should add sitemaps with sitemap" do
    new_robot do |rules|
      rules.sitemap "http://mydomain.com/sitemap.xml", "http://mydomain.com/new_posts.xml"
    end
    file_equals? "Sitemap: http://mydomain.com/sitemap.xml\nSitemap: http://mydomain.com/new_posts.xml\n"
  end
  
  test "should raise an error if sitemap is not absolute url" do
    assert_raise ArgumentError do
      new_robot do |rules|
        rules.sitemap "/sitemap.xml"
      end
    end
  end
  
  test "should add allow rules with allow" do
    new_robot do |rules|
      rules.allow "/index.html", "/users/index.html"
    end
    file_equals? "Allow: /index.html\nAllow: /users/index.html\n"
  end
  
  test "should add Visit-time with visit_time" do
    new_robot do |rules|
      rules.visit_time "0800", "1200"
    end
    file_equals? "Visit-time: 0800-1200\n"
  end
  
  test "should raise an error if time is not the correct format" do
    assert_raise ArgumentError do
      new_robot do |rules|
        rules.visit_time "08:00", "12:00"
      end
    end
  end
  
  test "should add a line break with line_break" do
    new_robot do |rules|
      rules.line_break
    end
    file_equals? "\n"
  end
  
  test "should add Request-rate with rate" do
    new_robot do |rules|
      rules.rate "1/500"
    end
    file_equals? "Request-rate: 1/500\n"
  end
  
  test "should accept different units for rate" do
    new_robot do |rules|
      rules.rate "1/500s"
      rules.rate "1/500m"
      rules.rate "1/500h"
    end
    file_equals? "Request-rate: 1/500s\nRequest-rate: 1/500m\nRequest-rate: 1/500h\n"
  end
  
  test "should raise an error if rate is not the correct format" do
    assert_raise ArgumentError do
      new_robot do |rules|
        rules.rate "1/666x"
      end
    end
  end
  
  test "should add extra disallow rules with block" do
    new_robot do |rules|
      rules.block "/users/new", "/blog/"
    end
    file_equals? "Disallow: /users/new\nDisallow: /blog/\n"
  end
  
  test "should alias line_break with something short and snappy like br" do
    new_robot do |rules|
      rules.br
    end
    file_equals? "\n"
  end
  
  test "should combine a mixture of all of these methods into something beautiful" do
    new_robot do |rules|
      rules.comment "Block all bots from all pages except articles"
      rules.add :all
      rules.allow "/articles/show", "/articles/"
      rules.block "/"
      rules.rate "1/5s"
      rules.comment <<-END
Request these robots only crawl between 2am and 8am.
(Those are our quiet times)
END
      rules.visit_time "0200", "0800"
      rules.line_break
      rules.comment "Give google, yahoo and msn a little extra access"
      rules.add [:google, :yahoo, :msn], "/private/", "/admin"
      rules.delay 10
      rules.br
      rules.sitemap "http://mydomain.com/articles.xml", "http://mydomain.com/sitemap.xml"
    end
    file_equals? "# Block all bots from all pages except articles
User-agent: *
Allow: /articles/show
Allow: /articles/
Disallow: /
Request-rate: 1/5s
# Request these robots only crawl between 2am and 8am.
# (Those are our quiet times)
Visit-time: 0200-0800

# Give google, yahoo and msn a little extra access
User-agent: Googlebot
User-agent: Slurp
User-agent: MSNBot
Disallow: /private/
Disallow: /admin
Crawl-delay: 10

Sitemap: http://mydomain.com/articles.xml
Sitemap: http://mydomain.com/sitemap.xml
"  end


  test "should add a shortcut method called robots_dot_text to ActionController::Base" do
    @shortcut = ActionController::Base.new.robots_dot_text do |rules|
      rules.add :all, "/"
    end
    @longcut = RobotsDotText::RobotsFile.new do |rules|
      rules.add :all, "/"
    end.to_s
    assert_equal @shortcut, @longcut
  end
  
  test "should create a new log file called user_agent.log with setup_ua_log" do
    path = "#{Rails.root}/log/user_agents.log"
    File.delete("#{Rails.root}/log/user_agents.log") if File.exist?(path)
    RobotsDotText::UserAgentLog.new
    assert File.exist?(path)
  end

  
  def new_robot(&block)
    @robots = RobotsDotText::RobotsFile.new(&block).to_s
  end
  
  def file_equals?(content)
    assert_equal @robots, content
  end
  
end
