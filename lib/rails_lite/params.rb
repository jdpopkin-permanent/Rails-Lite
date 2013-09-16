require 'uri'

class Params
  def initialize(req, route_params)
    # check if query is parsed or not
    @params = req.query # parse_query
  end

  def [](key)
    @params[key]
  end

  def to_s
    str = "{ "
    @params.each_key do |key|
      str << key.to_s
      str << "=>"
      str << @params[key].to_s
      str << ", "
    end

    str = str[0...-2] + " }"
    str
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    assoc_array = URI::decode_www_form(www_encoded_form)
    @params ||= {}
    assoc_array.each do |arr|
      @params[arr[0]] = @params[arr[1]]
    end
  end

  def parse_key(key)
  end
end
