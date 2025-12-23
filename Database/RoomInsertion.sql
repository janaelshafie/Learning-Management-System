-- -----------------------------------------------------------------
-- --- University LMS Room Insertion Script ---
-- --- Tailored for Faculty of Engineering ---
-- --- Departments: CSE, ECE, MCT, EPM, ARC, PHM, ASU ---
-- --- Run after TableCreation.sql ---
-- -----------------------------------------------------------------

USE university_lms_db;

-- Disable FK checks for bulk insertion
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- BUILDING A - MAIN ACADEMIC BUILDING
-- General Lecture Halls and Shared Classrooms
-- Used by all departments for large lectures
-- =====================================================

-- Ground Floor (A-0XX) - Large Lecture Halls for PHM, ASU courses
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building A', 'A-001', 'auditorium', 350, 'Main Auditorium - Mathematics & Physics lectures, projector, microphone system', 'available'),
('Building A', 'A-002', 'auditorium', 300, 'Large Lecture Hall - Engineering Mathematics (PHM012, PHM013)', 'available'),
('Building A', 'A-003', 'auditorium', 250, 'Lecture Hall - Physics courses (PHM021, PHM022, PHM121)', 'available'),
('Building A', 'A-004', 'auditorium', 200, 'Lecture Hall - University Requirements (ASU courses)', 'available'),
('Building A', 'A-005', 'auditorium', 200, 'Lecture Hall - Statics and Dynamics (PHM031, PHM032)', 'available'),
('Building A', 'A-006', 'auditorium', 150, 'Medium Lecture Hall - Probability & Statistics (PHM111)', 'available');

-- First Floor (A-1XX) - Classrooms for General Courses
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building A', 'A-101', 'classroom', 80, 'Classroom - Technical English (ASU011)', 'available'),
('Building A', 'A-102', 'classroom', 80, 'Classroom - Human Rights (ASU111)', 'available'),
('Building A', 'A-103', 'classroom', 70, 'Classroom - Report Writing (ASU112)', 'available'),
('Building A', 'A-104', 'classroom', 70, 'Classroom - Professional Ethics (ASU113)', 'available'),
('Building A', 'A-105', 'classroom', 60, 'Classroom - Contemporary Issues (ASU114)', 'available'),
('Building A', 'A-106', 'classroom', 60, 'Tutorial Room - Calculus tutorials', 'available'),
('Building A', 'A-107', 'classroom', 60, 'Tutorial Room - Physics tutorials', 'available'),
('Building A', 'A-108', 'classroom', 50, 'Seminar Room - Innovation & Entrepreneurship (ASU321)', 'available'),
('Building A', 'A-109', 'classroom', 50, 'Seminar Room - Business Administration (ASU336)', 'available'),
('Building A', 'A-110', 'classroom', 45, 'Language Lab - Language Course (ASU322)', 'available');

-- Second Floor (A-2XX) - More Classrooms and Meeting Rooms
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building A', 'A-201', 'classroom', 60, 'Classroom - Differential Equations (PHM112, PHM113)', 'available'),
('Building A', 'A-202', 'classroom', 60, 'Classroom - Numerical Analysis (PHM114, PHM115)', 'available'),
('Building A', 'A-203', 'classroom', 55, 'Classroom - Discrete Mathematics (PHM211)', 'available'),
('Building A', 'A-204', 'classroom', 55, 'Classroom - Complex Functions (PHM212, PHM213)', 'available'),
('Building A', 'A-205', 'classroom', 50, 'Classroom - Modern Physics (PHM121, PHM122)', 'available'),
('Building A', 'A-206', 'office', 25, 'Faculty Board Meeting Room', 'available'),
('Building A', 'A-207', 'office', 20, 'Academic Council Room', 'available'),
('Building A', 'A-208', 'office', 15, 'Department Heads Meeting Room', 'available'),
('Building A', 'A-209', 'office', 12, 'Small Meeting Room', 'available'),
('Building A', 'A-210', 'office', 10, 'Interview Room', 'available');

-- Third Floor (A-3XX) - Study Areas
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building A', 'A-301', 'classroom', 50, 'Classroom - Thermal Physics (PHM123)', 'available'),
('Building A', 'A-302', 'classroom', 50, 'Classroom - Engineering Chemistry (PHM041)', 'available'),
('Building A', 'A-303', 'classroom', 45, 'Classroom - Organic Chemistry (PHM141, PHM142)', 'available'),
('Building A', 'A-304', 'classroom', 45, 'Classroom - Electrochemistry (PHM241)', 'available'),
('Building A', 'A-305', 'classroom', 40, 'Tutorial Room - Chemistry tutorials', 'available'),
('Building A', 'A-306', 'classroom', 30, 'Group Study Room 1', 'available'),
('Building A', 'A-307', 'classroom', 30, 'Group Study Room 2', 'available'),
('Building A', 'A-308', 'classroom', 25, 'Quiet Study Room', 'available'),
('Building A', 'A-309', 'classroom', 20, 'Individual Study Carrels', 'available'),
('Building A', 'A-310', 'office', 40, 'Prayer Room', 'available');

-- =====================================================
-- BUILDING B - COMPUTER & SYSTEMS ENGINEERING (CSE)
-- Computer Labs, Programming Labs, AI/ML facilities
-- =====================================================

-- Ground Floor (B-0XX) - General Computer Labs
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building B', 'B-001', 'lab', 60, 'Programming Lab 1 - Computer Programming (CSE131)', 'available'),
('Building B', 'B-002', 'lab', 60, 'Programming Lab 2 - Advanced Programming (CSE231)', 'available'),
('Building B', 'B-003', 'lab', 50, 'Linux Lab - Operating Systems (CSE335)', 'available'),
('Building B', 'B-004', 'lab', 50, 'Open Access Lab - 24/7 Student Access', 'available'),
('Building B', 'B-005', 'lab', 45, 'Database Lab - Database Systems (CSE333)', 'available');

