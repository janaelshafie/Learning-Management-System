USE university_lms_db;

INSERT INTO Department (department_code, name, unit_head_id) VALUES 
('PHM', 'Engineering Physics and Mathematics Department', NULL),
('ASU', 'ASU Courses (General / University Requirements)', NULL),
('MCT', 'Mechatronics Engineering Department', NULL),
('ARC', 'Architecture Engineering Department', NULL),
('ECE', 'Electronics and Communication Engineering Department', NULL),
('CSE', 'Computer and Systems Engineering Department', NULL),
('EPM', 'Electrical Power and Machines Engineering Department', NULL);



-- University Requirements (Compulsory) -> 'core'
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('ASU011', 'Technical English Language', 'Grammar rules, technical writing characteristics, and reporting on engineering subjects.', 0, 'core', 'ASU'),
('ASU111', 'Human Rights', 'Introduction to public ethics, history of human rights, international instruments, and current rights issues.', 2, 'core', 'ASU'),
('ASU112', 'Report Writing & Communication Skills', 'Formal report components, nonverbal communication, infographics, and presentation skills.', 3, 'core', 'ASU'),
('ASU113', 'Professional Ethics and Legislations', 'Engineering ethics concepts, moral theory, decision making, and national legislation.', 3, 'core', 'ASU'),
('ASU114', 'Selected Topics in Contemporary Issues', 'National mega projects, multidisciplinary thinking, and pressing engineering issues like water and energy security.', 2, 'core', 'ASU');

-- University Requirements (Elective Group 1 & 2) -> 'elective'
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('ASU321', 'Innovation and Entrepreneurship', 'Entrepreneurial thinking, business models, product market fit, financing, and innovation in organizations.', 2, 'elective', 'ASU'),
('ASU322', 'Language Course', 'Basics of a non-English language (e.g., German, French), grammar, and translation of engineering texts.', 2, 'elective', 'ASU'),
('ASU323', 'Introduction to Accounting', 'Financial reporting, cost accounting concepts, budgeting, and cost-volume-profit analysis.', 2, 'elective', 'ASU'),
('ASU324', 'History of Engineering & Technology', 'Historical development of engineering, societal interaction, and the role of engineers in shaping the world.', 2, 'elective', 'ASU'),
('ASU331', 'Human Resource Management', 'HRM frameworks, job analysis, recruitment, training, performance management, and labor relations.', 2, 'elective', 'ASU'),
('ASU332', 'History of Architecture', 'Survey of global architectural history from prehistoric times to the 16th century and design principles.', 2, 'elective', 'ASU'),
('ASU333', 'Introduction to Marketing', 'Marketing concepts, consumer behavior, market mix, product strategy, pricing, and promotion.', 2, 'elective', 'ASU'),
('ASU334', 'Building Safety and Fire Protection', 'Fire risk, Eurocodes, fire resistance, evacuation, fire extinguishing systems, and safety management.', 2, 'elective', 'ASU'),
('ASU335', 'Literature and Arts', 'Themes in literature and art, artistic traditions, creative processes, and examples from Egyptian arts.', 2, 'elective', 'ASU'),
('ASU336', 'Business Administration', 'Entrepreneurship, management functions (planning, controlling), and functional areas like finance and marketing.', 2, 'elective', 'ASU');


-- Mathematics
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('PHM011', 'Basic Mathematics', 'Differential/integral calculus, algebra, and analytic/solid geometry.', 0, 'core', 'PHM'),
('PHM012', 'Mathematics (1)', 'Calculus review, chain rule, hyperbolic functions, integration techniques, and series.', 3, 'core', 'PHM'),
('PHM013', 'Mathematics (2)', 'Functions of several variables, partial differentiation, multiple integrals, and matrix algebra.', 3, 'core', 'PHM'),
('PHM111', 'Probability and Statistics', 'Probability theorems, random variables, distributions, and inferential statistics.', 2, 'core', 'PHM'),
('PHM112', 'Differential Equations and Numerical Analysis', 'ODEs, Laplace transform, Fourier series, PDEs, and numerical methods.', 4, 'core', 'PHM'),
('PHM113', 'Differential and Partial Differential Equations', 'First/higher order ODEs, Laplace transform, Fourier series, and PDEs.', 3, 'core', 'PHM'),
('PHM114', 'Numerical Analysis', 'Numerical solutions for non-linear equations, curve fitting, integration, and ODEs/PDEs.', 3, 'core', 'PHM'),
('PHM115', 'Engineering Mathematics', 'Linear/non-linear equations, error analysis, interpolation, and ODEs.', 3, 'core', 'PHM'),
('PHM211', 'Discrete Mathematics', 'Number theory, proof methods, sets, sequences, recursion, graphs, and trees.', 2, 'core', 'PHM'),
('PHM212', 'Complex, Special Functions and Numerical Analysis', 'Complex variables, Cauchy theorems, special functions (Gamma/Beta), and Bessel/Legendre series.', 3, 'core', 'PHM'),
('PHM213', 'Complex, Special Functions and Fourier Analysis', 'Complex derivatives/integrals, special functions, and continuous time Fourier transform.', 3, 'core', 'PHM');

-- Physics
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('PHM021', 'Vibration and Waves', 'Simple harmonic motion, damped/forced vibration, wave motion, sound, and light interference.', 3, 'core', 'PHM'),
('PHM022', 'Electricity and Magnetism', 'Electric fields, Gauss law, capacitance, magnetic fields, Ampere’s law, and induction.', 3, 'core', 'PHM'),
('PHM121', 'Modern Physics and Quantum Mechanics', 'Relativity, Planck’s theory, wave properties, Schrodinger equation, and band theory of solids.', 3, 'core', 'PHM'),
('PHM122', 'Physics of Semiconductors and Dielectrics', 'Crystal structure, semiconductor equilibrium, carrier transport, and dielectric properties.', 3, 'core', 'PHM'),
('PHM123', 'Thermal and Statistical Physics', 'Thermodynamics laws, entropy, statistical physics, Fermi-Dirac/Bose-Einstein distributions.', 3, 'core', 'PHM');

-- Mechanics
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('PHM031', 'Statics', 'Force systems, equilibrium of particles/rigid bodies, friction, centroids, and virtual work.', 3, 'core', 'PHM'),
('PHM032', 'Dynamics', 'Kinematics of particles, kinetics, work and energy, impulse and impact, and vibration.', 3, 'core', 'PHM'),
('PHM131', 'Rigid Body Dynamics', 'Mass moments of inertia, kinematics/kinetics of rigid bodies, and impact.', 2, 'core', 'PHM');

-- Chemistry
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('PHM041', 'Engineering Chemistry', 'Thermodynamics, electrochemistry, corrosion, water treatment, polymers, and pollution.', 3, 'core', 'PHM'),
('PHM141', 'Introduction to Organic Chemistry', 'Organic compound principles, reaction mechanisms, petroleum, and petrochemicals.', 2, 'core', 'PHM'),
('PHM142', 'Reaction Kinetics and Chemical Analysis', 'Equilibrium concepts, kinetic methods of analysis, and instrumental analysis methods.', 3, 'core', 'PHM'),
('PHM241', 'Electrochemistry', 'Conductivity, potential, electrode kinetics, batteries, corrosion, and electroplating.', 3, 'core', 'PHM'),
('PHM242', 'Polymer Chemistry', 'Polymer nomenclature, structure, molecular weight, and polymerization methods.', 3, 'core', 'PHM');


INSERT INTO Prerequisite (course_id, prereq_course_id)
SELECT c.course_id, p.course_id
FROM Course c, Course p
WHERE 
     (c.course_code = 'PHM112' AND p.course_code = 'PHM013')
    OR (c.course_code = 'PHM113' AND p.course_code = 'PHM013')
    OR (c.course_code = 'PHM114' AND p.course_code = 'PHM113')
    OR (c.course_code = 'PHM115' AND p.course_code = 'PHM013')
    OR (c.course_code = 'PHM212' AND p.course_code = 'PHM113')
    OR (c.course_code = 'PHM213' AND p.course_code = 'PHM113')
    OR (c.course_code = 'PHM022' AND p.course_code = 'PHM021')
    OR (c.course_code = 'PHM121' AND p.course_code IN ('PHM013', 'PHM022'))
    OR (c.course_code = 'PHM122' AND p.course_code = 'PHM121')
    OR (c.course_code = 'PHM123' AND p.course_code = 'PHM111')
    OR (c.course_code = 'PHM032' AND p.course_code = 'PHM031')
    OR (c.course_code = 'PHM131' AND p.course_code = 'PHM032')
    OR (c.course_code = 'PHM141' AND p.course_code = 'PHM041')
    OR (c.course_code = 'PHM142' AND p.course_code = 'PHM141')
    OR (c.course_code = 'PHM241' AND p.course_code = 'PHM041')
    OR (c.course_code = 'PHM242' AND p.course_code = 'PHM142');

-- -----------------------------------------------------------------------------
-- POPULATE DEPARTMENT_COURSE (Linking PHM Courses to Your Departments)
-- -----------------------------------------------------------------------------

-- 1. Faculty Requirements: Available to All Your Selected Departments
-- Courses: PHM012, PHM013, PHM021, PHM022, PHM031, PHM032, PHM041, PHM111
-- Targets: MCT, ARC, EPM, ECE, CSE
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 500, 'Faculty Requirement'
FROM Department d, Course c
WHERE c.course_code IN ('PHM012', 'PHM013', 'PHM021', 'PHM022', 'PHM031', 'PHM032', 'PHM041', 'PHM111')
-- Note: Assuming you have a 'department_code' column or identifying by name
AND (
    d.name LIKE '%(MCT)' OR 
    d.name LIKE '%(ARC)' OR 
    d.name LIKE '%(EPM)' OR 
    d.name LIKE '%(ECE)' OR 
    d.name LIKE '%(CSE)'
);

