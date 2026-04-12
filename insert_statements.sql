-- ============================================================
-- FIXED INSERT SCRIPT
-- Changes from original:
--   1. Transport_Route rows 7 & 17: vendor_id 38 → 7 (Air India, valid transport vendor)
--   2. Hotel rows 9-14: vendor_ids 32,33,34,35,36,100 → valid hotel vendor IDs (1,19,20,1,5,10)
-- ============================================================

INSERT INTO Vendor (vendor_id, company_name, vendor_type, gst_number, registered_address, website, contact_name, contact_phone, contact_email, is_active, created_at)
VALUES
(1,'Taj Hotels','hotel','GST20001','Mumbai, Maharashtra','https://tajhotels.com','Raj Mehta','9876500001','raj@taj.com',TRUE,CURRENT_TIMESTAMP),
(2,'IRCTC','transport','GST20002','New Delhi','https://irctc.co.in','Amit Sharma','9876500002','amit@irctc.co.in',TRUE,CURRENT_TIMESTAMP),
(3,'MakeMyTrip','package','GST20003','Gurgaon, Haryana','https://makemytrip.com','Neha Kapoor','9876500003','neha@mmt.com',TRUE,CURRENT_TIMESTAMP),
(4,'IndiGo Airlines','transport','GST20004','Delhi','https://goindigo.in','Karan Singh','9876500004','karan@indigo.com',TRUE,CURRENT_TIMESTAMP),
(5,'OYO Rooms','hotel','GST20005','Bangalore','https://oyo.com','Riya Gupta','9876500005','riya@oyo.com',TRUE,CURRENT_TIMESTAMP),
(6,'SpiceJet','transport','GST20006','Delhi','https://spicejet.com','Manish Verma','9876500006','manish@spicejet.com',TRUE,CURRENT_TIMESTAMP),
(7,'Air India','transport','GST20007','Mumbai','https://airindia.com','Sanjay Kulkarni','9876500007','sanjay@airindia.com',TRUE,CURRENT_TIMESTAMP),
(8,'Cleartrip','package','GST20008','Mumbai','https://cleartrip.com','Pooja Shah','9876500008','pooja@cleartrip.com',TRUE,CURRENT_TIMESTAMP),
(9,'Yatra','package','GST20009','Gurgaon','https://yatra.com','Rohit Bansal','9876500009','rohit@yatra.com',TRUE,CURRENT_TIMESTAMP),
(10,'Treebo Hotels','hotel','GST20010','Bangalore','https://treebo.com','Ankit Jain','9876500010','ankit@treebo.com',TRUE,CURRENT_TIMESTAMP),
(11,'FabHotels','hotel','GST20011','Delhi',NULL,'Vikas Arora','9876500011','vikas@fab.com',TRUE,CURRENT_TIMESTAMP),
(12,'Goibibo','package','GST20012','Gurgaon','https://goibibo.com','Kriti Sharma','9876500012','kriti@goibibo.com',TRUE,CURRENT_TIMESTAMP),
(13,'RedBus','transport','GST20013','Bangalore','https://redbus.in','Deepak Nair','9876500013','deepak@redbus.com',TRUE,CURRENT_TIMESTAMP),
(14,'VRL Travels','transport','GST20014','Hubli',NULL,'Suresh Patil','9876500014','suresh@vrl.com',TRUE,CURRENT_TIMESTAMP),
(15,'SRS Travels','transport','GST20015','Bangalore',NULL,'Mahesh Gowda','9876500015','mahesh@srs.com',TRUE,CURRENT_TIMESTAMP),
(16,'Club Mahindra','package','GST20016','Mumbai','https://clubmahindra.com','Nitin Joshi','9876500016','nitin@clubmahindra.com',TRUE,CURRENT_TIMESTAMP),
(17,'Thomas Cook India','package','GST20017','Mumbai','https://thomascook.in','Alok Saxena','9876500017','alok@tc.com',TRUE,CURRENT_TIMESTAMP),
(18,'Sterling Holidays','package','GST20018','Chennai','https://sterlingholidays.com','Harish Iyer','9876500018','harish@sterling.com',TRUE,CURRENT_TIMESTAMP),
(19,'Leela Hotels','hotel','GST20019','Mumbai','https://theleela.com','Rakesh Malhotra','9876500019','rakesh@leela.com',TRUE,CURRENT_TIMESTAMP),
(20,'ITC Hotels','hotel','GST20020','Kolkata','https://itchotels.com','Arvind Menon','9876500020','arvind@itc.com',TRUE,CURRENT_TIMESTAMP),
(21,'Lemon Tree Hotels','hotel','GST20021','Delhi','https://lemontreehotels.com','Saurabh Gupta','9876500021','saurabh@lemontree.com',TRUE,CURRENT_TIMESTAMP),
(22,'Sarovar Hotels','hotel','GST20022','Delhi','https://sarovarhotels.com','Rahul Khanna','9876500022','rahul@sarovar.com',TRUE,CURRENT_TIMESTAMP),
(23,'EaseMyTrip','package','GST20023','Delhi','https://easemytrip.com','Naveen Verma','9876500023','naveen@emt.com',TRUE,CURRENT_TIMESTAMP),
(24,'AbhiBus','transport','GST20024','Hyderabad','https://abhibus.com','Ravi Teja','9876500024','ravi@abhibus.com',TRUE,CURRENT_TIMESTAMP),
(25,'Orange Travels','transport','GST20025','Hyderabad',NULL,'Kishore Reddy','9876500025','kishore@orange.com',TRUE,CURRENT_TIMESTAMP);

