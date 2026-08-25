-- ==============================================================================
-- AJAY INFOTECH — FIX & PROVISION STUDENT B IN AUTH.USERS
-- ==============================================================================

-- Delete incomplete Student B user if exists
DELETE FROM public.profiles WHERE email = 'student_b@ajayinfotech.in';
DELETE FROM auth.users WHERE email = 'student_b@ajayinfotech.in';

-- Clean Insert for Student B
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    invited_at,
    confirmation_token,
    confirmation_sent_at,
    recovery_token,
    recovery_sent_at,
    email_change_token_new,
    email_change,
    email_change_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    created_at,
    updated_at,
    phone,
    phone_confirmed_at,
    phone_change,
    phone_change_token,
    phone_change_sent_at,
    email_change_token_current,
    email_change_confirm_status,
    banned_until,
    reauthentication_token,
    reauthentication_sent_at,
    is_sso_user,
    deleted_at
)
VALUES (
    '00000000-0000-0000-0000-000000000000',
    'b0000000-0000-0000-0000-000000000002',
    'authenticated',
    'authenticated',
    'student_b@ajayinfotech.in',
    crypt('password123', gen_salt('bf')),
    NOW(),
    NULL, '', NULL, '', NULL, '', '', NULL, NOW(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Priya Patel","student_id":"AI-2026-9011"}',
    FALSE,
    NOW(),
    NOW(),
    NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, FALSE, NULL
)
ON CONFLICT (id) DO NOTHING;

-- Profile for Student B
INSERT INTO public.profiles (
    id,
    student_id,
    full_name,
    email,
    phone,
    avatar_url,
    program,
    batch_code,
    enrolled_date,
    overall_attendance,
    role
)
VALUES (
    'b0000000-0000-0000-0000-000000000002',
    'AI-2026-9011',
    'Priya Patel (Student B)',
    'student_b@ajayinfotech.in',
    '+91 91234 56789',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
    'Full Stack Web & Mobile App Development (MERN & Flutter)',
    'MERN-2026-B1',
    '2026-01-20',
    92.0,
    'student'
)
ON CONFLICT (id) DO NOTHING;