-- 2. Mechanical Discipline Requirements
-- Courses: PHM112 (Diff Eq), PHM131 (Rigid Body)
-- Targets: MCT (Only MCT remains from the Mechanical group)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 200, 'Mechanical Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code IN ('PHM112', 'PHM131')
AND d.name LIKE '%(MCT)';

-- 3. Electrical Discipline Requirements
-- Courses: PHM113 (Diff/PDE), PHM121 (Modern Phys), PHM122 (Semiconductors)
-- Targets: EPM, ECE, CSE
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 200, 'Electrical Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code IN ('PHM113', 'PHM121', 'PHM122')
AND (
    d.name LIKE '%(EPM)' OR 
    d.name LIKE '%(ECE)' OR 
    d.name LIKE '%(CSE)'
);

-- 4. Specialized Program Requirements

-- PHM211 (Discrete Math) -> CSE
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 150, 'Program Requirement'
FROM Department d, Course c
WHERE c.course_code = 'PHM211' 
AND d.name LIKE '%(CSE)';

-- PHM212 (Complex/Numerical) -> ECE
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 150, 'Program Requirement'
FROM Department d, Course c
WHERE c.course_code = 'PHM212' 
AND d.name LIKE '%(ECE)';

-- PHM213, PHM114 -> Communication Systems (ECE) and Computer Systems (CSE)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 100, 'Program Requirement'
FROM Department d, Course c
WHERE c.course_code IN ('PHM213', 'PHM114', 'PHM123') 
AND (
    d.name LIKE '%(ECE)' OR 
    d.name LIKE '%(CSE)'
);

-- Automation and Control
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('MCT211', 'Automatic Control', 'Fundamentals of open/closed loop systems, modelling techniques, time/frequency domain analysis, PID tuning, and industrial control components.', 3, 'core', 'MCT'),
('MCT311', 'Hydraulics and Pneumatics Control', 'Physical principles of fluidic control, hydraulic components (pumps, valves, actuators), electrohydraulic circuits, and pneumatic systems design.', 3, 'core', 'MCT'),
('MCT312', 'Industrial Automation', 'Automation system structure, sensors, actuators, PLC hardware and programming, SCADA systems, and industrial communication networks.', 2, 'core', 'MCT'),
('MCT313', 'Automation', 'Logic systems design, Boolean logic, PLC programming languages (Ladder, FBD, SFC), HMI, DCS, and applications in flexible manufacturing.', 3, 'core', 'MCT'),
('MCT411', 'Hybrid Control Systems', 'Time-driven vs event-driven systems, discrete event systems, Petri-nets, hybrid control architecture, and supervisory control design.', 3, 'core', 'MCT'),
('MCT412', 'Motion Control', 'Motion actuators (Induction, DC, Stepper), sensors in motion control, motion system design, stability, and error analysis.', 3, 'elective', 'MCT');

-- Mechatronics Design and Manufacturing
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('MCT131', 'Introduction to Mechatronics', 'Mechatronics design philosophy, system components, synergetic integration of mechanical/electrical systems, and introduction to programming.', 3, 'core', 'MCT'),
('MCT231', 'Engineering Measurements', 'Measurement systems design, sensors classification, static/dynamic performance, uncertainty analysis, and signal conditioning.', 3, 'core', 'MCT'),
('MCT232', 'Industrial Electronics', 'Operational amplifiers, active filters, timers, A/D and D/A converters, data acquisition systems, and power electronics applications.', 3, 'core', 'MCT'),
('MCT233', 'Dynamic Modeling and Simulation', 'Mathematical modeling of mechanical, electrical, thermal, and fluidic systems, transfer functions, block diagrams, and state space representation.', 3, 'core', 'MCT'),
('MCT234', 'Modeling and Simulation of Mechatronics Systems', 'Linear vs non-linear systems, discrete-time modeling, numerical methods of simulation, and Hardware-in-the-Loop (HIL) simulation.', 2, 'core', 'MCT'),
('MCT333', 'Mechatronic Systems Design', 'Mechatronic product development process, V-model methodology, selection of actuators/sensors, and integration using CAD/Simulink tools.', 3, 'core', 'MCT'),
('MCT334', 'Sensors and Measurement Systems', 'Advanced sensor technologies, signal conditioning, EMI/EMC issues, grounding, shielding, and multisensory fusion.', 3, 'core', 'MCT');

-- Embedded and Smart Systems
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('MCT421', 'Embedded Systems for Automotive', 'Static code checking (MISRA), RTOS in automotive, CAN bus standard, OSEK network management, and AUTOSAR concepts.', 3, 'elective', 'MCT'),
('MCT422', 'Automotive Embedded Networking', 'Automotive CAN network simulation, CAPL scripting, TIVA C embedded development, and vehicle network communication protocols.', 3, 'elective', 'MCT');

-- Robotics and Applications
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('MCT341', 'Introduction to Autotronics', 'Vehicle main systems (propulsion, braking, steering), engine management, electric vehicles, and introduction to autotronic systems.', 2, 'elective', 'MCT'),
('MCT344', 'Industrial Robotics', 'Robot kinematics (forward/inverse), trajectory planning, dynamics (Newton-Euler/Lagrange), and robot control techniques.', 3, 'core', 'MCT'),
('MCT441', 'Rehabilitation Robots', 'Physical Human-Robot Interaction, impedance control, BCI, and design of prosthetic limbs and exoskeletons.', 3, 'elective', 'MCT'),
('MCT443', 'Design of Autonomous Systems', 'Perception, multi-sensor fusion, localization, navigation, path planning, and autonomous system architecture.', 3, 'core', 'MCT'),
('MCT446', 'Autotronics', 'Advanced braking systems (ABS/EBD), active suspension, drive-by-wire, stability control, and hybrid vehicle control strategies.', 3, 'elective', 'MCT');

-- Graduation Projects
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('MCT491', 'Mechatronics Graduation Project (1)', 'Problem definition, literature review, and preliminary design of a mechatronics engineering project.', 3, 'core', 'MCT'),
('MCT492', 'Mechatronics Graduation Project (2)', 'Implementation, testing, and validation of the mechatronics project prototype.', 3, 'core', 'MCT');

INSERT INTO Prerequisite (course_id, prereq_course_id)
SELECT c.course_id, p.course_id
FROM Course c, Course p
WHERE 
    -- MCT211 requires MEP231 (Measurement & Instrumentation)
    (c.course_code = 'MCT211' AND p.course_code = 'MEP231')
    OR
    -- MCT311 requires MEP221 or MEP222 (Fluid Mechanics)
    (c.course_code = 'MCT311' AND p.course_code IN ('MEP221', 'MEP222'))
    OR
    -- MCT312 requires MCT211 and CSE131
    (c.course_code = 'MCT312' AND p.course_code IN ('MCT211', 'CSE131'))
    OR
    -- MCT313 requires MCT211
    (c.course_code = 'MCT313' AND p.course_code = 'MCT211')
    OR
    -- MCT411/412/413 require MCT211
    (c.course_code IN ('MCT411', 'MCT412', 'MCT413') AND p.course_code = 'MCT211')
    OR
    -- MCT231 requires PHM111 (Prob & Stat)
    (c.course_code = 'MCT231' AND p.course_code = 'PHM111')
    OR
    -- MCT232 requires ECE213 or ECE215
    (c.course_code = 'MCT232' AND p.course_code IN ('ECE213', 'ECE215'))
    OR
    -- MCT233 requires PHM131 (Rigid Body) and PHM112 (Diff Eq)
    (c.course_code = 'MCT233' AND p.course_code IN ('PHM131', 'PHM112'))
    OR
    -- MCT234 requires MDP311 (Vibrations) or MCT233
    (c.course_code = 'MCT234' AND p.course_code IN ('MDP311', 'MCT233'))
    OR
    -- MCT333 requires MCT131 and MCT234
    (c.course_code = 'MCT333' AND p.course_code IN ('MCT131', 'MCT234'))
    OR
    -- MCT334 requires MEP231 and MCT232
    (c.course_code = 'MCT334' AND p.course_code IN ('MEP231', 'MCT232'))
    OR
    -- MCT421 requires CSE211 (Embedded Systems)
    (c.course_code = 'MCT421' AND p.course_code = 'CSE211')
    OR
    -- MCT341/342/343 require MCT131
    (c.course_code IN ('MCT341', 'MCT342', 'MCT343') AND p.course_code = 'MCT131')
    OR
    -- MCT344 requires MDP212 (Mechanics of Machines)
    (c.course_code = 'MCT344' AND p.course_code = 'MDP212')
    OR
    -- MCT443 requires MCT344
    (c.course_code = 'MCT443' AND p.course_code = 'MCT344')
    OR
    -- MCT446 requires MCT341
    (c.course_code = 'MCT446' AND p.course_code = 'MCT341')
    OR
    -- Graduation Project 2 requires Project 1
    (c.course_code = 'MCT492' AND p.course_code = 'MCT491');

-- 1. Automatic Control (MCT211)
-- Originally for Mechanical Depts. 
-- Now assigned to: Mechatronics (MCT) and Electrical Power (EPM) as Core.
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 300, 'Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'MCT211'
AND d.department_code IN ('MCT', 'EPM');

-- 2. Hydraulics and Pneumatics Control (MCT311)
-- Originally for Mechanical Depts.
-- Now assigned to: Mechatronics (MCT) as Core.
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 200, 'Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'MCT311'
AND d.department_code = 'MCT';

-- 3. Industrial Automation (MCT312)
-- Originally Elective for MEP/MDP.
-- Now assigned to: Mechatronics (MCT) and Electrical Power (EPM) as Elective.
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'elective', 100, NULL
FROM Department d, Course c
WHERE c.course_code = 'MCT312'
AND d.department_code IN ('MCT', 'EPM');

-- 4. Introduction to Autotronics (MCT341)
-- Originally for Automotive (MEA).
-- Now assigned to: Mechatronics (MCT) as Elective (likely a concentration track within MCT).
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'elective', 50, 'Automotive Concentration'
FROM Department d, Course c
WHERE c.course_code = 'MCT341'
AND d.department_code = 'MCT';

