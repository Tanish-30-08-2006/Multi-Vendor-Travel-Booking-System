import os
from connection import get_db_connection
from tabulate import tabulate


def clear_screen():
    """Removes all old text from the console for a clean look."""
    os.system('cls' if os.name == 'nt' else 'clear')


# ----------------------------------------------------------------------------
# 1. TRANSPORT SEARCH (G1)
# ----------------------------------------------------------------------------

def search_transport(source, destination, travel_date, mode_filter, class_filter):
    """
    Exhaustive search for transport options with filtering for
    Transport Mode (Flight/Train/Bus) and Class (Economy/Business/etc).
    """

    conn = get_db_connection()
    if not conn: return 

    cursor = None


    try:
        cursor = conn.cursor()

        # Build dynamic filters
        mode_clause = ""
        if mode_filter != "All Modes":
            mode_clause = f"AND r.transport_mode = '{mode_filter.lower()}'"

        class_clause = ""
        if class_filter != "All Classes":
            class_clause = f"AND c.class_name = '{class_filter}'"


        query = f"""
            SELECT 
                r.origin_city || ' -> ' || r.destination_city AS route,
                v.company_name, 
                s.departure_time || ' / ' || s.arrival_time AS timings, 
                c.class_name, 
                COALESCE(d.dynamic_fare, c.base_fare) as fare, 
                d.available_seats
            FROM transport_route r
            JOIN vendor v ON v.vendor_id = r.vendor_id
            JOIN route_schedule s ON r.route_id = s.route_id
            JOIN route_schedule_class rsc ON s.schedule_id = rsc.schedule_id
            JOIN schedule_class c ON rsc.class_id = c.class_id
            JOIN schedule_departure d ON (s.schedule_id = d.schedule_id AND c.class_id = d.class_id)
            WHERE UPPER(r.origin_city) = UPPER(%s) 
              AND UPPER(r.destination_city) = UPPER(%s) 
              AND d.departure_date = %s
              {mode_clause}
              {class_clause}
            ORDER BY fare ASC;
        """


        cursor.execute(query, (source, destination, travel_date))
        results = cursor.fetchall()


        clear_screen()
        print("\n" + "═"*85)
        print(f"       ✈️  TRANSPORT RESULTS: {source.upper()} to {destination.upper()} ({travel_date})")
        print(f"       Filters: {mode_filter} | {class_filter}")
        print("═"*85)


        if not results:
            print(f"\n   ❌ No services found matching your criteria.")
        else:
            headers = ["Route", "Vendor", "Dep / Arr", "Class", "Fare (₹)", "Seats"]
            print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
            print(f"\n   ✅ Total Options Found: {len(results)}")
        

        input("\n   Press Enter to return to Guest Menu...")


    except Exception as e:
        print(f"⚠️ Transport Search Error: {e}")


    finally:
        if cursor: cursor.close()
        conn.close()


# ----------------------------------------------------------------------------
# 2. HOTEL SEARCH (G2)
# ----------------------------------------------------------------------------

def search_hotels(city, checkin_date, star_filter, price_tier):
    """
    Exhaustive search for Hotels with sophisticated tier-based filtering.
    """

    conn = get_db_connection()
    if not conn: return 


    cursor = None


    try:
        cursor = conn.cursor()

        # Handle Star Rating Filter
        star_clause = ""
        if star_filter != "Any":
            star_clause = f"AND h.star_rating = {float(star_filter.split(' ')[0])}"

        # Handle Price Tier Filter
        price_clause = ""
        if price_tier == "Under ₹3,000/night":
            price_clause = "AND rc.price_per_night < 3000"
        elif price_tier == "₹3,000–₹8,000/night":
            price_clause = "AND rc.price_per_night BETWEEN 3000 AND 8000"
        elif price_tier == "₹8,000–₹15,000/night":
            price_clause = "AND rc.price_per_night BETWEEN 8000 AND 15000"
        elif price_tier == "Above ₹15,000/night":
            price_clause = "AND rc.price_per_night > 15000"


        query = f""" 
            SELECT 
                h.hotel_name, 
                h.city,
                h.full_address,
                h.star_rating, 
                v.company_name, 
                rc.category_name, 
                rc.price_per_night, 
                ra.available_rooms
            FROM hotel h
            JOIN vendor v ON v.vendor_id = h.vendor_id
            JOIN room_category rc ON rc.hotel_id = h.hotel_id
            JOIN room_availability ra ON ra.room_category_id = rc.room_category_id
            WHERE UPPER(h.city) = UPPER(%s) 
              AND ra.available_date = %s
              {star_clause}
              {price_clause}
              AND ra.available_rooms > 0
            ORDER BY rc.price_per_night ASC;
        """


        cursor.execute(query, (city, checkin_date))
        results = cursor.fetchall()
        

        clear_screen()
        print("\n" + "═"*95)
        print(f"       🏨 HOTEL RESULTS: {city.upper()} ({checkin_date})")
        print(f"       Filters: Stars={star_filter} | Range={price_tier}")
        print("═"*95)


        if not results:
            print(f"\n   ⚠️  No hotels match your filters in {city}.")
        else:
            headers = ["Hotel Name", "City", "Address", "Stars", "Vendor", "Room Type", "Price", "Avail"]
            print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
            print(f"\n   ✅ Total Options Found: {len(results)}")


        input("\n   Press Enter to return...")


    except Exception as e:
        print(f"⚠️ Hotel Search Error: {e}")


    finally:
        if cursor: cursor.close()
        conn.close()