-- First Floor (B-1XX) - Specialized Labs
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building B', 'B-101', 'lab', 35, 'Logic Design Lab - Digital circuits (CSE111)', 'available'),
('Building B', 'B-102', 'lab', 35, 'Computer Architecture Lab - CPU design (CSE112, CSE212)', 'available'),
('Building B', 'B-103', 'lab', 30, 'Embedded Systems Lab - Microcontrollers (CSE211)', 'available'),
('Building B', 'B-104', 'lab', 30, 'FPGA Lab - Digital VLSI (CSE414)', 'available'),
('Building B', 'B-105', 'lab', 35, 'Software Engineering Lab - UML, Design Patterns (CSE232, CSE334)', 'available'),
('Building B', 'B-106', 'lab', 30, 'Web Development Lab - Internet Programming (CSE341)', 'available'),
('Building B', 'B-107', 'lab', 30, 'Mobile Development Lab - Android/iOS (CSE431)', 'available'),
('Building B', 'B-108', 'classroom', 60, 'CSE Classroom 1 - Data Structures (CSE331)', 'available'),
('Building B', 'B-109', 'classroom', 55, 'CSE Classroom 2 - Algorithms (CSE332)', 'available'),
('Building B', 'B-110', 'classroom', 50, 'CSE Classroom 3 - Theory lectures', 'available');

-- Second Floor (B-2XX) - Networks, Security, AI Labs
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building B', 'B-201', 'lab', 30, 'Network Lab - Cisco equipment, Computer Networks (CSE351)', 'available'),
('Building B', 'B-202', 'lab', 25, 'Cybersecurity Lab - Isolated network (CSE451)', 'available'),
('Building B', 'B-203', 'lab', 25, 'IoT Lab - Internet of Things (CSE356)', 'available'),
('Building B', 'B-204', 'lab', 30, 'AI/ML Lab - GPU workstations, Machine Learning (CSE375, CSE381)', 'available'),
('Building B', 'B-205', 'lab', 25, 'Deep Learning Lab - RTX 4090 GPUs (CSE477, CSE485)', 'available'),
('Building B', 'B-206', 'lab', 25, 'Big Data Lab - Hadoop cluster (CSE476, CSE484)', 'available'),
('Building B', 'B-207', 'lab', 25, 'Cloud Computing Lab - AWS/Azure (CSE456)', 'available'),
('Building B', 'B-208', 'lab', 20, 'Computer Graphics Lab - OpenGL (CSE378)', 'available'),
('Building B', 'B-209', 'lab', 20, 'Computer Vision Lab - Image Processing (CSE374, CSE483)', 'available'),
('Building B', 'B-210', 'classroom', 45, 'CSE Seminar Room - Graduate seminars', 'available');

-- Third Floor (B-3XX) - Research and Server Room
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building B', 'B-301', 'office', 5, 'Main Server Room - Climate controlled', 'available'),
('Building B', 'B-302', 'lab', 20, 'HPC Research Lab - Parallel Computing (CSE314, CSE455)', 'available'),
('Building B', 'B-303', 'lab', 15, 'Graduate Research Lab - PhD students', 'available'),
('Building B', 'B-304', 'lab', 15, 'Real-Time Systems Lab - RTOS (CSE411, CSE413)', 'available'),
('Building B', 'B-305', 'lab', 20, 'Compiler Lab - Compiler Design (CSE439)', 'available'),
('Building B', 'B-306', 'lab', 20, 'Digital Forensics Lab (CSE453, CSE458)', 'available'),
('Building B', 'B-307', 'office', 12, 'CSE Teaching Assistants Office', 'available'),
('Building B', 'B-308', 'office', 8, 'System Administrators Office', 'available'),
('Building B', 'B-309', 'office', 15, 'CSE Project Room - Agile boards', 'available'),
('Building B', 'B-310', 'office', 0, 'CSE Equipment Storage', 'available');

-- =====================================================
-- BUILDING C - ELECTRONICS & COMMUNICATION (ECE)
-- Electronics Labs, RF Labs, Communication Labs
-- =====================================================

-- Ground Floor (C-0XX) - Basic Electronics Labs
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building C', 'C-001', 'lab', 35, 'Electronics Lab 1 - Basic Electronics (ECE211, ECE215)', 'available'),
('Building C', 'C-002', 'lab', 35, 'Electronics Lab 2 - Electronic Circuits (ECE214, ECE315)', 'available'),
('Building C', 'C-003', 'lab', 30, 'Digital Electronics Lab - Digital Circuits (ECE212)', 'available'),
('Building C', 'C-004', 'lab', 30, 'Semiconductor Lab - Electronic Materials (ECE111, ECE213)', 'available'),
('Building C', 'C-005', 'lab', 25, 'Analog Circuits Lab - Op-amps, Amplifiers (ECE312, ECE313)', 'available');

-- First Floor (C-1XX) - Advanced Electronics and VLSI
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building C', 'C-101', 'lab', 30, 'VLSI Design Lab - IC Layout (ECE314, ECE316)', 'available'),
('Building C', 'C-102', 'lab', 25, 'IC Fabrication Lab - Clean room (ECE411)', 'maintenance'),
('Building C', 'C-103', 'lab', 25, 'RF Circuit Lab - High frequency (ECE414)', 'available'),
('Building C', 'C-104', 'lab', 25, 'MEMS Lab - Microfabrication (ECE416)', 'available'),
('Building C', 'C-105', 'lab', 20, 'Electronic Instrumentation Lab (ECE318, ECE415)', 'available'),
('Building C', 'C-106', 'lab', 35, 'EDA Lab - Cadence/Mentor (ECE413)', 'available'),
('Building C', 'C-107', 'classroom', 60, 'ECE Classroom 1 - Theory lectures', 'available'),
('Building C', 'C-108', 'classroom', 55, 'ECE Classroom 2 - Signals and Systems (ECE251, ECE253)', 'available'),
('Building C', 'C-109', 'classroom', 50, 'ECE Classroom 3 - Communication Theory', 'available'),
('Building C', 'C-110', 'classroom', 45, 'ECE Seminar Room', 'available');

-- Second Floor (C-2XX) - Electromagnetics and Communications
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building C', 'C-201', 'lab', 30, 'EM Waves Lab - Wave propagation (ECE331)', 'available'),
('Building C', 'C-202', 'lab', 25, 'Microwave Lab - Waveguides, Antennas (ECE333, ECE432)', 'available'),
('Building C', 'C-203', 'lab', 25, 'Optical Communications Lab - Fiber optics (ECE334, ECE434)', 'available'),
('Building C', 'C-204', 'lab', 20, 'Optoelectronics Lab - Lasers, LEDs (ECE431)', 'available'),
('Building C', 'C-205', 'lab', 20, 'Photonics Lab - Integrated optics (ECE435, ECE436)', 'available'),
('Building C', 'C-206', 'lab', 30, 'DSP Lab - Digital Signal Processing (ECE255)', 'available'),
('Building C', 'C-207', 'lab', 30, 'Communication Systems Lab - Modulation (ECE252, ECE254)', 'available'),
('Building C', 'C-208', 'lab', 25, 'Wireless Lab - RF testing (ECE353)', 'available'),
('Building C', 'C-209', 'lab', 25, 'Telecom Networks Lab - Network simulation (ECE352)', 'available'),
('Building C', 'C-210', 'office', 15, 'ECE Project Discussion Room', 'available');

