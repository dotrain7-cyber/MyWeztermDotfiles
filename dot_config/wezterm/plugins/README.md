# 実際に存在するWezTermの外部プラグイン（今回は自動導入しません）

WezTerm Luaの `wezterm.plugin.require('https://github.com/...')` は初回にネットワークを使ってクローンするため、
今回の設定は**標準機能で確実に見た目を変更する**ことを優先し、外部プラグインへの依存はありません。
使いたいものは公式READMEの構成に沿って追加してください。

- tabline.wez（装飾されたタブバー）: https://github.com/michaelbrusegard/tabline.wez
- bar.wezterm（ステータス・タブバー）: https://github.com/adriankarlen/bar.wezterm
- resurrect.wezterm（タブ・ペインの復元）: https://github.com/MLFlexer/resurrect.wezterm
- modal.wezterm（Vim風キー操作）: https://github.com/MLFlexer/modal.wezterm
- awesome-wezterm（実在する拡張の索引）: https://github.com/michaelbrusegard/awesome-wezterm

今回のステータスバーは `ui/styling.lua` に自作しているため、tablineやbarを同時に入れるなら
登録イベントと描画対象が重複しないよう、標準描画の方を無効にしてください。
