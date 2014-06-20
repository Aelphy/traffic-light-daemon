require 'open-uri'

module TrafficLight
  class Daemon
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
      @notifigher ||= Notifier.new
    end
  end
end
