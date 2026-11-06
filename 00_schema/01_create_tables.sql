--SQL
DROP TABLE enrollments CASCADE CONSTRAINTS PURGE;
DROP TABLE courses      CASCADE CONSTRAINTS PURGE;
DROP TABLE students     CASCADE CONSTRAINTS PURGE;
DROP TABLE departments  CASCADE CONSTRAINTS PURGE;

DROP SEQUENCE seq_departments;
DROP SEQUENCE seq_students;
DROP SEQUENCE seq_courses;
DROP SEQUENCE seq_enrollments;

-- DEPARTMENTS  : academic departments of the university

CREATE TABLE departments (
    dept_id     NUMBER(4)      CONSTRAINT pk_departments PRIMARY KEY,
    dept_name   VARCHAR2(60)   CONSTRAINT nn_dept_name  NOT NULL,
    dept_head   VARCHAR2(80),
    office      VARCHAR2(40),
    CONSTRAINT uq_departments_name UNIQUE (dept_name)
);

-- STUDENTS  : registered students; every student belongs to one department

CREATE TABLE students (
    student_id      NUMBER(6)     CONSTRAINT pk_students PRIMARY KEY,
    full_name       VARCHAR2(100) CONSTRAINT nn_stu_name  NOT NULL,
    email           VARCHAR2(120) CONSTRAINT nn_stu_email NOT NULL,
    dept_id         NUMBER(4)     CONSTRAINT nn_stu_dept  NOT NULL,
    enrollment_date DATE          CONSTRAINT nn_stu_edate NOT NULL,
    status          VARCHAR2(12)  DEFAULT 'ACTIVE' CONSTRAINT nn_stu_status NOT NULL,
    CONSTRAINT uq_students_email UNIQUE (email),
    CONSTRAINT fk_students_dept  FOREIGN KEY (dept_id) REFERENCES departments (dept_id),
    CONSTRAINT ck_students_status CHECK (status IN ('ACTIVE', 'PROBATION', 'GRADUATED', 'WITHDRAWN'))
);


-- COURSES  : courses offered; every course belongs to one department

CREATE TABLE courses (
    course_id   NUMBER(6)     CONSTRAINT pk_courses PRIMARY KEY,
    course_code VARCHAR2(12)  CONSTRAINT nn_crs_code  NOT NULL,
    title       VARCHAR2(120) CONSTRAINT nn_crs_title NOT NULL,
    credits     NUMBER(2)     CONSTRAINT nn_crs_credits NOT NULL,
    capacity    NUMBER(3)     CONSTRAINT nn_crs_capacity NOT NULL,
    dept_id     NUMBER(4)     CONSTRAINT nn_crs_dept  NOT NULL,
    CONSTRAINT uq_courses_code   UNIQUE (course_code),
    CONSTRAINT ck_courses_credits  CHECK (credits  BETWEEN 1 AND 6),
    CONSTRAINT ck_courses_capacity CHECK (capacity > 0),
    CONSTRAINT fk_courses_dept     FOREIGN KEY (dept_id) REFERENCES departments (dept_id)
);
-- DEPARTMENTS  : academic departments of the university

CREATE TABLE departments (
    dept_id     NUMBER(4)      CONSTRAINT pk_departments PRIMARY KEY,
    dept_name   VARCHAR2(60)   CONSTRAINT nn_dept_name  NOT NULL,
    dept_head   VARCHAR2(80),
    office      VARCHAR2(40),
    CONSTRAINT uq_departments_name UNIQUE (dept_name)
);


-- STUDENTS  : registered students; every student belongs to one department

CREATE TABLE students (
    student_id      NUMBER(6)     CONSTRAINT pk_students PRIMARY KEY,
    full_name       VARCHAR2(100) CONSTRAINT nn_stu_name  NOT NULL,
    email           VARCHAR2(120) CONSTRAINT nn_stu_email NOT NULL,
    dept_id         NUMBER(4)     CONSTRAINT nn_stu_dept  NOT NULL,
    enrollment_date DATE          CONSTRAINT nn_stu_edate NOT NULL,
    status          VARCHAR2(12)  DEFAULT 'ACTIVE' CONSTRAINT nn_stu_status NOT NULL,
    CONSTRAINT uq_students_email UNIQUE (email),
    CONSTRAINT fk_students_dept  FOREIGN KEY (dept_id) REFERENCES departments (dept_id),
    CONSTRAINT ck_students_status CHECK (status IN ('ACTIVE', 'PROBATION', 'GRADUATED', 'WITHDRAWN'))
);


CREATE TABLE courses (
    course_id   NUMBER(6)     CONSTRAINT pk_courses PRIMARY KEY,
    course_code VARCHAR2(12)  CONSTRAINT nn_crs_code  NOT NULL,
    title       VARCHAR2(120) CONSTRAINT nn_crs_title NOT NULL,
    credits     NUMBER(2)     CONSTRAINT nn_crs_credits NOT NULL,
    capacity    NUMBER(3)     CONSTRAINT nn_crs_capacity NOT NULL,
    dept_id     NUMBER(4)     CONSTRAINT nn_crs_dept  NOT NULL,
    CONSTRAINT uq_courses_code   UNIQUE (course_code),
    CONSTRAINT ck_courses_credits  CHECK (credits  BETWEEN 1 AND 6),
    CONSTRAINT ck_courses_capacity CHECK (capacity > 0),
    CONSTRAINT fk_courses_dept     FOREIGN KEY (dept_id) REFERENCES departments (dept_id)
);


CREATE TABLE enrollments (
    enroll_id    NUMBER(8)    CONSTRAINT pk_enrollments PRIMARY KEY,
    student_id   NUMBER(6)    CONSTRAINT nn_enr_student NOT NULL,
    course_id    NUMBER(6)    CONSTRAINT nn_enr_course  NOT NULL,
    semester     VARCHAR2(11) CONSTRAINT nn_enr_semester NOT NULL,
    score        NUMBER(5,2),
    grade        VARCHAR2(2),
    enrolled_on  DATE         DEFAULT SYSDATE CONSTRAINT nn_enr_edate NOT NULL,
    CONSTRAINT uq_enrollments UNIQUE (student_id, course_id, semester),
    CONSTRAINT fk_enr_student FOREIGN KEY (student_id) REFERENCES students (student_id),
    CONSTRAINT fk_enr_course  FOREIGN KEY (course_id)  REFERENCES courses (course_id),
    CONSTRAINT ck_enr_semester CHECK (REGEXP_LIKE(semester, '^[0-9]{4}-(FALL|SPRING)$')),
    CONSTRAINT ck_enr_score    CHECK (score IS NULL OR score BETWEEN 0 AND 100),
    CONSTRAINT ck_enr_grade    CHECK (grade IS NULL OR grade IN ('A','B+','B','C+','C','D','F'))
);


--
CREATE SEQUENCE seq_departments  START WITH 10   INCREMENT BY 1;
CREATE SEQUENCE seq_students     START WITH 100  INCREMENT BY 1;
CREATE SEQUENCE seq_courses      START WITH 100  INCREMENT BY 1;
CREATE SEQUENCE seq_enrollments  START WITH 1000 INCREMENT BY 1;
