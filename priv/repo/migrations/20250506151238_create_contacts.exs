defmodule AddressBookEcto.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    # Create the contacts table with an integer primary key
    create table(:contacts) do # Removed primary_key: false
      # add :entry, :integer # We are replacing 'entry' with 'id'
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :contact, :string # Allow null for optional fields if needed
      add :email, :string # Allow null for optional fields if needed

      # Add the foreign key column to the contacts table, now an integer
      add :user_id, :integer, null: false # Change from :binary_id to :integer

      timestamps()
    end # <-- End of the create table block

    # Now, *outside* the create table block, create the index
    # Add an index for faster lookups by user
    create index(:contacts, [:user_id])

    # Optional: Add a foreign key constraint for referential integrity
    # This is also done as a separate command outside the create table block
    # foreign_key(:contacts, :user_id, :users, type: :integer, on_delete: :delete_all)
  end
end
