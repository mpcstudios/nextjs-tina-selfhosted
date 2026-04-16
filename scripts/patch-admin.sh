#!/bin/bash
# Patches the TinaCMS admin panel with MPC Studios branding.
# Run automatically after `tinacms build` via the build script.

ADMIN_HTML="public/admin/index.html"
FAVICON="public/admin/assets/favicon-eb31bc17.svg"
BRANDING_SNIPPET="scripts/admin-branding.html"

if [ ! -f "$ADMIN_HTML" ]; then
  echo "⚠ $ADMIN_HTML not found — skipping admin patch"
  exit 0
fi

# 1. Replace page title
sed -i 's|<title>TinaCMS</title>|<title>MPC Studios CMS</title>|' "$ADMIN_HTML"

# 2. Replace favicon SVG with MPC cube icon
cat > "$FAVICON" << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 85.37 90.11"><defs><linearGradient id="linear-gradient" x1="-1752.18" y1="644.63" x2="-1751.38" y2="645.11" gradientTransform="matrix(72, 0, 0, -76, 126167, 49055.56)" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#fe6e64"/><stop offset=".33" stop-color="#fc8446"/><stop offset=".65" stop-color="#f7951d"/><stop offset="1" stop-color="#ffc14f"/></linearGradient></defs><path d="M15.41,33.2l33.2,19.5V90.11L15.41,70.56Zm70-17.79V51.58L52.17,71.14V33.79l0,0ZM33.71,0,67.58,20.2,33.87,39.13,0,18.93Z" fill-rule="evenodd" fill="url(#linear-gradient)"/></svg>
SVGEOF

# 3. Inject logo swap script before </body> using the snippet file
if [ -f "$BRANDING_SNIPPET" ] && ! grep -q "mpc-g" "$ADMIN_HTML"; then
  sed -i "/<\/body>/e cat $BRANDING_SNIPPET" "$ADMIN_HTML"
  echo "✓ Admin panel patched with MPC Studios branding"
else
  echo "✓ Admin branding already applied or snippet missing"
fi
