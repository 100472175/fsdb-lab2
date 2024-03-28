create or replace view my_profile as (
    select 
        NVL(cl.username, 'NaN') as username,
        NVL(cl.name, 'NaN') as name,
        NVL(cl.surn1, 'NaN') as surn1,
        NVL(cl.surn2, 'NaN') as surn2,
        NVL(cl.email, 'NaN') as email,
        NVL(cast(cl.mobile AS VARCHAR(10)), 'NaN') as mobile,
        NVL(cast(cl.voucher AS VARCHAR(10)), 'NaN') as voucher,
        NVL(cast(cl.voucher_exp AS VARCHAR(10)), 'NaN') as voucher_exp,
        NVL(a.waytype, 'NaN') as waytype,
        NVL(a.wayname, 'NaN')as wayname,
        NVL(a.gate, 'NaN') as gate,
        NVL(a.block, 'NaN') as block,
        NVL(a.stairw, 'NaN') as stairw, 
        NVL(a.floor, 'NaN') as floor,
        NVL(a.door, 'NaN') as door ,
        NVL(a.ZIP, 'NaN') as ZIP,
        NVL(a.town, 'NaN') as town,
        NVL(a.country, 'NaN') as country,
        NVL(cast(c.cardnum AS VARCHAR(16)), 'NaN') as cardnum,
        NVL(c.card_comp, 'NaN') as card_comp,
        NVL(c.card_holder, 'NaN') as card_holder,
        RPAD(NVL(TO_CHAR(c.card_expir, 'MM-YY'), 'NaN'), 10, ' ') as card_expir
    from Clients cl 
    left join Client_Addresses a on cl.username = a.username
    left join Client_Cards c on cl.username = c.username
    where cl.username = current_user
);
select * from my_profile;

-- Interestingly, this does not work, as there are repeated columns in the view, namely the username column.
create or replace view my_profile2 as (
    select * 
    from Clients cl
    left join Client_Addresses a on cl.username = a.username
    left join Client_Cards c on cl.username = c.username
    where cl.username = current_user
)