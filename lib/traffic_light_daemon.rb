#coding: utf-8
require 'open-uri'
require File.join(File.dirname(__FILE__), 'traffic_light')

class TrafficLightDaemon
  def start
    loop do
      begin
        case mode
        when 'Новый Год' then
          notifigher.new_year
        else
          notifigher.notify
          sleep 5
        end
      rescue
        notifigher.alarm
      end
    end
  end

  def io
    open('http://traffic-light.railsc.ru:4567/mode')
  end

  def mode
    io.read
  end

  def notifigher
    @notifigher ||= TrafficLight::Notifier.new
  end
end

TrafficLightDaemon.new.start