INSERT INTO "User" (user_id, full_name, email, phone, dob, home_city, account_status)
VALUES
(1,'Vatsal Mori','vatsal.mori@gmail.com','9000000001','2003-01-01','Ahmedabad','active'),
(2,'Rahul Shah','rahul.shah@gmail.com','9000000002','2000-05-12','Surat','active'),
(3,'Priya Mehta','priya.mehta@gmail.com','9000000003','1999-07-21','Mumbai','active'),
(4,'Aman Jain','aman.jain@gmail.com','9000000004','2001-03-10','Delhi','active'),
(5,'Sneha Kapoor','sneha.kapoor@gmail.com','9000000005','2002-11-25','Pune','active'),
(6,'Rohit Verma','rohit.verma@gmail.com','9000000006','1998-09-15','Jaipur','active'),
(7,'Anjali Singh','anjali.singh@gmail.com','9000000007','2000-08-20','Lucknow','active'),
(8,'Karan Patel','karan.patel@gmail.com','9000000008','2001-06-18','Ahmedabad','active'),
(9,'Neha Sharma','neha.sharma@gmail.com','9000000009','1997-12-05','Delhi','active'),
(10,'Saurabh Gupta','saurabh.gupta@gmail.com','9000000010','1996-10-22','Noida','active'),
(11,'Pooja Desai','pooja.desai@gmail.com','9000000011','1999-02-14','Vadodara','active'),
(12,'Harsh Mehta','harsh.mehta@gmail.com','9000000012','2002-04-11','Rajkot','active'),
(13,'Ritika Kapoor','ritika.kapoor@gmail.com','9000000013','2000-07-09','Chandigarh','active'),
(14,'Deepak Nair','deepak.nair@gmail.com','9000000014','1998-01-30','Kochi','active'),
(15,'Manish Kumar','manish.kumar@gmail.com','9000000015','1997-03-18','Patna','active'),
(16,'Simran Kaur','simran.kaur@gmail.com','9000000016','2001-05-05','Amritsar','active'),
(17,'Arjun Reddy','arjun.reddy@gmail.com','9000000017','1996-11-11','Hyderabad','active'),
(18,'Nikita Joshi','nikita.joshi@gmail.com','9000000018','1999-09-23','Indore','active'),
(19,'Yash Agarwal','yash.agarwal@gmail.com','9000000019','2002-08-08','Kanpur','active'),
(20,'Tanvi Shah','tanvi.shah@gmail.com','9000000020','2001-02-02','Surat','active'),
(21,'Kunal Bansal','kunal.bansal@gmail.com','9000000021','1998-06-16','Delhi','active'),
(22,'Aditi Iyer','aditi.iyer@gmail.com','9000000022','1997-07-27','Chennai','active'),
(23,'Varun Malhotra','varun.malhotra@gmail.com','9000000023','1996-12-19','Delhi','active'),
(24,'Megha Arora','megha.arora@gmail.com','9000000024','2000-10-10','Gurgaon','active'),
(25,'Ravi Teja','ravi.teja@gmail.com','9000000025','1999-04-04','Hyderabad','active');

-- FIX 1: Routes 7 & 17 had vendor_id=38 (non-existent). Changed to vendor_id=7 (Air India).
INSERT INTO Transport_Route (route_id, transport_mode, origin_city, destination_city, vehicle_number, vendor_id)
VALUES
(1,'train','Delhi','Mumbai','12951',2),
(2,'flight','Mumbai','Bangalore','6E203',4),
(3,'bus','Ahmedabad','Udaipur','GJ01AB1234',13),
(4,'flight','Delhi','Goa','AI401',7),
(5,'train','Chennai','Hyderabad','12604',2),
(6,'bus','Pune','Mumbai','MH12XY4567',14),
(7,'flight','Delhi','Kolkata','UK707',7),      -- FIXED: 38 → 7 (Air India)
(8,'train','Kolkata','Patna','12367',2),
(9,'bus','Jaipur','Delhi','RJ14AB7890',15),
(10,'flight','Bangalore','Chennai','6E455',4),
(11,'train','Mumbai','Ahmedabad','12932',2),
(12,'flight','Hyderabad','Delhi','AI502',7),
(13,'bus','Surat','Mumbai','GJ05CD2345',13),
(14,'flight','Goa','Mumbai','SG812',6),
(15,'train','Lucknow','Delhi','12004',2),
(16,'bus','Indore','Bhopal','MP09XY1122',14),
(17,'flight','Chandigarh','Delhi','UK981',7),   -- FIXED: 38 → 7 (Air India)
(18,'train','Patna','Kolkata','12352',2),
(19,'bus','Nagpur','Pune','MH31AB7788',15),
(20,'flight','Delhi','Ahmedabad','6E101',4);

INSERT INTO Route_Schedule (schedule_id, route_id, departure_time, arrival_time, days_of_week, is_active)
VALUES
(1,1,'08:00','20:00','Mon,Wed,Fri',TRUE),
(2,1,'16:00','06:00','Tue,Thu,Sat',TRUE),
(3,2,'09:30','11:30','Daily',TRUE),
(4,2,'18:00','20:00','Mon,Fri',TRUE),
(5,3,'06:00','12:00','Daily',TRUE),
(6,3,'14:00','20:00','Tue,Thu,Sat',TRUE),
(7,4,'07:30','10:00','Daily',TRUE),
(8,4,'19:00','21:30','Mon,Wed,Fri',TRUE),
(9,5,'05:45','11:30','Daily',TRUE),
(10,5,'17:00','22:30','Tue,Thu,Sat',TRUE),
(11,6,'08:00','12:00','Daily',TRUE),
(12,6,'18:00','22:00','Fri,Sat,Sun',TRUE),
(13,7,'06:00','08:30','Daily',TRUE),
(14,7,'20:00','22:30','Mon,Thu',TRUE),
(15,8,'07:00','13:00','Daily',TRUE),
(16,8,'15:00','21:00','Tue,Sat',TRUE),
(17,9,'06:30','11:00','Daily',TRUE),
(18,9,'17:30','22:00','Fri,Sun',TRUE),
(19,10,'09:00','10:30','Daily',TRUE),
(20,10,'19:30','21:00','Mon,Fri',TRUE),
(21,11,'06:00','12:00','Daily',TRUE),
(22,12,'08:00','10:30','Daily',TRUE),
(23,13,'07:30','11:30','Daily',TRUE),
(24,14,'10:00','11:30','Daily',TRUE),
(25,15,'06:15','09:00','Daily',TRUE);

INSERT INTO Schedule_Class (class_id, class_name, total_seats, base_fare)
VALUES
(1, 'Economy', 180, 2000.00),
(2, 'Premium Economy', 120, 3500.00),
(3, 'Business', 60, 7000.00),
(4, 'Sleeper', 200, 900.00),
(5, 'AC First Class', 40, 5000.00);

