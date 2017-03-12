defmodule SimulationTest do
  use ExUnit.Case
  doctest Simulation

  describe "validate!" do
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
end
