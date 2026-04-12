-- ============================================================
-- TRAVEL PLATFORM — COMPLETE QUERY COLLECTION
-- ============================================================

-- ============================================================
-- FOR GUESTS
-- ============================================================

-- G1. Search available transport by parameters
--     (filter by source, destination, date, mode, class)
SELECT
    tr.route_id,
    tr.transport_mode,
    tr.origin_city,
    tr.destination_city,
    tr.vehicle_number,
    v.company_name        AS vendor,
    rs.departure_time,
    rs.arrival_time,
    sc.class_name,
    COALESCE(sd.dynamic_fare, sc.base_fare) AS fare,
    sd.available_seats,
    sd.departure_date,
    sd.status
FROM Schedule_Departure sd
JOIN Route_Schedule_Class rsc ON rsc.schedule_id = sd.schedule_id
                              AND rsc.class_id    = sd.class_id
JOIN Route_Schedule rs  ON rs.schedule_id = sd.schedule_id
JOIN Transport_Route tr ON tr.route_id    = rs.route_id
JOIN Schedule_Class  sc ON sc.class_id    = sd.class_id
JOIN Vendor          v  ON v.vendor_id    = tr.vendor_id
WHERE sd.status = 'scheduled'
  AND sd.available_seats > 0
  -- Parameterise as needed; sample filters shown below:
  AND tr.origin_city      = 'Delhi'        -- :origin_city
  AND tr.destination_city = 'Mumbai'       -- :destination_city
  AND sd.departure_date   = '2026-05-01'   -- :departure_date
  AND tr.transport_mode   = 'train'        -- :transport_mode
  AND sc.class_name       = 'Sleeper'      -- :class_name
ORDER BY fare;


-- G2. Search hotels by parameters
--     (city, check-in date, check-out date, star rating, price range)
SELECT
    h.hotel_id,
    h.hotel_name,
    h.city,
    h.full_address,
    h.star_rating,
    h.checkin_time,
    h.checkout_time,
    v.company_name        AS vendor,
    rc.room_category_id,
    rc.category_name,
    rc.max_guests,
    rc.price_per_night,
    ra.available_rooms
FROM Hotel h
JOIN Vendor          v  ON v.vendor_id        = h.vendor_id
JOIN Room_Category   rc ON rc.hotel_id        = h.hotel_id
JOIN Room_Availability ra ON ra.room_category_id = rc.room_category_id
WHERE h.city            = 'Delhi'            -- :city
  AND ra.available_date = '2026-05-01'       -- :checkin_date  (simplified; full range needs every date)
  AND ra.available_rooms > 0
  AND h.star_rating    >= 4.0               -- :min_star_rating
  AND rc.price_per_night BETWEEN 5000 AND 15000  -- :price_min / :price_max
ORDER BY h.star_rating DESC, rc.price_per_night;


-- G3. Browse holiday packages by parameters
--     (destination/theme/duration/price range)
SELECT
    hp.package_id,
    hp.package_name,
    hp.theme,
    hp.duration_days,
    hp.duration_nights,
    hp.base_price_per_person,
    v.company_name        AS vendor,
    pd.departure_date,
    pd.available_seats,
    pd.price_per_person,
    pd.status
FROM Holiday_Package hp
JOIN Vendor            v  ON v.vendor_id          = hp.vendor_id
JOIN Package_Departure pd ON pd.package_id        = hp.package_id
WHERE hp.is_active   = TRUE
  AND pd.status      = 'open'
  AND pd.available_seats > 0
  -- Sample filters:
  AND hp.theme       = 'Adventure'                -- :theme
  AND hp.duration_days BETWEEN 5 AND 8           -- :min_days / :max_days
  AND pd.price_per_person BETWEEN 15000 AND 35000 -- :price_min / :price_max
ORDER BY pd.price_per_person;


-- G4. Compare prices for the same route/destination across vendors & modes
--     (includes average traveller rating per vendor)
SELECT
    tr.origin_city,
    tr.destination_city,
    tr.transport_mode,
    v.company_name                           AS vendor,
    sc.class_name,
    COALESCE(sd.dynamic_fare, sc.base_fare)  AS fare,
    sd.departure_date,
    sd.available_seats,
    ROUND(AVG(r.star_rating), 2)             AS avg_vendor_rating,
    COUNT(r.review_id)                       AS review_count
FROM Schedule_Departure sd
JOIN Route_Schedule_Class rsc ON rsc.schedule_id = sd.schedule_id
                              AND rsc.class_id    = sd.class_id
JOIN Route_Schedule rs  ON rs.schedule_id = sd.schedule_id
JOIN Transport_Route tr ON tr.route_id    = rs.route_id
JOIN Schedule_Class  sc ON sc.class_id    = sd.class_id
JOIN Vendor          v  ON v.vendor_id    = tr.vendor_id
LEFT JOIN Review     r  ON r.entity_type  = 'transport'
                       AND r.entity_id    = tr.route_id
