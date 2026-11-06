# Implementation & Performance Notes

Assignment IV — Records, Collections, Cursors, Bulk Processing, Stored Procedures,
Functions and Exception Handling.
Application: **Student Registration & Grading System** (semester `2026-FALL`).

---

## 1. Overview and design decisions

The registrar-style model uses four tables:

| Table | Purpose | Key relationships / constraints |
|-------|---------|---------------------------------|
| `departments` | academic departments | PK, unique `dept_name` |
| `students` | registered students | FK → departments; unique `email`; `status` CHECK (ACTIVE/PROBATION/GRADUATED/WITHDRAWN) |
| `courses` | offered courses | FK → departments; unique `course_code`; `credits` and `capacity` CHECKs |
| `enrollments` | bridge student ↔ course per semester | PK; **UNIQUE (student_id, course_id, semester)**; FKs to students & courses; `semester` format CHECK (`^[0-9]{4}-(FALL|SPRING)$`), `score` 0–100 CHECK, `grade` in ('A','B+','B','C+','C','D','F') CHECK |

Two deliberate design choices:

1. **Sequence-generated keys.** Sample data is inserted with explicit ids (1–12 for
   students, 1–18 for enrollments) so tests are deterministic; the sequences used by the
   procedures start **above** those ids (`seq_students` at 100, `seq_enrollments` at 1000),
   so runtime-created rows can never collide with the seeded rows.
2. **A shared types package (`reg_types`).** All record/collection types are declared once
   in a package spec, so every procedure and function uses identical structures. This also
   allows collections of records to be passed as parameters between subprograms.

Business rules live in the PL/SQL layer (procedures), not only in table constraints, so
users get *readable* errors instead of raw constraint names; constraints remain as the
final safety net (e.g. `uq_enrollments` catches concurrent duplicate enrollments in
`sp_enroll_student` via `DUP_VAL_ON_INDEX`).

---

## 2. Records (requirement 1)

* **User-defined records** (`reg_types`): `t_student_rec` (full student summary),
  `t_grade_upload_rec` (one score-upload row), `t_roster_rec` (one roster line).
* `sp_register_student` builds a `t_student_rec` for the new student and inserts the
  columns from that record; `fn_get_student_summary` **returns** a whole record value;
  `sp_record_grades_bulk` receives a **collection of records** as its IN parameter.
* **`%ROWTYPE`**: `sp_transfer_student` (`students%ROWTYPE`), `sp_show_course_roster` and
  `sp_course_grade_distribution` (`courses%ROWTYPE`), and `sp_withdraw_enrollment`
  (`enrollments%ROWTYPE`) fetch entire rows with `SELECT * INTO`. `%ROWTYPE` keeps those
  variables automatically aligned with the table if a column is ever added.

---

## 3. Collections (requirement 2) — three kinds, used where each fits best

| Collection type (in `reg_types`) | Kind | Used by | Why this kind |
|----------------------------------|------|---------|---------------|
| `t_points_map`, `t_count_map` | **Associative array** (`INDEX BY VARCHAR2(2)`) | `fn_get_gpa` (letter → points lookups with `EXISTS`), `sp_course_grade_distribution` | String-keyed sparse lookups; no `EXTEND` needed; traversed with `FIRST`/`NEXT` in test T05 |
| `t_student_tab`, `t_grade_upload_tab`, `t_roster_tab`, `t_num_tab` | **Nested table** (`TABLE OF …`) | `sp_record_grades_bulk` (FORALL driver), `sp_flag_academic_warning` (BULK COLLECT target), `sp_show_course_roster` (batched fetch) | Unbounded, constructor + `EXTEND`, can be passed as a parameter — ideal for bulk DML |
| `t_grade_varray` | **VARRAY(8)** | `sp_course_grade_distribution` | The grade scale has a fixed maximum size and a fixed order — exactly what a VARRAY guarantees; it drives the ordered distribution report |

