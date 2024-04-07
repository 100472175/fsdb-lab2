insert into my_purchases (anything)

delete from my_purchases where orderdate = '12-12-2015';

delete from client_lines where username=current_user and extract(YEAR FROM orderdate)=2021 and extract(MONTH FROM orderdate)=1;

delete from client_lines where 1=1;

