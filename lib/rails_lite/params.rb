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

  def parse_www_encoded_form(www_encoded_form)
    # get assoc array mapping hash-keypairs to vals
    # call parse_key on each hash-keypair to get hash name, key name.
    # get val after.
    assoc_array = URI::decode_www_form(www_encoded_form)
    new_arr = []

    assoc_array = assoc_array.each do |arr| # warning: assumes depth of only 2?
      arr.each do |a|
        new_arr << parse_key(a)
      end
    end

    # danger: assumes no vars exist outside the hash?
    new_arr.each_with_index do |sub_arr, i|
      if sub_arr.length > 1
        val = sub_arr.last

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

        # next 3 lines work but not with nesting
        #@params[sub_arr[0]] ||= {}
        #curr_hash = @params[sub_arr[0]]
        #curr_hash[sub_arr[1]] = new_arr[i + 1][0]
      else
        next if i % 2 == 1 # in this case sub_arr is value not key
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
