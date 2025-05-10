# address_book_ecto/lib/address_book_ecto/repo.ex
defmodule AddressBookEcto.Repo do
  use Ecto.Repo,
    otp_app: :address_book_ecto, # Your application name
    adapter: Ecto.Adapters.Postgres
end
