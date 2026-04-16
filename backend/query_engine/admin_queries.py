import os
from connection import get_db_connection
from tabulate import tabulate


def clear_screen():
    """Removes old console text for a clean UI."""
    os.system('cls' if os.name == 'nt' else 'clear')


# ============================================================================
# SECTION 1: REVENUE & FINANCIALS
# ============================================================================

def get_platform_revenue(period, breakdown):
    """
    Exhaustive platform-wide revenue report with discounts and net calculation.
    """

    conn = get_db_connection()
    if not conn: return
    cursor = None


    try:
        cursor = conn.cursor()

        # Handle Period logic
        time_col = "DATE(b.booked_at)"
        if period == "Weekly": time_col = "DATE_TRUNC('week', b.booked_at)::DATE"
        elif period == "Monthly": time_col = "DATE_TRUNC('month', b.booked_at)::DATE"
        elif period == "Annual": time_col = "DATE_TRUNC('year', b.booked_at)::DATE"

        # Handle Breakdown logic
        cat_select = " '' "
        extra_join = ""
        
        if breakdown == "By Vendor":
            cat_select = " v.company_name "
            extra_join = """
                JOIN (
                    SELECT hb.booking_id, h.vendor_id FROM hotel_booking hb JOIN room_category rc ON rc.room_category_id = hb.room_category_id JOIN hotel h ON h.hotel_id = rc.hotel_id
                    UNION ALL
                    SELECT tb.booking_id, tr.vendor_id FROM transport_booking tb JOIN schedule_departure sd ON sd.departure_id = tb.departure_id JOIN transport_route tr ON tr.route_id = sd.schedule_id
                ) details ON details.booking_id = b.booking_id
                JOIN vendor v ON v.vendor_id = details.vendor_id
            """
        elif breakdown == "By Service Type":
            cat_select = " b.booking_type "
        elif breakdown == "By Destination":
            cat_select = " details.dest "
            extra_join = """
                JOIN (
                    SELECT hb.booking_id, h.city as dest FROM hotel_booking hb JOIN room_category rc ON rc.room_category_id = hb.room_category_id JOIN hotel h ON h.hotel_id = rc.hotel_id
                    UNION ALL
                    SELECT tb.booking_id, tr.destination_city as dest FROM transport_booking tb JOIN schedule_departure sd ON sd.departure_id = tb.departure_id JOIN transport_route tr ON tr.route_id = sd.schedule_id
                ) details ON details.booking_id = b.booking_id
            """


        query = f"""
            SELECT 
                {time_col} AS p, 
                COUNT(*), 
                SUM(b.base_amount), 
                SUM(b.discount_amount), 
                SUM(b.final_amount),
                {cat_select}
            FROM booking b
            {extra_join}
            WHERE b.status <> 'cancelled'
            GROUP BY 1, 6
            ORDER BY 1 DESC;
        """


        cursor.execute(query)
        results = cursor.fetchall()


        clear_screen()
        print("\n" + "═"*95)
        print(f"       🏦 PLATFORM REVENUE SUMMARY: {period.upper()} | {breakdown.upper()}")
        print("═"*95)


        headers = ["Period", "Bookings", "Gross Amt.", "Discounts", "Net Revenue", "Category"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\n   Press Enter to return...")


    except Exception as e:
        print(f"⚠️ Revenue Error: {e}")
    finally:
        if cursor: cursor.close()
        conn.close()


def get_vendor_ledger(vendor_id):
    """Detailed financial log for a specific vendor."""
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        query = """
            SELECT b.booking_id, b.booked_at::DATE, b.booking_type, b.status, b.base_amount, b.discount_amount, b.final_amount, b.payment_method
            FROM booking b
            JOIN (
                SELECT hb.booking_id FROM hotel_booking hb JOIN room_category rc ON rc.room_category_id = hb.room_category_id JOIN hotel h ON h.hotel_id = rc.hotel_id WHERE h.vendor_id = %s
                UNION ALL
                SELECT tb.booking_id FROM transport_booking tb JOIN schedule_departure sd ON sd.departure_id = tb.departure_id JOIN transport_route tr ON tr.route_id = sd.schedule_id WHERE tr.vendor_id = %s
            ) v_bookings ON v_bookings.booking_id = b.booking_id
            ORDER BY b.booked_at DESC;
        """
        cursor.execute(query, (vendor_id, vendor_id))
        results = cursor.fetchall()
        clear_screen()
        print(f"\n🏢 VENDOR FINANCIAL LEDGER: VENDOR #{vendor_id}")
        headers = ["Booking ID", "Date", "Type", "Status", "Base", "Disc", "Final", "Method"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()


# ============================================================================
# SECTION 2: OPERATIONAL MANAGEMENT
# ============================================================================

def get_pending_refunds():
    """List of all cancellations that require admin refund processing."""
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        query = """
            SELECT c.cancellation_id, b.booking_id, u.full_name || ' (' || u.email || ')', b.booking_type, c.reason, c.cancelled_at::DATE, c.refund_amount, c.refund_status
            FROM cancellation c
            JOIN booking b ON b.booking_id = c.booking_id
            JOIN "User" u ON u.user_id = b.user_id
            WHERE c.refund_status = 'pending'
            ORDER BY c.cancelled_at ASC;
        """
        cursor.execute(query)
        results = cursor.fetchall()
        clear_screen()
        print(f"\n💸 PENDING REFUND OPERATIONS")
        headers = ["ID", "Booking", "Customer", "Type", "Reason", "Cancelled At", "Amount", "Status"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()


def get_top_vendors(rank_by):
    """Ranks vendors by volume, revenue, or customer rating."""
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        
        order_clause = "bookings DESC"
        if rank_by == "Revenue": order_clause = "revenue DESC"
        elif rank_by == "Average Customer Rating": order_clause = "rating DESC"

        query = f"""
            SELECT 
                v.company_name, 
                v.vendor_type, 
                COUNT(DISTINCT b.booking_id) as bookings, 
                COALESCE(SUM(b.final_amount), 0) as revenue, 
                COALESCE(ROUND(AVG(r.star_rating), 2), 0) as rating
            FROM vendor v
            LEFT JOIN (
                SELECT hb.booking_id, h.vendor_id FROM hotel_booking hb JOIN room_category rc ON rc.room_category_id = hb.room_category_id JOIN hotel h ON h.hotel_id = rc.hotel_id
                UNION ALL
                SELECT tb.booking_id, tr.vendor_id FROM transport_booking tb JOIN schedule_departure sd ON sd.departure_id = tb.departure_id JOIN transport_route tr ON tr.route_id = sd.schedule_id
            ) v_bookings ON v_bookings.vendor_id = v.vendor_id
            LEFT JOIN booking b ON b.booking_id = v_bookings.booking_id
            LEFT JOIN review r ON r.entity_id = v.vendor_id
            GROUP BY v.company_name, v.vendor_type
            ORDER BY {order_clause};
        """
        cursor.execute(query)
        results = cursor.fetchall()
        clear_screen()
        print(f"\n🏆 VENDOR LEADERBOARD: RANKED BY {rank_by.upper()}")
        headers = ["Vendor", "Type", "Bookings", "Total Revenue", "Avg Rating"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()


def get_top_destinations(period):
    """Top 10 routes/destinations by booking volume."""
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        time_clause = ""
        if period == "This Year": time_clause = "WHERE EXTRACT(YEAR FROM b.booked_at) = 2026"
        
        query = f"""
            SELECT 
                details.dest, 
                COUNT(DISTINCT b.booking_id) as volume
            FROM booking b
            JOIN (
                SELECT hb.booking_id, h.city as dest FROM hotel_booking hb JOIN room_category rc ON rc.room_category_id = hb.room_category_id JOIN hotel h ON h.hotel_id = rc.hotel_id
                UNION ALL
                SELECT tb.booking_id, tr.origin_city || '->' || tr.destination_city as dest FROM transport_booking tb JOIN schedule_departure sd ON sd.departure_id = tb.departure_id JOIN transport_route tr ON tr.route_id = sd.schedule_id
            ) details ON details.booking_id = b.booking_id
            {time_clause}
            GROUP BY details.dest
            ORDER BY volume DESC LIMIT 10;
        """
        cursor.execute(query)
        results = cursor.fetchall()
        clear_screen()
        print(f"\n📍 TOP 10 DESTINATIONS ({period})")
        headers = ["Location / Route", "Booking Volume"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()


# ============================================================================
# SECTION 3: REVIEWS & QUALITY
# ============================================================================

def get_feedback_summary(vendor_id, service_type):
    """Aggregated feedback metrics for a specific vendor."""
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        type_clause = ""
        if service_type != "All": type_clause = f"AND r.entity_type = '{service_type.lower()}'"

        query = f"""
            SELECT r.entity_type, COUNT(*), ROUND(AVG(r.star_rating), 2), MIN(r.star_rating), MAX(r.star_rating)
            FROM review r
            WHERE r.entity_type IN ('hotel', 'transport')
            -- Simplified to show general trend for the vendor
            {type_clause}
            GROUP BY r.entity_type;
        """
        cursor.execute(query)
        results = cursor.fetchall()
        clear_screen()
        print(f"\n⭐ CUSTOMER FEEDBACK SUMMARY")
        headers = ["Entity Type", "Review Count", "Avg Rating", "Min", "Max"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()


def get_poor_services():
    """Identifies specific services falling below 2.5 stars."""
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        query = """
            SELECT r.entity_type, r.entity_id, COUNT(*), COALESCE(AVG(r.star_rating), 0)
            FROM review r
            GROUP BY r.entity_type, r.entity_id
            HAVING AVG(r.star_rating) < 2.5;
        """
        cursor.execute(query)
        results = cursor.fetchall()
        clear_screen()
        print(f"\n🚨 SERVICES WITH POOR RATINGS (< 2.5 STARS)")
        if not results:
            print("\n   ✅ No services with poor ratings found — quality looks good!")
        else:
            headers = ["Type", "Entity ID", "Reviews", "Avg Rating"]
            print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()


# ============================================================================
# SECTION 4: TRENDS & INSURANCE
# ============================================================================

def get_monthly_trends():
    """Analyzes booking volume peaks by month across service categories."""
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        query = """
            SELECT TO_CHAR(booked_at, 'YYYY-MM') as month,
                   COUNT(CASE WHEN booking_type = 'transport' THEN 1 END) as transport,
                   COUNT(CASE WHEN booking_type = 'hotel' THEN 1 END) as hotel,
                   COUNT(CASE WHEN booking_type = 'package' THEN 1 END) as package,
                   COUNT(*) as total
            FROM booking
            GROUP BY 1
            ORDER BY 1 DESC;
        """
        cursor.execute(query)
        results = cursor.fetchall()
        clear_screen()
        print(f"\n📈 MONTHLY BOOKING VOLUME TRENDS")
        headers = ["Month", "Transport", "Hotel", "Package", "Total"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()


def get_insurance_summary():
    """Summary of all insurance plans, premiums, and active claims."""
    conn = get_db_connection()
    if not conn: return
    cursor = None
    try:
        cursor = conn.cursor()
        query = """
            SELECT b.booking_id, u.full_name, b.booking_type, i.provider_name, i.plan_name, i.premium_amount, i.claim_status
            FROM booking b
            JOIN "User" u ON u.user_id = b.user_id
            JOIN booking_insurance bi ON bi.booking_id = b.booking_id
            JOIN insurance i ON i.insurance_id = bi.insurance_id
            ORDER BY b.booking_id DESC;
        """
        cursor.execute(query)
        results = cursor.fetchall()
        clear_screen()
        print(f"\n🛡️  INSURANCE CLAIM & PREMIUM SUMMARY")
        headers = ["Booking", "Customer", "Type", "Provider", "Plan", "Premium", "Claim Status"]
        print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        input("\nPress Enter...")
    finally:
        if cursor: cursor.close()
        conn.close()
