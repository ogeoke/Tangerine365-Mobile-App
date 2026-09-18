# Pending issues — Tangerine365 mobile app

_Last updated: 16 Sep 2026_

## 1. Message reply fails — BACKEND (open)

**Symptom:** In the app, Information Management → Messages → open an admin message → type a reply → Send shows **"Reply not sent"**.

**Endpoint:** `POST /api/messages/reply/{messageId}`

**Reproduced (16 Sep 2026):**

| Test | Result |
|---|---|
| learner `luca` (idst 195453) replies to message **18** "Congratulations on Your Progress!" (multipart, as the app sends) | **HTTP 500** `{"success":false,"message":"The message could not be sent."}` |
| Same, urlencoded body | **HTTP 500**, same error |
| Reply to message **17** "Welcome to the LMS" | **HTTP 500**, same error |
| luca's `messages/sent` afterwards | `total: 0` (nothing created) |

Both messages were sent by admin **Ogechi Okechukwu (idst 11840)**. Validation passes (`auth`, `messageId`, `content` all present), so the failure is in the message-creation / recipient step. **Backend: please check the server error log.**

**App status:** fixed on the app side. The app now sends `messageId` in the body. Without it, the server rejects the reply with **422** "A message and non-empty reply are required". No further app change is expected. Retest once the backend is fixed.

## 2. Related backend asks

1. **Reply docs:** `messageId` must be sent in the request **body**, but the docs only show it in the URL. Update the docs, or read it from the URL.
2. **Attachment URL:** `attachment.url` is always `null` (only `name` is returned). The app currently builds `https://tangerinelms.com/files/appLms/message/<name>`. Please return the full URL.
3. **Emojis:** 4-byte emojis in messages are stored as `????` (e.g. 🎯 📈), while ✨ survives. The messages tables/columns need the **utf8mb4** character set. The app hides `????` for now.
4. **Security (bank audit):** message attachments under `files/appLms/message/` can be downloaded **without logging in** by anyone who has the link.

## 3. Other pending items

- **Certificates:** "Generate certificate" needs an issue/generate endpoint from the backend. The app currently only renders certificates that are already issued.