-- Third Floor (C-3XX) - Research Labs
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building C', 'C-301', 'lab', 15, 'Anechoic Chamber - Antenna measurements', 'available'),
('Building C', 'C-302', 'lab', 15, 'Shielded Room - EMC testing', 'available'),
('Building C', 'C-303', 'lab', 20, 'Graduate Research Lab - ECE PhD', 'available'),
('Building C', 'C-304', 'lab', 15, 'Advanced Semiconductor Research', 'available'),
('Building C', 'C-305', 'lab', 15, 'Quantum Electronics Lab', 'available'),
('Building C', 'C-306', 'office', 10, 'ECE Teaching Assistants Office', 'available'),
('Building C', 'C-307', 'office', 6, 'Lab Technicians Office', 'available'),
('Building C', 'C-308', 'office', 0, 'ECE Equipment Storage', 'available'),
('Building C', 'C-309', 'office', 0, 'Component Storage', 'available'),
('Building C', 'C-310', 'classroom', 20, 'ECE Study Room', 'available');

-- =====================================================
-- BUILDING D - MECHATRONICS ENGINEERING (MCT)
-- Robotics, Automation, Automotive Labs
-- =====================================================

-- Ground Floor (D-0XX) - Mechanical and Hydraulics Labs
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building D', 'D-001', 'lab', 40, 'Mechanical Workshop - CNC, Lathes, Milling', 'available'),
('Building D', 'D-002', 'lab', 30, 'Hydraulics Lab - Hydraulic systems (MCT311)', 'available'),
('Building D', 'D-003', 'lab', 30, 'Pneumatics Lab - Pneumatic control (MCT311)', 'available'),
('Building D', 'D-004', 'lab', 25, 'Fluid Mechanics Lab', 'available'),
('Building D', 'D-005', 'lab', 25, 'Materials Testing Lab', 'available');

-- First Floor (D-1XX) - Control and Automation Labs
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building D', 'D-101', 'lab', 30, 'Automatic Control Lab - PID, Controllers (MCT211)', 'available'),
('Building D', 'D-102', 'lab', 30, 'PLC Lab - Industrial Automation (MCT312, MCT313)', 'available'),
('Building D', 'D-103', 'lab', 25, 'SCADA Lab - Supervisory control', 'available'),
('Building D', 'D-104', 'lab', 25, 'Motion Control Lab - Servo motors (MCT412)', 'available'),
('Building D', 'D-105', 'lab', 25, 'Sensors Lab - Measurement systems (MCT231, MCT334)', 'available'),
('Building D', 'D-106', 'lab', 25, 'Industrial Electronics Lab (MCT232)', 'available'),
('Building D', 'D-107', 'lab', 35, 'MATLAB/Simulink Lab - Modeling (MCT233, MCT234)', 'available'),
('Building D', 'D-108', 'classroom', 55, 'MCT Classroom 1 - Control Theory', 'available'),
('Building D', 'D-109', 'classroom', 50, 'MCT Classroom 2 - System Dynamics', 'available'),
('Building D', 'D-110', 'classroom', 45, 'MCT Classroom 3 - Mechatronics Design (MCT333)', 'available');

-- Second Floor (D-2XX) - Robotics and Embedded Systems
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building D', 'D-201', 'lab', 30, 'Robotics Lab - Industrial robot arms (MCT344)', 'available'),
('Building D', 'D-202', 'lab', 25, 'Mobile Robotics Lab - Autonomous systems (MCT443)', 'available'),
('Building D', 'D-203', 'lab', 20, 'Rehabilitation Robotics Lab - Exoskeletons (MCT441)', 'available'),
('Building D', 'D-204', 'lab', 30, 'Embedded Systems Lab - ARM, Arduino (MCT421)', 'available'),
('Building D', 'D-205', 'lab', 25, 'CAN Bus Lab - Automotive networking (MCT422)', 'available'),
('Building D', 'D-206', 'lab', 25, 'CAD/CAM Lab - 3D printing, CNC', 'available'),
('Building D', 'D-207', 'lab', 20, 'HIL Simulation Lab - Hardware-in-the-Loop', 'available'),
('Building D', 'D-208', 'office', 15, 'MCT Project Room', 'available'),
('Building D', 'D-209', 'office', 10, 'MCT Teaching Assistants Office', 'available'),
('Building D', 'D-210', 'office', 0, 'MCT Equipment Storage', 'available');

-- Third Floor (D-3XX) - Automotive and Research
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building D', 'D-301', 'lab', 30, 'Automotive Lab - Vehicle systems (MCT341, MCT446)', 'available'),
('Building D', 'D-302', 'lab', 20, 'Electric Vehicle Lab - EV/Hybrid systems', 'available'),
('Building D', 'D-303', 'lab', 20, 'Engine Test Cell - Dynamometer', 'available'),
('Building D', 'D-304', 'lab', 15, 'Graduate Research Lab - MCT PhD', 'available'),
('Building D', 'D-305', 'lab', 15, 'Hybrid Control Research Lab (MCT411)', 'available'),
('Building D', 'D-306', 'classroom', 40, 'MCT Seminar Room', 'available'),
('Building D', 'D-307', 'office', 8, 'Lab Technicians Office', 'available'),
('Building D', 'D-308', 'office', 0, 'Automotive Parts Storage', 'available'),
('Building D', 'D-309', 'office', 0, 'Robot Components Storage', 'available'),
('Building D', 'D-310', 'classroom', 20, 'MCT Study Room', 'available');

-- =====================================================
-- BUILDING E - ELECTRICAL POWER & MACHINES (EPM)
-- Power Systems, Machines, High Voltage Labs
-- =====================================================