INSERT INTO Route_Schedule_Class (schedule_id, class_id)
VALUES
-- Route 1 (train)
(1,4),(1,5),
(2,4),(2,5),
-- Route 2 (flight)
(3,1),(3,3),
(4,1),(4,3),
-- Route 3 (bus)
(5,1),
(6,1),
-- Route 4 (flight)
(7,1),(7,3),
(8,1),(8,3),
-- Route 5 (train)
(9,4),(9,5),
(10,4),(10,5),
-- Route 6 (bus)
(11,1),
(12,1),
-- Route 7 (flight)
(13,1),(13,3),
(14,1),(14,3),
-- Route 8 (train)
(15,4),(15,5),
(16,4),(16,5),
-- Route 9 (bus)
(17,1),
(18,1),
-- Route 10 (flight)
(19,1),(19,3),
(20,1),(20,3),
-- Extra schedules
(21,4),(21,5),
(22,1),(22,3),
(23,1),
(24,1),(24,3),
(25,4);

INSERT INTO Schedule_Departure
(departure_id, schedule_id, class_id, departure_date, available_seats, dynamic_fare, status)
VALUES
(1,1,4,'2026-05-01',150,NULL,'scheduled'),
(2,1,5,'2026-05-01',30,5500,'scheduled'),
(3,2,4,'2026-05-02',140,NULL,'scheduled'),
(4,2,5,'2026-05-02',25,6000,'scheduled'),
(5,3,1,'2026-05-01',120,NULL,'scheduled'),
(6,3,3,'2026-05-01',40,8000,'scheduled'),
(7,4,1,'2026-05-03',100,NULL,'scheduled'),
(8,4,3,'2026-05-03',35,8500,'scheduled'),
(9,5,1,'2026-05-01',50,NULL,'scheduled'),
(10,6,1,'2026-05-02',45,NULL,'scheduled'),
(11,7,1,'2026-05-01',110,NULL,'scheduled'),
(12,7,3,'2026-05-01',50,7500,'scheduled'),
(13,8,1,'2026-05-02',95,NULL,'scheduled'),
(14,8,3,'2026-05-02',30,8200,'scheduled'),
(15,9,4,'2026-05-01',180,NULL,'scheduled'),
(16,9,5,'2026-05-01',35,5200,'scheduled'),
(17,10,4,'2026-05-03',160,NULL,'scheduled'),
(18,10,5,'2026-05-03',30,5800,'scheduled'),
(19,11,1,'2026-05-01',60,NULL,'scheduled'),
(20,12,1,'2026-05-02',55,NULL,'scheduled'),
(21,13,1,'2026-05-01',130,NULL,'scheduled'),
(22,13,3,'2026-05-01',45,7800,'scheduled'),
(23,14,1,'2026-05-02',100,NULL,'scheduled'),
(24,14,3,'2026-05-02',35,8200,'scheduled'),
(25,15,4,'2026-05-01',170,NULL,'scheduled'),
(26,15,5,'2026-05-01',28,5400,'scheduled'),
(27,16,4,'2026-05-03',160,NULL,'scheduled'),
(28,16,5,'2026-05-03',25,6000,'scheduled'),
(29,17,1,'2026-05-01',50,NULL,'scheduled'),
(30,18,1,'2026-05-02',48,NULL,'scheduled'),
(31,19,1,'2026-05-01',115,NULL,'scheduled'),
(32,19,3,'2026-05-01',42,7700,'scheduled'),
(33,20,1,'2026-05-02',105,NULL,'scheduled'),
(34,20,3,'2026-05-02',38,8100,'scheduled'),
(35,21,4,'2026-05-01',150,NULL,'scheduled'),
(36,22,1,'2026-05-02',110,NULL,'scheduled'),
(37,22,3,'2026-05-02',40,7900,'scheduled'),
(38,23,1,'2026-05-01',60,NULL,'scheduled'),
(39,24,1,'2026-05-02',100,NULL,'scheduled'),
(40,25,4,'2026-05-03',140,NULL,'scheduled');

-- FIX 2: Hotels 9-14 had non-existent vendor_ids (32,33,34,35,36,100).
-- Replaced with valid hotel vendor IDs from existing Vendor table.
INSERT INTO Hotel (hotel_id, hotel_name, city, full_address, star_rating, checkin_time, checkout_time, vendor_id)
VALUES
(1,'Taj Palace','Delhi','Diplomatic Enclave, New Delhi',5.0,'14:00','12:00',1),
(2,'OYO Residency','Mumbai','Andheri East, Mumbai',3.5,'13:00','11:00',5),
(3,'Leela Palace','Udaipur','Lake Pichola Road, Udaipur',5.0,'14:00','12:00',19),
(4,'ITC Grand Chola','Chennai','Guindy, Chennai',5.0,'15:00','12:00',20),
(5,'Treebo Trend Hotel','Bangalore','Indiranagar, Bangalore',3.0,'12:00','11:00',10),
(6,'Lemon Tree Premier','Delhi','Aerocity, Delhi',4.0,'14:00','12:00',21),
(7,'Sarovar Portico','Jaipur','MI Road, Jaipur',4.0,'13:00','11:00',22),
(8,'FabHotel Prime','Pune','Shivaji Nagar, Pune',3.5,'12:00','10:00',11),
(9,'Radisson Blu','Mumbai','Andheri West, Mumbai',5.0,'14:00','12:00',1),   -- FIXED: 32 → 1 (Taj Hotels)
(10,'Hyatt Regency','Delhi','Bhikaji Cama Place, Delhi',5.0,'15:00','12:00',19), -- FIXED: 33 → 19 (Leela Hotels)
(11,'Marriott Courtyard','Ahmedabad','Satellite Road, Ahmedabad',4.5,'14:00','12:00',20), -- FIXED: 34 → 20 (ITC Hotels)
(12,'Novotel','Hyderabad','Hitech City, Hyderabad',4.5,'14:00','12:00',21), -- FIXED: 35 → 21 (Lemon Tree)
(13,'Accor Grand','Kolkata','Salt Lake, Kolkata',4.0,'13:00','11:00',22),   -- FIXED: 36 → 22 (Sarovar Hotels)
(14,'Royal Orchid','Bangalore','Old Airport Road, Bangalore',4.0,'14:00','12:00',10), -- FIXED: 100 → 10 (Treebo Hotels)
(15,'Sterling Resort','Manali','Mall Road, Manali',4.0,'12:00','10:00',18),
(16,'Club Mahindra Resort','Goa','Baga Beach, Goa',4.5,'15:00','12:00',16),
(17,'Taj Fort Aguada','Goa','Candolim, Goa',5.0,'14:00','12:00',1),
(18,'ITC Rajputana','Jaipur','Palace Road, Jaipur',5.0,'14:00','12:00',20),
(19,'Leela Kovalam','Kerala','Kovalam Beach, Kerala',5.0,'15:00','12:00',19),
(20,'OYO Townhouse','Hyderabad','Banjara Hills, Hyderabad',3.0,'12:00','11:00',5);

