# Reports specification
Selected local date scopes exports. Case-insensitive search filters display only; exports include the whole selected day.
- Copy day's work: date header, HH:mm and activity text in stored order.
- Copy as bullet points: one Unicode bullet per activity, no date/timestamps; normalize CRLF and indent continuation lines two spaces. Do not split multiline notes into multiple activities.
- Copy JSON: date and activities object, two-space pretty printing.
- Empty day: text/bullet disabled; JSON exports empty array.
- Clipboard success appears only after write completes.

ReportFormatter is pure and takes typed entries. Export schema excludes tasks/preferences. Clipboard integration belongs to controller.
Tests: report_formatter_test.dart covers Unicode, CRLF, ordering, empty days and JSON/text. Actual paste into another app is manual.
