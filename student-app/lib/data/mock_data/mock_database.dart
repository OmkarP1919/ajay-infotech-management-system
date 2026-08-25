import '../models/student_model.dart';
import '../models/course_model.dart';
import '../models/batch_model.dart';
import '../models/attendance_model.dart';
import '../models/fee_model.dart';
import '../models/announcement_model.dart';

class MockDatabase {
  static const StudentModel currentStudent = StudentModel(
    id: 'std_01',
    registrationNo: 'AI-2026-8842',
    name: 'Rohit Sharma',
    email: 'rohit.sharma@ajayinfotech.in',
    phone: '+91 98765 43210',
    program: 'Diploma in Full Stack Development',
    batchCode: 'FS-2026-B4',
    avatarUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    overallAttendance: 88.5,
    completedModules: 14,
    totalModules: 20,
    pendingAssignments: 2,
    upcomingTests: 1,
    enrolledDate: '15 Jan 2026',
  );

  static final List<CourseModel> courses = [
    const CourseModel(
      id: 'crs_01',
      title: 'Full Stack Masterclass: React, Node & Cloud',
      description:
          'Comprehensive industry program covering modern frontend, backend API architecture, databases, and microservices.',
      instructor: 'Ajay Sir (Chief Technical Lead)',
      category: 'Full Stack Web',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=600',
      progress: 0.68,
      totalLessons: 42,
      completedLessons: 28,
      activeLessonTitle: 'Building REST APIs with Express & MongoDB',
      modules: [
        ModuleModel(
          id: 'mod_01',
          title: 'Module 1: Modern JavaScript & Async Fundamentals',
          duration: '6h 30m',
          lessons: [
            LessonModel(
              id: 'les_01',
              title: 'ES6+ Syntax & Array Methods Mastery',
              duration: '45 mins',
              videoUrl:
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
              isCompleted: true,
              isLocked: false,
              order: 1,
              description:
                  'In-depth exploration of map, filter, reduce, destructuring, and arrow functions in production.',
            ),
            LessonModel(
              id: 'les_02',
              title: 'Promises, Async/Await & Event Loop',
              duration: '52 mins',
              videoUrl:
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
              isCompleted: true,
              isLocked: false,
              order: 2,
              description:
                  'Demystifying asynchronous programming in JavaScript with practical network request patterns.',
            ),
          ],
        ),
        ModuleModel(
          id: 'mod_02',
          title: 'Module 2: React Core & State Architecture',
          duration: '10h 15m',
          lessons: [
            LessonModel(
              id: 'les_03',
              title: 'Component Lifecycle & Hook Deep Dive',
              duration: '58 mins',
              videoUrl:
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
              isCompleted: true,
              isLocked: false,
              order: 3,
              description:
                  'Mastering useState, useEffect, useMemo, and useCallback for 60fps React render cycles.',
            ),
            LessonModel(
              id: 'les_04',
              title: 'Global State Management Patterns',
              duration: '1h 12m',
              videoUrl:
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
              isCompleted: true,
              isLocked: false,
              order: 4,
              description:
                  'Scalable state architectures using Context, Redux Toolkit, and atomic state stores.',
            ),
          ],
        ),
        ModuleModel(
          id: 'mod_03',
          title: 'Module 3: Backend Services & API Design',
          duration: '12h 45m',
          lessons: [
            LessonModel(
              id: 'les_05',
              title: 'Building REST APIs with Express & MongoDB',
              duration: '1h 05m',
              videoUrl:
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
              isCompleted: false,
              isLocked: false,
              order: 5,
              description:
                  'Designing clean controller-service-repository patterns with Mongoose schemas and middleware.',
            ),
            LessonModel(
              id: 'les_06',
              title: 'JWT Authentication & Role-Based Access Control',
              duration: '55 mins',
              videoUrl:
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
              isCompleted: false,
              isLocked: false,
              order: 6,
              description:
                  'Secure token issuance, refresh rotation, password hashing with bcrypt, and protected routes.',
            ),
          ],
        ),
      ],
      resources: [
        ResourceModel(
          id: 'res_01',
          title: 'Full Stack API Architecture & Cheat Sheet.pdf',
          type: 'PDF',
          size: '4.2 MB',
          downloadUrl: 'https://ajayinfotech.in/downloads/cheatsheet.pdf',
        ),
        ResourceModel(
          id: 'res_02',
          title: 'Express Boilerplate Starter Kit.zip',
          type: 'ZIP',
          size: '1.8 MB',
          downloadUrl: 'https://ajayinfotech.in/downloads/starter.zip',
        ),
        ResourceModel(
          id: 'res_03',
          title: 'Database Schema Designs & ER Diagram.pdf',
          type: 'PDF',
          size: '3.1 MB',
          downloadUrl: 'https://ajayinfotech.in/downloads/schema.pdf',
        ),
      ],
    ),
    const CourseModel(
      id: 'crs_02',
      title: 'Flutter Mobile App Development: Zero to Hero',
      description:
          'Master cross-platform mobile development with Dart, Riverpod, native Android integrations, and animations.',
      instructor: 'Ajay Sir',
      category: 'Mobile Dev',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=600',
      progress: 0.35,
      totalLessons: 36,
      completedLessons: 12,
      activeLessonTitle: 'State Management with Riverpod 2.0',
      modules: [],
      resources: [],
    ),
    const CourseModel(
      id: 'crs_03',
      title: 'Python for Data Science & Machine Learning',
      description:
          'Data analytics, NumPy, Pandas, visualization with Matplotlib, and foundational machine learning algorithms.',
      instructor: 'Dr. S. Kulkarni',
      category: 'Data Science',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600',
      progress: 0.15,
      totalLessons: 30,
      completedLessons: 5,
      activeLessonTitle: 'Pandas DataFrames & Data Cleaning',
      modules: [],
      resources: [],
    ),
  ];

