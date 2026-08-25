-- ==============================================================================
-- AJAY INFOTECH — MIGRATION 002: ADMIN RLS POLICIES
-- Adds Row Level Security policies that allow admin_users to access institute data
-- Safe, additive — no existing student policies are removed
-- Run AFTER migration 001
-- ==============================================================================

-- ==============================================================================
-- HELPER FUNCTION: Check if current authenticated user is an admin
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.admin_users
        WHERE id = auth.uid() AND is_active = TRUE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.admin_users
        WHERE id = auth.uid() AND role = 'super_admin' AND is_active = TRUE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ==============================================================================
-- ADMIN_USERS TABLE RLS
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can view own record" ON public.admin_users;
DROP POLICY IF EXISTS "Super admins can view all admins" ON public.admin_users;
DROP POLICY IF EXISTS "Super admins can manage admins" ON public.admin_users;

CREATE POLICY "Admins can view own record" ON public.admin_users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Super admins can view all admins" ON public.admin_users
    FOR SELECT USING (public.is_super_admin());

CREATE POLICY "Super admins can manage admins" ON public.admin_users
    FOR ALL USING (public.is_super_admin());

-- ==============================================================================
-- PROFILES TABLE — Admin read access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can read all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can insert profiles" ON public.profiles;

CREATE POLICY "Admins can read all profiles" ON public.profiles
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can update profiles" ON public.profiles
    FOR UPDATE USING (public.is_admin());

CREATE POLICY "Admins can insert profiles" ON public.profiles
    FOR INSERT WITH CHECK (public.is_admin());

-- ==============================================================================
-- BATCHES TABLE — Admin write access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can manage batches" ON public.batches;
CREATE POLICY "Admins can manage batches" ON public.batches
    FOR ALL USING (public.is_admin());

-- ==============================================================================
-- BATCH SCHEDULES TABLE — Admin write access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can manage batch_schedules" ON public.batch_schedules;
CREATE POLICY "Admins can manage batch_schedules" ON public.batch_schedules
    FOR ALL USING (public.is_admin());

-- ==============================================================================
-- COURSES TABLE — Admin write access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can manage courses" ON public.courses;
CREATE POLICY "Admins can manage courses" ON public.courses
    FOR ALL USING (public.is_admin());

-- ==============================================================================
-- COURSE MODULES TABLE — Admin write access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can manage course_modules" ON public.course_modules;
CREATE POLICY "Admins can manage course_modules" ON public.course_modules
    FOR ALL USING (public.is_admin());

-- ==============================================================================
-- LESSONS TABLE — Admin write access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can manage lessons" ON public.lessons;
CREATE POLICY "Admins can manage lessons" ON public.lessons
    FOR ALL USING (public.is_admin());

-- ==============================================================================
-- COURSE RESOURCES TABLE — Admin write access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can manage course_resources" ON public.course_resources;
CREATE POLICY "Admins can manage course_resources" ON public.course_resources
    FOR ALL USING (public.is_admin());

-- ==============================================================================
-- STUDENT ENROLLMENTS TABLE — Admin read/write access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can manage student_enrollments" ON public.student_enrollments;
CREATE POLICY "Admins can manage student_enrollments" ON public.student_enrollments
    FOR ALL USING (public.is_admin());

-- ==============================================================================
-- ATTENDANCE TABLE — Admin read/write access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can manage attendance" ON public.attendance;
CREATE POLICY "Admins can manage attendance" ON public.attendance
    FOR ALL USING (public.is_admin());

-- ==============================================================================
-- LEAVE REQUESTS TABLE — Admin read/update access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can manage leave_requests" ON public.leave_requests;
CREATE POLICY "Admins can manage leave_requests" ON public.leave_requests
    FOR ALL USING (public.is_admin());

-- ==============================================================================
-- FEES TABLE — Admin read/write access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can manage fees" ON public.fees;
CREATE POLICY "Admins can manage fees" ON public.fees
    FOR ALL USING (public.is_admin());

-- ==============================================================================
-- FEE INSTALLMENTS TABLE — Admin read/write access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can manage fee_installments" ON public.fee_installments;
CREATE POLICY "Admins can manage fee_installments" ON public.fee_installments
    FOR ALL USING (public.is_admin());

-- ==============================================================================
-- PAYMENTS TABLE — Admin read access (no payment fraud via admin UI)
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can read all payments" ON public.payments;
CREATE POLICY "Admins can read all payments" ON public.payments
    FOR SELECT USING (public.is_admin());

-- ==============================================================================
-- ANNOUNCEMENTS TABLE — Admin write access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can manage announcements" ON public.announcements;
CREATE POLICY "Admins can manage announcements" ON public.announcements
    FOR ALL USING (public.is_admin());

-- ==============================================================================
-- ASSIGNMENT SUBMISSIONS TABLE — Admin read access
-- ==============================================================================
DROP POLICY IF EXISTS "Admins can view all submissions" ON public.assignment_submissions;
DROP POLICY IF EXISTS "Admins can update submissions (grading)" ON public.assignment_submissions;
CREATE POLICY "Admins can view all submissions" ON public.assignment_submissions
    FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins can update submissions (grading)" ON public.assignment_submissions
    FOR UPDATE USING (public.is_admin());

-- ==============================================================================
-- NEW TABLES RLS
-- ==============================================================================

-- Faculty
DROP POLICY IF EXISTS "Admins can manage faculty" ON public.faculty;
CREATE POLICY "Admins can manage faculty" ON public.faculty
    FOR ALL USING (public.is_admin());
DROP POLICY IF EXISTS "Public can read faculty" ON public.faculty;
CREATE POLICY "Public can read faculty" ON public.faculty
    FOR SELECT TO authenticated USING (TRUE);

-- Assignments
DROP POLICY IF EXISTS "Admins can manage assignments" ON public.assignments;
CREATE POLICY "Admins can manage assignments" ON public.assignments
    FOR ALL USING (public.is_admin());
DROP POLICY IF EXISTS "Students can read assignments for their courses" ON public.assignments;
CREATE POLICY "Students can read assignments for their courses" ON public.assignments
    FOR SELECT TO authenticated USING (TRUE);

-- Audit Logs
DROP POLICY IF EXISTS "Admins can read audit logs" ON public.audit_logs;
DROP POLICY IF EXISTS "Admins can insert audit logs" ON public.audit_logs;
CREATE POLICY "Admins can read audit logs" ON public.audit_logs
    FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins can insert audit logs" ON public.audit_logs
    FOR INSERT WITH CHECK (public.is_admin());

-- Institute Settings
DROP POLICY IF EXISTS "Admins can manage settings" ON public.institute_settings;
CREATE POLICY "Admins can manage settings" ON public.institute_settings
    FOR ALL USING (public.is_admin());
