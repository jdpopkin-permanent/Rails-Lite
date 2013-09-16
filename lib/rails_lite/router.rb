class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    return false unless pattern =~ req.path
    return false unless http_method == req.request_method.downcase.to_sym
    true # is that it?
  end

  def run(req, res)
    route_params = {pattern: pattern, http_method: http_method } # do we need controller_class or action_name ?
    url = req.unparsed_uri
    route_params = pattern.match(url)
    # make hash

    controller = controller_class.new(req, res, route_params)
    controller.invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name) # old def?
  #def add_route(route)
    [:get, :post, :put, :delete].each do |http_method|
      self.send(http_method, pattern, controller_class, action_name)
    end
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    # add these helpers in a loop here
    define_method(http_method) do |pattern, controller_class, action_name|
      routes << (Route.new(pattern, http_method, controller_class, action_name))
    end
  end

  def match(req)
    @routes.each do |route|
      return route if route.matches?(req)
    end
    nil
  end

  def run(req, res)
    route = match(req)
    if route.nil?
      res.status = 404
      return
    end

    route.run(req, res)
  end
end
