defmodule AddressBookEcto.User do
  use Ecto.Schema
  import Ecto.Changeset

  # Add this line to define the type 't()' for this module
  @type t() :: %__MODULE__{
          id: integer() | nil,
          username: String.t(),
          password: String.t(), # Remember the WARNING about plain text passwords
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "users" do
    field :username, :string
    field :password, :string # Store hashed password in production!

    timestamps()
  end

  @doc false # Typically changesets are not part of the public API you'd document with ExDoc
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> unique_constraint(:username) # Add a unique constraint on username
  end
end
