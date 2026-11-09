[READ ME 1.txt](https://github.com/user-attachments/files/34577700/READ.ME.1.txt)
# Crownfield Eye Hospital MySQL Workbench project

Database: `crownfield_eye_hospital_com`

Requires MySQL Server 8.0.16 or later (including 8.4) and MySQL Workbench.
Earlier MySQL releases do not enforce the CHECK constraints used here.

## Run order

1. Open MySQL Workbench and connect to your MySQL server.
2. Open `01_schema.sql` using File > Open SQL Script, or paste its contents into a query tab. Run the whole script once on a fresh database. It creates ten related tables, inserts synthetic records, demonstrates controlled UPDATE/DELETE, and demonstrates ROLLBACK and COMMIT.
3. Run `02_individual_queries.sql` for GROUP BY/HAVING, INNER JOIN, LEFT JOIN, and subquery results.
4. Run `03_procedure_and_trigger.sql` for the input-parameter procedure, INSERT/UPDATE triggers and a valid trigger test.
5. Run `04_security.sql` with a MySQL administrator connection. It creates roles, example users, grants, a limited patient view, and an educational hashing example.
6. Optionally open `05_integrity_tests.sql`. The deliberate failures are commented out. Uncomment and run one complete failing statement at a time; capture the error as evidence. The final positive test can run as supplied.

Each file selects the database itself. Stop when an unexpected error appears and resolve it before continuing. Run the transaction demonstrations on the same connection, without other pending changes. Workbench's SQL editor understands the DELIMITER statements in file 03.

## Re-running

The schema file intentionally does not drop your database. Run it once on an empty schema: re-running it will encounter existing tables and duplicate data. Files 02 and 03 can be run again after setup. File 04 expects fresh example users, roles, view and app_user table; do not repeatedly run it against existing security objects. No automatic destructive reset is included.
