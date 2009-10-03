module Kii
  class Markup
    class Paragraph
      LIST_TYPES = {"*" => "ul", "#" => "ol"}
      def initialize(paragraph)
        @p = paragraph
        @p.strip!
      end
      
      def to_html
        case @p
        when /^=/
          level = (@p.count("=") / 2) + 1 # Starting on h2
          @p.gsub!(/^[= ]+|[= ]+$/, "")
          "<h#{level}>" + @p + "</h#{level}>"
        when /^(\*|\#)/
          list_type = LIST_TYPES[$1]
          list_output = []
          previous_nesting_level = 0
          
          @p.scan(/(#{Regexp.escape($1)}+) ?([^#{Regexp.escape($1)}]+)/) {|m|
            nesting_level = $~[1].length
            contents = $~[2]
            contents.strip!
            
            if nesting_level > previous_nesting_level
              list_output << "<#{list_type}><li>#{contents}"
            end
            if nesting_level < previous_nesting_level
              (previous_nesting_level - nesting_level).times { list_output << "</li></#{list_type}>" }
              list_output << "</li><li>#{contents}"
            end
            if nesting_level == previous_nesting_level
              list_output << "</li><li>#{contents}"
            end
            previous_nesting_level = nesting_level
          }
          
          tail = Array.new(previous_nesting_level).map { "</li></#{list_type}>" }
          
          list_output.join + tail.join
        else
          @p.gsub!("\n", "\n<br/>")
          "<p>" + @p + "</p>"
        end
      end
    end
  end
end