require 'twitter'

module TrafficLight
  class Notifier
    URL = 'http://ci.railsc.ru/XmlStatusReport.aspx'

    @@client = Twitter::REST::Client.new do |config|
      config.consumer_key        = 'IRJU5nDfDUOnHfw38wD7VShd2'
      config.consumer_secret     = 'Y3rDQS0jVdg0gqBOnxYpxPIqAouQopvDswjiV55ahAZISZF80g'
      config.access_token        = '2433155473-jLYPVqkY7x2crvyeDyhLjzxXFopdS8J0xNpoH9T'
      config.access_token_secret = 'sdDu9CS829FtXF9rRtqTMcNGlf3e00Zy3FEL6aMgwjgsI'
    end

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
      @previous_activity ||= build.activity

      if @previous_activity != 'Building' && build.activity == 'Building'
        @@client.update("Запущен билд ветки #{project_name}")
      elsif @previous_activity == 'Building' && build.activity != 'Building'
        if build.lastBuildStatus == 'Failure'
          @@client.update("Билд ветки #{project_name} не прошел")
        elsif build.lastBuildStatus == 'Success'
          @@client.update("Билд ветки #{project_name} прошел успешно")
        end
      end

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
