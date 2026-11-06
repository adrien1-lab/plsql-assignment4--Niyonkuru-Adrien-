--
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 140
SET PAGESIZE 200
SET FEEDBACK ON



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
    sp_register_student(
        p_full_name => 'TEST Anita Mukamana',
        p_email     => 'test.anita.' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '@auca.ac.rw',
        p_dept_id   => 2);
    DBMS_OUTPUT.PUT_LINE('T01 PASS');
END;
/


DECLARE
    v_left NUMBER;
BEGIN
    v_left := fn_course_seats_left(3, '2026-FALL');
    DBMS_OUTPUT.PUT_LINE('Seats left in course 3: ' || v_left || '  (expected 27)');
    DBMS_OUTPUT.PUT_LINE('T02 PASS');
END;
/


DECLARE
    v_id students.student_id%TYPE;
BEGIN
    SELECT student_id INTO v_id
    FROM   students
    WHERE  full_name = 'TEST Anita Mukamana';

    sp_enroll_student(v_id, 3, '2026-FALL');
    DBMS_OUTPUT.PUT_LINE('T03 PASS');
END;
/


BEGIN
    DBMS_OUTPUT.PUT_LINE('95 -> ' || fn_calculate_grade(95) || '  (expected A)');
    DBMS_OUTPUT.PUT_LINE('87 -> ' || fn_calculate_grade(87) || '  (expected B+)');
    DBMS_OUTPUT.PUT_LINE('45 -> ' || fn_calculate_grade(45) || '  (expected F)');
    DBMS_OUTPUT.PUT_LINE('T04 PASS');
END;
/


DECLARE
    v_map reg_types.t_points_map;
    v_key VARCHAR2(2);
BEGIN
    DBMS_OUTPUT.PUT_LINE('GPA of student 1: ' || fn_get_gpa(1) || '  (expected 3.75)');

    DBMS_OUTPUT.PUT_LINE('Grade-point scale (associative array walk):');
    v_map := reg_types.get_points_map();
    v_key := v_map.FIRST;
    WHILE v_key IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE('   ' || v_key || ' = ' || v_map(v_key));
        v_key := v_map.NEXT(v_key);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('T05 PASS');
END;
/


DECLARE
    v_id    students.student_id%TYPE;
    v_email students.email%TYPE;
BEGIN
    sp_get_student_by_name('Jean Pierre Habimana', v_id, v_email);
    DBMS_OUTPUT.PUT_LINE('T06 PASS');
END;
/


DECLARE
    v_batch reg_types.t_grade_upload_tab := reg_types.t_grade_upload_tab();
BEGIN
    v_batch.EXTEND(2);
    v_batch(1).enroll_id := 8;
    v_batch(1).score     := 72;
    v_batch(2).enroll_id := 9;
    v_batch(2).score     := 65;

    sp_record_grades_bulk(v_batch);

    DBMS_OUTPUT.PUT_LINE('Verification (expected 72/C and 65/D):');
    FOR r IN (SELECT enroll_id, score, grade FROM enrollments
              WHERE enroll_id IN (8, 9) ORDER BY enroll_id) LOOP
        DBMS_OUTPUT.PUT_LINE('   enroll_id ' || r.enroll_id || ' -> ' ||
                             r.score || ' / ' || r.grade);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('T07 PASS');
END;
/


BEGIN
    sp_show_course_roster(1, '2026-FALL');
    DBMS_OUTPUT.PUT_LINE('T08 PASS');
END;
/


BEGIN
    sp_course_grade_distribution(1, '2026-FALL');
    DBMS_OUTPUT.PUT_LINE('T09 PASS');
END;
/

DECLARE
    v_avg NUMBER;
BEGIN
    v_avg := fn_course_average(1, '2026-FALL');
    DBMS_OUTPUT.PUT_LINE('Average score of course 1: ' || v_avg || '  (expected 78.8)');
    DBMS_OUTPUT.PUT_LINE('T10 PASS');
END;
/


DECLARE
    v_rec reg_types.t_student_rec;
BEGIN
    v_rec := fn_get_student_summary(1);
    DBMS_OUTPUT.PUT_LINE('Summary of student 1: ' || v_rec.full_name || ' / ' ||
                         v_rec.email || ' / ' || v_rec.dept_name || ' / ' ||
                         v_rec.status || ' / enrolled ' || v_rec.enrollment_date);
    DBMS_OUTPUT.PUT_LINE('T11 PASS');
END;
/


DECLARE
    v_email VARCHAR2(120);
    v_id    students.student_id%TYPE;
BEGIN
    v_email := 'test.bruce.' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '@auca.ac.rw';
    sp_register_student('TEST Bruce Ndayisaba', v_email, 1);

    SELECT student_id INTO v_id
    FROM   students
    WHERE  email = v_email;

    sp_transfer_student(v_id, 3);
    DBMS_OUTPUT.PUT_LINE('T12 PASS');
END;
/


BEGIN
    sp_flag_academic_warning('2026-FALL', 2);
    DBMS_OUTPUT.PUT_LINE('Verification (expected status=PROBATION for id 3):');
    FOR r IN (SELECT student_id, full_name, status FROM students
              WHERE student_id = 3) LOOP
        DBMS_OUTPUT.PUT_LINE('   ' || r.student_id || ' ' || r.full_name ||
                             ' -> ' || r.status);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('T13 PASS');
END;
/


DECLARE
    v_id       students.student_id%TYPE;
    v_enroll_id enrollments.enroll_id%TYPE;
    v_left     NUMBER;
BEGIN
    SELECT student_id INTO v_id
    FROM   students
    WHERE  full_name = 'TEST Anita Mukamana';

    SELECT enroll_id INTO v_enroll_id
    FROM   enrollments
    WHERE  student_id = v_id
    AND    course_id  = 3
    AND    semester   = '2026-FALL';

    sp_withdraw_enrollment(v_enroll_id);

    v_left := fn_course_seats_left(3, '2026-FALL');
    DBMS_OUTPUT.PUT_LINE('Seats left after withdrawal: ' || v_left || '  (expected 27)');
    DBMS_OUTPUT.PUT_LINE('T14 PASS');
END;
/
