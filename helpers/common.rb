class Hash
  def slice(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
  end
end

class Array
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end

class Numeric
  def scale_between(from_min, from_max, to_min, to_max)
    ((to_max - to_min) * (self - from_min)) / (from_max - from_min) + to_min
  end
end

class Template < Sinatra::Base
  helpers do
    def partial(template, *args)
      options = args.extract_options!
      options.merge!(:layout => false)
      if collection = options.delete(:collection) then
        collection.inject([]) do |buffer, member|
          buffer << erb(template, options.merge(
                                    :layout => false,
                                    :locals => {template.to_sym => member}
                                )
          )
        end.join("\n")
      else
        erb(template, options)
      end
    end

    def options_from_collection(collection, selected)
      collection.collect do |element|
        option_attr = []
        option_attr << "value=\"#{element}\""
        option_attr << 'selected' if selected.to_s == element.to_s
        '<option ' + option_attr.join(' ') + '>' + (block_given? ? yield(element).to_s : element.to_s) + '</option>'
      end.join("\n")
    end

    def h(text)
      Rack::Utils.escape_html(text)
    end

    def j(javascript)
      js_escape_map = {
          '\\'   => '\\\\',
          '</'   => '<\/',
          "\r\n" => '\n',
          "\n"   => '\n',
          "\r"   => '\n',
          '"'    => '\\"',
          "'"    => "\\'"
      }
      if javascript
        javascript.gsub(/(\\|<\/|\r\n|\342\200\250|[\n\r"'])/u) { |match| js_escape_map[match] }
      else
        ''
      end
    end
  end
end
