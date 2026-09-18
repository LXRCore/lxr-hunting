/* LXR-HUNTING — the skinning card | © 2026 iBoss21 / LXRCore */
(function () {
  const $ = (id) => document.getElementById(id);
  const card = $('card');
  let L = {}, timer = null;
  const t = (k, vars) => { let s = L[k] || k.split('.').pop().replace(/_/g, ' '); if (vars) for (const v in vars) s = s.replace('%{' + v + '}', vars[v]); return s; };
  function applyLocale() { document.querySelectorAll('[data-l]').forEach(el => { const k = 'ui.' + el.dataset.l; if (L[k]) el.textContent = L[k]; }); }
  const grades = { 1: 'poor', 2: 'good', 3: 'perfect' };
  window.addEventListener('message', e => {
    const m = e.data || {};
    if (m.brand && m.brand.theme) document.documentElement.dataset.theme = m.brand.theme;
    if (m.locale) { L = m.locale; applyLocale(); }
    if (m.lang) document.body.classList.toggle('lang-ka', m.lang === 'ka');
    if (m.action === 'show') {
      const p = m.payload || {};
      $('animal').textContent = p.label || '';
      $('grade').textContent = t('grade.' + (grades[p.grade] || 'poor'));
      const rows = $('rows'); rows.innerHTML = '';
      (p.got || []).forEach((g, i) => {
        const row = document.createElement('div'); row.className = 'lxr-row';
        const idx = document.createElement('span'); idx.className = 'lxr-row-index'; idx.textContent = String(i + 1).padStart(2, '0');
        const name = document.createElement('span'); name.className = 'lxr-row-name'; name.textContent = g.label;
        const sub = document.createElement('span'); sub.className = 'lxr-row-sub lxr-mono'; sub.textContent = '×' + g.amount + (g.quality ? ' · ' + t('grade.' + grades[g.quality]) : '');
        row.append(idx, name, sub); rows.appendChild(row);
      });
      card.classList.remove('lxr-hidden');
      clearTimeout(timer); timer = setTimeout(() => card.classList.add('lxr-hidden'), 6000);
    }
    if (m.action === 'hide') card.classList.add('lxr-hidden');
  });
  if (window.__LXR_MOCK__) window.postMessage(window.__LXR_MOCK__, '*');
})();
