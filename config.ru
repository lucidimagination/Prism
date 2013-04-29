# for some reason the load path doesn't automatically include lib/
$LOAD_PATH << $servlet_context.getRealPath("/WEB-INF/lib")
# $LOAD_PATH << 'lib' # maybe want to have something like this so Prism can be more easily launched from a source checkout?

require 'sinatra'
set :run, false

require 'prism'

run Lucid::Prism::Main
