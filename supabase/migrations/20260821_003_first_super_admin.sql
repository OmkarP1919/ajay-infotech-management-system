-- ==============================================================================
-- AJAY INFOTECH — MIGRATION 003: FIRST SUPER ADMIN SETUP SCRIPT
-- Run this ONCE after migrations 001 and 002
-- You must first create the auth user via Supabase Dashboard or Auth API,
-- then run this to grant them super_admin privileges.
--
-- INSTRUCTIONS:
-- 1. Go to https://supabase.com/dashboard/project/fsibagcyyducyurkdoii/auth/users
-- 2. Click "Add User" → Enter admin email & password
-- 3. Copy the generated UUID from the user list
-- 4. Replace 'YOUR-ADMIN-USER-UUID-HERE' below with that UUID
-- 5. Replace 'admin@ajayinfotech.in' with the actual email
-- 6. Run this script in the SQL Editor
-- ==============================================================================

-- STEP 1: Set these variables
DO $$
DECLARE
    v_admin_id UUID := '608b2917-a6aa-4a71-8dfb-659b636224e7'; -- Replace with actual UUID
    v_admin_email TEXT := 'admin@gmail.com';  -- Replace with actual email
    v_admin_name TEXT := 'Admin User';              -- Replace with actual name
BEGIN
    -- Insert super admin record (skip if already exists)
    INSERT INTO public.admin_users (
        id,
        full_name,
        email,
        role,
        is_active
    )
    VALUES (
        v_admin_id,
        v_admin_name,
        v_admin_email,
        'super_admin',
        TRUE
    )
    ON CONFLICT (id) DO UPDATE
        SET role = 'super_admin',
            is_active = TRUE,
            updated_at = NOW();

    -- Audit the action
    INSERT INTO public.audit_logs (admin_id, action, entity_type, entity_id, new_values)
    VALUES (
        v_admin_id,
        'SUPER_ADMIN_CREATED',
        'admin_users',
        v_admin_id::text,
        jsonb_build_object('email', v_admin_email, 'role', 'super_admin')
    );

    RAISE NOTICE 'Super admin % created successfully', v_admin_email;
END $$;
