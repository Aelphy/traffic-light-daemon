require 'daemons'
require './lib/traffic_light'

Daemons.run_proc('TLdaemon') do
  TrafficLight::Daemon.new.start
end
