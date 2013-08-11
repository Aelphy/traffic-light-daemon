#coding: utf-8
class GPIOMock
  def initialize(params)
    @pin = params[:pin]
    @direction = params[:direction]
  end

  def on
    1
  end

  def off
    0
  end
end