-- Ground Floor (E-0XX) - Heavy Equipment Labs
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building E', 'E-001', 'lab', 40, 'Electrical Machines Lab 1 - DC machines (EPM221, EPM321)', 'available'),
('Building E', 'E-002', 'lab', 40, 'Electrical Machines Lab 2 - AC machines (EPM222, EPM322)', 'available'),
('Building E', 'E-003', 'lab', 30, 'Transformers Lab - Testing and analysis', 'available'),
('Building E', 'E-004', 'lab', 25, 'Special Machines Lab - Stepper, BLDC (EPM421)', 'available'),
('Building E', 'E-005', 'lab', 25, 'Electrical Drives Lab (EPM451, EPM455)', 'available');

-- First Floor (E-1XX) - Power Electronics and Control
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building E', 'E-101', 'lab', 30, 'Power Electronics Lab 1 - Rectifiers (EPM351)', 'available'),
('Building E', 'E-102', 'lab', 30, 'Power Electronics Lab 2 - Inverters, Converters (EPM352, EPM354)', 'available'),
('Building E', 'E-103', 'lab', 25, 'Industrial Electronics Lab (EPM151)', 'available'),
('Building E', 'E-104', 'lab', 25, 'Control Systems Lab - PID control (EPM232)', 'available'),
('Building E', 'E-105', 'lab', 25, 'PLC Lab - Industrial automation (EPM422)', 'available'),
('Building E', 'E-106', 'lab', 30, 'Electrical Circuits Lab (EPM111, EPM212)', 'available'),
('Building E', 'E-107', 'lab', 25, 'Electrical Measurements Lab (EPM113)', 'available'),
('Building E', 'E-108', 'classroom', 60, 'EPM Classroom 1 - Circuit Theory', 'available'),
('Building E', 'E-109', 'classroom', 55, 'EPM Classroom 2 - Power Systems (EPM231)', 'available'),
('Building E', 'E-110', 'classroom', 50, 'EPM Classroom 3 - Machines Theory', 'available');

-- Second Floor (E-2XX) - Power Systems and Protection
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building E', 'E-201', 'lab', 30, 'Power Systems Lab - Load flow, Fault analysis (EPM332, EPM335)', 'available'),
('Building E', 'E-202', 'lab', 25, 'Power System Protection Lab - Relays (EPM461, EPM463)', 'available'),
('Building E', 'E-203', 'lab', 25, 'Transmission Lines Lab (EPM331)', 'available'),
('Building E', 'E-204', 'lab', 25, 'Distribution Systems Lab (EPM333, EPM336)', 'available'),
('Building E', 'E-205', 'lab', 35, 'Power System Simulation Lab - PSCAD, ETAP (EPM214, EPM436)', 'available'),
('Building E', 'E-206', 'lab', 20, 'Power Quality Lab - Harmonics, Filters (EPM453, EPM456)', 'available'),
('Building E', 'E-207', 'lab', 20, 'Smart Grid Lab - Energy management', 'available'),
('Building E', 'E-208', 'classroom', 45, 'EPM Seminar Room', 'available'),
('Building E', 'E-209', 'office', 15, 'EPM Project Room', 'available'),
('Building E', 'E-210', 'office', 10, 'EPM Teaching Assistants Office', 'available');

-- Third Floor (E-3XX) - High Voltage and Renewable Energy
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building E', 'E-301', 'lab', 20, 'High Voltage Lab - HV testing (EPM341)', 'out_of_service'),
('Building E', 'E-302', 'lab', 20, 'Switchgear Lab - Circuit breakers (EPM342)', 'available'),
('Building E', 'E-303', 'lab', 25, 'Renewable Energy Lab - Solar/Wind (EPM117, EPM213)', 'available'),
('Building E', 'E-304', 'lab', 20, 'Photovoltaic Lab - Solar cells (EPM311)', 'available'),
('Building E', 'E-305', 'lab', 20, 'Energy Storage Lab - Batteries, Supercapacitors', 'available'),
('Building E', 'E-306', 'lab', 15, 'Grid Integration Lab (EPM454)', 'available'),
('Building E', 'E-307', 'lab', 15, 'Graduate Research Lab - EPM PhD', 'available'),
('Building E', 'E-308', 'office', 8, 'Lab Technicians Office', 'available'),
('Building E', 'E-309', 'office', 0, 'HV Equipment Storage', 'available'),
('Building E', 'E-310', 'classroom', 20, 'EPM Study Room', 'available');

-- =====================================================
-- BUILDING F - ARCHITECTURE ENGINEERING (ARC)
-- Design Studios, CAD Labs, Model Workshops
-- =====================================================

-- Ground Floor (F-0XX) - Design Studios
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building F', 'F-001', 'classroom', 45, 'Design Studio 1 - Principles of Design (ARC111)', 'available'),
('Building F', 'F-002', 'classroom', 45, 'Design Studio 2 - Creativity Studio (ARC112)', 'available'),
('Building F', 'F-003', 'classroom', 40, 'Design Studio 3 - Vernacular Architecture (ARC113)', 'available'),
('Building F', 'F-004', 'classroom', 40, 'Design Studio 4 - Building Type (ARC211)', 'available'),
('Building F', 'F-005', 'classroom', 35, 'Design Studio 5 - Multi-story Buildings (ARC212)', 'available');

-- First Floor (F-1XX) - Advanced Studios and Workshops
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building F', 'F-101', 'classroom', 35, 'Environmental Design Studio 1 (ARC213)', 'available'),
('Building F', 'F-102', 'classroom', 35, 'Environmental Design Studio 2 (ARC214)', 'available'),
('Building F', 'F-103', 'classroom', 35, 'Smart Systems Studio (ARC311)', 'available'),
('Building F', 'F-104', 'classroom', 35, 'Sustainable Design Studio (ARC312, ARC313)', 'available'),
('Building F', 'F-105', 'lab', 30, 'Model Making Workshop - Laser cutters, 3D printers', 'available'),
('Building F', 'F-106', 'lab', 20, 'Woodworking Shop - Power tools', 'available'),
('Building F', 'F-107', 'classroom', 50, 'Architecture History Room (ARC131, ARC132)', 'available'),
('Building F', 'F-108', 'classroom', 45, 'Design Methods Classroom (ARC221)', 'available'),
('Building F', 'F-109', 'classroom', 60, 'Jury Room 1 - Design critiques', 'available'),
('Building F', 'F-110', 'classroom', 60, 'Jury Room 2 - Final reviews', 'available');

