-- ==============================================================================
-- AJAY INFOTECH — PHASE 2: STORAGE, RLS POLICIES & STUDENT B PROVISIONING
-- Run this script in the Supabase Cloud SQL Editor (Project: fsibagcyyducyurkdoii)
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 1. CREATE ASSIGNMENT SUBMISSIONS TABLE FIRST (TABLE #16)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.assignment_submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    assignment_title VARCHAR(256) NOT NULL,
    file_name VARCHAR(256) NOT NULL,
    file_size VARCHAR(32) NOT NULL,
    file_url TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(32) DEFAULT 'submitted',
    grade VARCHAR(16),
    feedback TEXT
);

CREATE INDEX IF NOT EXISTS idx_assignment_submissions_student ON public.assignment_submissions(student_id);
ALTER TABLE public.assignment_submissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Students can view own submissions" ON public.assignment_submissions;
DROP POLICY IF EXISTS "Students can create own submissions" ON public.assignment_submissions;

CREATE POLICY "Students can view own submissions" ON public.assignment_submissions
    FOR SELECT USING (auth.uid() = student_id);

CREATE POLICY "Students can create own submissions" ON public.assignment_submissions
    FOR INSERT WITH CHECK (auth.uid() = student_id);

-- ==============================================================================
-- 2. CLEAN PROVISIONING FOR STUDENT B IN AUTH.USERS & AUTH.IDENTITIES
-- ==============================================================================
DO $$
DECLARE
    v_user_b_id UUID := 'b0000000-0000-0000-0000-000000000002';
    v_fee_b_id UUID := 'f0000000-0000-0000-0000-000000000002';
    v_identity_id UUID := 'b7000000-0000-0000-0000-000000000002';
BEGIN
    -- Delete existing Student B data to prevent duplicates
    DELETE FROM public.assignment_submissions WHERE student_id = v_user_b_id;
    DELETE FROM public.payments WHERE student_id = v_user_b_id;
    DELETE FROM public.fee_installments WHERE fee_id = v_fee_b_id;
    DELETE FROM public.fees WHERE student_id = v_user_b_id;
    DELETE FROM public.attendance WHERE student_id = v_user_b_id;
    DELETE FROM public.profiles WHERE email = 'student_b@ajayinfotech.in' OR id = v_user_b_id;
    DELETE FROM auth.identities WHERE user_id = v_user_b_id OR id = v_identity_id;
    DELETE FROM auth.users WHERE email = 'student_b@ajayinfotech.in' OR id = v_user_b_id;

    -- Insert Student B into auth.users with confirmed email and password 'password123'
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
        v_user_b_id,
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
    );

    -- Insert identity for Student B (required for Supabase GoTrue Auth)
    INSERT INTO auth.identities (
        id,
        user_id,
        identity_data,
        provider,
        provider_id,
        last_sign_in_at,
        created_at,
        updated_at
    )
    VALUES (
        v_identity_id,
        v_user_b_id,
        jsonb_build_object('sub', v_user_b_id::text, 'email', 'student_b@ajayinfotech.in'),
        'email',
        v_user_b_id::text,
        NOW(),
        NOW(),
        NOW()
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
        v_user_b_id,
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
    );

    -- Fees for Student B
    INSERT INTO public.fees (
        id,
        student_id,
        total_fee,
        paid_amount,
        outstanding_amount,
        next_due_date
    )
    VALUES (
        v_fee_b_id,
        v_user_b_id,
        45000.00,
        15000.00,
        30000.00,
        '2026-08-30'
    );

    -- Installments for Student B
    INSERT INTO public.fee_installments (
        id,
        fee_id,
        title,
        amount,
        due_date,
        paid_date,
        receipt_no,
        status
    )
    VALUES
    ('f1000000-0000-0000-0000-000000000011', v_fee_b_id, 'Installment 1: Admission & Registration', 15000.00, '2026-01-20', '2026-01-20', 'AI-REC-2026-0189', 'paid'),
    ('f1000000-0000-0000-0000-000000000012', v_fee_b_id, 'Installment 2: Mid-Term Module Fee', 15000.00, '2026-08-30', NULL, NULL, 'pending'),
    ('f1000000-0000-0000-0000-000000000013', v_fee_b_id, 'Installment 3: Final Certification Fee', 15000.00, '2026-11-30', NULL, NULL, 'pending');

    -- Attendance for Student B
    INSERT INTO public.attendance (student_id, subject, date, day, status)
    VALUES
    (v_user_b_id, 'Flutter & State Management', '2026-02-20', 'Friday', 'present'),
    (v_user_b_id, 'PostgreSQL & Supabase Architecture', '2026-02-19', 'Thursday', 'present'),
    (v_user_b_id, 'REST API & PostgREST', '2026-02-18', 'Wednesday', 'present'),
    (v_user_b_id, 'Razorpay Payment Gateway', '2026-02-17', 'Tuesday', 'present');

END $$;

-- ==============================================================================
-- 3. STRICT RLS POLICIES FOR DATABASE TABLES
-- ==============================================================================
-- Strict Profiles RLS
DROP POLICY IF EXISTS "Students can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Students can update own profile" ON public.profiles;
CREATE POLICY "Students can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Students can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Strict Attendance RLS
DROP POLICY IF EXISTS "Students can view own attendance" ON public.attendance;
CREATE POLICY "Students can view own attendance" ON public.attendance
    FOR SELECT USING (auth.uid() = student_id);