-- 5. Autotronics (MCT446)
-- Originally for Automotive (MEA).
-- Now assigned to: Mechatronics (MCT).
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'elective', 50, 'Automotive Concentration'
FROM Department d, Course c
WHERE c.course_code = 'MCT446'
AND d.department_code = 'MCT';

-- 6. Embedded Systems for Automotive (MCT421)
-- Originally for Automotive (MEA).
-- Now assigned to: Mechatronics (MCT) and Computer & Systems (CSE) as Elective.
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'elective', 50, 'Embedded Systems Track'
FROM Department d, Course c
WHERE c.course_code = 'MCT421'
AND d.department_code IN ('MCT', 'CSE');



    -- 1. Architectural Design & Studios
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('ARC111', 'Principles of Architecture Design Studio', 'Fundamentals of graphic communication, model making, and exploration of conceptual and spatial aspects of architecture.', 3, 'core', 'ARC'),
('ARC112', 'Creativity and Design Studio', 'Development of creative skills and perception of spaces through designing small scale projects like residences and kinder gardens.', 4, 'core', 'ARC'),
('ARC113', 'Vernacular Architecture Design Studio', 'Application of vernacular design fundamentals, focusing on environmental responsiveness and local traditions.', 3, 'core', 'ARC'),
('ARC211', 'Building Type Design Studio', 'Design of public projects with complex programs (e.g., museums, libraries) considering context and codes.', 4, 'core', 'ARC'),
('ARC212', 'Multi Story Accommodation Building Design Studio', 'Design of multi-story residential buildings in urban contexts, focusing on circulation, orientation, and structure.', 4, 'core', 'ARC'),
('ARC213', 'Environmental Architecture Design Studio (1)', 'Understanding architecture in its environment, spatial design according to climatic issues and human needs.', 3, 'core', 'ARC'),
('ARC214', 'Environmental Architecture Design Studio (2)', 'Developing design capacities reflecting environmental behavior and the role of structural systems and materials.', 3, 'core', 'ARC'),
('ARC311', 'Smart Systems Design Studio', 'Technical design approaches embracing intelligent adaptivity, BMS, and high-tech building components.', 4, 'core', 'ARC'),
('ARC312', 'Sustainable Architecture Design Studio (1)', 'Designing buildings with energy-saving features, green aspects, and harvesting natural resources.', 3, 'core', 'ARC'),
('ARC313', 'Sustainable Architecture Design Studio (2)', 'Comprehensive application of sustainable principles, from conceptual stages to construction systems.', 3, 'core', 'ARC'),
('ARC411', 'Thematic Design Studio', 'Analytical design of complex architectural projects addressing specific themes and modern theories.', 4, 'core', 'ARC'),
('ARC412', 'Technological Design Studio', 'Integration of technological systems, innovative materials, and environmental control in comprehensive design.', 4, 'core', 'ARC'),
('ARC413', 'Smart Housing Design Studio', 'Design of housing projects taking into account local environment, nature, and smart systems.', 4, 'core', 'ARC');

-- 2. Theories of Design and Architecture
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('ARC221', 'Design Methods', 'Architectural problem solving, root maps of design process, and creative problem solving (CPS) techniques.', 3, 'core', 'ARC'),
('ARC321', 'Theory and Philosophy of Contemporary Architecture', 'Theoretical foundations of architectural movements from the Industrial Revolution to Contemporary Architecture.', 3, 'core', 'ARC'),
('ARC322', 'Architectural Criticism & Project Evaluation', 'Theoretical approaches of contemporary thought, concepts of integration, and techniques of evaluating projects.', 2, 'elective', 'ARC'),
('ARC323', 'Built Environment Accessibility', 'Design for All concepts, disability needs, and regulations for accessible design in urban and architectural levels.', 2, 'elective', 'ARC'),
('ARC421', 'Ergonomics & Interior Design Principles', 'Interior design principles, color theory, interior space elements, and concept development.', 2, 'core', 'ARC'),
('ARC422', 'Human Aspects in Architecture', 'Influence of human use on physical settings, territoriality, cultural expression, and evidence-based design.', 3, 'elective', 'ARC'),
('ARC423', 'Identity and Contemporaneity in Middle East Architecture', 'Modern architectural developments in the Middle East and the relationship between architecture and regional identity.', 3, 'elective', 'ARC');

-- 3. History of Architecture
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('ARC131', 'History of Arts and Architecture 1', 'Art and architecture of ancient eras: Ancient Egyptian, West Asiatic, Greek, Roman, and Byzantine.', 3, 'core', 'ARC'),
('ARC132', 'History of Arts and Architecture 2', 'Islamic art and architecture development, and Western European architecture from Romanesque to Neoclassical.', 3, 'core', 'ARC'),
('ARC133', 'Intro to History and Theory of Arts', 'Relation between arts, architectural concepts, and design philosophy across different old cultures.', 3, 'core', 'ARC');

-- 4. Computer Applications and Digital Skills
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('ARC141', 'Architectural Representation', 'Freehand drawing techniques, visual design elements, and communicating forms graphically in 2D and 3D.', 3, 'core', 'ARC'),
('ARC142', 'Digital Presentation of the Built Environment', 'Computer aided design (CAD) for 2D/3D representation, raster/vector graphics, and rendering.', 2, 'core', 'ARC'),
('ARC143', 'Building Engineering Drawing', 'Engineering drawings including plans, sections, elevations, CAD standards, and structural systems representation.', 3, 'core', 'ARC'),
('ARC241', 'Modeling of the Built Environment', '3D modeling, form generation, parametric modeling using tools like Rhino and Grasshopper.', 2, 'core', 'ARC'),
('ARC341', 'Photography and Architecture', 'Architectural photography techniques, documentation of models and spaces, and critical evaluation.', 2, 'elective', 'ARC'),
('ARC441', 'Building Information Modeling (BIM)', 'Intelligent 3D model-based process (Revit), creating and managing tender drawings and schematic designs.', 3, 'core', 'ARC'),
('ARC442', 'Principles of Parametric Design', 'Generative design, parametric modeling, algorithms, and digital fabrication using CNC equipment.', 3, 'core', 'ARC');

-- 5. Building Technology and Working Drawings
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('ARC151', 'Building (1): Conventional Construction Systems', 'Construction processes, load bearing walls, RC skeletons, arches, lintels, and staircases.', 3, 'core', 'ARC'),
('ARC152', 'Building (2): Finishing Works', 'Building finishing processes: carpentry, flooring, wall cladding, plastering, painting, and ceilings.', 3, 'core', 'ARC'),
('ARC251', 'Building (3): Advanced Construction', 'Wide span structure systems, precast/post-tension systems, curtain walls, and advanced finishing materials.', 3, 'core', 'ARC'),
('ARC252', 'Building (3): Mass Housing Production', 'Coordinates systems, advanced construction for mass housing, precast systems, and landscape construction.', 3, 'core', 'ARC'),
('ARC253', 'Building (3): Sustainable Construction', 'Vernacular materials (earth, adobe, straw bales) and native technologies for sustainable building.', 3, 'core', 'ARC'),
('ARC254', 'Landscape Construction', 'Landscape constructing materials, hardscape, softscape, and street furniture details.', 2, 'core', 'ARC'),
('ARC351', 'Working Design (1)', 'Execution drawings, coordination between technical systems, and CSI coding system.', 3, 'core', 'ARC'),
('ARC352', 'Working Design (2)', 'Detailing architectural spaces, internal finishing, fixtures, assembly drawings, and BOQs.', 3, 'core', 'ARC'),
('ARC451', 'Working Design (3)', 'Execution documents for complex projects, advanced installations (Firefighting, BMS), and specifications.', 3, 'core', 'ARC'),
('ARC452', 'Working Design (3) - Towers', 'Execution and tender documents for residential towers, advanced supplementary systems, and coordination.', 3, 'core', 'ARC');

INSERT INTO Prerequisite (course_id, prereq_course_id)
SELECT c.course_id, p.course_id
FROM Course c, Course p
WHERE 
    -- ARC113 requires ARC111
    (c.course_code = 'ARC113' AND p.course_code = 'ARC111')
    -- ARC211 requires ARC111
    OR (c.course_code = 'ARC211' AND p.course_code = 'ARC111')
    -- ARC212 requires ARC111
    OR (c.course_code = 'ARC212' AND p.course_code = 'ARC111')
    -- ARC213 requires ARC111
    OR (c.course_code = 'ARC213' AND p.course_code = 'ARC111')
    -- ARC214 requires ARC213
    OR (c.course_code = 'ARC214' AND p.course_code = 'ARC213')
    -- ARC311 requires ARC211 and ARC321
    OR (c.course_code = 'ARC311' AND p.course_code IN ('ARC211', 'ARC321'))
    -- ARC312 requires ARC214
    OR (c.course_code = 'ARC312' AND p.course_code = 'ARC214')
    -- ARC313 requires ARC312
    OR (c.course_code = 'ARC313' AND p.course_code = 'ARC312')
    -- ARC411 requires ARC311
    OR (c.course_code = 'ARC411' AND p.course_code = 'ARC311')
    -- ARC412 requires ARC311 and ARC351
    OR (c.course_code = 'ARC412' AND p.course_code IN ('ARC311', 'ARC351'))
    -- ARC221 requires ARC112
    OR (c.course_code = 'ARC221' AND p.course_code = 'ARC112')
    -- ARC132 requires ARC131
    OR (c.course_code = 'ARC132' AND p.course_code = 'ARC131')
    -- ARC241 requires ARC142
    OR (c.course_code = 'ARC241' AND p.course_code = 'ARC142')
    -- ARC441 requires ARC241 and ARC351
    OR (c.course_code = 'ARC441' AND p.course_code IN ('ARC241', 'ARC351'))
    -- ARC442 requires ARC241 and ARC321
    OR (c.course_code = 'ARC442' AND p.course_code IN ('ARC241', 'ARC321'))
    -- ARC152 requires ARC151
    OR (c.course_code = 'ARC152' AND p.course_code = 'ARC151')
    -- ARC251, ARC252, ARC253, ARC254 require ARC152
    OR (c.course_code IN ('ARC251', 'ARC252', 'ARC253', 'ARC254') AND p.course_code = 'ARC152')
    -- ARC351 requires ARC152
    OR (c.course_code = 'ARC351' AND p.course_code = 'ARC152')
    -- ARC352 requires ARC351
    OR (c.course_code = 'ARC352' AND p.course_code = 'ARC351')
    -- ARC451, ARC452 require ARC352
    OR (c.course_code IN ('ARC451', 'ARC452') AND p.course_code = 'ARC352');



