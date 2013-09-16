require 'erb'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params
  # rescue_from WEBrick::HTTPStatus::Redirect, with: send_to

  def initialize(req, res, route_params = {})
    @request = req
    @response = res
  end

  def session
  end

  def already_rendered?
    @already_built_response
  end

  def redirect_to(url)
    #@response.set_redirect(302, url)
    #rescue Exception #WEBrick::HTTPStatus::Redirect # do this elsewhere

    # @response.body = "<HTML><A HREF=\"#{url.to_s}\">#{url.to_s}</A>.</HTML>\n"
    @response.header["location"] = url.to_s
    @response.status = 302

    @already_built_response = true
  end

  def render_content(content, type)
    raise if @already_built_response
    @response.content_type = type
    @response.body = content
    @already_built_response = true
  end

  def render(template_name)
    f = File.read("views/my_controller/#{template_name}.html.erb") # don't hard code this ew
    #last_line = "\n<% binding %>" # what.
    #f << last_line
    #template = ERB.new(f)
    controller_bind = binding
    template = ERB.new(f).result(controller_bind)
    render_content(template, "text/html")
  end

  def invoke_action(name)
  end
end
