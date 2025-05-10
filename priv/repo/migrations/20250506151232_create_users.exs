defmodule AddressBookEcto.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    # Create the users table with an integer primary key
    create table(:users) do # Removed primary_key: false as integer primary keys are default
      add :username, :string, null: false # Make username required
      # WARNING: Store hashed passwords in production!
      add :password, :string, null: false # Make password required

      timestamps() # Adds inserted_at and updated_at columns
    end

    # Add a unique index on username
    create unique_index(:users, [:username])
  end
end
