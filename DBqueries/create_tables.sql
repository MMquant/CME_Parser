CREATE TABLE exchange
(
  id serial PRIMARY KEY NOT NULL,
  abbrev character varying(32) UNIQUE NOT NULL,
  name character varying(64) UNIQUE NOT NULL,
  city character varying(32) NOT NULL,
  country character varying(64) NOT NULL,
  currency character varying(32) NOT NULL,
  timezone text NOT NULL,
  created timestamp without time zone NOT NULL DEFAULT now(),
  modified timestamp without time zone DEFAULT now()
);
CREATE TABLE symbol
(
  id serial PRIMARY KEY NOT NULL,
  exchange_abbrev character varying(32) REFERENCES exchange(abbrev) NOT NULL,
  instrument character varying(32) UNIQUE NOT NULL,
  name character varying(64) NOT NULL,
  product_group character varying(64) NOT NULL,
  currency character varying(32) NOT NULL,
  created timestamp without time zone NOT NULL DEFAULT now(),
  modified timestamp without time zone DEFAULT now()
);
CREATE TABLE data_vendor
(
  id serial PRIMARY KEY NOT NULL,
  name character varying(64) UNIQUE NOT NULL,
  web character varying(64) NOT NULL,
  email character varying(64) NOT NULL,
  phone character varying(64) NOT NULL,
  created timestamp without time zone NOT NULL DEFAULT now(),
  modified timestamp without time zone DEFAULT now()
);
CREATE TABLE daily_price
(
  id serial PRIMARY KEY,
  data_vendor_name character varying(64) REFERENCES data_vendor(name) NOT NULL,
  exchange_symbol character varying(32) NOT NULL,
  vendor_symbol character varying(32) NOT NULL,
  complete_symbol character varying(32) REFERENCES symbol(instrument) NOT NULL,
  contract_month character varying(32) NOT NULL,
  price_date date NOT NULL,
  open_price double precision,
  high_price double precision,
  low_price double precision,
  last_price double precision,
  settle double precision,
  volume integer,
  open_interest integer,
  created timestamp without time zone NOT NULL DEFAULT now(),
  modified timestamp without time zone DEFAULT now(),
  UNIQUE (complete_symbol, price_date)
);