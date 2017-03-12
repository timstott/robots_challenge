defmodule SimulationTest do
  use ExUnit.Case
  doctest Simulation

  describe "validate!/1" do
    test "is invalid when grid exceeds max coordinate" do
      simulation = %Simulation{grid: {5, 51}}

      assert_raise ArgumentError, "Max coordinate is 50, received x5 y51", fn() ->
        Simulation.validate!(simulation)
      end
    end

    test "is invalid when a mission contains invalid actions" do
      simulation = %Simulation{
        missions: [
          %{actions: [:K]}
        ]
      }

      assert_raise ArgumentError, "Mission contains invalid action", fn() ->
        Simulation.validate!(simulation)
      end
    end

    test "is invalid when a mission has more than 100 actions" do
      simulation = %Simulation{
        missions: [
          %{actions: Stream.cycle([:L]) |> Enum.take(101)}
        ]
      }

      assert_raise ArgumentError, "Mission has more than 100", fn() ->
        Simulation.validate!(simulation)
      end
    end

    test "returns the simulation when valid" do
      simulation = %Simulation{
        grid: {5, 5},
        missions: [
          %{actions: []}
        ]
      }

      assert Simulation.validate!(simulation) == simulation
    end
  end

  describe "simulate/1" do
    test "all robots termninate inside the simulation" do
      simulation = %Simulation{
        grid: {5, 3},
        missions: [
          %{robot: %Robot{position: {1, 1}, bearing: :E}, actions: [:R, :F, :R, :F, :R, :F, :R, :F]}
        ]
      }

      output = [
        %Robot{position: {1, 1}, bearing: :E}
      ]

      assert Simulation.run(simulation) == output
    end

    test "one robot is lost" do
      simulation = %Simulation{
        grid: {5, 3},
        missions: [
          %{robot: %Robot{position: {3, 2}, bearing: :N}, actions: [:F, :R, :R, :F, :L, :L, :F, :F, :R, :R,:F, :L, :L]}
        ]
      }

      output = [
        %Robot{position: {3, 3}, bearing: :N, lost: true}
      ]

      assert Simulation.run(simulation) == output
    end

    test "one robot saved by lost robot" do
      simulation = %Simulation{
        grid: {5, 3},
        missions: [
          %{robot: %Robot{position: {3, 2}, bearing: :N}, actions: [:F, :R, :R, :F, :L, :L, :F, :F, :R, :R,:F, :L, :L]},
          %{robot: %Robot{position: {0, 3}, bearing: :W}, actions: [:L, :L, :F, :F, :F, :L, :F, :L, :F, :L]}
        ]
      }

      output = [
        %Robot{position: {3, 3}, bearing: :N, lost: true},
        %Robot{position: {2, 3}, bearing: :S}
      ]

      assert Simulation.run(simulation) == output
    end
  end
end