WHERE tr.origin_city      = 'Delhi'
  AND tr.destination_city = 'Mumbai'
  AND sd.departure_date   = '2026-05-01'
  AND sd.status           = 'scheduled'
GROUP BY tr.origin_city, tr.destination_city, tr.transport_mode,
         v.company_name, sc.class_name, sd.dynamic_fare, sc.base_fare,
         sd.departure_date, sd.available_seats
ORDER BY fare;


-- ============================================================
-- FOR TRAVELERS (substitute :user_id with the actual user id)
-- ============================================================

-- T1. My Bookings — all bookings with type, service details, travel date, status
SELECT
    b.booking_id,
    b.booking_type,
    b.status,
    b.booked_at,
    b.final_amount,
    b.payment_method,
    -- service detail columns (NULL when not applicable for that type)
    CASE b.booking_type
        WHEN 'transport' THEN tr.origin_city || ' → ' || tr.destination_city
        WHEN 'hotel'     THEN h.hotel_name || ', ' || h.city
        WHEN 'package'   THEN hp.package_name
    END                                     AS service_description,
    CASE b.booking_type
        WHEN 'transport' THEN sd.departure_date::TEXT
        WHEN 'hotel'     THEN hb.checkin_date::TEXT
        WHEN 'package'   THEN pd.departure_date::TEXT
    END                                     AS travel_date
FROM Booking b
LEFT JOIN Transport_Booking tb ON tb.booking_id = b.booking_id
LEFT JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
LEFT JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
LEFT JOIN Transport_Route tr ON tr.route_id = rs.route_id
LEFT JOIN Hotel_Booking hb ON hb.booking_id = b.booking_id
LEFT JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
LEFT JOIN Hotel h ON h.hotel_id = rc.hotel_id
LEFT JOIN Package_Booking pb ON pb.booking_id = b.booking_id
LEFT JOIN Package_Departure pd ON pd.package_departure_id = pb.package_departure_id
LEFT JOIN Holiday_Package hp ON hp.package_id = pd.package_id
WHERE b.user_id = 1   -- :user_id
ORDER BY b.booked_at DESC;


-- T2. Upcoming Trips — confirmed bookings where travel date is in the future
SELECT
    b.booking_id,
    b.booking_type,
    b.status,
    CASE b.booking_type
        WHEN 'transport' THEN tr.origin_city || ' → ' || tr.destination_city
        WHEN 'hotel'     THEN h.hotel_name || ', ' || h.city
        WHEN 'package'   THEN hp.package_name
    END                                     AS service_description,
    CASE b.booking_type
        WHEN 'transport' THEN sd.departure_date
        WHEN 'hotel'     THEN hb.checkin_date
        WHEN 'package'   THEN pd.departure_date
    END                                     AS travel_date,
    b.final_amount
FROM Booking b
LEFT JOIN Transport_Booking tb ON tb.booking_id = b.booking_id
LEFT JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
LEFT JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
LEFT JOIN Transport_Route tr ON tr.route_id = rs.route_id
LEFT JOIN Hotel_Booking hb ON hb.booking_id = b.booking_id
LEFT JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
LEFT JOIN Hotel h ON h.hotel_id = rc.hotel_id
LEFT JOIN Package_Booking pb ON pb.booking_id = b.booking_id
LEFT JOIN Package_Departure pd ON pd.package_departure_id = pb.package_departure_id
LEFT JOIN Holiday_Package hp ON hp.package_id = pd.package_id
WHERE b.user_id = 1    -- :user_id
  AND b.status = 'confirmed'
  AND CASE b.booking_type
          WHEN 'transport' THEN sd.departure_date
          WHEN 'hotel'     THEN hb.checkin_date
          WHEN 'package'   THEN pd.departure_date
      END > CURRENT_DATE
ORDER BY travel_date;


-- T3. My Cancellations and Refund Status
SELECT
    c.cancellation_id,
    b.booking_id,
    b.booking_type,
    c.reason,
    c.cancelled_at,
    c.refund_amount,
    c.refund_status,
    c.processed_at
FROM Cancellation c
JOIN Booking b ON b.booking_id = c.booking_id
WHERE b.user_id = 5    -- :user_id
ORDER BY c.cancelled_at DESC;


-- T4. My Insurance — policies linked to each booking with plan details and claim status
SELECT
    b.booking_id,
    b.booking_type,
    i.provider_name,
    i.plan_name,
    i.coverage_summary,
    i.premium_amount,
    i.valid_from,
    i.valid_to,
    i.claim_status
FROM Booking_Insurance bi
JOIN Booking   b ON b.booking_id    = bi.booking_id
JOIN Insurance i ON i.insurance_id  = bi.insurance_id
WHERE b.user_id = 1    -- :user_id
ORDER BY b.booking_id;


