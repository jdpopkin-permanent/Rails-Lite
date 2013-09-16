require 'json'
require 'webrick'

class Session
  def initialize(req)
    req.cookies.each do |cookie|
      # parsed_cookie = JSON.parse(cookie)
      next unless cookie.name == "_rails_lite_app"
      @cookie_hash = JSON.parse(cookie.value)
    end

    @cookie_hash ||= {}
  end

  def [](key)
    @cookie_hash[key]
  end

  def []=(key, val)
    @cookie_hash[key] = val
  end

  def store_session(res)
    serialized_hash = @cookie_hash.to_json
    name = "_rails_lite_app"

    new_cookie = WEBrick::Cookie.new(name, serialized_hash)
    res.cookies << new_cookie # note: doesn't overwrite matching cookie
  end
end
