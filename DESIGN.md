# Design

Personal ledger for one person. Phone first. Utility register.

- Style: Minimal and clean. Off-white and near-black, one neutral sans, weight-led hierarchy. Hairlines, no shadows.
- Primary theme: Light. Settings can follow the system, or force light or dark. Dark is derived after light is right.
- Accent: Coral `#C2410C` for the record button, the selected tab, the selected day, and the month expense total. The month income total uses green `#0E7A42`. The month balance stays near-black. A transaction amount uses its category color. Transfer amounts stay near-black. Labels, the keypad, and app bars stay near-black on off-white.
- Category colors, reused and not free-form: 飲食 `#C2410C`, 交通 `#1D4ED8`, 住房 `#B45309`, 購物 `#0F766E`, 娛樂 `#BE185D`, 醫療 `#0E7A42`, 其他 `#3F4A57`. A category uses its color for its icon circle and its slice of the summary donut.
- Surfaces: one page color `#F7F7F6` for the screen and the keyboard. Hairline `#E6E6E4`, ink `#171717`, muted `#5C5C5C`. No separate keyboard panel.
- Motion: Calm. Press feedback only. Sheets use the platform transition.
- Voice: Minimal and matter-of-fact. Traditional Chinese and English. Buttons name the outcome.
- Dials: variance 3, motion 3, density 5.
- Primary action: 記一筆. The center tab button opens the transaction page. On that page the keypad commits with a check key. While an operator is pending, that key shows equals and evaluates before the check returns. The tab bar is hidden. Default type is expense. A new expense or income selects the first category of that kind.
- Corners: 12.
- Navigation: bottom bar 主頁, 分析, 帳戶, 設定, with the record button in the center. Every tab uses this bar. App bar titles are centered.
- Visual lead: typography.

## Decisions

- 2026-10-23: Light editorial ledger and persimmon accent. Superseded the same day.
- 2026-10-23: Style is Minimal and clean. Monochrome. Serif and persimmon are out.
- 2026-10-23: Home is one page. The app bar has one action. Its icon is the other mode: calendar opens the calendar, bars return to the summary. The month stays in the title.
- 2026-10-23: A month has one 結餘: income minus expense. Transfers stay out of 結餘.
- 2026-10-23: Category create and edit live under Settings. The transaction page only picks a category.
- 2026-10-23: Settings holds language, appearance, currency, first weekday, and categories.
- 2026-10-23: Single currency in the first version. Amounts are plain numbers. The currency symbol comes from settings.
- 2026-10-23: Every screen has an app bar. Add and edit transaction are full pages, one page per type.
- 2026-10-23: Transaction app bar title is the date and opens the date picker. A segment in the app bar switches 支出, 收入, and 轉帳.
- 2026-10-23: Expense and income use the page body for categories. The body is a grid of four items per row, icon above the name. It scrolls when there are more rows. Transfer uses the body for from and to.
- 2026-10-27: Category cells share one 8px gap. Each cell is at most 72 wide, and the grid is centered, so the horizontal gap stays short and even. A new expense or income selects the first category of that kind. Switching kind selects the first category of the new kind.
- 2026-10-23: The custom keyboard stays fixed and uses the page background. Keys are 1–9, decimal, delete, and + − × ÷. Evaluation is left to right. The saved amount is the result, and it must be greater than 0.
- 2026-10-23: The amount is its own full-width line, right aligned, only a little larger than the digit keys. It scales down only when the number would overflow. The expression is not shown. Remark and the account button sit on the next line. Delete stays inside the keypad.
- 2026-10-23: The keypad is four columns. The top row is + − × ÷. Under it, the digits are 1 2 3, 4 5 6, 7 8 9, and the bottom row is 0 . 00, each one cell. The right column under the operators is C, delete, then a vertical check that spans two rows. C clears the amount. Delete removes one digit. 00 appends two zeros. The operator in progress is coral. While an operator is pending, that key shows equals and evaluates the expression. The check returns after the result is shown, and only then commits. Expense and income use the account button. It opens a bottom sheet. Transfer keeps 從 and 到 in the page body and has no account button.
- 2026-10-23: Edit keeps the same page. 刪除 is the app bar action. The check key commits after any pending calculation. Switching type clears a category from the other kind and selects the first category of the new kind.
- 2026-10-23: Layout stays minimal. Color is added on purpose: coral for actions and expenses, green for income, and seven fixed category colors. Category edit can choose one of those colors.
- 2026-10-23: Summary shows a small income and expense pair, then a lower donut. 結餘 sits in the donut. The pair has no side labels on the chart. The list under that is transactions. Every screen uses the same off-white background, centered app bar title, and the same tab bar.
- 2026-10-23: Accounts is a tab. An account opens its own page: balance, this month's movement, history, and 轉帳.
- 2026-10-23: Analysis is a tab. It shows this month against the previous month, the last six months, then totals by category and by account.
