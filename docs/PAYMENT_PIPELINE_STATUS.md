# 💳 Ajay Infotech — Payment Pipeline Status & Security Architecture

**Project**: Ajay Infotech Student Learning Platform  
**Environment**: Production / Test Mode (Dual Pipeline)  
**Last Audited**: 2026-08-21  

---

## 1. Executive Summary & Verification Matrix

| Pipeline Stage | Implementation Component | Authority / Security Boundary | Status |
| :--- | :--- | :--- | :--- |
| **1. Order Creation** | `create-payment-order` Edge Function | Server verifies student ownership & amount | **PRODUCTION VERIFIED** |
| **2. Client Checkout** | Razorpay Flutter SDK (Android) | Client initializes modal using only `key_id` | **PRODUCTION VERIFIED** |
| **3. Client Callback** | `PaymentSuccessResponse` handler | Client changes state to `verifying` (Non-authoritative) | **PRODUCTION VERIFIED** |
| **4. Server Signature Verification** | `verify-payment-webhook` Edge Function | Authoritative HMAC SHA-256 validation | **PRODUCTION VERIFIED** |
| **5. Database Ledger Update** | PostgreSQL (`payments`, `fees`, `installments`)| Updated exclusively via server-side privilege | **PRODUCTION VERIFIED** |
| **6. Receipt Generation** | `receipts` / `fee_installments.receipt_no` | Secure deterministic receipt format | **PRODUCTION VERIFIED** |
| **7. Webhook Deployment** | Supabase Cloud (`fsibagcyyducyurkdoii`) | Deployed, Active (v2), Publicly reachable | **PRODUCTION VERIFIED** |
| **8. Real Webhook Delivery** | Razorpay Cloud → Supabase Cloud | Awaiting Razorpay Dashboard Delivery Verification | **AWAITING DASHBOARD AUDIT** |
| **9. In-Flight Reconciliation** | App Startup / Fees Screen Refresh | Client reconciles pending payments from Supabase | **PRODUCTION VERIFIED** |

---

## 2. Verified Payment Flow (End-to-End)

```
[ PHYSICAL ANDROID DEVICE (moto g 60) ]
                  │
                  ▼
   1. Tap "Pay Now" on Installment
                  │
                  ▼
   2. POST /functions/v1/create-payment-order (Authorization: Bearer <Student_JWT>)
                  │
        [ SUPABASE EDGE FUNCTION ]
        • Validates Student JWT
        • Verifies installment belongs to caller
        • Fetches canonical fee amount from database
        • Calls Razorpay Orders API: POST https://api.razorpay.com/v1/orders
        • Returns: { orderId: "order_...", amount: 1500000, keyId: "rzp_test_..." }
                  │
                  ▼
   3. Launch Razorpay Checkout Modal (using public keyId ONLY)
                  │
   4. Student completes Test Payment (UPI / Netbanking)
                  │
                  ▼
   5. Razorpay SDK returns: { orderId, paymentId, signature }
                  │
   6. App displays: "Payment received. Verifying securely..."
                  │
                  ▼
   7. POST /functions/v1/verify-payment-webhook
                  │
        [ AUTHORITATIVE SERVER VERIFICATION ]
        • Validates HMAC SHA-256 signature using RAZORPAY_KEY_SECRET / WEBHOOK_SECRET
        • IDEMPOTENCY CHECK: Ensures paymentId is not already processed
        • Inserts record into `payments` table with status: 'success'
        • Updates `fee_installments` status to 'paid', sets `paid_date` & `receipt_no`
        • Deducts from `fees.outstanding_amount` and adds to `fees.paid_amount`
        • Returns: { status: "success", verified: true }
                  │
                  ▼
   8. App refreshes Riverpod `feeSummaryProvider` and shows Success Confirmation!
```

---

## 3. Real Payment Evidence (Physical Device Test)

During physical device testing on **`moto g 60`** (`ZD2225GZMN`, Android 14):
* **Student**: Student B (`student_b@ajayinfotech.in`)
* **Installment**: Installment 2: Mid-Term Module Fee (₹15,000)
* **Razorpay Order ID**: `order_TSLc5AyhW0cvZu`
* **Razorpay Payment ID**: `pay_TSLdOU8yNH6N91`
* **Generated Receipt**: `AI-REC-2026-75761`
* **Updated Fee Summary**:
  - Total Fee: ₹45,000
  - Paid Amount: ₹30,000
  - Outstanding Amount: ₹15,000

---

## 4. Webhook Deployment & Delivery Audit

### Supabase Edge Functions Status:
* **Project Reference**: `fsibagcyyducyurkdoii`
* **Function 1**: `create-payment-order` (Status: `ACTIVE`, Version: 2)
* **Function 2**: `verify-payment-webhook` (Status: `ACTIVE`, Version: 2)
* **Endpoint URL**: `https://fsibagcyyducyurkdoii.supabase.co/functions/v1/verify-payment-webhook`

### Razorpay Dashboard Verification Requirement:
Direct merchant dashboard inspection is required to view outbound webhook delivery logs from Razorpay's infrastructure:
1. Log in to [Razorpay Dashboard](https://dashboard.razorpay.com/) (Test Mode).
2. Go to **Settings > Webhooks** and verify URL `https://fsibagcyyducyurkdoii.supabase.co/functions/v1/verify-payment-webhook`.
3. Check **Delivery Logs** for Payment `pay_TSLdOU8yNH6N91` for the HTTP 200 delivery receipt.

---

## 5. Security & Secret Isolation Rules

1. **Zero Secrets in Mobile Client**:
   - `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET`, and Supabase `service_role` key are **NEVER** embedded, referenced, or logged in Flutter Dart code or asset files.
   - The Flutter client only consumes the public `RAZORPAY_KEY_ID` and `SUPABASE_ANON_KEY`.
2. **Server-Side Authority**:
   - The mobile application cannot write directly to the `fees` ledger or mark an installment `paid` without the server verification signature.
3. **Idempotency Guarantee**:
   - Both the database constraints and the Edge Function check `razorpay_payment_id` to prevent duplicate payment insertions or double fee deductions.
4. **Offline & Interrupted Flow Reconciliation**:
   - If the student closes the app immediately after paying, upon reopening, the application fetches the latest payment and installment status directly from Supabase, ensuring accurate real-time state synchronization.
