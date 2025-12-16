# 🎨 JewelStack Luxury Color Palette Reference

## Primary Luxury Colors

```dart
// Rose Gold - Premium Metal Accent
const Color rosegold = Color(0xFFD4AF37);
const Color rosegoldDark = Color(0xFFC19A00);

// Dark Charcoal - Sophisticated Base
const Color darkCharcoal = Color(0xFF1F1F1F);
const Color darkBrown = Color(0xFF2D2416);
const Color richBrown = Color(0xFF3E2723);

// Premium Background
const Color premiumCream = Color(0xFFFAF9F6);
```

## Category-Specific Palettes

### Gold Details Theme
```dart
// Primary Accent
const Color goldAccent = Color(0xFFD4AF37); // Rose Gold

// Metal Colors
const Color silverAccent = Color(0xFFC0C0C0);
const Color copperAccent = Color(0xFFB87333);
const Color otherMetals = Color(0xFF9CA3AF);

// Gradient
LinearGradient goldGradient = LinearGradient(
  colors: [
    Color(0xFFFAF9F6),
    Color(0xFFD4AF37).withOpacity(0.08),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

### Rudraksh Details Theme
```dart
// Primary Accent Colors
const Color rudrakshPrimary = Color(0xFF5D4037); // Deep Brown
const Color rudrakshSecondary = Color(0xFF8B7355); // Medium Brown
const Color rudrakshTertiary = Color(0xFFA1887F); // Light Brown

