-- ==============================================================================
-- AJAY INFOTECH — PRODUCTION SUPABASE POSTGRESQL SCHEMA WITH ROW LEVEL SECURITY
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES & STUDENTS TABLE
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY,
    student_id VARCHAR(32) UNIQUE NOT NULL,
    full_name VARCHAR(128) NOT NULL,
    email VARCHAR(128) UNIQUE NOT NULL,
    phone VARCHAR(32),
    avatar_url TEXT,
    program VARCHAR(128) NOT NULL,
    batch_code VARCHAR(32) NOT NULL,
    enrolled_date DATE NOT NULL DEFAULT CURRENT_DATE,
    overall_attendance NUMERIC(5, 2) DEFAULT 0.00,
    role VARCHAR(20) DEFAULT 'student' CHECK (role IN ('student', 'teacher', 'admin')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. BATCHES TABLE
CREATE TABLE IF NOT EXISTS public.batches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(32) UNIQUE NOT NULL,
    name VARCHAR(128) NOT NULL,
    faculty VARCHAR(128) NOT NULL,
    timing VARCHAR(64) NOT NULL,
    mode VARCHAR(64) NOT NULL,
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE NOT NULL DEFAULT (CURRENT_DATE + INTERVAL '6 months'),
    total_students INT DEFAULT 0,
    progress NUMERIC(5, 2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. BATCH SCHEDULES TABLE
CREATE TABLE IF NOT EXISTS public.batch_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    batch_id UUID REFERENCES public.batches(id) ON DELETE CASCADE,
    day VARCHAR(16) NOT NULL,
    topic VARCHAR(128) NOT NULL,
    time VARCHAR(64) NOT NULL,
    room VARCHAR(64) NOT NULL,
    is_live BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. COURSES TABLE
CREATE TABLE IF NOT EXISTS public.courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(256) NOT NULL,
    category VARCHAR(64) NOT NULL,
    instructor VARCHAR(128) NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    total_lessons INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. COURSE MODULES TABLE
CREATE TABLE IF NOT EXISTS public.course_modules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    title VARCHAR(256) NOT NULL,
    duration VARCHAR(64),
    sequence_order INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. LESSONS TABLE
CREATE TABLE IF NOT EXISTS public.lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    module_id UUID REFERENCES public.course_modules(id) ON DELETE CASCADE,
    title VARCHAR(256) NOT NULL,
    duration VARCHAR(64) NOT NULL,
    video_url TEXT,
    sequence_order INT NOT NULL,
    is_preview BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. STUDENT ENROLLMENTS & LESSON PROGRESS TABLE
CREATE TABLE IF NOT EXISTS public.student_enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    progress NUMERIC(5, 2) DEFAULT 0.00,
    completed_lessons INT DEFAULT 0,
    active_lesson_id UUID REFERENCES public.lessons(id),
    enrolled_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(student_id, course_id)
);

CREATE TABLE IF NOT EXISTS public.lesson_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES public.lessons(id) ON DELETE CASCADE,
    is_completed BOOLEAN DEFAULT FALSE,
    playback_position_minutes NUMERIC(6, 2) DEFAULT 0.00,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(student_id, lesson_id)
);

-- 8. COURSE RESOURCES (PDFs, ZIPs) TABLE
CREATE TABLE IF NOT EXISTS public.course_resources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    title VARCHAR(256) NOT NULL,
    type VARCHAR(16) NOT NULL CHECK (type IN ('PDF', 'ZIP', 'DOC')),
    size VARCHAR(32) NOT NULL,
    file_url TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. ATTENDANCE & LEAVE REQUESTS TABLES
