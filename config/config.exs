import Config

# Configure your database
config :address_book_ecto, AddressBookEcto.Repo,
  adapter: Ecto.Adapters.Postgres, # Or Ecto.Adapters.MySQL, Ecto.Adapters.SQLite3, etc.
  username: "your_database_username",
  password: "your_database_password",
  database: "your_database_name", # Or your desired database name
  hostname: "your_database_hostname_or_ip", # E.g., "localhost" or a remote address
  port: 5432, # Default PostgreSQL port, adjust if needed (must be an integer)
  pool_size: 10 # Example pool size, adjust if needed

# Tell the application about its Ecto repository
config :address_book_ecto,
  ecto_repos: [AddressBookEcto.Repo]