INSERT INTO Hotel_Amenity (hotel_id, amenity)
VALUES
(1,'Free WiFi'),(1,'Swimming Pool'),(1,'Spa'),(1,'Gym'),
(2,'Free WiFi'),(2,'Air Conditioning'),
(3,'Lake View'),(3,'Spa'),(3,'Swimming Pool'),
(4,'Conference Hall'),(4,'Gym'),(4,'Restaurant'),
(5,'Free WiFi'),(5,'Parking'),
(6,'Free WiFi'),(6,'Gym'),
(7,'Restaurant'),(7,'Parking'),
(8,'Free WiFi'),(8,'Room Service'),
(9,'Swimming Pool'),(9,'Bar'),(9,'Gym'),
(10,'Spa'),(10,'Conference Hall'),
(11,'Free WiFi'),(11,'Parking'),
(12,'Swimming Pool'),(12,'Gym'),
(13,'Restaurant'),(13,'Free WiFi'),
(14,'Bar'),(14,'Parking'),
(15,'Mountain View'),(15,'Fireplace'),
(16,'Beach Access'),(16,'Swimming Pool'),
(17,'Beach View'),(17,'Spa'),
(18,'Heritage Property'),(18,'Restaurant'),
(19,'Sea View'),(19,'Spa'),
(20,'Free WiFi'),(20,'Air Conditioning');

INSERT INTO Room_Category
(room_category_id, hotel_id, category_name, max_guests, price_per_night, total_rooms)
VALUES
(1,1,'Deluxe Room',2,8000,20),
(2,1,'Executive Suite',3,15000,10),
(3,2,'Standard Room',2,2500,30),
(4,2,'Deluxe Room',2,3500,20),
(5,3,'Lake View Suite',3,18000,12),
(6,3,'Royal Suite',4,25000,8),
(7,4,'Luxury Room',2,12000,25),
(8,4,'Presidential Suite',4,30000,5),
(9,5,'Standard Room',2,2000,40),
(10,5,'Premium Room',3,4000,20),
(11,6,'Business Room',2,7000,30),
(12,6,'Executive Room',3,9000,15),
(13,7,'Standard Room',2,5000,25),
(14,7,'Suite',3,10000,10),
(15,8,'Budget Room',2,1800,35),
(16,8,'Deluxe Room',2,3000,20),
(17,9,'Luxury Suite',3,14000,15),
(18,9,'Club Room',2,10000,20),
(19,10,'Premium Room',2,13000,18),
(20,10,'Suite',3,20000,10),
(21,11,'Executive Room',2,9000,22),
(22,11,'Suite',3,16000,12),
(23,12,'Standard Room',2,6000,30),
(24,12,'Premium Room',3,10000,15),
(25,13,'Classic Room',2,5500,25),
(26,13,'Suite',3,11000,10),
(27,14,'Deluxe Room',2,7000,20),
(28,14,'Suite',3,14000,8),
(29,15,'Mountain View Room',2,8000,18),
(30,16,'Beach View Room',2,12000,15);

INSERT INTO Room_Availability (room_category_id, available_date, available_rooms)
VALUES
(1,'2026-05-01',10),(1,'2026-05-02',8),
(2,'2026-05-01',5),(2,'2026-05-02',4),
(3,'2026-05-01',20),(3,'2026-05-02',18),
(4,'2026-05-01',15),(4,'2026-05-02',12),
(5,'2026-05-01',6),(5,'2026-05-02',5),
(6,'2026-05-01',3),(6,'2026-05-02',2),
(7,'2026-05-01',18),(7,'2026-05-02',16),
(8,'2026-05-01',2),(8,'2026-05-02',1),
(9,'2026-05-01',25),(9,'2026-05-02',22),
(10,'2026-05-01',12),(10,'2026-05-02',10),
(11,'2026-05-01',20),(11,'2026-05-02',18),
(12,'2026-05-01',10),(12,'2026-05-02',9),
(13,'2026-05-01',14),(13,'2026-05-02',12),
(14,'2026-05-01',6),(14,'2026-05-02',5),
(15,'2026-05-01',28),(15,'2026-05-02',25),
(16,'2026-05-01',15),(16,'2026-05-02',13),
(17,'2026-05-01',10),(17,'2026-05-02',8),
(18,'2026-05-01',14),(18,'2026-05-02',12),
(19,'2026-05-01',9),(19,'2026-05-02',7),
(20,'2026-05-01',5),(20,'2026-05-02',4),
(21,'2026-05-01',12),(21,'2026-05-02',10),
(22,'2026-05-01',6),(22,'2026-05-02',5),
(23,'2026-05-01',20),(23,'2026-05-02',18),
(24,'2026-05-01',11),(24,'2026-05-02',9),
(25,'2026-05-01',17),(25,'2026-05-02',15);

INSERT INTO Holiday_Package
(package_id, package_name, theme, duration_days, duration_nights, base_price_per_person, is_active, vendor_id)
VALUES
(1,'Goa Beach Escape','Leisure',5,4,15000,TRUE,3),
(2,'Manali Adventure Tour','Adventure',6,5,18000,TRUE,3),
(3,'Kerala Backwaters Retreat','Relaxation',4,3,14000,TRUE,3),
(4,'Rajasthan Heritage Tour','Cultural',7,6,22000,TRUE,3),
(5,'Kashmir Paradise','Honeymoon',5,4,20000,TRUE,3),
(6,'Andaman Island Getaway','Leisure',6,5,25000,TRUE,3),
(7,'Ladakh Bike Expedition','Adventure',8,7,30000,TRUE,3),
(8,'Golden Triangle Tour','Cultural',5,4,17000,TRUE,3),
(9,'Sikkim Darjeeling Escape','Nature',6,5,19000,TRUE,3),
(10,'Coorg Coffee Trails','Relaxation',4,3,13000,TRUE,3),
(11,'Ooty Hill Station Trip','Nature',3,2,11000,TRUE,3),
(12,'Goa Party Special','Leisure',4,3,16000,TRUE,3),
(13,'Shimla Kullu Manali Combo','Adventure',7,6,21000,TRUE,3),
(14,'Varanasi Spiritual Tour','Spiritual',3,2,9000,TRUE,3),
(15,'Meghalaya Waterfall Trail','Nature',5,4,18000,TRUE,3);

