# coding: cp932
#�O�񁕏����ʒu�̍�
$p_x = 0
$p_y = 1
def change_route(route)
  #�O�ƍ��̃��[�g
  now_route = route[1]
  #�O�ƍ��̃��[�g�̍�
  if route == [0,0]
    n_x = $p_x - now_route[0]
    n_y = $p_y - now_route[1]
  end
  #���݂ƑO��̍�
  #ju_x = $p_x - n_x
  #ju_y = $p_y - n_y
  #����
  if(n_x == -1 || n_y == 1) message = "1"
  elsif(n_x == 1|| n_y == -1) message = "2"
  else message = "0"
  end
  $���̗p
  $p_x = now_route[0]
  $p_y = now_route[1]
  return message
end
