#coding: utf-8
require 'ox'
require 'open-uri'
require 'pi_piper'  if ENV['DEVICE'] == 'Raspberry'

module TrafficLight
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
end
