// index.mjs (Node.js 20)
import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";
import crypto from "crypto";

const ses = new SESClient({ region: "ap-northeast-1" });

// 環境変数化してもOK
const FROM = "no-reply@aws.ait0303.com";
const BASE_URL = "https://wdggqup3qg5gb3wxxrdhjhwsde0racsm.lambda-url.ap-northeast-1.on.aws";

export const handler = async (event) => {
  const headers = {
    "content-type": "application/json",
    "access-control-allow-origin": "http://localhost:5500",
    "access-control-allow-methods": "POST,OPTIONS",
    "access-control-allow-headers": "content-type",
  };

  // preflight
  if (event.requestContext?.http?.method === "OPTIONS") {
    return { statusCode: 204, headers };
  }

  const body = typeof event.body === "string" ? JSON.parse(event.body) : (event.body || {});
  const to = body?.email;
  if (!to) return { statusCode: 400, headers, body: JSON.stringify({ message: "email is required" }) };

  const token = crypto.randomBytes(24).toString("base64url");
  const url = `${BASE_URL}?token=${token}`;

  await ses.send(new SendEmailCommand({
    Source: FROM,
    Destination: { ToAddresses: [to] },
    Message: {
      Subject: { Data: "一時URLのご案内（60分目安）", Charset: "UTF-8" },
      Body: { Text: { Data: `こちらが一時URLです：\n${url}\n\n※デモ用トークン`, Charset: "UTF-8" } }
    }
  }));

  return { statusCode: 200, headers, body: JSON.stringify({ ok: true }) };
};
