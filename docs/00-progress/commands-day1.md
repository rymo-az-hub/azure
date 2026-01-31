\# Commands used on Day 1 (summary) / Day1コマンド一覧



This is a quick reference of the commands used during Day 1 work.

PowerShell is assumed. Azure CLI commands start with `az`.



Day1で使用したコマンドの早見表です。

PowerShell前提。Azure CLIは `az` で始まります。



---



\## Git / GitHub (local -> remote) / ローカル作業〜GitHub反映



git clone <repo\_url>

&nbsp;   EN: Clone the GitHub repository to local.

&nbsp;   JP: GitHubのリポジトリをローカルへ複製する。



cd <repo\_dir>

pwd

&nbsp;   EN: Move to repo directory / show current path.

&nbsp;   JP: リポジトリへ移動／現在のパスを確認する。



mkdir <path>

dir <path>

&nbsp;   EN: Create folders (docs/infra) / list directory contents.

&nbsp;   JP: フォルダ作成（docs/infraなど）／ディレクトリ内容を表示する。



git status

&nbsp;   EN: Show working tree status.

&nbsp;   JP: 変更状況（未追跡/差分/ステージ状況）を確認する。



git add .

git add <file>

&nbsp;   EN: Stage changes.

&nbsp;   JP: 変更をステージング（コミット対象に追加）する。



git commit -m "<message>"

&nbsp;   EN: Commit staged changes.

&nbsp;   JP: ステージ済み変更をコミットとして確定する。



git push

&nbsp;   EN: Push commits to GitHub (origin).

&nbsp;   JP: ローカルコミットをGitHub（origin）へ反映する。



git show --stat

&nbsp;   EN: Show last commit summary (files changed / insertions / deletions).

&nbsp;   JP: 直近コミットの変更概要（対象ファイル/追加/削除行数）を確認する。



git log --oneline -n 5

&nbsp;   EN: Show last 5 commits.

&nbsp;   JP: 直近5件のコミット履歴を短く表示する。



---



\## Azure CLI authentication / context / Azure認証・コンテキスト



az login

&nbsp;   EN: Authenticate Azure CLI via browser.

&nbsp;   JP: Azure CLIにログインする（ブラウザ認証）。



az account show

&nbsp;   EN: Show current subscription and tenant context (optional but recommended).

&nbsp;   JP: 現在のサブスクリプション/テナントを確認する（推奨）。



az account set --subscription <subscriptionId>

&nbsp;   EN: Set the target subscription (optional, when multiple subscriptions exist).

&nbsp;   JP: 操作対象サブスクリプションを固定する（複数ある場合に使用）。



---



\## Azure Policy: find built-in definition IDs / parameters

\## Azure Policy：定義ID取得・パラメータ確認



az policy definition list --query "<JMESPath>" -o tsv

&nbsp;   EN: Find built-in policy definition id by displayName and output as a single string (tsv).

&nbsp;       Used for: Allowed locations / Require a tag on resources / Require a tag on resource groups

&nbsp;   JP: built-inポリシー定義をdisplayName等で検索し、IDをtsvで取得する（変数代入しやすい）。

&nbsp;       用途: Allowed locations / Require a tag on resources / Require a tag on resource groups のID取得



az policy definition show --name <GUID> --query "parameters" -o jsonc

&nbsp;   EN: Show policy definition parameters (ex: listOfAllowedLocations, tagName).

&nbsp;   JP: ポリシー定義のパラメータ（例: listOfAllowedLocations, tagName）を確認する。



---



\## Deploy Bicep at subscription scope / サブスクリプションスコープでBicepデプロイ



az deployment sub what-if --name <deploymentName> --location <location> --template-file <bicep> --parameters ...

&nbsp;   EN: Preview changes before deployment (required step for safe change).

&nbsp;   JP: デプロイ前に差分確認（何が作成/変更されるか）。安全な変更のために必須。



az deployment sub create --name <deploymentName> --location <location> --template-file <bicep> --parameters ...

&nbsp;   EN: Deploy Bicep at subscription scope (create/update policy assignments).

