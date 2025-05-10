defmodule AddressBookEcto.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  # Add this line to define the type 't()' for this module
  @type t() :: %__MODULE__{
          id: integer() | nil,
          first_name: String.t(),
          last_name: String.t(),
          contact: String.t(), # Assuming this is phone number/contact string
          email: String.t(),
          user_id: integer(), # This is the foreign key field type
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t(),
          user: AddressBookEcto.User.t() | Ecto.Association.NotLoaded.t() # Define the association type
        }


  schema "contacts" do
    field :first_name, :string
    field :last_name, :string
    field :contact, :string # Assuming this is phone number/contact string
    field :email, :string

    # Define the association to the User module
    # This creates a user_id field in the database table
    belongs_to :user, AddressBookEcto.User, foreign_key: :user_id

    timestamps()
  end

  @doc false # Typically changesets are not part of the public API you'd document with ExDoc
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:first_name, :last_name, :contact, :email, :user_id]) # Include user_id in cast
    |> validate_required([:first_name, :last_name, :contact, :email, :user_id])
    # Add other validations here if needed (e.g., validate email format)
  end
end
