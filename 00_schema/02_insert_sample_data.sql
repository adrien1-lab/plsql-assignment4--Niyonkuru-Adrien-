-- Rerun-safe: clear the tables first (child tables before parents).
DELETE FROM enrollments;
DELETE FROM students;
DELETE FROM courses;
DELETE FROM departments;


-- DEPARTMENTS

INSERT INTO departments (dept_id, dept_name, dept_head, office) VALUES (1, 'Computer Science',        'Dr. Alice Mutoni',   'Block A, Room 201');
INSERT INTO departments (dept_id, dept_name, dept_head, office) VALUES (2, 'Information Technology',  'Dr. Bernard Nziza',  'Block A, Room 204');
INSERT INTO departments (dept_id, dept_name, dept_head, office) VALUES (3, 'Business Administration', 'Dr. Carine Uwase',   'Block B, Room 110');
INSERT INTO departments (dept_id, dept_name, dept_head, office) VALUES (4, 'Nursing',                 'Dr. Daniel Bizimana','Block C, Room 305');


-- STUDENTS  (12 students; 7 and 9 share a full name on purpose)

INSERT INTO students (student_id, full_name, email, dept_id, enrollment_date, status) VALUES (1,  'Jean Pierre Habimana',  'jp.habimana@auca.ac.rw',    1, DATE '2024-08-26', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, dept_id, enrollment_date, status) VALUES (2,  'Aline Uwase',           'a.uwase1@auca.ac.rw',       1, DATE '2024-08-26', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, dept_id, enrollment_date, status) VALUES (3,  'Eric Nshimiyimana',     'e.nshimiyimana@auca.ac.rw', 1, DATE '2024-08-26', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, dept_id, enrollment_date, status) VALUES (4,  'Claudine Mukamana',     'c.mukamana@auca.ac.rw',     2, DATE '2024-08-27', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, dept_id, enrollment_date, status) VALUES (5,  'Thierry Kagabo',        't.kagabo@auca.ac.rw',       1, DATE '2024-08-27', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, dept_id, enrollment_date, status) VALUES (6,  'Sandrine Nyirahabimana','s.nyirahabimana@auca.ac.rw',2, DATE '2024-08-28', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, dept_id, enrollment_date, status) VALUES (7,  'Patrick Mugisha',       'p.mugisha@auca.ac.rw',      3, DATE '2025-08-25', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, dept_id, enrollment_date, status) VALUES (8,  'Josiane Ingabire',      'j.ingabire@auca.ac.rw',     3, DATE '2025-08-25', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, dept_id, enrollment_date, status) VALUES (9,  'Aline Uwase',           'a.uwase2@auca.ac.rw',       4, DATE '2025-08-26', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, dept_id, enrollment_date, status) VALUES (10, 'Emmanuel Nkurunziza',   'e.nkurunziza@auca.ac.rw',   4, DATE '2025-08-26', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, dept_id, enrollment_date, status) VALUES (11, 'Diane Uwamariya',       'd.uwamariya@auca.ac.rw',    2, DATE '2025-08-27', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, dept_id, enrollment_date, status) VALUES (12, 'Fabrice Habinshuti',    'f.habinshuti@auca.ac.rw',   1, DATE '2023-08-28', 'GRADUATED');

-- COURSES  (7 courses; course 1 mirrors the real INSY-8311 course)

INSERT INTO courses (course_id, course_code, title, credits, capacity, dept_id) VALUES (1, 'INSY-8311', 'Database Development with PL/SQL',  3, 40, 1);
INSERT INTO courses (course_id, course_code, title, credits, capacity, dept_id) VALUES (2, 'INSY-8302', 'Advanced Database Administration',  3, 35, 1);
INSERT INTO courses (course_id, course_code, title, credits, capacity, dept_id) VALUES (3, 'INSY-8405', 'Web Application Development',       3, 30, 1);
INSERT INTO courses (course_id, course_code, title, credits, capacity, dept_id) VALUES (4, 'NET-2201',  'Computer Networks Fundamentals',    4, 45, 2);
INSERT INTO courses (course_id, course_code, title, credits, capacity, dept_id) VALUES (5, 'BUS-1101',  'Principles of Management',          3, 60, 3);
INSERT INTO courses (course_id, course_code, title, credits, capacity, dept_id) VALUES (6, 'NUR-2103',  'Human Anatomy and Physiology',      4, 50, 4);
INSERT INTO courses (course_id, course_code, title, credits, capacity, dept_id) VALUES (7, 'INSY-8201',  'Data Structures and Algorithms',    4, 38, 1);


-- ENROLLMENTS  (18 rows, semester 2026-FALL)
-- score/grade NULL = not yet graded (these are the bulk-upload demo rows)
--
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (1,  1,  1, '2026-FALL', 95,   'A',  DATE '2026-09-05');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (2,  2,  1, '2026-FALL', 87,   'B+', DATE '2026-09-05');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (3,  3,  1, '2026-FALL', 42,   'F',  DATE '2026-09-06');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (4,  4,  1, '2026-FALL', 82,   'B',  DATE '2026-09-06');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (5,  1,  2, '2026-FALL', 87,   'B+', DATE '2026-09-07');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (6,  3,  2, '2026-FALL', 38,   'F',  DATE '2026-09-07');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (7,  5,  2, '2026-FALL', 76,   'C+', DATE '2026-09-08');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (8,  2,  3, '2026-FALL', NULL, NULL, DATE '2026-09-08');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (9,  5,  3, '2026-FALL', NULL, NULL, DATE '2026-09-09');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (10, 6,  3, '2026-FALL', 84,   'B',  DATE '2026-09-09');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (11, 3,  4, '2026-FALL', 45,   'F',  DATE '2026-09-10');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (12, 7,  4, '2026-FALL', 70,   'C',  DATE '2026-09-10');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (13, 8,  5, '2026-FALL', 93,   'A',  DATE '2026-09-11');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (14, 9,  5, '2026-FALL', NULL, NULL, DATE '2026-09-11');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (15, 10, 6, '2026-FALL', 60,   'D',  DATE '2026-09-12');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (16, 4,  7, '2026-FALL', 86,   'B+', DATE '2026-09-12');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (17, 11, 7, '2026-FALL', NULL, NULL, DATE '2026-09-13');
INSERT INTO enrollments (enroll_id, student_id, course_id, semester, score, grade, enrolled_on) VALUES (18, 12, 1, '2026-FALL', 88,   'B+', DATE '2026-09-13');

COMMIT;

--

SELECT COUNT(*) AS departments  FROM departments;
SELECT COUNT(*) AS students     FROM students;
SELECT COUNT(*) AS courses      FROM courses;
SELECT COUNT(*) AS enrollments  FROM enrollments;

