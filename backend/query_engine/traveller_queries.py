import os
from connection import get_db_connection
from tabulate import tabulate


def clear_screen():
    """Removes old console text for a clean UI."""
    os.system('cls' if os.name == 'nt' else 'clear')


def get_all_users():
    """Helper to fetch all registered users for selection."""
    conn = get_db_connection()
    if not conn: return []
    cursor = None
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT user_id, full_name || ' (ID: ' || user_id || ')' FROM \"User\" ORDER BY full_name;")
        return cursor.fetchall()
    finally:
        if cursor: cursor.close()
        conn.close()


# ----------------------------------------------------------------------------
# 1. MY BOOKINGS (T1)
# ----------------------------------------------------------------------------

def get_my_bookings(user_id):
    """
    Exhaustive list of all bookings including service description,
    travel date, status, amount, and payment method.
    """

    conn = get_db_connection()
    if not conn: return
    cursor = None


    try:
        cursor = conn.cursor()

        query = """
            SELECT 
                b.booking_id, 
                b.booking_type, 
                CASE b.booking_type
                    WHEN 'transport' THEN tr.origin_city || ' -> ' || tr.destination_city
                    WHEN 'hotel'     THEN h.hotel_name
                    WHEN 'package'   THEN hp.package_name
                END AS service,
                CASE b.booking_type
                    WHEN 'transport' THEN sd.departure_date::TEXT
                    WHEN 'hotel'     THEN hb.checkin_date::TEXT
                    WHEN 'package'   THEN pd.departure_date::TEXT
                END AS travel_date,
                b.status, 
                b.final_amount,
                b.payment_method
            FROM booking b
            LEFT JOIN transport_booking tb ON tb.booking_id = b.booking_id
            LEFT JOIN schedule_departure sd ON sd.departure_id = tb.departure_id
            LEFT JOIN route_schedule rs ON rs.schedule_id = sd.schedule_id
            LEFT JOIN transport_route tr ON tr.route_id = rs.route_id
            LEFT JOIN hotel_booking hb ON hb.booking_id = b.booking_id
            LEFT JOIN room_category rc ON rc.room_category_id = hb.room_category_id
            LEFT JOIN hotel h ON h.hotel_id = rc.hotel_id
            LEFT JOIN package_booking pb ON pb.booking_id = b.booking_id
            LEFT JOIN package_departure pd ON pd.package_departure_id = pb.package_departure_id
            LEFT JOIN holiday_package hp ON hp.package_id = pd.package_id
            WHERE b.user_id = %s
            ORDER BY travel_date DESC;
        """


        cursor.execute(query, (user_id,))
        results = cursor.fetchall()
        

        clear_screen()
        print(f"\n📜 COMPLETE BOOKING HISTORY (User #{user_id})")


        if not results:
            print("\n   ⚠️  No bookings found.")
        else:
            headers = ["ID", "Type", "Service Description", "Travel Date", "Status", "Amount", "Paid Via"]
            print(tabulate(results, headers=headers, tablefmt="rounded_grid"))


        input("\nPress Enter to return...")


    except Exception as e:
        print(f"⚠️ Bookings Fetch Error: {e}")


    finally:
        if cursor: cursor.close()
        conn.close()


# ----------------------------------------------------------------------------
# 2. UPCOMING TRIPS (T2)
# ----------------------------------------------------------------------------

def get_upcoming_trips(user_id):
    """
    Filters for confirmed future trips only across all service types.
    """

    conn = get_db_connection()
    if not conn: return
    cursor = None


    try:
        cursor = conn.cursor()

        query = """
            SELECT 
                CASE b.booking_type
                    WHEN 'transport' THEN tr.origin_city || ' -> ' || tr.destination_city
                    WHEN 'hotel'     THEN h.hotel_name
                    WHEN 'package'   THEN hp.package_name
                END AS service,
                CASE b.booking_type
                    WHEN 'transport' THEN sd.departure_date::TEXT
                    WHEN 'hotel'     THEN hb.checkin_date::TEXT
                    WHEN 'package'   THEN pd.departure_date::TEXT
                END AS travel_date,
                b.final_amount
            FROM booking b
            LEFT JOIN transport_booking tb ON tb.booking_id = b.booking_id
            LEFT JOIN schedule_departure sd ON sd.departure_id = tb.departure_id
            LEFT JOIN route_schedule rs ON rs.schedule_id = sd.schedule_id
            LEFT JOIN transport_route tr ON tr.route_id = rs.route_id
            LEFT JOIN hotel_booking hb ON hb.booking_id = b.booking_id
            LEFT JOIN room_category rc ON rc.room_category_id = hb.room_category_id
            LEFT JOIN hotel h ON h.hotel_id = rc.hotel_id
            LEFT JOIN package_booking pb ON pb.booking_id = b.booking_id
            LEFT JOIN package_departure pd ON pd.package_departure_id = pb.package_departure_id
            LEFT JOIN holiday_package hp ON hp.package_id = pd.package_id
            WHERE b.user_id = %s 
              AND b.status = 'confirmed'
              AND (
                CASE b.booking_type
                    WHEN 'transport' THEN sd.departure_date
                    WHEN 'hotel'     THEN hb.checkin_date
                    WHEN 'package'   THEN pd.departure_date
                END > CURRENT_DATE
              )
            ORDER BY travel_date ASC;
        """


        cursor.execute(query, (user_id,))
        results = cursor.fetchall()
        

        clear_screen()
        print(f"\n📅 UPCOMING CONFIRMED TRIPS (User #{user_id})")


        if not results:
            print("\n   ✅ No upcoming confirmed trips found.")
        else:
            headers = ["Service", "Travel Date", "Amount (₹)"]
            print(tabulate(results, headers=headers, tablefmt="rounded_grid"))


        input("\nPress Enter to return...")


    except Exception as e:
        print(f"⚠️ Error: {e}")


    finally:
        if cursor: cursor.close()
        conn.close()


