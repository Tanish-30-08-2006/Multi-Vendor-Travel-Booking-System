import questionary
from questionary import Style

# 1. Importing all the query functions from our engine
from query_engine.vendor_queries import (
    get_all_vendors,
    get_revenue_report,
    get_sales_register,
    get_upcoming_bookings,
    get_cancellation_summary,
    get_payment_received,
    get_customer_list,
    get_customer_history,
    get_poor_ratings,
    get_service_demand
)

# Premium UI Style
vendor_style = Style([
    ('qmark', 'fg:#E040FB bold'),
    ('question', 'bold'),
    ('answer', 'fg:#f1c40f bold'),
    ('pointer', 'fg:#E040FB bold'),
    ('highlighted', 'fg:#E040FB bold'),
    ('separator', 'fg:#666666'),
])


def vendor_menu():
    """
    Exhaustive Vendor Portal with hierarchical menus for Sales, 
    Bookings, and Customer Management.
    """

    # --- STEP 1: VENDOR SELECTION ---
    try:
        vendors = get_all_vendors()
        if not vendors:
            print("\n❌ No Vendors found in database.")
            input("\n   Press Enter to return...")
            return

        # Create a nice selection list: "Company Name (Type)"
        vendor_choices = [f"{v[1]} ({v[2]}) | ID: {v[0]}" for v in vendors]
        vendor_pick = questionary.select(
            "Which company Dashboard are you entering?", 
            choices=vendor_choices, 
            style=vendor_style
        ).ask()

        if not vendor_pick: return
        
        # Extract the ID from the selected string
        v_id = int(vendor_pick.split("| ID: ")[1])
        v_name = vendor_pick.split(" (")[0]
    except Exception as e:
        print(f"⚠️ Vendor Login Error: {e}")
        input("\n   Press Enter...")
        return


    # --- STEP 2: MAIN DASHBOARD LOOP ---
    while True:
        print("\n" + "═"*65)
        print(f"           🏢 {v_name.upper()} — VENDOR DASHBOARD")
        print("═"*65)

        section = questionary.select(
            "Select Dashboard Section:",
            choices=[
                "💰 SALES & REVENUE",
                "🎫 BOOKINGS",
                "👤 CUSTOMERS",
                "📈 DEMAND INSIGHTS",
                "⬅️  Back to Main Menu"
            ],
            style=vendor_style
        ).ask()

        if section == "⬅️  Back to Main Menu" or section is None:
            break


        # --------------------------------------------------------------------
        # SECTION A: SALES & REVENUE
        # --------------------------------------------------------------------

        if section == "💰 SALES & REVENUE":
            sub_choice = questionary.select(
                "Sales Options:",
                choices=["📈 Revenue Summary", "📜 Sales Register", "🔙 Back"],
                style=vendor_style
            ).ask()

            if sub_choice == "📈 Revenue Summary":
                period = questionary.select(
                    "Select Time Period:", 
                    choices=["Daily", "Weekly", "Monthly", "Annual"], 
                    style=vendor_style
                ).ask()
                
                breakdown = questionary.select(
                    "Select Breakdown Type:", 
                    choices=["Overall", "By Service Type", "By Route/Destination", "By Class"], 
                    style=vendor_style
                ).ask()
                
                get_revenue_report(v_id, period, breakdown)

            elif sub_choice == "📜 Sales Register":
                get_sales_register(v_id)


        # --------------------------------------------------------------------
        # SECTION B: BOOKING MANAGEMENT
        # --------------------------------------------------------------------

        elif section == "🎫 BOOKINGS":
            sub_choice = questionary.select(
                "Booking Options:",
                choices=[
                    "🔔 Upcoming Bookings to Service", 
                    "❌ Cancellation Summary", 
                    "💸 Payment Received from Platform", 
                    "🔙 Back"
                ],
                style=vendor_style
            ).ask()

            if sub_choice == "🔔 Upcoming Bookings to Service":
                get_upcoming_bookings(v_id)

            elif sub_choice == "❌ Cancellation Summary":
                period = questionary.select(
                    "Select Period:", 
                    choices=["This Year", "Last 6 Months", "All Time"], 
                    style=vendor_style
                ).ask()
                get_cancellation_summary(v_id, period)

            elif sub_choice == "💸 Payment Received from Platform":
                get_payment_received(v_id)


        # --------------------------------------------------------------------
        # SECTION C: CUSTOMER RELATIONSHIP MANAGEMENT
        # --------------------------------------------------------------------

        elif section == "👤 CUSTOMERS":
            sub_choice = questionary.select(
                "Customer Options:",
                choices=[
                    "👨‍👩‍👧‍👦 Customer List", 
                    "📖 History of Specific Customer", 
                    "⭐ Poor Ratings (1–2 Stars)", 
                    "🔙 Back"
                ],
                style=vendor_style
            ).ask()

            if sub_choice == "👨‍👩‍👧‍👦 Customer List":
                get_customer_list(v_id)

            elif sub_choice == "📖 History of Specific Customer":
                try:
                    cid_str = input("\n👤 Enter Customer User ID: ")
                    if cid_str:
                        cid = int(cid_str)
                        get_customer_history(v_id, cid)
                except ValueError:
                    print("\n   ⚠️  Invalid ID. Please enter a numeric User ID.")
                    input("\n   Press Enter to continue...")

            elif sub_choice == "⭐ Poor Ratings (1–2 Stars)":
                get_poor_ratings(v_id)


        # --------------------------------------------------------------------
        # SECTION D: DEMAND INSIGHTS
        # --------------------------------------------------------------------

        elif section == "📈 DEMAND INSIGHTS":
            get_service_demand(v_id)


def get_customer_list_raw(vendor_id):
    """Helper to return raw user data for selection."""
    from connection import get_db_connection
    conn = get_db_connection()
    if not conn: return []
    cursor = None
    try:
        cursor = conn.cursor()
        query = """
            SELECT DISTINCT u.user_id, u.full_name
            FROM "User" u
            JOIN booking b ON b.user_id = u.user_id
            JOIN (
                SELECT hb.booking_id FROM hotel_booking hb JOIN room_category rc ON rc.room_category_id = hb.room_category_id JOIN hotel h ON h.hotel_id = rc.hotel_id WHERE h.vendor_id = %s
                UNION ALL
                SELECT tb.booking_id FROM transport_booking tb JOIN schedule_departure sd ON sd.departure_id = tb.departure_id JOIN transport_route tr ON tr.route_id = sd.schedule_id WHERE tr.vendor_id = %s
            ) v ON v.booking_id = b.booking_id;
        """
        cursor.execute(query, (vendor_id, vendor_id))
        return cursor.fetchall()
    finally:
        if cursor: cursor.close()
        conn.close()
