import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // 1. Authenticate the student caller
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized: Missing Authorization header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(token);

    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized: Invalid user session" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { installmentId } = await req.json();

    if (!installmentId) {
      return new Response(JSON.stringify({ error: "Bad Request: Missing installmentId" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Fetch installment and verify ownership server-side (Cannot pay another student's fee)
    const { data: installment, error: instError } = await supabaseAdmin
      .from("fee_installments")
      .select("id, fee_id, title, amount, status, fees(student_id)")
      .eq("id", installmentId)
      .single();

    if (instError || !installment) {
      return new Response(JSON.stringify({ error: "Installment not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const installmentOwner = (installment.fees as any)?.student_id;
    if (installmentOwner !== user.id) {
      return new Response(JSON.stringify({ error: "Forbidden: You cannot pay another student's fee installment" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (installment.status === "paid") {
      return new Response(JSON.stringify({ error: "Installment is already paid" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 3. Server-validated amount (in Paise for INR)
    const validatedAmountPaise = Math.round(Number(installment.amount) * 100);
    const keyId = Deno.env.get("RAZORPAY_KEY_ID") || "rzp_test_TS6aY6OCDjZldb";
    const keySecret = Deno.env.get("RAZORPAY_KEY_SECRET") || "";

    // 4. Create Razorpay Test Order via Razorpay REST API
    const basicAuth = btoa(`${keyId}:${keySecret}`);
    const receiptId = `AI_ORD_${Date.now()}_${installment.id.substring(0, 8)}`;
    
    const rzpResponse = await fetch("https://api.razorpay.com/v1/orders", {
      method: "POST",
      headers: {
        Authorization: `Basic ${basicAuth}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        amount: validatedAmountPaise,
        currency: "INR",
        receipt: receiptId,
        notes: {
          studentId: user.id,
          installmentId: installment.id,
          feeId: installment.fee_id,
          title: installment.title,
        },
      }),
    });

    const orderData = await rzpResponse.json();

    if (!rzpResponse.ok) {
      return new Response(JSON.stringify({ error: "Razorpay order creation failed", details: orderData }), {
        status: 502,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(
      JSON.stringify({
        orderId: orderData.id,
        amount: orderData.amount,
        currency: orderData.currency,
        keyId: keyId,
        installmentTitle: installment.title,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