---

## 4. Implicit and explicit cursors (requirements 3 & 4)

**Implicit cursors** — one statement, cursor attributes read immediately after:

| Statement | Procedure | Attributes used |
|-----------|-----------|-----------------|
| INSERT | `sp_register_student`, `sp_enroll_student` (+ `RETURNING` clause) | `SQL%FOUND`, `SQL%ROWCOUNT` |
| UPDATE | `sp_transfer_student`, `sp_flag_academic_warning` (FORALL), `sp_record_grades_bulk` (FORALL) | `SQL%FOUND`, `SQL%ROWCOUNT` |
| DELETE | `sp_withdraw_enrollment` | **`SQL%NOTFOUND`** → user-defined exception; `SQL%ROWCOUNT` |

**Explicit cursors** — two processing styles are demonstrated:

* `fn_get_gpa` and `sp_course_grade_distribution` use **cursor FOR loops** (open/fetch/close
  managed automatically).
* `sp_show_course_roster` uses the manual **OPEN → FETCH → CLOSE** cycle, with
  `FETCH … BULK COLLECT INTO … LIMIT 10` for memory-bounded batch fetching, `%ROWCOUNT`
  captured *before* `CLOSE`, and an `OTHERS` handler that closes the cursor via
  `%ISOPEN` (guards against `INVALID_CURSOR`).

---

## 5. Bulk processing (requirement 5)

* **`BULK COLLECT`**: `sp_flag_academic_warning` fetches all qualifying student ids into
  `t_num_tab` in one round trip; `sp_show_course_roster` fetches roster rows in batches of 10
  (`LIMIT 10`) — the standard pattern for huge result sets: few round trips, bounded memory.
* **`FORALL`**: `sp_record_grades_bulk` rewrites a batch of score updates as **one**
  statement (`FORALL i IN … SAVE EXCEPTIONS UPDATE …`); `sp_flag_academic_warning` switches
  all flagged students with one bulk `UPDATE`.
* **Bulk DML errors**: `FORALL … SAVE EXCEPTIONS` does not abort at the first bad row; all
  errors are collected in `SQL%BULK_EXCEPTIONS` (caught via the `PRAGMA EXCEPTION_INIT`
  alias for ORA-24381). `sp_record_grades_bulk` prints every failing row
  (`ERROR_INDEX` → enroll_id, `SQLERRM(-ERROR_CODE)` → reason), **rolls back the whole
  batch** (atomic all-or-nothing semantics — grades are never half-uploaded) and raises
  ORA-20044. Test E06 proves the rollback: the valid row keeps its old value.

### Why bulk processing is faster (performance explanation)

PL/SQL and SQL run in two different engines. Every single-row DML or fetch from PL/SQL
costs a **context switch** between the two engines. For N rows, row-by-row code pays
N switches; bulk code pays **one**.

Concretely, uploading 1 000 grades:

* row-by-row: 1 000 `UPDATE` statements → 1 000 parse/bind/execute cycles and 1 000
  context switches;
* `FORALL`: 1 statement → the 1 000 binds are sent to the SQL engine in one switch.

The saved overhead is pure engine-hopping cost, so measured speed-ups in Oracle labs
typically range from **10× to 100×** as N grows — the larger the batch, the bigger the win
(for small N ≈ 5 the difference is negligible, which is why single-row procedures here stay
simple). Two engineering caveats handled in this project:

1. **Memory**: `BULK COLLECT` without `LIMIT` loads the whole result set into PGA memory;
   `sp_show_course_roster` caps every batch at 10 rows (`FETCH … LIMIT`).
2. **Error granularity**: a plain `FORALL` stops at the first error; `SAVE EXCEPTIONS`
   + `SQL%BULK_EXCEPTIONS` gives full batch diagnostics while the code decides the
   transactional outcome (here: rollback).

---

## 6. Exception handling (requirement 8)

