--------------------------------------------------
-- CLEAN USER (OPTIONAL FOR DEV)
--------------------------------------------------
-- DROP USER sufioun CASCADE;

CREATE USER sufioun IDENTIFIED BY sufioun
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

GRANT CONNECT, RESOURCE, DBA TO sufioun;

CONNECT sufioun/sufioun;


--------------------------------------------------
-- PARTS CATEGORY
--------------------------------------------------
CREATE TABLE parts_category (
    parts_cat_id    VARCHAR2(50) PRIMARY KEY,
    parts_cat_code  VARCHAR2(50),
    parts_cat_name  VARCHAR2(200),
    status          NUMBER,
    Created_by          VARCHAR2(100),
    Created_Date          DATE,
    Updated_by          VARCHAR2(100),
    Updated_Date          DATE,
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
    :NEW.Created_by := NVL(:NEW.Created_by, USER);
    :NEW.Created_Date := NVL(:NEW.Created_Date, SYSDATE);
  ELSE
    :NEW.Updated_by := NVL(:NEW.Updated_by, USER);
    :NEW.Updated_Date := NVL(:NEW.Updated_Date, SYSDATE);
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
    Created_by         VARCHAR2(100),
    Created_Date         DATE,
    Updated_by         VARCHAR2(100),
    Updated_Date         DATE,
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
    :NEW.Created_by := NVL(:NEW.Created_by, USER);
    :NEW.Created_Date := NVL(:NEW.Created_Date, SYSDATE);
  ELSE
    :NEW.Updated_by := NVL(:NEW.Updated_by, USER);
    :NEW.Updated_Date := NVL(:NEW.Updated_Date, SYSDATE);
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
    Created_Date          DATE,
    Created_by          VARCHAR2(50),
    Updated_by          VARCHAR2(50),
    Updated_Date          DATE,
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
    :NEW.Created_Date := NVL(:NEW.Created_Date,SYSDATE);
    :NEW.Created_by := NVL(:NEW.Created_by,USER);
  ELSE
    :NEW.customer_id := :OLD.customer_id;
    :NEW.Updated_Date := SYSDATE;
    :NEW.Updated_by := USER;
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
    Created_by VARCHAR2(50),
    Created_Date DATE,
    Updated_by VARCHAR2(50),
    Updated_Date DATE
);

CREATE SEQUENCE company_seq START WITH 1;

