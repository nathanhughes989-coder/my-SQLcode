USE crownfield_eye_hospital_com;
-- Recreate only these named demonstration routines.
DROP PROCEDURE IF EXISTS get_patient_appointments;
DROP TRIGGER IF EXISTS trg_validate_followup_date;
DROP TRIGGER IF EXISTS trg_validate_followup_date_update;
DELIMITER $$

USE crownfield_eye_hospital_com;

DELIMITER $$

CREATE PROCEDURE get_patient_appointments(
    IN p_patient_id VARCHAR(10)
)
BEGIN
    SELECT
        a.appointment_id,
        a.appointment_date,
        a.appointment_time,
        CONCAT(c.first_name, ' ', c.last_name) AS clinician_name,
        cl.clinic_name,
        a.status
    FROM appointment a
    JOIN clinician c
        ON a.clinician_id = c.clinician_id
    JOIN clinic cl
        ON a.clinic_id = cl.clinic_id
    WHERE a.patient_id = p_patient_id
    ORDER BY a.appointment_date;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_validate_followup_date
BEFORE INSERT ON follow_up
FOR EACH ROW
BEGIN
    DECLARE v_appointment_date DATE;

    SELECT appointment_date
    INTO v_appointment_date
    FROM appointment
    WHERE appointment_id = NEW.appointment_id;

    IF NEW.due_date < v_appointment_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Follow-up date cannot be before appointment date';
    END IF;
END $$

DELIMITER ;

-- Apply the same rule when existing follow-up rows are edited.
DELIMITER $$

CREATE TRIGGER trg_validate_followup_date_update
BEFORE UPDATE ON follow_up
FOR EACH ROW
BEGIN
    DECLARE v_appointment_date DATE;

    SELECT appointment_date
    INTO v_appointment_date
    FROM appointment
    WHERE appointment_id = NEW.appointment_id;

    IF NEW.due_date < v_appointment_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Follow-up date cannot be before appointment date';
    END IF;
END $$

DELIMITER ;

-- Procedure evidence: OP001 has two appointments.
CALL get_patient_appointments('OP001');

-- Valid trigger test: appointment 3 has no existing follow-up.
-- ROLLBACK removes the test row so the dataset remains reproducible.
START TRANSACTION;
INSERT INTO follow_up (appointment_id, due_date, priority, status)
VALUES (3, '2026-12-01', 'Routine', 'Pending');
SELECT * FROM follow_up WHERE appointment_id = 3;
ROLLBACK;
 
-- Run the deliberate failing tests separately from 05_integrity_tests.sql.
-- This trigger validates follow_up inserts/updates. It does not prevent changing
-- an appointment date later; that is a documented extension for this prototype.
SHOW TRIGGERS;
INSERT INTO follow_up
(
    appointment_id,
    due_date,
    priority,
    status
)
VALUES
(
    3,
    '2026-01-01',
    'Routine',
    'Pending'
);