DROP SCHEMA IF EXISTS foodie_fi;
CREATE SCHEMA foodie_fi;
USE foodie_fi;

CREATE TABLE plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(20),
    price DECIMAL(5,2)
);

CREATE TABLE subscriptions (
    customer_id INT,
    plan_id INT,
    start_date DATE,
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);