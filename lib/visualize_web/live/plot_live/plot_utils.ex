defmodule VisualizeWeb.PlotLive.PlotUtils do
  alias Explorer.DataFrame, as: DF

  require Explorer.DataFrame
  alias Visualize.Presentation.Plot

  @operators ["+", "-", "*", "/"]
  @base_url "https://raw.githubusercontent.com/plotly/datasets/master/"

  def get_csv_data(%Plot{} = plot) do
    dataset_name = plot.dataset_name

    dataset_name =
      if(String.length(dataset_name) > 1) do
        String.replace(dataset_name, " ", "")
      else
        dataset_name
      end

    raw_csv =
      (@base_url <> dataset_name <> ".csv")
      |> Req.get!()

    case raw_csv.status == 200 do
      true ->
        {:ok, %Plot{plot | csv_body: raw_csv.body}}

      false ->
        {:error, plot}
    end
  end

  def calculate_plot_data({:ok, %Plot{} = plot}) do
    dataframe = DF.load_csv!(plot.csv_body)
    expression = convert_expression(plot.expression)
    result_frame = calculate_result_frame(dataframe, expression)
    {:ok, result_frame}
  end

  def calculate_plot_data({:error, plot}) do
    {:error, plot}
  end

  def mutate(dataframe, "+", a, b) do
    Explorer.DataFrame.mutate(dataframe, result: ^a + ^b)
  end

  def mutate(dataframe, "-", a, b) do
    Explorer.DataFrame.mutate(dataframe, result: ^a - ^b)
  end

  def mutate(dataframe, "*", a, b) do
    Explorer.DataFrame.mutate(dataframe, result: ^a * ^b)
  end

  def mutate(dataframe, "/", a, b) do
    Explorer.DataFrame.mutate(dataframe, result: ^a / ^b)
  end

  def calculate_result_frame(dataframe, [single_exp]) do
    Explorer.Series.to_list(dataframe[single_exp])
  end

  def calculate_result_frame(dataframe, expression) do
    {result_frame, _, _} =
      Enum.reduce(expression, {dataframe, [], ""}, fn x, {df, col_list, last} ->
        case last in @operators do
          true ->
            a = df[Enum.at(col_list, 0)]
            b = df[x]
            data_frame = mutate(dataframe, last, a, b)
            {data_frame, [], ""}

          false ->
            case x in @operators do
              true ->
                {df, col_list, x}

              false ->
                {df, col_list ++ [x], x}
            end
        end
      end)

    Explorer.Series.to_list(result_frame["result"])
  end

  def convert_expression(input) do
    input = input <> "+"
    result = String.split(input, "")

    {command_table, _rest} =
      Enum.reduce(result, {[], ""}, fn x, {tb, cm} ->
        case x in @operators do
          true ->
            {tb ++ [cm] ++ [x], ""}

          false ->
            {tb, cm <> x}
        end
      end)

    Enum.slice(command_table, 0..(length(command_table) - 2))
  end
end