// Icon Gradient
LinearGradient rudrakshGradient = LinearGradient(
  colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Gradient Background
LinearGradient rudrakshCardGradient = LinearGradient(
  colors: [
    Color(0xFFFAF9F6),
    Color(0xFF8B7355).withOpacity(0.08),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

### Gemstones Details Theme
```dart
// Primary Accent Colors
const Color gemPrimary = Color(0xFF1E3A5F); // Royal Blue
const Color gemSecondary = Color(0xFF2D5016); // Deep Emerald
const Color gemTertiary = Color(0xFF4A3F35); // Subtle Brown

// Icon Gradient
LinearGradient gemGradient = LinearGradient(
  colors: [Color(0xFF1E3A5F), Color(0xFF2D5016)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Gradient Background
LinearGradient gemCardGradient = LinearGradient(
  colors: [
    Color(0xFFFAF9F6),
    Color(0xFF1E3A5F).withOpacity(0.06),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

## Neutral & Supporting Colors

```dart
// Text Colors
const Color textPrimary = Color(0xFF1F1F1F); // Dark gray
const Color textSecondary = Color(0xFF5D4037); // Medium brown
const Color textTertiary = Color(0xFF9CA3AF); // Light gray

// Background Variations
const Color backgroundLight = Color(0xFFFAF9F6); // Premium cream
const Color backgroundDark = Color(0xFF3E2723); // Dark brown

// Borders & Dividers
const Color borderColor = Color(0xFFD4AF37); // Rose gold (with opacity)
const Color dividerColor = Color(0xFFE5E5E5); // Light gray

// Shadow Colors
Color shadowPremium = Colors.black.withOpacity(0.06); // Subtle
Color shadowHover = Colors.black.withOpacity(0.08); // Light hover
Color shadowDeep = Colors.black.withOpacity(0.15); // Deep shadows
```

## Dashboard Navigation Card Colors

```dart
// Inventory Card
const Color inventoryPrimary = Color(0xFFD4AF37); // Rose Gold
const Color inventorySecondary = Color(0xFFC19A00);

// Customers Card
const Color customersPrimary = Color(0xFF8B7355); // Deep Brown
const Color customersSecondary = Color(0xFFA1887F);

// Orders Card
const Color ordersPrimary = Color(0xFF1E3A5F); // Royal Blue
const Color ordersSecondary = Color(0xFF2D5016); // Emerald

// ML Insights Card
const Color mlPrimary = Color(0xFF4A3F35); // Dark Brown
const Color mlSecondary = Color(0xFF3E2723); // Rich Brown
```

## Gradient Definitions

### AppBar & Headers Gradient
```dart
LinearGradient luxuryAppBarGradient = LinearGradient(
  colors: [
    Color(0xFF1F1F1F),
    Color(0xFF2D2416),
    Color(0xFF3E2723),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

### Bottom Navigation Bar Styling
```dart
// Background
Color bottomNavBackground = Color(0xFFFAF9F6); // Premium Cream

// Selected Item
Color bottomNavSelected = Color(0xFFD4AF37); // Rose Gold

// Unselected Item
Color bottomNavUnselected = Color(0xFF9CA3AF); // Light Gray
```

## Shadow Styles

```dart
// Premium Card Shadow
BoxShadow premiumShadow = BoxShadow(
  color: Colors.black.withOpacity(0.06),
  blurRadius: 16,
  offset: const Offset(0, 6),
);

// Hover Shadow (Interactive)
BoxShadow hoverShadow = BoxShadow(
  color: Colors.black.withOpacity(0.08),
  blurRadius: 12,
  offset: const Offset(0, 4),
);

// Category Specific Shadow (Example: Rose Gold)
BoxShadow categoryGoldShadow = BoxShadow(
  color: Color(0xFFD4AF37).withOpacity(0.3),
  blurRadius: 8,
);
```

## Border Styling

```dart
// Premium Card Border
Border premiumCardBorder = Border.all(
  color: Color(0xFFD4AF37).withOpacity(0.3),
  width: 1.5,
);

// Category-Specific Borders
Border goldBorder = Border.all(
  color: Color(0xFFD4AF37).withOpacity(0.3),
  width: 1.5,
);

Border brownBorder = Border.all(
  color: Color(0xFF8B7355).withOpacity(0.3),
  width: 1.5,
);

Border blueBorder = Border.all(
  color: Color(0xFF1E3A5F).withOpacity(0.3),
  width: 1.5,
);
```

## Typography Colors

```dart
// Headers
Color headerPrimary = Color(0xFF1F1F1F); // Dark charcoal
Color headerAccent = Color(0xFFD4AF37); // Rose gold (for subtitles)

// Body Text
Color bodyPrimary = Color(0xFF3F3F3F); // Dark gray
Color bodySecondary = Color(0xFF5D4037); // Medium brown

// Labels & Captions
Color labelPrimary = Color(0xFF1F1F1F); // Dark charcoal
Color labelAccent = Color(0xFFD4AF37); // Rose gold for emphasis
```

## Animation & Transition Colors

```dart
// Loading States
Color loadingPrimary = Color(0xFFD4AF37); // Rose gold spinner

// Focus States
Color focusBorder = Color(0xFFD4AF37); // Rose gold outline
Color focusBackground = Color(0xFFD4AF37).withOpacity(0.1); // Light wash

// Error States
Color errorColor = Color(0xFFD32F2F); // Standard error red
Color errorBackground = Color(0xFFFFEBEE); // Light error background

// Success States
Color successColor = Color(0xFF2E7D32); // Standard success green
Color successBackground = Color(0xFFE8F5E9); // Light success background
```

## Opacity Reference

```dart
// Transparency levels
const double opacityFull = 1.0;
const double opacityStrong = 0.75;
const double opacityMedium = 0.5;
const double opacityLight = 0.3;
const double opacitySubtle = 0.1;
const double opacityMinimal = 0.06;
```

## CSS Equivalent for Web

```css
/* Primary Colors */
:root {
  --rose-gold: #D4AF37;
  --rose-gold-dark: #C19A00;
  --dark-charcoal: #1F1F1F;
  --dark-brown: #2D2416;
  --rich-brown: #3E2723;
  --premium-cream: #FAF9F6;
  
  /* Category Colors */
  --gold-accent: #D4AF37;
  --rudraksh-primary: #5D4037;
  --gem-primary: #1E3A5F;
  
  /* Text Colors */
  --text-primary: #1F1F1F;
  --text-secondary: #5D4037;
  --text-tertiary: #9CA3AF;
  
  /* Shadows */
  --shadow-premium: 0 6px 16px rgba(0, 0, 0, 0.06);
  --shadow-hover: 0 4px 12px rgba(0, 0, 0, 0.08);
}
```

## Usage Examples

### Creating a Luxury Card
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFFFAF9F6),
        Color(0xFFD4AF37).withOpacity(0.08),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Color(0xFFD4AF37).withOpacity(0.3),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  ),
)
```

### Creating a Category Icon Container
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFD4AF37), Color(0xFFC19A00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Color(0xFFD4AF37).withOpacity(0.3),
        blurRadius: 8,
      ),
    ],
  ),
  child: Icon(
    Icons.diamond,
    size: 24,
    color: Color(0xFFFAF9F6),
  ),
)
```

---

**Color Palette Version**: 1.0
**Last Updated**: 2024
**Status**: Production Ready ✅