-- T5. My Spending Summary — total spend over a period, broken down by service type
--     (change date range as needed)
SELECT
    b.booking_type                              AS service_type,
    COUNT(*)                                    AS booking_count,
    SUM(b.final_amount)                         AS total_spent,
    SUM(b.discount_amount)                      AS total_discount_saved
FROM Booking b
WHERE b.user_id = 1           -- :user_id
  AND b.status NOT IN ('cancelled')
  AND b.booked_at >= '2026-01-01'   -- :from_date
  AND b.booked_at <  '2027-01-01'   -- :to_date
GROUP BY b.booking_type
ORDER BY total_spent DESC;


-- ============================================================
-- FOR VENDORS  (substitute :vendor_id with the actual vendor id)
-- ============================================================

-- V1a. Daily revenue summary for a vendor
SELECT
    DATE(b.booked_at)           AS booking_date,
    b.booking_type,
    COUNT(*)                    AS bookings,
    SUM(b.final_amount)         AS revenue
FROM Booking b
JOIN (
    -- hotel bookings for this vendor
    SELECT hb.booking_id FROM Hotel_Booking hb
    JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
    JOIN Hotel h ON h.hotel_id = rc.hotel_id
    WHERE h.vendor_id = 1    -- :vendor_id
    UNION ALL
    -- transport bookings for this vendor
    SELECT tb.booking_id FROM Transport_Booking tb
    JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
    JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
    JOIN Transport_Route tr ON tr.route_id = rs.route_id
    WHERE tr.vendor_id = 1   -- :vendor_id
    UNION ALL
    -- package bookings for this vendor
    SELECT pb.booking_id FROM Package_Booking pb
    JOIN Package_Departure pd ON pd.package_departure_id = pb.package_departure_id
    JOIN Holiday_Package hp ON hp.package_id = pd.package_id
    WHERE hp.vendor_id = 1   -- :vendor_id
) vendor_bookings ON vendor_bookings.booking_id = b.booking_id
WHERE b.status <> 'cancelled'
GROUP BY DATE(b.booked_at), b.booking_type
ORDER BY booking_date, b.booking_type;


-- V1b. Weekly/Monthly/Annual summary — change DATE_TRUNC granularity
--      ('week', 'month', 'year')
SELECT
    DATE_TRUNC('month', b.booked_at)::DATE  AS period,
    b.booking_type,
    COUNT(*)                                AS bookings,
    SUM(b.final_amount)                     AS revenue
FROM Booking b
JOIN (
    SELECT hb.booking_id FROM Hotel_Booking hb
    JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
    JOIN Hotel h ON h.hotel_id = rc.hotel_id
    WHERE h.vendor_id = 1
    UNION ALL
    SELECT tb.booking_id FROM Transport_Booking tb
    JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
    JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
    JOIN Transport_Route tr ON tr.route_id = rs.route_id
    WHERE tr.vendor_id = 1
    UNION ALL
    SELECT pb.booking_id FROM Package_Booking pb
    JOIN Package_Departure pd ON pd.package_departure_id = pb.package_departure_id
    JOIN Holiday_Package hp ON hp.package_id = pd.package_id
    WHERE hp.vendor_id = 1
) vendor_bookings ON vendor_bookings.booking_id = b.booking_id
WHERE b.status <> 'cancelled'
GROUP BY DATE_TRUNC('month', b.booked_at), b.booking_type
ORDER BY period, b.booking_type;


-- V1c. Class-wise revenue for transport vendor
SELECT
    sc.class_name,
    COUNT(*)                                AS bookings,
    SUM(tb.num_seats)                       AS seats_sold,
    SUM(b.final_amount)                     AS revenue
FROM Transport_Booking tb
JOIN Booking b ON b.booking_id = tb.booking_id
JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
JOIN Schedule_Class sc ON sc.class_id = sd.class_id
JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
JOIN Transport_Route tr ON tr.route_id = rs.route_id
WHERE tr.vendor_id = 2    -- :vendor_id (IRCTC)
  AND b.status <> 'cancelled'
GROUP BY sc.class_name
ORDER BY revenue DESC;


-- V1d. Route-wise and destination-wise breakdown for transport vendor
SELECT
    tr.origin_city,
    tr.destination_city,
    tr.transport_mode,
    COUNT(DISTINCT b.booking_id)            AS bookings,
    SUM(b.final_amount)                     AS revenue
FROM Transport_Booking tb
JOIN Booking b ON b.booking_id = tb.booking_id
JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
JOIN Transport_Route tr ON tr.route_id = rs.route_id
WHERE tr.vendor_id = 2    -- :vendor_id
  AND b.status <> 'cancelled'
GROUP BY tr.origin_city, tr.destination_city, tr.transport_mode
ORDER BY revenue DESC;


