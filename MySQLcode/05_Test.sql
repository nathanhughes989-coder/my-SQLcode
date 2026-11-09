USE crownfield_eye_hospital_com;
-- OPTIONAL: all failing tests are commented so Run All is safe.
-- Select one complete statement, remove its leading -- markers, and run it.
-- Capture the error and compare it with the expected outcome.
-- Run after 01_schema.sql and 03_procedure_and_trigger.sql.

-- 1. Duplicate primary key: rejected (OP001 already exists).
-- INSERT INTO patient (patient_id, first_name, last_name, postcode)
-- VALUES ('OP001', 'Duplicate', 'Patient', 'ZZ1 1ZZ');

-- 2. Invalid appointment status: rejected by CHECK.
-- INSERT INTO appointment
-- (patient_id, clinician_id, clinic_id, appointment_date, appointment_time, status)
-- VALUES ('OP001', 1, 1, '2026-12-01', '09:00:00', 'Finished');

-- 3. Missing parent patient: rejected by foreign key.
-- INSERT INTO appointment
-- (patient_id, clinician_id, clinic_id, appointment_date, appointment_time)
-- VALUES ('OP999', 1, 1, '2026-12-01', '09:00:00');

-- 4. Duplicate medicine name: rejected by UNIQUE.
-- INSERT INTO medicine (medicine_name) VALUES ('Latanoprost');

-- 5. Negative duration: rejected by CHECK.
-- UPDATE prescription_item SET duration_days = -5 WHERE prescription_item_id = 1;

-- 6. Invalid priority: rejected by CHECK.
-- UPDATE follow_up SET priority = 'Extreme' WHERE follow_up_id = 1;

-- 7. Follow-up before appointment: rejected by INSERT trigger, SQLSTATE 45000.
-- INSERT INTO follow_up (appointment_id, due_date, priority, status)
-- VALUES (3, '2020-01-01', 'Routine', 'Pending');

-- 8. Edit follow-up before appointment: rejected by UPDATE trigger.
-- UPDATE follow_up SET due_date = '2020-01-01' WHERE follow_up_id = 1;

-- 9. Missing required postcode: rejected by NOT NULL.
-- INSERT INTO patient (patient_id, first_name, last_name, postcode)
-- VALUES ('TEST02', 'Test', 'Patient', NULL);

-- Positive test: valid linked appointment, then rollback to remove it.
START TRANSACTION;
INSERT INTO appointment
(patient_id, clinician_id, clinic_id, appointment_date, appointment_time)
VALUES ('OP001', 1, 1, '2026-12-01', '09:00:00');
SELECT * FROM appointment WHERE appointment_id = LAST_INSERT_ID();
ROLLBACK;