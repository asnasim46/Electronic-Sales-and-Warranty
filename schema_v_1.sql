--------------------------------------------------
-- CLEAN USER (OPTIONAL FOR DEV)
--------------------------------------------------
-- DROP USER marzan CASCADE;

CREATE USER marzan IDENTIFIED BY marzan
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

GRANT CONNECT, RESOURCE, DBA TO marzan;

CONNECT marzan/marzan;


--------------------------------------------------
-- PARTS CATEGORY
--------------------------------------------------
CREATE TABLE parts_category (
    parts_cat_id    VARCHAR2(50) PRIMARY KEY,
    parts_cat_code  VARCHAR2(50),
    parts_cat_name  VARCHAR2(200),
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT uq_parts_cat_name UNIQUE (parts_cat_name)
);

CREATE SEQUENCE parts_cat_seq START WITH 1 INCREMENT BY 5 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_parts_cat_bi
BEFORE INSERT OR UPDATE ON parts_category
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.parts_cat_id :=
      NVL(UPPER(TRIM(:NEW.parts_cat_code)), '') || parts_cat_seq.NEXTVAL;
    :NEW.status := NVL(:NEW.status, 1);
    :NEW.cre_by := NVL(:NEW.cre_by, USER);
    :NEW.cre_dt := NVL(:NEW.cre_dt, SYSDATE);
  ELSE
    :NEW.upd_by := NVL(:NEW.upd_by, USER);
    :NEW.upd_dt := NVL(:NEW.upd_dt, SYSDATE);
  END IF;
END;
/

--------------------------------------------------
-- PARTS
--------------------------------------------------
CREATE TABLE parts (
    parts_id       VARCHAR2(50) PRIMARY KEY,
    parts_code     VARCHAR2(50),
    parts_name     VARCHAR2(200),
    price          NUMBER(15,2),
    parts_cat_id   VARCHAR2(50),
    status         NUMBER,
    cre_by         VARCHAR2(100),
    cre_dt         DATE,
    upd_by         VARCHAR2(100),
    upd_dt         DATE,
    CONSTRAINT fk_parts_parts_cat FOREIGN KEY (parts_cat_id)
        REFERENCES parts_category(parts_cat_id)
);

CREATE SEQUENCE parts_seq START WITH 1 INCREMENT BY 5 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_parts_bi
BEFORE INSERT OR UPDATE ON parts
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.parts_id :=
      NVL(UPPER(TRIM(:NEW.parts_code)), '') || parts_seq.NEXTVAL;
    :NEW.status := NVL(:NEW.status, 1);
    :NEW.cre_by := NVL(:NEW.cre_by, USER);
    :NEW.cre_dt := NVL(:NEW.cre_dt, SYSDATE);
  ELSE
    :NEW.upd_by := NVL(:NEW.upd_by, USER);
    :NEW.upd_dt := NVL(:NEW.upd_dt, SYSDATE);
  END IF;
END;
/

--------------------------------------------------
-- CUSTOMERS
--------------------------------------------------
CREATE TABLE customers (
    customer_id     VARCHAR2(50) PRIMARY KEY,
    customer_name   VARCHAR2(200) NOT NULL,
    phone_no        VARCHAR2(50) NOT NULL,
    alternative_phone_no VARCHAR2(50),
    address         VARCHAR2(300),
    city            VARCHAR2(100),
    rewards_points  NUMBER,
    notes           VARCHAR2(500),
    status          NUMBER,
    cre_dt          DATE,
    cre_by          VARCHAR2(50),
    upd_by          VARCHAR2(50),
    upd_dt          DATE,
    CONSTRAINT uq_customers_phone UNIQUE (phone_no)
);

CREATE OR REPLACE TRIGGER trg_customers_bi
BEFORE INSERT OR UPDATE ON customers
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.customer_id :=
      RPAD(UPPER(SUBSTR(:NEW.customer_name,1,3)),3,'X')
      || '+' || :NEW.phone_no;
    :NEW.status := NVL(:NEW.status,1);
    :NEW.cre_dt := NVL(:NEW.cre_dt,SYSDATE);
    :NEW.cre_by := NVL(:NEW.cre_by,USER);
  ELSE
    :NEW.customer_id := :OLD.customer_id;
    :NEW.upd_dt := SYSDATE;
    :NEW.upd_by := USER;
  END IF;
END;
/

--------------------------------------------------
-- COMPANY
--------------------------------------------------
CREATE TABLE company (
    company_id NUMBER PRIMARY KEY,
    company_name VARCHAR2(100) UNIQUE NOT NULL,
    phone_no VARCHAR2(50) UNIQUE NOT NULL,
    email VARCHAR2(50) UNIQUE NOT NULL,
    status NUMBER,
    cre_by VARCHAR2(50),
    cre_dt DATE,
    upd_by VARCHAR2(50),
    upd_dt DATE
);

CREATE SEQUENCE company_seq START WITH 1;

CREATE OR REPLACE TRIGGER trg_company
BEFORE INSERT OR UPDATE ON company
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.company_id := NVL(:NEW.company_id, company_seq.NEXTVAL);
    :NEW.status := NVL(:NEW.status,1);
    :NEW.cre_by := NVL(:NEW.cre_by,USER);
    :NEW.cre_dt := NVL(:NEW.cre_dt,SYSDATE);
  ELSE
    :NEW.upd_by := USER;
    :NEW.upd_dt := SYSDATE;
  END IF;
END;
/

--------------------------------------------------
-- DEPARTMENTS
--------------------------------------------------
CREATE TABLE departments (
    department_id NUMBER PRIMARY KEY,
    department_name VARCHAR2(50),
    manager_id NUMBER,
    company_id NUMBER,
    status NUMBER,
    cre_by VARCHAR2(50),
    cre_dt DATE,
    upd_by VARCHAR2(50),
    upd_dt DATE,
    CONSTRAINT fk_dept_company FOREIGN KEY (company_id)
      REFERENCES company(company_id)
);

CREATE SEQUENCE departments_seq START WITH 10 INCREMENT BY 10;

--------------------------------------------------
-- JOBS
--------------------------------------------------
CREATE TABLE jobs (
    job_id VARCHAR2(30) PRIMARY KEY,
    job_code VARCHAR2(50),
    job_title VARCHAR2(50),
    job_grade VARCHAR2(1),
    min_salary NUMBER,
    max_salary NUMBER,
    status NUMBER,
    cre_by VARCHAR2(50),
    cre_dt DATE,
    upd_by VARCHAR2(50),
    upd_dt DATE,
    CONSTRAINT chk_job_grade CHECK (job_grade IN ('A','B','C') OR job_grade IS NULL)
);

CREATE SEQUENCE jobs_seq START WITH 1 INCREMENT BY 5;

--------------------------------------------------
-- EMPLOYEES
--------------------------------------------------
CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    job_id VARCHAR2(30),
    department_id NUMBER,
    manager_id NUMBER,
    status NUMBER,
    cre_by VARCHAR2(50),
    cre_dt DATE,
    upd_by VARCHAR2(50),
    upd_dt DATE
);

ALTER TABLE employees ADD CONSTRAINT fk_emp_job
FOREIGN KEY (job_id) REFERENCES jobs(job_id);

ALTER TABLE employees ADD CONSTRAINT fk_emp_dept
FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE employees ADD CONSTRAINT fk_emp_mgr
FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

CREATE SEQUENCE employees_seq START WITH 1;

--------------------------------------------------
-- FIX CIRCULAR FK (DEFERRABLE)
--------------------------------------------------
ALTER TABLE departments
ADD CONSTRAINT fk_dept_mgr
FOREIGN KEY (manager_id)
REFERENCES employees(employee_id)
DEFERRABLE INITIALLY DEFERRED;