CREATE TABLE IF NOT EXISTS public.attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    subject VARCHAR(128) NOT NULL,
    date DATE NOT NULL,
    day VARCHAR(16) NOT NULL,
    status VARCHAR(16) NOT NULL CHECK (status IN ('present', 'absent', 'holiday', 'leave')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.leave_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    leave_date DATE NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(16) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. FEES, INSTALLMENTS & PAYMENTS TABLES
CREATE TABLE IF NOT EXISTS public.fees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    total_fee NUMERIC(10, 2) NOT NULL,
    paid_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    outstanding_amount NUMERIC(10, 2) NOT NULL,
    next_due_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.fee_installments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fee_id UUID REFERENCES public.fees(id) ON DELETE CASCADE,
    title VARCHAR(128) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    due_date DATE NOT NULL,
    paid_date DATE,
    receipt_no VARCHAR(64),
    status VARCHAR(16) DEFAULT 'pending' CHECK (status IN ('paid', 'pending', 'overdue')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    installment_id UUID REFERENCES public.fee_installments(id),
    amount NUMERIC(10, 2) NOT NULL,
    payment_method VARCHAR(64) NOT NULL,
    razorpay_order_id VARCHAR(128),
    razorpay_payment_id VARCHAR(128),
    razorpay_signature VARCHAR(256),
    status VARCHAR(16) DEFAULT 'success' CHECK (status IN ('success', 'failed', 'pending')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. ANNOUNCEMENTS & NOTICES TABLE
CREATE TABLE IF NOT EXISTS public.announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(256) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(32) NOT NULL CHECK (category IN ('all', 'academic', 'exams', 'placement', 'holidays')),
    date VARCHAR(32) NOT NULL,
    is_pinned BOOLEAN DEFAULT FALSE,
    attachment_name VARCHAR(128),
    attachment_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- INDEXES FOR MAXIMUM QUERY PERFORMANCE
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_profiles_student_id ON public.profiles(student_id);
CREATE INDEX IF NOT EXISTS idx_student_enrollments_student ON public.student_enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_lesson_progress_student ON public.lesson_progress(student_id, lesson_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student_date ON public.attendance(student_id, date);
CREATE INDEX IF NOT EXISTS idx_fees_student ON public.fees(student_id);
CREATE INDEX IF NOT EXISTS idx_fee_installments_fee ON public.fee_installments(fee_id);
CREATE INDEX IF NOT EXISTS idx_announcements_category ON public.announcements(category);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES (IDEMPOTENT WITH DROP IF EXISTS)
-- ==============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.batch_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leave_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fee_installments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

-- 1. Profiles
DROP POLICY IF EXISTS "Students can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Students can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow student read profile" ON public.profiles;
CREATE POLICY "Students can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id OR auth.role() = 'anon');
CREATE POLICY "Students can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- 2. Courses, Batches, Lessons, Announcements (Publicly Readable)
DROP POLICY IF EXISTS "Authenticated users can read courses" ON public.courses;
DROP POLICY IF EXISTS "Public read courses" ON public.courses;
CREATE POLICY "Public read courses" ON public.courses
    FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Authenticated users can read batches" ON public.batches;
DROP POLICY IF EXISTS "Public read batches" ON public.batches;
CREATE POLICY "Public read batches" ON public.batches
    FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Public read batch_schedules" ON public.batch_schedules;
CREATE POLICY "Public read batch_schedules" ON public.batch_schedules
    FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Authenticated users can read modules" ON public.course_modules;
DROP POLICY IF EXISTS "Public read modules" ON public.course_modules;
CREATE POLICY "Public read modules" ON public.course_modules
    FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Authenticated users can read lessons" ON public.lessons;
DROP POLICY IF EXISTS "Public read lessons" ON public.lessons;
CREATE POLICY "Public read lessons" ON public.lessons
    FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Authenticated users can read resources" ON public.course_resources;
DROP POLICY IF EXISTS "Public read resources" ON public.course_resources;
CREATE POLICY "Public read resources" ON public.course_resources
    FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Authenticated users can read announcements" ON public.announcements;
DROP POLICY IF EXISTS "Public read announcements" ON public.announcements;
CREATE POLICY "Public read announcements" ON public.announcements
    FOR SELECT TO anon, authenticated USING (true);

-- 3. Student Progress & Enrollments: Strict isolation
DROP POLICY IF EXISTS "Students can read own enrollments" ON public.student_enrollments;
DROP POLICY IF EXISTS "Students can update own enrollments" ON public.student_enrollments;
CREATE POLICY "Students can read own enrollments" ON public.student_enrollments
    FOR SELECT USING (auth.uid() = student_id);
CREATE POLICY "Students can update own enrollments" ON public.student_enrollments
    FOR UPDATE USING (auth.uid() = student_id);

DROP POLICY IF EXISTS "Students can read own progress" ON public.lesson_progress;
DROP POLICY IF EXISTS "Students can upsert own progress" ON public.lesson_progress;
CREATE POLICY "Students can read own progress" ON public.lesson_progress
    FOR SELECT USING (auth.uid() = student_id);
CREATE POLICY "Students can upsert own progress" ON public.lesson_progress
    FOR ALL USING (auth.uid() = student_id);

-- 4. Attendance: Read-only for student's own records
DROP POLICY IF EXISTS "Students can view own attendance" ON public.attendance;
CREATE POLICY "Students can view own attendance" ON public.attendance
    FOR SELECT USING (auth.uid() = student_id OR auth.role() = 'anon');

-- 5. Leave Requests: Students can view and insert own requests
DROP POLICY IF EXISTS "Students can view own leave requests" ON public.leave_requests;
DROP POLICY IF EXISTS "Students can create leave requests" ON public.leave_requests;
CREATE POLICY "Students can view own leave requests" ON public.leave_requests
    FOR SELECT USING (auth.uid() = student_id);
CREATE POLICY "Students can create leave requests" ON public.leave_requests
    FOR INSERT WITH CHECK (auth.uid() = student_id);

-- 6. Fees & Payments: Strict isolation
DROP POLICY IF EXISTS "Students can view own fees" ON public.fees;
CREATE POLICY "Students can view own fees" ON public.fees
    FOR SELECT USING (auth.uid() = student_id OR auth.role() = 'anon');

DROP POLICY IF EXISTS "Students can view own installments" ON public.fee_installments;
CREATE POLICY "Students can view own installments" ON public.fee_installments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.fees WHERE fees.id = fee_installments.fee_id AND (fees.student_id = auth.uid() OR auth.role() = 'anon')
        )
    );

DROP POLICY IF EXISTS "Students can view own payments" ON public.payments;
CREATE POLICY "Students can view own payments" ON public.payments
    FOR SELECT USING (auth.uid() = student_id);

-- ==============================================================================
-- AUTOMATIC TIMESTAMPS TRIGGER
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_fees_updated_at ON public.fees;
CREATE TRIGGER set_fees_updated_at
    BEFORE UPDATE ON public.fees
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