-- Strict Fees RLS
DROP POLICY IF EXISTS "Students can view own fees" ON public.fees;
CREATE POLICY "Students can view own fees" ON public.fees
    FOR SELECT USING (auth.uid() = student_id);

-- Strict Fee Installments RLS
DROP POLICY IF EXISTS "Students can view own installments" ON public.fee_installments;
CREATE POLICY "Students can view own installments" ON public.fee_installments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.fees WHERE fees.id = fee_installments.fee_id AND fees.student_id = auth.uid()
        )
    );

-- Strict Payments RLS
DROP POLICY IF EXISTS "Students can view own payments" ON public.payments;
CREATE POLICY "Students can view own payments" ON public.payments
    FOR SELECT USING (auth.uid() = student_id);

-- ==============================================================================
-- 4. CREATE STORAGE BUCKETS
-- ==============================================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
    ('course-resources', 'course-resources', true, 52428800, ARRAY['application/pdf', 'application/zip', 'text/plain', 'image/png', 'image/jpeg']),
    ('assignment-submissions', 'assignment-submissions', false, 10485760, ARRAY['application/pdf', 'application/zip', 'image/png', 'image/jpeg', 'text/plain']),
    ('profile-images', 'profile-images', true, 5242880, ARRAY['image/png', 'image/jpeg', 'image/webp']),
    ('announcement-attachments', 'announcement-attachments', true, 20971520, ARRAY['application/pdf', 'image/png', 'image/jpeg']),
    ('receipts', 'receipts', false, 10485760, ARRAY['application/pdf', 'image/png', 'image/jpeg']),
    ('certificates', 'certificates', false, 10485760, ARRAY['application/pdf', 'image/png', 'image/jpeg'])
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit;

-- ==============================================================================
-- 5. STORAGE RLS POLICIES
-- ==============================================================================
-- A. Course Resources: Authenticated students can read
DROP POLICY IF EXISTS "Allow authenticated read course-resources" ON storage.objects;
CREATE POLICY "Allow authenticated read course-resources" ON storage.objects
    FOR SELECT TO authenticated
    USING (bucket_id = 'course-resources');

-- B. Assignment Submissions: Strict student folder isolation (student_id/*)
DROP POLICY IF EXISTS "Students can upload own submissions" ON storage.objects;
DROP POLICY IF EXISTS "Students can read own submissions" ON storage.objects;
CREATE POLICY "Students can upload own submissions" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
        bucket_id = 'assignment-submissions' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );
CREATE POLICY "Students can read own submissions" ON storage.objects
    FOR SELECT TO authenticated
    USING (
        bucket_id = 'assignment-submissions' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- C. Profile Images: Publicly readable, student can upload/update only their own folder
DROP POLICY IF EXISTS "Public can view profile images" ON storage.objects;
DROP POLICY IF EXISTS "Students can upload own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Students can update own avatar" ON storage.objects;
CREATE POLICY "Public can view profile images" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'profile-images');
CREATE POLICY "Students can upload own avatar" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
        bucket_id = 'profile-images' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );
CREATE POLICY "Students can update own avatar" ON storage.objects
    FOR UPDATE TO authenticated
    USING (
        bucket_id = 'profile-images' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- D. Receipts: Student can read only their own receipts
DROP POLICY IF EXISTS "Students can view own receipts" ON storage.objects;
CREATE POLICY "Students can view own receipts" ON storage.objects
    FOR SELECT TO authenticated
    USING (
        bucket_id = 'receipts' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- E. Certificates: Student can read only their own certificates
DROP POLICY IF EXISTS "Students can view own certificates" ON storage.objects;
CREATE POLICY "Students can view own certificates" ON storage.objects
    FOR SELECT TO authenticated
    USING (
        bucket_id = 'certificates' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- F. Announcement Attachments: Publicly readable
DROP POLICY IF EXISTS "Public can view announcement attachments" ON storage.objects;
CREATE POLICY "Public can view announcement attachments" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'announcement-attachments');

-- ==============================================================================
-- 6. INSERT SAMPLE COURSE RESOURCES (PDFs)
-- ==============================================================================
DO $$
DECLARE
    v_course_id UUID;
BEGIN
    SELECT id INTO v_course_id FROM public.courses LIMIT 1;
    IF v_course_id IS NOT NULL THEN
        DELETE FROM public.course_resources WHERE course_id = v_course_id;
        INSERT INTO public.course_resources (course_id, title, type, size, file_url)
        VALUES
        (v_course_id, 'Module 1: MERN Stack Architecture & Design Patterns.pdf', 'PDF', '4.2 MB', 'https://fsibagcyyducyurkdoii.supabase.co/storage/v1/object/public/course-resources/module1_mern_architecture.pdf'),
        (v_course_id, 'Module 2: Advanced Flutter & State Management Cheat Sheet.pdf', 'PDF', '2.8 MB', 'https://fsibagcyyducyurkdoii.supabase.co/storage/v1/object/public/course-resources/module2_flutter_cheatsheet.pdf'),
        (v_course_id, 'Module 3: PostgreSQL & Supabase Database Security Guide.pdf', 'PDF', '3.5 MB', 'https://fsibagcyyducyurkdoii.supabase.co/storage/v1/object/public/course-resources/module3_database_security.pdf');
    END IF;
END $$;