# ----------------------------------------------------------------------------
# 3. BROWSE HOLIDAY PACKAGES (G3)
# ----------------------------------------------------------------------------

def browse_packages(theme_filter, duration_tier, price_tier):
    """
    Exhaustive filtering for Holiday Packages based on Theme, 
    Duration tiers, and Price tiers.
    """

    conn = get_db_connection()
    if not conn: return 
    cursor = None


    try:
        cursor = conn.cursor()

        # Theme filter
        theme_clause = ""
        if theme_filter != "All Themes":
            theme_clause = f"AND hp.theme = '{theme_filter}'"

        # Duration filter
        dur_clause = ""
        if duration_tier == "1–3 days":
            dur_clause = "AND hp.duration_days BETWEEN 1 AND 3"
        elif duration_tier == "4–5 days":
            dur_clause = "AND hp.duration_days BETWEEN 4 AND 5"
        elif duration_tier == "6–8 days":
            dur_clause = "AND hp.duration_days BETWEEN 6 AND 8"
        elif duration_tier == "8+ days":
            dur_clause = "AND hp.duration_days > 8"

        # Price filter
        price_clause = ""
        if price_tier == "Under ₹12,000":
            price_clause = "AND pd.price_per_person < 12000"
        elif price_tier == "₹12,000–₹20,000":
            price_clause = "AND pd.price_per_person BETWEEN 12000 AND 20000"
        elif price_tier == "₹20,000–₹30,000":
            price_clause = "AND pd.price_per_person BETWEEN 20000 AND 30000"
        elif price_tier == "Above ₹30,000":
            price_clause = "AND pd.price_per_person > 30000"


        query = f"""
            SELECT 
                hp.package_name, 
                hp.theme, 
                hp.duration_days || 'D / ' || (hp.duration_days - 1) || 'N' as duration, 
                v.company_name, 
                pd.departure_date, 
                pd.available_seats,
                pd.price_per_person
            FROM holiday_package hp
            JOIN vendor v ON v.vendor_id = hp.vendor_id
            JOIN package_departure pd ON pd.package_id = hp.package_id
            WHERE hp.is_active = TRUE AND pd.status = 'open'
              {theme_clause}
              {dur_clause}
              {price_clause}
            ORDER BY pd.price_per_person ASC;
        """


        cursor.execute(query)
        results = cursor.fetchall()


        clear_screen()
        print("\n" + "═"*95)
        print(f"       🌴 HOLIDAY PACKAGE RESULTS")
        print(f"       Filters: {theme_filter} | {duration_tier} | {price_tier}")
        print("═"*95)


        if not results:
            print(f"\n   ❌ No packages found matching these filters.")
        else:
            headers = ["Package Name", "Theme", "Duration", "Vendor", "Dep. Date", "Seats", "Price/Person"]
            print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        

        input("\n   Press Enter to return...")


    except Exception as e:
        print(f"⚠️ Package Browse Error: {e}")


    finally:
        if cursor: cursor.close()
        conn.close()


# ----------------------------------------------------------------------------
# 4. COMPARE PRICES (G4)
# ----------------------------------------------------------------------------

def compare_transport_prices(source, destination, date):
    """
    Side-by-side comparison of all vendors for a route, including 
    aggregated user ratings and review counts.
    """

    conn = get_db_connection()
    if not conn: return 
    cursor = None


    try:
        cursor = conn.cursor()

        query = """
            SELECT 
                v.company_name AS vendor,
                tr.transport_mode AS mode,
                sc.class_name AS class,
                COALESCE(sd.dynamic_fare, sc.base_fare) AS fare,
                sd.available_seats,
                ROUND(AVG(rv.star_rating), 2) AS avg_rating,
                COUNT(rv.review_id) AS reviews
            FROM schedule_departure sd
            JOIN route_schedule_class rsc ON rsc.schedule_id = sd.schedule_id AND rsc.class_id = sd.class_id
            JOIN route_schedule rs ON rs.schedule_id = sd.schedule_id
            JOIN transport_route tr ON tr.route_id = rs.route_id
            JOIN schedule_class sc ON sc.class_id = sd.class_id
            JOIN vendor v ON v.vendor_id = tr.vendor_id
            LEFT JOIN review rv ON rv.entity_type = 'transport' AND rv.entity_id = tr.route_id
            WHERE UPPER(tr.origin_city) = UPPER(%s) 
              AND UPPER(tr.destination_city) = UPPER(%s) 
              AND sd.departure_date = %s
            GROUP BY v.company_name, tr.transport_mode, sc.class_name, sd.dynamic_fare, sc.base_fare, sd.available_seats
            ORDER BY fare ASC;
        """


        cursor.execute(query, (source, destination, date))
        results = cursor.fetchall()


        clear_screen()
        print("\n" + "═"*90)
        print(f"       ⚖️  PRICE COMPARISON: {source.upper()} to {destination.upper()} ({date})")
        print("═"*90)


        if not results:
            print(f"\n   ❌ No data available to compare for this route.")
        else:
            headers = ["Vendor", "Mode", "Class", "Fare (₹)", "Seats", "Rating", "Reviews"]
            print(tabulate(results, headers=headers, tablefmt="rounded_grid"))
        

        input("\n   Press Enter to return...")


    except Exception as e:
        print(f"⚠️ Comparison Error: {e}")


    finally:
        if cursor: cursor.close()
        conn.close()
