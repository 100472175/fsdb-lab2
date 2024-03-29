select barcode, quantity from Lines_Anonym where trim(dliv_country)='Venezuela';
select barcode, quantity from Client_Lines where trim(country)='Venezuela';