-- V2. Sales Register — date-wise log of all bookings for a vendor
SELECT
    b.booking_id,
    DATE(b.booked_at)           AS booking_date,
    u.full_name                 AS customer,
    b.booking_type,
    b.status,
    b.base_amount,
    b.discount_amount,
    b.final_amount,
    b.payment_method,
    b.payment_ref
FROM Booking b
JOIN "User" u ON u.user_id = b.user_id
JOIN (
    SELECT hb.booking_id FROM Hotel_Booking hb
    JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
    JOIN Hotel h ON h.hotel_id = rc.hotel_id
    WHERE h.vendor_id = 1
    UNION ALL
    SELECT tb.booking_id FROM Transport_Booking tb
    JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
    JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
    JOIN Transport_Route tr ON tr.route_id = rs.route_id
    WHERE tr.vendor_id = 1
    UNION ALL
    SELECT pb.booking_id FROM Package_Booking pb
    JOIN Package_Departure pd ON pd.package_departure_id = pb.package_departure_id
    JOIN Holiday_Package hp ON hp.package_id = pd.package_id
    WHERE hp.vendor_id = 1
) vendor_bookings ON vendor_bookings.booking_id = b.booking_id
ORDER BY booking_date DESC;


-- V3. Upcoming bookings to be serviced by a vendor
SELECT
    b.booking_id,
    u.full_name                 AS customer,
    u.phone,
    u.email,
    b.booking_type,
    CASE b.booking_type
        WHEN 'transport' THEN tr.origin_city || ' → ' || tr.destination_city
        WHEN 'hotel'     THEN h.hotel_name || ', ' || h.city
        WHEN 'package'   THEN hp.package_name
    END                         AS service,
    CASE b.booking_type
        WHEN 'transport' THEN sd.departure_date
        WHEN 'hotel'     THEN hb.checkin_date
        WHEN 'package'   THEN pd.departure_date
    END                         AS service_date,
    b.final_amount
FROM Booking b
JOIN "User" u ON u.user_id = b.user_id
LEFT JOIN Transport_Booking tb ON tb.booking_id = b.booking_id
LEFT JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
LEFT JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
LEFT JOIN Transport_Route tr ON tr.route_id = rs.route_id
LEFT JOIN Hotel_Booking hb ON hb.booking_id = b.booking_id
LEFT JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
LEFT JOIN Hotel h ON h.hotel_id = rc.hotel_id
LEFT JOIN Package_Booking pb ON pb.booking_id = b.booking_id
LEFT JOIN Package_Departure pd ON pd.package_departure_id = pb.package_departure_id
LEFT JOIN Holiday_Package hp ON hp.package_id = pd.package_id
WHERE b.status = 'confirmed'
  AND CASE b.booking_type
          WHEN 'transport' THEN sd.departure_date
          WHEN 'hotel'     THEN hb.checkin_date
          WHEN 'package'   THEN pd.departure_date
      END > CURRENT_DATE
  AND (
      tr.vendor_id = 1 OR h.vendor_id = 1 OR hp.vendor_id = 1
  )                             -- :vendor_id
ORDER BY service_date;


-- V4. Cancellation summary for a vendor
SELECT
    COUNT(c.cancellation_id)    AS total_cancellations,
    c.reason,
    SUM(c.refund_amount)        AS total_refund_owed,
    c.refund_status
FROM Cancellation c
JOIN Booking b ON b.booking_id = c.booking_id
JOIN (
    SELECT hb.booking_id FROM Hotel_Booking hb
    JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
    JOIN Hotel h ON h.hotel_id = rc.hotel_id
    WHERE h.vendor_id = 1
    UNION ALL
    SELECT tb.booking_id FROM Transport_Booking tb
    JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
    JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
    JOIN Transport_Route tr ON tr.route_id = rs.route_id
    WHERE tr.vendor_id = 1
    UNION ALL
    SELECT pb.booking_id FROM Package_Booking pb
    JOIN Package_Departure pd ON pd.package_departure_id = pb.package_departure_id
    JOIN Holiday_Package hp ON hp.package_id = pd.package_id
    WHERE hp.vendor_id = 1
) vendor_bookings ON vendor_bookings.booking_id = b.booking_id
WHERE c.cancelled_at >= '2026-01-01'    -- :from_date
  AND c.cancelled_at <  '2027-01-01'    -- :to_date
GROUP BY c.reason, c.refund_status
ORDER BY total_refund_owed DESC;


-- V5. Payment received by a vendor from the platform
--     (confirmed/completed bookings = payment received)
SELECT
    DATE_TRUNC('month', b.booked_at)::DATE  AS month,
    b.booking_type,
    COUNT(*)                                AS bookings,
    SUM(b.final_amount)                     AS amount_received
