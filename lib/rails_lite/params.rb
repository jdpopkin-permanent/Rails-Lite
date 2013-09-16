require 'uri'

class Params
  def initialize(req, route_params)
    # check if query is parsed or not
    @params = route_params
    parse_www_encoded_form(req.query_string) unless req.query_string.nil?
    #@params = req.query # parse_query
    body = req.body
    parse_www_encoded_form(body) unless body.nil?
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

  # Converts the raw URI input into an array of strings, then converts
  # these strings to arrays of keys and values. For example: "cat[hair] =>
  # black" becomes [[cat, hair], [black]].
  def assoc_array(www_encoded_form)
    assoc_array = URI::decode_www_form(www_encoded_form)
    new_arr = []

    assoc_array = assoc_array.each do |arr| # warning: assumes depth of only 2?
      arr.each do |a|
        new_arr << parse_key(a)
      end
    end

    new_arr
  end

  def merge_subarray_into_params(new_arr, sub_arr, i)
    j = sub_arr.length - 1
    old_hash = { sub_arr[j] => new_arr[i + 1][0] }

    while j > 1
      new_hash = {}
      new_hash[sub_arr[j - 1]] = old_hash
      old_hash = new_hash
      j -= 1
    end

    @params[sub_arr[0]] ||= {}
    @params[sub_arr[0]].merge!(old_hash) do |key, oldval, newval|
      recursive_merge(key, oldval, newval)
    end
  end

  def parse_www_encoded_form(www_encoded_form)
    new_arr = assoc_array(www_encoded_form)

    new_arr.each_with_index do |sub_arr, i|

      if sub_arr.length > 1
        merge_subarray_into_params(new_arr, sub_arr, i)

      else
        next if i % 2 == 1 # in this case sub_arr is value, not key
        # otherwise it is a key pointing to next value
        @params[sub_arr[0]] = new_arr[i + 1][0]
      end
    end
    @params
  end

  def recursive_merge(key, oldval, newval)
    return newval unless oldval.is_a?(Hash) && newval.is_a?(Hash)

    oldval.merge!(newval) { |key2, olderval, newerval | recursive_merge(key2, olderval, newerval) }
  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