CREATE OR REPLACE TRIGGER trg_company
BEFORE INSERT OR UPDATE ON company
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.company_id := NVL(:NEW.company_id, company_seq.NEXTVAL);
    :NEW.status := NVL(:NEW.status,1);
    :NEW.Created_by := NVL(:NEW.Created_by,USER);
    :NEW.Created_Date := NVL(:NEW.Created_Date,SYSDATE);
  ELSE
    :NEW.Updated_by := USER;
    :NEW.Updated_Date := SYSDATE;
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
    Created_by VARCHAR2(50),
    Created_Date DATE,
    Updated_by VARCHAR2(50),
    Updated_Date DATE,
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
    Created_by VARCHAR2(50),
    Created_Date DATE,
    Updated_by VARCHAR2(50),
    Updated_Date DATE,
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
    Created_by VARCHAR2(50),
    Created_Date DATE,
    Updated_by VARCHAR2(50),
    Updated_Date DATE
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
    Created_by VARCHAR2(50),
    Created_Date DATE,
    Updated_by VARCHAR2(50),
    Updated_Date DATE
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
    Created_by         VARCHAR2(100),
    Created_Date         DATE,
    Updated_by         VARCHAR2(100),
    Updated_Date         DATE
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
    IF :NEW.Created_by IS NULL THEN :NEW.Created_by := USER; END IF;
    IF :NEW.Created_Date IS NULL THEN :NEW.Created_Date := SYSDATE; END IF;
  ELSIF UPDATING THEN
    IF :NEW.Updated_by IS NULL THEN :NEW.Updated_by := USER; END IF;
    IF :NEW.Updated_Date IS NULL THEN :NEW.Updated_Date := SYSDATE; END IF;
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
    Created_by            VARCHAR2(100),
    Created_Date            DATE,
    Updated_by            VARCHAR2(100),
    Updated_Date            DATE,
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
    IF :NEW.Created_by IS NULL THEN :NEW.Created_by := USER; END IF;
    IF :NEW.Created_Date IS NULL THEN :NEW.Created_Date := SYSDATE; END IF;
  ELSIF UPDATING THEN
    IF :NEW.Updated_by IS NULL THEN :NEW.Updated_by := USER; END IF;
    IF :NEW.Updated_Date IS NULL THEN :NEW.Updated_Date := SYSDATE; END IF;
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
    Created_by            VARCHAR2(100),
    Created_Date            DATE,
    Updated_by            VARCHAR2(100),
    Updated_Date            DATE,
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
    IF :NEW.Created_by IS NULL THEN :NEW.Created_by := USER; END IF;
    IF :NEW.Created_Date IS NULL THEN :NEW.Created_Date := SYSDATE; END IF;
  ELSIF UPDATING THEN
    IF :NEW.Updated_by IS NULL THEN :NEW.Updated_by := USER; END IF;
    IF :NEW.Updated_Date IS NULL THEN :NEW.Updated_Date := SYSDATE; END IF;
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
    Created_by            VARCHAR2(100),
    Created_Date            DATE,
    Updated_by            VARCHAR2(100),
    Updated_Date            DATE,
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
    IF :NEW.Created_by IS NULL THEN :NEW.Created_by := USER; END IF;
    IF :NEW.Created_Date IS NULL THEN :NEW.Created_Date := SYSDATE; END IF;
  ELSIF UPDATING THEN
    IF UPDATING('amount') OR UPDATING('quantity') THEN
      :NEW.line_total := NVL(:NEW.amount,0) * NVL(:NEW.quantity,1);
    END IF;
    IF :NEW.Updated_by IS NULL THEN :NEW.Updated_by := USER; END IF;
    IF :NEW.Updated_Date IS NULL THEN :NEW.Updated_Date := SYSDATE; END IF;
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
    Created_by            VARCHAR2(30),
    Created_Date            DATE,
    Updated_by            VARCHAR2(30),
    Updated_Date            DATE
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
        IF :new.Created_by IS NULL THEN :new.Created_by := USER; END IF;
        IF :new.Created_Date IS NULL THEN :new.Created_Date := SYSDATE; END IF;
    ELSIF UPDATING THEN
        IF :new.Updated_by IS NULL THEN :new.Updated_by := USER; END IF;
        IF :new.Updated_Date IS NULL THEN :new.Updated_Date := SYSDATE; END IF;
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
    Created_by           VARCHAR2(30),
    Created_Date           DATE,
    Updated_by           VARCHAR2(30),
    Updated_Date           DATE,
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
        IF :new.Created_by IS NULL THEN :new.Created_by := USER; END IF;
        IF :new.Created_Date IS NULL THEN :new.Created_Date := SYSDATE; END IF;
   ELSIF UPDATING THEN
        IF :new.Updated_by IS NULL THEN :new.Updated_by := USER; END IF;
        IF :new.Updated_Date IS NULL THEN :new.Updated_Date := SYSDATE; END IF;
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
    Created_by        VARCHAR2(10),
    Created_Date        DATE,
    Updated_by        VARCHAR2(10),
    Updated_Date        DATE
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
        IF :new.Created_by IS NULL THEN :new.Created_by := USER; END IF;
        IF :new.Created_Date IS NULL THEN :new.Created_Date := SYSDATE; END IF;
    ELSIF UPDATING THEN
        IF :new.Updated_by IS NULL THEN :new.Updated_by := USER; END IF;
        IF :new.Updated_Date IS NULL THEN :new.Updated_Date := SYSDATE; END IF;
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
    Created_by VARCHAR2(20),
    Created_Date DATE,
    Updated_by VARCHAR2(20),
    Updated_Date DATE
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
        IF :new.Created_by IS NULL THEN :new.Created_by := USER; END IF;
        IF :new.Created_Date IS NULL THEN :new.Created_Date := SYSDATE; END IF;
    ELSIF UPDATING THEN
        IF :new.Updated_by IS NULL THEN :new.Updated_by := USER; END IF;
        IF :new.Updated_Date IS NULL THEN :new.Updated_Date := SYSDATE; END IF;
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
    Brand_id          NUMBER,
    UOM               VARCHAR2(50),
    MRP               NUMBER,
    purchase_price    NUMBER,
    warranty          VARCHAR2(20),
    Status            VARCHAR2(50),
    Created_by            VARCHAR2(20),
    Created_Date            DATE,
    Updated_by            VARCHAR2(20),
    Updated_Date            DATE,
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
        IF :new.Created_by IS NULL THEN :new.Created_by := USER; END IF;
        IF :new.Created_Date IS NULL THEN :new.Created_Date := SYSDATE; END IF;
    ELSIF UPDATING THEN
        IF :new.Updated_by IS NULL THEN :new.Updated_by := USER; END IF;
        IF :new.Updated_Date IS NULL THEN :new.Updated_Date := SYSDATE; END IF;
    END IF;
END;
/

--------------------------------------------------
-- SAMPLE DATA
--------------------------------------------------


COMMIT;
