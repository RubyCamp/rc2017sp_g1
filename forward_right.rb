# coding: utf-8-with-signature
require 'dxruby'
require_relative 'ev3/ev3'

class Player
  LEFT_MOTOR = "C"
  RIGHT_MOTOR = "B"
  DISTANCE_SENSOR = "4"
  PORT = "COM9"
  WHEEL_SPEED = 20
  COLOR_SENSOR = "1"

  attr_reader :distance
  attr_reader :color

  def initialize
    @brick = EV3::Brick.new(EV3::Connections::Bluetooth.new(PORT))
    @brick.connect
    @busy = false
    @grabbing = false
  end

  # 前進する
  def run_forward(speed=WHEEL_SPEED)
    operate do
      @brick.step_velocity(speed, 26, 4, *wheel_motors)
      @brick.motor_ready(*wheel_motors)
    end
  end

  # バックする
  def run_backward(speed=WHEEL_SPEED)
    operate do
      @brick.reverse_polarity(*wheel_motors)
      @brick.step_velocity(speed, 260, 40, *wheel_motors)
      @brick.motor_ready(*wheel_motors)
    end
  end

  # 右に回る
  def turn_right(speed=WHEEL_SPEED)
    operate do
      @brick.reverse_polarity(RIGHT_MOTOR)
      @brick.step_velocity(speed, 130, 60, *wheel_motors)
      @brick.motor_ready(*wheel_motors)
    end
  end

  # 左に回る
  def turn_left(speed=WHEEL_SPEED)
    operate do
      @brick.reverse_polarity(LEFT_MOTOR)
      @brick.step_velocity(speed, 130, 60, *wheel_motors)
      @brick.motor_ready(*wheel_motors)
    end
  end

  #@colorがある前提
#前進して右回転
  def forward_right(speed=WHEEL_SPEED)
   update
   if @color == 6
     loop do
	update
	 break if @color != 6
        run_forward if @color == 6
    end
   end
   loop do
      update
     if @color == 1
	puts "@color=1"
     run_forward
     else break
     end
   end
#前進
    loop do
	update
	 break if @color != 6
        run_forward if @color == 6
    end
    turn_right
  end
  
    
  def get_count(motor)
    @brick.get_count(motor)
  end

  # 動きを止める
  def stop
    @brick.stop(true, *all_motors)
    @brick.run_forward(*all_motors)
  end

  # ある動作中は別の動作を受け付けないようにする
  def operate
    unless @busy
      @busy = true
      yield(@brick)
      stop
      @busy = false
    end
  end

  # センサー情報の更新
  def update
    @distance = @brick.get_sensor(DISTANCE_SENSOR, 0)
    @color = @brick.get_sensor(COLOR_SENSOR, 2)
  end

  # センサー情報の更新とキー操作受け付け
  def run
    update
    run_forward if Input.keyDown?(K_UP)
    run_backward if Input.keyDown?(K_DOWN)
    turn_left if Input.keyDown?(K_LEFT)
    turn_right if Input.keyDown?(K_RIGHT)
    forward_right if Input.keyDown?(K_W)
    stop if [K_UP, K_DOWN, K_LEFT, K_RIGHT, K_W, K_S].all?{|key| !Input.keyDown?(key) }
  end

  # 終了処理
  def close
    stop
    @brick.clear_all
    @brick.disconnect
  end

  def reset
    @brick.clear_all
    #motors = wheel_motors  if motors.empty?
    #@brick.reset(*motors)
  end

  # "～_MOTOR" という名前の定数すべての値を要素とする配列を返す
  def all_motors
    @all_motors ||= self.class.constants.grep(/_MOTOR\z/).map{|c| self.class.const_get(c) }
  end

  def wheel_motors
    [LEFT_MOTOR, RIGHT_MOTOR]
  end
end

begin
  puts "starting..."
  font = Font.new(32)
  player = Player.new
  puts "connected"

  Window.loop do
    break if Input.keyDown?(K_SPACE)
    player.run
    #Window.draw_font(100, 200, "#{player.distance.to_i}cm", font)
  end
rescue Exception => e
  p e
  e.backtrace.each{|trace| puts trace}
# 終了処理は必ず実行する
ensure
  puts "closing..."
  player.close
  puts "finished"
end
