# -=-=-=-=-=-=-=-=-=-=-=-=-=-
#   Velaro - The code below will be extracted back into erikhatcher's Velaro github project
# -=-=-=-=-=-=-=-=-=-=-=-=-=-

if RUBY_PLATFORM == "java"
  include Java

  # TODO: upgrade Velocity, analyze what new features it provides
  require "./lib/velocity-1.7-dep.jar"

  java_import 'org.apache.velocity.Template'
  java_import 'org.apache.velocity.VelocityContext'
  java_import 'org.apache.velocity.app.VelocityEngine'
  java_import 'java.io.StringWriter'
else
  raise "Velaro requires JRuby"
end # if java

# options:
#   :locals - go into Velocity context
#   :velocity - control VelocityEngine properties
def velaro(template_name, options={})
  # TODO: how do we, or do we, handle helper methods in Velocity templates?
  engine = VelocityEngine.new
  
  options[:velocity].each do |k,v|
    engine.setProperty(k.to_s,v.to_s)  # TODO: could v be an array?  if so, maybe #join(',') it
  end
    
  context = VelocityContext.new
  options[:locals].each do |k,v|
    context.put(k.to_s, v)
  end if options[:locals]

  template = engine.getTemplate("#{template_name}.vel")
  writer = StringWriter.new
  template.merge(context, writer)
  output = writer.getBuffer.to_s
  
  if options[:layout]
    # TODO: maybe pull out a #render method that can be reused here and just above?
    template = engine.getTemplate("#{options[:layout]}.vel")
    context.put('content', output)
    writer = StringWriter.new
    template.merge(context,writer)
    output = writer.getBuffer.to_s
  end
  
  return output
end
