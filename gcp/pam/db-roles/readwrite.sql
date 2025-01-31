DO $$
DECLARE
    schema_name text;
    sequence_name text;
    type_name text;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'readwrite') THEN
        CREATE ROLE readwrite;
    END IF;
    -- Loop through all schemas except system schemas
    FOR schema_name IN
        SELECT s.schema_name
        FROM information_schema.schemata s
        WHERE s.schema_name NOT IN ('pg_catalog', 'information_schema')
    LOOP
        BEGIN
            -- Grant USAGE on the schema
            EXECUTE format('GRANT USAGE ON SCHEMA %I TO readwrite;', schema_name);

            -- Grant privileges on all existing tables
            EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA %I TO readwrite;', schema_name);

            -- Set default privileges for future tables
            EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO readwrite;', schema_name);

            -- Grant privileges on all existing sequences
            EXECUTE format('GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA %I TO readwrite;', schema_name);

            -- Set default privileges for future sequences
            EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT USAGE, SELECT ON SEQUENCES TO readwrite;', schema_name);

            -- Grant EXECUTE on all existing functions
            EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA %I TO readwrite;', schema_name);

            -- Set default privileges for future functions
            EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT EXECUTE ON FUNCTIONS TO readwrite;', schema_name);

            -- Grant USAGE on all user-defined types (composite and enum types)
            FOR type_name IN
                SELECT t.typname
                FROM pg_type t
                JOIN pg_namespace n ON t.typnamespace = n.oid
                WHERE n.nspname = schema_name AND t.typcategory IN ('C', 'E')
            LOOP
                EXECUTE format('GRANT USAGE ON TYPE %I.%I TO readwrite;', schema_name, type_name);
            END LOOP;

            -- Note: Default privileges for future types are not supported in PostgreSQL
        EXCEPTION
            WHEN others THEN
                RAISE WARNING 'Failed to apply privileges in schema %: %', schema_name, SQLERRM;
        END;
    END LOOP;
END $$;
