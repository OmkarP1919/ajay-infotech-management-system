# Payment Pipeline & Security Architecture

This document details the end-to-end payment integration between the Student Mobile App, Supabase Edge Functions, Razorpay Gateway, and the PostgreSQL database ledger.

---

## Payment Sequence Flow

```mermaid
sequenceDiagram
    autonumber
    actor Student as Student Mobile App
    participant EdgeOrder as Edge Function (create-payment-order)
    participant Razorpay as Razorpay API / SDK
    participant EdgeVerify as Edge Function (verify-payment-webhook)
    participant DB as PostgreSQL Database

    Student->>EdgeOrder: POST /create-payment-order (Bearer Student_JWT, installmentId)
    Note over EdgeOrder: 1. Validate JWT<br/>2. Verify installment ownership<br/>3. Read pending balance
    EdgeOrder->>Razorpay: POST /v1/orders (amount, currency: INR, notes)
    Razorpay-->>EdgeOrder: 200 OK (order_id, amount)
    EdgeOrder-->>Student: Return { orderId, amount, keyId }

    Student->>Razorpay: Launch Razorpay Checkout Modal (orderId, keyId)
    Note over Student,Razorpay: Student completes UPI / Card / NetBanking payment
    Razorpay-->>Student: Success Callback (razorpay_payment_id, signature, razorpay_order_id)

    Student->>EdgeVerify: POST /verify-payment-webhook (orderId, paymentId, signature)
    Note over EdgeVerify: Authoritative HMAC SHA-256 Signature Verification
    EdgeVerify->>DB: Check idempotency (payment_id exists?)
    EdgeVerify->>DB: Begin Transaction
    EdgeVerify->>DB: Insert record into `payments` table (status: 'success')
    EdgeVerify->>DB: Update `fee_installments` (status: 'paid', paid_date, receipt_no)
    EdgeVerify->>DB: Deduct `fees.outstanding_amount` & increment `fees.paid_amount`
    EdgeVerify->>DB: Commit Transaction
    EdgeVerify-->>Student: 200 OK { status: 'success', verified: true }

    Student->>Student: Invalidate & Refresh Riverpod `feeSummaryProvider`
```

---

## Critical Security Controls

### 1. Zero Secrets in Client Applications
* Mobile and web applications **never** possess `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET`, or `SUPABASE_SERVICE_ROLE_KEY`.
* Only the client-safe public identifier (`RAZORPAY_KEY_ID`) and public anon key (`SUPABASE_ANON_KEY`) are present on client devices.

### 2. Cryptographic Signature Verification
* Verification is executed in `verify-payment-webhook` using Node/Deno Web Crypto `HMAC-SHA256`:
  $$\text{expected\_signature} = \text{HMAC-SHA256}(\text{order\_id} + "|" + \text{payment\_id}, \text{RAZORPAY\_KEY\_SECRET})$$
* Any mismatch immediately halts the transaction and logs a security violation.

### 3. Idempotency & Replay Prevention
* The PostgreSQL `payments` table maintains a `UNIQUE (razorpay_payment_id)` constraint.
* If a duplicate verification request or webhook retry arrives, the Edge Function safely detects existing status and returns success without deducting duplicate balances.

### 4. Deterministic Receipt Generation
* When an installment is settled, the server issues a standardized receipt sequence:
  `AI-REC-{YEAR}-{RANDOM_OR_SEQUENCE}`
