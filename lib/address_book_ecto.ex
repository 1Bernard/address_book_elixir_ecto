defmodule AddressBookEcto do
  import Ecto.Query # Import Ecto's query DSL for database queries

  # --- Public Interface ---

  # Starts the address book application loop.
  # This function is typically called from the application supervisor's `start` function.
  # It initializes the main loop in a pre-login state (no user logged in).
  # The Ecto repository (`AddressBookEcto.Repo`) is expected to be started
  # in the application's supervision tree before calling this function.
  @spec run() :: :ok | no_return
  def run do
    # Ecto repo is started in the application.ex supervision tree
    # Start the main loop in a pre-login state
    main_loop(nil) # nil indicates no user is logged in initially
  end

  # --- Core Logic ---

  # The main application loop that handles both pre-login and post-login states.
  # The state is managed by passing the `current_user` struct (or `nil` if not logged in)
  # through recursive calls. It displays the appropriate menu and delegates input handling.
  @spec main_loop(AddressBookEcto.User.t() | nil) :: no_return
  defp main_loop(current_user) do
    # Display the appropriate menu based on login status
    if current_user do
      contact_menu() # User is logged in, show contact management menu
    else
      auth_menu() # No user logged in, show authentication menu
    end

    # Read user input from the console and handle potential end-of-file (Ctrl+D)
    case IO.gets("Select from the options above: ") do
      :eof ->
        end_session() # If end of input is reached, end the session gracefully

      input_line ->
        input = String.trim(input_line) # Trim leading/trailing whitespace from input

        # Delegate input handling based on login status
        if current_user do
          handle_contact_action(input, current_user) # User is logged in, handle contact actions
        else
          handle_auth_action(input) # No user logged in, handle authentication actions
        end
    end
  end

  # Handles actions when no user is logged in (registration, login, exit).
  # It directs the flow based on the user's menu choice.
  @spec handle_auth_action(String.t()) :: no_return
  defp handle_auth_action(input) do
    case input do
      "1" -> register() # Option 1: Register a new user
      "2" -> login() # Option 2: Log in an existing user
      "0" -> end_session() # Option 0: End the session and exit
      _ ->
        # Handle invalid input
        IO.puts(String.pad_leading("Invalid option. Please select a valid option.", 50, "#"))
        main_loop(nil) # Continue the loop in the pre-login state
    end
  end

  # Handles actions when a user is logged in (Add, Edit, View, Delete contacts, Logout, Search).
  # It directs the flow based on the user's menu choice and the `current_user`.
  @spec handle_contact_action(String.t(), AddressBookEcto.User.t()) :: no_return
  defp handle_contact_action(input, current_user) do
    case input do
      "1" -> create(current_user) # Option 1: Add a new contact
      "2" -> edit(current_user) # Option 2: Edit an existing contact
      "3" -> view(current_user) # Option 3: View all contacts for the current user
      "4" -> delete(current_user) # Option 4: Delete a contact
      "5" -> search(current_user) # Option 5: Search contacts
      "6" -> logout() # Option 6: Log out the current user
      _ ->
        # Handle invalid input
        IO.puts(String.pad_leading("Invalid option. Please select a valid option.", 50, "#"))
        main_loop(current_user) # Continue the loop in the post-login state with the current user
    end
  end

  # Displays the authentication menu options.
  # This menu is shown when no user is logged in, providing options for registration, login, or exiting the application.
  @spec auth_menu() :: :ok
  defp auth_menu do
    IO.puts(String.pad_leading(" Address Book Application ", 50, "#"))
    IO.puts("1. Register")
    IO.puts("2. Login")
    IO.puts("0. End Session")
  end

  # Displays the contact management menu options.
  # This menu is shown when a user is logged in, providing options for adding, editing,
  # viewing, deleting, searching contacts, or logging out.
  @spec contact_menu() :: :ok
  defp contact_menu do
    IO.puts(String.pad_leading(" Contact Management ", 50, "#"))
    IO.puts("1. Add Contact")
    IO.puts("2. Edit Contact")
    IO.puts("3. View Contact List")
    IO.puts("4. Delete Contact")
    IO.puts("5. Search Contacts") # Added Search option
    IO.puts("6. Logout")
  end

  # --- Authentication Functions ---

  # Registers a new user by getting username and password from the console
  # and inserting them into the database.
  # WARNING: This implementation stores passwords in plain text. In a
  # production environment, use a library like `Comeonin` for secure password hashing.
  @spec register() :: no_return
  defp register() do
    IO.puts(String.pad_leading(" New User Registration ", 50, "#"))

    username = get_input("Enter a username: ")

    # Check if username already exists in the database using the Repo
    if AddressBookEcto.Repo.get_by(AddressBookEcto.User, username: username) do
      IO.puts(String.pad_leading("Username already exists. Please try a different one.", 50, "#"))
      main_loop(nil) # Return to the authentication menu
    else
      password = get_input("Enter a password: ")

      new_user_attrs = %{username: username, password: password}

      # Create a new User struct, build a changeset, and insert into the database
      %AddressBookEcto.User{}
      |> AddressBookEcto.User.changeset(new_user_attrs)
      |> AddressBookEcto.Repo.insert()
      |> case do
        {:ok, _user} -> # Insertion successful
          IO.puts(String.pad_leading(" User Registered Successfully", 50, "#"))
          main_loop(nil) # Return to the authentication menu
        {:error, changeset} -> # Insertion failed (e.g., validation error)
          IO.puts(String.pad_leading("Error registering user: #{inspect(changeset.errors)}", 50, "#"))
          main_loop(nil) # Return to the authentication menu
      end
    end
  end

  # Logs in an existing user by checking the provided username and password
  # against the database.
  # WARNING: This function performs a plain text password check. For production,
  # implement secure password verification using hashing (e.g., `Bcrypt` via `Comeonin`).
  @spec login() :: no_return
  defp login() do
    IO.puts(String.pad_leading(" User Login ", 50, "#"))

    username = get_input("Enter your username: ")
    password = get_input("Enter your password: ")

    # Find the user by username using the Repo
    user = AddressBookEcto.Repo.get_by(AddressBookEcto.User, username: username)

    case user do
      nil ->
        IO.puts(String.pad_leading("Invalid username or password.", 50, "#"))
        main_loop(nil) # User not found or password incorrect
      %AddressBookEcto.User{password: stored_password} = fetched_user ->
        if stored_password == password do # Check password
          IO.puts(String.pad_leading(" Welcome, #{fetched_user.username}!", 50, "#"))
          main_loop(fetched_user) # Start post-login loop with user struct
        else
          IO.puts(String.pad_leading("Invalid username or password.", 50, "#"))
          main_loop(nil) # Password incorrect
        end
    end
  end

  # Logs out the current user.
  # It returns the application to the pre-login state by calling `main_loop(nil)`.
  @spec logout() :: no_return
  defp logout() do
    IO.puts(String.pad_leading(" Logged out successfully.", 50, "#"))
    main_loop(nil) # Return to pre-login state (nil user)
  end

  # --- Contact Management Functions (require current_user) ---

  # Guides the user through adding a new contact.
  # It prompts for contact details (first name, last name, contact number, email)
  # and then proceeds to a review/save menu. Users can type `*` at any prompt to
  # cancel and return to the main menu.
  @spec create(AddressBookEcto.User.t()) :: no_return
  defp create(current_user) do
    IO.puts(String.pad_leading(" Add Contact ", 50, "#"))

    # Get contact details from user input
    first_name = get_input("Your First Name (or type '*' to return to main menu): ")
    if first_name == "*", do: main_loop(current_user) # Return if '*' entered

    last_name = get_input("Your Last Name (or type '*' to return to main menu): ")
    if last_name == "*", do: main_loop(current_user) # Return if '*' entered

    contact_num = get_input("Your Contact (or type '*' to return to main menu): ")
    if contact_num == "*", do: main_loop(current_user) # Return if '*' entered

    email = get_input("Your Email (or type '*' to return to main menu): ")
    if email == "*", do: main_loop(current_user) # Return if '*' entered

    # Store the collected details in a map
    new_contact_details = %{
      first_name: first_name,
      last_name: last_name,
      contact: contact_num,
      email: email
    }

    # Proceed to the review/save menu
    review_new_contact(new_contact_details, current_user)
  end

  # Displays a summary of the new contact details and provides options to
  # save, edit, or cancel the contact creation.
  @spec review_new_contact(map(), AddressBookEcto.User.t()) :: no_return
  defp review_new_contact(contact_details, current_user) do
    IO.puts(String.pad_leading(" Summary ", 50, "-"))
    IO.puts("First Name: #{contact_details.first_name}")
    IO.puts("Last Name: #{contact_details.last_name}")
    IO.puts("Phone Number: #{contact_details.contact}") # Assuming 'contact' is phone number
    IO.puts("Email: #{contact_details.email}")
    IO.puts(String.pad_leading("", 50, "-"))

    IO.puts("\nWhat would you like to do next?")
    IO.puts("1. Save Contact")
    IO.puts("2. Edit Details")
    IO.puts("3. Cancel and Return to Main Menu")

    # Read user input for the menu choice
    case IO.gets("Select from the options above: ") |> String.trim() do
      "1" -> save_new_contact(contact_details, current_user) # Save the contact
      "2" -> edit_new_contact_details(contact_details, current_user) # Edit the details
      "3" ->
        IO.puts(String.pad_leading(" Contact creation cancelled.", 50, "#"))
        main_loop(current_user) # Cancel and return to main menu
      _ ->
        IO.puts(String.pad_leading("Invalid option. Please select a valid option.", 50, "#"))
        review_new_contact(contact_details, current_user) # Re-prompt for menu choice
    end
  end

  # Saves the new contact details to the database, associating it with the `current_user`.
  # It constructs a changeset for `AddressBookEcto.Contact` and attempts to insert it.
  @spec save_new_contact(map(), AddressBookEcto.User.t()) :: no_return
  defp save_new_contact(contact_details, current_user) do
    # Create a map of contact attributes for the changeset, INCLUDING user_id
    # Pass the integer user_id directly in the attributes map
    contact_attrs = Map.put(contact_details, :user_id, current_user.id)

    # Create a new Contact struct and build a changeset by casting the attributes.
    # The Contact.changeset is expected to handle casting the user_id from integer to the correct type for the database.
    final_changeset = %AddressBookEcto.Contact{}
                      |> AddressBookEcto.Contact.changeset(contact_attrs) # Pass the attrs including user_id

    # Attempt to insert the contact using the final changeset
    AddressBookEcto.Repo.insert(final_changeset)
    |> case do
      {:ok, _contact} -> # Insertion successful
        IO.puts(String.pad_leading(" Contact Successfully Added", 50, "#"))
        view(current_user) # Display the updated list of contacts
        # view calls main_loop, so no need to call it again here
      {:error, changeset} -> # Insertion failed (e.g., validation error, or type mismatch on user_id)
        IO.puts(String.pad_leading("An error occurred while saving contact: #{inspect(changeset.errors)}", 50, "#"))
        main_loop(current_user) # Return to the contact management menu
    end
  end

  # Allows the user to edit the details of a contact they are currently creating.
  # It prompts for each field, allowing blank input to keep the existing value.
  # Users can type `*` to cancel and return to the main menu.
  @spec edit_new_contact_details(map(), AddressBookEcto.User.t()) :: no_return
  defp edit_new_contact_details(current_details, current_user) do
    IO.puts(String.pad_leading(" Edit New Contact Details ", 50, "#"))

    # Get updated details, allowing blank input to keep existing value
    # We'll pass the current value to get_input for display, but it doesn't pre-fill
    updated_first_name = get_input("Update First Name (leave blank for no change, '*' to cancel, current: #{current_details.first_name}): ")
    if updated_first_name == "*", do: main_loop(current_user)

    updated_last_name = get_input("Update Last Name (leave blank for no change, '*' to cancel, current: #{current_details.last_name}): ")
    if updated_last_name == "*", do: main_loop(current_user)

    updated_contact_num = get_input("Update Contact (leave blank for no change, '*' to cancel, current: #{current_details.contact}): ")
    if updated_contact_num == "*", do: main_loop(current_user)

    updated_email = get_input("Update Email (leave blank for no change, '*' to cancel, current: #{current_details.email}): ")
    if updated_email == "*", do: main_loop(current_user)

    # Create a new map with updated details, keeping existing if input was blank
    updated_details = %{
      first_name: if(updated_first_name != "", do: updated_first_name, else: current_details.first_name),
      last_name: if(updated_last_name != "", do: updated_last_name, else: current_details.last_name),
      contact: if(updated_contact_num != "", do: updated_contact_num, else: current_details.contact),
      email: if(updated_email != "", do: updated_email, else: current_details.email)
    }

    # Return to the review menu with the updated details
    review_new_contact(updated_details, current_user)
  end

  # Allows the current user to edit an existing contact.
  # It displays the user's contacts, prompts for a contact ID to edit,
  # then allows updating individual fields. Users can type `*` at any prompt
  # to cancel and return to the main menu.
  @spec edit(AddressBookEcto.User.t()) :: no_return
  defp edit(current_user) do
    # Fetch current user's contacts from the database using a query
    user_contacts = AddressBookEcto.Repo.all(from c in AddressBookEcto.Contact, where: c.user_id == ^current_user.id)

    # Check if the user has any contacts
    if Enum.empty?(user_contacts) do
      IO.puts(String.pad_leading(" You have no records ", 50, "#"))
      main_loop(current_user) # Return to the contact management menu
    else
      IO.puts(String.pad_leading(" Edit Contact ", 50, "#"))
      display_contacts(user_contacts) # Display contacts for selection

      # Get the ID to edit from the user (expecting an integer)
      edit_input = get_input("Select the ID from the options above to edit (or type '*' to return to main menu): ")
      if edit_input == "*", do: main_loop(current_user) # Return if '*' entered

      # Attempt to parse the input as an integer
      case Integer.parse(edit_input) do
        {contact_id_to_edit, ""} -> # Successfully parsed as integer
          # Find the contact with the matching ID AND belonging to the current user
          contact_to_edit = AddressBookEcto.Repo.get_by(AddressBookEcto.Contact, id: contact_id_to_edit, user_id: current_user.id)

          case contact_to_edit do
            nil -> # No contact found with that ID for this user
              IO.puts(String.pad_leading("Invalid selection. Please try again.", 50, "#"))
              edit(current_user) # Re-prompt for edit input
            %AddressBookEcto.Contact{} = contact_to_edit -> # Contact found
              IO.puts(String.pad_leading(" You have selected ", 50, "#"))
              display_contact(contact_to_edit) # Display the selected contact

              IO.puts(String.pad_leading(" Update Contact ", 50, "#"))

              # Get updated details, allowing blank input to keep existing value
              updated_first_name = get_input("Update First Name (leave blank for no change, '*' to cancel): ")
              if updated_first_name == "*", do: main_loop(current_user)
              updated_last_name = get_input("Update Last Name (leave blank for no change, '*' to cancel): ")
              if updated_last_name == "*", do: main_loop(current_user)
              updated_contact_num = get_input("Update Contact (leave blank for no change, '*' to cancel): ")
              if updated_contact_num == "*", do: main_loop(current_user)
              updated_email = get_input("Update Email (leave blank for no change, '*' to cancel): ")
              if updated_email == "*", do: main_loop(current_user)

              # Prepare attributes for update, only including fields where input was not blank
              update_attrs = %{}
              update_attrs = if updated_first_name != "", do: Map.put(update_attrs, :first_name, updated_first_name), else: update_attrs
              update_attrs = if updated_last_name != "", do: Map.put(update_attrs, :last_name, updated_last_name), else: update_attrs
              update_attrs = if updated_contact_num != "", do: Map.put(update_attrs, :contact, updated_contact_num), else: update_attrs
              update_attrs = if updated_email != "", do: Map.put(update_attrs, :email, updated_email), else: update_attrs

              # Build a changeset with the update attributes and update the contact in the database
              contact_to_edit
              |> AddressBookEcto.Contact.changeset(update_attrs)
              |> AddressBookEcto.Repo.update()
              |> case do
                {:ok, _updated_contact} -> # Update successful
                  IO.puts(String.pad_leading(" Contact Updated Successfully", 50, "#"))
                  view(current_user) # Display the updated list
                {:error, changeset} -> # Update failed
                  IO.puts(String.pad_leading("An error occurred while saving contact: #{inspect(changeset.errors)}", 50, "#"))
                  main_loop(current_user) # Return to the contact management menu
              end
          end
        _ -> # Input was not a valid integer
          IO.puts(String.pad_leading("Invalid selection. Please try again.", 50, "#"))
          edit(current_user) # Re-prompt for edit input
      end
    end
  end

  # Views and displays all contacts associated with the `current_user`.
  # If the user has no contacts, a message indicating this is displayed.
  @spec view(AddressBookEcto.User.t()) :: no_return
  defp view(current_user) do
    # Fetch current user's contacts from the database
    user_contacts = AddressBookEcto.Repo.all(from c in AddressBookEcto.Contact, where: c.user_id == ^current_user.id)

    # Check if the user has any contacts
    if Enum.empty?(user_contacts) do
      IO.puts(String.pad_leading(" You have no records", 50, "#"))
      main_loop(current_user) # Return to the contact management menu
    else
      IO.puts(String.pad_leading(" All your stored contacts ", 50, "#"))
      display_contacts(user_contacts) # Display the contacts
      main_loop(current_user) # Return to the contact management menu
    end
  end

  # Allows the current user to delete an existing contact.
  # It displays the user's contacts, prompts for a contact ID to delete.
  # Users can type `*` to cancel and return to the main menu.
  @spec delete(AddressBookEcto.User.t()) :: no_return
  defp delete(current_user) do
    # Fetch current user's contacts from the database
    user_contacts = AddressBookEcto.Repo.all(from c in AddressBookEcto.Contact, where: c.user_id == ^current_user.id)

    # Check if the user has any contacts
    if Enum.empty?(user_contacts) do
      IO.puts(String.pad_leading(" You have no records ", 50, "#"))
      main_loop(current_user) # Return to the contact management menu
    else
      IO.puts(String.pad_leading(" Delete contacts ", 50, "#"))
      display_contacts(user_contacts) # Display contacts for selection

      # Get the ID to delete from the user (expecting an integer)
      delete_input = get_input("Select the ID from the options above to delete (or type '*' to return to main menu): ")
      if delete_input == "*", do: main_loop(current_user) # Return if '*' entered

      # Attempt to parse the input as an integer
      case Integer.parse(delete_input) do
        {contact_id_to_delete, ""} -> # Successfully parsed as integer
          # Find the contact with the matching ID AND belonging to the current user
          contact_to_delete = AddressBookEcto.Repo.get_by(AddressBookEcto.Contact, id: contact_id_to_delete, user_id: current_user.id)

          case contact_to_delete do
            nil -> # No contact found with that ID for this user
              IO.puts(String.pad_leading("Invalid selection. Please try again.", 50, "#"))
              delete(current_user) # Re-prompt for delete input
            %AddressBookEcto.Contact{} = contact_to_delete -> # Contact found
              IO.puts(String.pad_leading(" You have selected ", 50, "#"))
              display_contact(contact_to_delete) # Display the selected contact

              # Delete the contact from the database
              AddressBookEcto.Repo.delete(contact_to_delete)
              |> case do
                {:ok, _deleted_contact} -> # Deletion successful
                  IO.puts(String.pad_leading(" Contact Successfully deleted ", 50, "#"))
                  view(current_user) # Display the remaining contacts
                {:error, changeset} -> # Deletion failed
                  IO.puts(String.pad_leading("An error occurred while deleting contact: #{inspect(changeset.errors)}", 50, "#"))
                  main_loop(current_user) # Return to the contact management menu
              end
          end
        _ -> # Input was not a valid integer
          IO.puts(String.pad_leading("Invalid selection. Please try again.", 50, "#"))
          delete(current_user) # Re-prompt for delete input
      end
    end
  end

  # Searches contacts for the current user based on a provided search term.
  # It performs a case-insensitive search across first name, last name, contact number, and email.
  # Users can type `*` to cancel and return to the main menu.
  @spec search(AddressBookEcto.User.t()) :: no_return
  defp search(current_user) do
    IO.puts(String.pad_leading(" Search Contacts ", 50, "#"))

    search_term = get_input("Enter search term (or type '*' to return to main menu): ")
    if search_term == "*", do: main_loop(current_user) # Return if '*' entered

    # Fetch all contacts for the current user
    user_contacts = AddressBookEcto.Repo.all(from c in AddressBookEcto.Contact, where: c.user_id == ^current_user.id)

    # Filter contacts based on the search term (case-insensitive)
    filtered_contacts = Enum.filter(user_contacts, fn contact ->
      String.contains?(String.downcase(contact.first_name), String.downcase(search_term)) ||
      String.contains?(String.downcase(contact.last_name), String.downcase(search_term)) ||
      String.contains?(String.downcase(contact.contact), String.downcase(search_term)) ||
      String.contains?(String.downcase(contact.email), String.downcase(search_term))
    end)

    # Display results
    if Enum.empty?(filtered_contacts) do
      IO.puts(String.pad_leading(" No contacts found matching '#{search_term}'", 50, "#"))
    else
      IO.puts(String.pad_leading(" Search Results for '#{search_term}' ", 50, "#"))
      display_contacts(filtered_contacts)
    end

    main_loop(current_user) # Return to the contact management menu
  end


  # Ends the application session gracefully.
  # This function is called when the user selects to end the session (e.g., by entering '0'
  # in the authentication menu or by reaching end-of-file (Ctrl+D) in input).
  # The process will exit naturally when `IO.gets` receives `:eof` in `main_loop`
  # or the external shell process terminates.
  @spec end_session() :: :ok
  defp end_session do
    IO.puts(String.pad_leading(" Session Ended. Hope to see you soon.", 50, "#"))
    # The process will exit naturally when :eof is received in main_loop
    # or the external shell process terminates.
    # If you needed to explicitly stop the OTP application tree:
    # Application.stop(:address_book_ecto)
    :ok # Return value
  end

  # --- Helper Functions ---

  # Gets input from the user with a given prompt and trims leading/trailing whitespace.
  @spec get_input(String.t()) :: String.t()
  defp get_input(prompt) do
    IO.gets(prompt) |> String.trim()
  end

  # Displays a list of contacts by iterating over them and calling `display_contact/1` for each.
  @spec display_contacts(list(AddressBookEcto.Contact.t())) :: :ok
  defp display_contacts(contacts) do
    Enum.each(contacts, fn contact ->
      display_contact(contact)
      IO.puts("") # Add an empty line between contacts for readability
    end)
  end

  # Displays the details of a single contact, including its database ID.
  @spec display_contact(AddressBookEcto.Contact.t()) :: :ok
  defp display_contact(contact) do
    IO.puts("ID = #{contact.id}") # Display the contact's integer ID
    IO.puts("first_name = #{contact.first_name}")
    IO.puts("last_name = #{contact.last_name}")
    IO.puts("contact = #{contact.contact}")
    IO.puts("email = #{contact.email}")
  end
end