--------------------------------------------------
-- USERS
--------------------------------------------------
CREATE TABLE users (
    user_id NUMBER PRIMARY KEY,
    user_name VARCHAR2(50) UNIQUE NOT NULL,
    password VARCHAR2(100) NOT NULL,
    role VARCHAR2(50) DEFAULT 'user',
    employee_id NUMBER,
    status NUMBER,
    cre_by VARCHAR2(50),
    cre_dt DATE,
    upd_by VARCHAR2(50),
    upd_dt DATE
);

ALTER TABLE users ADD CONSTRAINT fk_users_emp
FOREIGN KEY (employee_id)
REFERENCES employees(employee_id)
ON DELETE SET NULL;

CREATE SEQUENCE users_seq START WITH 1;

--------------------------------------------------
-- SERVICE_LIST
--------------------------------------------------
CREATE TABLE service_list (
    servicelist_id VARCHAR2(50) PRIMARY KEY,
    service_code   VARCHAR2(50),
    service_name   VARCHAR2(200) NOT NULL,
    service_desc   VARCHAR2(1000),
    service_cost   NUMBER DEFAULT 0,
    status         NUMBER,
    cre_by         VARCHAR2(100),
    cre_dt         DATE,
    upd_by         VARCHAR2(100),
    upd_dt         DATE
);

CREATE SEQUENCE service_list_seq START WITH 1 INCREMENT BY 5 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_service_list
BEFORE INSERT OR UPDATE ON service_list
FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
  IF INSERTING THEN
    v_seq := service_list_seq.NEXTVAL;
    IF :NEW.service_code IS NOT NULL THEN
      v_code := UPPER(TRIM(:NEW.service_code));
      :NEW.servicelist_id := v_code || TO_CHAR(v_seq);
    ELSE
      :NEW.servicelist_id := TO_CHAR(v_seq);
    END IF;
    IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
    IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
    IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
  ELSIF UPDATING THEN
    IF :NEW.upd_by IS NULL THEN :NEW.upd_by := USER; END IF;
    IF :NEW.upd_dt IS NULL THEN :NEW.upd_dt := SYSDATE; END IF;
  END IF;
END;
/

CREATE INDEX idx_service_name ON service_list(service_name);

--------------------------------------------------
-- EXPENSE_LIST
--------------------------------------------------
CREATE TABLE expense_list (
    expense_type_id   VARCHAR2(50) PRIMARY KEY,
    expense_code      VARCHAR2(50),
    type_name         VARCHAR2(200) NOT NULL,
    description       VARCHAR2(1000),
    default_amount    NUMBER(15,2),
    status            NUMBER,
    cre_by            VARCHAR2(100),
    cre_dt            DATE,
    upd_by            VARCHAR2(100),
    upd_dt            DATE,
    CONSTRAINT uq_expense_list_type UNIQUE (type_name)
);

CREATE SEQUENCE expense_list_seq START WITH 1 INCREMENT BY 5 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_expense_list
BEFORE INSERT OR UPDATE ON expense_list
FOR EACH ROW
DECLARE v_seq_val NUMBER; v_code VARCHAR2(100);
BEGIN
  IF INSERTING THEN
    v_seq_val := expense_list_seq.NEXTVAL;
    IF :NEW.expense_code IS NOT NULL THEN
      v_code := UPPER(TRIM(:NEW.expense_code));
      :NEW.expense_type_id := v_code || TO_CHAR(v_seq_val);
    ELSE
      :NEW.expense_type_id := TO_CHAR(v_seq_val);
    END IF;
    IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
    IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
    IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
  ELSIF UPDATING THEN
    IF :NEW.upd_by IS NULL THEN :NEW.upd_by := USER; END IF;
    IF :NEW.upd_dt IS NULL THEN :NEW.upd_dt := SYSDATE; END IF;
  END IF;
END;
/

--------------------------------------------------
-- EXPENSE_MASTER
--------------------------------------------------
CREATE TABLE expense_master (
    expense_id        VARCHAR2(50) PRIMARY KEY,
    expense_code      VARCHAR2(50),
    expense_date      DATE DEFAULT SYSDATE,
    expense_by        VARCHAR2(50) NOT NULL,
    expense_type_id   VARCHAR2(50) NOT NULL,
    total_amount      NUMBER(15,2) DEFAULT 0,
    remarks           VARCHAR2(1000),
    status            VARCHAR2(20) DEFAULT 'OPEN',
    cre_by            VARCHAR2(100),
    cre_dt            DATE,
    upd_by            VARCHAR2(100),
    upd_dt            DATE,
    CONSTRAINT fk_exp_master_type FOREIGN KEY (expense_type_id)
      REFERENCES expense_list(expense_type_id)
);

CREATE SEQUENCE expense_master_seq START WITH 1 INCREMENT BY 5 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_expense_master
BEFORE INSERT OR UPDATE ON expense_master
FOR EACH ROW
DECLARE v_seq_val NUMBER; v_code VARCHAR2(100);
BEGIN
  IF INSERTING THEN
    v_seq_val := expense_master_seq.NEXTVAL;
    IF :NEW.expense_code IS NOT NULL THEN
      v_code := UPPER(TRIM(:NEW.expense_code));
      :NEW.expense_id := v_code || TO_CHAR(v_seq_val);
    ELSE
      :NEW.expense_id := TO_CHAR(v_seq_val);
    END IF;
    IF :NEW.status IS NULL THEN :NEW.status := 'OPEN'; END IF;
    IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
    IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
  ELSIF UPDATING THEN
    IF :NEW.upd_by IS NULL THEN :NEW.upd_by := USER; END IF;
    IF :NEW.upd_dt IS NULL THEN :NEW.upd_dt := SYSDATE; END IF;
  END IF;
END;
/

CREATE INDEX idx_exp_master_by ON expense_master(expense_by);
CREATE INDEX idx_exp_master_type ON expense_master(expense_type_id);

--------------------------------------------------
-- EXPENSE_DETAILS
--------------------------------------------------
CREATE TABLE expense_details (
    expense_det_id    VARCHAR2(50) PRIMARY KEY,
    detail_code       VARCHAR2(50),
    expense_id        VARCHAR2(50) NOT NULL,
    expense_type_id   VARCHAR2(50) NOT NULL,
    description       VARCHAR2(1000),
    amount            NUMBER(15,2) DEFAULT 0,
    quantity          NUMBER DEFAULT 1,
    line_total        NUMBER(15,2),
    status            NUMBER,
    cre_by            VARCHAR2(100),
    cre_dt            DATE,
    upd_by            VARCHAR2(100),
    upd_dt            DATE,
    CONSTRAINT fk_exp_det_master FOREIGN KEY (expense_id)
      REFERENCES expense_master(expense_id),
    CONSTRAINT fk_exp_det_type   FOREIGN KEY (expense_type_id)
      REFERENCES expense_list(expense_type_id)
);

CREATE SEQUENCE expense_details_seq START WITH 1 INCREMENT BY 5 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_expense_details
BEFORE INSERT OR UPDATE ON expense_details
FOR EACH ROW
DECLARE v_seq_val NUMBER; v_code VARCHAR2(100);
BEGIN
  IF INSERTING THEN
    v_seq_val := expense_details_seq.NEXTVAL;
    IF :NEW.detail_code IS NOT NULL THEN
      v_code := UPPER(TRIM(:NEW.detail_code));
      :NEW.expense_det_id := v_code || TO_CHAR(v_seq_val);
    ELSE
      :NEW.expense_det_id := TO_CHAR(v_seq_val);
    END IF;
    IF :NEW.line_total IS NULL THEN
      :NEW.line_total := NVL(:NEW.amount,0) * NVL(:NEW.quantity,1);
    END IF;
    IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
    IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
    IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
  ELSIF UPDATING THEN
    IF UPDATING('amount') OR UPDATING('quantity') THEN
      :NEW.line_total := NVL(:NEW.amount,0) * NVL(:NEW.quantity,1);
    END IF;
    IF :NEW.upd_by IS NULL THEN :NEW.upd_by := USER; END IF;
    IF :NEW.upd_dt IS NULL THEN :NEW.upd_dt := SYSDATE; END IF;
  END IF;
