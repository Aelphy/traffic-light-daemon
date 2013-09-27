#coding: utf-8
require 'ox'
require 'open-uri'
require ENV['DEVICE'] == 'Raspberry' ?  'pi_piper' : "#{File.dirname(__FILE__)}/gpio_mock"

class TrafficLight
  class GPIOConfiguration
    def self.pin_conf(pin_number)
      {pin: pin_number, direction: :out}
    end

    def self.access_class
      ENV['DEVICE'] == 'Raspberry' ? PiPiper::Pin : GPIOMock
    end
  end

  class Lights
    # Green light
    #
    # Returns Pin
    def green(pin_number = 22)
      @green ||= GPIOConfiguration.access_class.new(GPIOConfiguration.pin_conf(pin_number))
    end

    # Red light
    #
    # Returns Pin
    def red(pin_number = 4)
      @red ||= GPIOConfiguration.access_class.new(GPIOConfiguration.pin_conf(pin_number))
    end

    # Yellow light
    #
    # Returns Pin
    def yellow(pin_number = 17)
      @yellow ||= GPIOConfiguration.access_class.new(GPIOConfiguration.pin_conf(pin_number))
    end

    # All the lights
    #
    # Returns Array
    def all
      [red, yellow, green]
    end

    # Turn off the lights
    #
    # Returns Array
    def extinguish(without = nil)
      lightbulbs = all.select { |lightbulb| lightbulb != without }

      lightbulbs.map(&:off)
    end

    # Turn on all the lights
    #
    # Returns Array
    def turn_on
      all.map(&:on)
    end
  end

  class Notifier
    URL = 'http://ci.dev.apress.ru/XmlStatusReport.aspx'

    # Find build for project
    #
    # Returns Ox::Element
    def build
      nodes.locate('Project').select { |node| node[:name] == project_name.read }.first
    end

    def lights
      @lights ||= TrafficLight::Lights.new
    end

    # Notify TrafficLight status
    #
    # Returns Integer
    def notify
      if build.activity == 'Building'
        lights.extinguish(lights.yellow)
        sleep 0.25
        lights.yellow.on
      elsif build.lastBuildStatus == 'Failure'
        lights.extinguish(lights.red)
        sleep 0.25
        lights.red.on
      elsif build.lastBuildStatus == 'Success'
        lights.extinguish(lights.green)
        sleep 0.25
        lights.green.on
      end
    end

    # Notify about problems
    #
    # Returns Integer
    def alarm
      lights.extinguish
      sleep 0.25
      lights.yellow.on
      sleep 0.25
      lights.yellow.off
      sleep 0.25
    end

    # Notify about hollydays
    #
    # Returns Integer
    def new_year
      lights.extinguish
      sleep 0.25
      lights.green.on
      sleep 0.25
      lights.yellow.on
      sleep 0.25
      lights.red.on
      sleep 0.25
    end

    private
    # Compute IO
    #
    # Returns StringIO
    def io(url = URL)
      open(url)
    end

    # Compute nodes
    #
    # Returns Ox::Element
    def nodes
      Ox.parse io.read
    end

    # Compute Project Name
    #
    # Returns StringIO
    def project_name
      open('http://traffic-light.railsc.ru:4567/branch')
    end
  end
end
