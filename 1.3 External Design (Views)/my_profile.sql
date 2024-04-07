create or replace view my_profile as (
    select 
        cl.username as username,
        cl.name as name,
        cl.surn1 as surn1,
        NVL(cl.surn2, '----') as surn2,
        NVL(cl.email, '----') as email,
        NVL(cast(cl.mobile AS VARCHAR(10)), '----') as mobile,
        cast(cl.voucher AS VARCHAR(10)) as voucher,
        NVL(cast(cl.voucher_exp AS VARCHAR(10)), '----') as voucher_exp,
        waytype as waytype,
        wayname as wayname,
        NVL(a.gate, '----') as gate,
        NVL(a.block, '----') as block,
        NVL(a.stairw, '----') as stairw, 
        NVL(a.floor, '----') as floor,
        NVL(a.door, '----') as door ,
        a.ZIP as ZIP,
        a.town as town,
        a.country as country,
        CAST(cc.cardnum AS VARCHAR(16)) as cardnum,
        cc.card_comp as card_comp,
        cc.card_holder as card_holder,
        RPAD(TO_CHAR(cc.card_expir, 'MM-YY'), 10, ' ') as card_expir
    from Clients cl 
    left join Client_Addresses a on cl.username = a.username
    left join Client_Cards cc on cl.username = cc.username
    where cl.username = current_user
) with read only;
select * from my_profile;

-- Interestingly, this does not work, as there are repeated columns in the view, namely the username column.
create or replace view my_profile2 as (
    select * 
    from Clients cl
    left join Client_Addresses a on cl.username = a.username
    left join Client_Cards cc on cl.username = cc.username
    where cl.username = current_user
)