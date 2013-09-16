require 'erb'
require_relative 'params'
require_relative 'session'
require_relative 'flash'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params = {})
    @request = req
    @response = res
    @params = Params.new(req, route_params)
  end

  def session
    @session ||= Session.new(@request)
  end

  def flash
    @flash ||= Flash.new(@request)
  end

  def already_rendered?
    @already_built_response
  end

  def redirect_to(url)
    raise if @already_built_response

    session.store_session(@response)
    flash.store_flash(@response)
    @response.header["location"] = url.to_s
    @response.status = 302

    @already_built_response = true
  end

  def render_content(content, type)
    raise if @already_built_response

    session.store_session(@response)
    flash.store_flash(@response)
    @response.content_type = type
    @response.body = content
    @already_built_response = true
  end

  def render(template_name)
    controller_name = self.class.to_s.underscore

    f = File.read("views/#{controller_name}/#{template_name}.html.erb")
    controller_bind = binding
    template = ERB.new(f).result(controller_bind)
    render_content(template, "text/html")
  end

  def invoke_action(name)
    # render unless already_rendered?
    self.send(name)
    render(name) unless already_rendered?
  end
end
