require 'json'
require 'webrick'

class Session
  def initialize(req)
    req.cookies.each do |cookie|
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
    res.cookies.each_index do |i|
      cookie = res.cookies[i]
      next unless cookie.name == "_rails_lite_app"
      res.cookies[i] = new_cookie
    end
  end
end
