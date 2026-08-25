# Supabase Backend Setup Guide

This guide details configuring the Supabase PostgreSQL database, applying migrations, and provisioning Edge Functions.

---

## 1. Project Creation

1. Log in to [Supabase Dashboard](https://supabase.com/dashboard).
2. Click **New Project** and configure your organization and database password.
3. Note down your **Project URL** and **Anon Key** from **Project Settings > API**.

---

## 2. Applying Database Schemas

### Step 1: Base Schema
Navigate to the SQL Editor in the Supabase Dashboard and execute:
```sql
-- Run contents of supabase/schema.sql
```

### Step 2: Storage & Security Policies
Execute:
```sql
-- Run contents of supabase/phase2_storage_and_security.sql
```

### Step 3: Admin Tables & RBAC Migrations
Execute in order:
1. `supabase/migrations/20260821_001_admin_tables.sql`
2. `supabase/migrations/20260821_002_admin_rls.sql`
3. `supabase/migrations/20260821_003_first_super_admin.sql` (Replace placeholder UUID with your admin user's auth UUID)

---

## 3. Edge Functions Configuration

Deploy the Edge Functions using Supabase CLI:

```bash
# Login to Supabase CLI
supabase login

# Link your project
supabase link --project-ref your_project_ref

# Set secrets securely
supabase secrets set RAZORPAY_KEY_ID=rzp_test_...
supabase secrets set RAZORPAY_KEY_SECRET=your_secret_here
supabase secrets set RAZORPAY_WEBHOOK_SECRET=your_webhook_secret_here

# Deploy Functions
supabase functions deploy create-payment-order --no-verify-jwt
supabase functions deploy verify-payment-webhook --no-verify-jwt
```
