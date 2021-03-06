module Kii
  module Markup
    class Default
      def initialize(markup, helper)
        @markup, @helper = CGI.escapeHTML(markup), helper
      end
      
      def to_html
        return @html if defined?(@html)

        # Prepare page link parsing
        page_link_preprocessor = Kii::PageLinkPreprocessor.new(@markup, @helper)

        buffer = @markup.split(/(\r\n){2,}|\n{2,}/).map {|p| Paragraph.new(p).to_html }.join("\n")
        @html = with_parseable_text(buffer) {|text|
          page_link_preprocessor.parse(text)
          parse_regular_links(text)
          parse_tokens(text)
          text = @helper.auto_link(text)

          text
        }

        return @html
      end
      
      private

      # Yields all the text that is to be parsed. Returns the parsed string.
      def with_parseable_text(string)
        buffer = string.dup
        result = ''

        # This will match everything we don't want to parse, which is <nowiki>
        # tags and `code snippets`.
        while m = buffer.match(/&lt;nowiki&gt;(.*?)&lt;\/nowiki&gt;|`(.*?)`/i)
          # Everything before the match should be parsed
          result << yield(m.pre_match)

          # Adding the unparsed content to the results.
          if m[1] # nowiki
            result << m[1]
          elsif m[2] # code snippet
            result << inline_code_snippet(m[2])
          end

          # Everything after the match has not been treated yet. It will be
          # treated in the next iteration.
          buffer = m.post_match
        end

        # Everything after the last pass hasn't been parsed yet.
        result << yield(buffer)

        return result
      end

      # [http://google.com/ foo]
      def parse_regular_links(text)
        text.gsub!(/\[{1}([^ ]+) (.*?)\]{1}/) {
          %{<a href="#{$~[1]}" class="ext">#{$~[2]}</a>}
        }
      end

      def parse_tokens(text)
        text.gsub!(/'{3}([^']+)'{3}/, "<strong>\\1</strong>")
        text.gsub!(/'{2}([^']+)'{2}/, "<em>\\1</em>")
      end

      def inline_code_snippet(text)
        %{<code>#{text}</code>}
      end
      
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
end