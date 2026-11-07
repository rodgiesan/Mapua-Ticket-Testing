# Moving the MCL Help Desk to Supabase

1. **Create the project.** supabase.com → New project. Wait for it to finish starting.
2. **Run the SQL.** SQL Editor → New query → paste `1-schema.sql` → Run. Then do the same with `2-import-firebase-data.sql` (your current users, tickets, alerts and photos, exported 2026-11-07).
3. **Paste the keys.** Project Settings → API. Copy the Project URL and the `anon` `public` key into the top of the script in `index.html` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
4. **Allow your site address.** Authentication → URL Configuration: set Site URL to your Vercel address (e.g. `https://your-app.vercel.app`) and add the same address under Redirect URLs.
5. **Leave "Confirm email" on** (Authentication → Sign In / Providers → Email). It is what stops someone from claiming another person's moved account.
6. **Set up email sending (needed for real users).** Supabase's built-in email only sends to your own team's addresses and only a few per hour. Under Authentication → Emails → SMTP Settings, connect a provider (Resend, Brevo, or a Gmail app password all work). If you change the sender address, also change `SENDER` near the top of the script.
7. **Deploy.** Commit `index.html` to GitHub; Vercel redeploys.

## What changes for people
- **Old username accounts** (like `admin`) log in exactly as before.
- **Email accounts** can't bring their Firebase passwords along. Each person taps **Create account** with the same email, confirms it, and logs in. Their old profile, role and tickets reconnect automatically.
- Invited accounts get a confirm link, then choose their password in the app.

## Rollback
`index-firebase-backup.html` is the last Firebase version.