-- 1. Electronics
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('ECE111', 'Electronic Materials', 'Crystals, bonding, energy bands in solids, semiconductors, Fermi level, PN-junction characteristics, and Zener diodes.', 3, 'core', 'ECE'),
('ECE211', 'Electronics', 'Diode models and applications, BJT and MOSFET operation, single-stage amplifiers, and operational amplifiers.', 3, 'core', 'ECE'),
('ECE212', 'Digital Circuits', 'MOSFET as a switch, CMOS inverter, combinational circuits, sequential circuits, and logic circuit characterization.', 3, 'core', 'ECE'),
('ECE213', 'Solid State Electronic Devices', 'Theory of junctions, bipolar transistor operation, field effect devices (MESFET, MOSFET), LEDs, and Laser Diodes.', 3, 'core', 'ECE'),
('ECE214', 'Electronic Circuits (1)', 'Small signal models of BJT and MOSFET, DC biasing, multi-stage amplifiers, frequency response, and active filters.', 4, 'core', 'ECE'),
('ECE215', 'Introduction to Electronics', 'Diode applications, Op-amp models and applications, analog/digital signals, and A/D & D/A converters.', 2, 'core', 'ECE'),
('ECE311', 'Advanced Semiconductor Devices', 'Scaling principles, submicron devices, TFET, SOI transistors, FinFET, and surround gate FET.', 2, 'core', 'ECE'),
('ECE312', 'Analog Circuits (1)', 'Analysis of single/multi-stage amplifiers, differential amplifiers, current mirrors, and introduction to feedback.', 3, 'core', 'ECE'),
('ECE313', 'Analog Circuits (2)', 'Feedback topologies, stability, frequency compensation, oscillators, VCOs, and power amplifiers.', 3, 'core', 'ECE'),
('ECE314', 'VLSI Design', 'CMOS fabrication, scaling, IC layout, datapath building blocks, semiconductor memories, and FPGA design.', 3, 'core', 'ECE'),
('ECE315', 'Electronic Circuits (2)', 'Differential amplifiers in BJT/CMOS, active loads, feedback topologies, and power amplifiers (Class A, B, AB).', 3, 'core', 'ECE'),
('ECE316', 'Digital Circuit Design', 'CMOS inverter noise margin, pass transistors, dynamic design, latches, flip-flops, RAM, ROM, and BiCMOS circuits.', 3, 'core', 'ECE'),
('ECE317', 'Modern VLSI Devices', 'MOS capacitor, nanoscale MOSFETs, high field effects, SOI devices, and multi-gate MOSFETs.', 3, 'elective', 'ECE'),
('ECE318', 'Electronic Measurements and Instrumentation', 'Digital multimeter, oscilloscope, sensors, amplifiers, noise, and data acquisition systems.', 3, 'elective', 'ECE'),
('ECE411', 'Integrated Circuits Technology', 'IC processing, crystal growth, photolithography, etching, oxidation, diffusion, and interconnect modeling.', 3, 'elective', 'ECE'),
('ECE412', 'Analog Integrated Circuit Design', 'Advanced current mirrors, folded cascode op-amps, stability, bandgap references, and noise analysis.', 3, 'elective', 'ECE'),
('ECE413', 'ASIC Design and Automation', 'EDA flows, HDL languages, logic synthesis, design for testability, floor-planning, and routing.', 3, 'elective', 'ECE'),
('ECE414', 'RF Circuit Design', 'RF transceivers, noise analysis, impedance matching, LNA, mixers, oscillators, and RF power amplifiers.', 3, 'elective', 'ECE'),
('ECE415', 'Electronic Instrumentation', 'Sensor categories, signal conditioning, noise reduction, lock-in detection, and smart sensors.', 3, 'elective', 'ECE'),
('ECE416', 'MEMS Design', 'Fabrication processes, system modeling, mechanical design, damping, actuation methods, and sensing elements.', 3, 'elective', 'ECE'),
('ECE417', 'Low Power Digital Design', 'Energy vs power, dynamic/static power optimization, clock gating, and subthreshold circuit design.', 3, 'elective', 'ECE'),
('ECE418', 'Selected Topics in Electronics', 'Recent directions and advanced topics in electronics engineering.', 3, 'elective', 'ECE'),
('ECE419', 'Selected Topics in Circuits and Systems', 'Recent directions and advanced topics in circuits and systems.', 3, 'elective', 'ECE');

-- 2. Waves and Photonics
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('ECE131', 'Electrostatics and Magnetostatics', 'Coulomb law, Gauss law, electric potential, magnetic fields, Amperes law, Maxwell equations, and wave equations.', 3, 'core', 'ECE'),
('ECE331', 'Electromagnetic Waves', 'Time varying fields, wave propagation, skin depth, reflection/refraction, Poynting theorem, and transmission lines.', 3, 'core', 'ECE'),
('ECE332', 'Waveguides', 'Rectangular/circular waveguides, microstrip lines, optical fibers, mode analysis, and dispersion.', 3, 'core', 'ECE'),
('ECE333', 'Microwave Engineering', 'Guided waves, scattering parameters, passive devices (couplers, isolators), and microstrip transmission lines.', 4, 'core', 'ECE'),
('ECE334', 'Optical Fiber Communications', 'Ray/modal analysis, dispersion, attenuation, laser sources, photodetectors, and link power budgets.', 4, 'core', 'ECE'),
('ECE335', 'Microwave Measurements', 'Measurement of power, impedance, frequency, scattering parameters, and antenna radiation patterns.', 3, 'elective', 'ECE'),
('ECE336', 'Integrated Optics and Optical MEMS', 'Dielectric waveguides, optical couplers/switches, MEMS technology, micro-mirrors, and tunable filters.', 3, 'elective', 'ECE'),
('ECE337', 'Microwave Circuits', 'Planar transmission lines, impedance matching, microwave filters, and microwave amplifiers.', 3, 'elective', 'ECE'),
('ECE338', 'Optical Sensing and Instrumentation', 'Geometrical optics, interferometers, LiDAR, spectroscopy, and optical coherent imaging.', 3, 'elective', 'ECE'),
('ECE431', 'Optoelectronics', 'Light-matter interaction, lasers (semiconductor, DFB), LED dynamics, and PIN/APD photodetectors.', 3, 'core', 'ECE'),
('ECE432', 'Antenna Engineering and Propagation', 'Dipoles, arrays, microstrip antennas, broadband antennas, aperture antennas, and atmospheric effects.', 2, 'core', 'ECE'),
('ECE433', 'Microwave Circuits and Systems', 'Matching networks, resonators, planar filters, power amplifiers, and microwave systems.', 3, 'core', 'ECE'),
('ECE434', 'Optical Communication Systems', 'Pulse propagation, noise in detectors/amplifiers, WDM systems, and coherent detection.', 3, 'elective', 'ECE'),
('ECE435', 'Fundamentals of Photonics', 'Dielectric waveguides, electro-optics, acousto-optics, modulators, and optical routers.', 3, 'elective', 'ECE'),
('ECE436', 'Micro Photonic Systems', 'Diffraction gratings, micro-resonators, optical MEMS switches, and multilayer filter design.', 3, 'elective', 'ECE'),
('ECE437', 'Selected Topics in Electromagnetics', 'Advanced and recent topics in electromagnetics.', 3, 'elective', 'ECE'),
('ECE438', 'Microwave Devices', 'Microwave tubes (Klystron, TWT), solid state devices (Gunn, IMPATT), and parametric devices.', 3, 'elective', 'ECE'),
('ECE439', 'Optoelectronic Devices', 'Laser rate equations, erbium doped fiber amplifiers, semiconductor optical amplifiers, and solar cells.', 3, 'elective', 'ECE'),
('ECE440', 'RF and Microwave Systems', 'Mixers, frequency multipliers, radar systems, radiometer systems, and microwave heating.', 3, 'elective', 'ECE');

-- 3. Communication Engineering
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('ECE251', 'Signals and Systems Fundamentals', 'Signal classification, LTI systems, convolution, Fourier series/transform, and sampling theory.', 4, 'core', 'ECE'),
('ECE252', 'Fundamentals of Communication Systems', 'AM/FM/PM modulation, superheterodyne receiver, pulse modulation (PCM), and line coding.', 3, 'core', 'ECE'),
('ECE253', 'Signals and Systems', 'Continuous/discrete time signals, LTI systems, Fourier series, CTFT, and DTFT properties.', 4, 'core', 'ECE'),
('ECE254', 'Analog Communications', 'Amplitude/Frequency modulation, random processes, noise analysis, and Gaussian process.', 3, 'core', 'ECE'),
('ECE255', 'Digital Signal Processing', 'Z-transform, DFT, FFT, digital filter design (FIR/IIR), and multi-rate signal processing.', 3, 'core', 'ECE'),
('ECE351', 'Analog and Digital Communication Systems', 'Random processes, noise figure, matched filter, ISI, M-ary modulation, and Shannon capacity.', 3, 'core', 'ECE'),
('ECE352', 'Telecommunication Networks', 'LAN/WAN, OSI model, TCP/IP, physical layer, switching, and network devices.', 3, 'core', 'ECE'),
('ECE353', 'Wireless Communication Networks', 'Multipath fading, cellular concepts, diversity, MIMO, OFDM, and 4G/5G systems.', 3, 'core', 'ECE');


