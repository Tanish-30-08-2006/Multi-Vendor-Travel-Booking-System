import questionary
from questionary import Style

# 1. Importing all the query functions from our engine
from query_engine.guest_queries import (
    search_transport, 
    search_hotels, 
    browse_packages, 
    compare_transport_prices
)

# Premium UI Style
guest_style = Style([
    ('qmark', 'fg:#FF9D00 bold'),
    ('question', 'bold'),
    ('answer', 'fg:#27ae60 bold'),
    ('pointer', 'fg:#27ae60 bold'),
    ('highlighted', 'fg:#27ae60 bold'),
])


def guest_menu():
    """
    Exhaustive Guest Portal menu with multi-step nested filtering 
    exactly as requested.
    """

    while True: 
        print("\n" + "-"*65)
        print("           🌍 TRAVEL PLATFORM — GUEST EXPLORER")
        print("-"*65)

        choice = questionary.select(
            "What would you like to explore?",
            choices=[
                "🔍 Search Transport",
                "🏨 Search Hotels",
                "🌴 Browse Holiday Packages",
                "⚖️  Compare Prices for a Route",
                "⬅️  Back to Main Menu"
            ],
            style=guest_style
        ).ask()


        # --------------------------------------------------------------------
        # OPTION 1: DETAILED TRANSPORT SEARCH
        # --------------------------------------------------------------------

        if choice == "🔍 Search Transport":
            print("\n--- Search Transport ---")
            src = input("Enter Source City: ")
            dest = input("Enter Destination City: ")
            date = input("Enter Date (YYYY-MM-DD): ")
            
            mode = questionary.select(
                "Select Transport Mode:",
                choices=["All Modes", "Flight", "Train", "Bus"],
                style=guest_style
            ).ask()

            t_class = questionary.select(
                "Select Class:",
                choices=["All Classes", "Economy", "Sleeper", "AC First Class", "Business", "Premium Economy"],
                style=guest_style
            ).ask()

            search_transport(src, dest, date, mode, t_class)


        # --------------------------------------------------------------------
        # OPTION 2: DETAILED HOTEL SEARCH
        # --------------------------------------------------------------------

        elif choice == "🏨 Search Hotels":
            print("\n--- Search Hotels ---")
            city = input("Enter City: ")
            date = input("Enter Check-in Date (YYYY-MM-DD): ")
            
            stars = questionary.select(
                "Select Min Star Rating:",
                choices=["Any", "1.0 Stars", "2.0 Stars", "3.0 Stars", "4.0 Stars", "5.0 Stars"],
                style=guest_style
            ).ask()

            price_range = questionary.select(
                "Select Price Range:",
                choices=["Any", "Under ₹3,000/night", "₹3,000–₹8,000/night", "₹8,000–₹15,000/night", "Above ₹15,000/night"],
                style=guest_style
            ).ask()

            search_hotels(city, date, stars, price_range)


        # --------------------------------------------------------------------
        # OPTION 3: DETAILED HOLIDAY PACKAGES
        # --------------------------------------------------------------------

        elif choice == "🌴 Browse Holiday Packages":
            print("\n--- Browse Holiday Packages ---")
            
            theme = questionary.select(
                "Filter by Theme:",
                choices=["All Themes", "Adventure", "Leisure", "Relaxation", "Cultural", "Honeymoon", "Nature", "Spiritual"],
                style=guest_style
            ).ask()

            duration = questionary.select(
                "Filter by Duration:",
                choices=["Any", "1–3 days", "4–5 days", "6–8 days", "8+ days"],
                style=guest_style
            ).ask()

            price = questionary.select(
                "Filter by Price (Per Person):",
                choices=["Any", "Under ₹12,000", "₹12,000–₹20,000", "₹20,000–₹30,000", "Above ₹30,000"],
                style=guest_style
            ).ask()

            browse_packages(theme, duration, price)


        # --------------------------------------------------------------------
        # OPTION 4: SIDE-BY-SIDE COMPARISON
        # --------------------------------------------------------------------

        elif choice == "⚖️  Compare Prices for a Route":
            print("\n--- Compare Across All Vendors ---")
            src = input("Enter Source City: ")
            dest = input("Enter Destination City: ")
            date = input("Enter Date (YYYY-MM-DD): ")
            compare_transport_prices(src, dest, date)


        # --------------------------------------------------------------------
        # OPTION 5: EXIT
        # --------------------------------------------------------------------

        elif choice == "⬅️  Back to Main Menu":
            break
