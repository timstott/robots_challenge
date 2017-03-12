defmodule Robot do
  defstruct [:position, :bearing, :lost]

  @doc """
  Applies sequence of actions to a robot.
  """
  def actionate(actions, robot, %Simulation{grid: grid, results: results}) do
    Enum.reduce_while(actions, robot, fn(action, robot) ->
      new_robot = move(robot, action)

      new_robot_lost? = Robot.is_lost?(new_robot, grid)
      cond do
        new_robot_lost? && Robot.any_lost?(robot, results) ->
          {:cont, robot}
        new_robot_lost? ->
          {:halt, Map.put(robot, :lost, true)}
        true ->
          {:cont, new_robot}
      end
    end)
  end

  @doc """
  Returns true when the robot position is outside the grid
  """
  def is_lost?(%Robot{position: {x_robot, y_robot}}, {x_grid, y_grid}) do
    x_robot > x_grid || y_robot > y_grid
  end

  @doc """
  Retruns true when robots have been lost at the robot location
  """
  def any_lost?(%Robot{position: robot_position}, robots) do
    Enum.any?(robots, fn(%{position: was_position, lost: was_lost}) ->
      was_lost && robot_position == was_position
    end)
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
