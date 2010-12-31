# -=-=-=-=-=-=-=-=-=-=-=-=-=-
#   Velaro - The code below will be extracted back into erikhatcher's Velaro github project
# -=-=-=-=-=-=-=-=-=-=-=-=-=-

if RUBY_PLATFORM == "java"
  include Java

  require "./lib/velocity-1.6.4-dep.jar"

  java_import 'org.apache.velocity.Template'
  java_import 'org.apache.velocity.VelocityContext'
  java_import 'org.apache.velocity.app.VelocityEngine'
  java_import 'java.io.StringWriter'
else
  raise "Velaro requires JRuby"
end # if java

# TODO: consider using options with :locals => {...} as second parameter instead
def velaro(template_name, parameters)
  # TODO: handle layouts
  # TODO: how do we, or do we, handle helper methods in Velocity templates?
  engine = VelocityEngine.new
  
  # TODO: allow engine properties to be controlled per request, such as load path
  engine.setProperty(VelocityEngine::FILE_RESOURCE_LOADER_PATH, "./views")
  # TODO: create resource loaders for classpath and request params
  engine.setProperty(VelocityEngine::RESOURCE_LOADER, "file")
    
  context = VelocityContext.new
  parameters.each do |k,v|
    context.put(k, v)
  end

  template = engine.getTemplate("#{template_name}.vel")
  writer = StringWriter.new
  template.merge(context, writer)
  return writer.getBuffer.to_s
end
