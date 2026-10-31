# WezTerm Pixel Pencil — v10 (chezmoi)

## 構成

- **PowerShell 5.1 / 7**: `startup.ps1` -> `powershell.ps1`。入力中はカラフルなA型シェブロン、Enter後は各階層を保持した**輪郭版**（`│PS5││~│...`）に変わります。空Enterにも適用します。
- **実行中**: 通常の `ls`、`git status`、`Start-Sleep` をそのまま実行。シェルが `OSC 1337` の `WEZ_RUN` に `running` / `idle` を通知し、WezTermが**上部タブ内だけ**点字スピナーを表示（緑～黄色）。コマンド出力に描画しません。
- **Git Bash**: `source "$HOME/.config/wezterm/prompts/gitbash.sh"` を `~/.bashrc` の末尾に追加。Bash 4.4+ の `PS0` と `PROMPT_COMMAND` でタブスピナーに対応。従来のカラフルなA型プロンプトは維持します。**Git Bashの実行済み輪郭化は未対応**（Readlineの過去の行の安全な再描画に制約があるため）。
- `WEZTERM_USE_STARSHIP=1` にした場合、StarshipがPowerShellプロンプトを置き換えるため、輪郭化・Enter連携は無効です。
- 常時アニメーション・右側RUNNING・Start-Jobによる専用ラッパーは**削除**しました。

## 診断コマンド

PowerShell（WezTermの新規タブで試す）：

```powershell
Get-WezAnimationDiagnostic | Format-List
Test-WezTabSpinner -Seconds 7
Start-Sleep -Seconds 7
```

- `EnterHookStatus = installed` であれば、通常のEnterからも通知されます。
- `Test-WezTabSpinner` が動くのに `Start-Sleep` で動かないなら、PSReadLineのEnterフックを確認してください。
- **空Enter**: 入力待ちの塗りつぶしが、同じ階層の輪郭型に切り替わります。空Enterではスピナーは出しません。
- 輪郭部分が `????` になるなら `Set-WezTransientStyle ASCII` で切り替えられます。UTF-8対応フォントとConsoleの出力エンコーディングも確認してください。
- ターミナル幅を超えるコマンドや複数行コマンドでは、PSReadLineの描画を壊さないよう輪郭化をスキップします（スピナーの通知は行単位で試みます）。
- F1: ヘルプ / F3: シェル起動メニュー。

## 注意

PSReadLineの既存Enterキーバインドがカスタムの場合は**勝手に上書きせず**、フックをスキップします。この場合、手動テストは可能でも通常のコマンドの自動タブ表示は動作しません。

Windows上の実機テストはこの作業環境では実施できません。WezTermを完全終了してから新しいタブを起動してください。
