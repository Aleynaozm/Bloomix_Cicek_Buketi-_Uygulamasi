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
      template: String(body.template ?? ""),
      flowerLayout: Array.isArray(body.flowerLayout) ? body.flowerLayout : [],
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
  template: string;
  flowerLayout: Array<Record<string, unknown>>;
}) {
  const flowerText = Object.entries(input.flowers)
    .map(([name, count]) => `${count} ${name}`)
    .join(", ");
  const content = flowerText || input.prompt || "custom mixed flower bouquet";
  const styleText = input.style === "lego"
    ? "LEGO brick-built flower bouquet, clearly made of toy bricks, premium product photo, same bouquet composition as a simple mobile bouquet preview"
    : "realistic fresh flower bouquet, natural petals and stems, premium product photo, same bouquet composition as a simple mobile bouquet preview";
  const compositionText = input.style === "lego"
    ? "Preserve a compact hand-tied bouquet silhouette: tall center flowers, smaller flowers around them, visible green stems gathered at the bottom, ribbon tied at the lower stem area. Do not redesign it as a wide dome, basket, vase, wreath, or large rose ball."
    : "Preserve a compact hand-tied bouquet silhouette: tall center flowers, smaller flowers around them, visible green stems gathered at the bottom, ribbon tied at the lower stem area. Do not redesign it as a wide dome, basket, vase, wreath, or large rose ball.";
  const templateText = templateInstructions(input.template);
  const layoutText = input.flowerLayout.length
    ? `Approximate flower layout from the user's design canvas: ${input.flowerLayout
      .map((item) => `${item.flower ?? "flower"} at x=${item.x ?? "?"}, y=${item.y ?? "?"}, scale=${item.scale ?? "1"}`)
      .join("; ")}. Preserve this relative arrangement: flowers with lower y values appear higher, lower x values appear left, higher x values appear right.`
    : "";

  return [
    styleText,
    `Flowers: ${content}`,
    input.ribbon ? `Ribbon: ${input.ribbon}` : "",
    input.size ? `Bouquet size: ${input.size}` : "",
    templateText,
    layoutText,
    compositionText,
    "Match the requested flower counts as closely as possible. Keep the bouquet front-facing, centered, isolated on a clean soft studio background, no text, no watermark, no hands, full bouquet visible.",
  ].filter(Boolean).join(". ");
}

function templateInstructions(template: string) {
  switch (template) {
    case "modern":
      return "Bouquet template: modern wrapped bouquet. Use visible folded wrapping paper around the stems, with a soft pink outer wrap and muted green inner wrap, gathered into a neat cone shape. The ribbon is tied over the wrap near the bottom. Do not leave the stems completely bare.";
    case "minimal":
      return "Bouquet template: minimal bouquet. Use a small, airy, simple hand-tied arrangement with very little filler, clean negative space, slim visible stems, and a subtle ribbon. Avoid dense round bouquets.";
    case "luxury":
      return "Bouquet template: luxury bouquet. Use a fuller premium arrangement with elegant layered wrapping, polished ribbon, balanced height, and a refined boutique-florist look. Avoid plain bare stems.";
    case "classic":
    default:
      return "Bouquet template: classic hand-tied bouquet. Use visible green stems gathered naturally at the bottom with a ribbon, no vase, no basket, no large round rose dome.";
  }
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
