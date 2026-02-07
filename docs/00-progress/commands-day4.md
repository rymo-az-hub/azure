# Commands Log (2026-02-07)

> 目的: Day4 で実行した主要コマンドの記録（再現性 / Evidence 用）

---

## Repo状態確認
```powershell
ls -R infra/kv
git status
git diff --stat
git diff --cached --stat
git diff --cached --name-status
git log --oneline -5
git status -sb
```

## baseline-v1 の module 参照確認
```powershell
Select-String -Path infra/kv/baseline-v1/main.bicep -Pattern 'module\s+' | ForEach-Object { $_.Line.Trim() }
```

## Docs系コミット
```powershell
git commit -m "docs(kv): update evidence and progress logs for baseline/rbac"
git push
```

## CRLF -> LF 正規化（PowerShell）
```powershell
# PowerShellだけでOK（CRLF -> LF）
(Get-Content -Raw infra/kv/README.md) -replace "`r`n", "`n" | Set-Content -NoNewline infra/kv/README.md
```

## infra/kv の staging（CRLFが残っているファイルがあると止まる）
```powershell
git add infra/kv/README.md
git add infra/kv
```

## Azure: what-if
```powershell
az deployment group what-if -g $rg -f $f -p @$p
```

### what-if 結果メモ（抜粋）
- Modify: Diagnostic settings / privateDnsZoneGroups（ノイズ含む）
- No change: KV本体、Role assignments、Private DNS Zone、VNet link、PE本体
- Ignore: VM/Disks/NIC/MI/LAW など
