# Razorpay Payment Gateway Setup Guide

This guide details configuring Razorpay in Test Mode and transitioning to Production Live Mode.

---

## 1. Razorpay Dashboard Configuration

1. Register or sign in at [Razorpay Dashboard](https://dashboard.razorpay.com/).
2. Switch to **Test Mode** during development.
3. Navigate to **Account & Settings > API Keys** and generate a new key pair:
   * **Key ID** (`rzp_test_...`) $\rightarrow$ Public identifier for client applications.
   * **Key Secret** $\rightarrow$ Private secret used strictly by Supabase Edge Functions.

---

## 2. Webhook Configuration

1. In Razorpay Dashboard, go to **Settings > Webhooks > Add New Webhook**.
2. **Webhook URL**:
   `https://<your-project-ref>.supabase.co/functions/v1/verify-payment-webhook`
3. **Secret**: Set a high-entropy secret string and configure the same value in Supabase:
   ```bash
   supabase secrets set RAZORPAY_WEBHOOK_SECRET=your_configured_secret
   ```
4. **Active Events**:
   * `payment.captured`
   * `order.paid`
   * `payment.failed`

---

## 3. Testing Test Payments

Use the official Razorpay test cards or UPI handles:
* **UPI**: `success@razorpay`
* **Card**: Any standard test card number provided in Razorpay documentation.
