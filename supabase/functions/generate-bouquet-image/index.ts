import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const openAiKey = Deno.env.get("OPENAI_API_KEY");
    if (!openAiKey) {
      return json({ error: "OPENAI_API_KEY Supabase secret olarak tanımlı değil." }, 500);
    }

    const body = await req.json();
    const style = body.style === "lego" ? "lego" : "realistic";
    const prompt = buildPrompt({
      style,
      prompt: String(body.prompt ?? ""),
      flowers: body.flowers ?? {},
      ribbon: String(body.ribbon ?? ""),
      size: String(body.size ?? ""),
    });

    const response = await fetch("https://api.openai.com/v1/images/generations", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${openAiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-image-1-mini",
        prompt,
        size: "1024x1024",
        quality: "medium",
        output_format: "png",
      }),
    });

    const data = await response.json();
    if (!response.ok) {
      return json({ error: data.error?.message ?? "OpenAI görsel üretimi başarısız." }, response.status);
    }

    const imageBase64 = data.data?.[0]?.b64_json;
    if (!imageBase64) {
      return json({ error: "OpenAI görsel verisi dönmedi." }, 500);
    }

    return json({ imageBase64, prompt });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : String(error) }, 500);
  }
});

function buildPrompt(input: {
  style: "realistic" | "lego";
  prompt: string;
  flowers: Record<string, number>;
  ribbon: string;
  size: string;
}) {
  const flowerText = Object.entries(input.flowers)
    .map(([name, count]) => `${count} ${name}`)
    .join(", ");
  const content = flowerText || input.prompt || "custom mixed flower bouquet";
  const styleText = input.style === "lego"
    ? "LEGO brick-built flower bouquet, clearly made of toy bricks, premium product photo"
    : "realistic fresh flower bouquet, natural petals and stems, premium product photo";

  return [
    styleText,
    `Flowers: ${content}`,
    input.ribbon ? `Ribbon: ${input.ribbon}` : "",
    input.size ? `Bouquet size: ${input.size}` : "",
    "Centered bouquet, clean soft studio background, no text, no watermark, no hands, full bouquet visible.",
  ].filter(Boolean).join(". ");
}

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}
