# Security Model & Secret Isolation

The Ajay Infotech Management System follows security-by-design principles to safeguard student information, administrative access, and payment integrity.

---

## 1. Zero Trust Secret Isolation

| Credential Type | Usage Scope | Client Access | Safe Storage Location |
| :--- | :--- | :--- | :--- |
| `SUPABASE_ANON_KEY` | Public client authentication & RLS queries | **Allowed** (Safe) | Client config & `.env` |
| `RAZORPAY_KEY_ID` | Client checkout modal initialization | **Allowed** (Safe) | Client config & `.env` |
| `SUPABASE_SERVICE_ROLE_KEY` | Serverless backend execution | **STRICTLY FORBIDDEN** | Supabase Edge Function Secrets |
| `RAZORPAY_KEY_SECRET` | HMAC signature calculation & Order API | **STRICTLY FORBIDDEN** | Supabase Edge Function Secrets |
| `RAZORPAY_WEBHOOK_SECRET` | Webhook event verification | **STRICTLY FORBIDDEN** | Supabase Edge Function Secrets |

---

## 2. Row Level Security (RLS) Policies

All PostgreSQL tables have Row Level Security enabled. Key rules:

1. **Student Profiles & Attendance**:
   ```sql
   CREATE POLICY "Students can view own profile"
   ON public.profiles FOR SELECT
   USING (auth.uid() = id);
   ```
2. **Fee Records & Installments**:
   * Students can only `SELECT` fee and installment records matching their own `auth.uid()`.
   * Direct `INSERT`, `UPDATE`, or `DELETE` operations are denied to student tokens.
3. **Administrative Access**:
   * Protected by checks against the `admin_users` table with `is_active = TRUE`.

---

## 3. Webhook Integrity & Replay Mitigation

* Webhook payload verification uses strict timing-safe HMAC SHA-256 validation.
* Replay attacks are mitigated by validating order state and checking existing payment IDs before processing ledger modifications.
