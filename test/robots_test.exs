defmodule RobotsTest do
  use ExUnit.Case
  doctest Robots

  describe "Robots.run/1" do
    test "all robots termninate inside the world" do
      world = %{
        size: {5, 3},
        missions: [
          %{robot: %{position: {1, 1}, bearing: :E}, actions: [:R, :F, :R, :F, :R, :F, :R, :F]}
        ]
      }

      output = [
        %{position: {1, 1}, bearing: :E}
      ]

      assert Robots.run(world) == output
    end
  end

  describe "Robots.move/2" do
    test "robot moves bearing" do
      robot = %{position: {0, 0}, bearing: :N}
      assert Robots.move(robot, :L) == %{robot | bearing: :W}
      assert Robots.move(robot, :R) == %{robot | bearing: :E}

      robot = %{robot | bearing: :W}
      assert Robots.move(robot, :L) == %{robot | bearing: :S}
      assert Robots.move(robot, :R) == %{robot | bearing: :N}

      robot = %{robot | bearing: :E}
      assert Robots.move(robot, :L) == %{robot | bearing: :N}
      assert Robots.move(robot, :R) == %{robot | bearing: :S}

      robot = %{robot | bearing: :S}
      assert Robots.move(robot, :L) == %{robot | bearing: :E}
      assert Robots.move(robot, :R) == %{robot | bearing: :W}
    end

    test "robot moves position" do
      robot = %{position: {5, 5}, bearing: :N}
      assert Robots.move(robot, :F) == %{robot | position: {5, 6}}

      robot = %{robot | bearing: :W}
      assert Robots.move(robot, :F) == %{robot | position: {4, 5}}

      robot = %{robot | bearing: :E}
      assert Robots.move(robot, :F) == %{robot | position: {6, 5}}

      robot = %{robot | bearing: :S}
      assert Robots.move(robot, :F) == %{robot | position: {5, 4}}
    end

    test "robot moves bearing and position" do
      robot = %{position: {0, 0}, bearing: :E}
      new_robot = robot
                  |> Robots.move(:F)
                  |> Robots.move(:L)
                  |> Robots.move(:F)
                  |> Robots.move(:L)

      assert new_robot == %{position: {1, 1}, bearing: :W}
    end
  end
end
