/*
=========================================================
Crownfield Eye Hospital Database
CPU4:103 Introduction to Databases

This database supports the management of:
- Patients
- Clinicians
- Clinics
- Appointments
- Diagnoses
- Prescriptions
- Medicines
- Follow-up plans

The schema has been normalised to Third Normal Form
(3NF) to reduce redundancy and improve integrity.

Author: Nathan Hughes
=========================================================
*/
-- Create the database used throughout the project.
-- A dedicated database keeps all project tables isolated.

CREATE DATABASE IF NOT EXISTS crownfield_eye_hospital_com;
USE crownfield_eye_hospital_com;
SELECT DATABASE() AS current_database;

-- Table: specialty
CREATE TABLE IF NOT EXISTS specialty (
    specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    specialty_name VARCHAR(60) NOT NULL UNIQUE
);

-- Table: patient
CREATE TABLE patient (
    patient_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    postcode VARCHAR(10) NOT NULL,
    date_of_birth DATE,
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: clinician
CREATE TABLE clinician (
    clinician_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialty_id INT NOT NULL,
    email VARCHAR(100) UNIQUE,
    
    CONSTRAINT fk_clinician_specialty
        FOREIGN KEY (specialty_id)
        REFERENCES specialty(specialty_id)
);

-- Table: clinic
CREATE TABLE clinic (
    clinic_id INT AUTO_INCREMENT PRIMARY KEY,
    clinic_name VARCHAR(80) NOT NULL UNIQUE,
    address VARCHAR(150)
);

-- Table: appointment
CREATE TABLE appointment (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id VARCHAR(10) NOT NULL,
    clinician_id INT NOT NULL,
    clinic_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    notes VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'Scheduled',

    CONSTRAINT chk_appointment_status
        CHECK (status IN (
            'Scheduled',
            'Completed',
            'Cancelled',
            'Did Not Attend'
        )),

    CONSTRAINT fk_appointment_patient
        FOREIGN KEY (patient_id)
        REFERENCES patient(patient_id),

    CONSTRAINT fk_appointment_clinician
        FOREIGN KEY (clinician_id)
        REFERENCES clinician(clinician_id),

    CONSTRAINT fk_appointment_clinic
        FOREIGN KEY (clinic_id)
        REFERENCES clinic(clinic_id)
);

-- Table: diagnosis
CREATE TABLE diagnosis (
    diagnosis_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    diagnosis_name VARCHAR(100) NOT NULL,
    diagnosis_notes VARCHAR(255),

    CONSTRAINT fk_diagnosis_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointment(appointment_id)
        ON DELETE CASCADE
);

-- Table: medicine
CREATE TABLE medicine (
    medicine_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL UNIQUE
);

-- Table: prescription
CREATE TABLE prescription (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    prescription_date DATE NOT NULL,

    CONSTRAINT fk_prescription_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointment(appointment_id)
        ON DELETE CASCADE
);

-- Table: prescription_item
CREATE TABLE prescription_item (
    prescription_item_id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id INT NOT NULL,
    medicine_id INT NOT NULL,
    dose VARCHAR(50) NOT NULL,
    route VARCHAR(30) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    duration_days INT NOT NULL,

    CONSTRAINT chk_duration
        CHECK (duration_days > 0),

    CONSTRAINT uq_prescription_medicine
        UNIQUE (prescription_id, medicine_id),

    CONSTRAINT fk_item_prescription
        FOREIGN KEY (prescription_id)
        REFERENCES prescription(prescription_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_item_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicine(medicine_id)
);

-- Table: follow_up
CREATE TABLE follow_up (
    follow_up_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    due_date DATE NOT NULL,
    priority VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',

    CONSTRAINT chk_followup_priority
        CHECK (priority IN ('Routine', 'High', 'Urgent')),

    CONSTRAINT chk_followup_status
        CHECK (status IN ('Pending', 'Booked', 'Completed', 'Cancelled')),

    CONSTRAINT fk_followup_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointment(appointment_id)
        ON DELETE CASCADE
);

-- Synthetic sample data: specialty
INSERT INTO specialty (specialty_name)
VALUES
('Glaucoma'),
('Retina'),
('Cornea'),
('Cataract'),
('Paediatric Ophthalmology'),
('Neuro-Ophthalmology'),
('Oculoplastics'),
('General Ophthalmology'),
('Uveitis'),
('Medical Retina');

-- Synthetic sample data: patient
INSERT INTO patient
(patient_id, first_name, last_name, postcode, date_of_birth, phone, email)
VALUES
('OP001','Amina','Yusuf','NE1 4AB','1981-03-15','07000000001','amina.yusuf@example.test'),
('OP002','Daniel','Reed','N16 7QP','1975-09-21','07000000002','daniel.reed@example.test'),
('OP003','Sofia','Bennett','E8 2LD','1990-06-12','07000000003','sofia.bennett@example.test'),
('OP004','Michael','Okoro','SE6 3RT','1986-11-02','07000000004','michael.okoro@example.test'),
('OP005','Grace','Taylor','B1 2AA','1968-01-28','07000000005','grace.taylor@example.test'),
('OP006','Ahmed','Khan','M1 4QT','1959-05-13','07000000006','ahmed.khan@example.test'),
('OP007','Lucy','Brown','LS1 3AF','2001-08-19','07000000007','lucy.brown@example.test'),
('OP008','Samuel','Green','S2 4BB','1984-04-08','07000000008','samuel.green@example.test'),
('OP009','Chloe','Wilson','CV1 5RT','1994-12-11','07000000009','chloe.wilson@example.test'),
('OP010','David','Mensah','NG1 1AB','1979-07-30','07000000010','david.mensah@example.test');

-- Synthetic sample data: clinician
INSERT INTO clinician
(first_name, last_name, specialty_id, email)
VALUES
('Maya', 'Shah', 1, 'maya.shah@crownfield.test'),
('Leo', 'Grant', 2, 'leo.grant@crownfield.test'),
('Priya', 'Nair', 3, 'priya.nair@crownfield.test'),
('James', 'Collins', 4, 'james.collins@crownfield.test'),
('Sarah', 'Ahmed', 5, 'sarah.ahmed@crownfield.test'),
('Peter', 'Wong', 6, 'peter.wong@crownfield.test'),
('Helen', 'Brooks', 7, 'helen.brooks@crownfield.test'),
('David', 'Okafor', 8, 'david.okafor@crownfield.test'),
('Nina', 'Patel', 9, 'nina.patel@crownfield.test'),
('Grace', 'Morgan', 10, 'grace.morgan@crownfield.test');

-- Synthetic sample data: clinic
INSERT INTO clinic (clinic_name, address)
VALUES
('City Road', '12 City Road'),
('Bedford', '5 Bedford Street'),
('Croydon', '18 High Street'),
('North Wing', 'Crownfield Hospital North Wing'),
('South Wing', 'Crownfield Hospital South Wing'),
('Retina Centre', '22 Medical Avenue'),
('Glaucoma Suite', '14 Vision Lane'),
('Cornea Unit', '7 Eye Care Road'),
('Paediatric Clinic', '10 Children Way'),
('Urgent Eye Clinic', '1 Emergency Road');

-- Synthetic sample data: appointment
INSERT INTO appointment
(patient_id, clinician_id, clinic_id, appointment_date, appointment_time, notes, status)
VALUES
('OP001',1,1,'2026-10-05','09:00:00','Review IOP','Completed'),
('OP002',2,1,'2026-10-05','09:30:00','OCT before review','Completed'),
('OP001',1,2,'2026-11-16','10:15:00','Visual field test','Scheduled'),
('OP003',1,1,'2026-10-06','11:00:00','Monitor','Completed'),
('OP004',3,3,'2026-10-07','14:00:00','Corneal topography','Completed'),
('OP005',4,4,'2026-10-08','09:00:00','Cataract assessment','Completed'),
('OP006',8,5,'2026-10-09','11:30:00','General eye review','Completed'),
('OP007',5,9,'2026-10-10','10:00:00','Paediatric review','Completed'),
('OP008',2,6,'2026-10-11','13:00:00','Retina review','Completed'),
('OP009',9,4,'2026-10-12','15:30:00','Inflammation review','Completed'),
('OP010',6,1,'2026-10-13','10:30:00','Neurological visual assessment','Scheduled');

-- Synthetic sample data: diagnosis
INSERT INTO diagnosis
(appointment_id, diagnosis_name, diagnosis_notes)
VALUES
(1,'Ocular hypertension','Raised intraocular pressure'),
(2,'Diabetic macular oedema','OCT changes noted'),
(4,'Glaucoma suspect','Observation required'),
(5,'Keratoconus','Corneal thinning confirmed'),
(6,'Cataract','Reduced lens clarity'),
(7,'Dry eye syndrome','Moderate symptoms'),
(8,'Amblyopia','Reduced visual acuity'),
(9,'Retinal vein occlusion','Retinal swelling'),
(10,'Anterior uveitis','Inflammation present'),
(11,'Optic neuritis','Further investigation required');

-- Synthetic sample data: medicine
INSERT INTO medicine (medicine_name)
VALUES
('Latanoprost'),
('Timolol'),
('Aflibercept'),
('Sodium chloride drops'),
('Prednisolone eye drops'),
('Artificial tears'),
('Cyclopentolate'),
('Dorzolamide'),
('Moxifloxacin'),
('Acetazolamide');

-- Synthetic sample data: prescription
INSERT INTO prescription
(appointment_id, prescription_date)
VALUES
(1,'2026-10-05'),
(2,'2026-10-05'),
(4,'2026-10-06'),
(5,'2026-10-07'),
(6,'2026-10-08'),
(7,'2026-10-09'),
(8,'2026-10-10'),
(9,'2026-10-11'),
(10,'2026-10-12'),
(11,'2026-10-13');

-- Synthetic sample data: prescription_item
INSERT INTO prescription_item
(prescription_id, medicine_id, dose, route, frequency, duration_days)
VALUES
(1,1,'1 drop','Ocular','Once daily',30),
(1,2,'1 drop','Ocular','Twice daily',30),
(2,3,'2 mg','Intravitreal','Single dose',1),
(3,8,'1 drop','Ocular','Twice daily',30),
(4,4,'1 drop','Ocular','Four times daily',14),
(5,9,'1 drop','Ocular','Four times daily',7),
(6,6,'1 drop','Ocular','As required',30),
(7,7,'1 drop','Ocular','Twice daily',7),
(8,3,'2 mg','Intravitreal','Single dose',1),
(9,5,'1 drop','Ocular','Four times daily',14),
(10,10,'250 mg','Oral','Twice daily',5);

-- Synthetic sample data: follow_up
INSERT INTO follow_up
(appointment_id, due_date, priority, status)
VALUES
(1,'2026-11-16','High','Booked'),
(2,'2026-11-02','Urgent','Booked'),
(4,'2027-04-06','Routine','Pending'),
(5,'2026-12-02','Routine','Pending'),
(6,'2026-12-03','Routine','Pending'),
(7,'2026-11-20','Routine','Pending'),
(8,'2026-12-01','High','Pending'),
(9,'2026-11-08','Urgent','Pending'),
(10,'2026-10-26','High','Pending'),
(11,'2026-11-10','High','Pending');

-- Test and Checks
-- Inspect implementation and sample record counts.
SHOW TABLES;
DESCRIBE patient;
DESCRIBE appointment;
DESCRIBE prescription_item;
SELECT 'specialty' AS table_name, COUNT(*) AS row_count FROM specialty
UNION ALL SELECT 'patient', COUNT(*) FROM patient
UNION ALL SELECT 'clinician', COUNT(*) FROM clinician
UNION ALL SELECT 'clinic', COUNT(*) FROM clinic
UNION ALL SELECT 'appointment', COUNT(*) FROM appointment
UNION ALL SELECT 'diagnosis', COUNT(*) FROM diagnosis
UNION ALL SELECT 'medicine', COUNT(*) FROM medicine
UNION ALL SELECT 'prescription', COUNT(*) FROM prescription
UNION ALL SELECT 'prescription_item', COUNT(*) FROM prescription_item
UNION ALL SELECT 'follow_up', COUNT(*) FROM follow_up;

-- Controlled UPDATE: capture before and after result grids.
SELECT * FROM follow_up WHERE follow_up_id = 1;
UPDATE follow_up SET status = 'Completed' WHERE follow_up_id = 1;
SELECT * FROM follow_up WHERE follow_up_id = 1;

-- Controlled DELETE: create and remove one disposable patient.
INSERT INTO patient (patient_id, first_name, last_name, postcode)
VALUES ('TEST01', 'Test', 'Patient', 'ZZ1 1ZZ');
SELECT * FROM patient WHERE patient_id = 'TEST01';
DELETE FROM patient WHERE patient_id = 'TEST01';
SELECT * FROM patient WHERE patient_id = 'TEST01';

-- ROLLBACK: the second result should restore 'Booked'.
SELECT * FROM follow_up WHERE follow_up_id = 1;
START TRANSACTION;
UPDATE follow_up SET status = 'Completed' WHERE follow_up_id = 1;
SELECT * FROM follow_up WHERE follow_up_id = 1;
ROLLBACK;
SELECT * FROM follow_up WHERE follow_up_id = 1;
-- UPDATE follow_up SET status = 'Booked' WHERE follow_up_id = 1;
-- COMMIT: the final result should retain 'Completed'.
START TRANSACTION;
UPDATE follow_up SET status = 'Completed' WHERE follow_up_id = 2;
COMMIT;
SELECT * FROM follow_up WHERE follow_up_id = 2;
SELECT * FROM appointment;
ROLLBACK;