END;
/

CREATE INDEX idx_exp_det_exp ON expense_details(expense_id);
CREATE INDEX idx_exp_det_type ON expense_details(expense_type_id);

--------------------------------------------------
-- PRODUCT CATEGORIES
--------------------------------------------------
CREATE TABLE product_categories (
    product_cat_id    NUMBER PRIMARY KEY,
    product_cat_name  VARCHAR2(30),
    status            NUMBER,
    cre_by            VARCHAR2(30),
    cre_dt            DATE,
    upd_by            VARCHAR2(30),
    upd_dt            DATE
);

CREATE SEQUENCE product_categories_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_product_categories_bi
BEFORE INSERT OR UPDATE ON product_categories
FOR EACH ROW
DECLARE v_seq NUMBER;
BEGIN
    IF INSERTING THEN
        IF :new.product_cat_id IS NULL THEN
            v_seq := product_categories_seq.NEXTVAL;
            :new.product_cat_id := v_seq;
        END IF;
        IF :new.status IS NULL THEN :new.status := 1; END IF;
        IF :new.cre_by IS NULL THEN :new.cre_by := USER; END IF;
        IF :new.cre_dt IS NULL THEN :new.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        IF :new.upd_by IS NULL THEN :new.upd_by := USER; END IF;
        IF :new.upd_dt IS NULL THEN :new.upd_dt := SYSDATE; END IF;
    END IF;
END;
/

--------------------------------------------------
-- SUB CATEGORIES
--------------------------------------------------
CREATE TABLE sub_categories (
    sub_cat_id       NUMBER PRIMARY KEY,
    sub_cat_name     VARCHAR2(30),
    product_cat_id   NUMBER,
    status           NUMBER,
    cre_by           VARCHAR2(30),
    cre_dt           DATE,
    upd_by           VARCHAR2(30),
    upd_dt           DATE,
    CONSTRAINT fk_subcat_productcat FOREIGN KEY (product_cat_id)
      REFERENCES product_categories(product_cat_id)
);

CREATE SEQUENCE sub_categories_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_sub_categories_bi
BEFORE INSERT OR UPDATE ON sub_categories
FOR EACH ROW
DECLARE v_seq NUMBER;
BEGIN
    IF INSERTING THEN
        IF :new.sub_cat_id IS NULL THEN
            v_seq := sub_categories_seq.NEXTVAL;
            :new.sub_cat_id := v_seq;
        END IF;
        IF :new.status IS NULL THEN :new.status := 1; END IF;
        IF :new.cre_by IS NULL THEN :new.cre_by := USER; END IF;
        IF :new.cre_dt IS NULL THEN :new.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        IF :new.upd_by IS NULL THEN :new.upd_by := USER; END IF;
        IF :new.upd_dt IS NULL THEN :new.upd_dt := SYSDATE; END IF;
    END IF;
END;
/

--------------------------------------------------
-- BRAND
--------------------------------------------------
CREATE TABLE brand (
    brand_id      NUMBER PRIMARY KEY,
    brand_name    VARCHAR2(30),
    model_name    VARCHAR2(20),
    product_size  VARCHAR2(15),
    color         VARCHAR2(10),
    status        NUMBER,
    cre_by        VARCHAR2(10),
    cre_dt        DATE,
    upd_by        VARCHAR2(10),
    upd_dt        DATE
);

CREATE SEQUENCE brand_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_brand_bi
BEFORE INSERT OR UPDATE ON brand
FOR EACH ROW
DECLARE v_seq NUMBER;
BEGIN
    IF INSERTING THEN
        IF :new.brand_id IS NULL THEN
            v_seq := brand_seq.NEXTVAL;
            :new.brand_id := v_seq;
        END IF;
        IF :new.status IS NULL THEN :new.status := 1; END IF;
        IF :new.cre_by IS NULL THEN :new.cre_by := USER; END IF;
        IF :new.cre_dt IS NULL THEN :new.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        IF :new.upd_by IS NULL THEN :new.upd_by := USER; END IF;
        IF :new.upd_dt IS NULL THEN :new.upd_dt := SYSDATE; END IF;
    END IF;
END;
/

--------------------------------------------------
-- SUPPLIERS
--------------------------------------------------
CREATE TABLE suppliers (
    supplier_id NUMBER PRIMARY KEY,
    supplier_name VARCHAR2(30) NOT NULL,
    phone_no VARCHAR2(50),
    email VARCHAR2(30),
    address VARCHAR2(30),
    contact_person VARCHAR2(30),
    cp_phone_no VARCHAR2(50),
    cp_email VARCHAR2(30),
    purchase_total NUMBER DEFAULT 0,
    pay_total NUMBER DEFAULT 0,
    due NUMBER GENERATED ALWAYS AS (NVL(purchase_total,0) - NVL(pay_total,0)) VIRTUAL,
    status NUMBER,
    cre_by VARCHAR2(20),
    cre_dt DATE,
    upd_by VARCHAR2(20),
    upd_dt DATE
);

CREATE SEQUENCE suppliers_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_suppliers_bi
BEFORE INSERT OR UPDATE ON suppliers
FOR EACH ROW
DECLARE v_seq NUMBER;
BEGIN
    IF INSERTING THEN
        IF :new.supplier_id IS NULL THEN
            v_seq := suppliers_seq.NEXTVAL;
            :new.supplier_id := v_seq;
        END IF;
        IF :new.status IS NULL THEN :new.status := 1; END IF;
        IF :new.cre_by IS NULL THEN :new.cre_by := USER; END IF;
        IF :new.cre_dt IS NULL THEN :new.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        IF :new.upd_by IS NULL THEN :new.upd_by := USER; END IF;
        IF :new.upd_dt IS NULL THEN :new.upd_dt := SYSDATE; END IF;
    END IF;
END;
/

--------------------------------------------------
-- PRODUCTS
--------------------------------------------------
CREATE TABLE products (
    product_id        NUMBER PRIMARY KEY,
    product_code      VARCHAR2(30) UNIQUE,
    product_name      VARCHAR2(100) NOT NULL,
    subcategory_id    NUMBER,
    category_id       NUMBER,
    supplier_id       NUMBER,
    brand_id          NUMBER,
    uom               VARCHAR2(50),
    mrp               NUMBER,
    purchase_price    NUMBER,
    warranty_24_12    VARCHAR2(20),
    status            VARCHAR2(50),
    cre_by            VARCHAR2(20),
    cre_dt            DATE,
    upd_by            VARCHAR2(20),
    upd_dt            DATE,
    CONSTRAINT fk_products_supplier FOREIGN KEY (supplier_id)
      REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_products_category FOREIGN KEY (category_id)
      REFERENCES product_categories(product_cat_id),
    CONSTRAINT fk_products_subcategory FOREIGN KEY (subcategory_id)
      REFERENCES sub_categories(sub_cat_id),
    CONSTRAINT fk_products_brand FOREIGN KEY (brand_id)
      REFERENCES brand(brand_id)
);

