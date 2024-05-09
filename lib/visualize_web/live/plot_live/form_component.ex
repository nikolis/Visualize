defmodule VisualizeWeb.PlotLive.FormComponent do
  use VisualizeWeb, :live_component

  alias Explorer.DataFrame, as: DF
  alias Visualize.Presentation.PlotUserShareEntry
  alias Visualize.Presentation
  alias Visualize.Accounts
  alias Visualize.Accounts.User

  import VisualizeWeb.PlotLive.PlotUtils
  @operators ["+", "-", "*", "/"]
  @base_url "https://raw.githubusercontent.com/plotly/datasets/master/"

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div>
        <.header class="header">
          <%= @title %>
          <.error :for={{:general, {msg, _}} <- @form.errors}><%= msg %></.error>
        </.header>

        <.simple_form
          for={@form}
          id="plot-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <%= if @plot_context  != :not_ready do %>
            <div
              style="height: 500px; width: 600px"
              id="plotly_container"
              phx-hook="PlotlyHook"
              data-plot-context={@plot_context}
            >
            </div>
          <% end %>
          <.input field={@form[:name]} type="text" label="Name" />
          <.input field={@form[:dataset_name]} type="text" label="Dataset name" />
          <.input field={@form[:expression]} type="text" label="Expression" />
          <.input field={@form[:user_id]} type="hidden" />

          <.inputs_for :let={user_entry} field={@form[:plot_user_share_entries]}>
            <.user_entry_render user_entry={user_entry} users={@users} myself={@myself} />
          </.inputs_for>
          <.button class="button_secondary" type="button" phx-click="add-line" phx-target={@myself}>
            Add collbaorators
          </.button>

          <:actions>
            <.button class="button w-full text-xl" phx-disable-with="Saving...">Save Plot</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def user_entry_render(assigns) do
    assigns =
      assign(
        assigns,
        :deleted,
        Phoenix.HTML.Form.input_value(assigns.user_entry, :delete) == true
      )

    ~H"""
    <div class="flex space-x-10 drag-item " style={if(@deleted, do: "display: none")}>
      <.input
        type="hidden"
        name={Phoenix.HTML.Form.input_name(@user_entry, :delete)}
        value={to_string(Phoenix.HTML.Form.input_value(@user_entry, :delete))}
      />
      <.input type="select" field={@user_entry[:user_id]} placeholder="User" options={@users} />
      <div class="max-w-50 m-auto text-black">
        <.error :for={{_, {msg, _}} <- @user_entry.errors}><%= msg %></.error>
      </div>
      <button
        class="button_delete"
        phx-target={@myself}
        phx-click="delete-line"
        phx-value-index={@user_entry.index}
        disabled={@deleted}
        type="button"
      >
        <.icon class="" name="hero-x-mark" />
      </button>
    </div>
    """
  end

  @impl true
  def update(%{plot: plot} = assigns, socket) do
    changeset = Presentation.change_plot(plot, assigns.current_user)
    plot_data =
      plot
      |> get_csv_data()
      |> calculate_plot_data()

    {:ok,
     socket
     |> assign(assigns)
     |> maybe_assign_plot_context(plot_data)
     |> assign_form(changeset)
     |> assign_users()}
  end

  def handle_event("add-line", _, socket) do
    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_assoc(changeset, :plot_user_share_entries)

        changeset =
          Ecto.Changeset.put_assoc(changeset, :plot_user_share_entries, existing ++ [%{}])

        to_form(changeset)
      end)

    {:noreply, socket}
  end

  def handle_event("delete-line", %{"index" => index}, socket) do
    index = String.to_integer(index)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_assoc(changeset, :plot_user_share_entries)
        {to_delete, rest} = List.pop_at(existing, index)

        user_share_entries =
          if Ecto.Changeset.change(to_delete).data.id do
            List.replace_at(existing, index, Ecto.Changeset.change(to_delete, delete: true))
          else
            rest
          end

        changeset
        |> Ecto.Changeset.put_assoc(:plot_user_share_entries, user_share_entries)
        |> to_form()
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"plot" => plot_params}, socket) do
    changeset =
      socket.assigns.plot
      |> Presentation.change_plot(plot_params, socket.assigns.current_user)
      |> Map.put(:action, :validate)

    changeset =
      changeset
      |> validate_csv(socket.assigns.form)
      |> validate_data_frame()
      |> validate_expression(socket.assigns.form)

    plot_data = calculate_plot_data(changeset, socket.assigns.form)

    {:noreply,
     socket
     |> assign_form(changeset)
     |> maybe_assign_plot_context(plot_data)}
  end

  def handle_event("save", %{"plot" => plot_params}, socket) do
    save_plot(socket, socket.assigns.action, plot_params)
  end

  defp save_plot(socket, :edit, plot_params) do
    case Presentation.update_plot(socket.assigns.plot, plot_params, socket.assigns.current_user) do
      {:ok, plot} ->
        notify_parent({:saved, plot})

        {:noreply,
         socket
         |> put_flash(:info, "Plot updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_plot(socket, :new, plot_params) do
    case Presentation.create_plot(plot_params) do
      {:ok, plot} ->
        notify_parent({:saved, plot})

        {:noreply,
         socket
         |> put_flash(:info, "Plot created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_users(socket) do
    authors =
      Accounts.list_users()
      |> Enum.map(&{&1.email, &1.id})

    assign(socket, :users, authors)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))

    if Ecto.Changeset.get_field(changeset, :plot_user_share_entries) == [] do
      plot_user_share_entry = %PlotUserShareEntry{}

      changeset =
        Ecto.Changeset.put_change(changeset, :plot_user_share_entries, [plot_user_share_entry])

      assign(socket, :form, to_form(changeset))
    else
      assign(socket, :form, to_form(changeset))
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp validate_expression(changeset, form) do
    case changeset.valid? do
      true ->
        expression = get_key_from_change_or_data(changeset, form, :expression)
        expression_list = convert_expression(expression)

        valid =
          Enum.reduce(expression_list, true, fn x, acc ->
            case x in @operators or (x in changeset.changes.column_names and acc) do
              true ->
                true

              false ->
                false
            end
          end)

        case valid do
          true ->
            changeset

          false ->
            Ecto.Changeset.add_error(changeset, :expression, "Not a valid expression")
        end

      false ->
        changeset
    end
  end

  def calculate_plot_data(changeset, form) do
    case changeset.valid? do
      false ->
        {:error, :invalid_changest}

      true ->
        dataframe = DF.load_csv!(get_key_from_change_or_data(changeset, form, :csv_body))

        expression =
          get_key_from_change_or_data(changeset, form, :expression)

        {:ok, calculate_result_frame(dataframe, convert_expression(expression))}
    end
  end

  defp get_key_from_change_or_data(
         %Ecto.Changeset{changes: changes} = _changeset,
         %Phoenix.HTML.Form{data: data},
         key
       ) do
    Map.get(changes, key) || Map.get(data, key)
  end

  def maybe_assign_plot_context(socket, {:error, _}) do
    assign(socket, :plot_context, :not_ready)
  end

  def maybe_assign_plot_context(socket, {:ok, data}) do
    assign(socket, :plot_context, Poison.encode!(%{x: data, type: "histogram"}))
  end

  defp validate_csv(changeset, form) do
    case changeset.valid? do
      false ->
        changeset

      true ->
        dataset_name = get_key_from_change_or_data(changeset, form, :dataset_name)

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
            Ecto.Changeset.put_change(changeset, :csv_body, raw_csv.body)

          false ->
            Ecto.Changeset.add_error(changeset, :dataset_name, "the dataset does not exist")
        end
    end
  end

  defp validate_data_frame(changeset) do
    case changeset.valid? do
      false ->
        changeset

      true ->
        dataframe = DF.load_csv!(changeset.changes.csv_body)
        names = Explorer.DataFrame.names(dataframe)
        # Ecto.Changeset.put_change(changeset, :data_frame, dataframe) 
        # TODO Find a clever way to put dataframe in the schema as virtual field
        changeset
        |> Ecto.Changeset.put_change(:column_names, names)
    end
  end
end
