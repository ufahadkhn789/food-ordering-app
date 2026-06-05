**Design System — Online Food Delivery (Project)**

Overview
- Style: Professional, minimal, airy
- Primary color: #FF6A3D (Warm orange)

Palette
- Primary: #FF6A3D
- Primary Container: #FFEFE9
- Secondary: #2B2D42
- Accent: #00B894
- Surface: #FFFFFF
- Surface Variant: #F7F7FA
- Muted Text: #6B6E76
- Danger: #E53935

Typography
- Display / H1: 28sp, 700
- H2: 22sp, 600
- H3 / Title: 18sp, 600
- Body Large: 16sp
- Body: 14sp
- Caption: 12sp

Spacing
- Base unit: 8px
- Common: 4 / 8 / 12 / 16 / 24 / 32

Components
- `AppSearchBar` — rounded search field + filter
- `RestaurantCard` — image, name, cuisine, rating, ETA
- `MenuItemCard` — thumbnail, name, desc, price, Add button
- `FloatingCart` — sticky cart CTA with count and total

Screens
- Onboarding: hero, sign in/up, guest
- Home: search, featured carousel, cuisines chips, recommendations
- Restaurant: details, menu grouped, add-to-cart
- Cart & Checkout: editable items, delivery, payment
- Tracking: map, timeline, ETA
- Profile: orders, addresses, payments

Developer Notes
- Use Material3 `ThemeData(useMaterial3: true, colorScheme: ...)`
- Base radius: 12px
- Icons: Material (rounded) or custom SVG