CREATE SEQUENCE products_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_products_bi
BEFORE INSERT OR UPDATE ON products
FOR EACH ROW
DECLARE v_seq NUMBER;
BEGIN
    IF INSERTING THEN
        IF :new.product_id IS NULL THEN
            v_seq := products_seq.NEXTVAL;
            :new.product_id := v_seq;
        END IF;
        IF :new.status_num IS NULL THEN :new.status_num := 1; END IF;
        IF :new.cre_by IS NULL THEN :new.cre_by := USER; END IF;
        IF :new.cre_dt IS NULL THEN :new.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        IF :new.upd_by IS NULL THEN :new.upd_by := USER; END IF;
        IF :new.upd_dt IS NULL THEN :new.upd_dt := SYSDATE; END IF;
    END IF;
END;
/

--------------------------------------------------
-- SAMPLE DATA
--------------------------------------------------
SET DEFINE OFF;

-- 1) PARTS_CATEGORY (10 rows)
INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('ENG', 'Engine Parts');
INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('ELC', 'Electrical Parts');
INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('BDY', 'Body Parts');
INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('BRK', 'Brake Parts');
INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('TRN', 'Transmission Parts');
INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('SUS', 'Suspension Parts');
INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('TIR', 'Tire & Wheel');
INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('AC', 'AC & Cooling');
INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('LUB', 'Lubricants');
INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('MISC', 'Miscellaneous Parts');

-- 2) PARTS (10 rows, referencing categories by code prefix)
INSERT INTO parts (parts_code, parts_name, price, parts_cat_id)
SELECT 'ENG-OILFLT', 'Engine Oil Filter', 500, parts_cat_id
FROM parts_category WHERE parts_cat_name = 'Engine Parts';

INSERT INTO parts (parts_code, parts_name, price, parts_cat_id)
SELECT 'ENG-AIRFLT', 'Air Filter', 650, parts_cat_id
FROM parts_category WHERE parts_cat_name = 'Engine Parts';

INSERT INTO parts (parts_code, parts_name, price, parts_cat_id)
SELECT 'ELC-BAT', 'Car Battery 45Ah', 5500, parts_cat_id
FROM parts_category WHERE parts_cat_name = 'Electrical Parts';

INSERT INTO parts (parts_code, parts_name, price, parts_cat_id)
SELECT 'ELC-SPARK', 'Spark Plug Set', 1800, parts_cat_id
FROM parts_category WHERE parts_cat_name = 'Electrical Parts';

INSERT INTO parts (parts_code, parts_name, price, parts_cat_id)
SELECT 'BRK-PADF', 'Front Brake Pads', 3200, parts_cat_id
FROM parts_category WHERE parts_cat_name = 'Brake Parts';

INSERT INTO parts (parts_code, parts_name, price, parts_cat_id)
SELECT 'BRK-PADR', 'Rear Brake Pads', 2800, parts_cat_id
FROM parts_category WHERE parts_cat_name = 'Brake Parts';

INSERT INTO parts (parts_code, parts_name, price, parts_cat_id)
SELECT 'SUS-SHOCKF', 'Front Shock Absorber', 4200, parts_cat_id
FROM parts_category WHERE parts_cat_name = 'Suspension Parts';

INSERT INTO parts (parts_code, parts_name, price, parts_cat_id)
SELECT 'SUS-SHOCKR', 'Rear Shock Absorber', 3900, parts_cat_id
FROM parts_category WHERE parts_cat_name = 'Suspension Parts';

INSERT INTO parts (parts_code, parts_name, price, parts_cat_id)
SELECT 'TIR-195R15', '195/65R15 Tire', 7200, parts_cat_id
FROM parts_category WHERE parts_cat_name = 'Tire & Wheel';

INSERT INTO parts (parts_code, parts_name, price, parts_cat_id)
SELECT 'AC-COMP', 'AC Compressor', 15500, parts_cat_id
FROM parts_category WHERE parts_cat_name = 'AC & Cooling';

-- 3) CUSTOMERS (10 rows)
INSERT INTO customers (customer_name, phone_no, alternative_phone_no, address, city, rewards_points, notes)
VALUES ('Rahim Uddin',   '01710000001', '01810000001', 'Mirpur DOHS', 'Dhaka', 120, 'Regular customer');
INSERT INTO customers (customer_name, phone_no, alternative_phone_no, address, city, rewards_points, notes)
VALUES ('Karim Hasan',   '01710000002', '01810000002', 'Banani', 'Dhaka', 80, 'Prefers OEM parts');
INSERT INTO customers (customer_name, phone_no, alternative_phone_no, address, city, rewards_points, notes)
VALUES ('Sumaiya Akter', '01710000003', NULL, 'Uttara', 'Dhaka', 200, 'High value customer');
INSERT INTO customers (customer_name, phone_no, alternative_phone_no, address, city, rewards_points, notes)
VALUES ('Imran Hossain', '01710000004', NULL, 'Dhanmondi', 'Dhaka', 60, NULL);
INSERT INTO customers (customer_name, phone_no, alternative_phone_no, address, city, rewards_points, notes)
VALUES ('Nusrat Jahan',  '01710000005', '01910000005', 'Mohakhali', 'Dhaka', 150, 'Corporate account');
INSERT INTO customers (customer_name, phone_no, alternative_phone_no, address, city, rewards_points, notes)
VALUES ('Faisal Ahmed',  '01710000006', NULL, 'Chittagong', 'Chattogram', 40, NULL);
INSERT INTO customers (customer_name, phone_no, alternative_phone_no, address, city, rewards_points, notes)
VALUES ('Rashid Khan',   '01710000007', NULL, 'Sylhet Sadar', 'Sylhet', 25, NULL);
INSERT INTO customers (customer_name, phone_no, alternative_phone_no, address, city, rewards_points, notes)
VALUES ('Mitu Rahman',   '01710000008', NULL, 'Khulna Sadar', 'Khulna', 55, NULL);
INSERT INTO customers (customer_name, phone_no, alternative_phone_no, address, city, rewards_points, notes)
VALUES ('Sabbir Ahmed',  '01710000009', NULL, 'Rajshahi', 'Rajshahi', 90, 'Loyalty candidate');
INSERT INTO customers (customer_name, phone_no, alternative_phone_no, address, city, rewards_points, notes)
VALUES ('Farhana Islam', '01710000010', '01610000010', 'Cumilla', 'Cumilla', 130, 'Referral source');

-- 4) COMPANY (10 rows)
INSERT INTO company (company_name, phone_no, email)
VALUES ('AutoCare Ltd',        '09600000001', 'info@autocare.com');
INSERT INTO company (company_name, phone_no, email)
VALUES ('Dhaka Motors',        '09600000002', 'contact@dhakamotors.com');
INSERT INTO company (company_name, phone_no, email)
VALUES ('Chittagong Auto',     '09600000003', 'hello@ctgauto.com');
INSERT INTO company (company_name, phone_no, email)
VALUES ('Sylhet Wheels',       '09600000004', 'info@sylhetwheels.com');
INSERT INTO company (company_name, phone_no, email)
VALUES ('Rajshahi Motors',     '09600000005', 'support@rajmotors.com');
INSERT INTO company (company_name, phone_no, email)
VALUES ('Khulna Auto House',   '09600000006', 'info@khulnaauto.com');
INSERT INTO company (company_name, phone_no, email)
VALUES ('Barisal Car Care',    '09600000007', 'contact@barisalcar.com');
INSERT INTO company (company_name, phone_no, email)
VALUES ('Mymensingh Motors',   '09600000008', 'info@mymmotors.com');
INSERT INTO company (company_name, phone_no, email)
VALUES ('Cumilla Auto Services','09600000009','info@cumauto.com');
INSERT INTO company (company_name, phone_no, email)
VALUES ('Rangpur Auto Tech',   '09600000010', 'info@rangpurauto.com');

