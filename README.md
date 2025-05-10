# Elixir CLI Address Book (Ecto Version)

A basic command-line application in Elixir for managing personal contacts with multi-user support and database persistence using Ecto. This project serves as an educational resource for new Elixir developers to learn fundamental concepts, including Ecto database interactions, by exploring a functional example.

**WARNING:** This application stores user passwords in plain text for simplicity and educational purposes. **DO NOT** use this code in any production environment. Secure password handling (hashing and salting) is essential for real-world applications.

## Features

* User Registration
* User Login/Logout
* Add New Contacts (per user)
* Edit Existing Contacts (per user)
* View All Contacts (for the logged-in user)
* Delete Contacts (per user)
* Search Contacts (by name, number, or email for the logged-in user)
* Data persistence to a relational database using Ecto.

## How to Run

1.  **Prerequisites:**
    * Elixir and Erlang/OTP installed on your system. You can find installation instructions [here](https://elixir-lang.org/install.html).
    * A running database server (e.g., PostgreSQL, MySQL, SQLite). This README assumes PostgreSQL, but you can adapt the `config/config.exs` and dependency (`mix.exs`) for other databases.
2.  **Clone the repository:**
    ```bash
    git clone https://github.com/1Bernard/address_book_elixir_ecto
    cd address_book_elixir_ecto
    ```
3.  **Configure Database Connection:**
    * Open the `config/config.exs` file in your project.
    * Locate the `config :address_book_ecto, AddressBookEcto.Repo` block.
    * Update the `username`, `password`, `database`, `hostname`, and `port` fields to match your local database server's credentials and connection details.

    *Example `config/config.exs` snippet (adjust for your database type and credentials):*
    ```elixir
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

    # You might have other configurations here as well
    ```
    *Make sure the `port` is configured as an integer (e.g., `5432`) instead of a string.*

4.  **Fetch dependencies:**
    ```bash
    mix deps.get
    ```
    This will download Ecto, the database adapter (like Postgrex), and `ex_doc`, needed for documentation generation.
5.  **Create and Migrate Database:**
    * Ensure your database server is running and accessible from where you are running these commands.
    * Run the following commands in your terminal from the project root:
    ```bash
    mix ecto.create
    mix ecto.migrate
    ```mix ecto.create` will attempt to create the database specified in your `config/config.exs`. `mix ecto.migrate` will run the database migration files located in `priv/repo/migrations/` to set up the necessary tables (users and contacts).
6.  **Run the application using Mix:**
    ```bash
    mix run --no-halt
    ```
    The `--no-halt` flag keeps the application running after initialization, allowing you to interact with the CLI. The application will start, display a welcome message, and present the authentication menu.

## Project Structure

Your project has the following key directories and files:

* `address_book_ecto/`: A directory containing other modules specific to your application.
    * `application.ex`: The OTP application entry point, defining the supervision tree.
    * `repo.ex`: The Ecto repository module, used for interacting with the database.
    * `user.ex`: The Ecto schema and changeset for the `User` model.
    * `contact.ex`: The Ecto schema and changeset for the `Contact` model.

* `priv/`: Contains private files, often used for repository-specific tasks.
    * `repo/`: Contains files related to your Ecto repository.
        * `migrations/`: Directory containing Ecto database migration files.

## Code Overview and Key Concepts for Learning

This application is designed to demonstrate several core Elixir and functional programming concepts, along with Ecto for database interaction:

1.  **Modules and Functions:** The code is organized into logical units (`AddressBookEcto`, `AddressBookEcto.User`, `AddressBookEcto.Contact`, `AddressBookEcto.Repo`). Explore how functions are defined (`def`, `defp`) and called. Pay attention to the `@moduledoc` and `@doc` attributes used for documentation.
2.  **State Management with Recursion:** Notice the `AddressBookEcto.main_loop/1` function. Instead of mutable state and imperative loops, the application state (the `current_user`) is passed as an argument in recursive function calls. This is a common functional pattern for managing state in long-running processes or simple state machines.
3.  **Ecto for Database Interaction:** Learn how Ecto is used to define schemas (`AddressBookEcto.User`, `AddressBookEcto.Contact`), build changesets for data validation and casting, and interact with the database via the repository (`AddressBookEcto.Repo`). See examples of `Repo.get_by/2`, `Repo.insert/1`, `Repo.update/1`, `Repo.delete/1`, and Ecto queries (`import Ecto.Query`, `from c in ...`).
4.  **Changesets:** Understand how `Ecto.Changeset` is used to validate and prepare data before inserting or updating records in the database.
5.  **Pattern Matching and `case` Expressions:** Observe how `case` expressions and pattern matching are used extensively to handle different user inputs (`"1"`, `"2"`, etc.) and function return values (e.g., `{:ok, result}`, `{:error, changeset}` from Repo operations).
6.  **Data Structures (Structs, Maps, and Lists):** User and contact data fetched from the database are represented as Elixir Structs (`%AddressBookEcto.User{}`, `%AddressBookEcto.Contact{}`). Maps are used for passing attributes. Collections of structs are managed as Lists (`[]`). The `Enum` module is used to work with these lists.
7.  **The `Enum` Module:** Elixir's `Enum` module provides powerful functions for working with collections. See examples of `Enum.filter`, `Enum.empty?`, etc. for data manipulation and querying results from the database.
8.  **The `String` Module:** Learn how `String.trim`, `String.downcase`, `String.contains?` are used for input processing and searching.
9.  **User Interaction (`IO` module):** `IO.gets/1` is used to get input from the user (including handling the `:eof` case for Ctrl+D), and `IO.puts/1` is used to display output.

## Generating HTML Documentation

The code includes `@moduledoc` and `@doc` attributes. You can generate browsable HTML documentation from these comments using `ExDoc`:

1.  Make sure you have fetched dependencies (`mix deps.get`). ExDoc should be included in your `mix.exs` `deps` function, typically under `only: :dev`.
2.  Run the documentation task:
    ```bash
    mix docs
    ```
3.  Open the generated documentation in your web browser by opening the file `doc/index.html`.

**Alternatively, you can view the deployed documentation online:** [https://1bernard.github.io/address_book_elixir/readme.html](https://1bernard.github.io/address_book_elixir/readme.html)

## Areas for Improvement and Further Learning

This application can be extended and improved in many ways. Consider implementing some of these to further practice your Elixir and Ecto skills:

* **Security:** **Implement secure password hashing** (e.g., using the `bcrypt_elixir` library and integrating it with your User schema and login logic) instead of plain text storage and comparison.
* **Data Validation:** Enhance validation in your Ecto changesets to ensure contact details (like email format or phone number) are valid before saving.
* **Error Handling:** Make the error handling more sophisticated, perhaps providing more user-friendly messages for specific issues or logging errors.
* **Concurrency:** How would you handle multiple processes or users interacting with the application simultaneously? While Ecto helps manage database connections, the CLI structure is single-user.
* **More Features:** Add sorting contacts by name, filtering by other criteria, exporting contacts to a different format (like CSV), importing contacts.
* **Testing:** Write unit tests for your functions, especially the login/registration logic and contact management functions that interact with the Repo. Write tests for your Ecto schemas and changesets.
* **Supervisors:** Review your `application.ex` file and understand how the Repo is supervised. For more complex applications, you'd add more processes under supervision.

## Getting Started as a New Team Member

This project is your starting point for learning Elixir CLI development with Ecto. Here's a suggested path:

1.  **Get it Running:** Follow the "How to Run" instructions above to ensure you can start and interact with the application. Register a user and add some contacts. Verify that data is being stored in your configured database.
2.  **Explore the Code:** Read through `lib/address_book_ecto.ex`, `lib/address_book_ecto/user.ex`, `lib/address_book_ecto/contact.ex`, and `lib/address_book_ecto/repo.ex`. Use the inline `@moduledoc` and `@doc` comments directly in your editor, or generate the HTML documentation (`mix docs`) and browse it in your web browser.
3.  **Trace Execution:** As you interact with the running application, try to follow the code path in your editor. For example, choose "1" from the contact menu ("Add Contact") and trace how `handle_contact_action` calls `create`, which then calls `get_input` multiple times, leads to `review_new_contact`, and finally calls `save_new_contact` which interacts with `AddressBookEcto.Repo.insert`.
4.  **Identify Key Patterns:** Look for the recurring patterns like state passing in `main_loop`, `case` statements for handling different outcomes (input, Repo operations), Ecto schema and changeset usage, and `Enum` functions for list manipulation.
5.  **Implement an Improvement:** Pick one item from the "Areas for Improvement" list (e.g., add basic validation to ensure the email address input contains "@" and "." within the Contact changeset) and try to implement it. This hands-on practice is invaluable.
6.  **Build Your Own:** Once you feel comfortable, try starting a new Mix project (`mix new my_cli_app_with_db`) and build something similar but different (e.g., a task tracker, a simple inventory) using Ecto, referencing this project as a template for structure and database interaction.

## License

This project is open-source under the [MIT License](LICENSE).

## Contributing

(Optional section: If you want to accept contributions from team members for improving this example)