FROM Booking b
JOIN (
    SELECT hb.booking_id FROM Hotel_Booking hb
    JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
    JOIN Hotel h ON h.hotel_id = rc.hotel_id
    WHERE h.vendor_id = 1
    UNION ALL
    SELECT tb.booking_id FROM Transport_Booking tb
    JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
    JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
    JOIN Transport_Route tr ON tr.route_id = rs.route_id
    WHERE tr.vendor_id = 1
    UNION ALL
    SELECT pb.booking_id FROM Package_Booking pb
    JOIN Package_Departure pd ON pd.package_departure_id = pb.package_departure_id
    JOIN Holiday_Package hp ON hp.package_id = pd.package_id
    WHERE hp.vendor_id = 1
) vendor_bookings ON vendor_bookings.booking_id = b.booking_id
WHERE b.status IN ('confirmed', 'completed')
GROUP BY DATE_TRUNC('month', b.booked_at), b.booking_type
ORDER BY month;


-- V6. Customers who have booked from this vendor
SELECT DISTINCT
    u.user_id,
    u.full_name,
    u.email,
    u.phone,
    u.home_city,
    COUNT(b.booking_id) OVER (PARTITION BY u.user_id) AS total_bookings
FROM "User" u
JOIN Booking b ON b.user_id = u.user_id
JOIN (
    SELECT hb.booking_id FROM Hotel_Booking hb
    JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
    JOIN Hotel h ON h.hotel_id = rc.hotel_id
    WHERE h.vendor_id = 1
    UNION ALL
    SELECT tb.booking_id FROM Transport_Booking tb
    JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
    JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
    JOIN Transport_Route tr ON tr.route_id = rs.route_id
    WHERE tr.vendor_id = 1
    UNION ALL
    SELECT pb.booking_id FROM Package_Booking pb
    JOIN Package_Departure pd ON pd.package_departure_id = pb.package_departure_id
    JOIN Holiday_Package hp ON hp.package_id = pd.package_id
    WHERE hp.vendor_id = 1
) vendor_bookings ON vendor_bookings.booking_id = b.booking_id
ORDER BY total_bookings DESC;


-- V7. All bookings by a specific customer for this vendor's services
SELECT
    b.booking_id,
    b.booking_type,
    b.status,
    b.booked_at,
    b.final_amount,
    CASE b.booking_type
        WHEN 'transport' THEN tr.origin_city || ' → ' || tr.destination_city
        WHEN 'hotel'     THEN h.hotel_name
        WHEN 'package'   THEN hp.package_name
    END  AS service
FROM Booking b
LEFT JOIN Transport_Booking tb ON tb.booking_id = b.booking_id
LEFT JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
LEFT JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
LEFT JOIN Transport_Route tr ON tr.route_id = rs.route_id
LEFT JOIN Hotel_Booking hb ON hb.booking_id = b.booking_id
LEFT JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
LEFT JOIN Hotel h ON h.hotel_id = rc.hotel_id
LEFT JOIN Package_Booking pb ON pb.booking_id = b.booking_id
LEFT JOIN Package_Departure pd ON pd.package_departure_id = pb.package_departure_id
LEFT JOIN Holiday_Package hp ON hp.package_id = pd.package_id
WHERE b.user_id = 1        -- :customer_user_id
  AND (tr.vendor_id = 1 OR h.vendor_id = 1 OR hp.vendor_id = 1)  -- :vendor_id
ORDER BY b.booked_at DESC;


-- V8. Customers who gave poor ratings (1 or 2 stars) with their review comments
SELECT
    u.user_id,
    u.full_name,
    u.email,
    r.entity_type,
    r.entity_id,
    r.star_rating,
    r.title,
    r.comment,
    r.reviewed_at
FROM Review r
JOIN "User" u ON u.user_id = r.user_id
WHERE r.star_rating <= 2
  AND (
      (r.entity_type = 'hotel'     AND r.entity_id IN (
           SELECT h.hotel_id FROM Hotel h WHERE h.vendor_id = 1))
   OR (r.entity_type = 'transport' AND r.entity_id IN (
           SELECT tr.route_id FROM Transport_Route tr WHERE tr.vendor_id = 1))
   OR (r.entity_type = 'package'   AND r.entity_id IN (
           SELECT hp.package_id FROM Holiday_Package hp WHERE hp.vendor_id = 1))
  )                              -- :vendor_id
ORDER BY r.star_rating, r.reviewed_at DESC;


-- V9. Services tagged as HIGH DEMAND / FILLING FAST / LOW AVAILABILITY
--     (based on available seats vs total seats ratio)
SELECT
    service_type,
    service_id,
    service_name,
    total_capacity,
    available_seats,
    ROUND(100.0 * available_seats / NULLIF(total_capacity,0), 1) AS pct_available,
    CASE
        WHEN 100.0 * available_seats / NULLIF(total_capacity,0) <= 10 THEN 'HIGH DEMAND'
        WHEN 100.0 * available_seats / NULLIF(total_capacity,0) <= 30 THEN 'FILLING FAST'
        ELSE 'LOW AVAILABILITY'
    END AS demand_tag