-- 5) DEPARTMENTS (10 rows, simple mapping to first 3 companies)
INSERT INTO departments (department_id, department_name, manager_id, company_id, status)
VALUES (10, 'Sales',       NULL, 1, 1);
INSERT INTO departments (department_id, department_name, manager_id, company_id, status)
VALUES (20, 'Service',     NULL, 1, 1);
INSERT INTO departments (department_id, department_name, manager_id, company_id, status)
VALUES (30, 'Accounts',    NULL, 1, 1);
INSERT INTO departments (department_id, department_name, manager_id, company_id, status)
VALUES (40, 'HR',          NULL, 2, 1);
INSERT INTO departments (department_id, department_name, manager_id, company_id, status)
VALUES (50, 'IT',          NULL, 2, 1);
INSERT INTO departments (department_id, department_name, manager_id, company_id, status)
VALUES (60, 'Logistics',   NULL, 2, 1);
INSERT INTO departments (department_id, department_name, manager_id, company_id, status)
VALUES (70, 'Procurement', NULL, 3, 1);
INSERT INTO departments (department_id, department_name, manager_id, company_id, status)
VALUES (80, 'Warehouse',   NULL, 3, 1);
INSERT INTO departments (department_id, department_name, manager_id, company_id, status)
VALUES (90, 'Quality',     NULL, 3, 1);
INSERT INTO departments (department_id, department_name, manager_id, company_id, status)
VALUES (100,'Admin',       NULL, 3, 1);

-- 6) JOBS (10 rows)
INSERT INTO jobs (job_id, job_code, job_title, job_grade, min_salary, max_salary, status)
VALUES ('JOB-A1', 'SALES_EXE',     'Sales Executive',     'B', 15000, 25000, 1);
INSERT INTO jobs (job_id, job_code, job_title, job_grade, min_salary, max_salary, status)
VALUES ('JOB-A2', 'SR_SALES',      'Sr Sales Executive',  'A', 25000, 40000, 1);
INSERT INTO jobs (job_id, job_code, job_title, job_grade, min_salary, max_salary, status)
VALUES ('JOB-A3', 'SERVICE_ENG',   'Service Engineer',    'B', 18000, 30000, 1);
INSERT INTO jobs (job_id, job_code, job_title, job_grade, min_salary, max_salary, status)
VALUES ('JOB-A4', 'ACCT_OFF',      'Accounts Officer',    'B', 18000, 28000, 1);
INSERT INTO jobs (job_id, job_code, job_title, job_grade, min_salary, max_salary, status)
VALUES ('JOB-A5', 'HR_OFF',        'HR Officer',          'B', 18000, 28000, 1);
INSERT INTO jobs (job_id, job_code, job_title, job_grade, min_salary, max_salary, status)
VALUES ('JOB-A6', 'IT_EXE',        'IT Executive',        'B', 20000, 32000, 1);
INSERT INTO jobs (job_id, job_code, job_title, job_grade, min_salary, max_salary, status)
VALUES ('JOB-A7', 'STORE_OFF',     'Store Officer',       'C', 14000, 22000, 1);
INSERT INTO jobs (job_id, job_code, job_title, job_grade, min_salary, max_salary, status)
VALUES ('JOB-A8', 'MGR_OPS',       'Operations Manager',  'A', 40000, 60000, 1);
INSERT INTO jobs (job_id, job_code, job_title, job_grade, min_salary, max_salary, status)
VALUES ('JOB-A9', 'MGR_SALES',     'Sales Manager',       'A', 40000, 65000, 1);
INSERT INTO jobs (job_id, job_code, job_title, job_grade, min_salary, max_salary, status)
VALUES ('JOB-A10','TECH_LEAD',     'Technical Lead',      'A', 35000, 55000, 1);

-- 7) EMPLOYEES (10 rows)
INSERT INTO employees (employee_id, first_name, last_name, job_id, department_id, manager_id, status)
VALUES (1,  'Mahmud',  'Rahman',  'JOB-A9', 10, NULL, 1); -- Sales Manager, top
INSERT INTO employees (employee_id, first_name, last_name, job_id, department_id, manager_id, status)
VALUES (2,  'Sajid',   'Khan',    'JOB-A1', 10, 1,    1);
INSERT INTO employees (employee_id, first_name, last_name, job_id, department_id, manager_id, status)
VALUES (3,  'Nihad',   'Hasan',   'JOB-A1', 10, 1,    1);
INSERT INTO employees (employee_id, first_name, last_name, job_id, department_id, manager_id, status)
VALUES (4,  'Ruby',    'Akter',   'JOB-A3', 20, NULL, 1);
INSERT INTO employees (employee_id, first_name, last_name, job_id, department_id, manager_id, status)
VALUES (5,  'Kamal',   'Hossain', 'JOB-A3', 20, 4,    1);
INSERT INTO employees (employee_id, first_name, last_name, job_id, department_id, manager_id, status)
VALUES (6,  'Javed',   'Iqbal',   'JOB-A4', 30, NULL, 1);
INSERT INTO employees (employee_id, first_name, last_name, job_id, department_id, manager_id, status)
VALUES (7,  'Tania',   'Sultana', 'JOB-A5', 40, NULL, 1);
INSERT INTO employees (employee_id, first_name, last_name, job_id, department_id, manager_id, status)
VALUES (8,  'Reza',    'Karim',   'JOB-A6', 50, NULL, 1);
INSERT INTO employees (employee_id, first_name, last_name, job_id, department_id, manager_id, status)
VALUES (9,  'Shila',   'Parvin',  'JOB-A7', 80, NULL, 1);
INSERT INTO employees (employee_id, first_name, last_name, job_id, department_id, manager_id, status)
VALUES (10, 'Aziz',    'Mia',     'JOB-A8', 70, NULL, 1);

-- optionally update departments.manager_id to fix manager link
UPDATE departments SET manager_id = 1 WHERE department_id = 10;
UPDATE departments SET manager_id = 4 WHERE department_id = 20;
UPDATE departments SET manager_id = 6 WHERE department_id = 30;
UPDATE departments SET manager_id = 7 WHERE department_id = 40;
UPDATE departments SET manager_id = 8 WHERE department_id = 50;
UPDATE departments SET manager_id = 10 WHERE department_id = 70;

-- 8) USERS (10 rows)
INSERT INTO users (user_id, user_name, password, role, employee_id, status)
VALUES (1,  'admin',       'admin123',   'admin', 1, 1);
INSERT INTO users (user_id, user_name, password, role, employee_id, status)
VALUES (2,  'sales1',      'pass123',    'user',  2, 1);
INSERT INTO users (user_id, user_name, password, role, employee_id, status)
VALUES (3,  'sales2',      'pass123',    'user',  3, 1);
INSERT INTO users (user_id, user_name, password, role, employee_id, status)
VALUES (4,  'service1',    'pass123',    'user',  5, 1);
INSERT INTO users (user_id, user_name, password, role, employee_id, status)
VALUES (5,  'accounts1',   'pass123',    'user',  6, 1);
INSERT INTO users (user_id, user_name, password, role, employee_id, status)
VALUES (6,  'hr1',         'pass123',    'user',  7, 1);
INSERT INTO users (user_id, user_name, password, role, employee_id, status)
VALUES (7,  'it1',         'pass123',    'user',  8, 1);
INSERT INTO users (user_id, user_name, password, role, employee_id, status)
VALUES (8,  'store1',      'pass123',    'user',  9, 1);
INSERT INTO users (user_id, user_name, password, role, employee_id, status)
VALUES (9,  'ops1',        'pass123',    'user', 10, 1);
INSERT INTO users (user_id, user_name, password, role, employee_id, status)
VALUES (10, 'guest',       'guest123',   'user', NULL,1);

