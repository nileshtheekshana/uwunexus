-- ============================================================
-- UWU-NEXUS SMART GPA CALCULATOR - COMPLETE DATABASE SCHEMA
-- Faculty of Applied Sciences, Uva Wellassa University
-- Generated from Student Handbook (2025)
-- Target: MySQL 8.0+
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'STRICT_TRANS_TABLES';

-- ============================================================
-- TABLE 1: degrees
-- Stores the 4 degree programs offered by the faculty.
-- SCT has 3 specializations from Level 300; MRT has 2.
-- Each specialization is treated as its own degree pathway.
-- ============================================================
CREATE TABLE IF NOT EXISTS degrees (
    id          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    degree_code VARCHAR(10)     NOT NULL,
    degree_name VARCHAR(200)    NOT NULL,
    total_credits_required DECIMAL(6,2) NOT NULL DEFAULT 120.00,
    duration_years INT          NOT NULL DEFAULT 4,
    PRIMARY KEY (id),
    UNIQUE KEY uq_degree_code (degree_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLE 2: modules
-- Master list of every course unit mentioned in the handbook.
-- Module codes are unique system-wide.
-- is_gpa = 0 for Non-GPA courses (Sinhala/Tamil Language, Industrial Training, Essential Mathematics)
-- ============================================================
CREATE TABLE IF NOT EXISTS modules (
    id          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    module_code VARCHAR(20)     NOT NULL,
    module_name VARCHAR(255)    NOT NULL,
    credits     DECIMAL(4,1)   NOT NULL,
    is_gpa      TINYINT(1)     NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uq_module_code (module_code),
    KEY idx_modules_is_gpa (is_gpa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLE 3: curriculum_groups
-- Each row represents a "slot" in the curriculum for a
-- specific degree, year, and semester.
-- group_type:
--   CORE     = compulsory course units (all must be taken)
--   ESD      = Essential Skills Development (compulsory)
--   BGE      = Broad General Education (compulsory)
--   ELECTIVE = select from this pool to satisfy min_credits
--   OPTIONAL = select from this pool to satisfy min_credits
--   BASKET   = must pick exactly min_credits worth (e.g., IIT L400 Basket-1)
-- min_credits_required = minimum credits student must earn from this group
-- ============================================================
CREATE TABLE IF NOT EXISTS curriculum_groups (
    id                   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    degree_id            INT UNSIGNED NOT NULL,
    academic_year        TINYINT      NOT NULL COMMENT '1=Level100, 2=Level200, 3=Level300, 4=Level400',
    semester             TINYINT      NOT NULL COMMENT '1=First Semester, 2=Second Semester',
    group_type           ENUM('CORE','ESD','BGE','ELECTIVE','OPTIONAL','BASKET') NOT NULL,
    group_name           VARCHAR(100) NOT NULL COMMENT 'e.g. Core Course Units, Basket-1, Elective Pool',
    min_credits_required DECIMAL(4,1) NOT NULL DEFAULT 0.0 COMMENT 'Minimum credits student must complete from this group',
    PRIMARY KEY (id),
    KEY idx_cg_degree (degree_id),
    KEY idx_cg_year_sem (academic_year, semester),
    CONSTRAINT fk_cg_degree FOREIGN KEY (degree_id)
        REFERENCES degrees(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLE 4: curriculum_modules
-- Maps a module to a specific curriculum group.
-- is_mandatory: for CORE/ESD/BGE groups this is always 1.
--               for ELECTIVE/OPTIONAL/BASKET groups this is 0.
-- ============================================================
CREATE TABLE IF NOT EXISTS curriculum_modules (
    id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    group_id     INT UNSIGNED NOT NULL,
    module_id    INT UNSIGNED NOT NULL,
    is_mandatory TINYINT(1)  NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uq_cm_group_module (group_id, module_id),
    KEY idx_cm_module (module_id),
    CONSTRAINT fk_cm_group FOREIGN KEY (group_id)
        REFERENCES curriculum_groups(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cm_module FOREIGN KEY (module_id)
        REFERENCES modules(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLE 5: user_grades
-- Stores the grade a student received for a module attempt.
-- attempt_number allows tracking of repeat examinations.
-- is_best_grade = 1 flags the best attempt used for GPA calc.
-- ============================================================
CREATE TABLE IF NOT EXISTS user_grades (
    id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id        INT          NOT NULL COMMENT 'FK to existing users.id',
    module_id      INT UNSIGNED NOT NULL,
    academic_year  TINYINT      NOT NULL COMMENT '1-4 corresponding to Level 100-400',
    semester       TINYINT      NOT NULL,
    grade          VARCHAR(3)   NOT NULL COMMENT 'A+, A, A-, B+, B, B-, C+, C, C-, D+, D, E',
    gpv            DECIMAL(4,2) NOT NULL COMMENT 'Grade Point Value e.g. 4.00, 3.70, 3.30...',
    attempt_number TINYINT      NOT NULL DEFAULT 1,
    is_best_grade  TINYINT(1)  NOT NULL DEFAULT 1,
    created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_ug_user_module_attempt (user_id, module_id, attempt_number),
    KEY idx_ug_user (user_id),
    KEY idx_ug_module (module_id),
    KEY idx_ug_best_grade (is_best_grade),
    CONSTRAINT fk_ug_module FOREIGN KEY (module_id)
        REFERENCES modules(id) ON DELETE RESTRICT ON UPDATE CASCADE
    -- NOTE: FK to users.id is intentionally omitted here as the users table
    -- is managed externally. Add: CONSTRAINT fk_ug_user FOREIGN KEY (user_id)
    --   REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
    -- if this schema is run in the same DB as the users table.
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================
-- SEED DATA
-- ============================================================

-- ============================================================
-- DEGREES
-- Only 4 degree programmes exist in the Faculty of Applied Sciences.
-- SCT has 3 specializations; MRT has 2. Each is a separate
-- curriculum pathway stored as a distinct degree record.
-- ============================================================
INSERT INTO degrees (degree_code, degree_name, total_credits_required) VALUES
('IIT',     'Bachelor of Science Honours in Industrial Information Technology', 124.00),
('CST',     'Bachelor of Science Honours in Computer Science and Technology',   125.00),
('MRT-MPT', 'Bachelor of Science Honours in Mineral Resources and Technology (Mineral Processing Technology)', 123.00),
('MRT-WST', 'Bachelor of Science Honours in Mineral Resources and Technology (Water Science and Technology)',  123.00),
('SCT-FEB', 'Bachelor of Science Honours in Science and Technology (Food Engineering and Bioprocess Technology)', 120.00),
('SCT-MST', 'Bachelor of Science Honours in Science and Technology (Material Science and Technology)', 120.00),
('SCT-MEC', 'Bachelor of Science Honours in Science and Technology (Mechatronics)', 120.00);


-- ============================================================
-- MODULES (Master List - All unique course units from handbook)
-- ============================================================

-- --- ESD & BGE Common Modules ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('ESD 121-2',   'English Language Level- I',                        2.0,  1),
('ESD 122-2',   'English Language Level - II',                      2.0,  1),
('ESD 221-2',   'English Language Level- III',                      2.0,  1),
('ESD 311-1',   'Communication Skills - II',                        1.0,  1),
('ESD 111-1',   'Communication Skills - I',                         1.0,  1),
('ESD 141-2',   'Quantitative Reasoning',                           2.0,  1),
('ESD 103-2',   'Information Technology',                           2.0,  1),
('ESD 151-1',   'Sinhala Language - I (non-GPA)',                   1.0,  0),
('ESD 161-1',   'Tamil Language - I (non-GPA)',                     1.0,  0),
('ESD 152-1',   'Sinhala Language - II (non-GPA)',                  1.0,  0),
('ESD 162-1',   'Tamil Language - II (non-GPA)',                    1.0,  0),
('BGE 121-2',   'Ethics and Law Basics',                            2.0,  1),
('BGE 211-2',   'Aesthetic Studies',                                2.0,  1),
('BGE 214-1',   'Geography',                                        1.0,  1),
('BGE 215-1',   'History for Science',                              1.0,  1);

-- --- Common Science/Technology Foundation Modules (SCT-coded, used across degrees) ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('SCT 101-1',   'Essential Mathematics (non-GPA)',                  1.0,  0),
('SCT 121-1',   'Introductory Biology (non-GPA)',                   1.0,  0),
('SCT 131-2',   'General Chemistry',                                2.0,  1),
('SCT 141-1',   'Engineering Drawings',                             1.0,  1),
('SCT 142-2',   'Engineering Workshop',                             2.0,  1),
('SCT 151-2',   'Mechanics, Waves, and Vibrations',                 2.0,  1),
('SCT 102-2',   'Calculus',                                         2.0,  1),
('SCT 132-2',   'Inorganic Chemistry',                              2.0,  1),
('SCT 152-2',   'Properties of Matter',                             2.0,  1),
('SCT 161-1',   'Computer Programming',                             1.0,  1),
('SCT 201-1',   'Abstract Algebra',                                 1.0,  1),
('SCT 211-2',   'Statistical Methods',                              2.0,  1),
('SCT 231-2',   'Physical Chemistry',                               2.0,  1),
('SCT 251-2',   'Electricity and Magnetism',                        2.0,  1),
('SCT 252-1',   'Optics',                                           1.0,  1),
('SCT 221-1',   'Microbiology',                                     1.0,  1),
('SCT 222-2',   'Biochemistry',                                     2.0,  1),
('SCT 261-1',   'Database Management Systems',                      1.0,  1),
('SCT 202-3',   'Differential Equations and Applications',          3.0,  1),
('SCT 232-2',   'Organic Chemistry',                                2.0,  1),
('SCT 242-2',   'Engineering Thermodynamics',                       2.0,  1),
('SCT 253-1',   'Basic Electronics',                                1.0,  1),
('SCT 212-1',   'Operational Research',                             1.0,  1),
('SCT 223-3',   'Diversity of Life',                                3.0,  1),
('SCT 241-2',   'Mechanics of Materials',                           2.0,  1),
('SCT 302-2',   'Applied Economics and Financial Accounting',       2.0,  1),
('SCT 303-2',   'Research Methodology and Scientific Writing',      2.0,  1),
('SCT 384-2',   'Embedded Systems',                                 2.0,  1),
('SCT 401-2',   'Business Management and Entrepreneurship',         2.0,  1),
('SCT 402-2',   'Quality Assurance and Control',                    2.0,  1),
('SCT 403-6',   'Industrial Training (Non-GPA)',                    6.0,  0),
('SCT 404-6',   'Research Project',                                 6.0,  1);

-- --- MRT (Mineral Resources & Technology) - Common L100 & L200 Modules ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('MRT 151-3',   'Earth Materials and Processes',                    3.0,  1),
('MRT 152-1',   'Water Resources - I',                              1.0,  1),
('MRT 161-3',   'Mineralogy and Petrology - I',                     3.0,  1),
('MRT 162-1',   'Water Resources - II',                             1.0,  1),
('MRT 251-3',   'Mineralogy and Petrology - II',                    3.0,  1),
('MRT 253-2',   'Principles of Hydrogeology',                       2.0,  1),
('MRT 252-2',   'Structural Geology',                               2.0,  1),
('MRT 254-2',   'Applied Geochemistry',                             2.0,  1);

-- --- MRT Level 300 - Mineral Processing Technology (MPT) Specialization ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('MRT 311-2',   'Physics and Chemistry of Minerals',                2.0,  1),
('MRT 312-2',   'Genesis of Mineral Deposits',                      2.0,  1),
('MRT 362-2',   'Analytical Techniques and Instrumentation - I',    2.0,  1),
('MRT 313-2',   'Gemmology',                                        2.0,  1),
('MRT 314-1',   'Gemmology Laboratory',                             1.0,  1),
('MRT 315-3',   'Technical Mineralogy - I',                         3.0,  1),
('MRT 316-3',   'Engineering Geology',                              3.0,  1),
('MRT 317-2',   'Industrial Mineral Processing Technology',         2.0,  1),
('MRT 318-1',   'Industrial Mineral Processing Laboratory',         1.0,  1),
('MRT 352-2',   'Surveying and Levelling',                          2.0,  1),
('AQT 321-3',   'Oceanography',                                     3.0,  1),
('MRT 353-1',   'Engineering Workshop Technology',                  1.0,  1),
('MRT 355-2',   'Soil Physics',                                     2.0,  1),
('MRT 366-1',   'Computer Programming',                             1.0,  1),
('MRT 374-3',   'Fluid Mechanics and Hydraulics',                   3.0,  1),
('MRT 321-2',   'Mineral Exploration Methods',                      2.0,  1),
('MRT 365-3',   'Remote Sensing and Geospatial Technology',         3.0,  1),
('MRT 361-2',   'Research Methodology and Scientific Writing',      2.0,  1),
('MRT 322-2',   'Gemstone Fashioning',                              2.0,  1),
('MRT 324-3',   'Technical Mineralogy - II',                        3.0,  1),
('MRT 325-2',   'Mine Planning Strategies',                         2.0,  1),
('MRT 327-2',   'Petroleum Exploration and Extraction',             2.0,  1),
('MRT 351-3',   'Applied Geophysics',                               3.0,  1),
('MRT 364-1',   'Computer Aided Drawing and Designing',             1.0,  1),
('MRT 381-2',   'Water Safety Plan',                                2.0,  1),
('MRT 392-2',   'Project Management',                               2.0,  1),
('IIT 323-2',   'Human Resource Management',                        2.0,  1);

-- --- MRT Level 300 - Water Science and Technology (WST) Specialization ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('MRT 371-3',   'Water Chemistry',                                  3.0,  1),
('MRT 372-1',   'Water Chemistry Laboratory - I',                   1.0,  1),
('MRT 373-2',   'Hydrology',                                        2.0,  1),
('MRT 376-2',   'Aquatic Microbiology',                             2.0,  1),
('MRT 378-2',   'Advanced Hydrogeology',                            2.0,  1),
('MRT 382-3',   'Water Treatment Methods',                          3.0,  1),
('MRT 383-1',   'Water Treatment Laboratory',                       1.0,  1),
('MRT 384-2',   'Water Supply Engineering',                         2.0,  1),
('MRT 385-2',   'Wastewater Treatment and Reuse - I',               2.0,  1),
('MRT 386-3',   'Groundwater Flow Modelling',                       3.0,  1),
('MRT 388-2',   'Water Wells and Pumps',                            2.0,  1);

-- --- MRT Level 400 - MPT Specialization ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('MRT 411-2',   'Mineral Economics',                                2.0,  1),
('MRT 412-2',   'Mineral Nanoscience and Technology',               2.0,  1),
('MRT 451-2',   'Environment and Industry Regulations',             2.0,  1),
('MRT 463-2',   'Analytical Techniques and Instrumentation - II',   2.0,  1),
('MRT 413-2',   'Gem Enhancement Techniques',                       2.0,  1),
('MRT 414-2',   'Jewellery Designing',                              2.0,  1),
('MRT 415-3',   'Ceramic and Glass Technology',                     3.0,  1),
('MRT 416-2',   'Mining Methods',                                   2.0,  1),
('MRT 417-2',   'Extractive Metallurgy',                            2.0,  1),
('MRT 418-2',   'Simulation of Mineral Processing Systems',         2.0,  1),
('MRT 453-2',   'Pollution Control and Remediation',                2.0,  1),
('MRT 454-2',   'Quantity Surveying',                               2.0,  1),
('IIT 446-2',   'Intellectual Property Rights, Legislations and Commercialization', 2.0, 1),
-- NOTE: SCT 401-2 (Business Management and Entrepreneurship) is already in the SCT common modules above.
-- All optional pool references use module_code='SCT 401-2' which resolves correctly via subquery.
('MRT 461-6',   'Directed Research Project',                        6.0,  1),
('MRT 462-6',   'Industrial Training (Non-GPA)',                    6.0,  0);

-- --- MRT Level 400 - WST Specialization (additional modules) ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('MRT 471-3',   'Advanced Water Chemistry',                         3.0,  1),
('MRT 472-1',   'Water Chemistry Laboratory - II',                  1.0,  1),
('MRT 473-2',   'Wastewater Treatment and Reuse - II',              2.0,  1),
('MRT 474-1',   'Nanotechnology for Water Treatment',               1.0,  1),
('MRT 475-2',   'Bottled Water Technology',                         2.0,  1),
('MRT 476-3',   'Solute Transport and Reactive Fluid Flow Modelling', 3.0, 1),
('MRT 479-2',   'Membrane Technology',                              2.0,  1);

-- --- CST (Computer Science & Technology) Level 100 ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('CST 102-2',   'Introduction to Computer Science',                 2.0,  1),
('CST 101-2',   'Fundamentals of Electronics',                      2.0,  1),
('CST 121-3',   'Structured Programming',                           3.0,  1),
('CST 111-2',   'Essential Mathematics (non-GPA)',                  2.0,  0),
('CST 122-2',   'Web Programming',                                  2.0,  1),
('CST 131-2',   'Fundamentals of Computer Networks',                2.0,  1),
('CST 123-3',   'Database Management Systems',                      3.0,  1),
('CST 161-3',   'Microcomputer Architecture and Logic Design',      3.0,  1),
('CST 124-2',   'Object Oriented Programming',                      2.0,  1),
('CST 112-2',   'Calculus',                                         2.0,  1);

-- --- CST Level 200 ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('CST 241-3',   'System Analysis and Design',                       3.0,  1),
('CST 214-3',   'Statistical Methods-I',                            3.0,  1),
('CST 232-2',   'Data Communication and Networking',                2.0,  1),
('CST 242-3',   'Software Engineering',                             3.0,  1),
('CST 213-2',   'Discrete Mathematics',                             2.0,  1),
('CST 291-2',   'Entrepreneurship',                                 2.0,  1),
('CST 225-3',   'Data Structures and Analysis of Algorithm',        3.0,  1),
('CST 262-2',   'Operating Systems Concepts and Compiler Designs',  2.0,  1),
('CST 243-3',   'Rapid Application Development',                    3.0,  1),
('CST 292-2',   'Project I',                                        2.0,  1),
('CST 226-2',   'Web Application Development',                      2.0,  1),
('IIT 223-2',   'Information Technology Project Management',        2.0,  1);

-- --- CST Level 300 ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('CST 328-2',   'Advanced Programming Techniques',                  2.0,  1),
('CST 371-2',   'Human Computer Interaction',                       2.0,  1),
('CST 372-3',   'Intelligent Systems',                              3.0,  1),
('CST 327-2',   'Advanced Database Management Systems',             2.0,  1),
('CST 381-2',   'Computer Graphics',                                2.0,  1),
('CST 333-2',   'Data and Network Security',                        2.0,  1),
('CST 315-2',   'Mathematics for Computing',                        2.0,  1),
('CST 344-2',   'Management Information Systems',                   2.0,  1),
('CST 345-2',   'Mobile Application Development',                   2.0,  1),
('CST 393-2',   'Principles of Management',                         2.0,  1),
('CST 347-2',   'Software Architecture and Design Patterns',        2.0,  1),
('CST 363-2',   'Computer Systems Architecture',                    2.0,  1),
('CST 394-2',   'Project-II',                                       2.0,  1),
('CST 346-2',   'Software Quality Assurance',                       2.0,  1),
('CST 382-3',   'Digital Image Processing',                         3.0,  1),
('CST 364-2',   'Systems Level Programming',                        2.0,  1),
('CST 395-2',   'Research Methodology and Scientific Writing',      2.0,  1),
('CST 396-1',   'Emerging Technologies in Computer Science and Informatics', 1.0, 1),
('CST 334-2',   'Mobile Computing',                                 2.0,  1),
('CST 316-2',   'Statistical Method-II',                            2.0,  1),
('CST 351-2',   'Parallel and Distributed Computing',               2.0,  1);

-- --- CST Level 400 ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('CST 497-2',   'Social, Ethical and Professional Issues in Computing', 2.0, 1),
('CST 429-2',   'Semantic Web Technologies',                        2.0,  1),
('CST 453-2',   'Cloud Computing',                                  2.0,  1),
('CST 476-2',   'Deep Learning',                                    2.0,  1),
('CST 483-2',   'Remote Sensing and Image Interpretation',          2.0,  1),
('CST 473-2',   'Bioinformatics',                                   2.0,  1),
('CST 448-2',   'Enterprise Resource Planning (ERP)',               2.0,  1),
('CST 477-2',   'Robotics',                                         2.0,  1),
('CST 474-2',   'Data Warehousing and Data Mining',                 2.0,  1),
('CST 475-2',   'Digital Forensics',                                2.0,  1),
('CST 436-2',   'System Administration and Maintenance',            2.0,  1),
('CST 435-2',   'Advanced Computer Networks',                       2.0,  1),
('IIT 447-2',   'GIS for Business',                                 2.0,  1),
('CST 437-2',   'Internet of Things',                               2.0,  1),
('CST 498-6',   'Industrial Training (Non-GPA)',                    6.0,  0),
('CST 499-6',   'Research Project',                                 6.0,  1);

-- --- IIT (Industrial Information Technology) Level 100 ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('IIT 121-3',   'Principles of Management',                         3.0,  1),
('IIT 131-3',   'Fundamentals of Economics',                        3.0,  1);

-- --- IIT Level 200 ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('IIT 232-3',   'Financial Accounting',                             3.0,  1),
('IIT 241-2',   'Entrepreneurship',                                 2.0,  1),
('IIT 251-3',   'Principles of Marketing',                          3.0,  1),
('IIT 271-2',   'Project I',                                        2.0,  1),
('IIT 233-2',   'Management Accountancy',                           2.0,  1),
('IIT 211-2',   'Operational Research',                             2.0,  1),
('IIT 334-2',   'Business Finance',                                 2.0,  1);

-- --- IIT Level 300 ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('IIT 342-3',   'Organizational Behavior',                          3.0,  1),
('IIT 311-3',   'Statistical Methods-I',                            3.0,  1),
('IIT 301-2',   'Data Structures and Algorithms',                   2.0,  1),
('IIT 327-2',   'Information Security and Risk Management',         2.0,  1),
('IIT 343-2',   'Business Law',                                     2.0,  1),
('IIT 372-2',   'Project-II',                                       2.0,  1),
('IIT 344-2',   'Strategic Management',                             2.0,  1),
('IIT 313-2',   'Statistical Method-II',                            2.0,  1),
('IIT 361-2',   'Digital Image Processing',                         2.0,  1);

-- --- IIT Level 400 ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('IIT 448-2',   'Business Process Management',                      2.0,  1),
('IIT 414-2',   'Business Analytics',                               2.0,  1),
('IIT 424-2',   'Organizational Change and Development',            2.0,  1),
('IIT 445-2',   'e-Commerce',                                       2.0,  1),
('IIT 452-2',   'Digital Marketing',                                2.0,  1),
('IIT 402-2',   'Advanced Programming Techniques',                  2.0,  1),
('IIT 462-2',   'Multimedia Technologies',                          2.0,  1),
('IIT 473-6',   'Industrial Training (Non-GPA)',                    6.0,  0),
('IIT 474-6',   'Research Project',                                 6.0,  1);

-- --- SCT Level 300 - Food Engineering & Bioprocess Technology ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('SCT 311-3',   'Bio-product Separation and Purification Processes', 3.0, 1),
('SCT 312-2',   'Characterization and Analytical Techniques',       2.0,  1),
('SCT 313-2',   'Engineering Properties of Bio Based Materials',    2.0,  1),
('SCT 314-2',   'Enzymology',                                       2.0,  1),
('SCT 315-2',   'Food Analysis',                                    2.0,  1),
('SCT 316-2',   'Metabolism',                                       2.0,  1),
('SCT 317-2',   'Microbiology II',                                  2.0,  1),
('SCT 318-2',   'Organic Synthesis',                                2.0,  1),
('SCT 331-1',   'Applications of Nanotechnology',                   1.0,  1),
('SCT 332-1',   'Cleaner Production Technology',                    1.0,  1),
('SCT 333-1',   'Industrial Quality and Safety Standards',          1.0,  1),
('SCT 321-2',   'Data Handling and Statistics',                     2.0,  1),
('SCT 322-3',   'Food Process Technology I',                        3.0,  1),
('SCT 323-1',   'Food Storage and Packaging Technology',            1.0,  1),
('SCT 324-2',   'Fermentation Technology',                          2.0,  1),
('SCT 325-2',   'In vitro Culture Techniques',                      2.0,  1),
('SCT 326-2',   'Metabolomics',                                     2.0,  1),
('SCT 327-1',   'Mini Project',                                     1.0,  1),
('SCT 328-3',   'Molecular Biology and Biotechnology',              3.0,  1),
('SCT 331-2',   'Functional Foods and Nutraceuticals',              2.0,  1);

-- --- SCT Level 400 - Food Engineering & Bioprocess Technology ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('SCT 411-2',   'Biomass Conversion and Biofuels',                  2.0,  1),
('SCT 412-2',   'Bioprocess Equipment Design and Fabrication',      2.0,  1),
('SCT 413-2',   'Flavors and Fragrances',                           2.0,  1),
('SCT 414-2',   'Food Process Modeling and Simulation',             2.0,  1),
('SCT 415-3',   'Food Process Technology II',                       3.0,  1),
('SCT 433-2',   'Biodegradation and Bioremediation',                2.0,  1);

-- --- SCT Level 300 - Material Science and Technology ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('SCT 341-2',   'Materials Characterization Techniques - I',        2.0,  1),
('SCT 342-2',   'Materials Chemistry',                              2.0,  1),
('SCT 343-2',   'Materials Physics',                                2.0,  1),
('SCT 344-1',   'Materials Technology Laboratory - I',              1.0,  1),
('SCT 345-2',   'Polymer Science and Technology - I',               2.0,  1),
('SCT 346-2',   'Quantum Mechanics',                                2.0,  1),
('SCT 347-2',   'Structural Properties of Materials',               2.0,  1),
('SCT 348-2',   'Surface and Colloidal Science',                    2.0,  1),
('SCT 377-2',   'Mathematical Methods and Complex Analysis',        2.0,  1),
('SCT 361-1',   'Environmental Science',                            1.0,  1),
('SCT 362-1',   'Green Technology',                                 1.0,  1),
('SCT 363-1',   'Soft Materials and Their Applications',            1.0,  1),
('SCT 351-1',   'Bio Materials and Applications',                   1.0,  1),
('SCT 352-2',   'Ceramic Science and Technology',                   2.0,  1),
('SCT 353-2',   'Computational Chemistry',                          2.0,  1),
('SCT 354-2',   'Functional Properties of Materials',               2.0,  1),
('SCT 355-1',   'Glass Science and Technology',                     1.0,  1),
('SCT 356-2',   'Materials Characterization Techniques - II',       2.0,  1),
('SCT 357-1',   'Materials Technology Laboratory - II',             1.0,  1),
('SCT 358-1',   'Polymer Science and Technology - II',              1.0,  1),
('SCT 359-1',   'Seminar in Materials Science',                     1.0,  1),
('SCT 301-2',   'Material Science Group Project',                   2.0,  1),
('SCT 364-2',   'Wood and Wood based product development',          2.0,  1);

-- --- SCT Level 400 - Material Science and Technology ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('SCT 441-1',   'Chemical Engineering Science',                     1.0,  1),
('SCT 442-2',   'Composites and Polymer Blends',                    2.0,  1),
('SCT 443-1',   'Materials Technology Laboratory - III',            1.0,  1),
('SCT 444-2',   'Metallurgy',                                       2.0,  1),
('SCT 445-2',   'Nano Materials and Nanotechnology',                2.0,  1),
('SCT 446-2',   'Product Design and Manufacturing Technology',      2.0,  1),
('SCT 461-1',   'Materials for Energy Applications',                1.0,  1),
('SCT 462-1',   'Smart Materials and Intelligent Mechanical Systems', 1.0, 1),
('MET 431-1',   'Safety and Risk Management',                       1.0,  1),
('MET 475-1',   'Sustainable Consumption and Production',           1.0,  1),
('PLT 442-2',   'Rubber Products Designing and Development',        2.0,  1);

-- --- SCT Level 300 - Mechatronics ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('SCT 371-2',   'Advanced Computer Programming',                    2.0,  1),
('SCT 372-3',   'Digital and Analog Electronics',                   3.0,  1),
('SCT 373-2',   'Digital Image Processing',                         2.0,  1),
('SCT 374-2',   'Electrical Systems',                               2.0,  1),
('SCT 375-1',   'Engineering Design',                               1.0,  1),
('SCT 376-1',   'Introduction to Mechatronics',                     1.0,  1),
('SCT 378-1',   'Mechatronics Laboratory I',                        1.0,  1),
('SCT 379-1',   'Mechatronics Projects',                            1.0,  1),
('SCT 391-2',   'Data Transmission and Signal Processing',          2.0,  1),
('SCT 392-2',   'Energy Technology',                                2.0,  1),
('SCT 393-2',   'Engineering Metallurgy',                           2.0,  1),
('SCT 381-2',   'Applied Engineering Thermodynamics',               2.0,  1),
('SCT 382-2',   'Computer Aided Drafting and Manufacturing',        2.0,  1),
('SCT 383-2',   'Electric Power and Machine',                       2.0,  1),
('SCT 385-1',   'Mechatronics Laboratory II',                       1.0,  1),
('SCT 386-1',   'New Product Development',                          1.0,  1),
('SCT 387-2',   'Power Electronics',                                2.0,  1),
('SCT 388-2',   'Theory of Machines',                               2.0,  1),
('SCT 389-1',   'Vector Calculus',                                  1.0,  1),
('SCT 394-2',   'Maintenance, Production and Project Management',   2.0,  1);

-- --- SCT Level 400 - Mechatronics ---
INSERT INTO modules (module_code, module_name, credits, is_gpa) VALUES
('SCT 471-2',   'Control Theory',                                   2.0,  1),
('SCT 472-2',   'Intelligent Control Systems',                      2.0,  1),
('SCT 473-2',   'Mechatronic Systems Modeling and Simulation',      2.0,  1),
('SCT 474-2',   'Numerical Analysis',                               2.0,  1),
('SCT 475-2',   'Robotics',                                         2.0,  1),
('SCT 476-2',   'Systems Automation',                               2.0,  1),
('SCT 477-1',   'Time Series and Stochastic Processes',             1.0,  1),
('SCT 491-2',   'Sensors and Transducers',                          2.0,  1),
('SCT 492-2',   'Virtual Instrumentation',                          2.0,  1);


-- ============================================================
-- IIT CURRICULUM GROUPS AND MAPPINGS
-- Reference: Handbook pp.49-52
-- ============================================================

-- IIT - Level 100 - Semester 1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(1, 1, 1, 'ESD',  'ESD & BGE Course Units',   4.0),  -- group 1
(1, 1, 1, 'CORE', 'Core Course Units',        12.0); -- group 2

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
-- ESD L100 S1
(1, (SELECT id FROM modules WHERE module_code='ESD 121-2'), 1),
(1, (SELECT id FROM modules WHERE module_code='ESD 151-1'), 1),
(1, (SELECT id FROM modules WHERE module_code='ESD 161-1'), 1),
(1, (SELECT id FROM modules WHERE module_code='BGE 121-2'), 1),
-- CORE L100 S1
(2, (SELECT id FROM modules WHERE module_code='CST 102-2'), 1),
(2, (SELECT id FROM modules WHERE module_code='IIT 121-3'), 1),
(2, (SELECT id FROM modules WHERE module_code='CST 121-3'), 1),
(2, (SELECT id FROM modules WHERE module_code='CST 111-2'), 1),
(2, (SELECT id FROM modules WHERE module_code='CST 122-2'), 1),
(2, (SELECT id FROM modules WHERE module_code='CST 131-2'), 1);

-- IIT - Level 100 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(1, 1, 2, 'ESD',  'ESD & BGE Course Units',   6.0),  -- group 3
(1, 1, 2, 'CORE', 'Core Course Units',         9.0); -- group 4

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
-- ESD L100 S2
(3, (SELECT id FROM modules WHERE module_code='ESD 122-2'), 1),
(3, (SELECT id FROM modules WHERE module_code='ESD 152-1'), 1),
(3, (SELECT id FROM modules WHERE module_code='ESD 162-1'), 1),
(3, (SELECT id FROM modules WHERE module_code='ESD 111-1'), 1),
(3, (SELECT id FROM modules WHERE module_code='ESD 141-2'), 1),
-- CORE L100 S2
(4, (SELECT id FROM modules WHERE module_code='CST 123-3'), 1),
(4, (SELECT id FROM modules WHERE module_code='IIT 131-3'), 1),
(4, (SELECT id FROM modules WHERE module_code='CST 124-2'), 1),
(4, (SELECT id FROM modules WHERE module_code='CST 112-2'), 1);

-- IIT - Level 200 - Semester 1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(1, 2, 1, 'ESD',  'ESD & BGE Course Units',  4.0),   -- group 5
(1, 2, 1, 'CORE', 'Core Course Units',       15.0);  -- group 6

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(5, (SELECT id FROM modules WHERE module_code='ESD 221-2'), 1),
(5, (SELECT id FROM modules WHERE module_code='BGE 211-2'), 1),
(6, (SELECT id FROM modules WHERE module_code='CST 241-3'), 1),
(6, (SELECT id FROM modules WHERE module_code='IIT 232-3'), 1),
(6, (SELECT id FROM modules WHERE module_code='CST 232-2'), 1),
(6, (SELECT id FROM modules WHERE module_code='CST 242-3'), 1),
(6, (SELECT id FROM modules WHERE module_code='CST 213-2'), 1),
(6, (SELECT id FROM modules WHERE module_code='IIT 241-2'), 1);

-- IIT - Level 200 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(1, 2, 2, 'CORE', 'Core Course Units', 18.0);   -- group 7

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(7, (SELECT id FROM modules WHERE module_code='IIT 251-3'), 1),
(7, (SELECT id FROM modules WHERE module_code='CST 262-2'), 1),
(7, (SELECT id FROM modules WHERE module_code='CST 243-3'), 1),
(7, (SELECT id FROM modules WHERE module_code='IIT 271-2'), 1),
(7, (SELECT id FROM modules WHERE module_code='IIT 233-2'), 1),
(7, (SELECT id FROM modules WHERE module_code='IIT 211-2'), 1),
(7, (SELECT id FROM modules WHERE module_code='CST 226-2'), 1),
(7, (SELECT id FROM modules WHERE module_code='IIT 223-2'), 1);

-- IIT - Level 300 - Semester 1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(1, 3, 1, 'ESD',      'ESD Course Units',     1.0),   -- group 8
(1, 3, 1, 'CORE',     'Core Course Units',   16.0),   -- group 9
(1, 3, 1, 'OPTIONAL', 'Optional Pool',        2.0);   -- group 10

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(8,  (SELECT id FROM modules WHERE module_code='ESD 311-1'), 1),
(9,  (SELECT id FROM modules WHERE module_code='IIT 334-2'), 1),
(9,  (SELECT id FROM modules WHERE module_code='IIT 342-3'), 1),
(9,  (SELECT id FROM modules WHERE module_code='IIT 311-3'), 1),
(9,  (SELECT id FROM modules WHERE module_code='IIT 301-2'), 1),
(9,  (SELECT id FROM modules WHERE module_code='CST 371-2'), 1),
(9,  (SELECT id FROM modules WHERE module_code='CST 344-2'), 1),
(9,  (SELECT id FROM modules WHERE module_code='CST 327-2'), 1),
(10, (SELECT id FROM modules WHERE module_code='IIT 327-2'), 0),
(10, (SELECT id FROM modules WHERE module_code='CST 334-2'), 0),
(10, (SELECT id FROM modules WHERE module_code='CST 315-2'), 0);

-- IIT - Level 300 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(1, 3, 2, 'CORE',     'Core Course Units',   13.0),   -- group 11
(1, 3, 2, 'OPTIONAL', 'Optional Pool',        2.0);   -- group 12

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(11, (SELECT id FROM modules WHERE module_code='IIT 343-2'), 1),
(11, (SELECT id FROM modules WHERE module_code='IIT 323-2'), 1),
(11, (SELECT id FROM modules WHERE module_code='IIT 372-2'), 1),
(11, (SELECT id FROM modules WHERE module_code='CST 346-2'), 1),
(11, (SELECT id FROM modules WHERE module_code='CST 347-2'), 1),
(11, (SELECT id FROM modules WHERE module_code='CST 395-2'), 1),
(11, (SELECT id FROM modules WHERE module_code='CST 396-1'), 1),
(12, (SELECT id FROM modules WHERE module_code='IIT 344-2'), 0),
(12, (SELECT id FROM modules WHERE module_code='IIT 313-2'), 0),
(12, (SELECT id FROM modules WHERE module_code='IIT 361-2'), 0);

-- IIT - Level 400 - Semester 1
-- Note from handbook (p.52): "Student must choose at least 4 credits from Basket 1 AND 4 credits from Basket 2"
-- The list of 13 Optional modules (IIT 414-2 through CST 435-2) is split into Basket-1 and Basket-2.
-- The handbook does not explicitly name which modules are in Basket-1 vs Basket-2, only that
-- each basket requires >= 4 credits selected from it.
-- We model them as two separate BASKET groups with min_credits_required = 4.
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(1, 4, 1, 'CORE',   'Core Course Units', 8.0),    -- group 13
(1, 4, 1, 'BASKET', 'Basket-1',          4.0),    -- group 14
(1, 4, 1, 'BASKET', 'Basket-2',          4.0);    -- group 15

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
-- Core L400 S1
(13, (SELECT id FROM modules WHERE module_code='IIT 446-2'),  1),
(13, (SELECT id FROM modules WHERE module_code='CST 497-2'),  1),
(13, (SELECT id FROM modules WHERE module_code='CST 429-2'),  1),
(13, (SELECT id FROM modules WHERE module_code='IIT 448-2'),  1),
-- Basket-1 options (Business/Management themed)
(14, (SELECT id FROM modules WHERE module_code='IIT 414-2'),  0),
(14, (SELECT id FROM modules WHERE module_code='IIT 447-2'),  0),
(14, (SELECT id FROM modules WHERE module_code='IIT 424-2'),  0),
(14, (SELECT id FROM modules WHERE module_code='IIT 445-2'),  0),
(14, (SELECT id FROM modules WHERE module_code='IIT 452-2'),  0),
(14, (SELECT id FROM modules WHERE module_code='CST 448-2'),  0),
-- Basket-2 options (Technical themed)
(15, (SELECT id FROM modules WHERE module_code='CST 437-2'),  0),
(15, (SELECT id FROM modules WHERE module_code='IIT 402-2'),  0),
(15, (SELECT id FROM modules WHERE module_code='CST 474-2'),  0),
(15, (SELECT id FROM modules WHERE module_code='CST 436-2'),  0),
(15, (SELECT id FROM modules WHERE module_code='CST 475-2'),  0),
(15, (SELECT id FROM modules WHERE module_code='CST 435-2'),  0),
(15, (SELECT id FROM modules WHERE module_code='IIT 462-2'),  0);

-- IIT - Level 400 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(1, 4, 2, 'CORE', 'Core Course Units', 6.0);   -- group 16

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(16, (SELECT id FROM modules WHERE module_code='IIT 473-6'), 1),
(16, (SELECT id FROM modules WHERE module_code='IIT 474-6'), 1);


-- ============================================================
-- CST CURRICULUM GROUPS AND MAPPINGS
-- Reference: Handbook pp.44-47
-- ============================================================

-- CST - Level 100 - Semester 1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(2, 1, 1, 'ESD',  'ESD & BGE Course Units',  4.0),   -- group 17
(2, 1, 1, 'CORE', 'Core Course Units',       13.0);  -- group 18

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(17, (SELECT id FROM modules WHERE module_code='ESD 121-2'), 1),
(17, (SELECT id FROM modules WHERE module_code='ESD 151-1'), 1),
(17, (SELECT id FROM modules WHERE module_code='ESD 161-1'), 1),
(17, (SELECT id FROM modules WHERE module_code='BGE 121-2'), 1),
(18, (SELECT id FROM modules WHERE module_code='CST 102-2'), 1),
(18, (SELECT id FROM modules WHERE module_code='CST 101-2'), 1),
(18, (SELECT id FROM modules WHERE module_code='CST 121-3'), 1),
(18, (SELECT id FROM modules WHERE module_code='CST 111-2'), 1),
(18, (SELECT id FROM modules WHERE module_code='CST 122-2'), 1),
(18, (SELECT id FROM modules WHERE module_code='CST 131-2'), 1);

-- CST - Level 100 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(2, 1, 2, 'ESD',  'ESD & BGE Course Units', 6.0),   -- group 19
(2, 1, 2, 'CORE', 'Core Course Units',      10.0);  -- group 20

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(19, (SELECT id FROM modules WHERE module_code='ESD 122-2'), 1),
(19, (SELECT id FROM modules WHERE module_code='ESD 152-1'), 1),
(19, (SELECT id FROM modules WHERE module_code='ESD 162-1'), 1),
(19, (SELECT id FROM modules WHERE module_code='ESD 111-1'), 1),
(19, (SELECT id FROM modules WHERE module_code='ESD 141-2'), 1),
(20, (SELECT id FROM modules WHERE module_code='CST 123-3'), 1),
(20, (SELECT id FROM modules WHERE module_code='CST 161-3'), 1),
(20, (SELECT id FROM modules WHERE module_code='CST 124-2'), 1),
(20, (SELECT id FROM modules WHERE module_code='CST 112-2'), 1);

-- CST - Level 200 - Semester 1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(2, 2, 1, 'ESD',  'ESD & BGE Course Units',  4.0),  -- group 21
(2, 2, 1, 'CORE', 'Core Course Units',       15.0); -- group 22

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(21, (SELECT id FROM modules WHERE module_code='ESD 221-2'), 1),
(21, (SELECT id FROM modules WHERE module_code='BGE 211-2'), 1),
(22, (SELECT id FROM modules WHERE module_code='CST 241-3'), 1),
(22, (SELECT id FROM modules WHERE module_code='CST 214-3'), 1),
(22, (SELECT id FROM modules WHERE module_code='CST 232-2'), 1),
(22, (SELECT id FROM modules WHERE module_code='CST 242-3'), 1),
(22, (SELECT id FROM modules WHERE module_code='CST 213-2'), 1),
(22, (SELECT id FROM modules WHERE module_code='CST 291-2'), 1);

-- CST - Level 200 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(2, 2, 2, 'CORE', 'Core Course Units', 14.0); -- group 23

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(23, (SELECT id FROM modules WHERE module_code='CST 225-3'), 1),
(23, (SELECT id FROM modules WHERE module_code='CST 262-2'), 1),
(23, (SELECT id FROM modules WHERE module_code='CST 243-3'), 1),
(23, (SELECT id FROM modules WHERE module_code='CST 292-2'), 1),
(23, (SELECT id FROM modules WHERE module_code='CST 226-2'), 1),
(23, (SELECT id FROM modules WHERE module_code='IIT 223-2'), 1);

-- CST - Level 300 - Semester 1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(2, 3, 1, 'ESD',      'ESD Course Units',     1.0),  -- group 24
(2, 3, 1, 'CORE',     'Core Course Units',   17.0),  -- group 25
(2, 3, 1, 'OPTIONAL', 'Optional Pool',        2.0);  -- group 26

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(24, (SELECT id FROM modules WHERE module_code='ESD 311-1'),  1),
(25, (SELECT id FROM modules WHERE module_code='CST 328-2'),  1),
(25, (SELECT id FROM modules WHERE module_code='CST 371-2'),  1),
(25, (SELECT id FROM modules WHERE module_code='CST 372-3'),  1),
(25, (SELECT id FROM modules WHERE module_code='CST 327-2'),  1),
(25, (SELECT id FROM modules WHERE module_code='CST 381-2'),  1),
(25, (SELECT id FROM modules WHERE module_code='CST 333-2'),  1),
(25, (SELECT id FROM modules WHERE module_code='SCT 384-2'),  1),
(25, (SELECT id FROM modules WHERE module_code='CST 315-2'),  1),
(26, (SELECT id FROM modules WHERE module_code='CST 344-2'),  0),
(26, (SELECT id FROM modules WHERE module_code='CST 345-2'),  0),
(26, (SELECT id FROM modules WHERE module_code='CST 393-2'),  0);

-- CST - Level 300 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(2, 3, 2, 'CORE',     'Core Course Units',   16.0),  -- group 27
(2, 3, 2, 'OPTIONAL', 'Optional Pool',        2.0);  -- group 28

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(27, (SELECT id FROM modules WHERE module_code='CST 347-2'),  1),
(27, (SELECT id FROM modules WHERE module_code='CST 363-2'),  1),
(27, (SELECT id FROM modules WHERE module_code='CST 394-2'),  1),
(27, (SELECT id FROM modules WHERE module_code='CST 346-2'),  1),
(27, (SELECT id FROM modules WHERE module_code='CST 382-3'),  1),
(27, (SELECT id FROM modules WHERE module_code='CST 364-2'),  1),
(27, (SELECT id FROM modules WHERE module_code='CST 395-2'),  1),
(27, (SELECT id FROM modules WHERE module_code='CST 396-1'),  1),
(28, (SELECT id FROM modules WHERE module_code='CST 334-2'),  0),
(28, (SELECT id FROM modules WHERE module_code='CST 316-2'),  0),
(28, (SELECT id FROM modules WHERE module_code='CST 351-2'),  0);

-- CST - Level 400 - Semester 1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(2, 4, 1, 'CORE',     'Core Course Units',  10.0),  -- group 29
(2, 4, 1, 'OPTIONAL', 'Optional Pool',       8.0);  -- group 30

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(29, (SELECT id FROM modules WHERE module_code='IIT 446-2'),  1),
(29, (SELECT id FROM modules WHERE module_code='CST 497-2'),  1),
(29, (SELECT id FROM modules WHERE module_code='CST 429-2'),  1),
(29, (SELECT id FROM modules WHERE module_code='CST 453-2'),  1),
(29, (SELECT id FROM modules WHERE module_code='CST 476-2'),  1),
(30, (SELECT id FROM modules WHERE module_code='CST 483-2'),  0),
(30, (SELECT id FROM modules WHERE module_code='CST 473-2'),  0),
(30, (SELECT id FROM modules WHERE module_code='CST 448-2'),  0),
(30, (SELECT id FROM modules WHERE module_code='CST 477-2'),  0),
(30, (SELECT id FROM modules WHERE module_code='CST 474-2'),  0),
(30, (SELECT id FROM modules WHERE module_code='CST 475-2'),  0),
(30, (SELECT id FROM modules WHERE module_code='CST 436-2'),  0),
(30, (SELECT id FROM modules WHERE module_code='CST 435-2'),  0),
(30, (SELECT id FROM modules WHERE module_code='IIT 447-2'),  0),
(30, (SELECT id FROM modules WHERE module_code='CST 437-2'),  0);

-- CST - Level 400 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(2, 4, 2, 'CORE', 'Core Course Units', 6.0); -- group 31

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(31, (SELECT id FROM modules WHERE module_code='CST 498-6'), 1),
(31, (SELECT id FROM modules WHERE module_code='CST 499-6'), 1);


-- ============================================================
-- MRT - MINERAL PROCESSING TECHNOLOGY (MPT) CURRICULUM
-- Reference: Handbook pp.28-35
-- ============================================================

-- MRT-MPT - Level 100 - Semester 1 (same as MRT-WST)
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(3, 1, 1, 'ESD',  'ESD & BGE Course Units', 5.0),  -- group 32
(3, 1, 1, 'CORE', 'Core Course Units',      11.0); -- group 33

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(32, (SELECT id FROM modules WHERE module_code='ESD 121-2'), 1),
(32, (SELECT id FROM modules WHERE module_code='ESD 151-1'), 1),
(32, (SELECT id FROM modules WHERE module_code='ESD 161-1'), 1),
(32, (SELECT id FROM modules WHERE module_code='ESD 103-2'), 1),
(32, (SELECT id FROM modules WHERE module_code='BGE 121-2'), 1),
(33, (SELECT id FROM modules WHERE module_code='SCT 101-1'), 1),
(33, (SELECT id FROM modules WHERE module_code='SCT 121-1'), 1),
(33, (SELECT id FROM modules WHERE module_code='SCT 131-2'), 1),
(33, (SELECT id FROM modules WHERE module_code='SCT 141-1'), 1),
(33, (SELECT id FROM modules WHERE module_code='SCT 151-2'), 1),
(33, (SELECT id FROM modules WHERE module_code='MRT 151-3'), 1),
(33, (SELECT id FROM modules WHERE module_code='MRT 152-1'), 1);

-- MRT-MPT - Level 100 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(3, 1, 2, 'ESD',  'ESD & BGE Course Units',  6.0),  -- group 34
(3, 1, 2, 'CORE', 'Core Course Units',       11.0); -- group 35

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(34, (SELECT id FROM modules WHERE module_code='ESD 122-2'), 1),
(34, (SELECT id FROM modules WHERE module_code='ESD 152-1'), 1),
(34, (SELECT id FROM modules WHERE module_code='ESD 162-1'), 1),
(34, (SELECT id FROM modules WHERE module_code='ESD 111-1'), 1),
(34, (SELECT id FROM modules WHERE module_code='ESD 141-2'), 1),
(35, (SELECT id FROM modules WHERE module_code='SCT 102-2'), 1),
(35, (SELECT id FROM modules WHERE module_code='SCT 132-2'), 1),
(35, (SELECT id FROM modules WHERE module_code='SCT 152-2'), 1),
(35, (SELECT id FROM modules WHERE module_code='MRT 161-3'), 1),
(35, (SELECT id FROM modules WHERE module_code='MRT 162-1'), 1);

-- MRT-MPT - Level 200 - Semester 1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(3, 2, 1, 'ESD',  'ESD & BGE Course Units',  4.0),  -- group 36
(3, 2, 1, 'CORE', 'Core Course Units',       13.0); -- group 37

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(36, (SELECT id FROM modules WHERE module_code='ESD 221-2'), 1),
(36, (SELECT id FROM modules WHERE module_code='BGE 211-2'), 1),
(37, (SELECT id FROM modules WHERE module_code='SCT 201-1'), 1),
(37, (SELECT id FROM modules WHERE module_code='SCT 211-2'), 1),
(37, (SELECT id FROM modules WHERE module_code='SCT 231-2'), 1),
(37, (SELECT id FROM modules WHERE module_code='SCT 251-2'), 1),
(37, (SELECT id FROM modules WHERE module_code='SCT 252-1'), 1),
(37, (SELECT id FROM modules WHERE module_code='MRT 251-3'), 1),
(37, (SELECT id FROM modules WHERE module_code='MRT 253-2'), 1);

-- MRT-MPT - Level 200 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(3, 2, 2, 'BGE',  'BGE Course Units',   2.0),   -- group 38
(3, 2, 2, 'CORE', 'Core Course Units', 13.0);   -- group 39

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(38, (SELECT id FROM modules WHERE module_code='BGE 214-1'), 1),
(38, (SELECT id FROM modules WHERE module_code='BGE 215-1'), 1),
(39, (SELECT id FROM modules WHERE module_code='SCT 202-3'), 1),
(39, (SELECT id FROM modules WHERE module_code='SCT 232-2'), 1),
(39, (SELECT id FROM modules WHERE module_code='SCT 242-2'), 1),
(39, (SELECT id FROM modules WHERE module_code='SCT 253-1'), 1),
(39, (SELECT id FROM modules WHERE module_code='SCT 212-1'), 1),
(39, (SELECT id FROM modules WHERE module_code='MRT 252-2'), 1),
(39, (SELECT id FROM modules WHERE module_code='MRT 254-2'), 1);

-- MRT-MPT - Level 300 - Semester 1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(3, 3, 1, 'ESD',      'ESD Course Units',    1.0),  -- group 40
(3, 3, 1, 'CORE',     'Core Course Units',   6.0),  -- group 41
(3, 3, 1, 'ELECTIVE', 'Elective Pool',       7.0),  -- group 42
(3, 3, 1, 'OPTIONAL', 'Optional Pool',       4.0);  -- group 43

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(40, (SELECT id FROM modules WHERE module_code='ESD 311-1'), 1),
(41, (SELECT id FROM modules WHERE module_code='MRT 311-2'), 1),
(41, (SELECT id FROM modules WHERE module_code='MRT 312-2'), 1),
(41, (SELECT id FROM modules WHERE module_code='MRT 362-2'), 1),
(42, (SELECT id FROM modules WHERE module_code='MRT 313-2'), 0),
(42, (SELECT id FROM modules WHERE module_code='MRT 314-1'), 0),
(42, (SELECT id FROM modules WHERE module_code='MRT 315-3'), 0),
(42, (SELECT id FROM modules WHERE module_code='MRT 316-3'), 0),
(42, (SELECT id FROM modules WHERE module_code='MRT 317-2'), 0),
(42, (SELECT id FROM modules WHERE module_code='MRT 318-1'), 0),
(42, (SELECT id FROM modules WHERE module_code='MRT 352-2'), 0),
(43, (SELECT id FROM modules WHERE module_code='AQT 321-3'), 0),
(43, (SELECT id FROM modules WHERE module_code='MRT 353-1'), 0),
(43, (SELECT id FROM modules WHERE module_code='MRT 355-2'), 0),
(43, (SELECT id FROM modules WHERE module_code='MRT 366-1'), 0),
(43, (SELECT id FROM modules WHERE module_code='MRT 374-3'), 0);

-- MRT-MPT - Level 300 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(3, 3, 2, 'CORE',     'Core Course Units',  7.0),  -- group 44
(3, 3, 2, 'ELECTIVE', 'Elective Pool',      7.0),  -- group 45
(3, 3, 2, 'OPTIONAL', 'Optional Pool',      4.0);  -- group 46

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(44, (SELECT id FROM modules WHERE module_code='MRT 321-2'), 1),
(44, (SELECT id FROM modules WHERE module_code='MRT 365-3'), 1),
(44, (SELECT id FROM modules WHERE module_code='MRT 361-2'), 1),
(45, (SELECT id FROM modules WHERE module_code='MRT 322-2'), 0),
(45, (SELECT id FROM modules WHERE module_code='MRT 324-3'), 0),
(45, (SELECT id FROM modules WHERE module_code='MRT 325-2'), 0),
(45, (SELECT id FROM modules WHERE module_code='MRT 327-2'), 0),
(45, (SELECT id FROM modules WHERE module_code='MRT 351-3'), 0),
(46, (SELECT id FROM modules WHERE module_code='MRT 364-1'), 0),
(46, (SELECT id FROM modules WHERE module_code='MRT 381-2'), 0),
(46, (SELECT id FROM modules WHERE module_code='MRT 392-2'), 0),
(46, (SELECT id FROM modules WHERE module_code='IIT 323-2'), 0),
(46, (SELECT id FROM modules WHERE module_code='SCT 302-2'), 0);

-- MRT-MPT - Level 400 - Semester 1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(3, 4, 1, 'CORE',     'Core Course Units',  8.0),  -- group 47
(3, 4, 1, 'ELECTIVE', 'Elective Pool',      6.0),  -- group 48
(3, 4, 1, 'OPTIONAL', 'Optional Pool',      4.0);  -- group 49

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(47, (SELECT id FROM modules WHERE module_code='MRT 411-2'), 1),
(47, (SELECT id FROM modules WHERE module_code='MRT 412-2'), 1),
(47, (SELECT id FROM modules WHERE module_code='MRT 451-2'), 1),
(47, (SELECT id FROM modules WHERE module_code='MRT 463-2'), 1),
(48, (SELECT id FROM modules WHERE module_code='MRT 413-2'), 0),
(48, (SELECT id FROM modules WHERE module_code='MRT 414-2'), 0),
(48, (SELECT id FROM modules WHERE module_code='MRT 415-3'), 0),
(48, (SELECT id FROM modules WHERE module_code='MRT 416-2'), 0),
(48, (SELECT id FROM modules WHERE module_code='MRT 417-2'), 0),
(48, (SELECT id FROM modules WHERE module_code='MRT 418-2'), 0),
(49, (SELECT id FROM modules WHERE module_code='MRT 453-2'), 0),
(49, (SELECT id FROM modules WHERE module_code='MRT 454-2'), 0),
(49, (SELECT id FROM modules WHERE module_code='IIT 446-2'), 0),
(49, (SELECT id FROM modules WHERE module_code='SCT 401-2'), 0),
(49, (SELECT id FROM modules WHERE module_code='SCT 402-2'), 0);



-- MRT-MPT - Level 400 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(3, 4, 2, 'CORE', 'Core Course Units', 6.0); -- group 50

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(50, (SELECT id FROM modules WHERE module_code='MRT 461-6'), 1),
(50, (SELECT id FROM modules WHERE module_code='MRT 462-6'), 1);


-- ============================================================
-- MRT - WATER SCIENCE AND TECHNOLOGY (WST) CURRICULUM
-- Level 100 & 200 identical to MPT; only L300 & L400 differ.
-- ============================================================

-- MRT-WST - Level 100 - Semester 1 (copy of MPT structure)
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(4, 1, 1, 'ESD',  'ESD & BGE Course Units', 5.0),  -- group 51
(4, 1, 1, 'CORE', 'Core Course Units',      11.0); -- group 52

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(51, (SELECT id FROM modules WHERE module_code='ESD 121-2'), 1),
(51, (SELECT id FROM modules WHERE module_code='ESD 151-1'), 1),
(51, (SELECT id FROM modules WHERE module_code='ESD 161-1'), 1),
(51, (SELECT id FROM modules WHERE module_code='ESD 103-2'), 1),
(51, (SELECT id FROM modules WHERE module_code='BGE 121-2'), 1),
(52, (SELECT id FROM modules WHERE module_code='SCT 101-1'), 1),
(52, (SELECT id FROM modules WHERE module_code='SCT 121-1'), 1),
(52, (SELECT id FROM modules WHERE module_code='SCT 131-2'), 1),
(52, (SELECT id FROM modules WHERE module_code='SCT 141-1'), 1),
(52, (SELECT id FROM modules WHERE module_code='SCT 151-2'), 1),
(52, (SELECT id FROM modules WHERE module_code='MRT 151-3'), 1),
(52, (SELECT id FROM modules WHERE module_code='MRT 152-1'), 1);

-- MRT-WST - Level 100 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(4, 1, 2, 'ESD',  'ESD & BGE Course Units',  6.0),  -- group 53
(4, 1, 2, 'CORE', 'Core Course Units',       11.0); -- group 54

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(53, (SELECT id FROM modules WHERE module_code='ESD 122-2'), 1),
(53, (SELECT id FROM modules WHERE module_code='ESD 152-1'), 1),
(53, (SELECT id FROM modules WHERE module_code='ESD 162-1'), 1),
(53, (SELECT id FROM modules WHERE module_code='ESD 111-1'), 1),
(53, (SELECT id FROM modules WHERE module_code='ESD 141-2'), 1),
(54, (SELECT id FROM modules WHERE module_code='SCT 102-2'), 1),
(54, (SELECT id FROM modules WHERE module_code='SCT 132-2'), 1),
(54, (SELECT id FROM modules WHERE module_code='SCT 152-2'), 1),
(54, (SELECT id FROM modules WHERE module_code='MRT 161-3'), 1),
(54, (SELECT id FROM modules WHERE module_code='MRT 162-1'), 1);

-- MRT-WST - Level 200 (identical to MPT)
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(4, 2, 1, 'ESD',  'ESD & BGE Course Units',  4.0),  -- group 55
(4, 2, 1, 'CORE', 'Core Course Units',       13.0), -- group 56
(4, 2, 2, 'BGE',  'BGE Course Units',         2.0), -- group 57
(4, 2, 2, 'CORE', 'Core Course Units',       13.0); -- group 58

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(55, (SELECT id FROM modules WHERE module_code='ESD 221-2'), 1),
(55, (SELECT id FROM modules WHERE module_code='BGE 211-2'), 1),
(56, (SELECT id FROM modules WHERE module_code='SCT 201-1'), 1),
(56, (SELECT id FROM modules WHERE module_code='SCT 211-2'), 1),
(56, (SELECT id FROM modules WHERE module_code='SCT 231-2'), 1),
(56, (SELECT id FROM modules WHERE module_code='SCT 251-2'), 1),
(56, (SELECT id FROM modules WHERE module_code='SCT 252-1'), 1),
(56, (SELECT id FROM modules WHERE module_code='MRT 251-3'), 1),
(56, (SELECT id FROM modules WHERE module_code='MRT 253-2'), 1),
(57, (SELECT id FROM modules WHERE module_code='BGE 214-1'), 1),
(57, (SELECT id FROM modules WHERE module_code='BGE 215-1'), 1),
(58, (SELECT id FROM modules WHERE module_code='SCT 202-3'), 1),
(58, (SELECT id FROM modules WHERE module_code='SCT 232-2'), 1),
(58, (SELECT id FROM modules WHERE module_code='SCT 242-2'), 1),
(58, (SELECT id FROM modules WHERE module_code='SCT 253-1'), 1),
(58, (SELECT id FROM modules WHERE module_code='SCT 212-1'), 1),
(58, (SELECT id FROM modules WHERE module_code='MRT 252-2'), 1),
(58, (SELECT id FROM modules WHERE module_code='MRT 254-2'), 1);

-- MRT-WST - Level 300 - Semester 1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(4, 3, 1, 'ESD',      'ESD Course Units',   1.0),  -- group 59
(4, 3, 1, 'CORE',     'Core Course Units',  6.0),  -- group 60
(4, 3, 1, 'ELECTIVE', 'Elective Pool',      7.0),  -- group 61
(4, 3, 1, 'OPTIONAL', 'Optional Pool',      4.0);  -- group 62

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(59, (SELECT id FROM modules WHERE module_code='ESD 311-1'), 1),
(60, (SELECT id FROM modules WHERE module_code='MRT 371-3'), 1),
(60, (SELECT id FROM modules WHERE module_code='MRT 372-1'), 1),
(60, (SELECT id FROM modules WHERE module_code='MRT 362-2'), 1),
(61, (SELECT id FROM modules WHERE module_code='MRT 373-2'), 0),
(61, (SELECT id FROM modules WHERE module_code='MRT 374-3'), 0),
(61, (SELECT id FROM modules WHERE module_code='MRT 376-2'), 0),
(61, (SELECT id FROM modules WHERE module_code='MRT 378-2'), 0),
(61, (SELECT id FROM modules WHERE module_code='MRT 382-3'), 0),
(61, (SELECT id FROM modules WHERE module_code='MRT 352-2'), 0),
(62, (SELECT id FROM modules WHERE module_code='AQT 321-3'), 0),
(62, (SELECT id FROM modules WHERE module_code='MRT 353-1'), 0),
(62, (SELECT id FROM modules WHERE module_code='MRT 355-2'), 0),
(62, (SELECT id FROM modules WHERE module_code='MRT 366-1'), 0),
(62, (SELECT id FROM modules WHERE module_code='MRT 316-3'), 0);

-- MRT-WST - Level 300 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(4, 3, 2, 'CORE',     'Core Course Units',  7.0),  -- group 63
(4, 3, 2, 'ELECTIVE', 'Elective Pool',      7.0),  -- group 64
(4, 3, 2, 'OPTIONAL', 'Optional Pool',      4.0);  -- group 65

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(63, (SELECT id FROM modules WHERE module_code='MRT 381-2'), 1),
(63, (SELECT id FROM modules WHERE module_code='MRT 365-3'), 1),
(63, (SELECT id FROM modules WHERE module_code='MRT 361-2'), 1),
(64, (SELECT id FROM modules WHERE module_code='MRT 383-1'), 0),
(64, (SELECT id FROM modules WHERE module_code='MRT 384-2'), 0),
(64, (SELECT id FROM modules WHERE module_code='MRT 385-2'), 0),
(64, (SELECT id FROM modules WHERE module_code='MRT 386-3'), 0),
(64, (SELECT id FROM modules WHERE module_code='MRT 388-2'), 0),
(64, (SELECT id FROM modules WHERE module_code='MRT 351-3'), 0),
(65, (SELECT id FROM modules WHERE module_code='MRT 364-1'), 0),
(65, (SELECT id FROM modules WHERE module_code='MRT 327-2'), 0),
(65, (SELECT id FROM modules WHERE module_code='MRT 392-2'), 0),
(65, (SELECT id FROM modules WHERE module_code='IIT 323-2'), 0),
(65, (SELECT id FROM modules WHERE module_code='SCT 302-2'), 0);

-- MRT-WST - Level 400 - Semester 1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(4, 4, 1, 'CORE',     'Core Course Units',  8.0),  -- group 66
(4, 4, 1, 'ELECTIVE', 'Elective Pool',      6.0),  -- group 67
(4, 4, 1, 'OPTIONAL', 'Optional Pool',      4.0);  -- group 68

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(66, (SELECT id FROM modules WHERE module_code='MRT 451-2'), 1),
(66, (SELECT id FROM modules WHERE module_code='MRT 463-2'), 1),
(66, (SELECT id FROM modules WHERE module_code='MRT 471-3'), 1),
(66, (SELECT id FROM modules WHERE module_code='MRT 472-1'), 1),
(67, (SELECT id FROM modules WHERE module_code='MRT 473-2'), 0),
(67, (SELECT id FROM modules WHERE module_code='MRT 474-1'), 0),
(67, (SELECT id FROM modules WHERE module_code='MRT 475-2'), 0),
(67, (SELECT id FROM modules WHERE module_code='MRT 476-3'), 0),
(67, (SELECT id FROM modules WHERE module_code='MRT 479-2'), 0),
(68, (SELECT id FROM modules WHERE module_code='MRT 453-2'), 0),
(68, (SELECT id FROM modules WHERE module_code='MRT 454-2'), 0),
(68, (SELECT id FROM modules WHERE module_code='IIT 446-2'), 0),
(68, (SELECT id FROM modules WHERE module_code='SCT 401-2'), 0),
(68, (SELECT id FROM modules WHERE module_code='SCT 402-2'), 0);



-- MRT-WST - Level 400 - Semester 2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(4, 4, 2, 'CORE', 'Core Course Units', 6.0); -- group 69

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(69, (SELECT id FROM modules WHERE module_code='MRT 461-6'), 1),
(69, (SELECT id FROM modules WHERE module_code='MRT 462-6'), 1);


-- ============================================================
-- SCT - FOOD ENGINEERING AND BIOPROCESS TECHNOLOGY (FEB)
-- Reference: Handbook pp.63-66
-- ============================================================

-- SCT-FEB Level 100 S1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(5, 1, 1, 'ESD',  'ESD & BGE Course Units', 5.0),  -- group 70
(5, 1, 1, 'CORE', 'Core Course Units',      9.0);  -- group 71

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(70, (SELECT id FROM modules WHERE module_code='ESD 121-2'), 1),
(70, (SELECT id FROM modules WHERE module_code='ESD 151-1'), 1),
(70, (SELECT id FROM modules WHERE module_code='ESD 161-1'), 1),
(70, (SELECT id FROM modules WHERE module_code='ESD 103-2'), 1),
(70, (SELECT id FROM modules WHERE module_code='BGE 121-2'), 1),
(71, (SELECT id FROM modules WHERE module_code='SCT 101-1'), 1),
(71, (SELECT id FROM modules WHERE module_code='SCT 121-1'), 1),
(71, (SELECT id FROM modules WHERE module_code='SCT 131-2'), 1),
(71, (SELECT id FROM modules WHERE module_code='SCT 141-1'), 1),
(71, (SELECT id FROM modules WHERE module_code='SCT 142-2'), 1),
(71, (SELECT id FROM modules WHERE module_code='SCT 151-2'), 1);

-- SCT-FEB Level 100 S2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(5, 1, 2, 'ESD',  'ESD & BGE Course Units', 6.0),  -- group 72
(5, 1, 2, 'CORE', 'Core Course Units',      8.0);  -- group 73

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(72, (SELECT id FROM modules WHERE module_code='ESD 122-2'), 1),
(72, (SELECT id FROM modules WHERE module_code='ESD 152-1'), 1),
(72, (SELECT id FROM modules WHERE module_code='ESD 162-1'), 1),
(72, (SELECT id FROM modules WHERE module_code='ESD 111-1'), 1),
(72, (SELECT id FROM modules WHERE module_code='ESD 141-2'), 1),
(73, (SELECT id FROM modules WHERE module_code='SCT 102-2'), 1),
(73, (SELECT id FROM modules WHERE module_code='SCT 132-2'), 1),
(73, (SELECT id FROM modules WHERE module_code='SCT 152-2'), 1),
(73, (SELECT id FROM modules WHERE module_code='SCT 161-1'), 1);

-- SCT-FEB Level 200 S1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(5, 2, 1, 'ESD',  'ESD & BGE Course Units',  4.0),  -- group 74
(5, 2, 1, 'CORE', 'Core Course Units',       12.0); -- group 75

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(74, (SELECT id FROM modules WHERE module_code='ESD 221-2'), 1),
(74, (SELECT id FROM modules WHERE module_code='BGE 211-2'), 1),
(75, (SELECT id FROM modules WHERE module_code='SCT 201-1'), 1),
(75, (SELECT id FROM modules WHERE module_code='SCT 211-2'), 1),
(75, (SELECT id FROM modules WHERE module_code='SCT 231-2'), 1),
(75, (SELECT id FROM modules WHERE module_code='SCT 251-2'), 1),
(75, (SELECT id FROM modules WHERE module_code='SCT 252-1'), 1),
(75, (SELECT id FROM modules WHERE module_code='SCT 221-1'), 1),
(75, (SELECT id FROM modules WHERE module_code='SCT 222-2'), 1),
(75, (SELECT id FROM modules WHERE module_code='SCT 261-1'), 1);

-- SCT-FEB Level 200 S2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(5, 2, 2, 'BGE',  'BGE Course Units',   2.0),   -- group 76
(5, 2, 2, 'CORE', 'Core Course Units', 14.0);   -- group 77

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(76, (SELECT id FROM modules WHERE module_code='BGE 214-1'), 1),
(76, (SELECT id FROM modules WHERE module_code='BGE 215-1'), 1),
(77, (SELECT id FROM modules WHERE module_code='SCT 202-3'), 1),
(77, (SELECT id FROM modules WHERE module_code='SCT 232-2'), 1),
(77, (SELECT id FROM modules WHERE module_code='SCT 242-2'), 1),
(77, (SELECT id FROM modules WHERE module_code='SCT 253-1'), 1),
(77, (SELECT id FROM modules WHERE module_code='SCT 212-1'), 1),
(77, (SELECT id FROM modules WHERE module_code='SCT 223-3'), 1),
(77, (SELECT id FROM modules WHERE module_code='SCT 241-2'), 1);

-- SCT-FEB Level 300 S1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(5, 3, 1, 'ESD',      'ESD Course Units',   1.0),  -- group 78
(5, 3, 1, 'CORE',     'Core Course Units', 17.0),  -- group 79
(5, 3, 1, 'OPTIONAL', 'Optional Pool',      2.0);  -- group 80 (min 1 credit)

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(78, (SELECT id FROM modules WHERE module_code='ESD 311-1'), 1),
(79, (SELECT id FROM modules WHERE module_code='SCT 311-3'), 1),
(79, (SELECT id FROM modules WHERE module_code='SCT 312-2'), 1),
(79, (SELECT id FROM modules WHERE module_code='SCT 313-2'), 1),
(79, (SELECT id FROM modules WHERE module_code='SCT 314-2'), 1),
(79, (SELECT id FROM modules WHERE module_code='SCT 315-2'), 1),
(79, (SELECT id FROM modules WHERE module_code='SCT 316-2'), 1),
(79, (SELECT id FROM modules WHERE module_code='SCT 317-2'), 1),
(79, (SELECT id FROM modules WHERE module_code='SCT 318-2'), 1),
(80, (SELECT id FROM modules WHERE module_code='SCT 331-1'), 0),
(80, (SELECT id FROM modules WHERE module_code='SCT 332-1'), 0),
(80, (SELECT id FROM modules WHERE module_code='SCT 333-1'), 0);

-- SCT-FEB Level 300 S2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(5, 3, 2, 'CORE',     'Core Course Units', 18.0),  -- group 81
(5, 3, 2, 'OPTIONAL', 'Optional Pool',      2.0);  -- group 82

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(81, (SELECT id FROM modules WHERE module_code='SCT 321-2'), 1),
(81, (SELECT id FROM modules WHERE module_code='SCT 322-3'), 1),
(81, (SELECT id FROM modules WHERE module_code='SCT 323-1'), 1),
(81, (SELECT id FROM modules WHERE module_code='SCT 324-2'), 1),
(81, (SELECT id FROM modules WHERE module_code='SCT 325-2'), 1),
(81, (SELECT id FROM modules WHERE module_code='SCT 326-2'), 1),
(81, (SELECT id FROM modules WHERE module_code='SCT 327-1'), 1),
(81, (SELECT id FROM modules WHERE module_code='SCT 328-3'), 1),
(81, (SELECT id FROM modules WHERE module_code='SCT 303-2'), 1),
(82, (SELECT id FROM modules WHERE module_code='IIT 323-2'), 0),
(82, (SELECT id FROM modules WHERE module_code='SCT 302-2'), 0),
(82, (SELECT id FROM modules WHERE module_code='SCT 331-2'), 0);

-- SCT-FEB Level 400 S1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(5, 4, 1, 'CORE',     'Core Course Units', 15.0),  -- group 83
(5, 4, 1, 'OPTIONAL', 'Optional Pool',      2.0);  -- group 84

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(83, (SELECT id FROM modules WHERE module_code='SCT 411-2'), 1),
(83, (SELECT id FROM modules WHERE module_code='SCT 412-2'), 1),
(83, (SELECT id FROM modules WHERE module_code='SCT 413-2'), 1),
(83, (SELECT id FROM modules WHERE module_code='SCT 414-2'), 1),
(83, (SELECT id FROM modules WHERE module_code='SCT 415-3'), 1),
(83, (SELECT id FROM modules WHERE module_code='SCT 402-2'), 1),
(83, (SELECT id FROM modules WHERE module_code='IIT 446-2'), 1),
(84, (SELECT id FROM modules WHERE module_code='SCT 433-2'), 0),
(84, (SELECT id FROM modules WHERE module_code='SCT 401-2'), 0);

-- SCT-FEB Level 400 S2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(5, 4, 2, 'CORE', 'Core Course Units', 6.0); -- group 85

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(85, (SELECT id FROM modules WHERE module_code='SCT 403-6'), 1),
(85, (SELECT id FROM modules WHERE module_code='SCT 404-6'), 1);


-- ============================================================
-- SCT - MATERIAL SCIENCE AND TECHNOLOGY (MST)
-- Reference: Handbook pp.66-68
-- L100 & L200 identical to FEB. L300 & L400 differ.
-- ============================================================

-- SCT-MST Level 100 and 200 (reuse same logic as FEB, grouped for MST degree_id=6)
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(6, 1, 1, 'ESD',  'ESD & BGE Course Units', 5.0),
(6, 1, 1, 'CORE', 'Core Course Units',      9.0),
(6, 1, 2, 'ESD',  'ESD & BGE Course Units', 6.0),
(6, 1, 2, 'CORE', 'Core Course Units',      8.0),
(6, 2, 1, 'ESD',  'ESD & BGE Course Units', 4.0),
(6, 2, 1, 'CORE', 'Core Course Units',      12.0),
(6, 2, 2, 'BGE',  'BGE Course Units',       2.0),
(6, 2, 2, 'CORE', 'Core Course Units',      14.0);
-- SCT-MST Level 100 and 200: Module mappings for groups 86-93
INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
-- Group 86: SCT-MST L1S1 ESD
(86, (SELECT id FROM modules WHERE module_code='ESD 121-2'), 1),
(86, (SELECT id FROM modules WHERE module_code='ESD 151-1'), 1),
(86, (SELECT id FROM modules WHERE module_code='ESD 161-1'), 1),
(86, (SELECT id FROM modules WHERE module_code='ESD 103-2'), 1),
(86, (SELECT id FROM modules WHERE module_code='BGE 121-2'), 1),
-- Group 87: SCT-MST L1S1 CORE
(87, (SELECT id FROM modules WHERE module_code='SCT 101-1'), 1),
(87, (SELECT id FROM modules WHERE module_code='SCT 121-1'), 1),
(87, (SELECT id FROM modules WHERE module_code='SCT 131-2'), 1),
(87, (SELECT id FROM modules WHERE module_code='SCT 141-1'), 1),
(87, (SELECT id FROM modules WHERE module_code='SCT 142-2'), 1),
(87, (SELECT id FROM modules WHERE module_code='SCT 151-2'), 1),
-- Group 88: SCT-MST L1S2 ESD
(88, (SELECT id FROM modules WHERE module_code='ESD 122-2'), 1),
(88, (SELECT id FROM modules WHERE module_code='ESD 152-1'), 1),
(88, (SELECT id FROM modules WHERE module_code='ESD 162-1'), 1),
(88, (SELECT id FROM modules WHERE module_code='ESD 111-1'), 1),
(88, (SELECT id FROM modules WHERE module_code='ESD 141-2'), 1),
-- Group 89: SCT-MST L1S2 CORE
(89, (SELECT id FROM modules WHERE module_code='SCT 102-2'), 1),
(89, (SELECT id FROM modules WHERE module_code='SCT 132-2'), 1),
(89, (SELECT id FROM modules WHERE module_code='SCT 152-2'), 1),
(89, (SELECT id FROM modules WHERE module_code='SCT 161-1'), 1),
-- Group 90: SCT-MST L2S1 ESD
(90, (SELECT id FROM modules WHERE module_code='ESD 221-2'), 1),
(90, (SELECT id FROM modules WHERE module_code='BGE 211-2'), 1),
-- Group 91: SCT-MST L2S1 CORE
(91, (SELECT id FROM modules WHERE module_code='SCT 201-1'), 1),
(91, (SELECT id FROM modules WHERE module_code='SCT 211-2'), 1),
(91, (SELECT id FROM modules WHERE module_code='SCT 231-2'), 1),
(91, (SELECT id FROM modules WHERE module_code='SCT 251-2'), 1),
(91, (SELECT id FROM modules WHERE module_code='SCT 252-1'), 1),
(91, (SELECT id FROM modules WHERE module_code='SCT 221-1'), 1),
(91, (SELECT id FROM modules WHERE module_code='SCT 222-2'), 1),
(91, (SELECT id FROM modules WHERE module_code='SCT 261-1'), 1),
-- Group 92: SCT-MST L2S2 BGE
(92, (SELECT id FROM modules WHERE module_code='BGE 214-1'), 1),
(92, (SELECT id FROM modules WHERE module_code='BGE 215-1'), 1),
-- Group 93: SCT-MST L2S2 CORE
(93, (SELECT id FROM modules WHERE module_code='SCT 202-3'), 1),
(93, (SELECT id FROM modules WHERE module_code='SCT 232-2'), 1),
(93, (SELECT id FROM modules WHERE module_code='SCT 242-2'), 1),
(93, (SELECT id FROM modules WHERE module_code='SCT 253-1'), 1),
(93, (SELECT id FROM modules WHERE module_code='SCT 212-1'), 1),
(93, (SELECT id FROM modules WHERE module_code='SCT 223-3'), 1),
(93, (SELECT id FROM modules WHERE module_code='SCT 241-2'), 1);

-- SCT-MST Level 300 S1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(6, 3, 1, 'ESD',      'ESD Course Units',    1.0),  -- group 94
(6, 3, 1, 'CORE',     'Core Course Units',  18.0),  -- group 95
(6, 3, 1, 'OPTIONAL', 'Optional Pool',       1.0);  -- group 96

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(94, (SELECT id FROM modules WHERE module_code='ESD 311-1'), 1),
(95, (SELECT id FROM modules WHERE module_code='SCT 341-2'), 1),
(95, (SELECT id FROM modules WHERE module_code='SCT 342-2'), 1),
(95, (SELECT id FROM modules WHERE module_code='SCT 343-2'), 1),
(95, (SELECT id FROM modules WHERE module_code='SCT 344-1'), 1),
(95, (SELECT id FROM modules WHERE module_code='SCT 345-2'), 1),
(95, (SELECT id FROM modules WHERE module_code='SCT 346-2'), 1),
(95, (SELECT id FROM modules WHERE module_code='SCT 347-2'), 1),
(95, (SELECT id FROM modules WHERE module_code='SCT 348-2'), 1),
(95, (SELECT id FROM modules WHERE module_code='SCT 377-2'), 1),
(96, (SELECT id FROM modules WHERE module_code='SCT 361-1'), 0),
(96, (SELECT id FROM modules WHERE module_code='SCT 362-1'), 0),
(96, (SELECT id FROM modules WHERE module_code='SCT 363-1'), 0);

-- SCT-MST Level 300 S2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(6, 3, 2, 'CORE',     'Core Course Units', 17.0),  -- group 97
(6, 3, 2, 'OPTIONAL', 'Optional Pool',      2.0);  -- group 98

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(97, (SELECT id FROM modules WHERE module_code='SCT 351-1'), 1),
(97, (SELECT id FROM modules WHERE module_code='SCT 352-2'), 1),
(97, (SELECT id FROM modules WHERE module_code='SCT 353-2'), 1),
(97, (SELECT id FROM modules WHERE module_code='SCT 354-2'), 1),
(97, (SELECT id FROM modules WHERE module_code='SCT 355-1'), 1),
(97, (SELECT id FROM modules WHERE module_code='SCT 356-2'), 1),
(97, (SELECT id FROM modules WHERE module_code='SCT 357-1'), 1),
(97, (SELECT id FROM modules WHERE module_code='SCT 358-1'), 1),
(97, (SELECT id FROM modules WHERE module_code='SCT 359-1'), 1),
(97, (SELECT id FROM modules WHERE module_code='SCT 301-2'), 1),
(97, (SELECT id FROM modules WHERE module_code='SCT 303-2'), 1),
(98, (SELECT id FROM modules WHERE module_code='IIT 323-2'), 0),
(98, (SELECT id FROM modules WHERE module_code='SCT 302-2'), 0),
(98, (SELECT id FROM modules WHERE module_code='SCT 364-2'), 0);

-- SCT-MST Level 400 S1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(6, 4, 1, 'CORE',         'Core Course Units',                     14.0),  -- group 99
(6, 4, 1, 'OPTIONAL',     'Optional Pool 01 (Faculty Courses)',     2.0),   -- group 100
(6, 4, 1, 'OPTIONAL',     'Optional Pool 02 (Other Faculty)',       2.0);   -- group 101

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(99,  (SELECT id FROM modules WHERE module_code='SCT 441-1'), 1),
(99,  (SELECT id FROM modules WHERE module_code='SCT 442-2'), 1),
(99,  (SELECT id FROM modules WHERE module_code='SCT 443-1'), 1),
(99,  (SELECT id FROM modules WHERE module_code='SCT 444-2'), 1),
(99,  (SELECT id FROM modules WHERE module_code='SCT 445-2'), 1),
(99,  (SELECT id FROM modules WHERE module_code='SCT 446-2'), 1),
(99,  (SELECT id FROM modules WHERE module_code='SCT 402-2'), 1),
(99,  (SELECT id FROM modules WHERE module_code='IIT 446-2'), 1),
(100, (SELECT id FROM modules WHERE module_code='SCT 401-2'), 0),
(100, (SELECT id FROM modules WHERE module_code='SCT 461-1'), 0),
(100, (SELECT id FROM modules WHERE module_code='SCT 462-1'), 0),
(101, (SELECT id FROM modules WHERE module_code='MET 431-1'), 0),
(101, (SELECT id FROM modules WHERE module_code='MET 475-1'), 0),
(101, (SELECT id FROM modules WHERE module_code='PLT 442-2'), 0);

-- SCT-MST Level 400 S2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(6, 4, 2, 'CORE', 'Core Course Units', 6.0); -- group 102

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(102, (SELECT id FROM modules WHERE module_code='SCT 403-6'), 1),
(102, (SELECT id FROM modules WHERE module_code='SCT 404-6'), 1);


-- ============================================================
-- SCT - MECHATRONICS (MEC)
-- Reference: Handbook pp.68-70
-- L100 & L200 identical to FEB/MST.
-- ============================================================

-- SCT-MEC Level 100 and 200 (same structure as FEB)
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(7, 1, 1, 'ESD',  'ESD & BGE Course Units', 5.0),
(7, 1, 1, 'CORE', 'Core Course Units',      9.0),
(7, 1, 2, 'ESD',  'ESD & BGE Course Units', 6.0),
(7, 1, 2, 'CORE', 'Core Course Units',      8.0),
(7, 2, 1, 'ESD',  'ESD & BGE Course Units', 4.0),
(7, 2, 1, 'CORE', 'Core Course Units',      12.0),
(7, 2, 2, 'BGE',  'BGE Course Units',       2.0),
(7, 2, 2, 'CORE', 'Core Course Units',      14.0);

-- SCT-MEC Level 100 and 200: Module mappings for groups 103-110
INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
-- Group 103: SCT-MEC L1S1 ESD
(103, (SELECT id FROM modules WHERE module_code='ESD 121-2'), 1),
(103, (SELECT id FROM modules WHERE module_code='ESD 151-1'), 1),
(103, (SELECT id FROM modules WHERE module_code='ESD 161-1'), 1),
(103, (SELECT id FROM modules WHERE module_code='ESD 103-2'), 1),
(103, (SELECT id FROM modules WHERE module_code='BGE 121-2'), 1),
-- Group 104: SCT-MEC L1S1 CORE
(104, (SELECT id FROM modules WHERE module_code='SCT 101-1'), 1),
(104, (SELECT id FROM modules WHERE module_code='SCT 121-1'), 1),
(104, (SELECT id FROM modules WHERE module_code='SCT 131-2'), 1),
(104, (SELECT id FROM modules WHERE module_code='SCT 141-1'), 1),
(104, (SELECT id FROM modules WHERE module_code='SCT 142-2'), 1),
(104, (SELECT id FROM modules WHERE module_code='SCT 151-2'), 1),
-- Group 105: SCT-MEC L1S2 ESD
(105, (SELECT id FROM modules WHERE module_code='ESD 122-2'), 1),
(105, (SELECT id FROM modules WHERE module_code='ESD 152-1'), 1),
(105, (SELECT id FROM modules WHERE module_code='ESD 162-1'), 1),
(105, (SELECT id FROM modules WHERE module_code='ESD 111-1'), 1),
(105, (SELECT id FROM modules WHERE module_code='ESD 141-2'), 1),
-- Group 106: SCT-MEC L1S2 CORE
(106, (SELECT id FROM modules WHERE module_code='SCT 102-2'), 1),
(106, (SELECT id FROM modules WHERE module_code='SCT 132-2'), 1),
(106, (SELECT id FROM modules WHERE module_code='SCT 152-2'), 1),
(106, (SELECT id FROM modules WHERE module_code='SCT 161-1'), 1),
-- Group 107: SCT-MEC L2S1 ESD
(107, (SELECT id FROM modules WHERE module_code='ESD 221-2'), 1),
(107, (SELECT id FROM modules WHERE module_code='BGE 211-2'), 1),
-- Group 108: SCT-MEC L2S1 CORE
(108, (SELECT id FROM modules WHERE module_code='SCT 201-1'), 1),
(108, (SELECT id FROM modules WHERE module_code='SCT 211-2'), 1),
(108, (SELECT id FROM modules WHERE module_code='SCT 231-2'), 1),
(108, (SELECT id FROM modules WHERE module_code='SCT 251-2'), 1),
(108, (SELECT id FROM modules WHERE module_code='SCT 252-1'), 1),
(108, (SELECT id FROM modules WHERE module_code='SCT 221-1'), 1),
(108, (SELECT id FROM modules WHERE module_code='SCT 222-2'), 1),
(108, (SELECT id FROM modules WHERE module_code='SCT 261-1'), 1),
-- Group 109: SCT-MEC L2S2 BGE
(109, (SELECT id FROM modules WHERE module_code='BGE 214-1'), 1),
(109, (SELECT id FROM modules WHERE module_code='BGE 215-1'), 1),
-- Group 110: SCT-MEC L2S2 CORE
(110, (SELECT id FROM modules WHERE module_code='SCT 202-3'), 1),
(110, (SELECT id FROM modules WHERE module_code='SCT 232-2'), 1),
(110, (SELECT id FROM modules WHERE module_code='SCT 242-2'), 1),
(110, (SELECT id FROM modules WHERE module_code='SCT 253-1'), 1),
(110, (SELECT id FROM modules WHERE module_code='SCT 212-1'), 1),
(110, (SELECT id FROM modules WHERE module_code='SCT 223-3'), 1),
(110, (SELECT id FROM modules WHERE module_code='SCT 241-2'), 1);

-- SCT-MEC Level 300 S1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(7, 3, 1, 'ESD',      'ESD Course Units',    1.0),  -- group 111
(7, 3, 1, 'CORE',     'Core Course Units',  14.0),  -- group 112
(7, 3, 1, 'OPTIONAL', 'Optional Pool',       4.0);  -- group 113

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(111, (SELECT id FROM modules WHERE module_code='ESD 311-1'), 1),
(112, (SELECT id FROM modules WHERE module_code='SCT 371-2'), 1),
(112, (SELECT id FROM modules WHERE module_code='SCT 372-3'), 1),
(112, (SELECT id FROM modules WHERE module_code='SCT 373-2'), 1),
(112, (SELECT id FROM modules WHERE module_code='SCT 374-2'), 1),
(112, (SELECT id FROM modules WHERE module_code='SCT 375-1'), 1),
(112, (SELECT id FROM modules WHERE module_code='SCT 376-1'), 1),
(112, (SELECT id FROM modules WHERE module_code='SCT 377-2'), 1),
(112, (SELECT id FROM modules WHERE module_code='SCT 378-1'), 1),
(112, (SELECT id FROM modules WHERE module_code='SCT 379-1'), 1),
(113, (SELECT id FROM modules WHERE module_code='SCT 391-2'), 0),
(113, (SELECT id FROM modules WHERE module_code='SCT 392-2'), 0),
(113, (SELECT id FROM modules WHERE module_code='SCT 393-2'), 0);

-- SCT-MEC Level 300 S2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(7, 3, 2, 'CORE',     'Core Course Units',  17.0),  -- group 114
(7, 3, 2, 'OPTIONAL', 'Optional Pool',       4.0);  -- group 115

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(114, (SELECT id FROM modules WHERE module_code='SCT 381-2'), 1),
(114, (SELECT id FROM modules WHERE module_code='SCT 382-2'), 1),
(114, (SELECT id FROM modules WHERE module_code='SCT 383-2'), 1),
(114, (SELECT id FROM modules WHERE module_code='SCT 384-2'), 1),
(114, (SELECT id FROM modules WHERE module_code='SCT 385-1'), 1),
(114, (SELECT id FROM modules WHERE module_code='SCT 386-1'), 1),
(114, (SELECT id FROM modules WHERE module_code='SCT 387-2'), 1),
(114, (SELECT id FROM modules WHERE module_code='SCT 388-2'), 1),
(114, (SELECT id FROM modules WHERE module_code='SCT 389-1'), 1),
(114, (SELECT id FROM modules WHERE module_code='SCT 303-2'), 1),
(115, (SELECT id FROM modules WHERE module_code='IIT 323-2'), 0),
(115, (SELECT id FROM modules WHERE module_code='SCT 302-2'), 0),
(115, (SELECT id FROM modules WHERE module_code='SCT 394-2'), 0);

-- SCT-MEC Level 400 S1
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(7, 4, 1, 'CORE',     'Core Course Units',                  17.0),  -- group 116
(7, 4, 1, 'OPTIONAL', 'Optional Pool 01 (Faculty Courses)',  2.0),  -- group 117
(7, 4, 1, 'OPTIONAL', 'Optional Pool 02 (Other Faculty)',   1.0);   -- group 118

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(116, (SELECT id FROM modules WHERE module_code='SCT 471-2'), 1),
(116, (SELECT id FROM modules WHERE module_code='SCT 472-2'), 1),
(116, (SELECT id FROM modules WHERE module_code='SCT 473-2'), 1),
(116, (SELECT id FROM modules WHERE module_code='SCT 474-2'), 1),
(116, (SELECT id FROM modules WHERE module_code='SCT 475-2'), 1),
(116, (SELECT id FROM modules WHERE module_code='SCT 476-2'), 1),
(116, (SELECT id FROM modules WHERE module_code='SCT 477-1'), 1),
(116, (SELECT id FROM modules WHERE module_code='SCT 402-2'), 1),
(116, (SELECT id FROM modules WHERE module_code='IIT 446-2'), 1),
(117, (SELECT id FROM modules WHERE module_code='SCT 401-2'), 0),
(117, (SELECT id FROM modules WHERE module_code='SCT 491-2'), 0),
(117, (SELECT id FROM modules WHERE module_code='SCT 492-2'), 0),
(118, (SELECT id FROM modules WHERE module_code='MET 431-1'), 0),
(118, (SELECT id FROM modules WHERE module_code='MET 475-1'), 0);

-- SCT-MEC Level 400 S2
INSERT INTO curriculum_groups (degree_id, academic_year, semester, group_type, group_name, min_credits_required) VALUES
(7, 4, 2, 'CORE', 'Core Course Units', 6.0); -- group 119

INSERT INTO curriculum_modules (group_id, module_id, is_mandatory) VALUES
(119, (SELECT id FROM modules WHERE module_code='SCT 403-6'), 1),
(119, (SELECT id FROM modules WHERE module_code='SCT 404-6'), 1);


-- ============================================================
-- GRADE POINT VALUES REFERENCE
-- A+: 4.00 | A: 4.00 | A-: 3.70 | B+: 3.30 | B: 3.00 | B-: 2.70
-- C+: 2.30 | C: 2.00 | C-: 1.70 | D+: 1.30 | D: 1.00 | E: 0.00
-- ============================================================

-- ============================================================
-- DEGREE CLASS THRESHOLDS (for GPA Calculator module)
-- First Class Honours:              FGPA >= 3.70
-- Second Class (Upper Division):    FGPA >= 3.30
-- Second Class (Lower Division):    FGPA >= 3.00
-- General Pass:                     FGPA >= 2.00
-- ============================================================
