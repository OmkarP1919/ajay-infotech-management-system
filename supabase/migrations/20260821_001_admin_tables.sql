-- ==============================================================================
-- AJAY INFOTECH — MIGRATION 001: EXTEND ROLES & ADD ADMIN TABLES
-- Safe, additive migration — no existing data is modified or deleted
-- Run in Supabase SQL Editor: Project fsibagcyyducyurkdoii
-- ==============================================================================

-- Extend the role check constraint to include 'super_admin'
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('student', 'teacher', 'admin', 'super_admin'));

-- ==============================================================================
-- ADMIN USERS TABLE
-- Separate from student profiles — only admin/super_admin accounts here
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.admin_users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(128) NOT NULL,
    email VARCHAR(128) UNIQUE NOT NULL,
    phone VARCHAR(32),
    role VARCHAR(20) NOT NULL DEFAULT 'admin'
        CHECK (role IN ('admin', 'super_admin')),
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMPTZ,
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admin_users_email ON public.admin_users(email);
CREATE INDEX IF NOT EXISTS idx_admin_users_role ON public.admin_users(role);

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- AUDIT LOGS TABLE
-- Tracks all administrative actions for compliance and auditing
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID REFERENCES public.admin_users(id) ON DELETE SET NULL,
    action VARCHAR(128) NOT NULL,
    entity_type VARCHAR(64),
    entity_id TEXT,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(64),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_admin ON public.audit_logs(admin_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON public.audit_logs(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON public.audit_logs(created_at DESC);

ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- FACULTY TABLE
-- Faculty profiles, separate from student profiles
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.faculty (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(128) NOT NULL,
    email VARCHAR(128) UNIQUE,
    phone VARCHAR(32),
    specialization VARCHAR(128),
    qualification VARCHAR(128),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_faculty_email ON public.faculty(email);

ALTER TABLE public.faculty ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- ASSIGNMENTS TABLE
-- Admin-created assignments (distinct from student_submissions)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    batch_id UUID REFERENCES public.batches(id) ON DELETE SET NULL,
    title VARCHAR(256) NOT NULL,
    description TEXT,
    deadline TIMESTAMPTZ,
    max_marks NUMERIC(6, 2) DEFAULT 100,
    attachment_url TEXT,
    created_by UUID REFERENCES public.admin_users(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_assignments_course ON public.assignments(course_id);
CREATE INDEX IF NOT EXISTS idx_assignments_batch ON public.assignments(batch_id);

ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;

-- Add assignment_id FK to assignment_submissions if not exists
ALTER TABLE public.assignment_submissions
    ADD COLUMN IF NOT EXISTS assignment_id UUID REFERENCES public.assignments(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS marks NUMERIC(6, 2),
    ADD COLUMN IF NOT EXISTS graded_by UUID REFERENCES public.admin_users(id),
    ADD COLUMN IF NOT EXISTS graded_at TIMESTAMPTZ;

-- ==============================================================================
-- INSTITUTE SETTINGS TABLE
-- Key-value store for institute configuration
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.institute_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(128) UNIQUE NOT NULL,
    value TEXT,
    description VARCHAR(256),
    updated_by UUID REFERENCES public.admin_users(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.institute_settings ENABLE ROW LEVEL SECURITY;

-- Seed default institute settings
INSERT INTO public.institute_settings (key, value, description) VALUES
    ('institute_name', 'Ajay Infotech', 'Name of the institute'),
    ('institute_tagline', 'Empowering Future Innovators', 'Tagline'),
    ('institute_email', 'info@ajayinfotech.in', 'Contact email'),
    ('institute_phone', '+91 98765 43210', 'Contact phone'),
    ('institute_address', 'Pune, Maharashtra, India', 'Institute address'),
    ('institute_website', 'https://ajayinfotech.in', 'Website URL'),
    ('attendance_min_percent', '75', 'Minimum attendance percentage required'),
    ('academic_year', '2026', 'Current academic year')
ON CONFLICT (key) DO NOTHING;

-- ==============================================================================
-- ADD VIDEO FIELDS TO LESSONS TABLE (if not present)
-- ==============================================================================
ALTER TABLE public.lessons
    ADD COLUMN IF NOT EXISTS video_type VARCHAR(32) DEFAULT 'youtube'
        CHECK (video_type IN ('youtube', 'storage', 'external', 'none')),
    ADD COLUMN IF NOT EXISTS video_duration_minutes NUMERIC(6, 2),
    ADD COLUMN IF NOT EXISTS thumbnail_url TEXT,
    ADD COLUMN IF NOT EXISTS description TEXT,
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- ==============================================================================
-- ADD EXTRA FIELDS TO COURSES TABLE (if not present)
-- ==============================================================================
ALTER TABLE public.courses
    ADD COLUMN IF NOT EXISTS duration_hours NUMERIC(6, 1),
    ADD COLUMN IF NOT EXISTS price NUMERIC(10, 2),
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- ==============================================================================
-- ADD EXTRA FIELDS TO BATCHES TABLE (if not present)
-- ==============================================================================
ALTER TABLE public.batches
    ADD COLUMN IF NOT EXISTS faculty_id UUID REFERENCES public.faculty(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS description TEXT,
    ADD COLUMN IF NOT EXISTS max_students INT DEFAULT 30,
    ADD COLUMN IF NOT EXISTS days_of_week TEXT[],
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- ==============================================================================
-- ADD REVIEWED_BY / COMMENTS TO LEAVE REQUESTS
-- ==============================================================================
ALTER TABLE public.leave_requests
    ADD COLUMN IF NOT EXISTS reviewed_by UUID REFERENCES public.admin_users(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS admin_comment TEXT;

-- ==============================================================================
-- ADD ADMIN-ADJUSTMENT TRACKING TO PAYMENTS
-- ==============================================================================
ALTER TABLE public.payments
    ADD COLUMN IF NOT EXISTS adjustment_type VARCHAR(32),
    ADD COLUMN IF NOT EXISTS adjusted_by UUID REFERENCES public.admin_users(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS adjustment_note TEXT;

-- ==============================================================================
-- ANNOUNCEMENTS TABLE — ADD TARGET AUDIENCE & BATCH TARGETING
-- ==============================================================================
ALTER TABLE public.announcements
    ADD COLUMN IF NOT EXISTS target_audience VARCHAR(32) DEFAULT 'all'
        CHECK (target_audience IN ('all', 'batch', 'course')),
    ADD COLUMN IF NOT EXISTS target_id UUID,
    ADD COLUMN IF NOT EXISTS published_by UUID REFERENCES public.admin_users(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS publish_date DATE DEFAULT CURRENT_DATE;

-- ==============================================================================
-- TRIGGERS
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_admin_users_updated_at ON public.admin_users;
CREATE TRIGGER set_admin_users_updated_at
    BEFORE UPDATE ON public.admin_users
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_faculty_updated_at ON public.faculty;
CREATE TRIGGER set_faculty_updated_at
    BEFORE UPDATE ON public.faculty
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
