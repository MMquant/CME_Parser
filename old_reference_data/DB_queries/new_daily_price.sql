-- Table: daily_price_staging

-- DROP TABLE daily_price_staging;

CREATE TABLE daily_price_staging
(
  id serial NOT NULL,
  data_vendor_name character varying(64) NOT NULL,
  exchange_symbol character varying(32) NOT NULL,
  vendor_symbol character varying(32) NOT NULL,
  complete_symbol character varying(32) NOT NULL,
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
  CONSTRAINT daily_price_staging_pkey PRIMARY KEY (id),
  CONSTRAINT daily_price_staging__data_vendor_name_fkey FOREIGN KEY (data_vendor_name)
      REFERENCES data_vendor (name) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT daily_price_staging__exchange_symbol_fkey FOREIGN KEY (exchange_symbol)
      REFERENCES symbol (instrument) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE daily_price_staging
  OWNER TO admin;
GRANT ALL ON TABLE daily_price_staging TO admin;
GRANT ALL ON TABLE daily_price_staging TO maple;

-- Trigger: update_daily_price__staging_modified on daily_price

-- DROP TRIGGER update_daily_price_staging_modified ON daily_price;

CREATE TRIGGER update_daily_price_staging_modified
  BEFORE UPDATE
  ON daily_price_staging
  FOR EACH ROW
  EXECUTE PROCEDURE update_modified_column();