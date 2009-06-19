# When adding User-agent directives with the <b>add</b> method, you can pass any of these symbols as the
# user agent parameter. For example:
#
# <tt>robots_dot_text new { |rules| rules.add :google, "/users", "/admin" }</tt>
#
# ... which makes life a little easier.
module UserAgents
  
  # ==Known User Agents
  # http://www.google.com/support/webmasters/bin/answer.py?hl=en&answer=40364
  # [:google] => "Googlebot"
  # [:google_image] =>  "Googlebot-Image"
  # [:google_mobile] =>  "Googlebot-Mobile"
  #
  # http://help.live.com/help.aspx?mkt=en-gb&project=wl_webmasters
  # [:msn] => "MSNBot"
  # 
  # http://help.yahoo.com/l/us/yahoo/search/webcrawler/
  # [:yahoo] => "Slurp"
  #
  # http://help.yahoo.com/l/us/yahoo/search/image/image-08.html
  # [:yahoo_mm_crawler] => "yahoo-mmcrawler"
  # [:yahoo_blogs] => "yahoo-blogs/v3.9"
  #
  # http://about.ask.com/en/docs/about/webmasters.shtml
  # [:ask] => "Teoma"
  #
  # http://www.cuil.com/info/webmaster_info/
  # [:cuil] => "Twiceler"
  #
  # http://www.gigablast.com/spider.html
  # [:gigablast] => "Gigabot"
  #
  # http://www.scrubtheweb.com/help/technology.html
  # [:scrub_the_web] =>  "Scrubby"
  #
  # http://www.dmoz.org/guidelines/robozilla.html
  # [:dmoz] => "Robozilla"
  #
  # http://nutch.sourceforge.net/docs/en/bot.html
  # [:nutch] => "Nutch"
  #
  # http://www.alexa.com/help/webmasters
  # [:alexa] =>  "ia_archiver"
  #
  # http://www.baidu.com/search/spider.htm
  # [:baidu] => "baiduspider"
  #
  # http://help.naver.com/customer_webtxt_01.jsp (not in english)
  # [:naver] => "naverbot"
  # [:yeti] => "yeti"
  #
  # http://www.picsearch.com/menu.cgi?item=Psbot
  # [:picsearch] => "psbot"
  #
  # [:singing_fish] => "asterias"
  #
  # http://technorati.com
  # [:technorati] => "Technoratibot"    
  KNOWN_USER_AGENTS = {
    :google => "Googlebot", 
    :google_image =>  "Googlebot-Image", 
    :google_mobile =>  "Googlebot-Mobile",
    :msn => "MSNBot", 
    :yahoo => "Slurp", 
    :yahoo_mm_crawler => "yahoo-mmcrawler",
    :yahoo_blogs => "yahoo-blogs/v3.9",
    :ask => "Teoma", 
    :cuil => "Twiceler",
    :gigablast => "Gigabot",
    :scrub_the_web =>  "Scrubby",
    :dmoz => "Robozilla",
    :nutch => "Nutch",
    :alexa =>  "ia_archiver",
    :baidu => "baiduspider",
    :naver => "naverbot",
    :yeti => "yeti",
    :picsearch => "psbot",
    :singing_fish => "asterias",
    :technorati => "Technoratibot"}
    
  ALL_USER_AGENTS = {:all => "*"}
  
  USER_AGENTS = ALL_USER_AGENTS.merge(KNOWN_USER_AGENTS)
end