defmodule Day15 do
  @moduledoc false

  @path Application.app_dir(:advent_2022, "priv/day_15_input.txt")

  ### PART 1

  def part_1 do
    %{sensors: sensors, beacons: beacons} = parse_input(@path)

    sensors
    |> check_row(2_000_000)
    |> remove_sensors(sensors)
    |> remove_beacons(beacons)
    |> MapSet.size()
  end

  defp check_row(sensors, row) do
    coverage = Enum.reduce(sensors, MapSet.new(), &scan_row_with_sensor(&1, row, &2))

    {row, coverage}
  end

  # The plan here is to check how much of the sensor's range is used just getting to the
  # destination row, and subtract it.  The remaining distance (times 2 plus 1) will create
  # the horizontal scan area with the sensor's x-position as the midpoint.
  defp scan_row_with_sensor(sensor, row, coverage) do
    %{location: {x, y}, range: range} = sensor

    case abs(row - y) do
      dy when dy <= range ->
        x_range = range - dy
        lo = x - x_range
        hi = x + x_range

        MapSet.union(coverage, MapSet.new(lo..hi))

      dy when dy > range ->
        coverage
    end
  end

  defp remove_sensors({row, coverage}, sensors) do
    sensor_x_locations_in_row =
      sensors
      |> Enum.filter(fn %{location: {_x, y}} -> y == row end)
      |> Enum.map(fn %{location: {x, _y}} -> x end)
      |> MapSet.new()

    new_coverage = MapSet.difference(coverage, sensor_x_locations_in_row)

    {row, new_coverage}
  end

  defp remove_beacons({row, coverage}, beacons) do
    beacon_x_locations_in_row =
      beacons
      |> Enum.filter(fn {_x, y} -> y == row end)
      |> Enum.map(fn {x, _y} -> x end)
      |> MapSet.new()

    MapSet.difference(coverage, beacon_x_locations_in_row)
  end

  ### PART 2

  def part_2 do
    %{sensors: sensors} = parse_input(@path)
    quad = %{i: {4_000_000, 0}, ii: {0, 0}, iii: {0, 4_000_000}, iv: {4_000_000, 4_000_000}}

    quad
    |> check(sensors)
    |> calculate_tuning_frequency()
  end

  # For part 2 we use a regional quadtree to continually split the map into
  # quadrants until we find a 1x1 quadrant (single coord) which is not covered
  # by the sensors.  This allows quick checking of coverage by only checking the
  # four corners of a quadrant, regardless of its size.  We also optimize further
  # by removing quadrants as soon as we know they are covered.
  defp check(%{i: coord, ii: coord, iii: coord, iv: coord}, sensors) do
    case Enum.find(sensors, &contains_coord?(&1, coord)) do
      nil -> coord
      _sensor -> false
    end
  end

  defp check(quad, sensors) do
    corners = Map.values(quad)

    case Enum.find(sensors, &contains_all_corners?(&1, corners)) do
      nil ->
        [a, b, c, d] = split_quad(quad)

        with false <- check(a, sensors),
             false <- check(b, sensors),
             false <- check(c, sensors),
             false <- check(d, sensors) do
          false
        end

      _sensor ->
        false
    end
  end

  defp contains_coord?(sensor, coord) do
    distance(coord, sensor.location) <= sensor.range
  end

  defp contains_all_corners?(sensor, corners) do
    Enum.all?(corners, &contains_coord?(sensor, &1))
  end

  defp split_quad(%{i: {x2, y1}, ii: {x1, y1}, iii: {x1, y2}, iv: {x2, y2}}) do
    dx = x2 - x1
    x_mid_lo = x1 + div(dx, 2)
    x_mid_hi = x_mid_lo + rem(dx, 2)

    dy = y2 - y1
    y_mid_lo = y1 + div(dy, 2)
    y_mid_hi = y_mid_lo + rem(dy, 2)

    [
      %{i: {x2, y1}, ii: {x_mid_hi, y1}, iii: {x_mid_hi, y_mid_lo}, iv: {x2, y_mid_lo}},
      %{i: {x_mid_lo, y1}, ii: {x1, y1}, iii: {x1, y_mid_lo}, iv: {x_mid_lo, y_mid_lo}},
      %{i: {x_mid_lo, y_mid_hi}, ii: {x1, y_mid_hi}, iii: {x1, y2}, iv: {x_mid_lo, y2}},
      %{i: {x2, y_mid_hi}, ii: {x_mid_hi, y_mid_hi}, iii: {x_mid_hi, y2}, iv: {x2, y2}}
    ]
  end

  defp calculate_tuning_frequency({x, y}) do
    x * 4_000_000 + y
  end

  ### PARSING

  def parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{beacons: [], sensors: []}, &parse_line/2)
  end

  defp parse_line(line_text, acc) do
    ["Sensor at " <> sensor_coord_text, "closest beacon is at " <> closest_beacon_coord_text] =
      String.split(line_text, ": ")

    sensor_coord = parse_coord(sensor_coord_text)
    closest_beacon_coord = parse_coord(closest_beacon_coord_text)

    sensor = %{location: sensor_coord, range: distance(sensor_coord, closest_beacon_coord)}

    acc
    |> Map.update!(:beacons, &[closest_beacon_coord | &1])
    |> Map.update!(:sensors, &[sensor | &1])
  end

  defp parse_coord(coord_text) do
    ["x=" <> x_text, "y=" <> y_text] = String.split(coord_text, ", ")

    [x_text, y_text]
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp distance({x1, y1}, {x2, y2}) do
    abs(y2 - y1) + abs(x2 - x1)
  end
end
