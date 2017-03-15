# coding: cp932
require_relative 'ev3/ev3'

class Player
  LEFT_MOTOR = "C"
  RIGHT_MOTOR = "B"
  DISTANCE_SENSOR = "4"
  WHEEL_SPEED = 20
  COLOR_SENSOR = "1"
  
  attr_reader :distance
  attr_reader :color
  
  def initialize(port)
    @brick = EV3::Brick.new(EV3::Connections::Bluetooth.new(port))
    @brick.connect
    @busy = false
    @grabbing = false
  end

  # �O�i����
  def run_forward(speed=WHEEL_SPEED)
    operate do
      @brick.step_velocity(speed, 260, 40, *wheel_motors)
      @brick.motor_ready(*wheel_motors)
    end
  end

  # �o�b�N����
  def run_backward(speed=WHEEL_SPEED)
    operate do
      @brick.reverse_polarity(*wheel_motors)
      @brick.step_velocity(speed, 260, 40, *wheel_motors)
      @brick.motor_ready(*wheel_motors)
    end
  end

  # �E�ɉ��
  def turn_right(speed=WHEEL_SPEED)
    operate do
      @brick.reverse_polarity(RIGHT_MOTOR)
      @brick.step_velocity(speed, 130, 60, *wheel_motors)
      @brick.motor_ready(*wheel_motors)
    end
  end

  # ���ɉ��
  def turn_left(speed=WHEEL_SPEED)
    operate do
      @brick.reverse_polarity(LEFT_MOTOR)
      @brick.step_velocity(speed, 130, 60, *wheel_motors)
      @brick.motor_ready(*wheel_motors)
    end
  end

  def get_count(motor)
    @brick.get_count(motor)
  end

  # �������~�߂�
  def stop
    @brick.stop(true, *all_motors)
    @brick.run_forward(*all_motors)
  end

  # ���铮�쒆�͕ʂ̓�����󂯕t���Ȃ��悤�ɂ���
  def operate
    unless @busy
      @busy = true
      yield(@brick)
      stop
      @busy = false
    end
  end

  # �Z���T�[���̍X�V
  def update
    @distance = @brick.get_sensor(DISTANCE_SENSOR, 0)
    @color = @brick.get_sensor(COLOR_SENSOR, 2)
  end

  # �Z���T�[���̍X�V�ƃL�[����󂯕t��
  def run
    update
    run_forward if @color == 6 
    turn_right if Input.keyDown?(K_RIGHT)
    if @color == 1
      #���M����
      loop do
        break if #���߂�����...����...break

      end
      
      
    end

  # �I������
  def close
    stop
    reset
    @brick.disconnect
  end

  def reset
    @brick.clear_all
  end

  # "MOTOR" �Ƃ������O�̒萔���ׂĂ̒l��v�f�Ƃ���z���Ԃ�
  def all_motors
    @all_motors ||= self.class.constants.grep(/_MOTOR\z/).map{|c| self.class.const_get(c) }
  end

  def wheel_motors
    [LEFT_MOTOR, RIGHT_MOTOR]
  end
end
