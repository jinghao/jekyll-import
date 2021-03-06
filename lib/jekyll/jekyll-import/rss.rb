# Created by Kendall Buchanan (https://github.com/kendagriff) on 2011-12-22.
# Use at your own risk. The end.
#
# Usage:
#   (URL)
#   ruby -r 'jekyll/jekyll-import/rss' -e "JekyllImport::RSS.process(:source => 'http://yourdomain.com/your-favorite-feed.xml')"
#
#   (Local file)
#   ruby -r 'jekyll/jekyll-import/rss' -e "JekyllImport::RSS.process(:source => './somefile/on/your/computer.xml')"

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'fileutils'
require 'safe_yaml'

module JekyllImport
  module RSS
    def self.validate(options)
      if !options[:source]
        abort "Missing mandatory option --source."
      end
    end

    # Process the import.
    #
    # source - a URL or a local file String.
    #
    # Returns nothing.
    def self.process(options)
      validate(options)

      source = options[:source]

      content = ""
      open(source) { |s| content = s.read }
      rss = ::RSS::Parser.parse(content, false)

      raise "There doesn't appear to be any RSS items at the source (#{source}) provided." unless rss

      rss.items.each do |item|
        formatted_date = item.date.strftime('%Y-%m-%d')
        post_name = item.title.split(%r{ |!|/|:|&|-|$|,}).map do |i|
          i.downcase if i != ''
        end.compact.join('-')
        name = "#{formatted_date}-#{post_name}" 

        header = {
          'layout' => 'post',
          'title' => item.title
        }

        FileUtils.mkdir_p("_posts")

        File.open("_posts/#{name}.html", "w") do |f|
          f.puts header.to_yaml
          f.puts "---\n\n"
          f.puts item.description
        end
      end
    end
  end
end
