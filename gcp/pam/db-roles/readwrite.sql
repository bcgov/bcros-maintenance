DO $$
DECLARE
    schema_name text;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'readwrite') THEN
        CREATE ROLE readwrite;
    END IF;

    -- Loop through all schemas except system schemas
    FOR schema_name IN
        SELECT s.schema_name
        FROM information_schema.schemata s
        WHERE s.schema_name NOT IN ('pg_catalog', 'information_schema') -- Exclude system schemas
    LOOP
        -- Grant USAGE on the schema
        EXECUTE format('GRANT USAGE ON SCHEMA %I TO readwrite;', schema_name);

        -- Grant SELECT, INSERT, UPDATE, DELETE on all existing tables in the schema
        EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA %I TO readwrite;', schema_name);

        -- Set default privileges for future tables
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO readwrite;', schema_name);
    END LOOP;
END;
$$;
