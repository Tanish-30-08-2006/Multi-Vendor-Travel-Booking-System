import questionary
from questionary import Style


from menus.guest_menu import guest_menu
from menus.traveller_menu import traveller_menu
from menus.vendor_menu import vendor_menu
from menus.admin_menu import admin_menu

# 1. We create a "Premium" look for the console
custom_style = Style([
    ('qmark', 'fg:#FF9D00 bold'),       # question mark color
    ('question', 'bold'),               # question text
    ('answer', 'fg:#007bff bold'),      # submitted answer color
    ('pointer', 'fg:#61afef bold'),     # pointer color
    ('highlighted', 'fg:#61afef bold'), # highlighted item
    ('instruction', ''),                # hint text
])

def main_menu():
    print("\n" + "="*60)
    print("        WELCOME TO THE TRAVEL PLATFORM — MAIN MENU")
    print("="*60)

    # 2. This creates the selectable list
    choice = questionary.select(
        "Which Portal do you want to access?",
        choices=[
            "→ Guest Portal",
            "→ Traveller Portal",
            "→ Vendor Portal",
            "→ Admin Portal",
            "→ Exit"
        ],
        style=custom_style
    ).ask()

    # 3. Routing the choice
    if choice == "→ Guest Portal":
        print("Opening Guest Portal...")
        guest_menu()
    elif choice == "→ Traveller Portal":
        print("Opening Traveller Portal...")
        traveller_menu()
    elif choice == "→ Vendor Portal":
        print("Opening Vendor Portal...")
        vendor_menu()
    elif choice == "→ Admin Portal":
        print("Opening Admin Portal...")
        admin_menu()
    elif choice == "→ Exit":
        print("Thank you for using our platform.")
        exit()

if __name__ == "__main__":
    while True: # This keeps the app running until the user clicks Exit
        main_menu()