# ----------------------------------------------------------------------------
# 3. MY CANCELLATIONS & REFUND STATUS (T3)
# ----------------------------------------------------------------------------

def get_my_cancellations(user_id):
    """
    Detailed log of all cancellations: ID, Reason, Refund, and Status.
    """

    conn = get_db_connection()
    if not conn: return
    cursor = None


    try:
        cursor = conn.cursor()

        query = """
            SELECT 
                c.cancellation_id, 
                b.booking_id, 
                b.booking_type, 
                c.reason, 
                c.cancelled_at::DATE,
                c.refund_amount, 
                c.refund_status
            FROM cancellation c
            JOIN booking b ON b.booking_id = c.booking_id
            WHERE b.user_id = %s
            ORDER BY c.cancelled_at DESC;
        """


        cursor.execute(query, (user_id,))
        results = cursor.fetchall()
        

        clear_screen()
        print(f"\n❌ YOUR CANCELLATIONS & REFUND STATUS (User #{user_id})")


        if not results:
            print("\n   No cancelled bookings found.")
        else:
            headers = ["Cancel ID", "Booking ID", "Type", "Reason", "Cancelled At", "Refund (₹)", "Status"]
            print(tabulate(results, headers=headers, tablefmt="rounded_grid"))


        input("\nPress Enter to return...")


    except Exception as e:
        print(f"⚠️ Error: {e}")


    finally:
        if cursor: cursor.close()
        conn.close()


# ----------------------------------------------------------------------------
# 4. MY INSURANCE (T4)
# ----------------------------------------------------------------------------

def get_my_insurance(user_id):
    """
    Exhaustive list of all insurance policies linked to bookings.
    """

    conn = get_db_connection()
    if not conn: return
    cursor = None


    try:
        cursor = conn.cursor()

        query = """
            SELECT 
                b.booking_id, 
                b.booking_type,
                i.provider_name, 
                i.plan_name, 
                i.coverage_summary,
                i.premium_amount,
                i.valid_to::DATE,
                i.claim_status
            FROM booking_insurance bi
            JOIN booking b ON b.booking_id = bi.booking_id
            JOIN insurance i ON i.insurance_id = bi.insurance_id
            WHERE b.user_id = %s
            ORDER BY b.booking_id;
        """


        cursor.execute(query, (user_id,))
        results = cursor.fetchall()
        

        clear_screen()
        print(f"\n🛡️  MY INSURANCE POLICIES (User #{user_id})")


        if not results:
            print("\n   No insurance found for your bookings.")
        else:
            headers = ["Booking ID", "Type", "Provider", "Plan", "Coverage", "Premium", "Valid Until", "Status"]
            print(tabulate(results, headers=headers, tablefmt="rounded_grid"))


        input("\nPress Enter to return...")


    except Exception as e:
        print(f"⚠️ Error: {e}")


    finally:
        if cursor: cursor.close()
        conn.close()


# ----------------------------------------------------------------------------
# 5. MY SPENDING SUMMARY (T5)
# ----------------------------------------------------------------------------

def get_spending_summary(user_id, period):
    """
    Financial summary: spending totals grouped by service type
    with customizable time filtering based on the portal layout.
    """

    conn = get_db_connection()
    if not conn: return
    cursor = None


    try:
        cursor = conn.cursor()

        # Handle Period Filtering
        time_clause = ""
        if period == "This Year (2026)":
            time_clause = "AND EXTRACT(YEAR FROM b.booked_at) = 2026"
        elif period == "Last 6 Months":
            time_clause = "AND b.booked_at >= CURRENT_DATE - INTERVAL '6 months'"


        query = f"""
            SELECT 
                b.booking_type AS service, 
                COUNT(*) AS bookings, 
                SUM(b.final_amount) AS spent, 
                SUM(b.discount_amount) AS saved
            FROM booking b
            WHERE b.user_id = %s AND b.status <> 'cancelled'
            {time_clause}
            GROUP BY b.booking_type
            ORDER BY spent DESC;
        """


        cursor.execute(query, (user_id,))
        results = cursor.fetchall()
        

        clear_screen()
        print("\n" + "═"*65)
        print(f"           📊 SPENDING SUMMARY: {period.upper()}")
        print("═"*65)


        if not results:
            print("\n   No spending recorded for this period.")
        else:
            headers = ["Service Type", "Bookings", "Total Spent (₹)", "Total Saved (₹)"]
            print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
            
            total_sum = sum(row[2] for row in results)
            print("-" * 65)
            print(f"   💰 GRAND TOTAL SPENT: ₹{total_sum:,.2f}")
            print("-" * 65)


        input("\nPress Enter to return...")


    except Exception as e:
        print(f"⚠️ Error: {e}")


    finally:
        if cursor: cursor.close()
        conn.close()