-- Second Floor (F-2XX) - Computer Labs and Graduate Studios
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building F', 'F-201', 'lab', 40, 'CAD Lab - AutoCAD (ARC142, ARC143)', 'available'),
('Building F', 'F-202', 'lab', 35, 'BIM Lab - Revit (ARC441)', 'available'),
('Building F', 'F-203', 'lab', 30, '3D Modeling Lab - Rhino, Grasshopper (ARC241, ARC442)', 'available'),
('Building F', 'F-204', 'lab', 25, 'Rendering Lab - V-Ray, Lumion', 'available'),
('Building F', 'F-205', 'classroom', 30, 'Thematic Design Studio (ARC411)', 'available'),
('Building F', 'F-206', 'classroom', 30, 'Technological Design Studio (ARC412)', 'available'),
('Building F', 'F-207', 'classroom', 25, 'Smart Housing Studio (ARC413)', 'available'),
('Building F', 'F-208', 'classroom', 25, 'Graduate Design Studio - Masters', 'available'),
('Building F', 'F-209', 'classroom', 20, 'Thesis Studio - PhD students', 'available'),
('Building F', 'F-210', 'classroom', 40, 'Working Drawing Room (ARC351, ARC352)', 'available');

-- Third Floor (F-3XX) - Specialized Spaces
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building F', 'F-301', 'classroom', 45, 'Theory of Architecture (ARC321)', 'available'),
('Building F', 'F-302', 'classroom', 40, 'Urban Planning Room', 'available'),
('Building F', 'F-303', 'classroom', 35, 'Interior Design Room (ARC421)', 'available'),
('Building F', 'F-304', 'lab', 20, 'Building Materials Lab', 'available'),
('Building F', 'F-305', 'lab', 15, 'Environmental Analysis Lab - Climate simulation', 'available'),
('Building F', 'F-306', 'classroom', 80, 'Exhibition Gallery - Student works', 'available'),
('Building F', 'F-307', 'classroom', 30, 'Photography Studio (ARC341)', 'available'),
('Building F', 'F-308', 'office', 10, 'ARC Teaching Assistants Office', 'available'),
('Building F', 'F-309', 'office', 0, 'Model Storage Room', 'available'),
('Building F', 'F-310', 'office', 0, 'Portfolio Storage', 'available');

-- =====================================================
-- BUILDING G - SCIENCE LABS (PHM)
-- Physics, Chemistry, Materials Labs
-- =====================================================

-- Ground Floor (G-0XX) - Chemistry Labs
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building G', 'G-001', 'lab', 35, 'General Chemistry Lab (PHM041)', 'available'),
('Building G', 'G-002', 'lab', 30, 'Organic Chemistry Lab (PHM141)', 'available'),
('Building G', 'G-003', 'lab', 25, 'Analytical Chemistry Lab (PHM142)', 'available'),
('Building G', 'G-004', 'lab', 25, 'Electrochemistry Lab (PHM241)', 'available'),
('Building G', 'G-005', 'lab', 20, 'Polymer Chemistry Lab (PHM242)', 'available');

-- First Floor (G-1XX) - Physics Labs
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Building G', 'G-101', 'lab', 35, 'General Physics Lab - Mechanics (PHM031, PHM032)', 'available'),
('Building G', 'G-102', 'lab', 35, 'Waves and Vibration Lab (PHM021)', 'available'),
('Building G', 'G-103', 'lab', 30, 'Electricity and Magnetism Lab (PHM022)', 'available'),
('Building G', 'G-104', 'lab', 25, 'Modern Physics Lab (PHM121)', 'available'),
('Building G', 'G-105', 'lab', 25, 'Semiconductor Physics Lab (PHM122)', 'available'),
('Building G', 'G-106', 'lab', 25, 'Optics Lab - Lasers, Interference', 'available'),
('Building G', 'G-107', 'lab', 20, 'Thermal Physics Lab (PHM123)', 'available'),
('Building G', 'G-108', 'classroom', 50, 'Physics Demonstration Room', 'available'),
('Building G', 'G-109', 'office', 8, 'PHM Lab Technicians Office', 'available'),
('Building G', 'G-110', 'office', 0, 'Chemical Storage - Hazmat certified', 'available');

-- =====================================================
-- ADMINISTRATION AND COMMON FACILITIES
-- =====================================================

-- Exam Halls
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Admin Building', 'Exam Hall 1', 'auditorium', 250, 'Main Examination Hall - Individual desks, CCTV', 'available'),
('Admin Building', 'Exam Hall 2', 'auditorium', 200, 'Secondary Examination Hall', 'available'),
('Admin Building', 'Exam Hall 3', 'auditorium', 150, 'Examination Hall - Climate controlled', 'available'),
('Admin Building', 'Multipurpose Hall', 'auditorium', 200, 'Events, Seminars, and Examinations', 'available');

-- Conference and Meeting Rooms
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Admin Building', 'Main Conference Room', 'office', 60, 'Board meetings, Video conferencing', 'available'),
('Admin Building', 'Conference Room A', 'office', 40, 'Department meetings', 'available'),
('Admin Building', 'Conference Room B', 'office', 30, 'Faculty meetings', 'available'),
('Admin Building', 'Training Room', 'classroom', 40, 'Workshops and training sessions', 'available');

-- Faculty Offices
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Admin Building', 'Dean Office - CSE', 'office', 1, 'CSE Department Head Office', 'available'),
('Admin Building', 'Dean Office - ECE', 'office', 1, 'ECE Department Head Office', 'available'),
('Admin Building', 'Dean Office - MCT', 'office', 1, 'MCT Department Head Office', 'available'),
('Admin Building', 'Dean Office - EPM', 'office', 1, 'EPM Department Head Office', 'available'),
('Admin Building', 'Dean Office - ARC', 'office', 1, 'ARC Department Head Office', 'available'),
('Admin Building', 'Dean Office - PHM', 'office', 1, 'PHM Department Head Office', 'available'),
('Admin Building', 'Faculty Lounge', 'office', 30, 'Faculty break room and lounge', 'available');

