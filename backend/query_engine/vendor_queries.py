import os
from connection import get_db_connection
from tabulate import tabulate


def clear_screen():
    """Removes old console text for a clean UI."""
    os.system('cls' if os.name == 'nt' else 'clear')


def get_all_vendors():
    """Fetches list of all companies for the selection menu."""
    conn = get_db_connection()
    if not conn: return []
    cursor = None
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT vendor_id, company_name, vendor_type FROM vendor ORDER BY company_name;")
        return cursor.fetchall()
    finally:
        if cursor: cursor.close()
        conn.close()


# ============================================================================
# SECTION 1: SALES & REVENUE (V1, V2)
# ============================================================================

def get_revenue_report(vendor_id, period, breakdown):
    """
    Exhaustive revenue analysis with dynamic period grouping
    (Daily/Weekly/Monthly) and breakdown types.
    """

    conn = get_db_connection()
    if not conn: return
    cursor = None


    try:
        cursor = conn.cursor()

        # Handle Period Logic
        time_col = "DATE(b.booked_at)"
        if period == "Weekly": time_col = "DATE_TRUNC('week', b.booked_at)::DATE"
        elif period == "Monthly": time_col = "DATE_TRUNC('month', b.booked_at)::DATE"
        elif period == "Annual": time_col = "DATE_TRUNC('year', b.booked_at)::DATE"

        # Handle Breakdown logic
        cat_select = " '' "
        if breakdown == "By Service Type": cat_select = " b.booking_type "
        elif breakdown == "By Route/Destination": cat_select = " v_bookings.label "
        elif breakdown == "By Class": cat_select = " v_bookings.label "


        query = f"""
            SELECT 
                {time_col} AS p, 
                COUNT(b.booking_id), 
                SUM(b.final_amount),
                {cat_select} AS detail
            FROM booking b
            JOIN (
                SELECT hb.booking_id, h.hotel_name as label FROM hotel_booking hb JOIN room_category rc ON rc.room_category_id = hb.room_category_id JOIN hotel h ON h.hotel_id = rc.hotel_id WHERE h.vendor_id = %s
                UNION ALL
                SELECT tb.booking_id, tr.origin_city || '->' || tr.destination_city as label FROM transport_booking tb JOIN schedule_departure sd ON sd.departure_id = tb.departure_id JOIN route_schedule rs ON rs.schedule_id = sd.schedule_id JOIN transport_route tr ON tr.route_id = rs.route_id WHERE tr.vendor_id = %s
                UNION ALL
                SELECT pb.booking_id, hp.package_name as label FROM package_booking pb JOIN package_departure pd ON pd.package_departure_id = pb.package_departure_id JOIN holiday_package hp ON hp.package_id = pd.package_id WHERE hp.vendor_id = %s
            ) v_bookings ON v_bookings.booking_id = b.booking_id
            WHERE b.status <> 'cancelled'
            GROUP BY 1, 4
            ORDER BY 1 DESC;
        """


        cursor.execute(query, (vendor_id, vendor_id, vendor_id))
        results = cursor.fetchall()
        

        clear_screen()
        print("\n" + "═"*75)
        print(f"       📈 REVENUE SUMMARY: {period.upper()} | {breakdown.upper()}")
        print("═"*75)


        headers = ["Period", "Count", "Revenue (₹)", "Details"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")


    except Exception as e:
        print(f"⚠️ Error: {e}")


    finally:
        if cursor: cursor.close()
        conn.close()


def get_sales_register(vendor_id):
    """
    Detailed log of every booking: Date, Customer, Type, Status, and Detailed Pricing.
    """

    conn = get_db_connection()
    if not conn: return
    cursor = None


    try:
        cursor = conn.cursor()

        query = """
            SELECT b.booking_id, b.booked_at::DATE, u.full_name, b.booking_type, b.status, b.base_amount, b.discount_amount, b.final_amount, b.payment_method
            FROM booking b
            JOIN "User" u ON u.user_id = b.user_id
            JOIN (
                SELECT hb.booking_id FROM hotel_booking hb JOIN room_category rc ON rc.room_category_id = hb.room_category_id JOIN hotel h ON h.hotel_id = rc.hotel_id WHERE h.vendor_id = %s
                UNION ALL
                SELECT tb.booking_id FROM transport_booking tb JOIN schedule_departure sd ON sd.departure_id = tb.departure_id JOIN route_schedule rs ON rs.schedule_id = sd.schedule_id JOIN transport_route tr ON tr.route_id = rs.route_id WHERE tr.vendor_id = %s
                UNION ALL
                SELECT pb.booking_id FROM package_booking pb JOIN package_departure pd ON pd.package_departure_id = pb.package_departure_id JOIN holiday_package hp ON hp.package_id = pd.package_id WHERE hp.vendor_id = %s
            ) v_bookings ON v_bookings.booking_id = b.booking_id
            ORDER BY b.booked_at DESC;
        """


        cursor.execute(query, (vendor_id, vendor_id, vendor_id))
        results = cursor.fetchall()
        

        clear_screen()
        print(f"\n📜 COMPLETE SALES REGISTER LOG")
        headers = ["ID", "Date", "Customer", "Type", "Status", "Base", "Disc.", "Final", "Method"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")


    except Exception as e:
        print(f"⚠️ Error: {e}")


    finally:
        if cursor: cursor.close()
        conn.close()


# ============================================================================
# SECTION 2: BOOKINGS MANAGEMENT (V3, V4, V5)
# ============================================================================

def get_upcoming_bookings(vendor_id):
    """List of all confirmed future customers with contact info."""

    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        query = f"""
            SELECT b.booking_id, u.full_name || ' (' || u.phone || ')', b.booking_type, 
                   COALESCE(h.hotel_name, tr.origin_city || '->' || tr.destination_city) as service,
                   details.s_date,
                   b.final_amount
            FROM booking b
            JOIN "User" u ON u.user_id = b.user_id
            JOIN (
                SELECT hb.booking_id, hb.checkin_date as s_date, rc.hotel_id as ent_id FROM hotel_booking hb JOIN room_category rc ON rc.room_category_id = hb.room_category_id WHERE hb.checkin_date > CURRENT_DATE
                UNION ALL
                SELECT tb.booking_id, sd.departure_date as s_date, tr.route_id as ent_id FROM transport_booking tb JOIN schedule_departure sd ON sd.departure_id = tb.departure_id JOIN transport_route tr ON tr.route_id = sd.schedule_id WHERE sd.departure_date > CURRENT_DATE
                UNION ALL
                SELECT pb.booking_id, pd.departure_date as s_date, pd.package_id as ent_id FROM package_booking pb JOIN package_departure pd ON pd.package_departure_id = pb.package_departure_id WHERE pd.departure_date > CURRENT_DATE
            ) details ON details.booking_id = b.booking_id
            LEFT JOIN hotel h ON h.hotel_id = details.ent_id
            LEFT JOIN transport_route tr ON tr.route_id = details.ent_id
            WHERE b.status = 'confirmed'
            ORDER BY details.s_date ASC;
        """
        cursor.execute(query)
        results = cursor.fetchall()
        clear_screen()
        print(f"\n🔔 UPCOMING BOOKINGS TO SERVICE")
        headers = ["ID", "Customer (Phone)", "Type", "Service", "Date", "Amount"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()


def get_cancellation_summary(vendor_id, period):
    """Aggregated summary of cancellations and refund obligations."""
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        query = """
            SELECT c.reason, COUNT(*), SUM(c.refund_amount), c.refund_status
            FROM cancellation c
            JOIN booking b ON b.booking_id = c.booking_id
            JOIN (
                SELECT hb.booking_id FROM hotel_booking hb JOIN room_category rc ON rc.room_category_id = hb.room_category_id JOIN hotel h ON h.hotel_id = rc.hotel_id WHERE h.vendor_id = %s
                UNION ALL
                SELECT tb.booking_id FROM transport_booking tb JOIN schedule_departure sd ON sd.departure_id = tb.departure_id JOIN transport_route tr ON tr.route_id = sd.schedule_id WHERE tr.vendor_id = %s
            ) v_bookings ON v_bookings.booking_id = b.booking_id
            GROUP BY c.reason, c.refund_status;
        """
        cursor.execute(query, (vendor_id, vendor_id))
        results = cursor.fetchall()
        clear_screen()
        print(f"\n❌ CANCELLATION SUMMARY: {period.upper()}")
        headers = ["Reason", "Count", "Total Refund", "Status"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()


def get_payment_received(vendor_id):
    """Monthly report of payments received from the platform."""
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        query = """
            SELECT DATE_TRUNC('month', b.booked_at)::DATE, b.booking_type, COUNT(*), SUM(b.final_amount)
            FROM booking b
            JOIN (
                SELECT hb.booking_id FROM hotel_booking hb JOIN room_category rc ON rc.room_category_id = hb.room_category_id JOIN hotel h ON h.hotel_id = rc.hotel_id WHERE h.vendor_id = %s
                UNION ALL
                SELECT tb.booking_id FROM transport_booking tb JOIN schedule_departure sd ON sd.departure_id = tb.departure_id JOIN transport_route tr ON tr.route_id = sd.schedule_id WHERE tr.vendor_id = %s
            ) v_bookings ON v_bookings.booking_id = b.booking_id
            WHERE b.status IN ('confirmed', 'completed')
            GROUP BY 1, 2
            ORDER BY 1 DESC;
        """
        cursor.execute(query, (vendor_id, vendor_id))
        results = cursor.fetchall()
        clear_screen()
        print(f"\n💸 PAYMENTS RECEIVED FROM PLATFORM")
        headers = ["Month", "Type", "Bookings", "Amount"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()


# ============================================================================
# SECTION 3: CUSTOMER MANAGEMENT (V6, V7, V8)
# ============================================================================

def get_customer_list(vendor_id):
    """List of all unique customers who have booked with this vendor."""
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        query = """
            SELECT u.user_id, u.full_name, u.email, u.phone, u.home_city, COUNT(b.booking_id)
            FROM "User" u
            JOIN booking b ON b.user_id = u.user_id
            JOIN (
                SELECT hb.booking_id FROM hotel_booking hb JOIN room_category rc ON rc.room_category_id = hb.room_category_id JOIN hotel h ON h.hotel_id = rc.hotel_id WHERE h.vendor_id = %s
                UNION ALL
                SELECT tb.booking_id FROM transport_booking tb JOIN schedule_departure sd ON sd.departure_id = tb.departure_id JOIN transport_route tr ON tr.route_id = sd.schedule_id WHERE tr.vendor_id = %s
            ) v_bookings ON v_bookings.booking_id = b.booking_id
            GROUP BY u.user_id
            ORDER BY COUNT(b.booking_id) DESC;
        """
        cursor.execute(query, (vendor_id, vendor_id))
        results = cursor.fetchall()
        clear_screen()
        print(f"\n👥 YOUR CUSTOMER DATABASE")
        headers = ["ID", "Name", "Email", "Phone", "City", "Total Bookings"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()


def get_customer_history(vendor_id, user_id):
    """Full booking history for a specific customer with THIS vendor."""
    get_my_bookings_for_vendor(vendor_id, user_id) # Call actual detailed logic


def get_my_bookings_for_vendor(vendor_id, user_id):
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        query = """
            SELECT b.booking_id, b.booking_type, b.status, 
                   CASE b.booking_type WHEN 'hotel' THEN h.hotel_name WHEN 'transport' THEN tr.origin_city || '->' || tr.destination_city END,
                   b.booked_at::DATE, b.final_amount
            FROM booking b
            JOIN (
                SELECT hb.booking_id, h.hotel_id FROM hotel_booking hb JOIN room_category rc ON rc.room_category_id = hb.room_category_id JOIN hotel h ON h.hotel_id = rc.hotel_id WHERE h.vendor_id = %s
                UNION ALL
                SELECT tb.booking_id, tr.route_id FROM transport_booking tb JOIN schedule_departure sd ON sd.departure_id = tb.departure_id JOIN transport_route tr ON tr.route_id = sd.schedule_id WHERE tr.vendor_id = %s
            ) v_bookings ON v_bookings.booking_id = b.booking_id
            LEFT JOIN hotel h ON h.hotel_id = v_bookings.hotel_id
            LEFT JOIN transport_route tr ON tr.route_id = v_bookings.hotel_id
            WHERE b.user_id = %s
            ORDER BY b.booked_at DESC;
        """
        cursor.execute(query, (vendor_id, vendor_id, user_id))
        results = cursor.fetchall()
        clear_screen()
        print(f"\n📖 CUSTOMER BOOKING HISTORY (User #{user_id})")
        headers = ["ID", "Type", "Status", "Service", "Date", "Amount"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()


def get_poor_ratings(vendor_id):
    """Aggregated bad feedback (1-2 stars) for vendor analysis."""
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        query = """
            SELECT u.full_name, u.email, r.entity_type, r.entity_id, r.star_rating, r.title, r.comment, r.reviewed_at::DATE
            FROM review r
            JOIN "User" u ON u.user_id = r.user_id
            WHERE r.star_rating <= 2
              AND (
                (r.entity_type = 'hotel' AND r.entity_id IN (SELECT hotel_id FROM hotel WHERE vendor_id = %s))
                OR
                (r.entity_type = 'transport' AND r.entity_id IN (SELECT route_id FROM transport_route WHERE vendor_id = %s))
              )
            ORDER BY r.reviewed_at DESC;
        """
        cursor.execute(query, (vendor_id, vendor_id))
        results = cursor.fetchall()
        clear_screen()
        print(f"\n⚠️ POOR RATINGS FEEDBACK")
        headers = ["User", "Email", "Type", "ID", "Stars", "Title", "Comment", "Date"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()
def get_service_demand(vendor_id):
    """Identifies and tags high-demand services based on seat availability."""
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        query = """
            SELECT 
                'transport' as type, 
                tr.vehicle_number || ' (' || tr.origin_city || '-' || tr.destination_city || ')' as name,
                sc.total_seats as capacity,
                sd.available_seats,
                ROUND((1 - (sd.available_seats::DECIMAL / sc.total_seats)) * 100, 1) as fill_rate
            FROM transport_route tr
            JOIN route_schedule rs ON rs.route_id = tr.route_id
            JOIN schedule_departure sd ON sd.schedule_id = rs.schedule_id
            JOIN schedule_class sc ON sc.class_id = sd.class_id
            WHERE tr.vendor_id = %s AND sd.departure_date > CURRENT_DATE
            UNION ALL
            SELECT 
                'hotel' as type,
                h.hotel_name || ' (' || rc.category_name || ')' as name,
                rc.total_rooms as capacity,
                ra.available_rooms,
                ROUND((1 - (ra.available_rooms::DECIMAL / rc.total_rooms)) * 100, 1) as fill_rate
            FROM hotel h
            JOIN room_category rc ON rc.hotel_id = h.hotel_id
            JOIN room_availability ra ON ra.room_category_id = rc.room_category_id
            WHERE h.vendor_id = %s AND ra.available_date > CURRENT_DATE;
        """
        cursor.execute(query, (vendor_id, vendor_id))
        results = cursor.fetchall()
        
        # Adding dynamic tags based on the fill rate business logic
        tagged_results = []
        for row in results:
            fill = float(row[4])
            tag = "NORMAL"
            if fill > 95: tag = "🔥 LOW AVAILABILITY"
            elif fill > 80: tag = "🚀 HIGH DEMAND"
            elif fill > 60: tag = "⏳ FILLING FAST"
            tagged_results.append(row + (tag,))

        clear_screen()
        print(f"\n📊 DYNAMIC SERVICE DEMAND INSIGHTS")
        headers = ["Type", "Service Name", "Cap.", "Avail.", "Fill %", "DEMAND TAG"]
        print(tabulate(tagged_results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter to return...")
    finally:
        if cursor: cursor.close()
        conn.close()