INSERT INTO Prerequisite (course_id, prereq_course_id)
SELECT c.course_id, p.course_id
FROM Course c, Course p
WHERE 
    -- ECE211 requires PHM122
    (c.course_code = 'ECE211' AND p.course_code = 'PHM122')
    -- ECE212 requires CSE111
    OR (c.course_code = 'ECE212' AND p.course_code = 'CSE111')
    -- ECE213 requires PHM123 and ECE111
    OR (c.course_code = 'ECE213' AND p.course_code IN ('PHM123', 'ECE111'))
    -- ECE214 requires ECE213 and EPM114
    OR (c.course_code = 'ECE214' AND p.course_code IN ('ECE213', 'EPM114'))
    -- ECE215 requires PHM022
    OR (c.course_code = 'ECE215' AND p.course_code = 'PHM022')
    -- ECE312 requires ECE211
    OR (c.course_code = 'ECE312' AND p.course_code = 'ECE211')
    -- ECE313 requires ECE312
    OR (c.course_code = 'ECE313' AND p.course_code = 'ECE312')
    -- ECE314 requires ECE212
    OR (c.course_code = 'ECE314' AND p.course_code = 'ECE212')
    -- ECE315 requires ECE214
    OR (c.course_code = 'ECE315' AND p.course_code = 'ECE214')
    -- ECE331 requires PHM212 and EPM112
    OR (c.course_code = 'ECE331' AND p.course_code IN ('PHM212', 'EPM112'))
    -- ECE332 requires PHM212 and ECE331
    OR (c.course_code = 'ECE332' AND p.course_code IN ('PHM212', 'ECE331'))
    -- ECE333 requires ECE331
    OR (c.course_code = 'ECE333' AND p.course_code = 'ECE331')
    -- ECE431 requires ECE311 and ECE332
    OR (c.course_code = 'ECE431' AND p.course_code IN ('ECE311', 'ECE332'))
    -- ECE432 requires ECE332
    OR (c.course_code = 'ECE432' AND p.course_code = 'ECE332')
    -- ECE251 requires PHM111 and PHM113
    OR (c.course_code = 'ECE251' AND p.course_code IN ('PHM111', 'PHM113'))
    -- ECE252 requires ECE251
    OR (c.course_code = 'ECE252' AND p.course_code = 'ECE251')
    -- ECE253 requires PHM111 and PHM213
    OR (c.course_code = 'ECE253' AND p.course_code IN ('PHM111', 'PHM213'))
    -- ECE254 requires ECE253
    OR (c.course_code = 'ECE254' AND p.course_code = 'ECE253')
    -- ECE255 requires ECE253
    OR (c.course_code = 'ECE255' AND p.course_code = 'ECE253')
    -- ECE351 requires ECE252
    OR (c.course_code = 'ECE351' AND p.course_code = 'ECE252')
    -- ECE352 requires ECE252
    OR (c.course_code = 'ECE352' AND p.course_code = 'ECE252')
    -- ECE353 requires ECE351
    OR (c.course_code = 'ECE353' AND p.course_code = 'ECE351');


    -- 1. Signals and Systems Fundamentals (ECE251)
-- Taken by: Computer Engineering (CSE), Electrical Power (EPM)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 200, 'Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'ECE251' AND d.department_code IN ('CSE', 'EPM');

-- 2. Electronics (ECE211)
-- Taken by: Electrical Power (EPM)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 150, 'Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'ECE211' AND d.department_code = 'EPM';

-- 3. Fundamentals of Communication Systems (ECE252)
-- Taken by: Electrical Power (EPM)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 150, 'Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'ECE252' AND d.department_code = 'EPM';

-- 4. Introduction to Electronics (ECE215)
-- Taken by: Mechatronics (MCT)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 150, 'Mechatronics Requirement'
FROM Department d, Course c
WHERE c.course_code = 'ECE215' AND d.department_code = 'MCT';

-- 5. Digital Circuits (ECE212)
-- Taken by: Electrical Power (EPM) as elective/core depending on track
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'elective', 100, NULL
FROM Department d, Course c
WHERE c.course_code = 'ECE212' AND d.department_code = 'EPM';


-- 1. Computer Hardware & Embedded Systems
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('CSE111', 'Logic Design', 'Number systems, boolean algebra, logic gates, combinational circuits, flip-flops, counters, and registers.', 3, 'core', 'CSE'),
('CSE112', 'Computer Organization and Architecture', 'Computer performance metrics, instruction sets (RISC/CISC), CPU datapath, pipelining, and memory hierarchy.', 4, 'core', 'CSE'),
('CSE211', 'Introduction to Embedded Systems', 'Microcontroller architecture, addressing modes, assembly programming, I/O interfacing, interrupts, and timers.', 3, 'core', 'CSE'),
('CSE212', 'Computer Organization', 'Functional organization, performance evaluation, instruction formats, CPU control unit design, and bus systems.', 3, 'core', 'CSE'),
('CSE311', 'Computer Architecture', 'Instruction level parallelism, superscalar processors, cache coherence, multicore architectures, and I/O systems.', 3, 'core', 'CSE'),
('CSE312', 'Electronic Design Automation', 'EDA flows, HDL (Verilog/VHDL), logic synthesis, timing analysis, placement and routing, and verification.', 2, 'elective', 'CSE'),
('CSE313', 'Digital Systems Testing', 'Fault modeling, test generation, design for testability (DFT), scan design, and built-in self-test (BIST).', 2, 'elective', 'CSE'),
('CSE314', 'Parallel and Cluster Computing', 'Parallel architectures, cluster computing, message passing interface (MPI), load balancing, and GPU programming.', 2, 'elective', 'CSE'),
('CSE411', 'Real-Time and Embedded Systems Design', 'Real-time scheduling, RTOS, hardware/software codesign, device drivers, and embedded system validation.', 3, 'core', 'CSE'),
('CSE412', 'Embedded Operating Systems', 'Embedded Linux architecture, kernel modules, bootloaders, file systems, and real-time Linux.', 3, 'elective', 'CSE'),
('CSE413', 'Real-Time Operating Systems', 'RTOS concepts, task management, inter-task communication, synchronization, and resource management.', 2, 'elective', 'CSE'),
('CSE414', 'Digital VLSI Systems', 'CMOS technology, layout design rules, delay modeling, power analysis, and FPGA architecture.', 2, 'elective', 'CSE'),
('CSE415', 'Fault Tolerant Computing', 'Hardware/software redundancy, reliability modeling, error detection/correction codes, and safety-critical systems.', 2, 'elective', 'CSE');

-- 2. Software Engineering
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('CSE031', 'Computing in Engineering', 'Introduction to cloud computing, IoT, big data, network protocols, and computational thinking.', 2, 'core', 'CSE'),
('CSE131', 'Computer Programming', 'Structured programming, data types, control structures, functions, arrays, pointers, and memory management.', 3, 'core', 'CSE'),
('CSE231', 'Advanced Computer Programming', 'Object-oriented programming, classes, inheritance, polymorphism, templates, and exception handling.', 3, 'core', 'CSE'),
('CSE232', 'Advanced Software Engineering', 'Object-oriented analysis/design, UML modeling, design patterns, and software development life cycle.', 3, 'core', 'CSE'),
('CSE233', 'Agile Software Engineering', 'Agile principles, Scrum/Kanban, user stories, sprint planning, continuous integration, and agile testing.', 2, 'core', 'CSE'),
('CSE331', 'Data Structures and Algorithms', 'Linked lists, stacks, queues, trees, graphs, sorting algorithms, and complexity analysis.', 3, 'core', 'CSE'),
('CSE332', 'Design and Analysis of Algorithms', 'Divide-and-conquer, dynamic programming, greedy algorithms, graph algorithms, and NP-completeness.', 3, 'core', 'CSE'),
('CSE333', 'Database Systems', 'Relational model, SQL, normalization, ER modeling, transaction management, and concurrency control.', 3, 'core', 'CSE'),
('CSE334', 'Software Engineering', 'Software processes, requirements engineering, architectural design, testing strategies, and quality assurance.', 3, 'core', 'CSE'),
('CSE335', 'Operating Systems', 'Process management, threads, CPU scheduling, synchronization, deadlocks, memory management, and file systems.', 3, 'core', 'CSE'),
('CSE336', 'Software Design Patterns', 'Creational, structural, and behavioral design patterns, and refactoring techniques.', 2, 'elective', 'CSE'),
('CSE337', 'Software Testing', 'Testing techniques, black-box vs white-box testing, unit testing, integration testing, and automated testing tools.', 2, 'elective', 'CSE'),
('CSE338', 'Software Testing, Validation and Verification', 'V&V lifecycle, inspections, static analysis, model checking, and formal verification methods.', 3, 'elective', 'CSE'),
('CSE339', 'Software Formal Specifications', 'Mathematical modeling of software, Z notation, state-based/event-based approaches, and formal verification.', 2, 'elective', 'CSE'),
('CSE341', 'Internet Programming', 'Web development, client-side/server-side scripting, MVC architecture, web services, and database connectivity.', 3, 'elective', 'CSE'),
('CSE346', 'Advanced Database Systems', 'Query optimization, distributed databases, NoSQL, data warehousing, and transaction processing.', 2, 'elective', 'CSE'),
('CSE431', 'Mobile Programming', 'Mobile OS architectures, Android/iOS development, UI design, sensor integration, and mobile database access.', 3, 'core', 'CSE'),
('CSE432', 'Automata and Computability', 'Finite automata, regular expressions, context-free grammars, Turing machines, and decidability.', 3, 'core', 'CSE'),
('CSE433', 'Software Performance Evaluation', 'Software metrics, performance modeling, benchmarking, capacity planning, and scalability analysis.', 3, 'elective', 'CSE'),
('CSE439', 'Design of Compilers', 'Lexical analysis, parsing techniques, semantic analysis, code generation, and optimization.', 3, 'core', 'CSE'),
('CSE441', 'Software Project Management', 'Project planning, estimation, scheduling, risk management, and software process improvement.', 2, 'core', 'CSE');

