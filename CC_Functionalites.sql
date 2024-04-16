DROP TABLE IF EXISTS creditcard.customer_audit;
create table creditcard.customer_audit (
	cust_id serial,
	first_name varchar(100),
	last_name varchar(100),
	date_of_birth date,
	address varchar(255),
	age INT,
	gender creditcard.sex,
	email varchar(100),
	phone varchar(15),
	job varchar(50),
	is_married bool,
	delete_on_date date
);

CREATE OR REPLACE FUNCTION cust_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO creditcard.customer_audit(cust_id, first_name, last_name, date_of_birth, address, age, gender, email, phone, job, is_married, delete_on_date)
        VALUES (OLD.cust_id, OLD.first_name, OLD.last_name, OLD.date_of_birth, OLD.address, OLD.age, OLD.gender, OLD.email, OLD.phone, OLD.job, OLD.is_married, current_date);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO creditcard.customer_audit(cust_id, first_name, last_name, date_of_birth, address, age, gender, email, phone, job, is_married, delete_on_date)
        VALUES (OLD.cust_id, OLD.first_name, OLD.last_name, OLD.date_of_birth, OLD.address, OLD.age, OLD.gender, OLD.email, OLD.phone, OLD.job, OLD.is_married, current_date);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cust_audit
BEFORE UPDATE OR DELETE
ON creditcard.customer
FOR EACH ROW
EXECUTE FUNCTION cust_audit();





DROP TABLE IF EXISTS creditcard.credit_card_type_audit;
create table creditcard.credit_card_type_audit (
	card_type_id int,
	card_type_name varchar(100),
	emv_enable boolean,
	signup_bonus int,
	delete_on_date date
);	

CREATE OR REPLACE FUNCTION cc_type_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO creditcard.credit_card_type_audit(card_type_id, card_type_name, emv_enable, signup_bonus, delete_on_date)
        VALUES (OLD.card_type_id, OLD.card_type_name, OLD.emv_enable, OLD.signup_bonus, current_date);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO creditcard.credit_card_type_audit(card_type_id, card_type_name, emv_enable, signup_bonus, delete_on_date)
        VALUES (OLD.card_type_id, OLD.card_type_name, OLD.emv_enable, OLD.signup_bonus, current_date);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cc_type_audit
BEFORE UPDATE OR DELETE
ON creditcard.credit_card_type
FOR EACH ROW
EXECUTE FUNCTION cc_type_audit();



DROP TABLE IF EXISTS creditcard.offers_audit;
create table creditcard.offers_audit (
	offer_id int,
	offer_name varchar(100),
	offer_desc text,
	offer_type varchar(100),
	delete_on_date date
);

CREATE OR REPLACE FUNCTION offer_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO creditcard.offers_audit(offer_id, offer_name, offer_desc, offer_type, delete_on_date)
        VALUES (OLD.offer_id, OLD.offer_name, OLD.offer_desc, OLD.offer_type, current_date);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO creditcard.offers_audit(offer_id, offer_name, offer_desc, offer_type, delete_on_date)
        VALUES (OLD.offer_id, OLD.offer_name, OLD.offer_desc, OLD.offer_type, current_date);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER offer_audit
BEFORE UPDATE OR DELETE
ON creditcard.offers
FOR EACH ROW
EXECUTE FUNCTION offer_audit();



DROP TABLE IF EXISTS creditcard.cust_card_audit;
create table creditcard.cust_card_audit (
	card_no bigint,
	cust_id int,
	card_type_id int,
	valid_from date,
	valid_till date,
	cvv int,
	pin int,
	reward_pts int,
	Status creditcard.IsActive,
	DOJ date,
	Statement_date date,
	delete_on_date date
);

CREATE OR REPLACE FUNCTION custcard_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO creditcard.cust_card_audit(card_no ,cust_id ,card_type_id ,valid_from ,valid_till ,cvv ,pin  ,reward_pts ,Status ,DOJ ,Statement_date ,delete_on_date)
        VALUES (OLD.card_no ,OLD. cust_id ,OLD. card_type_id ,OLD. valid_from ,OLD. valid_till ,OLD. cvv ,OLD. pin  ,OLD. reward_pts ,OLD. Status ,OLD. DOJ ,OLD. Statement_date, current_date);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO creditcard.cust_card_audit(card_no ,cust_id ,card_type_id ,valid_from ,valid_till ,cvv ,pin  ,reward_pts ,Status ,DOJ ,Statement_date ,delete_on_date)
        VALUES (OLD.card_no ,OLD. cust_id ,OLD. card_type_id ,OLD. valid_from ,OLD. valid_till ,OLD. cvv ,OLD. pin  ,OLD. reward_pts ,OLD. Status ,OLD. DOJ ,OLD. Statement_date, current_date);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER custcard_audit
BEFORE UPDATE OR DELETE
ON creditcard.cust_card
FOR EACH ROW
EXECUTE FUNCTION custcard_audit();



DROP TABLE IF EXISTS creditcard.offer_card_audit;
create table creditcard.offer_card_audit (
	card_type_id int,
	offer_id int,
	delete_on_date date
);

CREATE OR REPLACE FUNCTION offercard_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO creditcard.offer_card_audit(card_type_id, offer_id, delete_on_date)
        VALUES (OLD.card_type_id ,OLD.offer_id, current_date);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO creditcard.offer_card_audit(card_type_id, offer_id, delete_on_date)
        VALUES (OLD.card_type_id ,OLD.offer_id, current_date);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER offercard_audit
BEFORE UPDATE OR DELETE
ON creditcard.offer_card
FOR EACH ROW
EXECUTE FUNCTION offercard_audit();





--updation of reward points function according to the card type
CREATE OR REPLACE FUNCTION creditcard.update_reward_points()
RETURNS TRIGGER AS $$
DECLARE
    multiplier INT;
BEGIN
    SELECT points_multiplier INTO multiplier
    FROM creditcard.credit_card_type
    WHERE card_type_id = NEW.card_type_id;

    NEW.reward_pts = NEW.reward_pts + (NEW.transaction_amount * multiplier);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--trigger for the reward point update function
CREATE TRIGGER update_reward_trigger
AFTER INSERT ON creditcard.transaction
FOR EACH ROW
WHEN (NEW.cust_id IS NOT NULL)
EXECUTE FUNCTION creditcard.update_reward_points();

--function for the signup bonus addition in the reward points
CREATE OR REPLACE FUNCTION creditcard.add_signup_bonus()
RETURNS TRIGGER AS $$
BEGIN
    NEW.reward_pts = NEW.reward_pts + NEW.signup_bonus;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--trigger for the function of signup bonus
CREATE TRIGGER add_signup_bonus_trigger
BEFORE INSERT ON creditcard.cust_card
FOR EACH ROW
EXECUTE FUNCTION creditcard.add_signup_bonus();