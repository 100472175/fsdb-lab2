SELECT trigger_name, trigger_type, triggering_event, table_name, owner
FROM ALL_TRIGGERS
WHERE owner = 'FSDB279';

SELECT owner, 
    LISTAGG(trigger_name, ', ') WITHIN GROUP (ORDER BY trigger_name) AS concatenated_names,
    LISTAGG(trigger_type, ', ') WITHIN GROUP (ORDER BY trigger_name) AS concatenated_types,
    LISTAGG(triggering_event, ', ') WITHIN GROUP (ORDER BY trigger_name) AS concatenated_events,
    LISTAGG(table_name, ', ') WITHIN GROUP (ORDER BY trigger_name) AS concatenated_tables
FROM ALL_TRIGGERS
GROUP BY owner;
