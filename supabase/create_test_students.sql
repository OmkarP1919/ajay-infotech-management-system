-- ==============================================================================
-- AJAY INFOTECH — LINK PROFILES, FEES & ATTENDANCE TO AUTH.USERS
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

DO $$
DECLARE
    v_user_a_id UUID;
    v_user_b_id UUID;
    v_fee_id UUID := 'f0000000-0000-0000-0000-000000000001';
BEGIN
    -- Check or Insert Student A
    SELECT id INTO v_user_a_id FROM auth.users WHERE email = 'student_a@ajayinfotech.in';
    IF v_user_a_id IS NULL THEN
        v_user_a_id := 'a0000000-0000-0000-0000-000000000001';
        INSERT INTO auth.users (
            instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
            raw_app_meta_data, raw_user_meta_data, created_at, updated_at
        ) VALUES (
            '00000000-0000-0000-0000-000000000000', v_user_a_id, 'authenticated', 'authenticated',
            'student_a@ajayinfotech.in', crypt('password123', gen_salt('bf')), NOW(),
            '{"provider":"email","providers":["email"]}', '{"full_name":"Rohit Sharma","student_id":"AI-2026-8842"}',
            NOW(), NOW()
        );
    ELSE
        -- Ensure email is confirmed and password is set to password123
        UPDATE auth.users
        SET encrypted_password = crypt('password123', gen_salt('bf')),
            email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
            updated_at = NOW()
        WHERE id = v_user_a_id;
    END IF;

    -- Check or Insert Student B
    SELECT id INTO v_user_b_id FROM auth.users WHERE email = 'student_b@ajayinfotech.in';
    IF v_user_b_id IS NULL THEN
        v_user_b_id := 'b0000000-0000-0000-0000-000000000002';
        INSERT INTO auth.users (
            instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
            raw_app_meta_data, raw_user_meta_data, created_at, updated_at
        ) VALUES (
            '00000000-0000-0000-0000-000000000000', v_user_b_id, 'authenticated', 'authenticated',
            'student_b@ajayinfotech.in', crypt('password123', gen_salt('bf')), NOW(),
            '{"provider":"email","providers":["email"]}', '{"full_name":"Priya Patel","student_id":"AI-2026-9011"}',
            NOW(), NOW()
        );
    ELSE
        UPDATE auth.users
        SET encrypted_password = crypt('password123', gen_salt('bf')),
            email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
            updated_at = NOW()
        WHERE id = v_user_b_id;
    END IF;

    -- 2. Insert or Update Profile for Student A
    INSERT INTO public.profiles (
        id, student_id, full_name, email, phone, avatar_url, program, batch_code, enrolled_date, overall_attendance, role
    )
    VALUES (
        v_user_a_id, 'AI-2026-8842', 'Rohit Sharma (Student A)', 'student_a@ajayinfotech.in', '+91 98765 43210',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
        'Full Stack Web & Mobile App Development (MERN & Flutter)', 'MERN-2026-B1', '2026-01-15', 88.5, 'student'
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        overall_attendance = EXCLUDED.overall_attendance;

    -- 3. Insert or Update Profile for Student B
    INSERT INTO public.profiles (
        id, student_id, full_name, email, phone, avatar_url, program, batch_code, enrolled_date, overall_attendance, role
    )
    VALUES (
        v_user_b_id, 'AI-2026-9011', 'Priya Patel (Student B)', 'student_b@ajayinfotech.in', '+91 91234 56789',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
        'Full Stack Web & Mobile App Development (MERN & Flutter)', 'MERN-2026-B1', '2026-01-20', 92.0, 'student'
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        overall_attendance = EXCLUDED.overall_attendance;

    -- 4. Fee Ledgers for Student A
    INSERT INTO public.fees (id, student_id, total_fee, paid_amount, outstanding_amount, next_due_date)
    VALUES (
        v_fee_id, v_user_a_id, 45000.00, 30000.00, 15000.00, '2026-09-15'
    )
    ON CONFLICT (id) DO UPDATE SET
        student_id = v_user_a_id,
        outstanding_amount = 15000.00;

    -- Installments
    INSERT INTO public.fee_installments (id, fee_id, title, amount, due_date, paid_date, receipt_no, status)
    VALUES
    ('f1000000-0000-0000-0000-000000000001', v_fee_id, 'Installment 1: Admission & Registration', 15000.00, '2026-01-15', '2026-01-15', 'AI-REC-2026-0112', 'paid'),
    ('f1000000-0000-0000-0000-000000000002', v_fee_id, 'Installment 2: Mid-Term Module Fee', 15000.00, '2026-02-15', '2026-02-14', 'AI-REC-2026-0489', 'paid'),
    ('f1000000-0000-0000-0000-000000000003', v_fee_id, 'Installment 3: Final Certification Fee', 15000.00, '2026-09-15', NULL, NULL, 'pending')
    ON CONFLICT (id) DO NOTHING;

    -- 5. Attendance Records for Student A
    DELETE FROM public.attendance WHERE student_id = v_user_a_id;
    INSERT INTO public.attendance (student_id, subject, date, day, status)
    VALUES
    (v_user_a_id, 'Flutter & State Management', '2026-02-20', 'Friday', 'present'),
    (v_user_a_id, 'PostgreSQL & Supabase Architecture', '2026-02-19', 'Thursday', 'present'),
    (v_user_a_id, 'REST API & PostgREST', '2026-02-18', 'Wednesday', 'absent'),
    (v_user_a_id, 'Razorpay Payment Gateway', '2026-02-17', 'Tuesday', 'present');

END $$;
