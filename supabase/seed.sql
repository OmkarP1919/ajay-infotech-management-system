-- ==============================================================================
-- AJAY INFOTECH — PRODUCTION SEED & TEST DATA SCRIPT
-- ==============================================================================

-- 1. SEED BATCHES
INSERT INTO public.batches (id, code, name, faculty, timing, mode, start_date, end_date, total_students, progress, is_active)
VALUES 
(
    'b1000000-0000-0000-0000-000000000001',
    'MERN-2026-B1',
    'Full Stack Web & Flutter Dev — Morning Batch',
    'Ajay Sir',
    'Mon - Fri (8:00 AM - 10:00 AM)',
    'Hybrid (Online + Classroom)',
    '2026-01-15',
    '2026-07-15',
    35,
    0.68,
    TRUE
),
(
    'b1000000-0000-0000-0000-000000000002',
    'PY-AI-2026-E1',
    'Python & AI Engineering — Evening Batch',
    'Prof. Sharma',
    'Mon - Fri (6:00 PM - 8:00 PM)',
    'Live Online',
    '2026-02-01',
    '2026-08-01',
    28,
    0.45,
    TRUE
)
ON CONFLICT (code) DO NOTHING;

-- 2. SEED BATCH SCHEDULES
INSERT INTO public.batch_schedules (batch_id, day, topic, time, room, is_live)
VALUES
('b1000000-0000-0000-0000-000000000001', 'Monday', 'State Management with Riverpod 2.0', '08:00 AM - 10:00 AM', 'Lab 3 / Google Meet', TRUE),
('b1000000-0000-0000-0000-000000000001', 'Tuesday', 'RESTful APIs & PostgREST Architecture', '08:00 AM - 10:00 AM', 'Lab 3 / Google Meet', FALSE),
('b1000000-0000-0000-0000-000000000001', 'Wednesday', 'Supabase Authentication & Row Level Security', '08:00 AM - 10:00 AM', 'Lab 3 / Google Meet', TRUE),
('b1000000-0000-0000-0000-000000000001', 'Thursday', 'Razorpay Payment Gateway Integration', '08:00 AM - 10:00 AM', 'Lab 3 / Google Meet', FALSE),
('b1000000-0000-0000-0000-000000000001', 'Friday', 'DevOps & Android Production Builds', '08:00 AM - 10:00 AM', 'Lab 3 / Google Meet', TRUE);

-- 3. SEED COURSES
INSERT INTO public.courses (id, title, category, instructor, description, thumbnail_url, total_lessons)
VALUES
(
    'c1000000-0000-0000-0000-000000000001',
    'Full Stack Masterclass (Flutter & Node.js)',
    'Mobile & Web Dev',
    'Ajay Sir',
    'Industry-standard curriculum covering Flutter UI/UX, Riverpod, Supabase Backend, Node.js REST APIs, and Razorpay payment integration.',
    'https://images.unsplash.com/photo-1587620962725-abab7fe55159',
    42
),
(
    'c1000000-0000-0000-0000-000000000002',
    'Applied Python & Generative AI Systems',
    'AI & Data Science',
    'Prof. Sharma',
    'Hands-on masterclass in Python programming, PyTorch, LangChain, and production AI application deployment.',
    'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5',
    36
)
ON CONFLICT (id) DO NOTHING;

-- 4. SEED COURSE MODULES & LESSONS
INSERT INTO public.course_modules (id, course_id, title, duration, sequence_order)
VALUES
('d1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 'Module 1: Flutter 3 Architecture & Design Systems', '4h 30m', 1),
('d1000000-0000-0000-0000-000000000002', 'c1000000-0000-0000-0000-000000000001', 'Module 2: Cloud Backend & Row Level Security', '6h 15m', 2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.lessons (id, module_id, title, duration, sequence_order, is_preview)
VALUES
('e1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001', 'Setting up Flutter on D: Drive & Environment Config', '45 mins', 1, TRUE),
('e1000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000001', 'Implementing Stitch Design Tokens & Custom Themes', '60 mins', 2, FALSE),
('e1000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000002', 'PostgreSQL Schema Design & UUID Keys', '50 mins', 1, TRUE),
('e1000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000002', 'Writing Secure Supabase RLS Policies', '55 mins', 2, FALSE)
ON CONFLICT (id) DO NOTHING;

-- 5. SEED COURSE RESOURCES
INSERT INTO public.course_resources (course_id, title, type, size, file_url)
VALUES
('c1000000-0000-0000-0000-000000000001', 'Complete Flutter Architecture Guide (PDF)', 'PDF', '4.2 MB', 'https://ajayinfotech.in/resources/flutter-guide.pdf'),
('c1000000-0000-0000-0000-000000000001', 'Supabase RLS Cheatsheet & SQL Scripts (ZIP)', 'ZIP', '8.5 MB', 'https://ajayinfotech.in/resources/supabase-rls.zip');

-- 6. SEED ANNOUNCEMENTS
INSERT INTO public.announcements (title, description, category, date, is_pinned, attachment_name)
VALUES
(
    'Major Campus Placement Drive: TCS, Infosys & Cognizant',
    'Upcoming placement registration opens next Monday for batch MERN-2026. Please ensure all 10 module assignments are completed and reviewed.',
    'placement',
    '20 Feb 2026',
    TRUE,
    'Placement_Guidelines_2026.pdf'
),
(
    'Mid-Term Assessment & Practical Viva Schedule',
    'Practical lab evaluations will commence from March 5th, 2026. Check the batch schedule tab for your specific room assignment.',
    'exams',
    '18 Feb 2026',
    TRUE,
    'Viva_Schedule_March.pdf'
),
(
    'Institute Holiday: Mahashivratri',
    'The institute will remain closed on Wednesday, 26 Feb 2026. Regular classes will resume on Thursday.',
    'holidays',
    '15 Feb 2026',
    FALSE,
    NULL
);
