defmodule Robots do
  @moduledoc """
  Documentation for Robots.
  """

  def run(world) do
    world = Map.put(world, :results, [])
    Enum.reduce(world.missions, world, fn(mission, world) ->
      {world, robot} = Enum.reduce(mission.actions, {world, mission.robot}, fn(step, {world, robot}) ->
        {world, move(robot, step)}
      end)
      %{world | results: (world.results ++ [robot])}
    end).results
  end

  def move(robot, movement) when movement == :L or movement == :R do
    bearings = [:W, :N, :E, :S]
    index = Enum.find_index(bearings, fn(x) -> x == robot.bearing end)
    offset = if (movement == :L), do: -1, else: 1
    bearing = Enum.at(bearings, rem(index+offset+4, 4))

    %{robot | bearing: bearing}
  end

  def move(robot, :F) do
    bearings_to_positions = %{
      :W => {-1, 0},
      :N => {0, 1},
      :E => {1, 0},
      :S => {0, -1}
    }
    {robot_x, robot_y} = robot.position
    {move_x, move_y} = Map.get(bearings_to_positions, robot.bearing)
    new_position = {robot_x + move_x, robot_y + move_y}

    %{robot | position: new_position}
  end
end
