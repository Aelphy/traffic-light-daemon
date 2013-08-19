require 'daemons'
#require './lib/traffic_light_daemon'

Daemons.run('/home/aelphy/traffic_light_daemon/lib/traffic_light_daemon.rb', {})
# тут че то не взлетело с работой в фоне- запилить