import questionary
from questionary import Style

# 1. Importing all the query functions from our engine
from query_engine.traveller_queries import (
    get_all_users,
    get_my_bookings, 
    get_upcoming_trips, 
    get_my_cancellations, 
    get_my_insurance,
    get_spending_summary
)

# Premium UI Style
traveller_style = Style([
    ('qmark', 'fg:#00E5FF bold'),
    ('question', 'bold'),
    ('answer', 'fg:#00E5FF bold'),
    ('pointer', 'fg:#00E5FF bold'),
    ('highlighted', 'fg:#00E5FF bold'),
])


def traveller_menu():
    """
    Exhaustive Traveller Portal which starts with a User Selection list
    with added robustness for empty databases and navigation.
    """

    # --- STEP 1: USER SELECTION ---
    try:
        users = get_all_users()
        if not users:
            print("\n❌ No Users found in your database. Please run insert scripts.")
            input("\n   Press Enter to return...")
            return

        # Prepare selection list: "Full Name (ID: X)"
        user_choices = [u[1] for u in users]
        user_pick = questionary.select(
            "Who is accessing the portal?", 
            choices=user_choices, 
            style=traveller_style
        ).ask()

        if not user_pick: return

        # Extract ID from string "(ID: 5)"
        user_id = int(user_pick.split("(ID: ")[1].replace(")", ""))
    except Exception as e:
        print(f"⚠️ Login Error: {e}")
        input("\n   Press Enter...")
        return


    # --- STEP 2: MAIN DASHBOARD LOOP ---
    while True:
        print("\n" + "═"*65)
        print(f"           💼 TRAVELLER DASHBOARD: {user_pick.upper()}")
        print("═"*65)

        choice = questionary.select(
            "Select an option to view:",
            choices=[
                "📜 My Bookings (Full History)",
                "📅 Upcoming Trips",
                "❌ My Cancellations & Refunds",
                "🛡️  My Insurance",
                "📊 My Spending Summary",
                "⬅️  Back to Main Menu"
            ],
            style=traveller_style
        ).ask()

        if choice == "⬅️  Back to Main Menu" or choice is None:
            break


        # 1. Full Bookings History
        if choice == "📜 My Bookings (Full History)":
            get_my_bookings(user_id)
        

        # 2. Future Confirmations
        elif choice == "📅 Upcoming Trips":
            get_upcoming_trips(user_id)


        # 3. Detailed Cancellation Log
        elif choice == "❌ My Cancellations & Refunds":
            get_my_cancellations(user_id)
    

        # 4. Comprehensive Insurance List
        elif choice == "🛡️  My Insurance":
            get_my_insurance(user_id)
        

        # 5. Financial Reports
        elif choice == "📊 My Spending Summary":
            period = questionary.select(
                "Select Summary Period:",
                choices=["This Year (2026)", "Last 6 Months", "All Time"],
                style=traveller_style
            ).ask()
            
            if period:
                get_spending_summary(user_id, period)