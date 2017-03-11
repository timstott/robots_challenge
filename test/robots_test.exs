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

    test "one robot is lost" do
      world = %{
        size: {5, 3},
        missions: [
          %{robot: %{position: {3, 2}, bearing: :N}, actions: [:F, :R, :R, :F, :L, :L, :F, :F, :R, :R,:F, :L, :L]}
        ]
      }

      output = [
        %{position: {3, 3}, bearing: :N, lost: true}
      ]

      assert Robots.run(world) == output
    end

    test "one robot saved by lost robot" do
      world = %{
        size: {5, 3},
        missions: [
          %{robot: %{position: {3, 2}, bearing: :N}, actions: [:F, :R, :R, :F, :L, :L, :F, :F, :R, :R,:F, :L, :L]},
          %{robot: %{position: {0, 3}, bearing: :W}, actions: [:L, :L, :F, :F, :F, :L, :F, :L, :F, :L]}
        ]
      }

      output = [
        %{position: {3, 3}, bearing: :N, lost: true},
        %{position: {2, 3}, bearing: :S}
      ]

      assert Robots.run(world) == output
    end
  end

  describe "Robots.actionate/2" do
    test "robot moves inside the world" do
      world = %{size: {1, 1}, results: []}

      actions = [:F]
      robot = %{position: {0, 0}, bearing: :N}

      new_robot = %{robot | position: {0, 1}}
      assert Robots.actionate(actions, robot, world) == new_robot
    end

    test "when the robot is lost actions terminate early" do
      world = %{size: {1, 1}, results: []}

      actions = [:F, :F, :R, :F]
      robot = %{position: {0, 0}, bearing: :N}

      new_robot = %{position: {0, 1}, bearing: :N, lost: true}
      assert Robots.actionate(actions, robot, world) == new_robot
    end

    test "one lost robot and onve save by lost robot" do
      lost_robot = %{position: {0, 1}, bearing: :N, lost: true}
      world = %{size: {1, 1}, results: [lost_robot]}

      actions = [:F, :F, :R, :R, :F]
      robot = %{position: {0, 0}, bearing: :N}

      new_robot = %{position: {0, 0}, bearing: :S}
      assert Robots.actionate(actions, robot, world) == new_robot
    end
  end

  describe "Robots.lost?/2" do
    test "is true when position is outside the grid" do
      position = {0, 2}
      assert Robots.lost?(position, {1,1}) == true
    end
    test "is false when position is inside the grid" do
      position = {0, 0}
      assert Robots.lost?(position, {1,1}) == false
    end
  end

  describe "Robots.any_lost?/2" do
    test "is false when no robots were lost at this coordinate" do
      robots = [
        %{position: {0, 0}, lost: true}
      ]
      robot = %{position: {0, 5}}
      assert Robots.any_lost?(robot, robots) == false
    end
    test "is true when one robot was lost at this coordinate" do
      robots = [
        %{position: {0, 5}, lost: true}
      ]
      robot = %{position: {0, 5}}
      assert Robots.any_lost?(robot, robots) == true
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
