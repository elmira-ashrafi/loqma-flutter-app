# Admin panel: multilingual content (en / fa / ps)

The Flutter app sends **`Accept-Language`** and **`X-App-Locale`** (`en`, `fa`, or `ps`) on every API request. Use these in Laravel to return the correct language where possible.

## Fields to maintain in the admin panel

For each entity below, store **English** in the base field and **Dari** / **Pashto** in `*_fa` / `*_ps` columns (same pattern as restaurant owner menu forms).

| Entity | Base (en) | Dari | Pashto |
|--------|-----------|------|--------|
| Restaurant | `name`, `description` | `name_fa`, `description_fa` | `name_ps`, `description_ps` |
| Menu category | `name` | `name_fa` | `name_ps` |
| Menu item / food | `name`, `description` | `name_fa`, `description_fa` | `name_ps`, `description_ps` |
| Variants / addons | `name` | `name_fa` | `name_ps` |
| Home category | `name` | `name_fa` | `name_ps` |
| Banner | `title`, `subtitle` | `title_fa`, `subtitle_fa` | `title_ps`, `subtitle_ps` |
| Promotion / offer label | `offer_label` | `offer_label_fa` | `offer_label_ps` |

## API behaviour

1. **Preferred:** Return localized strings in the main `name` / `title` fields based on `Accept-Language` when `*_fa` / `*_ps` exist.
2. **Also supported:** Return all three (`name`, `name_fa`, `name_ps`); the app picks the best match client-side.

## App UI strings

Static labels (buttons, errors, tabs) are **not** from the admin panel. They live in:

- `lib/l10n/app_en.arb`
- `lib/l10n/app_fa.arb`
- `lib/l10n/app_ps.arb`

Run `flutter gen-l10n` after editing ARB files.

## Restaurant owner app

Owners already edit `name_fa` in menu/settings forms. Ensure the **admin** portal uses the same columns for global categories, banners, and default copy so customers see Pashto/Dari when the app language is set accordingly.
