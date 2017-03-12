defmodule RobotTest do
  use ExUnit.Case
  doctest Robot

  describe "is_lost?/2" do
    test "is true when position is outside the grid" do
      robot = %Robot{position: {0, 10}, bearing: :N}
      assert Robot.is_lost?(robot, {1,1}) == true
    end
    test "is false when position is inside the grid" do
      robot = %Robot{position: {0, 0}, bearing: :N}
      assert Robot.is_lost?(robot, {1,1}) == false
    end
  end

  describe "any_lost?/2" do
    test "is false when no robots were lost at this coordinate" do
      robots = [
        %{position: {0, 0}, bearing: :N, lost: true}
      ]
      robot = %Robot{position: {0, 5}, bearing: :N}
      assert Robot.any_lost?(robot, robots) == false
    end
    test "is true when one robot was lost at this coordinate" do
      robots = [
        %{position: {0, 5}, bearing: :N, lost: true}
      ]
      robot = %Robot{position: {0, 5}, bearing: :N}
      assert Robot.any_lost?(robot, robots) == true
    end
  end

  describe "actionate/2" do
    test "robot moves inside the simulation" do
      simulation = %Simulation{grid: {1, 1}, results: []}

      actions = [:F]
      robot = %Robot{position: {0, 0}, bearing: :N}

      new_robot = %Robot{robot | position: {0, 1}}
      assert Robot.actionate(actions, robot, simulation) == new_robot
    end

    test "when the robot is lost actions terminate early" do
      simulation = %Simulation{grid: {1, 1}, results: []}

      actions = [:F, :F, :R, :F]
      robot = %Robot{position: {0, 0}, bearing: :N}

      new_robot = %Robot{position: {0, 1}, bearing: :N, lost: true}
      assert Robot.actionate(actions, robot, simulation) == new_robot
    end

    test "one lost robot and onve save by lost robot" do
      lost_robot = %Robot{position: {0, 1}, bearing: :N, lost: true}
      simulation = %Simulation{grid: {1, 1}, results: [lost_robot]}

      actions = [:F, :F, :R, :R, :F]
      robot = %Robot{position: {0, 0}, bearing: :N}

      new_robot = %Robot{position: {0, 0}, bearing: :S}
      assert Robot.actionate(actions, robot, simulation) == new_robot
    end
  end

  describe "move/2" do
    test "robot moves bearing" do
      robot = %{position: {0, 0}, bearing: :N}
      assert Robot.move(robot, :L) == %{robot | bearing: :W}
      assert Robot.move(robot, :R) == %{robot | bearing: :E}

      robot = %{robot | bearing: :W}
      assert Robot.move(robot, :L) == %{robot | bearing: :S}
      assert Robot.move(robot, :R) == %{robot | bearing: :N}

      robot = %{robot | bearing: :E}
      assert Robot.move(robot, :L) == %{robot | bearing: :N}
      assert Robot.move(robot, :R) == %{robot | bearing: :S}

      robot = %{robot | bearing: :S}
      assert Robot.move(robot, :L) == %{robot | bearing: :E}
      assert Robot.move(robot, :R) == %{robot | bearing: :W}
    end

    test "robot moves position" do
      robot = %{position: {5, 5}, bearing: :N}
      assert Robot.move(robot, :F) == %{robot | position: {5, 6}}

      robot = %{robot | bearing: :W}
      assert Robot.move(robot, :F) == %{robot | position: {4, 5}}

      robot = %{robot | bearing: :E}
      assert Robot.move(robot, :F) == %{robot | position: {6, 5}}

      robot = %{robot | bearing: :S}
      assert Robot.move(robot, :F) == %{robot | position: {5, 4}}
    end

    test "robot moves bearing and position" do
      robot = %{position: {0, 0}, bearing: :E}
      new_robot = robot
                  |> Robot.move(:F)
                  |> Robot.move(:L)
                  |> Robot.move(:F)
                  |> Robot.move(:L)

      assert new_robot == %{position: {1, 1}, bearing: :W}
    end
  end
end
