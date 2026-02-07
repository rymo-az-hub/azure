# Commands used on Day 4 (summary) / Day4繧ｳ繝槭Φ繝我ｸ隕ｧ・・026-02-07・・
PowerShell 蜑肴署縲ゆｸｻ縺ｫ Git 縺ｫ繧医ｋ繝ｪ繝昴ず繝医Μ謨ｴ逅・ｼ亥ｷｮ蛻・ヮ繧､繧ｺ謗帝勁繝ｻ蜻ｽ蜷咲ｵｱ荳繝ｻ豁｣譛ｬ荳譛ｬ蛹厄ｼ峨・
---

## 迥ｶ諷狗｢ｺ隱・/ Working tree 縺ｮ謚頑升

git status
git diff

---

## ZIP荳頑嶌縺榊ｾ後・蟾ｮ蛻・ヮ繧､繧ｺ蟇ｾ遲厄ｼ亥ｿ・ｦ∝・縺縺・stage 竊・restore・・
# 萓具ｼ壼ｿ・ｦ√↑螟画峩縺縺・add
git add README.md
git add infra/kv/pe-v1/main.bicep
git add infra/kv/_legacy/

# 縺昴ｌ莉･螟悶・蟾ｮ蛻・ｒ遐ｴ譽・ｼ・tage貂医∩縺ｯ菫晄戟・・git restore .
git status

---

## IaC 豁｣譛ｬ縺ｮ邨ｱ荳・・nfra/kv 繧・canonical 縺ｫ・・
# 蟄伜惠遒ｺ隱・Test-Path .\infra\keyvault

# 譌ｧ繝・ぅ繝ｬ繧ｯ繝医Μ蜑企勁・・it邂｡逅・ｸ具ｼ・git rm -r infra/keyvault

# commit / push・井ｾ具ｼ・git commit -m "Make infra/kv canonical, archive legacy keyvault, and align KV diagnostics"
git push

---

## Evidence 縺ｮ驥崎､・炎髯､・・EADME.txt 繧貞炎髯､・・
git rm docs/evidence/README.txt
git commit -m "Remove duplicate evidence README.txt"
git push

---

## ADR 蜻ｽ蜷咲ｵｱ荳・・dr- 竊・ADR-・・
git mv docs/04-adr/adr-0001-iac-tooling.md docs/04-adr/ADR-0001-iac-tooling.md
git mv docs/04-adr/adr-0002-management-group-hierarchy.md docs/04-adr/ADR-0002-management-group-hierarchy.md

git status
git commit -m "Clean up ADR naming (ADR- prefix)"
git push

---

## Docs蟆守ｷ・+ ADR繝ｫ繝ｼ繝ｫ + .editorconfig・亥・逋ｺ髦ｲ豁｢・・
git add README.md docs/04-adr/ADR-0000-template.md .editorconfig
git commit -m "Add docs links, ADR status/numbering rules, and .editorconfig"
git push