&nbsp;   JP: サブスクリプションスコープでBicepをデプロイ（Policy Assignment作成/更新）。



az deployment sub list --query "\[].{name:name, state:properties.provisioningState, time:properties.timestamp}" -o table

&nbsp;   EN: List subscription-scope deployments and their states.

&nbsp;   JP: サブスクリプションデプロイの履歴と状態（Succeeded/Failed等）を一覧表示。



az deployment sub show --name <deploymentName> --query "{state:properties.provisioningState, time:properties.timestamp, outputs:properties.outputs, error:properties.error}" -o jsonc

&nbsp;   EN: Show a deployment result (state / error / outputs).

&nbsp;   JP: 特定デプロイの結果（state/error/outputs）を確認する。



az deployment operation sub list --name <deploymentName> --query "\[].{op:operationId, state:properties.provisioningState, type:properties.targetResource.resourceType, name:properties.targetResource.resourceName}" -o table

&nbsp;   EN: Inspect operations inside a deployment (what resources were targeted).

&nbsp;   JP: デプロイ内の操作単位を確認（どのリソース種別/名前に対して処理したか）。



---



\## Verify policy assignments exist / Policy Assignmentの作成確認



az policy assignment list --query "\[?starts\_with(name,'pa-')].{name:name, displayName:displayName, scope:scope}" -o table

&nbsp;   EN: List policy assignments created by the baseline (pa-\*).

&nbsp;   JP: ベースラインで作成した `pa-` の割当一覧を表示し、作成済みか確認する。



---



\## Evidence (policy enforcement / deny proof) / 証跡（Denyが効いている確認）



az network vnet create -g <rg> -n <vnet> -l japaneast --address-prefixes 10.10.0.0/16

&nbsp;   EN: Try creating a VNet without required tags to trigger Deny (RequestDisallowedByPolicy).

&nbsp;   JP: 必須タグ無しでVNet作成を試み、Deny（RequestDisallowedByPolicy）を発生させる。



az group create -n <rg> -l japaneast

&nbsp;   EN: Try creating a Resource Group without required tags to trigger Deny.

&nbsp;   JP: 必須タグ無しでRG作成を試み、Denyを発生させる。



az group create -n <rg> -l japaneast --tags Owner=<value> CostCenter=<value> Environment=<value>

&nbsp;   EN: Create a Resource Group with required tags (expected to succeed).

&nbsp;   JP: 必須タグ付きでRGを作成し、許可（Succeeded）を確認する。



---



\## Cleanup / ensure no leftover billable resources

\## 後片付け（課金リソースが残っていない確認〜削除）



az group list -o table

&nbsp;   EN: List resource groups.

&nbsp;   JP: リソースグループ一覧を表示する。



az group list --query "\[?contains(name,'policy') || contains(name,'avd')].{name:name, location:location}" -o table

&nbsp;   EN: List RGs filtered by naming patterns (quick triage).

&nbsp;   JP: 名前パターンでRGを絞り込み表示（素早い棚卸し用）。



az resource list -g <rg> --query "\[].{type:type, name:name}" -o table

&nbsp;   EN: List resources in an RG (check for billable leftovers).

&nbsp;   JP: RG配下のリソース一覧を表示（課金対象が残っていないか確認）。



az network vnet list -o table

&nbsp;   EN: List VNets (confirm deny-created VNets do not exist).

&nbsp;   JP: VNet一覧を表示（Denyで作れなかったVNetが存在しないことを確認）。



az group delete -n <rg> --yes --no-wait

&nbsp;   EN: Delete an RG (and all resources inside).

&nbsp;   JP: RGを削除（配下リソースもまとめて削除）。



---



\## Local file checks (Markdown troubleshooting) / ローカルファイル確認（Markdown崩れ対策）



Get-Content <file> | Select-Object -Last 120

&nbsp;   EN: Show last lines of a file to confirm content and detect formatting issues.

&nbsp;   JP: ファイル末尾を表示して内容確認（Markdownの崩れ/切れの検知に使う）。