  static final List<BatchModel> batches = [
    const BatchModel(
      id: 'btc_01',
      name: 'Full Stack MERN - Batch 2026 (B4)',
      code: 'FS-2026-B4',
      faculty: 'Ajay Sharma (Lead Instructor)',
      timing: 'Mon - Fri • 7:00 PM - 9:00 PM',
      mode: 'Hybrid (Lab 3 / Live Stream)',
      startDate: '15 Jan 2026',
      endDate: '15 Jul 2026',
      progress: 0.70,
      totalStudents: 32,
      isActive: true,
      weeklySchedule: [
        ScheduleSlot(
          day: 'Monday',
          time: '7:00 PM - 9:00 PM',
          topic: 'Backend Architecture & Express Middleware',
          room: 'Lab 3 / Online',
          isLive: false,
        ),
        ScheduleSlot(
          day: 'Tuesday',
          time: '7:00 PM - 9:00 PM',
          topic: 'MongoDB Aggregations & Query Optimization',
          room: 'Lab 3 / Online',
          isLive: false,
        ),
        ScheduleSlot(
          day: 'Wednesday',
          time: '7:00 PM - 9:00 PM',
          topic: 'RESTful API Security & Token Refresh',
          room: 'Lab 3 / Online',
          isLive: true,
        ),
        ScheduleSlot(
          day: 'Thursday',
          time: '7:00 PM - 9:00 PM',
          topic: 'React Frontend Integration & Axios Interceptors',
          room: 'Lab 3 / Online',
          isLive: false,
        ),
        ScheduleSlot(
          day: 'Friday',
          time: '7:00 PM - 9:00 PM',
          topic: 'Weekly Doubt Clearing & Assignment Review',
          room: 'Seminar Hall / Online',
          isLive: false,
        ),
      ],
    ),
    const BatchModel(
      id: 'btc_02',
      name: 'Core Java & Data Structures - Batch 2025',
      code: 'JAVA-2025-A1',
      faculty: 'Ajay Sharma',
      timing: 'Sat - Sun • 10:00 AM - 1:00 PM',
      mode: 'Offline (Lab 1)',
      startDate: '01 Aug 2025',
      endDate: '31 Dec 2025',
      progress: 1.0,
      totalStudents: 28,
      isActive: false,
      weeklySchedule: [],
    ),
  ];

  static const List<SubjectAttendance> subjectAttendances = [
    SubjectAttendance(
      subjectName: 'React & Frontend Architecture',
      totalClasses: 30,
      attendedClasses: 28,
      percentage: 93.3,
    ),
    SubjectAttendance(
      subjectName: 'Node.js & Express Services',
      totalClasses: 26,
      attendedClasses: 23,
      percentage: 88.4,
    ),
    SubjectAttendance(
      subjectName: 'Database Engineering (MongoDB & SQL)',
      totalClasses: 22,
      attendedClasses: 19,
      percentage: 86.3,
    ),
    SubjectAttendance(
      subjectName: 'Cloud Deployment & DevOps (Docker/AWS)',
      totalClasses: 14,
      attendedClasses: 12,
      percentage: 85.7,
    ),
  ];

