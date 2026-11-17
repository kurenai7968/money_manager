# Design

Personal account book for one person. Phone first. Utility register.

- Style: Minimal and clean. Off-white and near-black, one neutral sans, weight-led hierarchy. Hairlines, no shadows.
- Primary theme: Light. Settings can follow the system, or force light or dark. Dark is derived after light is right.
- Accent: Coral `#C2410C` for the record button, the selected tab, the selected day, and the month expense total. The month income total uses green `#0E7A42`. The month balance stays near-black. A transaction amount uses its category color. Transfer amounts stay near-black. Labels, the keypad, and app bars stay near-black on off-white.
- Surfaces: one page color `#F7F7F6` for the screen and the keyboard. Hairline `#E6E6E4`, ink `#171717`, muted `#5C5C5C`. No separate keyboard panel.
- Motion: Calm. Press feedback only. Sheets use the platform transition.
- Sheets: the page background, a 12 top radius, and no shadow. An account sheet is at most half the screen tall and scrolls past that.
- Voice: Minimal and matter-of-fact. Traditional Chinese and English. Buttons name the outcome.
- Dials: variance 3, motion 3, density 5.
- Corners: 12.
- Visual lead: typography.

## Navigation

The bottom bar is 主頁, 分析, 帳戶, 設定, with the record button in the center. Every tab uses this bar. The center button opens the record page, and that page hides the bar. App bar titles are centered. Every screen has an app bar.

## Home

Home is one page. The month stays in the centered title. Its step controls are compact so the leading account keeps room. A long account name ellipsizes after the first characters. A leading control selects one account or all accounts and opens a sheet. All is the default. One action switches summary and calendar. Its icon is the other mode: calendar opens the calendar, bars return to the summary.

Summary shows a small income and expense pair, then a lower donut. 結餘 sits in the donut and is income minus expense. Transfers stay out of 結餘. The pair has no side labels on the chart. The list under that is transactions. Stepping to the next month selects that month's first day. Stepping to the previous month selects its last day.

## Record

Add and edit use the same page. The title is the date and opens the date picker. A segment switches 支出, 收入, and 轉帳. Default type is expense. A new expense or income selects the first category of that kind. Switching kind clears a category from the other kind and selects the first category of the new kind.

Expense and income use the page body for categories. The body is a grid of four items per row, icon above the name. Cells share one 8px gap. Each cell is at most 72 wide, and the grid is centered. It scrolls when there are more rows. Transfer uses the body for 從 and 到, and has no account button. Expense and income use the account button, which opens a bottom sheet.

The keypad stays fixed and uses the page background. It is four columns. The top row is + − × ÷. Under it, the digits are 1 2 3, 4 5 6, 7 8 9, and the bottom row is 0 . 00, each one cell. The right column under the operators is C, delete, then a vertical check that spans two rows. C clears the amount. Delete removes one digit. 00 appends two zeros. Evaluation is left to right. The saved amount is the result, and it must be greater than 0. The expression is not shown. The amount is its own full-width line, right aligned, only a little larger than the digit keys. It scales down only when the number would overflow. Remark and the account button sit on the next line. The operator in progress is coral. While an operator is pending, the check key shows equals and evaluates before the check returns. The check commits only after the result is shown. 刪除 is the app bar action.

## Other screens

Accounts is a tab. An account opens its own page: balance, this month's movement, history, and 轉帳.

Analysis is a tab. It shows this month against the previous month, the last six months, then totals by category and by account.

Settings holds language, appearance, currency, the first weekday, and categories. Single currency. Amounts are plain numbers. The currency symbol comes from settings. Category create and edit live under Settings. The record page only picks a category.

## Transaction row

A row shows the category icon, category name, note, amount, and account. The amount uses the category color. Transfer amounts stay near-black. A `#tag` in the note uses the income green. Home summary, the home calendar, and account history share that row and group it by day. The day header shows the date and that day's expense. Tapping the header collapses that day. The calendar lists the selected day.