FROM (
    -- Transport departures
    SELECT
        'transport'             AS service_type,
        sd.departure_id         AS service_id,
        tr.origin_city || ' → ' || tr.destination_city || ' (' || sc.class_name || ') on ' || sd.departure_date::TEXT AS service_name,
        sc.total_seats          AS total_capacity,
        sd.available_seats
    FROM Schedule_Departure sd
    JOIN Route_Schedule_Class rsc ON rsc.schedule_id = sd.schedule_id AND rsc.class_id = sd.class_id
    JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
    JOIN Transport_Route tr ON tr.route_id = rs.route_id
    JOIN Schedule_Class sc ON sc.class_id = sd.class_id
    WHERE tr.vendor_id = 2      -- :vendor_id (IRCTC example)
      AND sd.status = 'scheduled'
    UNION ALL
    -- Hotel room availability
    SELECT
        'hotel'                 AS service_type,
        rc.room_category_id     AS service_id,
        h.hotel_name || ' — ' || rc.category_name || ' on ' || ra.available_date::TEXT AS service_name,
        rc.total_rooms          AS total_capacity,
        ra.available_rooms      AS available_seats
    FROM Room_Availability ra
    JOIN Room_Category rc ON rc.room_category_id = ra.room_category_id
    JOIN Hotel h ON h.hotel_id = rc.hotel_id
    WHERE h.vendor_id = 1       -- :vendor_id (Taj Hotels example)
    UNION ALL
    -- Package departures
    SELECT
        'package'               AS service_type,
        pd.package_departure_id AS service_id,
        hp.package_name || ' on ' || pd.departure_date::TEXT AS service_name,
        pd.total_seats          AS total_capacity,
        pd.available_seats
    FROM Package_Departure pd
    JOIN Holiday_Package hp ON hp.package_id = pd.package_id
    WHERE hp.vendor_id = 3      -- :vendor_id (MakeMyTrip example)
      AND pd.status = 'open'
) combined
WHERE 100.0 * available_seats / NULLIF(total_capacity,0) <= 40  -- show only restricted supply
ORDER BY pct_available;


-- ============================================================
-- FOR PLATFORM ADMIN
-- ============================================================

-- A1a. Overall daily/weekly/monthly/annual platform revenue
SELECT
    DATE_TRUNC('month', b.booked_at)::DATE   AS period,
    COUNT(*)                                  AS total_bookings,
    SUM(b.base_amount)                        AS gross_revenue,
    SUM(b.discount_amount)                    AS total_discounts,
    SUM(b.final_amount)                       AS net_revenue
FROM Booking b
WHERE b.status <> 'cancelled'
GROUP BY DATE_TRUNC('month', b.booked_at)
ORDER BY period;


-- A1b. Revenue breakdown — vendor-wise
SELECT
    v.vendor_id,
    v.company_name,
    v.vendor_type,
    COUNT(DISTINCT b.booking_id)              AS bookings,
    SUM(b.final_amount)                       AS revenue
FROM Booking b
JOIN (
    SELECT hb.booking_id, h.vendor_id FROM Hotel_Booking hb
    JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
    JOIN Hotel h ON h.hotel_id = rc.hotel_id
    UNION ALL
    SELECT tb.booking_id, tr.vendor_id FROM Transport_Booking tb
    JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
    JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
    JOIN Transport_Route tr ON tr.route_id = rs.route_id
    UNION ALL
    SELECT pb.booking_id, hp.vendor_id FROM Package_Booking pb
    JOIN Package_Departure pd ON pd.package_departure_id = pb.package_departure_id
    JOIN Holiday_Package hp ON hp.package_id = pd.package_id
) bv ON bv.booking_id = b.booking_id
JOIN Vendor v ON v.vendor_id = bv.vendor_id
WHERE b.status <> 'cancelled'
GROUP BY v.vendor_id, v.company_name, v.vendor_type
ORDER BY revenue DESC;


-- A1c. Revenue breakdown — service type wise
SELECT
    b.booking_type,
    COUNT(*)                    AS bookings,
    SUM(b.final_amount)         AS revenue
FROM Booking b
WHERE b.status <> 'cancelled'
GROUP BY b.booking_type
ORDER BY revenue DESC;


-- A1d. Revenue breakdown — destination wise
SELECT
    destination,
    COUNT(*)                    AS bookings,
    SUM(final_amount)           AS revenue
FROM (
    SELECT tr.destination_city  AS destination, b.final_amount
    FROM Transport_Booking tb
    JOIN Booking b ON b.booking_id = tb.booking_id
    JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
    JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
    JOIN Transport_Route tr ON tr.route_id = rs.route_id
    WHERE b.status <> 'cancelled'
    UNION ALL
    SELECT h.city AS destination, b.final_amount
    FROM Hotel_Booking hb
    JOIN Booking b ON b.booking_id = hb.booking_id
    JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
    JOIN Hotel h ON h.hotel_id = rc.hotel_id
    WHERE b.status <> 'cancelled'
) dest_revenue
GROUP BY destination
ORDER BY revenue DESC;


