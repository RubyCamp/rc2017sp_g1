require 'dxruby'
require_relative "map"
require_relative "player_sprite"


 #前回＆初期位置の差
  $goal_ok = 0
  $p_x = 0
  $p_y = 1
  $ju = "y"
  def change_route(route)
    #前と今のルート
    prev_route = route[0]
    now_route = route[1]
    print("now_route = #{now_route}\n")
    #前と今のルートの差
		print("route= #{route}\n")
    if now_route[0] == 4 && now_route[1] == 4
       mess = "3"
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
         mess = 0
       else
         $ju = "x"
	 if (ju_x == 1)
           mess = 1
         else 
           mess = 2
         end
       end 
    else
       if(ju_x.abs == 0 || ju_x.abs ==2)
         mess = 0
       else
         $ju = "y"
         if (ju_y == -1)
           mess = 1
         else
           mess = 2
         end
       end
    end
    print("mess = #{mess}\n")
    $次の用
    $p_x = n_x
    $p_y = n_y
    return mess
  end
  

begin
  map = Map.new(File.join(File.dirname(__FILE__), "images", "map.dat"))
  player = PlayerSprite.new(0,0)
  current = map.start

  # DXRubyでは、Window.loopの処理の最後に描画が行われるため、
  # フラグ管理して描画がスキップされないようにする。
  init = true          # 初回のフレームかどうか
  reach_goal = false   # ゴールに到達したか
  give_up = false      # ゴール到達不可能になったかどうか
  
 
  Window.loop do
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
    if init
      init = false
    else
      route = map.calc_route(current, map.goal)
			route.push([4,4])
      print ("#{route}\n")
      print ("#{change_route(route).to_i}\n")
      if route.length == 2 
         route.pop
      end
      if route.length == 1
        if current == map.goal
          reach_goal = true
        else
          give_up = true
        end
      else
        player.move_to(route[1])
        current = route[1]
      end
    end
    map.draw
    player.draw
  end
ensure
  player.close if player
end
