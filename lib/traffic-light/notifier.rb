module TrafficLight
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