-- A1e. Revenue breakdown — transport mode wise
SELECT
    tr.transport_mode,
    COUNT(DISTINCT b.booking_id)    AS bookings,
    SUM(b.final_amount)             AS revenue
FROM Transport_Booking tb
JOIN Booking b ON b.booking_id = tb.booking_id
JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
JOIN Transport_Route tr ON tr.route_id = rs.route_id
WHERE b.status <> 'cancelled'
GROUP BY tr.transport_mode
ORDER BY revenue DESC;


-- A2. Financial ledger of a specific vendor
SELECT
    b.booking_id,
    DATE(b.booked_at)           AS date,
    b.booking_type,
    b.status,
    b.base_amount,
    b.discount_amount,
    b.final_amount,
    b.payment_method,
    b.payment_ref
FROM Booking b
JOIN (
    SELECT hb.booking_id FROM Hotel_Booking hb
    JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
    JOIN Hotel h ON h.hotel_id = rc.hotel_id
    WHERE h.vendor_id = 1
    UNION ALL
    SELECT tb.booking_id FROM Transport_Booking tb
    JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
    JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
    JOIN Transport_Route tr ON tr.route_id = rs.route_id
    WHERE tr.vendor_id = 1
    UNION ALL
    SELECT pb.booking_id FROM Package_Booking pb
    JOIN Package_Departure pd ON pd.package_departure_id = pb.package_departure_id
    JOIN Holiday_Package hp ON hp.package_id = pd.package_id
    WHERE hp.vendor_id = 1
) vendor_bookings ON vendor_bookings.booking_id = b.booking_id
ORDER BY b.booked_at;


-- A3. Pending refunds list
SELECT
    c.cancellation_id,
    b.booking_id,
    u.full_name         AS customer,
    u.email,
    b.booking_type,
    c.reason,
    c.cancelled_at,
    c.refund_amount,
    c.refund_status
FROM Cancellation c
JOIN Booking b ON b.booking_id = c.booking_id
JOIN "User" u  ON u.user_id    = b.user_id
WHERE c.refund_status = 'pending'
ORDER BY c.cancelled_at;


-- A4. Top vendors ranked by booking volume, revenue, and average customer rating
SELECT
    v.vendor_id,
    v.company_name,
    v.vendor_type,
    COUNT(DISTINCT b.booking_id)    AS booking_volume,
    SUM(b.final_amount)             AS total_revenue,
    ROUND(AVG(r.star_rating), 2)    AS avg_rating,
    RANK() OVER (ORDER BY COUNT(DISTINCT b.booking_id) DESC) AS rank_by_volume,
    RANK() OVER (ORDER BY SUM(b.final_amount) DESC)          AS rank_by_revenue,
    RANK() OVER (ORDER BY AVG(r.star_rating) DESC)           AS rank_by_rating
FROM Vendor v
LEFT JOIN (
    SELECT hb.booking_id, h.vendor_id FROM Hotel_Booking hb
    JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
    JOIN Hotel h ON h.hotel_id = rc.hotel_id
    UNION ALL
    SELECT tb.booking_id, tr.vendor_id FROM Transport_Booking tb
    JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
    JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
    JOIN Transport_Route tr ON tr.route_id = rs.route_id
    UNION ALL
    SELECT pb.booking_id, hp.vendor_id FROM Package_Booking pb
    JOIN Package_Departure pd ON pd.package_departure_id = pb.package_departure_id
    JOIN Holiday_Package hp ON hp.package_id = pd.package_id
) bv ON bv.vendor_id = v.vendor_id
LEFT JOIN Booking b ON b.booking_id = bv.booking_id AND b.status <> 'cancelled'
LEFT JOIN Review r  ON r.entity_type IN ('hotel','transport','package')
                    AND (
                        (r.entity_type = 'hotel'     AND r.entity_id IN (SELECT hotel_id FROM Hotel WHERE vendor_id = v.vendor_id))
                     OR (r.entity_type = 'transport' AND r.entity_id IN (SELECT route_id FROM Transport_Route WHERE vendor_id = v.vendor_id))
                     OR (r.entity_type = 'package'   AND r.entity_id IN (SELECT package_id FROM Holiday_Package WHERE vendor_id = v.vendor_id))
                    )
GROUP BY v.vendor_id, v.company_name, v.vendor_type
HAVING COUNT(DISTINCT b.booking_id) > 0
ORDER BY booking_volume DESC;


-- A5. Top destinations and routes by booking volume over a period
SELECT
    destination,
    route_label,
    COUNT(*) AS booking_volume
