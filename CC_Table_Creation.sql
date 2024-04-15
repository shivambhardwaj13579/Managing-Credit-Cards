--Drop schema if exists creditcard cascade;
create schema creditcard;
create extension if not exists pgcrypto;

create or replace function creditcard.calculate_age(birth_date DATE) RETURNS INT AS $$
    BEGIN
        return extract(YEAR FROM AGE(CURRENT_DATE, birth_date));
    END;
$$ LANGUAGE plpgsql IMMUTABLE;
create type creditcard.sex as enum('male', 'female', 'other');
DROP TABLE IF EXISTS creditcard.customer;
create table creditcard.customer (
	cust_id serial primary Key,
	first_name varchar(100) not null,
	last_name varchar(100),
	date_of_birth date not null,
	address varchar(255) not null,
	age INT GENERATED ALWAYS AS (creditcard.calculate_age(date_of_birth)) STORED,
	gender creditcard.sex not null,
	email varchar(100) not null,
	phone varchar(15) not null,
	job varchar(50) not null,
	is_married bool
);


DROP TABLE IF EXISTS creditcard.credit_card_type;
create table creditcard.credit_card_type (
	card_type_id int primary key,
	card_type_name varchar(100) not null,
	emv_enable boolean not null,
	signup_bonus int,
	ponits_multiplier INT
);	


DROP TABLE IF EXISTS creditcard.offers;
create table creditcard.offers (
	offer_id int primary key,
	offer_name varchar(100) not null,
	offer_desc text not null,
	offer_type varchar(100) not null
);

create type creditcard.IsActive as enum('active', 'inactive');
DROP TABLE IF EXISTS creditcard.cust_card;
create table creditcard.cust_card (
	card_no bigint unique not null,
	cust_id int references creditcard.customer(cust_id),
	card_type_id int references creditcard.credit_card_type(card_type_id),
	valid_from date not null,
	valid_till date not null,
	cvv int not null,
	pin int not null,
	reward_pts int,
	Status creditcard.IsActive not null,
	DOJ date not null,
	Statement_date date not null
);


DROP TABLE IF EXISTS creditcard.offer_card;
create table creditcard.offer_card (
	card_type_id int not null references creditcard.credit_card_type(card_type_id),
	offer_id int not null references creditcard.offers(offer_id)
);


create type creditcard.payment_mode as enum('online', 'offline');
DROP TABLE IF EXISTS creditcard.transaction;
create table creditcard.transaction (
	transact_id varchar(50) primary key,
	cust_id int references creditcard.customer(cust_id),
	card_type_id int references creditcard.credit_card_type(card_type_id), 
	transaction_time timestamp,
	mode_of_payment creditcard.payment_mode not null,
	transaction_amount decimal(10,2) not null,
	card_no bigint 
);


DROP TABLE IF EXISTS creditcard.offers_used;
create table creditcard.offers_used (
	cust_id int references creditcard.customer(cust_id),
	card_type_id int references creditcard.credit_card_type(card_type_id),
	offer_id int references creditcard.offers(offer_id),
	transact_id varchar(50) references creditcard.transaction(transact_id)
);
	

DROP TABLE IF EXISTS creditcard.Billing;
CREATE TABLE IF NOT EXISTS creditcard.Billing(
	card_no bigint references creditcard.cust_card (card_no),
	cust_id int references creditcard.customer(cust_id),
    billing_amount decimal(10,2) NOT NULL,
    Due_Date date NOT NULL,
	Payment_Date date not null,
    Late_fee_charges decimal(10,2),
	Statement_date date,
    CONSTRAINT Billing_pkey PRIMARY KEY(Card_no)
);


ALTER TABLE creditcard.cust_card
ADD PRIMARY KEY (cust_id, card_type_id);