-- 9) SERVICE_LIST (10 rows)
INSERT INTO service_list (service_code, service_name, service_desc, service_cost)
VALUES ('SRV-OIL',  'Engine Oil Change',      'Replace engine oil and filter', 1500);
INSERT INTO service_list (service_code, service_name, service_desc, service_cost)
VALUES ('SRV-TUNE', 'Full Engine Tuning',     'Spark plugs, filters, tuning', 3500);
INSERT INTO service_list (service_code, service_name, service_desc, service_cost)
VALUES ('SRV-BRK',  'Brake Service',          'Check and replace pads', 2500);
INSERT INTO service_list (service_code, service_name, service_desc, service_cost)
VALUES ('SRV-AC',   'AC Service',             'Clean and refill gas', 3000);
INSERT INTO service_list (service_code, service_name, service_desc, service_cost)
VALUES ('SRV-WASH', 'Premium Wash',           'Body wash and polish', 800);
INSERT INTO service_list (service_code, service_name, service_desc, service_cost)
VALUES ('SRV-ALIGN','Wheel Alignment',        '4-wheel alignment', 1200);
INSERT INTO service_list (service_code, service_name, service_desc, service_cost)
VALUES ('SRV-BAL',  'Wheel Balancing',        'Balancing all wheels', 1000);
INSERT INTO service_list (service_code, service_name, service_desc, service_cost)
VALUES ('SRV-SCAN', 'Computer Diagnostics',   'OBD scanning', 1500);
INSERT INTO service_list (service_code, service_name, service_desc, service_cost)
VALUES ('SRV-BODY', 'Body Repair',            'Minor dent & paint', 6000);
INSERT INTO service_list (service_code, service_name, service_desc, service_cost)
VALUES ('SRV-CHK',  'General Checkup',        'Standard inspection', 700);

-- 10) EXPENSE_LIST (10 rows)
INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('EXP-RENT',  'Workshop Rent',       'Monthly workshop rent', 50000);
INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('EXP-SAL',   'Staff Salary',        'Monthly staff salaries', 200000);
INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('EXP-UTIL',  'Utilities',           'Electricity, water, gas', 30000);
INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('EXP-MKT',   'Marketing',           'Promotions and ads', 15000);
INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('EXP-IT',    'IT Expenses',         'Software, hosting, etc.', 10000);
INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('EXP-TRAVL', 'Travel',              'Staff travel expenses', 8000);
INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('EXP-REP',   'Repairs',             'Machinery repair', 12000);
INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('EXP-CLEAN', 'Cleaning',            'Cleaning services', 5000);
INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('EXP-TRAIN', 'Training',            'Staff training', 7000);
INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('EXP-MISC',  'Miscellaneous',       'Other small expenses', 4000);

-- We need to capture some generated EXPENSE_LIST IDs for FK use
-- Use simple SELECTs with known type_name when inserting masters/details

-- 11) EXPENSE_MASTER (10 rows)
INSERT INTO expense_master (expense_code, expense_date, expense_by, expense_type_id, total_amount, remarks)
SELECT 'EM-001', SYSDATE-10, 'admin', expense_type_id, 52000, 'January rent'
FROM expense_list WHERE type_name = 'Workshop Rent';

INSERT INTO expense_master (expense_code, expense_date, expense_by, expense_type_id, total_amount, remarks)
SELECT 'EM-002', SYSDATE-9, 'admin', expense_type_id, 210000, 'January salaries'
FROM expense_list WHERE type_name = 'Staff Salary';

INSERT INTO expense_master (expense_code, expense_date, expense_by, expense_type_id, total_amount, remarks)
SELECT 'EM-003', SYSDATE-8, 'accounts1', expense_type_id, 32000, 'Utility bill'
FROM expense_list WHERE type_name = 'Utilities';

INSERT INTO expense_master (expense_code, expense_date, expense_by, expense_type_id, total_amount, remarks)
SELECT 'EM-004', SYSDATE-7, 'admin', expense_type_id, 18000, 'Facebook ads'
FROM expense_list WHERE type_name = 'Marketing';

INSERT INTO expense_master (expense_code, expense_date, expense_by, expense_type_id, total_amount, remarks)
SELECT 'EM-005', SYSDATE-6, 'it1', expense_type_id, 11000, 'New software licenses'
FROM expense_list WHERE type_name = 'IT Expenses';

INSERT INTO expense_master (expense_code, expense_date, expense_by, expense_type_id, total_amount, remarks)
SELECT 'EM-006', SYSDATE-5, 'admin', expense_type_id, 9000, 'Travel for client visit'
FROM expense_list WHERE type_name = 'Travel';

INSERT INTO expense_master (expense_code, expense_date, expense_by, expense_type_id, total_amount, remarks)
SELECT 'EM-007', SYSDATE-4, 'service1', expense_type_id, 13000, 'Lift repair'
FROM expense_list WHERE type_name = 'Repairs';

INSERT INTO expense_master (expense_code, expense_date, expense_by, expense_type_id, total_amount, remarks)
SELECT 'EM-008', SYSDATE-3, 'admin', expense_type_id, 5500, 'Deep cleaning'
FROM expense_list WHERE type_name = 'Cleaning';

INSERT INTO expense_master (expense_code, expense_date, expense_by, expense_type_id, total_amount, remarks)
SELECT 'EM-009', SYSDATE-2, 'hr1', expense_type_id, 7500, 'Technical training'
FROM expense_list WHERE type_name = 'Training';

INSERT INTO expense_master (expense_code, expense_date, expense_by, expense_type_id, total_amount, remarks)
SELECT 'EM-010', SYSDATE-1, 'admin', expense_type_id, 4200, 'Snacks & others'
FROM expense_list WHERE type_name = 'Miscellaneous';

-- 12) EXPENSE_DETAILS (10 rows, each linked to a master + type)
INSERT INTO expense_details (detail_code, expense_id, expense_type_id, description, amount, quantity)
SELECT 'ED-001',
       em.expense_id,
       el.expense_type_id,
       'Base rent', 50000, 1
FROM expense_master em
JOIN expense_list el ON em.expense_type_id = el.expense_type_id
WHERE em.expense_code = 'EM-001';

INSERT INTO expense_details (detail_code, expense_id, expense_type_id, description, amount, quantity)
SELECT 'ED-002', em.expense_id, el.expense_type_id,
       'VAT on rent', 2000, 1
FROM expense_master em
JOIN expense_list el ON em.expense_type_id = el.expense_type_id
WHERE em.expense_code = 'EM-001';

INSERT INTO expense_details (detail_code, expense_id, expense_type_id, description, amount, quantity)
SELECT 'ED-003', em.expense_id, el.expense_type_id,
       'Office staff salaries', 150000, 1
FROM expense_master em
JOIN expense_list el ON em.expense_type_id = el.expense_type_id
WHERE em.expense_code = 'EM-002';

INSERT INTO expense_details (detail_code, expense_id, expense_type_id, description, amount, quantity)
SELECT 'ED-004', em.expense_id, el.expense_type_id,
       'Technician salaries', 60000, 1
FROM expense_master em
JOIN expense_list el ON em.expense_type_id = el.expense_type_id
WHERE em.expense_code = 'EM-002';

INSERT INTO expense_details (detail_code, expense_id, expense_type_id, description, amount, quantity)
SELECT 'ED-005', em.expense_id, el.expense_type_id,
       'Electricity bill', 20000, 1
FROM expense_master em
JOIN expense_list el ON em.expense_type_id = el.expense_type_id
WHERE em.expense_code = 'EM-003';

INSERT INTO expense_details (detail_code, expense_id, expense_type_id, description, amount, quantity)
SELECT 'ED-006', em.expense_id, el.expense_type_id,
       'Water & gas bill', 12000, 1
