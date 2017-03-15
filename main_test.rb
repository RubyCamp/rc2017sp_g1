require 'dxruby'
require_relative "map"
require_relative "player"
require_relative "communicator"

include Communicator

#前回＆初期位置の差
$p_x = 0
$p_y = 0
$ju = "y"

#player = Player.new("COM4")

def change_route(route)

  #前と今のルート
  prev_route = route[0]
  now_route = route[1]
  print("now_route = #{now_route}\n")

  #前と今のルートの差
  print("route= #{route}\n")
  if now_route[0] == 4 && now_route[1] == 4
    mess = "D"
    return mess
  end
  if(route[0,0] == 0 && route[0,1] == 0)
    n_x = $p_x - now_route[0]
    n_y = $p_y - now_route[1]
  else
    n_x = prev_route[0] - now_route[0]
    n_y = prev_route[1] - now_route[1]
  end

  #現在と前回の差
  ju_x = $p_x - n_x
  ju_y = $p_y - n_y
  print("ju_x=#{ju_x},ju_y=#{ju_y}\n")
  if($ju == "y")
    if(ju_y.abs == 0 || ju_y.abs == 2 )
      mess = "A"
    else
      $ju = "x"
      if (ju_x == 1)
        mess = "B"
      else 
        mess = "C"
      end
    end 
  else
    if(ju_x.abs == 0 || ju_x.abs ==2)
      mess = "A"
    else
      $ju = "y"
      if (ju_y == -1)
        mess = "B"
      else
        mess = "C"
      end
    end
  end
  print("mess = #{mess}\n")
 # $次の用

  $p_x = n_x
  $p_y = n_y
  return mess
end

begin
  map = Map.new(File.join(File.dirname(__FILE__), "images", "map.dat"))
  
  current = map.start

  # DXRubyでは、Window.loopの処理の最後に描画が行われるため、
  # フラグ管理して描画がスキップされないようにする。
  reach_goal = false   # ゴールに到達したか
  give_up = false      # ゴール到達不可能になったかどうか
  route = map.calc_route(current, map.goal)
  route.push([4,4])
  $p = route[1]
  $p_x = $p[0]
  $p_y = $p[1]
  route.shift
  loop do
    break if Input.key_down? K_E
    if reach_goal
      puts "goal!"
      sleep 2
      break
    end
    if give_up
      puts "give up!"
      sleep 2
      break
    end
      #print ("#{route}\n")
     # @message = change_route(route)
      

    #送信
    #追加
    puts "send_start"

    threads = []
    @sender = Communicator::Sender.new
    #receiver = Communicator::Receiver.new(brick)
      
    #追加
    threads << Thread.start doh
    　@message = change_route(route)
　　　route.shift
　　　puts "send: #{@message}"
　　　@sender.send(@message)
    end
    threads.each{|t| t.join}
    #送信終了


    #@messageによって移動
    print("message = #{@message}\n")
    player = Player.new
    if @message == "A"
      player.forward
      puts"forward"
    elsif @message == "B"
      player.left_forward
      puts"left_forward"
    elsif @message == "C"
      player.right_forward
      puts"right_forward"
    elsif @message == "D"
      player.goal_stop
      puts"goal.stop"
    end

      #goalにたどり着いたか
    if route.length == 1
      if current == map.goal
        reach_goal = true
      else
        give_up = true
      end
    end
  end
#ensure
 # @sender.disconnect
  #player.close if player  
end
