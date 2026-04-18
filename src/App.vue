<template>
  <RouterView />
</template>

<script setup>
import { watch, onMounted } from 'vue'
import { useSchoolConfig } from './composables/useSchoolConfig'

const { config, fetchConfig } = useSchoolConfig()

// ─── Custom color scale generator ────────────────────────────────────────────
function hexToHsl(hex) {
  const r = parseInt(hex.slice(1,3), 16) / 255
  const g = parseInt(hex.slice(3,5), 16) / 255
  const b = parseInt(hex.slice(5,7), 16) / 255
  const max = Math.max(r,g,b), min = Math.min(r,g,b)
  const l = (max + min) / 2
  if (max === min) return [0, 0, l * 100]
  const d = max - min
  const s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
  let h = 0
  if (max === r) h = ((g - b) / d + (g < b ? 6 : 0)) / 6
  else if (max === g) h = ((b - r) / d + 2) / 6
  else h = ((r - g) / d + 4) / 6
  return [h * 360, s * 100, l * 100]
}

function hslToHex(h, s, l) {
  s /= 100; l /= 100
  const c = (1 - Math.abs(2*l - 1)) * s
  const x = c * (1 - Math.abs((h/60) % 2 - 1))
  const m = l - c/2
  let r=0, g=0, b=0
  if (h < 60)      { r=c; g=x; b=0 }
  else if (h < 120){ r=x; g=c; b=0 }
  else if (h < 180){ r=0; g=c; b=x }
  else if (h < 240){ r=0; g=x; b=c }
  else if (h < 300){ r=x; g=0; b=c }
  else             { r=c; g=0; b=x }
  const v = (n) => Math.min(255, Math.max(0, Math.round((n + m) * 255))).toString(16).padStart(2,'0')
  return `#${v(r)}${v(g)}${v(b)}`
}

// สร้าง scale จาก nav_color (treated as ~700 level)
function generateCustomScale(navHex) {
  const [h, s, l] = hexToHsl(navHex)
  const sat = Math.min(s * 1.1, 100)
  return {
    50:  hslToHex(h, Math.min(s * 0.15, 15), 97),
    100: hslToHex(h, Math.min(s * 0.25, 30), 94),
    200: hslToHex(h, Math.min(s * 0.45, 55), 87),
    300: hslToHex(h, Math.min(s * 0.65, 75), 77),
    400: hslToHex(h, Math.min(s * 0.85, 90), 65),
    500: hslToHex(h, sat, 54),
    600: hslToHex(h, sat, 44),
    700: navHex,
    800: hslToHex(h, sat, Math.max(l * 0.80, 3)),
    900: hslToHex(h, sat, Math.max(l * 0.65, 2)),
    950: hslToHex(h, sat, Math.max(l * 0.50, 1.5)),
  }
}

const CUSTOM_PROPS = ['50','100','200','300','400','500','600','700','800','900','950']

function clearCustomProps(html) {
  CUSTOM_PROPS.forEach(s => {
    html.style.removeProperty(`--color-blue-${s}`)
  })
  ;['600','800','900'].forEach(s => html.style.removeProperty(`--color-indigo-${s}`))
}

// ─── Apply theme ─────────────────────────────────────────────────────────────
function applyTheme(c) {
  if (!c) return
  const html = document.documentElement
  html.removeAttribute('data-theme')
  clearCustomProps(html)

  // ธีมไว้ทุกข์มีความสำคัญสูงสุด
  if (c.mourning_until) {
    const until = new Date(c.mourning_until)
    until.setHours(23, 59, 59)
    if (until >= new Date()) {
      html.setAttribute('data-theme', 'mono')
      return
    }
  }

  const theme = c.theme || 'blue'

  // Custom color: inject CSS variables directly
  if (theme === 'custom' && c.nav_color) {
    const scale = generateCustomScale(c.nav_color)
    CUSTOM_PROPS.forEach(stop => {
      html.style.setProperty(`--color-blue-${stop}`, scale[stop])
    })
    ;['600','800','900'].forEach(stop => {
      html.style.setProperty(`--color-indigo-${stop}`, scale[stop])
    })
    return
  }

  // Preset themes (ยกเว้น blue ซึ่งเป็นค่าเริ่มต้น)
  if (theme !== 'blue') {
    html.setAttribute('data-theme', theme)
  }
}

watch(config, applyTheme, { immediate: true })

onMounted(async () => {
  await fetchConfig()
})
</script>