-- 3. Computer Networks & Security
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('CSE351', 'Computer Networks', 'OSI/TCP-IP models, LAN technologies, IP addressing, routing protocols, transport layer, and application protocols.', 3, 'core', 'CSE'),
('CSE352', 'Parallel and Distributed Systems', 'Distributed architectures, MPI, synchronization, consistency, fault tolerance, and cloud computing models.', 3, 'core', 'CSE'),
('CSE353', 'Industrial Networks', 'Fieldbus systems, SCADA, CAN bus, industrial Ethernet, and real-time communication protocols.', 3, 'elective', 'CSE'),
('CSE354', 'Distributed Computing', 'Client-server model, RPC/RMI, P2P systems, distributed algorithms, and web services.', 3, 'elective', 'CSE'),
('CSE356', 'Internet of Things', 'IoT architecture, sensor networks, communication protocols (MQTT/CoAP), and cloud integration.', 2, 'elective', 'CSE'),
('CSE357', 'Network Operation and Management', 'SNMP protocol, network monitoring, fault management, performance analysis, and configuration management.', 2, 'elective', 'CSE'),
('CSE451', 'Computer and Network Security', 'Cryptography, authentication, firewalls, IDS, VPNs, web security, and malware analysis.', 3, 'core', 'CSE'),
('CSE452', 'Wireless Networks', 'Cellular networks, WiFi, Bluetooth, ad-hoc networks, mobile IP, and wireless security.', 2, 'elective', 'CSE'),
('CSE453', 'Digital Forensics', 'Computer crime investigation, evidence handling, file system analysis, and network forensics.', 2, 'elective', 'CSE'),
('CSE454', 'Quantum Communication and Security', 'Quantum key distribution, quantum cryptography, and quantum communication protocols.', 2, 'elective', 'CSE'),
('CSE455', 'High-Performance Computing', 'HPC architectures, parallel algorithms, CUDA programming, and performance optimization.', 2, 'core', 'CSE'),
('CSE456', 'Cloud Computing', 'Virtualization, IaaS/PaaS/SaaS models, cloud storage, and cloud security.', 3, 'elective', 'CSE'),
('CSE457', 'Mobile and Wireless Networks', 'Advanced mobile networks (4G/5G), mobility management, and QoS in wireless networks.', 3, 'elective', 'CSE'),
('CSE458', 'Computer and Network Forensics', 'Forensic tools, incident response, memory forensics, and legal aspects of cybercrime.', 3, 'elective', 'CSE');

-- 4. Systems and Artificial Intelligence
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('CSE271', 'System Dynamics and Control Components', 'Modeling of physical systems, transducers, actuators, signal conditioning, and PID control.', 4, 'core', 'CSE'),
('CSE371', 'Control Engineering', 'Feedback control, transfer functions, root locus, frequency response, and state-space analysis.', 3, 'core', 'CSE'),
('CSE372', 'Simulation of Engineering Systems', 'Discrete-event simulation, random number generation, input modeling, and output analysis.', 2, 'elective', 'CSE'),
('CSE373', 'Digital Control Systems', 'Z-transform, discrete-time systems, stability analysis, and digital controller design.', 2, 'elective', 'CSE'),
('CSE374', 'Digital Image Processing', 'Image enhancement, restoration, segmentation, compression, and morphological operations.', 2, 'elective', 'CSE'),
('CSE375', 'Machine Learning and Pattern Recognition', 'Supervised/unsupervised learning, bayesian classifiers, neural networks, and clustering.', 2, 'elective', 'CSE'),
('CSE376', 'Digital Signals Processing', 'Discrete Fourier Transform, FFT, digital filter design (FIR/IIR), and multirate processing.', 2, 'elective', 'CSE'),
('CSE378', 'Computer Graphics', '3D transformations, rendering pipeline, shading, ray tracing, and OpenGL programming.', 2, 'elective', 'CSE'),
('CSE379', 'Human Computer Interaction', 'Usability engineering, user-centered design, interaction styles, and UI prototyping.', 2, 'elective', 'CSE'),
('CSE381', 'Introduction to Machine Learning', 'Linear regression, logistic regression, SVM, decision trees, and ensemble methods.', 2, 'elective', 'CSE'),
('CSE382', 'Data Mining and Business Intelligence', 'Data preprocessing, association rules, classification, clustering, and data warehousing.', 2, 'elective', 'CSE'),
('CSE471', 'Robotic Systems', 'Kinematics, dynamics, trajectory planning, robot control, and robot programming.', 2, 'elective', 'CSE'),
('CSE472', 'Artificial Intelligence', 'Search algorithms, game playing, knowledge representation, expert systems, and planning.', 3, 'core', 'CSE'),
('CSE473', 'Computational Intelligence', 'Fuzzy logic, neural networks, genetic algorithms, and evolutionary computation.', 2, 'elective', 'CSE'),
('CSE474', 'Visualization', 'Information visualization techniques, visual encoding, interaction, and visualization tools.', 3, 'elective', 'CSE'),
('CSE476', 'Fundamentals of Big-Data Analytics', 'Hadoop ecosystem, MapReduce, Spark, and big data machine learning libraries.', 2, 'elective', 'CSE'),
('CSE477', 'Fundamentals of Deep Learning', 'Neural network architectures, CNNs, RNNs, training strategies, and deep learning frameworks.', 2, 'elective', 'CSE'),
('CSE479', 'Multimedia Engineering', 'Multimedia standards, audio/video compression, streaming, and multimedia retrieval.', 3, 'elective', 'CSE'),
('CSE481', 'Computer Animation', 'Keyframing, kinematics, physical modeling, and motion capture techniques.', 3, 'elective', 'CSE'),
('CSE483', 'Computer Vision', 'Feature extraction, object recognition, motion analysis, and 3D reconstruction.', 3, 'elective', 'CSE'),
('CSE484', 'Big-Data Analytics', 'Advanced big data technologies, stream processing, and graph analytics.', 3, 'elective', 'CSE'),
('CSE485', 'Deep Learning', 'Advanced deep learning models, generative models, and reinforcement learning.', 3, 'elective', 'CSE');



INSERT INTO Prerequisite (course_id, prereq_course_id)
SELECT c.course_id, p.course_id
FROM Course c, Course p
WHERE 
    -- CSE112 requires CSE111 and CSE131
    (c.course_code = 'CSE112' AND p.course_code IN ('CSE111', 'CSE131'))
    -- CSE211 requires CSE111 and CSE131
    OR (c.course_code = 'CSE211' AND p.course_code IN ('CSE111', 'CSE131'))
    -- CSE212 requires CSE111 and CSE131
    OR (c.course_code = 'CSE212' AND p.course_code IN ('CSE111', 'CSE131'))
    -- CSE231 requires CSE131
    OR (c.course_code = 'CSE231' AND p.course_code = 'CSE131')
    -- CSE232 requires CSE334 (Note: Check circular dependency in bylaw, usually depends on CSE231/131, bylaw says CSE334 for Advanced SE)
    OR (c.course_code = 'CSE232' AND p.course_code = 'CSE334') 
    -- CSE311 requires CSE212
    OR (c.course_code = 'CSE311' AND p.course_code = 'CSE212')
    -- CSE331 requires CSE231
    OR (c.course_code = 'CSE331' AND p.course_code = 'CSE231')
    -- CSE332 requires CSE331
    OR (c.course_code = 'CSE332' AND p.course_code = 'CSE331')
    -- CSE333 requires CSE331
    OR (c.course_code = 'CSE333' AND p.course_code = 'CSE331')
    -- CSE334 requires CSE131
    OR (c.course_code = 'CSE334' AND p.course_code = 'CSE131')
    -- CSE335 requires CSE112 or CSE212
    OR (c.course_code = 'CSE335' AND p.course_code IN ('CSE112', 'CSE212'))
    -- CSE351 (No Prereq listed in some tables, but relies on CSE211/Communication basics)
    -- CSE352 requires CSE351
    OR (c.course_code = 'CSE352' AND p.course_code = 'CSE351')
    -- CSE371 requires ECE251 and ECE253 (from ECE dept)
    OR (c.course_code = 'CSE371' AND p.course_code IN ('ECE251', 'ECE253'))
    -- CSE411 requires CSE211
    OR (c.course_code = 'CSE411' AND p.course_code = 'CSE211')
    -- CSE451 requires CSE351
    OR (c.course_code = 'CSE451' AND p.course_code = 'CSE351')
    -- CSE472 requires PHM111 and CSE131
    OR (c.course_code = 'CSE472' AND p.course_code IN ('PHM111', 'CSE131'))
    -- CSE439 requires CSE131
    OR (c.course_code = 'CSE439' AND p.course_code = 'CSE131');


    -- 1. Computing in Engineering (CSE031)
-- Faculty Requirement: Taken by almost all departments (EPM, ECE, MCT, PHM, etc.)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 300, 'Faculty Requirement'
FROM Department d, Course c
WHERE c.course_code = 'CSE031'
AND d.department_code IN ('EPM', 'ECE', 'MCT', 'PHM', 'ARC');

-- 2. Computer Programming (CSE131)
-- Taken by: Electrical Power (EPM), Electronics (ECE), Mechatronics (MCT)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 200, 'Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'CSE131'
AND d.department_code IN ('EPM', 'ECE', 'MCT');

-- 3. Logic Design (CSE111)
-- Taken by: Electrical Power (EPM), Electronics (ECE), Mechatronics (MCT)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 200, 'Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'CSE111'
AND d.department_code IN ('EPM', 'ECE', 'MCT');

-- 4. Introduction to Embedded Systems (CSE211)
-- Taken by: Electronics (ECE) as elective, Mechatronics (MCT) as core
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 150, 'Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'CSE211'
AND d.department_code = 'MCT';

INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'elective', 100, 'Concentration Requirement'
FROM Department d, Course c
WHERE c.course_code = 'CSE211'
AND d.department_code = 'ECE';