FROM expense_master em
JOIN expense_list el ON em.expense_type_id = el.expense_type_id
WHERE em.expense_code = 'EM-003';

INSERT INTO expense_details (detail_code, expense_id, expense_type_id, description, amount, quantity)
SELECT 'ED-007', em.expense_id, el.expense_type_id,
       'Facebook campaign', 10000, 1
FROM expense_master em
JOIN expense_list el ON em.expense_type_id = el.expense_type_id
WHERE em.expense_code = 'EM-004';

INSERT INTO expense_details (detail_code, expense_id, expense_type_id, description, amount, quantity)
SELECT 'ED-008', em.expense_id, el.expense_type_id,
       'Flyers printing', 8000, 1
FROM expense_master em
JOIN expense_list el ON em.expense_type_id = el.expense_type_id
WHERE em.expense_code = 'EM-004';

INSERT INTO expense_details (detail_code, expense_id, expense_type_id, description, amount, quantity)
SELECT 'ED-009', em.expense_id, el.expense_type_id,
       'Oracle license', 7000, 1
FROM expense_master em
JOIN expense_list el ON em.expense_type_id = el.expense_type_id
WHERE em.expense_code = 'EM-005';

INSERT INTO expense_details (detail_code, expense_id, expense_type_id, description, amount, quantity)
SELECT 'ED-010', em.expense_id, el.expense_type_id,
       'Domain & hosting', 4000, 1
FROM expense_master em
JOIN expense_list el ON em.expense_type_id = el.expense_type_id
WHERE em.expense_code = 'EM-005';

-- 13) PRODUCT_CATEGORIES (10 rows)
INSERT INTO product_categories (product_cat_name)
VALUES ('Engine Oil');
INSERT INTO product_categories (product_cat_name)
VALUES ('Filters');
INSERT INTO product_categories (product_cat_name)
VALUES ('Batteries');
INSERT INTO product_categories (product_cat_name)
VALUES ('Tyres');
INSERT INTO product_categories (product_cat_name)
VALUES ('Brake Parts');
INSERT INTO product_categories (product_cat_name)
VALUES ('Suspension');
INSERT INTO product_categories (product_cat_name)
VALUES ('Interior');
INSERT INTO product_categories (product_cat_name)
VALUES ('Exterior');
INSERT INTO product_categories (product_cat_name)
VALUES ('Electronics');
INSERT INTO product_categories (product_cat_name)
VALUES ('Accessories');

-- 14) SUB_CATEGORIES (10 rows)
INSERT INTO sub_categories (sub_cat_name, product_cat_id)
SELECT 'Mineral Oil', product_cat_id FROM product_categories
WHERE product_cat_name = 'Engine Oil';

INSERT INTO sub_categories (sub_cat_name, product_cat_id)
SELECT 'Synthetic Oil', product_cat_id FROM product_categories
WHERE product_cat_name = 'Engine Oil';

INSERT INTO sub_categories (sub_cat_name, product_cat_id)
SELECT 'Oil Filter', product_cat_id FROM product_categories
WHERE product_cat_name = 'Filters';

INSERT INTO sub_categories (sub_cat_name, product_cat_id)
SELECT 'Air Filter', product_cat_id FROM product_categories
WHERE product_cat_name = 'Filters';

INSERT INTO sub_categories (sub_cat_name, product_cat_id)
SELECT 'Lead Acid', product_cat_id FROM product_categories
WHERE product_cat_name = 'Batteries';

INSERT INTO sub_categories (sub_cat_name, product_cat_id)
SELECT 'Maintenance Free', product_cat_id FROM product_categories
WHERE product_cat_name = 'Batteries';

INSERT INTO sub_categories (sub_cat_name, product_cat_id)
SELECT 'Sedan Tyre', product_cat_id FROM product_categories
WHERE product_cat_name = 'Tyres';

INSERT INTO sub_categories (sub_cat_name, product_cat_id)
SELECT 'SUV Tyre', product_cat_id FROM product_categories
WHERE product_cat_name = 'Tyres';

INSERT INTO sub_categories (sub_cat_name, product_cat_id)
SELECT 'Disc Brake', product_cat_id FROM product_categories
WHERE product_cat_name = 'Brake Parts';

INSERT INTO sub_categories (sub_cat_name, product_cat_id)
SELECT 'Drum Brake', product_cat_id FROM product_categories
WHERE product_cat_name = 'Brake Parts';

-- 15) BRAND (10 rows)
INSERT INTO brand (brand_name, model_name, product_size, color)
VALUES ('Toyota',   'Corolla',  '1.5L', 'White');
INSERT INTO brand (brand_name, model_name, product_size, color)
VALUES ('Toyota',   'Axio',     '1.5L', 'Silver');
INSERT INTO brand (brand_name, model_name, product_size, color)
VALUES ('Honda',    'Civic',    '1.8L', 'Black');
INSERT INTO brand (brand_name, model_name, product_size, color)
VALUES ('Honda',    'Grace',    '1.5L', 'Blue');
INSERT INTO brand (brand_name, model_name, product_size, color)
VALUES ('Nissan',   'Sunny',    '1.6L', 'Gray');
INSERT INTO brand (brand_name, model_name, product_size, color)
VALUES ('Mitsubishi','Lancer',  '1.6L', 'Red');
INSERT INTO brand (brand_name, model_name, product_size, color)
VALUES ('Hyundai',  'Elantra',  '1.6L', 'White');
INSERT INTO brand (brand_name, model_name, product_size, color)
VALUES ('Kia',      'Cerato',   '1.6L', 'Blue');
INSERT INTO brand (brand_name, model_name, product_size, color)
VALUES ('BMW',      '320i',     '2.0L', 'Black');
INSERT INTO brand (brand_name, model_name, product_size, color)
VALUES ('Mercedes', 'C180',     '1.6L', 'Silver');

-- 16) SUPPLIERS (10 rows)
INSERT INTO suppliers (supplier_name, phone_no, email, address, contact_person, cp_phone_no, cp_email, purchase_total, pay_total, status)
VALUES ('Auto Import BD',  '0240000001', 'sales@autoimportbd.com', 'Tejgaon', 'Mr. Ali',   '01712000001', 'ali@autoimportbd.com', 1000000, 800000, 1);
INSERT INTO suppliers (supplier_name, phone_no, email, address, contact_person, cp_phone_no, cp_email, purchase_total, pay_total, status)
VALUES ('Global Parts',    '0240000002', 'info@globalparts.com',   'Uttara',  'Mr. Rahman','01712000002', 'rahman@globalparts.com', 750000, 600000, 1);
INSERT INTO suppliers (supplier_name, phone_no, email, address, contact_person, cp_phone_no, cp_email, purchase_total, pay_total, status)
VALUES ('Tyre World',      '0240000003', 'contact@tyreworld.com',  'Mirpur',  'Mr. Karim', '01712000003', 'karim@tyreworld.com', 500000, 450000, 1);
INSERT INTO suppliers (supplier_name, phone_no, email, address, contact_person, cp_phone_no, cp_email, purchase_total, pay_total, status)
VALUES ('Battery House',   '0240000004', 'info@batteryhouse.com',  'Moghbazar','Mr. Hasan','01712000004', 'hasan@batteryhouse.com', 300000, 250000, 1);
INSERT INTO suppliers (supplier_name, phone_no, email, address, contact_person, cp_phone_no, cp_email, purchase_total, pay_total, status)
VALUES ('Filter Plus',     '0240000005', 'info@filterplus.com',    'Khilkhet','Mr. Shah',  '01712000005', 'shah@filterplus.com', 200000, 150000, 1);
INSERT INTO suppliers (supplier_name, phone_no, email, address, contact_person, cp_phone_no, cp_email, purchase_total, pay_total, status)
VALUES ('Cool Air Ltd',    '0240000006', 'info@coolair.com',       'Panthapath','Mr. Alam','01712000006','alam@coolair.com', 220000, 200000, 1);
INSERT INTO suppliers (supplier_name, phone_no, email, address, contact_person, cp_phone_no, cp_email, purchase_total, pay_total, status)
VALUES ('Brake Masters',   '0240000007', 'info@brakemasters.com',  'Dhanmondi','Mr. Nabil','01712000007','nabil@brakemasters.com', 260000, 230000, 1);
INSERT INTO suppliers (supplier_name, phone_no, email, address, contact_person, cp_phone_no, cp_email, purchase_total, pay_total, status)
VALUES ('Suspension Pro',  '0240000008', 'info@suspro.com',        'Mohakhali','Mr. Rafi', '01712000008','rafi@suspro.com', 180000, 160000, 1);
INSERT INTO suppliers (supplier_name, phone_no, email, address, contact_person, cp_phone_no, cp_email, purchase_total, pay_total, status)
VALUES ('Body Parts BD',   '0240000009', 'info@bodybd.com',        'Jatrabari','Mr. Hridoy','01712000009','hridoy@bodybd.com', 210000, 170000, 1);
INSERT INTO suppliers (supplier_name, phone_no, email, address, contact_person, cp_phone_no, cp_email, purchase_total, pay_total, status)
VALUES ('Auto Paints BD',  '0240000010', 'info@autopaints.com',    'Malibagh','Mr. Sohan', '01712000010','sohan@autopaints.com', 190000, 150000, 1);

