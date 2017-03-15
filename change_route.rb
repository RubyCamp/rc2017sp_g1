# coding: cp932
#前回＆初期位置の差
$p_x = 0
$p_y = 1
def change_route(route)
  #前と今のルート
  now_route = route[1]
  #前と今のルートの差
  if route == [0,0]
    n_x = $p_x - now_route[0]
    n_y = $p_y - now_route[1]
  end
  #現在と前回の差
  #ju_x = $p_x - n_x
  #ju_y = $p_y - n_y
  #判定
  if(n_x == -1 || n_y == 1) message = "1"
  elsif(n_x == 1|| n_y == -1) message = "2"
  else message = "0"
  end
  $次の用
  $p_x = now_route[0]
  $p_y = now_route[1]
  return message
end