-- 5. Computer Organization (CSE212)
-- Taken by: Electronics (ECE)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 100, 'Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'CSE212'
AND d.department_code = 'ECE';

-- 6. Control Engineering (CSE371)
-- Taken by: Electronics (ECE), Electrical Power (EPM)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 150, 'Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'CSE371'
AND d.department_code IN ('ECE', 'EPM');

-- 7. System Dynamics and Control Components (CSE271)
-- Taken by: Electrical Power (EPM)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 100, 'Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'CSE271'
AND d.department_code = 'EPM';

-- 8. Advanced Courses for Mechatronics (MCT)
-- MCT takes: Computer Vision (CSE483), Computational Intelligence (CSE473), Real-Time Systems (CSE411)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 50, 'Mechatronics Requirement'
FROM Department d, Course c
WHERE c.course_code IN ('CSE483', 'CSE473', 'CSE411')
AND d.department_code = 'MCT';



-- 1. General Electrical Engineering
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('EPM111', 'Electrical Circuits (1)', 'Circuit elements, Kirchhoffs laws, Mesh/Nodal analysis, Thevenin/Norton theorems, and sinusoidal steady state analysis.', 4, 'core', 'EPM'),
('EPM112', 'Electromagnetic Fields', 'Coulombs law, Gauss law, electric potential, magnetic fields, Amperes law, and Maxwells equations.', 3, 'core', 'EPM'),
('EPM113', 'Electrical Measurements', 'Measurement errors, moving coil/iron instruments, power/energy measurement, bridges, and transducers.', 3, 'core', 'EPM'),
('EPM114', 'Fundamentals of Electrical Circuits', 'Circuit analysis for non-majors, network theorems, AC power, resonance, and three-phase circuits.', 3, 'core', 'EPM'),
('EPM115', 'Fundamentals of Electromagnetic Fields', 'Vector analysis, electric/magnetic fields, inductance, and Maxwells equations for energy programs.', 3, 'core', 'EPM'),
('EPM116', 'Electrical Circuits and Machines', 'DC/AC circuits, magnetic circuits, transformers, and introduction to DC/AC machines for mechanical engineering.', 3, 'core', 'EPM'),
('EPM117', 'Energy Resources and Renewable Energy', 'Thermal, nuclear, and renewable energy resources (solar, wind, biomass) and energy conversion.', 3, 'core', 'EPM'),
('EPM118', 'Electrical and Electronic Circuits', 'Circuit theorems, AC analysis, diodes, op-amps, and basic electronic applications for computer engineering.', 3, 'core', 'EPM'),
('EPM211', 'Properties of Electrical Materials', 'Conducting materials, insulating ceramics/polymers, magnetic materials, and semiconductor materials.', 2, 'core', 'EPM'),
('EPM212', 'Electrical Circuits (2)', 'Poly-phase circuits, magnetically coupled circuits, resonance, two-port networks, and harmonics.', 3, 'core', 'EPM'),
('EPM213', 'Energy and Renewable Energy', 'Conventional electromechanical conversion, generators, motors, and renewable resources (solar, wind, hydro).', 3, 'core', 'EPM'),
('EPM214', 'Electrical Systems Simulation', 'Numerical methods for circuit analysis, simulation of renewable energy systems and industrial electrical systems.', 3, 'core', 'EPM'),
('EPM311', 'Fundamentals of Photovoltaic', 'Solar cell operation, characteristics, crystalline silicon/thin film technologies, and PV system design.', 3, 'elective', 'EPM'),
('EPM411', 'Project Management for Electrical Engineering', 'Project life cycle, WBS, scheduling, cost estimation, quality management, and contracts.', 2, 'elective', 'EPM'),
('EPM412', 'Microprocessor-Based Automated Systems', 'Microcontroller programming, digital I/O, interrupts, timers, and interfacing with sensors/actuators.', 3, 'elective', 'EPM'),
('EPM413', 'Energy Management Essentials', 'Energy audits, efficiency standards, power factor correction, lighting/motor savings, and building management.', 3, 'elective', 'EPM');

-- 2. Electrical Machines
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('EPM221', 'Electrical Machines (1)', 'Electromechanical energy conversion, DC machines (generators/motors), and transformer construction/testing.', 3, 'core', 'EPM'),
('EPM222', 'Electrical Machines (2)', 'Synchronous machines (generators/motors), induction machines (construction, operation, speed control).', 3, 'core', 'EPM'),
('EPM321', 'Transformer and DC Machines', 'DC machine construction, armature reaction, load characteristics, and transformer efficiency/testing.', 3, 'core', 'EPM'),
('EPM322', 'Alternating Current Machines', 'Rotating magnetic fields, synchronous machines performance, and three-phase induction motors.', 3, 'core', 'EPM'),
('EPM421', 'Special Machines', 'Stepper motors, switched reluctance motors, linear induction motors, and brushless DC motors.', 2, 'elective', 'EPM'),
('EPM422', 'Industrial Automation Systems', 'PLC programming, SCADA systems, distributed control systems (DCS), and industrial applications.', 3, 'elective', 'EPM'),
('EPM423', 'Generating Power Stations', 'Steam/Gas/Hydro power plants, combined cycles, nuclear power, and CHP schemes.', 2, 'elective', 'EPM');

-- 3. Electrical Power Systems
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('EPM231', 'Electrical Power Engineering', 'Power system structure, transmission lines, distribution, cables, high voltage generation, and earthing.', 3, 'core', 'EPM'),
('EPM232', 'Automatic Control Systems', 'Control system modeling, block diagrams, PID tuning, stability analysis, and root locus.', 3, 'core', 'EPM'),
('EPM331', 'Electrical Transmission Systems', 'Transmission line modeling, performance, surge impedance, and mechanical design of lines.', 3, 'core', 'EPM'),
('EPM332', 'Power System Analysis (1)', 'Per unit system, symmetrical components, fault analysis (symmetrical/unsymmetrical), and load flow.', 3, 'core', 'EPM'),
('EPM333', 'Electrical Distribution Systems', 'Load characteristics, distribution system design, voltage drop, power factor correction, and earthing.', 3, 'core', 'EPM'),
('EPM334', 'Economics of Generation, Transmission & Operation', 'Load curves, power plant economics, tariff structures, and economic dispatch.', 3, 'core', 'EPM'),
('EPM335', 'Fundamentals of Power System Analysis', 'Symmetrical components, fault analysis, network matrices, and load flow methods (Gauss-Seidal/Newton-Raphson).', 3, 'core', 'EPM'),
('EPM336', 'Electrical Distribution Systems Installations', 'Codes/standards, wiring, illumination, switchgear selection, and protection of distribution systems.', 3, 'core', 'EPM'),
('EPM431', 'Operation and Control of Power Systems', 'Economic dispatch, unit commitment, load frequency control, and automatic voltage regulation.', 3, 'core', 'EPM'),
('EPM432', 'Electrical Installations and Energy Utilization', 'Installation design, illumination, industrial heating, and earthing systems.', 3, 'core', 'EPM'),
('EPM433', 'Power Systems Stability', 'Swing equation, transient stability, equal area criterion, and voltage stability.', 2, 'elective', 'EPM'),
('EPM434', 'Planning of Electrical Networks', 'Load forecasting, generation/transmission planning, reliability evaluation, and renewable integration.', 3, 'elective', 'EPM'),
('EPM435', 'Advanced Control on Power Systems', 'Frequency control, voltage control, power system stabilizers, and multi-area systems.', 3, 'elective', 'EPM'),
('EPM436', 'Computer Application in Electrical Power Systems', 'Computer modeling of power systems, large system simulation, and optimal power flow.', 3, 'elective', 'EPM');

-- 4. High Voltage Engineering
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('EPM341', 'High Voltage Engineering', 'Generation/measurement of HV, breakdown in gases/liquids/solids, insulators, and corona.', 3, 'core', 'EPM'),
('EPM342', 'Switchgear Engineering and Substations', 'Circuit breakers (Air/Oil/SF6/Vacuum), arc interruption, substation layout, and busbar schemes.', 3, 'core', 'EPM');

-- 5. Power Electronics
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('EPM151', 'Industrial Electronics', 'Power diodes, transistors, thyristors, op-amps, sensors, and data converters.', 3, 'core', 'EPM'),
('EPM251', 'Power Electronics for Energy Applications (1)', 'Rectifiers, static switches, and AC voltage controllers.', 3, 'core', 'EPM'),
('EPM351', 'Power Electronics (1)', 'Power semiconductor devices, single/three-phase rectifiers, and triggering circuits.', 3, 'core', 'EPM'),
('EPM352', 'Power Electronics (2)', 'DC-DC converters (Buck/Boost), inverters (VSI/CSI), PWM techniques, and UPS applications.', 3, 'core', 'EPM'),
('EPM353', 'Power Electronics and Motor Drives', 'Rectifiers, inverters, DC motor drives, and AC motor drives (V/f control).', 3, 'core', 'EPM'),
('EPM354', 'Power Electronics for Energy Applications (2)', 'DC choppers, inverters, cyclo-converters, and matrix converters.', 3, 'core', 'EPM'),
('EPM451', 'Electrical Drives Systems', 'Dynamics of electric drives, DC drives, induction motor drives, and synchronous motor drives.', 3, 'core', 'EPM'),
('EPM452', 'Advanced Applications in Power Electronics', 'Switched mode power supplies, HVDC transmission, FACTS, and resonant converters.', 2, 'elective', 'EPM'),
('EPM453', 'Power Quality', 'Harmonics, voltage sags/swells, active/passive filters, and power quality monitoring.', 2, 'elective', 'EPM'),
('EPM454', 'Renewable Energy Resources Interfacing', 'Grid interconnection of wind/PV, energy storage technologies, and interface topologies.', 3, 'core', 'EPM'),
('EPM455', 'Electric Drives', 'Selection of drives, regenerative braking, slip power recovery, and special motor drives.', 3, 'core', 'EPM'),
('EPM456', 'Power Quality for Energy Applications', 'Analysis of power quality events, standards, and compensation techniques.', 3, 'elective', 'EPM');