FROM (
    SELECT
        tr.destination_city         AS destination,
        tr.origin_city || ' → ' || tr.destination_city AS route_label,
        b.booking_id
    FROM Transport_Booking tb
    JOIN Booking b ON b.booking_id = tb.booking_id
    JOIN Schedule_Departure sd ON sd.departure_id = tb.departure_id
    JOIN Route_Schedule rs ON rs.schedule_id = sd.schedule_id
    JOIN Transport_Route tr ON tr.route_id = rs.route_id
    WHERE b.status <> 'cancelled'
      AND b.booked_at >= '2026-01-01'
      AND b.booked_at <  '2027-01-01'
    UNION ALL
    SELECT
        h.city                      AS destination,
        'Hotel: ' || h.city         AS route_label,
        b.booking_id
    FROM Hotel_Booking hb
    JOIN Booking b ON b.booking_id = hb.booking_id
    JOIN Room_Category rc ON rc.room_category_id = hb.room_category_id
    JOIN Hotel h ON h.hotel_id = rc.hotel_id
    WHERE b.status <> 'cancelled'
      AND b.booked_at >= '2026-01-01'
      AND b.booked_at <  '2027-01-01'
) all_destinations
GROUP BY destination, route_label
ORDER BY booking_volume DESC
LIMIT 10;


-- A6. Customer feedback summary — all reviews for a specific vendor or service
--     (with average rating)
SELECT
    r.entity_type,
    r.entity_id,
    CASE r.entity_type
        WHEN 'hotel'     THEN (SELECT hotel_name FROM Hotel WHERE hotel_id = r.entity_id)
        WHEN 'transport' THEN (SELECT origin_city || ' → ' || destination_city FROM Transport_Route WHERE route_id = r.entity_id)
        WHEN 'package'   THEN (SELECT package_name FROM Holiday_Package WHERE package_id = r.entity_id)
    END                             AS service_name,
    COUNT(*)                        AS review_count,
    ROUND(AVG(r.star_rating), 2)    AS avg_rating,
    MIN(r.star_rating)              AS min_rating,
    MAX(r.star_rating)              AS max_rating
FROM Review r
WHERE r.entity_type = 'hotel'       -- :entity_type  ('hotel','transport','package')
  AND r.entity_id IN (
      SELECT hotel_id FROM Hotel WHERE vendor_id = 1  -- :vendor_id
  )
GROUP BY r.entity_type, r.entity_id
ORDER BY avg_rating DESC;


-- A7. Services with consistently poor ratings (average below 2.5)
SELECT
    r.entity_type,
    r.entity_id,
    CASE r.entity_type
        WHEN 'hotel'     THEN (SELECT hotel_name FROM Hotel WHERE hotel_id = r.entity_id)
        WHEN 'transport' THEN (SELECT origin_city || ' → ' || destination_city FROM Transport_Route WHERE route_id = r.entity_id)
        WHEN 'package'   THEN (SELECT package_name FROM Holiday_Package WHERE package_id = r.entity_id)
    END                             AS service_name,
    COUNT(*)                        AS review_count,
    ROUND(AVG(r.star_rating), 2)    AS avg_rating
FROM Review r
GROUP BY r.entity_type, r.entity_id
HAVING AVG(r.star_rating) < 2.5
ORDER BY avg_rating;


-- A8. Monthly booking volume by service type — identify peak & off-peak seasons
SELECT
    TO_CHAR(DATE_TRUNC('month', b.booked_at), 'YYYY-MM')  AS month,
    SUM(CASE WHEN b.booking_type = 'transport' THEN 1 ELSE 0 END) AS transport_bookings,
    SUM(CASE WHEN b.booking_type = 'hotel'     THEN 1 ELSE 0 END) AS hotel_bookings,
    SUM(CASE WHEN b.booking_type = 'package'   THEN 1 ELSE 0 END) AS package_bookings,
    COUNT(*)                                               AS total_bookings
FROM Booking b
WHERE b.status <> 'cancelled'
GROUP BY DATE_TRUNC('month', b.booked_at)
ORDER BY month;


-- A9. Insurance claim summary — all bookings with a filed claim and settlement amount
SELECT
    b.booking_id,
    u.full_name         AS customer,
    b.booking_type,
    i.provider_name,
    i.plan_name,
    i.premium_amount,
    i.claim_status,
    CASE i.claim_status
        WHEN 'approved' THEN i.premium_amount   -- proxy for settlement
        ELSE 0
    END                 AS settlement_amount,
    bi.insurance_id
FROM Booking_Insurance bi
JOIN Booking   b ON b.booking_id   = bi.booking_id
JOIN Insurance i ON i.insurance_id = bi.insurance_id
JOIN "User"    u ON u.user_id      = b.user_id
WHERE i.claim_status IN ('filed', 'approved', 'rejected')
ORDER BY i.claim_status, b.booking_id;

