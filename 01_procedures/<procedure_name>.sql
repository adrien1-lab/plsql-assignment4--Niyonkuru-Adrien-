--SP_RECORD_GRADES_BULK

CREATE OR REPLACE PROCEDURE sp_record_grades_bulk (
    p_grades IN reg_types.t_grade_upload_tab   -- nested table of (enroll_id, score)
)
IS
    -- ORA-24381 = error(s) raised inside a FORALL ... SAVE EXCEPTIONS loop.
    -- The pragma lets us catch it as a named exception.
    e_bulk_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);

    v_applied  PLS_INTEGER;
    v_detail   VARCHAR2(2000);
BEGIN
    ------------------------------------------------------------------
    -- 1. An empty (or NULL) collection is a caller mistake, not success.
    ------------------------------------------------------------------
    IF p_grades IS NULL OR p_grades.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20045,
            'The grade-upload batch is empty. Provide at least one ' ||
            '(enroll_id, score) row.');
    END IF;


--DML statement for the WHOLE batch
FORALL i IN p_grades.FIRST .. p_grades.LAST SAVE EXCEPTIONS
        UPDATE enrollments
        SET    score = p_grades(i).score,
               grade = fn_calculate_grade(p_grades(i).score)
        WHERE  enroll_id = p_grades(i).enroll_id;

    v_applied := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Bulk upload applied to ' || v_applied ||
                         ' enrollment(s):');
    FOR i IN p_grades.FIRST .. p_grades.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(
            '  enroll_id ' || p_grades(i).enroll_id || ' -> score ' ||
            p_grades(i).score || ' (' || fn_calculate_grade(p_grades(i).score) || ')');
    END LOOP;
    COMMIT;
--EXCEPTION
 WHEN e_bulk_errors THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(
            'Bulk upload FAILED - ' || SQL%BULK_EXCEPTIONS.COUNT ||
            ' row(s) invalid. All changes were rolled back.');
        FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
            v_detail :=
                'Batch row ' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX ||
                ' (enroll_id ' ||
                p_grades(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX).enroll_id ||
                '): ' || SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE);
            DBMS_OUTPUT.PUT_LINE('  - ' || v_detail);
        END LOOP;
        RAISE_APPLICATION_ERROR(
            -20044,
            'Grade upload rejected: ' || SQL%BULK_EXCEPTIONS.COUNT ||
            ' row(s) failed (see output above). No grades were changed.');

    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Unexpected error in SP_RECORD_GRADES_BULK: ' || SQLERRM);
        RAISE;
END sp_record_grades_bulk;
/
