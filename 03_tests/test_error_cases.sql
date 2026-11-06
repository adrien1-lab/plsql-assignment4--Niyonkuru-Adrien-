--
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 140
SET PAGESIZE 200
SET FEEDBACK ON


-- Rerun-safe: remove leftovers from any previous test run first.
BEGIN
    DELETE FROM enrollments
    WHERE  student_id IN (SELECT student_id FROM students WHERE full_name LIKE 'TEST %');
    DELETE FROM enrollments
    WHERE  course_id IN (SELECT course_id FROM courses WHERE course_code LIKE 'TST-%');
    DELETE FROM courses    WHERE course_code LIKE 'TST-%';
    DELETE FROM students   WHERE full_name LIKE 'TEST %';
    COMMIT;
END;
/


BEGIN
    sp_register_student('TEST Dup Person', 'jp.habimana@auca.ac.rw', 1);
    DBMS_OUTPUT.PUT_LINE('E01 FAIL - no error was raised!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('E01 PASS - caught: ' || SQLERRM);
END;
/


BEGIN
    sp_enroll_student(99999, 1, '2026-FALL');
    DBMS_OUTPUT.PUT_LINE('E02 FAIL - no error was raised!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('E02 PASS - caught: ' || SQLERRM);
END;
/


BEGIN
    sp_enroll_student(1, 99999, '2026-FALL');
    DBMS_OUTPUT.PUT_LINE('E03 FAIL - no error was raised!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('E03 PASS - caught: ' || SQLERRM);
END;
/


DECLARE
    v_email_a   VARCHAR2(120);
    v_id_a      students.student_id%TYPE;
    v_course_id courses.course_id%TYPE;
BEGIN
    -- Setup: create a temporary 1-seat course and fill its only seat.
    INSERT INTO courses (course_id, course_code, title, credits, capacity, dept_id)
    VALUES (seq_courses.NEXTVAL, 'TST-100', 'Tiny Capacity Test Course', 1, 1, 1);
    COMMIT;

    v_email_a := 'test.carl.' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '@auca.ac.rw';
    sp_register_student('TEST Carl Ndoli', v_email_a, 1);

    SELECT student_id  INTO v_id_a
    FROM   students
    WHERE  email = v_email_a;

    SELECT course_id   INTO v_course_id
    FROM   courses
    WHERE  course_code = 'TST-100';

    -- The FIRST student takes the single seat (this call must SUCCEED).
    sp_enroll_student(v_id_a, v_course_id, '2026-FALL');
    DBMS_OUTPUT.PUT_LINE('E04 setup OK - the only seat of TST-100 is now taken.');
END;
/

DECLARE
    v_email_b   VARCHAR2(120);
    v_id_b      students.student_id%TYPE;
    v_course_id courses.course_id%TYPE;
BEGIN
    SELECT course_id INTO v_course_id
    FROM   courses
    WHERE  course_code = 'TST-100';

    -- The SECOND student must be rejected because the course is now full.
    v_email_b := 'test.dana.' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '@auca.ac.rw';
    sp_register_student('TEST Dana Uwimana', v_email_b, 2);

    SELECT student_id INTO v_id_b
    FROM   students
    WHERE  email = v_email_b;

    sp_enroll_student(v_id_b, v_course_id, '2026-FALL');
    DBMS_OUTPUT.PUT_LINE('E04 FAIL - no error was raised!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('E04 PASS - caught: ' || SQLERRM);
END;