-- 17) PRODUCTS (10 rows) using existing FK values via SELECT
INSERT INTO products (product_code, product_name, subcategory_id, category_id, supplier_id, brand_id,
                      uom, mrp, purchase_price, warranty_24_12, status)
SELECT 'PRD-ENGOIL-001', '5W30 Mineral Oil 4L',
       sc.sub_cat_id,
       pc.product_cat_id,
       1,
       1,
       'Litre', 2800, 2200, '12M', 'Active'
FROM sub_categories sc
JOIN product_categories pc ON sc.product_cat_id = pc.product_cat_id
WHERE sc.sub_cat_name = 'Mineral Oil'
  AND pc.product_cat_name = 'Engine Oil';

INSERT INTO products (product_code, product_name, subcategory_id, category_id, supplier_id, brand_id,
                      uom, mrp, purchase_price, warranty_24_12, status)
SELECT 'PRD-ENGOIL-002', '5W40 Synthetic Oil 4L',
       sc.sub_cat_id,
       pc.product_cat_id,
       1,
       3,
       'Litre', 3800, 3200, '24M', 'Active'
FROM sub_categories sc
JOIN product_categories pc ON sc.product_cat_id = pc.product_cat_id
WHERE sc.sub_cat_name = 'Synthetic Oil'
  AND pc.product_cat_name = 'Engine Oil';

INSERT INTO products (product_code, product_name, subcategory_id, category_id, supplier_id, brand_id,
                      uom, mrp, purchase_price, warranty_24_12, status)
SELECT 'PRD-FLTR-001', 'Oil Filter Small',
       sc.sub_cat_id,
       pc.product_cat_id,
       5,
       1,
       'Piece', 450, 300, '12M', 'Active'
FROM sub_categories sc
JOIN product_categories pc ON sc.product_cat_id = pc.product_cat_id
WHERE sc.sub_cat_name = 'Oil Filter'
  AND pc.product_cat_name = 'Filters';

INSERT INTO products (product_code, product_name, subcategory_id, category_id, supplier_id, brand_id,
                      uom, mrp, purchase_price, warranty_24_12, status)
SELECT 'PRD-FLTR-002', 'Air Filter Sedan',
       sc.sub_cat_id,
       pc.product_cat_id,
       5,
       2,
       'Piece', 950, 700, '12M', 'Active'
FROM sub_categories sc
JOIN product_categories pc ON sc.product_cat_id = pc.product_cat_id
WHERE sc.sub_cat_name = 'Air Filter'
  AND pc.product_cat_name = 'Filters';

INSERT INTO products (product_code, product_name, subcategory_id, category_id, supplier_id, brand_id,
                      uom, mrp, purchase_price, warranty_24_12, status)
SELECT 'PRD-BATT-001', '45Ah Battery',
       sc.sub_cat_id,
       pc.product_cat_id,
       4,
       3,
       'Piece', 5500, 4800, '24M', 'Active'
FROM sub_categories sc
JOIN product_categories pc ON sc.product_cat_id = pc.product_cat_id
WHERE sc.sub_cat_name = 'Lead Acid'
  AND pc.product_cat_name = 'Batteries';

INSERT INTO products (product_code, product_name, subcategory_id, category_id, supplier_id, brand_id,
                      uom, mrp, purchase_price, warranty_24_12, status)
SELECT 'PRD-BATT-002', '65Ah MF Battery',
       sc.sub_cat_id,
       pc.product_cat_id,
       4,
       5,
       'Piece', 8500, 7800, '24M', 'Active'
FROM sub_categories sc
JOIN product_categories pc ON sc.product_cat_id = pc.product_cat_id
WHERE sc.sub_cat_name = 'Maintenance Free'
  AND pc.product_cat_name = 'Batteries';

INSERT INTO products (product_code, product_name, subcategory_id, category_id, supplier_id, brand_id,
                      uom, mrp, purchase_price, warranty_24_12, status)
SELECT 'PRD-TYR-001', 'Sedan Tyre 195/65R15',
       sc.sub_cat_id,
       pc.product_cat_id,
       3,
       2,
       'Piece', 7200, 6000, '24M', 'Active'
FROM sub_categories sc
JOIN product_categories pc ON sc.product_cat_id = pc.product_cat_id
WHERE sc.sub_cat_name = 'Sedan Tyre'
  AND pc.product_cat_name = 'Tyres';

INSERT INTO products (product_code, product_name, subcategory_id, category_id, supplier_id, brand_id,
                      uom, mrp, purchase_price, warranty_24_12, status)
SELECT 'PRD-TYR-002', 'SUV Tyre 215/70R16',
       sc.sub_cat_id,
       pc.product_cat_id,
       3,
       4,
       'Piece', 9800, 8200, '24M', 'Active'
FROM sub_categories sc
JOIN product_categories pc ON sc.product_cat_id = pc.product_cat_id
WHERE sc.sub_cat_name = 'SUV Tyre'
  AND pc.product_cat_name = 'Tyres';

INSERT INTO products (product_code, product_name, subcategory_id, category_id, supplier_id, brand_id,
                      uom, mrp, purchase_price, warranty_24_12, status)
SELECT 'PRD-BRK-001', 'Front Disc Pad Set',
       sc.sub_cat_id,
       pc.product_cat_id,
       7,
       1,
       'Set', 3200, 2500, '12M', 'Active'
FROM sub_categories sc
JOIN product_categories pc ON sc.product_cat_id = pc.product_cat_id
WHERE sc.sub_cat_name = 'Disc Brake'
  AND pc.product_cat_name = 'Brake Parts';

INSERT INTO products (product_code, product_name, subcategory_id, category_id, supplier_id, brand_id,
                      uom, mrp, purchase_price, warranty_24_12, status)
SELECT 'PRD-BRK-002', 'Rear Drum Shoe Set',
       sc.sub_cat_id,
       pc.product_cat_id,
       7,
       2,
       'Set', 2800, 2200, '12M', 'Active'
FROM sub_categories sc
JOIN product_categories pc ON sc.product_cat_id = pc.product_cat_id
WHERE sc.sub_cat_name = 'Drum Brake'
  AND pc.product_cat_name = 'Brake Parts';

COMMIT;