INSERT INTO Package_Hotel (package_id, hotel_id)
VALUES
(1,17),(1,16),
(2,15),
(3,19),
(4,18),(4,7),
(5,19),
(6,17),
(7,15),
(8,1),(8,7),
(9,15),
(10,5),
(11,5),
(12,17),
(13,15),(13,7),
(14,1),
(15,15);

INSERT INTO Package_Transport (package_id, departure_id)
VALUES
(1,5),(1,6),
(2,15),(2,16),
(3,21),
(4,25),(4,26),
(5,31),(5,32),
(6,7),(6,8),
(7,17),(7,18),
(8,11),(8,12),
(9,21),(9,22),
(10,9),
(11,9),
(12,5),(12,6),
(13,15),(13,16),
(14,1),
(15,21);

INSERT INTO Package_Departure
(package_departure_id, package_id, departure_date, total_seats, available_seats, price_per_person, status)
VALUES
(1,1,'2026-06-01',40,30,15500,'open'),
(2,1,'2026-06-15',40,28,16000,'open'),
(3,2,'2026-06-05',35,25,18500,'open'),
(4,2,'2026-06-20',35,20,19000,'open'),
(5,3,'2026-06-03',30,22,14500,'open'),
(6,3,'2026-06-18',30,18,15000,'open'),
(7,4,'2026-06-10',45,35,23000,'open'),
(8,4,'2026-06-25',45,30,23500,'open'),
(9,5,'2026-06-08',40,32,20500,'open'),
(10,5,'2026-06-22',40,29,21000,'open'),
(11,6,'2026-06-12',30,24,26000,'open'),
(12,6,'2026-06-28',30,20,26500,'open'),
(13,7,'2026-06-15',25,18,31000,'open'),
(14,7,'2026-06-30',25,15,32000,'open'),
(15,8,'2026-06-05',40,30,17500,'open'),
(16,8,'2026-06-20',40,26,18000,'open'),
(17,9,'2026-06-07',35,28,19500,'open'),
(18,9,'2026-06-21',35,25,20000,'open'),
(19,10,'2026-06-04',30,22,13500,'open'),
(20,10,'2026-06-18',30,20,14000,'open'),
(21,11,'2026-06-06',25,18,11500,'open'),
(22,12,'2026-06-09',35,27,16500,'open'),
(23,13,'2026-06-14',40,30,22000,'open'),
(24,14,'2026-06-11',20,15,9500,'open'),
(25,15,'2026-06-16',30,24,18500,'open');

INSERT INTO Promo_Code
(promo_id, code, discount_type, discount_value, max_discount_cap, min_booking_amt, valid_from, valid_to, applicable_on, used_count, is_active)
VALUES
(1,'WELCOME10','percent',10,2000,5000,'2026-01-01','2026-12-31','all',0,TRUE),
(2,'FLAT500','flat',500,NULL,2000,'2026-01-01','2026-12-31','hotel',0,TRUE),
(3,'TRAVEL20','percent',20,3000,7000,'2026-01-01','2026-12-31','transport',0,TRUE),
(4,'PKG15','percent',15,2500,8000,'2026-01-01','2026-12-31','package',0,TRUE),
(5,'SUMMER300','flat',300,NULL,1500,'2026-03-01','2026-06-30','all',0,TRUE),
(6,'FLIGHT10','percent',10,1500,4000,'2026-01-01','2026-12-31','transport',0,TRUE),
(7,'HOTEL20','percent',20,3000,6000,'2026-01-01','2026-12-31','hotel',0,TRUE),
(8,'BUS200','flat',200,NULL,1000,'2026-01-01','2026-12-31','transport',0,TRUE),
(9,'NEWUSER','percent',15,2000,3000,'2026-01-01','2026-12-31','all',0,TRUE),
(10,'GOA500','flat',500,NULL,5000,'2026-01-01','2026-12-31','package',0,TRUE),
(11,'WEEKEND10','percent',10,1500,3000,'2026-01-01','2026-12-31','hotel',0,TRUE),
(12,'LUXURY20','percent',20,5000,10000,'2026-01-01','2026-12-31','hotel',0,TRUE),
(13,'TRAIN100','flat',100,NULL,800,'2026-01-01','2026-12-31','transport',0,TRUE),
(14,'EARLYBIRD','percent',12,2500,4000,'2026-01-01','2026-12-31','all',0,TRUE),
(15,'FESTIVE25','percent',25,4000,8000,'2026-10-01','2026-12-31','all',0,TRUE);

