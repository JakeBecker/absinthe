defmodule Absinthe.Phase.Document.Variables do
  @moduledoc """
  Provided a set of variable values:

  - Set the `variables` field on the `Blueprint.Document.Operation.t` to the reconciled
    mapping of variable values, supporting defined default values.

  ## Examples

  Given a GraphQL document that looks like:

  ```
  query Item($id: ID!, $text = String = "Another") {
    item(id: $id, category: "Things") {
      name
    }
  }
  ```

  And this phase configuration:

  ```
  run(blueprint, %{operation_name: "Item", variables: %{"id" => "1234"}})
  ``

  - The operation's `variables` field would have an `"id"` value set to
    `%Blueprint.Input.StringValue{value: "1234"}`
  - The operation's `variables` field would have an `"text"` value set to
    `%Blueprint.Input.StringValue{value: "Another"}`

  ```
  run(blueprint, %{operation_name: "Item", variables: %{}})
  ``

  - The operation's `variables` field would have an `"id"` value set to
    `nil`
  - The operation's `variables` field would have an `"text"` value set to
    `%Blueprint.Input.StringValue{value: "Another"}`

  Note that no validation occurs in this phase.
  """

  alias Absinthe.Blueprint

  @spec run(Blueprint.t, %{values: %{String.t => any}}) :: {:ok, Blueprint.t}
  def run(input, options) do
    acc = %{raw: options.values, processed: %{}}
    {node, _} = Blueprint.Mapper.postwalk(input, acc, &handle_node/2)
    {:ok, node}
  end

  @spec handle_node(Blueprint.node_t, map) :: {Blueprint.node_t, map}
  defp handle_node(%Blueprint.Document.VariableDefinition{} = node, acc) do
    provided_value = Map.get(acc.raw, node.name, node.default_value)
    |> Blueprint.Input.parse
    {
      %{node | provided_value: provided_value},
      update_in(acc.processed, &Map.put(&1, node.name, provided_value))
    }
  end
  defp handle_node(%Blueprint.Document.Operation{} = node, acc) do
    {
      %{node | provided_values: acc.processed},
      acc
    }
  end
  defp handle_node(node, acc) do
    {node, acc}
  end

end