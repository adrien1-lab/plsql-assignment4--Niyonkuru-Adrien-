# plsql-assignment4--Niyonkuru-Adrien-

# Assignment IV — Records & Collections in Oracle PL/SQL
## Student Registration & Grading System

**Course:** Database Development with PL/SQL (INSY 8311) — AUCA
**Instructor:** Eric Maniraguha · **Teaching Assistant:** Afanyu Emmanuel


---

## 1. Team

| Role | Niyonkuru Adrien | 29169 |


> The assignment default is groups of two; the lecturer approved this submission as **individual work**.


---

## 2. Application description

The application is a **Student Registration & Grading System** for one university semester
(here: `2026-FALL`). It models the academic core of a registrar's office:

* **departments** offer **courses**; **students** belong to a department;
* a student **enrolls** in a course for a semester (the `enrollments` bridge table),
  and later receives a numeric **score** and a letter **grade**.

Business logic is implemented in stored PL/SQL — not in client code:

* register new students (duplicate e-mails rejected);
* enroll students (course capacity, duplicate enrollment and inactive students checked);
* withdraw enrollments and transfer students between departments;
* **bulk-upload a batch of scores in one FORALL statement** (atomic: all rows or none);
* flag students with repeated failures to academic **PROBATION** automatically;
* compute **GPA**, seat availability, class rosters and grade distributions.

Every subprogram validates its input, gives **meaningful error messages**
(`RAISE_APPLICATION_ERROR` codes `-20001 … -20047`) and never silently swallows errors.
The full error-code registry is in (docs/IMPLEMENTATION_NOTES.md).

---

## 3. Repository structure

```
plsql-assignment4-<StudentID>/
├── README.md                      # this file
├── .gitignore
├── 00_schema/
│   ├── 01_create_tables.sql       # tables, relationships, constraints, sequences
│   ├── 02_insert_sample_data.sql  # realistic sample data (4/12/7/18 rows)
│   └── 03_create_common_types.sql # REG_TYPES: shared RECORD + COLLECTION types
├── 01_procedures/                 # one file per stored procedure (9 procedures)
├── 02_functions/                  # one file per stored function (5 functions)
├── 03_tests/
│   ├── test_success_cases.sql     # T01–T14 happy-path tests
│   └── test_error_cases.sql       # E01–E11 exception-handling tests
├── screenshots/                   # <test_name>_output.png (see docs/SCREENSHOT_GUIDE.md)
└── docs/
    ├── IMPLEMENTATION_NOTES.md    # implementation + performance explanation
    ├── SCREENSHOT_GUIDE.md        # exactly what to capture and how to name it
    └── GITHUB_PUSH_GUIDE.md       # how to create the repo and push this folder
```

---

## 4. Requirements coverage map

| # | Requirement | Implemented in | Demonstrated in |
|---|-------------|----------------|-----------------|
| 1 | Records: user-defined **and** %ROWTYPE | `reg_types` (t_student_rec, t_grade_upload_rec, t_roster_rec); `sp_register_student` (record processing); `sp_transfer_student`, `sp_show_course_roster`, `sp_course_grade_distribution`, `sp_withdraw_enrollment` (%ROWTYPE rows); `fn_get_student_summary` (returns a record) | T01, T08, T11 |
| 2 | Collections: associative array, nested table, VARRAY | `reg_types` (t_points_map / t_count_map INDEX BY, t_student_tab / t_grade_upload_tab / t_roster_tab / t_num_tab nested tables, t_grade_varray VARRAY(8)); `sp_record_grades_bulk`, `sp_flag_academic_warning`, `sp_show_course_roster`, `sp_course_grade_distribution`, `fn_get_gpa` | T05, T07, T08, T09, T13 |
| 3 | Implicit cursors + SQL%ROWCOUNT / SQL%FOUND / SQL%NOTFOUND | INSERT: `sp_register_student`, `sp_enroll_student`; UPDATE: `sp_transfer_student`, `sp_record_grades_bulk`, `sp_flag_academic_warning`; DELETE: `sp_withdraw_enrollment` (SQL%NOTFOUND) | T01, T03, T07, T12, T13, T14, E07 |
| 4 | Explicit cursors: OPEN/FETCH/CLOSE **and** cursor FOR loop | `sp_show_course_roster` (OPEN + BULK FETCH LIMIT + CLOSE), `fn_get_gpa` and `sp_course_grade_distribution` (cursor FOR loops) | T05, T08, T09 |
| 5 | Bulk processing: BULK COLLECT + FORALL (+ bulk DML errors) | `sp_flag_academic_warning` (BULK COLLECT → FORALL), `sp_record_grades_bulk` (FORALL … SAVE EXCEPTIONS + SQL%BULK_EXCEPTIONS), `sp_show_course_roster` (FETCH BULK COLLECT LIMIT) | T07, T13, E06 |
| 6 | Stored procedures (IN/OUT params, integrated concepts) | 9 procedures in `01_procedures/` | T01–T03, T06–T09, T12–T14 |
| 7 | Stored functions (called from PL/SQL and SQL) | 5 functions in `02_functions/` | T02, T04, T05, T10, T11 |
| 8 | Exception handling (predefined, user-defined, RAISE_APPLICATION_ERROR) | every block; NO_DATA_FOUND, TOO_MANY_ROWS, DUP_VAL_ON_INDEX; 12 user-defined exceptions; codes -20001…-20047 | E01–E11 |

---



## 5. AI use disclosure 

> **AI assistance:** an AI assistant (Z.ai GLM) was used to help draft the initial code.