INSERT INTO Booking
(booking_id, user_id, booking_type, booked_at, status, base_amount, discount_amount, final_amount, payment_method, payment_ref, promo_id)
VALUES
(1,1,'hotel',CURRENT_TIMESTAMP,'confirmed',8000,800,7200,'card','TXN1001',1),
(2,2,'transport',CURRENT_TIMESTAMP,'confirmed',2000,200,1800,'upi','TXN1002',3),
(3,3,'package',CURRENT_TIMESTAMP,'confirmed',15000,1500,13500,'card','TXN1003',4),
(4,4,'hotel',CURRENT_TIMESTAMP,'completed',7000,500,6500,'netbanking','TXN1004',2),
(5,5,'transport',CURRENT_TIMESTAMP,'cancelled',3000,200,2800,'card','TXN1005',8),
(6,6,'hotel',CURRENT_TIMESTAMP,'confirmed',9000,900,8100,'upi','TXN1006',7),
(7,7,'transport',CURRENT_TIMESTAMP,'confirmed',2500,250,2250,'card','TXN1007',6),
(8,8,'package',CURRENT_TIMESTAMP,'pending',18000,1800,16200,'wallet','TXN1008',4),
(9,9,'hotel',CURRENT_TIMESTAMP,'confirmed',6000,600,5400,'card','TXN1009',11),
(10,10,'transport',CURRENT_TIMESTAMP,'completed',2200,100,2100,'upi','TXN1010',13),
(11,11,'package',CURRENT_TIMESTAMP,'confirmed',17000,1700,15300,'card','TXN1011',14),
(12,12,'hotel',CURRENT_TIMESTAMP,'confirmed',7500,750,6750,'upi','TXN1012',7),
(13,13,'transport',CURRENT_TIMESTAMP,'confirmed',1800,100,1700,'card','TXN1013',13),
(14,14,'package',CURRENT_TIMESTAMP,'completed',20000,2000,18000,'netbanking','TXN1014',4),
(15,15,'hotel',CURRENT_TIMESTAMP,'cancelled',6500,500,6000,'wallet','TXN1015',2),
(16,16,'transport',CURRENT_TIMESTAMP,'confirmed',2400,200,2200,'card','TXN1016',3),
(17,17,'package',CURRENT_TIMESTAMP,'confirmed',21000,2100,18900,'upi','TXN1017',4),
(18,18,'hotel',CURRENT_TIMESTAMP,'completed',8500,850,7650,'card','TXN1018',12),
(19,19,'transport',CURRENT_TIMESTAMP,'confirmed',2600,200,2400,'upi','TXN1019',6),
(20,20,'package',CURRENT_TIMESTAMP,'pending',19000,1900,17100,'wallet','TXN1020',14),
(21,21,'hotel',CURRENT_TIMESTAMP,'confirmed',7200,700,6500,'card','TXN1021',1),
(22,22,'transport',CURRENT_TIMESTAMP,'completed',2100,150,1950,'upi','TXN1022',13),
(23,23,'package',CURRENT_TIMESTAMP,'confirmed',22000,2200,19800,'card','TXN1023',15),
(24,24,'hotel',CURRENT_TIMESTAMP,'confirmed',6800,600,6200,'netbanking','TXN1024',7),
(25,25,'transport',CURRENT_TIMESTAMP,'cancelled',2300,150,2150,'wallet','TXN1025',8),
(26,1,'package',CURRENT_TIMESTAMP,'confirmed',16000,1600,14400,'card','TXN1026',4),
(27,2,'hotel',CURRENT_TIMESTAMP,'confirmed',7800,700,7100,'upi','TXN1027',11),
(28,3,'transport',CURRENT_TIMESTAMP,'completed',2000,100,1900,'card','TXN1028',13),
(29,4,'package',CURRENT_TIMESTAMP,'confirmed',21000,2000,19000,'netbanking','TXN1029',4),
(30,5,'hotel',CURRENT_TIMESTAMP,'confirmed',8200,800,7400,'wallet','TXN1030',12),
(31,6,'transport',CURRENT_TIMESTAMP,'confirmed',2400,200,2200,'card','TXN1031',6),
(32,7,'package',CURRENT_TIMESTAMP,'pending',18000,1500,16500,'upi','TXN1032',14),
(33,8,'hotel',CURRENT_TIMESTAMP,'completed',7500,700,6800,'card','TXN1033',7),
(34,9,'transport',CURRENT_TIMESTAMP,'confirmed',2200,150,2050,'upi','TXN1034',3),
(35,10,'package',CURRENT_TIMESTAMP,'confirmed',20000,2000,18000,'card','TXN1035',4),
(36,11,'hotel',CURRENT_TIMESTAMP,'confirmed',7000,600,6400,'netbanking','TXN1036',2),
(37,12,'transport',CURRENT_TIMESTAMP,'completed',2100,150,1950,'upi','TXN1037',13),
(38,13,'package',CURRENT_TIMESTAMP,'confirmed',19000,1800,17200,'wallet','TXN1038',14),
(39,14,'hotel',CURRENT_TIMESTAMP,'confirmed',8500,800,7700,'card','TXN1039',12),
(40,15,'transport',CURRENT_TIMESTAMP,'cancelled',2300,200,2100,'upi','TXN1040',8);

INSERT INTO Transport_Booking (booking_id, departure_id, num_seats)
VALUES
(2,5,2),
(5,9,1),
(7,11,2),
(10,13,1),
(13,19,1),
(16,21,2),
(19,23,1),
(22,31,1),
(25,29,2),
(28,33,1),
(31,35,2),
(34,37,1),
(37,39,2),
(40,30,1);

INSERT INTO Passenger_List
(booking_id, passenger_name, age, gender, govt_id_type, govt_id_number)
VALUES
(2,'Ravi Kumar',30,'male','aadhar','A123456789'),
(2,'Amit Singh',28,'male','passport','P987654321'),
(5,'Suresh Patel',35,'male','pan','ABCDE1234F'),
(7,'Neha Sharma',26,'female','aadhar','A223456789'),
(7,'Karan Mehta',29,'male','passport','P123456789'),
(10,'Rahul Verma',32,'male','voter_id','V11223344'),
(13,'Pooja Shah',27,'female','aadhar','A323456789'),
(16,'Ankit Jain',31,'male','pan','FGHIJ5678K'),
(16,'Simran Kaur',25,'female','passport','P765432198'),
(19,'Rohit Agarwal',34,'male','aadhar','A423456789'),
(22,'Deepak Nair',29,'male','passport','P998877665'),
(25,'Sneha Kapoor',24,'female','aadhar','A523456789'),
(25,'Megha Arora',28,'female','voter_id','V55667788'),
(28,'Yash Gupta',33,'male','pan','LMNOP1234Q'),
(31,'Arjun Reddy',30,'male','aadhar','A623456789'),
(31,'Nikita Joshi',27,'female','passport','P112233445'),
(34,'Varun Malhotra',35,'male','voter_id','V66778899'),
(37,'Harsh Mehta',26,'male','aadhar','A723456789'),
(37,'Tanvi Shah',24,'female','passport','P556677889'),
(40,'Kunal Bansal',31,'male','pan','QRSTU5678V');

