#!/usr/bin/env ruby
# little_web.rb - Script for runing a web server for testing purposes
#
require 'webrick'
require 'erb'
require 'ostruct'
include ERB::Util

HELLO_TEMPLATE = <<'HTML'
<html>
  <head>
    <title>Test web page</title>
  </head>
  <body>
    <h1>Hello <%=html_escape(name)%>!</h1>
    <p>This is a test web page!</p>
    <form method="GET">
      <label for="name">Enter your name:</label>
      <input type="text" name="name" id="name">
      <input type="submit" value="Send">
    </form>
  </body>
</html>
HTML

if $0 == __FILE__
  dir = $0[/^(.*?)(.rb)?$/, 1]
  File.directory?(dir) or 
    raise ArgumentError, 'Cannot find directory to serve files from'
  port = 8080

  puts "serving files from #{dir}"
  puts "URL: http://#{Socket.gethostname}:#{port}"

  s = WEBrick::HTTPServer.new(
    :Port            => port,
    :DocumentRoot    => dir
  )
  template = ERB.new(HELLO_TEMPLATE).def_class(OpenStruct, 'render()').instance_exec do
    def render(h)
      r = new(h)
      yield(r) if block_given?
      r.render()
    end
    private_class_method :new
    self
  end
  s.mount_proc('/') do |request, response|
    response.status = 200
    response['Content-Type'] = 'text/html'
    response.body = template.render(request.query()) do |t|
      t.name ||= 'there'
    end
  end

  trap("INT") { s.shutdown }
  s.start
end

