CREATE OR REPLACE FUNCTION update_modified_column()	
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified = now();
    RETURN NEW;	
END;
$$ language 'plpgsql';

CREATE TRIGGER update_daily_price_modified
BEFORE UPDATE
ON daily_price
FOR EACH ROW
EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_data_vendor_modified
BEFORE UPDATE
ON data_vendor
FOR EACH ROW
EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_exchange_modified
BEFORE UPDATE
ON exchange
FOR EACH ROW
EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_symbol_modified
BEFORE UPDATE
ON symbol
FOR EACH ROW
EXECUTE PROCEDURE update_modified_column();