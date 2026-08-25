# Supabase Edge Functions Deployment Guide

Supabase Edge Functions are written in TypeScript and executed globally on Deno runtime.

---

## 1. Directory Structure

```
supabase/functions/
├── create-payment-order/
│   └── index.ts
└── verify-payment-webhook/
    └── index.ts
```

---

## 2. Setting Environment Secrets

Before deploying, set the required cryptographic secrets in Supabase:

```bash
# Razorpay Key ID & Key Secret (Test or Live)
supabase secrets set RAZORPAY_KEY_ID="rzp_test_..."
supabase secrets set RAZORPAY_KEY_SECRET="your_razorpay_secret"
supabase secrets set RAZORPAY_WEBHOOK_SECRET="your_webhook_secret"
```

---

## 3. Function Deployment Command

```bash
# Deploy order creation function
supabase functions deploy create-payment-order --no-verify-jwt

# Deploy webhook verification function
supabase functions deploy verify-payment-webhook --no-verify-jwt
```

---

## 4. Local Testing & Invocation

```bash
# Serve functions locally
supabase functions serve
```