-- Library and Study Facilities
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('classroom', 'Main Reading Hall', 'classroom', 250, 'Main library reading area', 'available'),
('classroom', 'Engineering Section', 'classroom', 100, 'Technical books and journals', 'available'),
('classroom', 'Digital Library', 'lab', 60, 'Online databases and e-resources', 'available'),
('classroom', 'Group Study Room 1', 'classroom', 12, 'Bookable group study', 'available'),
('classroom', 'Group Study Room 2', 'classroom', 12, 'Bookable group study', 'available'),
('classroom', 'Group Study Room 3', 'classroom', 10, 'Bookable group study', 'available'),
('classroom', 'Group Study Room 4', 'classroom', 10, 'Bookable group study', 'available'),
('classroom', 'Quiet Study Zone', 'classroom', 50, 'Individual silent study', 'available'),
('classroom', 'Media Room', 'lab', 25, 'Video/Audio resources', 'available');

-- Common Facilities
INSERT INTO Rooms (building, room_name, room_type, capacity, description, status) VALUES
('Student Center', 'Main Cafeteria', 'office', 400, 'Main dining hall', 'available'),
('Student Center', 'Coffee Shop', 'office', 60, 'Quick refreshments', 'available'),
('Student Center', 'Student Lounge', 'office', 100, 'Relaxation and socializing', 'available'),
('Sports Center', 'Gymnasium', 'office', 120, 'Indoor sports - Basketball, Volleyball', 'available'),
('Sports Center', 'Fitness Center', 'office', 60, 'Weight room and cardio', 'available'),
('Sports Center', 'Swimming Pool', 'office', 50, 'Indoor 25m pool', 'maintenance'),
('office', 'Football Field', 'office', 500, 'Main sports field', 'available'),
('office', 'Basketball Courts', 'office', 80, 'Outdoor courts (2)', 'available'),
('office', 'Amphitheater', 'office', 350, 'Outdoor events and ceremonies', 'available'),
('Religious', 'Prayer Room - Male', 'office', 100, 'Male prayer area', 'available'),
('Religious', 'Prayer Room - Female', 'office', 80, 'Female prayer area', 'available'),
('office', 'Health Center', 'office', 20, 'First aid and medical emergencies', 'available');

-- Re-enable FK checks
SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- ROOM ATTRIBUTES (EAV Model)
-- Define the attributes that can be assigned to rooms
-- =====================================================

INSERT INTO RoomAttributes (attribute_name, value_type) VALUES
-- Equipment attributes
('has_projector', 'bool'),
('projector_type', 'text'),
('has_whiteboard', 'bool'),
('whiteboard_count', 'int'),
('has_smartboard', 'bool'),
('has_microphone', 'bool'),
('has_speakers', 'bool'),
('has_recording_equipment', 'bool'),

-- Climate & Environment
('has_air_conditioning', 'bool'),
('has_heating', 'bool'),
('has_windows', 'bool'),
('natural_lighting', 'bool'),

-- IT & Network
('has_wifi', 'bool'),
('has_ethernet', 'bool'),
('ethernet_ports_count', 'int'),
('has_video_conferencing', 'bool'),

-- Furniture & Seating
('seating_type', 'text'),
('has_power_outlets', 'bool'),
('power_outlets_count', 'int'),
('desk_type', 'text'),

-- Lab-specific attributes
('equipment_list', 'json'),
('software_installed', 'json'),
('safety_requirements', 'json'),
('requires_supervision', 'bool'),
('requires_lab_coat', 'bool'),
('requires_safety_goggles', 'bool'),

-- Accessibility
('wheelchair_accessible', 'bool'),
('has_hearing_loop', 'bool'),

-- Special features
('has_3d_printer', 'bool'),
('has_laser_cutter', 'bool'),
('has_cnc_machine', 'bool'),
('has_oscilloscope', 'bool'),
('has_function_generator', 'bool'),
('has_soldering_station', 'bool'),
('computer_count', 'int'),
('computer_specs', 'json'),
('has_gpu_workstations', 'bool');

-- =====================================================
-- ROOM ATTRIBUTE VALUES
-- Assign attribute values to specific rooms
-- =====================================================

-- Helper: Get room_id by room_name for attribute assignment
-- We'll use subqueries to reference rooms by name

-- BUILDING A - Lecture Halls and Classrooms
-- A-001 Main Auditorium
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'A-001' AND a.attribute_name = 'has_projector';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'Dual 4K Laser'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'A-001' AND a.attribute_name = 'projector_type';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'A-001' AND a.attribute_name = 'has_microphone';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'A-001' AND a.attribute_name = 'has_speakers';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'A-001' AND a.attribute_name = 'has_recording_equipment';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'A-001' AND a.attribute_name = 'has_air_conditioning';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'A-001' AND a.attribute_name = 'has_wifi';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'A-001' AND a.attribute_name = 'has_video_conferencing';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'Tiered Theater'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'A-001' AND a.attribute_name = 'seating_type';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'A-001' AND a.attribute_name = 'wheelchair_accessible';

-- A-002 to A-006 Lecture Halls (similar equipment)
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('A-002', 'A-003', 'A-004', 'A-005', 'A-006') AND a.attribute_name = 'has_projector';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('A-002', 'A-003', 'A-004', 'A-005', 'A-006') AND a.attribute_name = 'has_microphone';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('A-002', 'A-003', 'A-004', 'A-005', 'A-006') AND a.attribute_name = 'has_air_conditioning';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('A-002', 'A-003', 'A-004', 'A-005', 'A-006') AND a.attribute_name = 'has_wifi';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'Tiered Theater'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('A-002', 'A-003', 'A-004', 'A-005', 'A-006') AND a.attribute_name = 'seating_type';

-- A-1XX Classrooms - Standard classroom equipment
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name LIKE 'A-1%' AND r.room_type = 'classroom' AND a.attribute_name = 'has_projector';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name LIKE 'A-1%' AND r.room_type = 'classroom' AND a.attribute_name = 'has_whiteboard';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '2'
FROM Rooms r, RoomAttributes a
WHERE r.room_name LIKE 'A-1%' AND r.room_type = 'classroom' AND a.attribute_name = 'whiteboard_count';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name LIKE 'A-1%' AND r.room_type = 'classroom' AND a.attribute_name = 'has_air_conditioning';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name LIKE 'A-1%' AND r.room_type = 'classroom' AND a.attribute_name = 'has_wifi';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'Fixed Rows'
FROM Rooms r, RoomAttributes a
WHERE r.room_name LIKE 'A-1%' AND r.room_type = 'classroom' AND a.attribute_name = 'seating_type';

