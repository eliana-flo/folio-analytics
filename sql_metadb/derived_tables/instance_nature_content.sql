--metadb:table instance_nature_content

-- Create derived table for instance nature of content with uuid and name.

DROP TABLE IF EXISTS instance_nature_content;

CREATE TABLE instance_nature_content AS
WITH nature_content AS (
    SELECT
        i.id AS instance_id,
        jsonb_extract_path_text(i.jsonb, 'hrid') AS instance_hrid,
        nature_of_content_term_ids.jsonb #>> '{}' AS nature_of_content_term_id,
        nature_of_content_term_ids.ordinality AS nature_of_content_ordinality
    FROM
        folio_inventory.instance AS i
        CROSS JOIN jsonb_array_elements(jsonb_extract_path(i.jsonb, 'natureOfContentTermIds')) WITH ORDINALITY AS nature_of_content_term_ids (jsonb)
)
SELECT
    nc.instance_id,
    nc.instance_hrid,
    nc.nature_of_content_term_id::uuid,
    noctt.name AS nature_of_content_term_name,
    noctt.source AS nature_of_content_term_source,
    nc.nature_of_content_ordinality
FROM
    nature_content AS nc
    LEFT JOIN folio_inventory.nature_of_content_term__t AS noctt ON nc.nature_of_content_term_id::uuid = noctt.id::uuid;

CREATE INDEX ON instance_nature_content (instance_id);

CREATE INDEX ON instance_nature_content (instance_hrid);

CREATE INDEX ON instance_nature_content (nature_of_content_term_id);

CREATE INDEX ON instance_nature_content (nature_of_content_term_name);

CREATE INDEX ON instance_nature_content (nature_of_content_term_source);

CREATE INDEX ON instance_nature_content (nature_of_content_ordinality);

VACUUM ANALYZE instance_nature_content;