  static const List<AttendanceRecord> attendanceRecords = [
    AttendanceRecord(
      date: '20 Aug 2026',
      day: 'Thursday',
      subject: 'Node.js & Express Services',
      status: AttendanceStatus.present,
      remarks: 'Attended full session',
    ),
    AttendanceRecord(
      date: '19 Aug 2026',
      day: 'Wednesday',
      subject: 'RESTful API Security & Token Refresh',
      status: AttendanceStatus.present,
      remarks: 'Participated in coding challenge',
    ),
    AttendanceRecord(
      date: '18 Aug 2026',
      day: 'Tuesday',
      subject: 'MongoDB Aggregations & Query Optimization',
      status: AttendanceStatus.present,
      remarks: 'Submitted lab exercise',
    ),
    AttendanceRecord(
      date: '15 Aug 2026',
      day: 'Saturday',
      subject: 'Independence Day',
      status: AttendanceStatus.holiday,
      remarks: 'Institute closed',
    ),
    AttendanceRecord(
      date: '14 Aug 2026',
      day: 'Friday',
      subject: 'React Query & Client State Caching',
      status: AttendanceStatus.absent,
      remarks: 'Medical leave submitted',
    ),
    AttendanceRecord(
      date: '13 Aug 2026',
      day: 'Thursday',
      subject: 'React Hooks Deep Dive',
      status: AttendanceStatus.present,
      remarks: 'Attended session',
    ),
  ];

  static const FeeSummaryModel feeSummary = FeeSummaryModel(
    totalFee: 45000.0,
    paidAmount: 30000.0,
    outstandingAmount: 15000.0,
    nextDueDate: '15 Sep 2026',
    installments: [
      InstallmentModel(
        id: 'inst_01',
        title: '1st Installment (Admission & Registration)',
        amount: 15000.0,
        dueDate: '15 Jan 2026',
        paidDate: '14 Jan 2026',
        receiptNo: 'AI-REC-8891',
        status: InstallmentStatus.paid,
      ),
      InstallmentModel(
        id: 'inst_02',
        title: '2nd Installment (Mid-term Term Fee)',
        amount: 15000.0,
        dueDate: '15 May 2026',
        paidDate: '12 May 2026',
        receiptNo: 'AI-REC-9022',
        status: InstallmentStatus.paid,
      ),
      InstallmentModel(
        id: 'inst_03',
        title: '3rd Installment (Final Placement & Certification)',
        amount: 15000.0,
        dueDate: '15 Sep 2026',
        paidDate: null,
        receiptNo: null,
        status: InstallmentStatus.pending,
      ),
    ],
    transactions: [
      TransactionModel(
        id: 'tx_01',
        receiptNo: 'AI-REC-9022',
        description: 'Diploma Program - 2nd Installment Payment',
        amount: 15000.0,
        date: '12 May 2026',
        paymentMethod: 'UPI (Google Pay)',
        status: 'Successful',
      ),
      TransactionModel(
        id: 'tx_02',
        receiptNo: 'AI-REC-8891',
        description: 'Diploma Program - Admission & 1st Installment',
        amount: 15000.0,
        date: '14 Jan 2026',
        paymentMethod: 'Netbanking (HDFC Bank)',
        status: 'Successful',
      ),
    ],
  );

  static const List<AnnouncementModel> announcements = [
    AnnouncementModel(
      id: 'ann_01',
      title: 'Full Stack Mid-Semester Evaluation & Capstone Project Submission',
      description:
          'All students of Batch B4 must submit their completed MERN Capstone repositories by September 10, 2026. Live project defense schedules will be shared shortly.',
      date: '20 Aug 2026',
      category: AnnouncementCategory.academic,
      isPinned: true,
      isRead: false,
      attachmentName: 'Capstone_Guidelines_2026.pdf',
      attachmentUrl: 'https://ajayinfotech.in/notices/capstone.pdf',
    ),
    AnnouncementModel(
      id: 'ann_02',
      title: 'Upcoming Campus Placement Drive: TechCorp & Infosolutions',
      description:
          'Eligible students with >75% attendance and cleared mock assessments can register for the junior developer interview rounds starting next week.',
      date: '18 Aug 2026',
      category: AnnouncementCategory.placement,
      isPinned: false,
      isRead: false,
      attachmentName: 'Placement_Eligibility_Criteria.pdf',
      attachmentUrl: 'https://ajayinfotech.in/notices/placement.pdf',
    ),
    AnnouncementModel(
      id: 'ann_03',
      title: 'Ganesh Chaturthi Institute Holiday Notice',
      description:
          'Ajay Infotech will remain closed on Friday, August 28, 2026 for Ganesh Chaturthi. Regular classes will resume on Monday.',
      date: '15 Aug 2026',
      category: AnnouncementCategory.holidays,
      isPinned: false,
      isRead: true,
    ),
  ];
}