-- A-110 Language Lab - special equipment
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '45'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'A-110' AND a.attribute_name = 'computer_count';

-- BUILDING B - CSE Computer Labs
-- B-001 to B-005 Programming Labs
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('B-001', 'B-002', 'B-003', 'B-004', 'B-005') AND a.attribute_name = 'has_projector';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('B-001', 'B-002', 'B-003', 'B-004', 'B-005') AND a.attribute_name = 'has_air_conditioning';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('B-001', 'B-002', 'B-003', 'B-004', 'B-005') AND a.attribute_name = 'has_ethernet';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, r.capacity
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('B-001', 'B-002', 'B-003', 'B-004', 'B-005') AND a.attribute_name = 'computer_count';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Visual Studio Code", "IntelliJ IDEA", "Python 3.x", "Java JDK", "Git", "MySQL Workbench", "Node.js"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('B-001', 'B-002') AND a.attribute_name = 'software_installed';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Ubuntu 22.04", "gcc", "gdb", "vim", "Docker", "Kubernetes CLI"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'B-003' AND a.attribute_name = 'software_installed';

-- B-2XX AI/ML Labs with GPU workstations
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('B-204', 'B-205', 'B-209') AND a.attribute_name = 'has_gpu_workstations';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '{"cpu": "Intel i9-13900K", "ram": "64GB DDR5", "gpu": "NVIDIA RTX 4090", "storage": "2TB NVMe SSD"}'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('B-205') AND a.attribute_name = 'computer_specs';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Python 3.x", "PyTorch", "TensorFlow", "CUDA Toolkit", "cuDNN", "Jupyter Lab", "Anaconda"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('B-204', 'B-205') AND a.attribute_name = 'software_installed';

-- B-201 Network Lab - Cisco equipment
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Cisco routers", "Cisco switches", "Network cables", "Packet Tracer", "Wireshark"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'B-201' AND a.attribute_name = 'equipment_list';

-- B-202 Cybersecurity Lab - isolated network
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Kali Linux", "Metasploit", "Burp Suite", "Wireshark", "Nmap", "Virtual Box"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'B-202' AND a.attribute_name = 'software_installed';

-- B-301 Server Room
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'B-301' AND a.attribute_name = 'has_air_conditioning';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'B-301' AND a.attribute_name = 'requires_supervision';

-- BUILDING C - ECE Electronics Labs
-- C-001 to C-005 Electronics Labs
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('C-001', 'C-002', 'C-003', 'C-004', 'C-005') AND a.attribute_name = 'has_oscilloscope';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('C-001', 'C-002', 'C-003', 'C-004', 'C-005') AND a.attribute_name = 'has_function_generator';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('C-001', 'C-002', 'C-003', 'C-004', 'C-005') AND a.attribute_name = 'has_soldering_station';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Oscilloscopes", "Function Generators", "Power Supplies", "Multimeters", "Soldering Stations", "Breadboards", "Component Kits"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('C-001', 'C-002', 'C-003', 'C-004', 'C-005') AND a.attribute_name = 'equipment_list';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('C-001', 'C-002', 'C-003', 'C-004', 'C-005') AND a.attribute_name = 'requires_safety_goggles';

-- C-101 VLSI Lab
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Cadence Virtuoso", "Synopsys Design Compiler", "ModelSim", "Xilinx Vivado"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'C-101' AND a.attribute_name = 'software_installed';

-- C-106 EDA Lab
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Cadence", "Mentor Graphics", "Synopsys", "Altium Designer", "KiCad"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'C-106' AND a.attribute_name = 'software_installed';

-- C-2XX Communication Labs
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Spectrum Analyzers", "Signal Generators", "Network Analyzers", "Antenna Measurement Kit"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('C-201', 'C-202', 'C-207', 'C-208') AND a.attribute_name = 'equipment_list';