-- 6. Protection Engineering
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('EPM461', 'Protection Engineering', 'Protective relays (Overcurrent/Distance/Differential), transformer/generator/busbar protection.', 3, 'core', 'EPM'),
('EPM462', 'Advanced Protection in Power Systems', 'Digital protection, numerical relays, and wide area measurement systems (WAMS).', 2, 'elective', 'EPM'),
('EPM463', 'Power System Protection', 'Protection philosophy, transmission line protection, and rotating machinery protection.', 4, 'core', 'EPM');

-- 9. Graduation Projects
INSERT INTO Course (course_code, title, description, credits, course_type, department_code) VALUES 
('EPM491', 'Electrical Power & Machines Graduation Project (1)', 'Problem definition, data collection, and preliminary design of an electrical engineering project.', 3, 'core', 'EPM'),
('EPM492', 'Electrical Power & Machines Graduation Project (2)', 'Detailed analysis, simulation, prototyping, and testing of the graduation project.', 3, 'core', 'EPM'),
('EPM493', 'Energy Graduation Project (1)', 'Analysis and design of an energy system using fundamental principles.', 3, 'core', 'EPM'),
('EPM494', 'Energy Graduation Project (2)', 'Implementation and testing of the energy system designed in Project 1.', 3, 'core', 'EPM');


INSERT INTO Prerequisite (course_id, prereq_course_id)
SELECT c.course_id, p.course_id
FROM Course c, Course p
WHERE 
    -- EPM111 requires PHM022
    (c.course_code = 'EPM111' AND p.course_code = 'PHM022')
    -- EPM112 requires PHM013 and PHM022
    OR (c.course_code = 'EPM112' AND p.course_code IN ('PHM013', 'PHM022'))
    -- EPM113 requires EPM111
    OR (c.course_code = 'EPM113' AND p.course_code = 'EPM111')
    -- EPM114 requires PHM022
    OR (c.course_code = 'EPM114' AND p.course_code = 'PHM022')
    -- EPM115 requires PHM013 and PHM022
    OR (c.course_code = 'EPM115' AND p.course_code IN ('PHM013', 'PHM022'))
    -- EPM116 requires PHM022
    OR (c.course_code = 'EPM116' AND p.course_code = 'PHM022')
    -- EPM118 requires PHM022
    OR (c.course_code = 'EPM118' AND p.course_code = 'PHM022')
    -- EPM211 requires EPM112
    OR (c.course_code = 'EPM211' AND p.course_code = 'EPM112')
    -- EPM212 requires EPM111
    OR (c.course_code = 'EPM212' AND p.course_code = 'EPM111')
    -- EPM213 requires EPM112
    OR (c.course_code = 'EPM213' AND p.course_code = 'EPM112')
    -- EPM214 requires EPM212
    OR (c.course_code = 'EPM214' AND p.course_code = 'EPM212')
    -- EPM311 requires EPM151
    OR (c.course_code = 'EPM311' AND p.course_code = 'EPM151')
    -- EPM412 requires EPM114 and EPM354
    OR (c.course_code = 'EPM412' AND p.course_code IN ('EPM114', 'EPM354'))
    -- EPM413 requires EPM113
    OR (c.course_code = 'EPM413' AND p.course_code = 'EPM113')
    -- EPM221 requires EPM114 and EPM115
    OR (c.course_code = 'EPM221' AND p.course_code IN ('EPM114', 'EPM115'))
    -- EPM222 requires EPM221
    OR (c.course_code = 'EPM222' AND p.course_code = 'EPM221')
    -- EPM321 requires EPM112 and EPM212
    OR (c.course_code = 'EPM321' AND p.course_code IN ('EPM112', 'EPM212'))
    -- EPM322 requires EPM321
    OR (c.course_code = 'EPM322' AND p.course_code = 'EPM321')
    -- EPM421 requires EPM322
    OR (c.course_code = 'EPM421' AND p.course_code = 'EPM322')
    -- EPM422 requires EPM322 and CSE371 (Control)
    OR (c.course_code = 'EPM422' AND p.course_code IN ('EPM322', 'CSE371'))
    -- EPM423 requires EPM322 and MEP214
    OR (c.course_code = 'EPM423' AND p.course_code IN ('EPM322', 'MEP214'))
    -- EPM231 requires EPM115
    OR (c.course_code = 'EPM231' AND p.course_code = 'EPM115')
    -- EPM232 requires PHM113
    OR (c.course_code = 'EPM232' AND p.course_code = 'PHM113')
    -- EPM331 requires EPM212
    OR (c.course_code = 'EPM331' AND p.course_code = 'EPM212')
    -- EPM332 requires EPM331
    OR (c.course_code = 'EPM332' AND p.course_code = 'EPM331')
    -- EPM333 requires EPM111
    OR (c.course_code = 'EPM333' AND p.course_code = 'EPM111')
    -- EPM334 requires EPM117 and EPM231
    OR (c.course_code = 'EPM334' AND p.course_code IN ('EPM117', 'EPM231'))
    -- EPM335 requires EPM222 and EPM231
    OR (c.course_code = 'EPM335' AND p.course_code IN ('EPM222', 'EPM231'))
    -- EPM336 requires EPM114
    OR (c.course_code = 'EPM336' AND p.course_code = 'EPM114')
    -- EPM431 requires EPM213 and EPM332
    OR (c.course_code = 'EPM431' AND p.course_code IN ('EPM213', 'EPM332'))
    -- EPM432 requires EPM333
    OR (c.course_code = 'EPM432' AND p.course_code = 'EPM333')
    -- EPM433 requires EPM332
    OR (c.course_code = 'EPM433' AND p.course_code = 'EPM332')
    -- EPM434 requires EPM332
    OR (c.course_code = 'EPM434' AND p.course_code = 'EPM332')
    -- EPM435 requires EPM231 and EPM232
    OR (c.course_code = 'EPM435' AND p.course_code IN ('EPM231', 'EPM232'))
    -- EPM436 requires EPM231
    OR (c.course_code = 'EPM436' AND p.course_code = 'EPM231')
    -- EPM341 requires EPM112
    OR (c.course_code = 'EPM341' AND p.course_code = 'EPM112')
    -- EPM342 requires EPM341
    OR (c.course_code = 'EPM342' AND p.course_code = 'EPM341')
    -- EPM251 requires EPM151
    OR (c.course_code = 'EPM251' AND p.course_code = 'EPM151')
    -- EPM351 requires PHM122 and ECE211
    OR (c.course_code = 'EPM351' AND p.course_code IN ('PHM122', 'ECE211'))
    -- EPM352 requires EPM351
    OR (c.course_code = 'EPM352' AND p.course_code = 'EPM351')
    -- EPM353 requires EPM222 (Assuming EPM222 for AC Machines basis)
    OR (c.course_code = 'EPM353' AND p.course_code = 'EPM222')
    -- EPM354 requires EPM251
    OR (c.course_code = 'EPM354' AND p.course_code = 'EPM251')
    -- EPM451 requires EPM322 and EPM352
    OR (c.course_code = 'EPM451' AND p.course_code IN ('EPM322', 'EPM352'))
    -- EPM452 requires EPM352
    OR (c.course_code = 'EPM452' AND p.course_code = 'EPM352')
    -- EPM453 requires EPM352
    OR (c.course_code = 'EPM453' AND p.course_code = 'EPM352')
    -- EPM454 requires EPM232 and EPM354
    OR (c.course_code = 'EPM454' AND p.course_code IN ('EPM232', 'EPM354'))
    -- EPM455 requires EPM222 and EPM354
    OR (c.course_code = 'EPM455' AND p.course_code IN ('EPM222', 'EPM354'))
    -- EPM456 requires EPM231 and EPM354
    OR (c.course_code = 'EPM456' AND p.course_code IN ('EPM231', 'EPM354'))
    -- EPM461 requires EPM332 and EPM342
    OR (c.course_code = 'EPM461' AND p.course_code IN ('EPM332', 'EPM342'))
    -- EPM462 requires EPM461
    OR (c.course_code = 'EPM462' AND p.course_code = 'EPM461')
    -- EPM463 requires EPM231
    OR (c.course_code = 'EPM463' AND p.course_code = 'EPM231')
    -- EPM492 requires EPM491
    OR (c.course_code = 'EPM492' AND p.course_code = 'EPM491')
    -- EPM494 requires EPM493
    OR (c.course_code = 'EPM494' AND p.course_code = 'EPM493');


    -- 1. Electrical Circuits (1) (EPM111)
-- Taken by: ECE, CSE
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 200, 'Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'EPM111' AND d.department_code IN ('ECE', 'CSE');

-- 2. Electromagnetic Fields (EPM112)
-- Taken by: ECE
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 150, 'Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'EPM112' AND d.department_code = 'ECE';

-- 3. Fundamentals of Electrical Circuits (EPM114)
-- Taken by: CSE (Communications Systems Program 18) and Energy
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 100, 'Program Requirement'
FROM Department d, Course c
WHERE c.course_code = 'EPM114' AND d.department_code = 'ECE';

-- 4. Electrical and Electronic Circuits (EPM118)
-- Taken by: CSE (Computer Engineering & Software Systems)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 100, 'Program Requirement'
FROM Department d, Course c
WHERE c.course_code = 'EPM118' AND d.department_code = 'CSE';

-- 5. Power Electronics and Motor Drives (EPM353)
-- Taken by: MCT
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 100, 'Mechatronics Requirement'
FROM Department d, Course c
WHERE c.course_code = 'EPM353' AND d.department_code = 'MCT';

-- 6. Electrical Circuits and Machines (EPM116)
-- Taken by: MCT (and other mechanical departments)
INSERT INTO DepartmentCourse (department_id, course_id, course_type, capacity, eligibility_requirements)
SELECT d.department_id, c.course_id, 'core', 150, 'Mechanical Discipline Requirement'
FROM Department d, Course c
WHERE c.course_code = 'EPM116' AND d.department_code = 'MCT';



