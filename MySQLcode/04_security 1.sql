USE crownfield_eye_hospital_com;
CREATE ROLE
    'hospital_admin',
    'doctor_role',
    'receptionist_role',
    'patient_role';

GRANT ALL PRIVILEGES
ON crownfield_eye_hospital_com.*
TO 'hospital_admin';

GRANT SELECT
ON crownfield_eye_hospital_com.*
TO 'doctor_role';

GRANT INSERT, UPDATE
ON crownfield_eye_hospital_com.diagnosis
TO 'doctor_role';

GRANT INSERT, UPDATE
ON crownfield_eye_hospital_com.prescription
TO 'doctor_role';

GRANT INSERT, UPDATE
ON crownfield_eye_hospital_com.prescription_item
TO 'doctor_role';

GRANT INSERT, UPDATE
ON crownfield_eye_hospital_com.follow_up
TO 'doctor_role';

GRANT SELECT, INSERT, UPDATE
ON crownfield_eye_hospital_com.patient
TO 'receptionist_role';

GRANT SELECT, INSERT, UPDATE
ON crownfield_eye_hospital_com.appointment
TO 'receptionist_role';

GRANT SELECT
ON crownfield_eye_hospital_com.clinic
TO 'receptionist_role';

-- Demo mapping: patient_user sees only OP001 through this view.
-- USER() identifies the connected account even inside a definer view.
CREATE VIEW patient_appointment_summary AS
SELECT
    a.patient_id,
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    a.status,
    cl.clinic_name
FROM appointment a
JOIN clinic cl
    ON a.clinic_id = cl.clinic_id
WHERE a.patient_id = 'OP001'
  AND SUBSTRING_INDEX(USER(), '@', 1) = 'patient_user';

GRANT SELECT
ON crownfield_eye_hospital_com.patient_appointment_summary
TO 'patient_role';

CREATE USER 'admin_user'@'localhost'
IDENTIFIED BY 'AdminExample!2026';

CREATE USER 'doctor_user'@'localhost'
IDENTIFIED BY 'DoctorExample!2026';

CREATE USER 'reception_user'@'localhost'
IDENTIFIED BY 'ReceptionExample!2026';

CREATE USER 'patient_user'@'localhost'
IDENTIFIED BY 'PatientExample!2026';

GRANT 'hospital_admin'
TO 'admin_user'@'localhost';

GRANT 'doctor_role'
TO 'doctor_user'@'localhost';

GRANT 'receptionist_role'
TO 'reception_user'@'localhost';

GRANT 'patient_role'
TO 'patient_user'@'localhost';

SET DEFAULT ROLE ALL TO
'admin_user'@'localhost',
'doctor_user'@'localhost',
'reception_user'@'localhost',
'patient_user'@'localhost';

SHOW GRANTS FOR 'doctor_user'@'localhost';

SHOW GRANTS FOR 'reception_user'@'localhost';

-- Educational hashing evidence only. Real passwords need a salted password
-- hash such as Argon2id, bcrypt or scrypt, generated in the application.
CREATE TABLE app_user (
    app_user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash CHAR(64) NOT NULL,
    user_type VARCHAR(20) NOT NULL,

    CHECK (user_type IN (
        'Administrator',
        'Doctor',
        'Receptionist',
        'Patient'
    ))
);

INSERT INTO app_user
(username, password_hash, user_type)
VALUES
(
    'doctor_demo',
    SHA2('ExamplePassword123!', 256),
    'Doctor'
);



-- Show role contents as well as the users' role assignments.
SHOW GRANTS FOR 'hospital_admin';
SHOW GRANTS FOR 'doctor_role';
SHOW GRANTS FOR 'receptionist_role';
SHOW GRANTS FOR 'patient_role';

-- Test from a NEW connection signed in as patient_user:
-- SELECT * FROM crownfield_eye_hospital_com.patient_appointment_summary;
-- Expected: only OP001 appointments.
-- SELECT * FROM crownfield_eye_hospital_com.patient;
-- Expected: access denied.