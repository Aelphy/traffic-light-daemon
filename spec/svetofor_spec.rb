require "#{File.dirname(__FILE__)}/spec_helper"
require "./lib/traffic_light"

describe TrafficLight do
  before { TrafficLight::GPIOConfiguration.stub(:access_class).and_return GPIOMock }

  describe TrafficLight::GPIOConfiguration do
    describe '.pin_conf' do
      it { TrafficLight::GPIOConfiguration.pin_conf(1).should eql(pin: 1, direction: :out) }
    end
  end

  describe TrafficLight::Lights do
    describe '#all' do
      before do
        TrafficLight::Lights.any_instance.stub(:red).and_return 1
        TrafficLight::Lights.any_instance.stub(:yellow).and_return 2
        TrafficLight::Lights.any_instance.stub(:green).and_return 3
      end

      it { TrafficLight::Lights.new.all.should eql [1, 2, 3] }
    end

    describe '#extinguish' do
      subject { TrafficLight::Lights.new }
      after { subject.extinguish }

      it { subject.all.each { |light| light.should_receive(:off) } }
    end

    describe '#turn_on' do
      subject { TrafficLight::Lights.new }
      after { subject.turn_on }

      it { subject.all.each { |light| light.should_receive(:on) } }
    end
  end

  describe TrafficLight::Notifier do
    describe '#lights' do
      it { TrafficLight::Notifier.new.lights.should be_an_instance_of TrafficLight::Lights }
    end

    describe '#build' do
      subject { TrafficLight::Notifier.new }
      let(:build) { [{name: TrafficLight::Notifier::PROJECT_NAME}] }

      before { subject.stub_chain(:nodes, :locate).and_return build }

      it { subject.build.should eql build.first }
    end

    describe '#notify' do
      subject { TrafficLight::Notifier.new }

      let(:lights) { double 'Lights' }
      let(:red) { GPIOMock.new(pin: 1, direction: :out) }
      let(:yellow) { GPIOMock.new(pin: 2, direction: :out) }
      let(:green) { GPIOMock.new(pin: 1, direction: :out) }
      let(:io) do
        "<Projects>\n
          <Project name=\"sg-master\"
            category=\"\"
            activity=\"CheckingModifications\"
            lastBuildStatus=\"Success\"
            lastBuildLabel=\"7836a63fa2df7dd2a33cabb9156e2da3c2d58477\"
            lastBuildTime=\"2013-08-09T19:35:05.0000000+0600\"
            nextBuildTime=\"1970-01-01T00:00:00.000000-00:00\"
            webUrl=\"http://ci.dev.apress.ru/projects/blizko-develop\"/>\n</Projects>\n"
      end

      before do
        io.stub(:read).and_return io
        TrafficLight::Notifier.any_instance.stub(:io).and_return io
        lights.stub(:green).and_return green
        lights.stub(:yellow).and_return yellow
        lights.stub(:red).and_return red
        subject.stub(:sleep)
        subject.stub(:lights).and_return lights
        subject.lights.stub(:extinguish)
      end

      after { subject.notify }

      it { subject.lights.should_receive(:extinguish) }

      context 'when build is in processing' do
        let(:io) do
        "<Projects>\n
          <Project name=\"sg-master\"
            category=\"\"
            activity=\"Building\"
            lastBuildStatus=\"Success\"
            lastBuildLabel=\"7836a63fa2df7dd2a33cabb9156e2da3c2d58477\"
            lastBuildTime=\"2013-08-09T19:35:05.0000000+0600\"
            nextBuildTime=\"1970-01-01T00:00:00.000000-00:00\"
            webUrl=\"http://ci.dev.apress.ru/projects/blizko-develop\"/>\n</Projects>\n"
        end

        it { subject.lights.yellow.should_receive(:on) }
      end

      context 'when build is not successful' do
        let(:io) do
          "<Projects>\n
            <Project name=\"sg-master\"
              category=\"\"
              activity=\"CheckingModifications\"
              lastBuildStatus=\"Failure\"
              lastBuildLabel=\"7836a63fa2df7dd2a33cabb9156e2da3c2d58477\"
              lastBuildTime=\"2013-08-09T19:35:05.0000000+0600\"
              nextBuildTime=\"1970-01-01T00:00:00.000000-00:00\"
              webUrl=\"http://ci.dev.apress.ru/projects/blizko-develop\"/>\n</Projects>\n"
        end

        it { subject.lights.red.should_receive(:on) }
      end

      context 'when build is successful' do
        let(:io) do
          "<Projects>\n
            <Project name=\"sg-master\"
              category=\"\"
              activity=\"CheckingModifications\"
              lastBuildStatus=\"Success\"
              lastBuildLabel=\"7836a63fa2df7dd2a33cabb9156e2da3c2d58477\"
              lastBuildTime=\"2013-08-09T19:35:05.0000000+0600\"
              nextBuildTime=\"1970-01-01T00:00:00.000000-00:00\"
              webUrl=\"http://ci.dev.apress.ru/projects/blizko-develop\"/>\n</Projects>\n"
        end

        it { subject.lights.green.should_receive(:on) }
      end
    end
  end
end
