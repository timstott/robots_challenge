defmodule Simulation do
  defstruct grid: {0, 0}, missions: [], results: []

  @max_coordinate 50
  @max_actions 100
  @valid_actions MapSet.new([:F, :L, :R])

  @doc """
  Returns the simulation when valid.
  Or raises an exception when the simulation is invalid.

  - Action list size in is less than 100
  - Action list only contains :F :R :L
  - Grid max coordinate is 50
  """
  def validate!(%Simulation{grid: {x, y}, missions: missions} = simulation) do
    if x > @max_coordinate || y > @max_coordinate do
      raise ArgumentError, message: "Max coordinate is #{@max_coordinate}, received x#{x} y#{y}"
    end

    Enum.each(missions, fn(%{actions: actions}) ->
      if Enum.count(actions) > @max_actions do
        raise ArgumentError, message: "Mission has more than #{@max_actions}"
      end
      if !MapSet.subset?(MapSet.new(actions), @valid_actions) do
          raise ArgumentError, message: "Mission contains invalid action"
      end
    end)
    simulation
  end

  def run(%Simulation{missions: missions} = simulation) do
    Enum.reduce(missions, simulation, fn(mission, simulation) ->
      robot = Robot.actionate(mission.actions, mission.robot, simulation)
      %{simulation | results: (simulation.results ++ [robot])}
    end).results
  end
end
