defmodule Absinthe.Blueprint.Schema.SchemaDefinition do

  alias Absinthe.Blueprint

  defstruct [
    description: nil,
    fields: [],
    directives: [],
    # Added by phases
    flags: [],
    errors: [],
  ]

  @type t :: %__MODULE__{
    description: nil | String.t,
    fields: [Blueprint.Schema.FieldDefinition.t],
    directives: [Blueprint.Directive.t],
    # Added by phases
    flags: [atom],
    errors: [Absinthe.Phase.Error.t],
  }

end