# Database Schema & Data Models

The Ajay Infotech system utilizes PostgreSQL 15 managed by Supabase. All tables implement strict Row Level Security (RLS) policies to ensure data isolation.

---

## Core Entities & Relationships

```mermaid
erDiagram
    PROFILES ||--o{ ENROLLMENTS : "has"
    PROFILES ||--o{ ATTENDANCE : "has"
    PROFILES ||--o{ FEES : "has"
    PROFILES ||--o{ LEAVE_REQUESTS : "submits"
    COURSES ||--o{ BATCHES : "contains"
    BATCHES ||--o{ ENROLLMENTS : "includes"
    BATCHES ||--o{ ATTENDANCE : "schedules"
    FEES ||--o{ FEE_INSTALLMENTS : "divided_into"
    FEE_INSTALLMENTS ||--o{ PAYMENTS : "settled_by"
    ADMIN_USERS ||--o{ AUDIT_LOGS : "triggers"

    PROFILES {
        uuid id PK
        text full_name
        text email
        text phone
        text roll_number
        timestamp created_at
    }

    COURSES {
        uuid id PK
        text title
        text description
        numeric fee_amount
        integer duration_months
    }

    BATCHES {
        uuid id PK
        uuid course_id FK
        text batch_name
        timestamp start_date
        timestamp end_date
    }

    FEES {
        uuid id PK
        uuid student_id FK
        numeric total_amount
        numeric paid_amount
        numeric outstanding_amount
        text status
    }

    FEE_INSTALLMENTS {
        uuid id PK
        uuid fee_id FK
        integer installment_number
        numeric amount
        date due_date
        date paid_date
        text status
        text receipt_no
    }

    PAYMENTS {
        uuid id PK
        uuid student_id FK
        uuid installment_id FK
        numeric amount
        text razorpay_order_id
        text razorpay_payment_id
        text status
        timestamp created_at
    }

    ADMIN_USERS {
        uuid id PK
        text full_name
        text email
        text role
        boolean is_active
    }

    AUDIT_LOGS {
        uuid id PK
        uuid admin_id FK
        text action
        text entity_type
        text entity_id
        jsonb old_values
        jsonb new_values
        timestamp created_at
    }
```

---

## Key Tables

### 1. `profiles`
Stores extended user profile information linked directly to `auth.users(id)`.

### 2. `fees` & `fee_installments`
* `fees`: Aggregated financial account for a student's enrolled courses.
* `fee_installments`: Granular installment breakdown with due dates, payment status (`pending`, `paid`, `overdue`), and unique receipt identifiers.

### 3. `payments`
Ledger recording all electronic transactions, containing Razorpay order and payment IDs with cryptographic verification metadata.

### 4. `admin_users` & `audit_logs`
* `admin_users`: Role-Based Access Control (`super_admin`, `admin`, `faculty`).
* `audit_logs`: Immutable tracking log for administrative operations.