INSERT INTO Hotel_Booking
(booking_id, room_category_id, checkin_date, checkout_date, num_rooms, num_guests)
VALUES
(1,1,'2026-05-01','2026-05-03',1,2),
(4,4,'2026-05-02','2026-05-05',2,4),
(6,11,'2026-05-03','2026-05-06',1,2),
(9,3,'2026-05-01','2026-05-04',1,2),
(12,12,'2026-05-05','2026-05-07',1,2),
(15,3,'2026-05-02','2026-05-04',1,2),
(18,17,'2026-05-06','2026-05-08',1,2),
(21,1,'2026-05-03','2026-05-06',2,3),
(24,7,'2026-05-07','2026-05-09',1,2),
(27,10,'2026-05-04','2026-05-06',1,2),
(30,2,'2026-05-05','2026-05-08',2,4),
(33,16,'2026-05-06','2026-05-08',1,2),
(36,13,'2026-05-01','2026-05-03',1,2),
(39,19,'2026-05-08','2026-05-10',1,2);

INSERT INTO Guest_List
(guest_id, booking_id, guest_name, age, gender, govt_id_type, govt_id_number)
VALUES
(1,1,'Vatsal Mori',23,'male','aadhar','A111111111'),
(2,1,'Rahul Shah',25,'male','passport','P222222222'),
(3,4,'Aman Jain',24,'male','pan','ABCDE1234F'),
(4,4,'Sneha Kapoor',22,'female','aadhar','A333333333'),
(5,6,'Rohit Verma',28,'male','aadhar','A444444444'),
(6,6,'Anjali Singh',26,'female','passport','P555555555'),
(7,9,'Karan Patel',27,'male','voter_id','V11112222'),
(8,9,'Neha Sharma',24,'female','aadhar','A666666666'),
(9,12,'Saurabh Gupta',29,'male','pan','FGHIJ5678K'),
(10,15,'Pooja Desai',26,'female','aadhar','A777777777'),
(11,15,'Harsh Mehta',27,'male','passport','P888888888'),
(12,18,'Ritika Kapoor',25,'female','aadhar','A999999999'),
(13,21,'Deepak Nair',30,'male','passport','P123123123'),
(14,21,'Manish Kumar',32,'male','pan','LMNOP1234Q'),
(15,24,'Simran Kaur',24,'female','aadhar','A101010101'),
(16,27,'Arjun Reddy',31,'male','passport','P202020202'),
(17,27,'Nikita Joshi',28,'female','aadhar','A303030303'),
(18,30,'Yash Agarwal',29,'male','pan','QRSTU5678V'),
(19,30,'Tanvi Shah',26,'female','aadhar','A404040404'),
(20,33,'Kunal Bansal',30,'male','passport','P505050505'),
(21,36,'Aditi Iyer',27,'female','aadhar','A606060606'),
(22,36,'Varun Malhotra',33,'male','voter_id','V90909090'),
(23,39,'Megha Arora',25,'female','aadhar','A707070707'),
(24,39,'Ravi Teja',29,'male','passport','P808080808');

INSERT INTO Package_Booking
(booking_id, package_departure_id, num_travellers)
VALUES
(3,1,2),
(8,3,3),
(11,5,2),
(14,7,4),
(17,9,2),
(20,11,3),
(23,13,2),
(26,15,3),
(29,17,2),
(32,19,4),
(35,21,2),
(38,23,3);

INSERT INTO Package_Traveller
(booking_id, traveller_name, age, gender, govt_id_type, govt_id_number)
VALUES
(3,'Priya Mehta',26,'female','aadhar','A111222333'),
(3,'Rahul Verma',30,'male','passport','P123456789'),
(8,'Sneha Kapoor',24,'female','aadhar','A222333444'),
(8,'Aman Jain',28,'male','pan','ABCDE6789F'),
(8,'Rohit Sharma',32,'male','passport','P987654321'),
(11,'Pooja Shah',27,'female','aadhar','A333444555'),
(11,'Karan Mehta',29,'male','passport','P456789123'),
(14,'Deepak Nair',31,'male','aadhar','A444555666'),
(14,'Anjali Singh',26,'female','passport','P789123456'),
(14,'Manish Kumar',34,'male','pan','FGHIJ1234K'),
(14,'Simran Kaur',25,'female','aadhar','A555666777'),
(17,'Ritika Kapoor',28,'female','passport','P321654987'),
(17,'Arjun Reddy',30,'male','aadhar','A666777888'),
(20,'Yash Agarwal',29,'male','pan','LMNOP5678Q'),
(20,'Tanvi Shah',26,'female','aadhar','A777888999'),
(20,'Nikita Joshi',27,'female','passport','P654987321'),
(23,'Kunal Bansal',31,'male','aadhar','A888999000'),
(23,'Megha Arora',25,'female','passport','P147258369'),
(26,'Ravi Teja',30,'male','aadhar','A999000111'),
(26,'Aditi Iyer',27,'female','passport','P258369147'),
(26,'Varun Malhotra',33,'male','pan','QRSTU1234V'),
(29,'Harsh Mehta',28,'male','aadhar','A121212121'),
(29,'Pooja Desai',26,'female','passport','P343434343'),
(32,'Saurabh Gupta',30,'male','aadhar','A565656565'),
(32,'Neha Sharma',24,'female','passport','P787878787'),
(32,'Karan Patel',27,'male','pan','ABCDE9999F'),
(32,'Simran Kaur',25,'female','aadhar','A909090909'),
(35,'Rohit Verma',32,'male','passport','P111222333'),
(35,'Ankit Jain',29,'male','aadhar','A232323232'),
(38,'Deepika Singh',27,'female','passport','P454545454'),
(38,'Rahul Shah',30,'male','aadhar','A676767676'),
(38,'Nikhil Gupta',31,'male','pan','LMNOP8888Q');

