defmodule Orde28 do
  use ExDoukaku.TestRunner

  defstruct [:N, :E, :W, :S]

  def split(input) do
    [building_str, room] =
      input |> String.split("/")

    extensions =
      Regex.scan(~r{[NEWS]|\d+}, building_str)
      |> List.flatten()
      |> Enum.chunk_every(2)
      |> Enum.map(fn [dir, size] ->
        {String.to_existing_atom(dir), String.to_integer(size)}
      end)
    {extensions, String.to_integer(room)}
  end

  def solve(input) do
    {extensions, room_number} =
      input
      |> split()

    initial_env = %{
      rooms: [
        {0, 0, 1, 1}
      ]
    }

    result =
      extensions
      |> Enum.reduce(initial_env, fn {dir, count}, env ->

        extended_rooms =
          env.rooms
          |> Enum.map(fn {x1, y1, x2, y2} ->
            {x1 * count, y1 * count, x2 * count, y2 * count}
          end)

        {min_x, min_y, max_x, max_y} =
          extended_rooms
          |> Enum.reduce(fn {x1, y1, x2, y2}, {b_x1, b_y1, b_x2, b_y2} ->
            {min(x1, b_x1), min(y1, b_y1), max(x2, b_x2), max(y2, b_y2)}
          end)

        width = max_x - min_x
        height = max_y - min_y
        room_size =
          case dir do
            :N -> div(width, count)
            :S -> div(width, count)
            :E -> div(height, count)
            :W -> div(height, count)
          end

        rooms =
          1..count
          |> Enum.reduce(extended_rooms, fn i, rooms ->
            {x, y} =
              case dir do
                :N -> {min_x + (i - 1) * room_size, min_y - room_size}
                :S -> {min_x + (i - 1) * room_size, max_y}
                :E -> {max_x,                       min_y + (i - 1) * room_size}
                :W -> {min_x - room_size,           min_y + (i - 1) * room_size}
              end
            [{x, y, x + room_size, y + room_size} | rooms]
          end)

        %{
          rooms: rooms
        }
      end)

    rooms =
      result.rooms
      |> Enum.reverse()
      |> Enum.with_index(1)

    {{room_x1, room_y1, room_x2, room_y2}, _} = rooms |> Enum.find(& elem(&1, 1) == room_number)

    neighbors =
      rooms
      |> Enum.filter(fn
        {{^room_x2, y1, _, y2}, _} when room_y1 < y2 and y1 < room_y2 -> true
        {{x1, ^room_y2, x2, _}, _} when room_x1 < x2 and x1 < room_x2 -> true
        {{_, y1, ^room_x1, y2}, _} when room_y1 < y2 and y1 < room_y2 -> true
        {{x1, _, x2, ^room_y1}, _} when room_x1 < x2 and x1 < room_x2 -> true
        _ -> false
      end)

    neighbors
    |> Enum.map(&elem(&1, 1))
    |> Enum.join(",")
  end

  c_styled_test_data """
    /*0*/ test( "N7N4E5/8", "1,7,12,13,14" );
    /*1*/ test( "E1/1", "2" );
    /*2*/ test( "N6/5", "1,4,6" );
    /*3*/ test( "W5/3", "1,2,4" );
    /*4*/ test( "S1N2/1", "2,3,4" );
    /*5*/ test( "E7E6/11", "4,5,10,12" );
    /*6*/ test( "W7W3/10", "4,5,6,9,11" );
    /*7*/ test( "N1E4N1/5", "1,4,6" );
    /*8*/ test( "N4E5S8/8", "1,7,9" );
    /*9*/ test( "S7E3N6/9", "1,10,16,17" );
    /*10*/ test( "N9E7S9/25", "1,17,24,26" );
    /*11*/ test( "E1N2W2S3/1", "2,3,6,8" );
    /*12*/ test( "E2N3W3S4/1", "2,3,4,5,8,9,11,12" );
    /*13*/ test( "E4E8S8N8/7", "2,6,8" );
    /*14*/ test( "W6W7W7E8/15", "8,16" );
    /*15*/ test( "E2N9E7S5E7/3", "1,2,17,18,19,23,24" );
    /*16*/ test( "E2N9E7S5E7/16", "2,15,17,27,28" );
    /*17*/ test( "E8S7E2N2N9/20", "1,2,17,19,25,26,27,28,29" );
    /*18*/ test( "N9S9N8W4W5/18", "1,17,19" );
    /*19*/ test( "S3E9N8N6S5/25", "18,19,24,26" );
    /*20*/ test( "S4N9W6S2N8/15", "1,6,16,23,24" );
    /*21*/ test( "W5E3N4S7N7S6/7", "1,8,13" );
    /*22*/ test( "N7S3N4W3N9W9/16", "1,2,12,17,19,20,21,22,28,29,30,31" );
    /*23*/ test( "S9W8S7E2E4N9/26", "1,27,28,29,36,37,38,39" );
    /*24*/ test( "W6W2S9E4N9E6/19", "1,20,30,31,32,33,34" );
    /*25*/ test( "W7W1W2W6W7S6N9/9", "2,3,4,5,6,7,8,10,11,26,27,28,33,34,35,36" );
    /*26*/ test( "E2E3E4E5E6E7N7/33", "2,4,7,32,34" );
    /*27*/ test( "N8E3W8N8S8S9N5/33", "1,32,34,41,42" );
    /*28*/ test( "S4S6W4N3E6N8S7/16", "1,12,17,25,26,27" );
    /*29*/ test( "W5N4E3S1N3S8W9/14", "1,6,13,18,19,20,21,22,23,24,25,30,31,32,33,34" );
    /*30*/ test( "N1E1N1E1N1E1N1E1/7", "5,6,8,9" );
    /*31*/ test( "N1E1W1S1N1E1W1S1/5", "1,3,4,7,8,9" );
    /*32*/ test( "N2E2W2S2N2E2W2S2/9", "1,5,8,13,17" );
    /*33*/ test( "E2S4S1W5N5E8E9W6/36", "9,14,37" );
    /*34*/ test( "E4S8E5S6E4W9N3W8/33", "1,32,34,45,46" );
    /*35*/ test( "E6W7E7W4N9N3E6N9/22", "8,9,23,26,27" );
    /*36*/ test( "E9E7E3S8S3S6W3S6N9/50", "1,49,51" );
    /*37*/ test( "N6N6E3W8W5W1W3N9S7/30", "25,26,27,28,29,31,32,33,35,36,37,38,43,44,45,46" );
    /*38*/ test( "S9N2E4N5E6S5S6W8W9/47", "39,48" );
    /*39*/ test( "N9E7E7E6W8N6N4E1S1E8/34", "1,33,35" );
    /*40*/ test( "W6S8E9S5W5S8E5E1N3N8/50", "1,16,43,48,49,51,54,55,56,57" );
    /*41*/ test( "W6W9E5E6S5S8N7W2N6N9/31", "1,21,30,32,37,38,39" );
    /*42*/ test( "N6S5N7W7S7W4N6W5S9W3S5/42", "16,17,18,41,43" );
    /*43*/ test( "S9W5N2W9W4E3N8W7N3W7W8/49", "34,35,36,42,50,52,53,54" );
    /*44*/ test( "W5N9E7E4W9E7W6E4S7S2E7/32", "4,5,31,33,46" );
    /*45*/ test( "E4W7E4S7E8W9N1E9W1N2W8S5/51", "32,33,34,35,36,37,38,39,40,41,52,53,57,58,59,60,61,62,63,64,65" );
    /*46*/ test( "N7E6E4S5S6N7N8E2S6N9N5W5/26", "20,21,25,27,48" );
    /*47*/ test( "N9N5N8E7N7N3N8S7N5W5S7E6/51", "1,50,52,69,70" );
    /*48*/ test( "N9N5N8E7N7N3N8S7N5W5S7E6/75", "24,25,26,37,74,76" );
    /*49*/ test( "N1E1N6W3W6N4N7W2S5N5E1E9S8/55", "36,42,54,56" );
    /*50*/ test( "S9E8E7N5S7S9E6N9W9W5E3N8E9/77", "48,49,50,76,78,90,91,92,93" );
    /*51*/ test( "S9E8E7N5S7S9E6N9W9W5E3N8E9/92", "77,91,93" );
    /*52*/ test( "W5N7W4E5E8S9E5E7S7N8E8N9E8/29", "21,22,28,30,43" );
    /*53*/ test( "W5N7W4E5E8S9E5E7S7N8E8N9E8/67", "66,68,83,85" );
    /*54*/ test( "S7E9W7W5S8S3W4E7W4S9N4N8E8E7/60", "38,39,59,61" );
    /*55*/ test( "W6E8E8W8W6N8N9S9W4S9S8N9S2E6/83", "74,75,82,84,95" );
    /*56*/ test( "E7W4E4S4N4E6W3E7W4W7E5W8E4N5W7/22", "1,21,23,71" );
    /*57*/ test( "W8S9N8S8N3W5E5N9E3N8S6W2S8E9E5/56", "43,55,57,65" );
    /*58*/ test( "N8E3N7W3S7S6E9S8N5S7W8E2N9E6N7E7/99", "84,85,98,100" );
    /*59*/ test( "W3W6S8W9E8N9W6E6N1S4E6S7S7W8S5N8/96", "57,82,95,97" );
    /*60*/ test( "E6E7N6E9W8E6W7E8W8E5W7W9S6E9S7N5S6/52", "38,39,51,53,67,68" );
    /*61*/ test( "N7N6S2W8S8W5N9S7N6S6W9E3E8W5N4W6N4/95", "91,96,101" );
    /*62*/ test( "E6W4E4N9S6S8E6E3W5W4E9E6W9S5N7N9E4S4/23", "2,12,22,24,90" );
    /*63*/ test( "W2N4W7E4E1W5W8E6S4E2N2N7E3W8E1E6W9N3/51", "46,50,52,81,82" );
    /*64*/ test( "S8E9W9E7E8W8E8W4W6W6W9W8E5W9S3S8S4E9/100", "86,87,99,101" );
    /*65*/ test( "W9W5N7E6W8W6W9S1E8S9W6S8S7N9W6S8E3S8/120", "110,111,119,121" );
    /*66*/ test( "S1W1N4S8S1S3W3W4E7N7N4S4N1S9N6S6S5E1W8/49", "41,42,43,44,59,60,61,62,63,64,76,77,78,79" );
    /*67*/ test( "S4W4E6N3N6W9N3N5S9N7S8N4W4E7W6S8W2E8S3/78", "10,11,12,18,77,79,101,102" );
    /*68*/ test( "S4W4E6N3N6W9N3N5S9N7S8N4W4E7W6S8W2E8S3/87", "86,88,96,105,106" );
    /*69*/ test( "W9W5N7E6W8W6W9S1E8S9W6S8S7N9W6S8E3S8E9/120", "110,111,119,121" );
    /*70*/ test( "E6E2W4W3E2W8E6W5E8S4S6E1W2N5W4S9N9S2S9E8/87", "72,73,74,75,76,86,92,93,94,95,96,101,102,103,104" );
    /*71*/ test( "N4W7S3S4W7S5N4N4N9S9E6N7S6S8N9W9N8E9E7S6/74", "55,56,57,73,75,81,82" );
    /*72*/ test( "N5S4S1W2W1W2W5W6N7W3W8E1S9W9N1W8W1S2W2W6/78", "74,75,77,82,83,84" );
    /*73*/ test( "N9S9S3S6N6S7N8W4E9W7E3N5W8S9E9E9W6N3N9N7/87", "53,69,86,88" );
    /*74*/ test( "N5E5S5W5N6E6S6W6N7E7S7W7N8E8S8W8N9E9S9W9/105", "73,90,104,124,140,141" );
    /*75*/ test( "N9S9S3S6N6S7N8W4E9W7E3N5W8S9E9E9W6N3N9W8/119", "73,74,78,113,120,122,123,124,131,132,133,134" );
    """
end
