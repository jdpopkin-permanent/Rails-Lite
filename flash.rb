require 'json'
require 'webrick'

class Flash
  attr_accessor :now, :later

  def initialize(req)
    req.cookies.each do |cookie|
      next unless cookie.name == "_rails_lite_app_flash"
      @flash_hash = JSON.parse(cookie.value)
    end

    @flash_hash ||= {}
  end

  def [](key)
    @flash_hash[key]
  end

  def []=(key, val)
    @flash_hash[:later][key] = val
  end

  def now(key, val)
    @flash_hash[:now][key] = val
  end

  def store_flash(res)
    @flash_hash[:now] = @flash_hash[:later]
    @flash_hash[:later] = {}
    serialized_hash = @flash_hash.to_json
    name = "_rails_lite_app_flash"

    new_cookie = WEBrick::Cookie.new(name, serialized_hash)
    req.cookies.each_index do |i|
      cookie = req.cookies[i]
      next unless cookie.name == "_rails_lite_app_flash"
      req.cookies[i] = new_cookie
    end
  end
end