INSERT INTO Insurance
(insurance_id, provider_name, plan_name, coverage_summary, premium_amount, valid_from, valid_to, claim_status)
VALUES
(1,'LIC','Basic Travel Cover','Medical emergencies and trip cancellation',500,'2026-01-01','2026-12-31','none'),
(2,'HDFC Ergo','Premium Travel Plan','Flight delay, baggage loss, medical',1200,'2026-01-01','2026-12-31','none'),
(3,'ICICI Lombard','Standard Plan','Hospitalization and evacuation',800,'2026-01-01','2026-12-31','filed'),
(4,'Bajaj Allianz','Gold Plan','Comprehensive travel insurance',1500,'2026-01-01','2026-12-31','approved'),
(5,'TATA AIG','Silver Plan','Basic trip coverage',700,'2026-01-01','2026-12-31','rejected'),
(6,'Reliance General','Travel Secure','Accidental and medical cover',900,'2026-01-01','2026-12-31','none'),
(7,'Star Health','Travel Plus','Health + trip insurance',1100,'2026-01-01','2026-12-31','none'),
(8,'New India Assurance','Standard Cover','Trip cancellation + baggage',750,'2026-01-01','2026-12-31','filed'),
(9,'SBI General','Travel Shield','Medical + travel risks',950,'2026-01-01','2026-12-31','approved'),
(10,'Aditya Birla Health','Premium Shield','Full coverage plan',1300,'2026-01-01','2026-12-31','none');

INSERT INTO Booking_Insurance (booking_id, insurance_id)
VALUES
(1,1),(2,2),(3,3),(4,4),(6,5),
(7,6),(8,7),(9,1),(10,2),(11,3),
(12,4),(14,5),(16,6),(17,7),(18,8),
(20,9),(21,10),(23,1),(26,2),(30,3);

INSERT INTO Review
(review_id, user_id, entity_type, entity_id, star_rating, title, comment, reviewed_at)
VALUES
(1,1,'hotel',1,4.5,'Great Stay','Very comfortable rooms and excellent service.',CURRENT_TIMESTAMP),
(2,2,'transport',1,4.0,'Smooth Journey','Train was on time and clean.',CURRENT_TIMESTAMP),
(3,3,'package',1,5.0,'Amazing Trip','Everything was well organized.',CURRENT_TIMESTAMP),
(4,4,'hotel',2,3.5,'Decent','Good stay but room service was slow.',CURRENT_TIMESTAMP),
(5,5,'transport',2,4.2,'Nice Flight','Comfortable seats and friendly staff.',CURRENT_TIMESTAMP),
(6,6,'hotel',3,5.0,'Luxury Experience','Beautiful location and top-notch service.',CURRENT_TIMESTAMP),
(7,7,'transport',3,3.8,'Okay Ride','Bus was decent but slightly delayed.',CURRENT_TIMESTAMP),
(8,8,'package',2,4.5,'Great Adventure','Loved the activities and planning.',CURRENT_TIMESTAMP),
(9,9,'hotel',4,4.8,'Excellent','Very clean and well maintained.',CURRENT_TIMESTAMP),
(10,10,'transport',4,4.1,'Good','Flight was smooth.',CURRENT_TIMESTAMP),
(11,11,'package',3,4.7,'Relaxing Trip','Very peaceful and well arranged.',CURRENT_TIMESTAMP),
(12,12,'hotel',5,3.9,'Average','Decent for the price.',CURRENT_TIMESTAMP),
(13,13,'transport',5,4.3,'Comfortable','Train journey was pleasant.',CURRENT_TIMESTAMP),
(14,14,'package',4,5.0,'Fantastic','Loved the cultural experience.',CURRENT_TIMESTAMP),
(15,15,'hotel',6,4.2,'Good Stay','Nice rooms and staff.',CURRENT_TIMESTAMP),
(16,16,'transport',6,3.5,'Could be better','Seats were not very comfortable.',CURRENT_TIMESTAMP),
(17,17,'package',5,4.6,'Beautiful Trip','Kashmir was amazing.',CURRENT_TIMESTAMP),
(18,18,'hotel',7,4.0,'Nice','Good location.',CURRENT_TIMESTAMP),
(19,19,'transport',7,4.4,'Great Flight','Very smooth journey.',CURRENT_TIMESTAMP),
(20,20,'package',6,4.8,'Wonderful','Loved the island trip.',CURRENT_TIMESTAMP),
(21,21,'hotel',8,3.7,'Okay','Basic facilities.',CURRENT_TIMESTAMP),
(22,22,'transport',8,4.2,'Good','Train was comfortable.',CURRENT_TIMESTAMP),
(23,23,'package',7,4.9,'Excellent','Adventure trip was thrilling.',CURRENT_TIMESTAMP),
(24,24,'hotel',9,4.5,'Great','Nice ambiance.',CURRENT_TIMESTAMP),
(25,25,'transport',9,4.1,'Good Service','Bus was on time.',CURRENT_TIMESTAMP);

INSERT INTO Cancellation
(cancellation_id, booking_id, reason, cancelled_at, refund_amount, refund_status, processed_at)
VALUES
(1,5,'Change of travel plans',CURRENT_TIMESTAMP,2500,'processed',CURRENT_TIMESTAMP),
(2,15,'Emergency situation',CURRENT_TIMESTAMP,6000,'pending',NULL),
(3,25,'Found better option',CURRENT_TIMESTAMP,2000,'processed',CURRENT_TIMESTAMP),
(4,40,'Schedule conflict',CURRENT_TIMESTAMP,1800,'failed',CURRENT_TIMESTAMP),
(5,8,'Trip postponed',CURRENT_TIMESTAMP,15000,'pending',NULL),
(6,20,'Personal reasons',CURRENT_TIMESTAMP,16000,'processed',CURRENT_TIMESTAMP),
(7,32,'Health issues',CURRENT_TIMESTAMP,14000,'pending',NULL),
(8,12,'Booking mistake',CURRENT_TIMESTAMP,5000,'processed',CURRENT_TIMESTAMP),
(9,27,'Change in plan',CURRENT_TIMESTAMP,6000,'processed',CURRENT_TIMESTAMP),
(10,30,'Weather conditions',CURRENT_TIMESTAMP,7000,'pending',NULL),
(11,33,'Rescheduled travel',CURRENT_TIMESTAMP,6500,'processed',CURRENT_TIMESTAMP),
(12,10,'Delay in service',CURRENT_TIMESTAMP,1500,'processed',CURRENT_TIMESTAMP),
(13,22,'Cancelled by user',CURRENT_TIMESTAMP,1800,'pending',NULL),
(14,18,'Upgrade booked',CURRENT_TIMESTAMP,7000,'processed',CURRENT_TIMESTAMP),
(15,36,'Duplicate booking',CURRENT_TIMESTAMP,6000,'processed',CURRENT_TIMESTAMP);
