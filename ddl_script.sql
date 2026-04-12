-- ============================================================
-- 1. VENDOR
-- ============================================================

CREATE TABLE Vendor (
vendor_id           SERIAL PRIMARY KEY,
company_name        VARCHAR(150)    NOT NULL,
vendor_type         VARCHAR(20)     NOT NULL  

CHECK (vendor_type IN ('hotel', 'transport', 'package')),
gst_number          VARCHAR(20)     UNIQUE NOT NULL,
registered_address  TEXT            NOT NULL,
website             VARCHAR(255),
contact_name        VARCHAR(100)    NOT NULL,
contact_phone       VARCHAR(15),
contact_email       VARCHAR(100),
is_active           BOOLEAN         DEFAULT TRUE,
created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

--- ============================================================
-- 2. USER
-- ============================================================

CREATE TABLE "User" (
user_id         SERIAL PRIMARY KEY,
full_name       VARCHAR(150)    NOT NULL,
email           VARCHAR(100)    UNIQUE NOT NULL,
phone           VARCHAR(15)     UNIQUE NOT NULL,
dob             DATE            NOT NULL,
home_city       VARCHAR(100),
account_status  VARCHAR(20)     DEFAULT 'active'
CHECK (account_status IN ('active', 'suspended', 'deleted'))
);

--- ============================================================
-- 3. TRANSPORT LAYER
---============================================================

CREATE TABLE Transport_Route (
route_id SERIAL PRIMARY KEY, 
transport_mode VARCHAR(10) NOT NULL
CHECK (transport_mode IN ('flight', 'train', 'bus')),
origin_city VARCHAR(100) NOT NULL,
destination_city VARCHAR(100) NOT NULL,
vehicle_number VARCHAR(50),
vendor_id INT NOT NULL REFERENCES Vendor(vendor_id)
);

CREATE TABLE Route_Schedule (
schedule_id SERIAL PRIMARY KEY,
route_id INT NOT NULL REFERENCES Transport_Route(route_id)
ON DELETE CASCADE,
departure_time TIME NOT NULL,
arrival_time TIME NOT NULL,
days_of_week VARCHAR(20), -- e.g. 'Mon,Tue,Wed'
is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE Schedule_Class (
class_id SERIAL PRIMARY KEY,
class_name VARCHAR(50) NOT NULL,
total_seats INT NOT NULL,
base_fare DECIMAL(10,2) NOT NULL
);

CREATE TABLE Route_Schedule_Class (
    schedule_id INT REFERENCES Route_Schedule(schedule_id) ON DELETE CASCADE,
    class_id INT REFERENCES Schedule_Class(class_id) ON DELETE CASCADE,
    PRIMARY KEY (schedule_id, class_id)
);

CREATE TABLE Schedule_Departure (
    departure_id SERIAL PRIMARY KEY,

    schedule_id INT NOT NULL,
    class_id INT NOT NULL,

    departure_date DATE NOT NULL,
    available_seats INT NOT NULL,
    dynamic_fare DECIMAL(10,2), -- overrides base_fare on peak dates
    status VARCHAR(20) DEFAULT 'scheduled',

    -- fix : composite foreign key
    FOREIGN KEY (schedule_id, class_id)
        REFERENCES Route_Schedule_Class(schedule_id, class_id)
        ON DELETE CASCADE,

    CHECK (status IN ('scheduled', 'cancelled', 'completed'))
);

--- ============================================================
-- 4. HOTELS
-- ============================================================

CREATE TABLE Hotel (
hotel_id SERIAL PRIMARY KEY,
hotel_name VARCHAR(150) NOT NULL,
city VARCHAR(100) NOT NULL,
full_address TEXT NOT NULL,
star_rating DECIMAL(2,1) CHECK (star_rating BETWEEN 1.0 AND 5.0),
checkin_time TIME,
checkout_time TIME,
vendor_id INT NOT NULL REFERENCES Vendor(vendor_id)
);

CREATE TABLE Hotel_Amenity (
hotel_id INT REFERENCES Hotel(hotel_id) ON DELETE CASCADE,
amenity VARCHAR(100) NOT NULL,
PRIMARY KEY (hotel_id, amenity)
);

CREATE TABLE Room_Category (
room_category_id SERIAL PRIMARY KEY,
hotel_id INT NOT NULL REFERENCES Hotel(hotel_id)
ON DELETE CASCADE,
category_name VARCHAR(100) NOT NULL, -- e.g. Deluxe, Suite, Standard
max_guests INT NOT NULL,
price_per_night DECIMAL(10,2) NOT NULL,
total_rooms INT NOT NULL
);

CREATE TABLE Room_Availability (
room_category_id INT REFERENCES Room_Category(room_category_id)
ON DELETE CASCADE,
available_date DATE NOT NULL,
available_rooms INT NOT NULL,
PRIMARY KEY (room_category_id, available_date)
);

--- ============================================================
-- 5. HOLIDAY PACKAGES
-- ============================================================

CREATE TABLE Holiday_Package (
package_id SERIAL PRIMARY KEY,
package_name VARCHAR(200) NOT NULL,
theme VARCHAR(100), -- e.g. Adventure, Honeymoon
duration_days INT NOT NULL,
duration_nights INT NOT NULL,
base_price_per_person DECIMAL(10,2) NOT NULL,
is_active BOOLEAN DEFAULT TRUE,
vendor_id INT NOT NULL REFERENCES Vendor(vendor_id)
);

CREATE TABLE Package_Hotel (
package_id INT REFERENCES Holiday_Package(package_id) ON DELETE CASCADE,
hotel_id INT REFERENCES Hotel(hotel_id) ON DELETE CASCADE,
PRIMARY KEY (package_id, hotel_id)

);

CREATE TABLE Package_Transport (
package_id INT REFERENCES Holiday_Package(package_id) ON DELETE CASCADE,
departure_id INT REFERENCES Schedule_Departure(departure_id) ON DELETE CASCADE,
PRIMARY KEY (package_id, departure_id)
);

CREATE TABLE Package_Departure (
package_departure_id SERIAL PRIMARY KEY,
package_id INT NOT NULL
REFERENCES Holiday_Package(package_id) ON DELETE CASCADE,
departure_date DATE NOT NULL,
total_seats INT NOT NULL,
available_seats INT NOT NULL,
price_per_person DECIMAL(10,2) NOT NULL,
status VARCHAR(20) DEFAULT 'open'
CHECK (status IN ('open', 'full', 'cancelled', 'completed'))
);

--- ============================================================
-- 6. PROMO CODES
-- ============================================================

CREATE TABLE Promo_Code (
promo_id            SERIAL PRIMARY KEY,
code                VARCHAR(50)     UNIQUE NOT NULL,
discount_type       VARCHAR(20)     NOT NULL
CHECK (discount_type IN ('percent', 'flat')),
discount_value      DECIMAL(10,2)   NOT NULL,
max_discount_cap    DECIMAL(10,2),              -- cap for % discounts
min_booking_amt     DECIMAL(10,2),              -- minimum cart value to apply
valid_from          DATE            NOT NULL,
valid_to            DATE            NOT NULL,
applicable_on       VARCHAR(20)     NOT NULL
CHECK (applicable_on IN ('hotel', 'transport', 'package', 'all')),
used_count          INT             DEFAULT 0,
is_active           BOOLEAN         DEFAULT TRUE
);

--- ============================================================
-- 7. BOOKING 
-- ============================================================

CREATE TABLE Booking (
booking_id      SERIAL PRIMARY KEY,
user_id         INT             NOT NULL REFERENCES "User"(user_id),
booking_type    VARCHAR(20)     NOT NULL
CHECK (booking_type IN ('hotel', 'transport', 'package')),
booked_at       TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
status          VARCHAR(20)     DEFAULT 'pending'
CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
base_amount     DECIMAL(10,2)   NOT NULL,
discount_amount DECIMAL(10,2)   DEFAULT 0.00,
final_amount    DECIMAL(10,2)   NOT NULL,
payment_method  VARCHAR(20)     CHECK (payment_method IN ('card', 'upi', 'netbanking', 'wallet', 'cod')),
payment_ref     VARCHAR(100),
promo_id        INT             REFERENCES Promo_Code(promo_id)
);

--- ============================================================
-- 8. BOOKING DETAIL TABLES
-- ============================================================
CREATE TABLE Transport_Booking (
booking_id INT PRIMARY KEY REFERENCES Booking(booking_id) ON DELETE CASCADE,
departure_id INT NOT NULL REFERENCES Schedule_Departure(departure_id),
num_seats INT NOT NULL
);

CREATE TABLE Passenger_List (
booking_id INT NOT NULL REFERENCES Transport_Booking(booking_id)
ON DELETE CASCADE,
passenger_name VARCHAR(150) NOT NULL,
age INT NOT NULL,
gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
govt_id_type VARCHAR(20) CHECK (govt_id_type IN ('aadhar', 'passport', 'voter_id', 'pan')),
govt_id_number VARCHAR(150)
);

CREATE TABLE Hotel_Booking (
booking_id INT PRIMARY KEY REFERENCES Booking(booking_id) ON DELETE CASCADE,
room_category_id INT NOT NULL REFERENCES Room_Category(room_category_id),
checkin_date DATE NOT NULL,
checkout_date DATE NOT NULL,
num_rooms INT NOT NULL,
num_guests INT NOT NULL
);

CREATE TABLE Guest_List (
guest_id SERIAL PRIMARY KEY,
booking_id INT NOT NULL REFERENCES Hotel_Booking(booking_id)
ON DELETE CASCADE,
guest_name VARCHAR(150) NOT NULL,
age INT,
gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
govt_id_type VARCHAR(20) CHECK (govt_id_type IN ('aadhar', 'passport', 'voter_id', 'pan')),
govt_id_number VARCHAR(50)
);

CREATE TABLE Package_Booking (
booking_id INT PRIMARY KEY REFERENCES Booking(booking_id) ON DELETE CASCADE,
package_departure_id INT NOT NULL REFERENCES Package_Departure(package_departure_id),
num_travellers INT NOT NULL
);

CREATE TABLE Package_Traveller (
booking_id INT NOT NULL REFERENCES Package_Booking(booking_id)
ON DELETE CASCADE,
traveller_name VARCHAR(150) NOT NULL,
age INT NOT NULL,
gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
govt_id_type VARCHAR(20) CHECK (govt_id_type IN ('aadhar', 'passport', 'voter_id', 'pan')),
govt_id_number VARCHAR(150)
);

--- ============================================================
-- 9. INSURANCE
--- ============================================================

CREATE TABLE Insurance (
insurance_id        SERIAL PRIMARY KEY,
provider_name       VARCHAR(150)    NOT NULL,
plan_name           VARCHAR(150)    NOT NULL,
coverage_summary    TEXT,
premium_amount      DECIMAL(10,2)   NOT NULL,
valid_from          DATE            NOT NULL,
valid_to            DATE            NOT NULL,
claim_status        VARCHAR(20)     DEFAULT 'none'
CHECK (claim_status IN ('none', 'filed', 'approved', 'rejected'))
);

CREATE TABLE Booking_Insurance (
booking_id      INT REFERENCES Booking(booking_id)     ON DELETE CASCADE,
insurance_id    INT REFERENCES Insurance(insurance_id) ON DELETE CASCADE,
PRIMARY KEY (booking_id, insurance_id)
);

--- ============================================================
-- 10. REVIEW
-- ============================================================

CREATE TABLE Review (
review_id       SERIAL PRIMARY KEY,
user_id         INT             NOT NULL REFERENCES "User"(user_id),
entity_type     VARCHAR(20)     NOT NULL
CHECK (entity_type IN ('hotel', 'transport', 'package')),
entity_id       INT             NOT NULL,
star_rating     DECIMAL(2,1)    NOT NULL CHECK (star_rating BETWEEN 1.0 AND 5.0),
title           VARCHAR(200),
comment         TEXT,
reviewed_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

--- ============================================================
-- 11. CANCELLATION
-- ============================================================

CREATE TABLE Cancellation (
cancellation_id SERIAL PRIMARY KEY,
booking_id      INT             NOT NULL REFERENCES Booking(booking_id),
reason          TEXT,
cancelled_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
refund_amount   DECIMAL(10,2),
refund_status   VARCHAR(20)     DEFAULT 'pending'
CHECK (refund_status IN ('pending', 'processed', 'failed')),
processed_at    TIMESTAMP
);