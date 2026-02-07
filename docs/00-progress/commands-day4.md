# Commands Log (2026-02-07)

> 逶ｮ逧・ Day4 縺ｧ螳溯｡後＠縺滉ｸｻ隕√さ繝槭Φ繝峨・險倬鹸・亥・迴ｾ諤ｧ / Evidence 逕ｨ・・
---

## Repo迥ｶ諷狗｢ｺ隱・```powershell
ls -R infra/kv
git status
git diff --stat
git diff --cached --stat
git diff --cached --name-status
git log --oneline -5
git status -sb
```

## baseline-v1 縺ｮ module 蜿ら・遒ｺ隱・```powershell
Select-String -Path infra/kv/baseline-v1/main.bicep -Pattern 'module\s+' | ForEach-Object { $_.Line.Trim() }
```

## Docs邉ｻ繧ｳ繝溘ャ繝・```powershell
git commit -m "docs(kv): update evidence and progress logs for baseline/rbac"
git push
```

## CRLF -> LF 豁｣隕丞喧・・owerShell・・```powershell
# PowerShell縺縺代〒OK・・RLF -> LF・・(Get-Content -Raw infra/kv/README.md) -replace "`r`n", "`n" | Set-Content -NoNewline infra/kv/README.md
```

## infra/kv 縺ｮ staging・・RLF縺梧ｮ九▲縺ｦ縺・ｋ繝輔ぃ繧､繝ｫ縺後≠繧九→豁｢縺ｾ繧具ｼ・```powershell
git add infra/kv/README.md
git add infra/kv
```

## Azure: what-if
```powershell
az deployment group what-if -g $rg -f $f -p @$p
```

### what-if 邨先棡繝｡繝｢・域栢邊具ｼ・- Modify: Diagnostic settings / privateDnsZoneGroups・医ヮ繧､繧ｺ蜷ｫ繧・・- No change: KV譛ｬ菴薙ヽole assignments縲￣rivate DNS Zone縲〃Net link縲￣E譛ｬ菴・- Ignore: VM/Disks/NIC/MI/LAW 縺ｪ縺ｩ