-- BUILDING D - MCT Labs
-- D-001 Mechanical Workshop
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'D-001' AND a.attribute_name = 'has_cnc_machine';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["CNC Mill", "Lathe", "Milling Machine", "Drill Press", "Band Saw", "Grinders"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'D-001' AND a.attribute_name = 'equipment_list';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Wear safety goggles", "Wear closed-toe shoes", "No loose clothing", "Tie back long hair", "Use hearing protection"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'D-001' AND a.attribute_name = 'safety_requirements';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'D-001' AND a.attribute_name = 'requires_supervision';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'D-001' AND a.attribute_name = 'requires_safety_goggles';

-- D-002, D-003 Hydraulics/Pneumatics Labs
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Hydraulic Trainer", "Pneumatic Trainer", "Pressure Gauges", "Flow Meters", "Valves", "Cylinders"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('D-002', 'D-003') AND a.attribute_name = 'equipment_list';

-- D-102 PLC Lab
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Siemens S7-1200 PLCs", "Allen Bradley PLCs", "Schneider PLCs", "HMI Panels", "Sensors", "Actuators"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'D-102' AND a.attribute_name = 'equipment_list';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["TIA Portal", "RSLogix 5000", "Unity Pro", "Factory IO"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'D-102' AND a.attribute_name = 'software_installed';

-- D-107 MATLAB Lab
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["MATLAB", "Simulink", "Control System Toolbox", "Signal Processing Toolbox", "Image Processing Toolbox"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'D-107' AND a.attribute_name = 'software_installed';

-- D-201 Robotics Lab
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["KUKA Robot Arms", "ABB Robots", "Fanuc Robots", "Robot Controllers", "End Effectors", "Vision Systems"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'D-201' AND a.attribute_name = 'equipment_list';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["KUKA Sim", "RobotStudio", "ROS", "MATLAB Robotics Toolbox"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'D-201' AND a.attribute_name = 'software_installed';

-- D-206 CAD/CAM Lab
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'D-206' AND a.attribute_name = 'has_3d_printer';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["SolidWorks", "AutoCAD", "Fusion 360", "CATIA", "Mastercam", "Ultimaker Cura"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'D-206' AND a.attribute_name = 'software_installed';

-- BUILDING E - EPM Labs
-- E-001, E-002 Electrical Machines Labs
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["DC Motors", "DC Generators", "AC Induction Motors", "Synchronous Machines", "Transformers", "Dynamometers"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('E-001', 'E-002') AND a.attribute_name = 'equipment_list';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["No jewelry or watches", "Insulated tools only", "Safety shoes required", "No loose clothing"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('E-001', 'E-002') AND a.attribute_name = 'safety_requirements';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('E-001', 'E-002') AND a.attribute_name = 'requires_supervision';

-- E-101, E-102 Power Electronics Labs
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Rectifiers", "Inverters", "Choppers", "Thyristors", "IGBTs", "Gate Drivers", "Power Supplies"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('E-101', 'E-102') AND a.attribute_name = 'equipment_list';

-- E-205 Power System Simulation Lab
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["PSCAD", "ETAP", "DIgSILENT PowerFactory", "MATLAB SimPowerSystems"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'E-205' AND a.attribute_name = 'software_installed';

-- E-301 High Voltage Lab (out of service)
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Minimum safe distance 2m", "Authorized personnel only", "Grounding procedures mandatory", "Emergency shutoff training required"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'E-301' AND a.attribute_name = 'safety_requirements';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'E-301' AND a.attribute_name = 'requires_supervision';

-- BUILDING F - ARC Studios and Labs
-- F-001 to F-005 Design Studios
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'Individual Drafting Tables'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('F-001', 'F-002', 'F-003', 'F-004', 'F-005') AND a.attribute_name = 'desk_type';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('F-001', 'F-002', 'F-003', 'F-004', 'F-005') AND a.attribute_name = 'natural_lighting';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('F-001', 'F-002', 'F-003', 'F-004', 'F-005') AND a.attribute_name = 'has_windows';

-- F-105 Model Making Workshop
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'F-105' AND a.attribute_name = 'has_3d_printer';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'F-105' AND a.attribute_name = 'has_laser_cutter';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["3D Printers (Ultimaker, Prusa)", "Laser Cutter", "Foam Cutter", "Spray Booth", "Hand Tools", "Cutting Mats"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'F-105' AND a.attribute_name = 'equipment_list';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'F-105' AND a.attribute_name = 'requires_supervision';

-- F-201 to F-204 CAD/BIM Labs
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["AutoCAD", "AutoCAD Architecture", "SketchUp Pro"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'F-201' AND a.attribute_name = 'software_installed';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Revit", "Navisworks", "BIM 360"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'F-202' AND a.attribute_name = 'software_installed';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Rhino 3D", "Grasshopper", "Ladybug Tools", "Kangaroo Physics"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'F-203' AND a.attribute_name = 'software_installed';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["V-Ray", "Lumion", "Enscape", "Twinmotion", "Adobe Creative Suite"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'F-204' AND a.attribute_name = 'software_installed';

-- BUILDING G - PHM Science Labs
-- G-001 to G-005 Chemistry Labs
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('G-001', 'G-002', 'G-003', 'G-004', 'G-005') AND a.attribute_name = 'requires_lab_coat';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('G-001', 'G-002', 'G-003', 'G-004', 'G-005') AND a.attribute_name = 'requires_safety_goggles';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Fume Hoods", "Bunsen Burners", "Balances", "Glassware", "Chemical Storage", "Eye Wash Stations", "Safety Showers"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('G-001', 'G-002', 'G-003', 'G-004', 'G-005') AND a.attribute_name = 'equipment_list';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Lab coat required", "Safety goggles required", "Closed-toe shoes", "Know location of eye wash and shower", "No food or drink"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('G-001', 'G-002', 'G-003', 'G-004', 'G-005') AND a.attribute_name = 'safety_requirements';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('G-001', 'G-002', 'G-003', 'G-004', 'G-005') AND a.attribute_name = 'requires_supervision';

-- G-101 to G-107 Physics Labs
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Mechanics apparatus", "Oscillation equipment", "Optical benches", "Laser sources", "Spectrometers"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name IN ('G-101', 'G-102', 'G-106') AND a.attribute_name = 'equipment_list';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '["Electrical measurement sets", "Multimeters", "Power supplies", "Magnetic field apparatus"]'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'G-103' AND a.attribute_name = 'equipment_list';

-- Library - Digital Library
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, '60'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'Digital Library' AND a.attribute_name = 'computer_count';

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_name = 'Digital Library' AND a.attribute_name = 'has_wifi';

-- All standard classrooms - basic equipment
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_type = 'classroom' AND a.attribute_name = 'has_whiteboard'
AND NOT EXISTS (SELECT 1 FROM RoomAttributeValues rav WHERE rav.room_id = r.room_id AND rav.attribute_id = a.attribute_id);

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_type = 'classroom' AND a.attribute_name = 'has_wifi'
AND NOT EXISTS (SELECT 1 FROM RoomAttributeValues rav WHERE rav.room_id = r.room_id AND rav.attribute_id = a.attribute_id);

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_type = 'classroom' AND a.attribute_name = 'wheelchair_accessible'
AND NOT EXISTS (SELECT 1 FROM RoomAttributeValues rav WHERE rav.room_id = r.room_id AND rav.attribute_id = a.attribute_id);

-- All labs - standard lab equipment
INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_type = 'lab' AND a.attribute_name = 'has_air_conditioning'
AND NOT EXISTS (SELECT 1 FROM RoomAttributeValues rav WHERE rav.room_id = r.room_id AND rav.attribute_id = a.attribute_id);

INSERT INTO RoomAttributeValues (room_id, attribute_id, value)
SELECT r.room_id, a.attribute_id, 'true'
FROM Rooms r, RoomAttributes a
WHERE r.room_type = 'lab' AND a.attribute_name = 'has_ethernet'
AND NOT EXISTS (SELECT 1 FROM RoomAttributeValues rav WHERE rav.room_id = r.room_id AND rav.attribute_id = a.attribute_id);

-- =====================================================
-- SUMMARY QUERIES
-- =====================================================

SELECT 'ROOMS BY BUILDING:' as '';
SELECT 
    building,
    COUNT(*) as room_count,
    SUM(capacity) as total_capacity
FROM Rooms
GROUP BY building
ORDER BY building;

SELECT 'ROOMS BY TYPE:' as '';
SELECT 
    room_type,
    COUNT(*) as count
FROM Rooms
GROUP BY room_type
ORDER BY count DESC;

SELECT 'ROOMS BY STATUS:' as '';
SELECT 
    status,
    COUNT(*) as count
FROM Rooms
GROUP BY status;

SELECT 'TOTAL ROOMS:', COUNT(*) FROM Rooms;