Pattern used consistently in every block: **validate → work → report → commit**;
handlers always `ROLLBACK` before raising, `OTHERS` never hides an error (it logs and
re-raises with `RAISE;`).

* **Predefined**: `NO_DATA_FOUND` (every `SELECT INTO` validation), `TOO_MANY_ROWS`
  (`sp_get_student_by_name` with the intentionally duplicated name "Aline Uwase"),
  `DUP_VAL_ON_INDEX` (unique e-mail / unique enrollment).
* **User-defined**: `e_invalid_status`, `e_invalid_semester`, `e_student_inactive`,
  `e_already_enrolled`, `e_course_full`, `e_not_enrolled`, `e_same_dept`,
  `e_name_not_found`, `e_ambiguous_name`, `e_invalid_score`, `e_not_found` semantics,
  plus `e_bulk_errors` bound to ORA-24381 by `PRAGMA EXCEPTION_INIT`.
* **`RAISE_APPLICATION_ERROR`** with a documented code registry:

| Code | Subprogram | Meaning |
|------|------------|---------|
| -20001 | sp_register_student | e-mail already registered |
| -20002 | sp_register_student / sp_transfer_student | department unknown |
| -20010 | sp_enroll_student | student or course unknown |
| -20011 | sp_show_course_roster / sp_course_grade_distribution | course unknown |
| -20012 | sp_enroll_student | already enrolled (checked + constraint safety net) |
| -20013 | sp_enroll_student | course full (user-defined `e_course_full`) |
| -20020 | sp_withdraw_enrollment | enrollment unknown (SQL%NOTFOUND) |
| -20021 | sp_enroll_student / sp_transfer_student | student GRADUATED/WITHDRAWN |
| -20022 | sp_transfer_student | target = current department |
| -20030 | sp_get_student_by_name | name unknown |
| -20031 | sp_get_student_by_name | name ambiguous (TOO_MANY_ROWS) |
| -20040 | fn_calculate_grade | score outside 0–100 (or NULL) |
| -20041 | fn_get_gpa | student unknown |
| -20042 | fn_course_seats_left / fn_course_average | course unknown |
| -20043 | fn_get_student_summary | student unknown |
| -20044 | sp_record_grades_bulk | batch rejected — rows failed, all rolled back |
| -20045 | sp_record_grades_bulk | empty upload batch |
| -20046 | sp_enroll_student | semester format invalid |
| -20047 | sp_register_student | status value invalid |

Documented non-error returns: `fn_get_gpa` returns NULL when a student has no graded
course yet, and `fn_course_average` returns NULL when no scores exist — these are states,
not errors, and the behaviour is stated in each file header.

---

## 7. Testing approach

* `03_tests/test_success_cases.sql` (T01–T14) — one anonymous block per feature, each
  printing a `Txn PASS` marker and the expected value (GPA 3.75, average 78.8, seats 27…),
  so the output is self-verifying and screenshot-ready.
* `03_tests/test_error_cases.sql` (E01–E11) — each block **expects** an exception:
  if no error is raised it prints `Exx FAIL`, otherwise `Exn PASS - caught: ORA-…`.
* Both suites are re-runnable: they delete their own `TEST %` / `TST-%` rows first, and
  the error suite restores the sample data at the end. The error suite depends on T07
  having run once (E06 verifies the rollback against the values T07 uploaded).

## 8. Limitations & possible improvements

* Commits are issued inside the procedures for demo transparency; a production design
  would move transaction control to the caller (no `COMMIT` inside stored programs).
* Grade points (A=4.0 … F=0) and the passing thresholds are hard-coded; a production
  system would keep them in a configuration table.
* One could add a PL/SQL package to encapsulate all procedures/functions, a trigger-based
  audit trail of grade changes, and a benchmark script comparing row-by-row vs `FORALL`
  with `DBMS_UTILITY.GET_TIME` on a 1 000-row batch (expected: one order of magnitude).

