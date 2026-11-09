USE crownfield_eye_hospital_com;

-- Query 1: Which clinicians have at least two recorded appointments?
SELECT
    c.clinician_id,
    CONCAT(c.first_name, ' ', c.last_name) AS clinician_name,
    COUNT(a.appointment_id) AS appointment_count
FROM clinician c
JOIN appointment a
    ON c.clinician_id = a.clinician_id
GROUP BY
    c.clinician_id,
    c.first_name,
    c.last_name
HAVING COUNT(a.appointment_id) >= 2;

-- Query 2: Show appointments with patient, clinician and clinic details.
SELECT
    a.appointment_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    CONCAT(c.first_name, ' ', c.last_name) AS clinician_name,
    cl.clinic_name,
    a.appointment_date,
    a.appointment_time,
    a.status
FROM appointment a
INNER JOIN patient p
    ON a.patient_id = p.patient_id
INNER JOIN clinician c
    ON a.clinician_id = c.clinician_id
INNER JOIN clinic cl
    ON a.clinic_id = cl.clinic_id
ORDER BY a.appointment_date;

-- Query 3: Which appointments have no diagnosis?
SELECT
    a.appointment_id,
    a.appointment_date,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    d.diagnosis_name
FROM appointment a
JOIN patient p
    ON a.patient_id = p.patient_id
LEFT JOIN diagnosis d
    ON a.appointment_id = d.appointment_id
WHERE d.diagnosis_id IS NULL;

-- Query 4: Which clinicians have more appointments than the average across all clinicians?
SELECT
    c.clinician_id,
    CONCAT(c.first_name, ' ', c.last_name) AS clinician_name,
    COUNT(a.appointment_id) AS appointment_count
FROM clinician c
JOIN appointment a
    ON c.clinician_id = a.clinician_id
GROUP BY
    c.clinician_id,
    c.first_name,
    c.last_name
HAVING COUNT(a.appointment_id) >
(
    SELECT AVG(appointment_total)
    FROM
    (
        SELECT COUNT(a2.appointment_id) AS appointment_total
        FROM clinician c2
        LEFT JOIN appointment a2 ON a2.clinician_id = c2.clinician_id
        GROUP BY c2.clinician_id
    ) AS clinician_counts
);
-- Query 5: Retrieve appointment history for a specific patient

CALL get_patient_appointments('OP001');