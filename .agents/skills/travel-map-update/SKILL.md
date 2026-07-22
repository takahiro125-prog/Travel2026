---
name: travel-map-update
description: "「旅行地図を作成して」「旅行地図を更新して」「旅程地図を作成して」「旅程地図を更新して」「最新の旅程表から地図を作って」「Travel2026の地図を更新して」「HTML地図を再生成して」「最新の旅行地図をGitHubへ反映して」と依頼されたときに使う。Remote経由の短い指示も含む。takahiro125-prog/Travel2026専用の、Google DriveとGoogle Sheetsの最新版を取得して旅行地図を再生成・検証し、安全にGitHubへ公開するスキル。"
---

# Travel2026旅行地図更新

## 適用境界

- このスキルを `takahiro125-prog/Travel2026` の旅行地図再生成・更新・GitHub公開だけに使う。
- Remote経由を含む短い依頼でも、以下の取得、照合、隔離生成、検証、公開確認を省略しない。
- 現在のプロジェクトまたはGit remoteから対象リポジトリを確認できない場合は、別のリポジトリを推測せず停止する。
- Remoteホストがオフライン、必要なconnectorが未認証、または承認が必要で継続できない場合は、公開成功と扱わず必要な操作を報告する。
- スキルの作成、編集、インストール、構造検証、説明だけを求められた場合は、地図更新を実行しない。
- リポジトリルートの `AGENTS.md` を最初に最後まで読み、本スキルと併せて守る。
- `AGENTS.md`、本スキル、最新版Driveプロトコルが矛盾する場合は推測で進めず、矛盾を報告して停止する。
- Google Driveの正本ファイルとGoogle Sheetsは読み取り専用として扱い、編集、上書き、移動、削除しない。

## 固定の正本

- GitHubリポジトリ: `https://github.com/takahiro125-prog/Travel2026`
- 既定ブランチ: `main`
- Driveプロトコルフォルダ: `https://drive.google.com/drive/folders/1XdyXOVDOaXGHo20x8DTsNEs0CWJFdtSD`
- Google Sheets: `https://docs.google.com/spreadsheets/d/1ecSx5D36tAQcqp3wvGjBQIxAA3_gYdFdikZihq2kKTs/edit`
- 公開目次: `https://takahiro125-prog.github.io/Travel2026/day1_day11_maps_index.html`

毎回、その実行中にDriveフォルダを新しく一覧取得し、次を取得する。

- `2026_summer_roadtrip_htmlmap_rebuild_protocol.md`
- `generate_2026_roadtrip_html_maps.py`

毎回、その実行中にGoogle Sheets全体を最新XLSXとして取得し、次のシートを確認する。

- `Plan_旅程DB`
- `Spot_Candidates_スポット候補`
- `Supplies_Food_Gas_沿線`

以前取得したプロトコル、Python、XLSX、Drive一覧、connector file reference、生成物を正本として再利用しない。いずれかを新規取得できない場合は代替物を作らず停止する。

## 保護対象と許可対象

`index.html` はダミーページである。変更、削除、再生成、旅行地図へのリンク追加、目次への置換を絶対に行わない。開始時にSHA-256を記録し、commit直前と公開確認時に同じであることを確認する。

GitHubで置換を許可する公開成果物は次だけとする。

```text
all_days_hotels_spots_overall_map.html
day1_day11_maps_index.html
day1_hotels_spots_only_map.html
day2_hotels_spots_only_map.html
day3_hotels_spots_only_map.html
day4_hotels_spots_only_map.html
day5_hotels_spots_only_map.html
day6_hotels_spots_only_map.html
day7_hotels_spots_only_map.html
day8_hotels_spots_only_map.html
day9_hotels_spots_only_map.html
day10_hotels_spots_only_map.html
day11_hotels_spots_only_map.html
2026_summer_roadtrip_maps_latest_rebuilt.zip
```

`generation_manifest.json` は検証用一時成果物であり、最新版プロトコルが明示的に公開対象へ変更しない限りGitへ追加しない。旅行地図以外の既存ファイル、GitHub Pages設定、workflow、ディレクトリ構造を変更しない。

## 1. リポジトリを準備する

1. `git remote -v`、`git status --short --branch`、`git branch --show-current`、`git log -1 --oneline` を確認する。
2. remoteが `takahiro125-prog/Travel2026` でなければ停止する。
3. 未commit変更があれば、ユーザーの変更として保持し、作業対象を安全に分離できない限り停止する。
4. `git fetch origin --prune` を実行し、cleanな `main` に切り替えて `origin/main` へfast-forwardする。force reset、force push、未確認変更の破棄を行わない。
5. ルート直下、公開HTML、ZIP、`.github/workflows/`、生成スクリプト、設定ファイルを読み取り専用で確認する。
6. `index.html` と既存の公開HTML・ZIPのSHA-256またはGit状態を記録する。

最新clean `main` を用意できなければ、生成や書き込みを始めず停止する。

## 2. 最新入力を取得する

Git管理外の次の一時領域だけを使う。

```text
.codex-map-work/protocol/
.codex-map-work/input/
.codex-map-work/generated/
```

1. Driveプロトコルフォルダの直下をその場で一覧取得し、指定Markdownと独立PythonをID、名前、更新時刻、サイズとともに確認する。
2. 2ファイルを `.codex-map-work/protocol/` へ取得する。通常のテキスト取得でPython本文を得られない場合はrawファイルとして取得する。
3. Google Sheets全体をXLSXでエクスポートし、`.codex-map-work/input/Travel-plan-2026-summer.xlsx` へ保存する。CSV結合などの独自代替処理を行わない。
4. XLSX内の必須3シートを実名で確認する。
5. 取得した各入力のサイズとSHA-256を記録する。

## 3. 正本コードを照合する

1. 独立した `.codex-map-work/protocol/generate_2026_roadtrip_html_maps.py` を実行コードの正本とする。
2. Markdown内のPythonコードブロックを抽出し、改行コードや末尾空白など意味を変えない差を正規化して独立Pythonと比較する。
3. 実質的な不一致があれば、統合、修正、古いコピーへの差し替え、HTML生成を行わず停止する。
4. 独立Pythonへ構文検査を行い、`--help` と最新版プロトコルから実際の引数を確認する。
5. 最新プロトコルに依存バージョン指定があれば優先する。なければリポジトリの `requirements.txt` を使い、隔離した `.venv/` へ依存関係を導入して `pip check` を実行する。
6. プロトコルやPythonを実行が通るように勝手に変更しない。

## 4. 隔離生成する

1. 最新版プロトコルに記載されたコマンドと引数を使い、`.codex-map-work/generated/` へ生成する。
2. リポジトリルートの公開HTMLやZIPへ直接出力しない。
3. 生成中にGoogle Drive、Google Sheets、GitHub上の公開物を書き換えない。
4. 生成エラー、警告による欠落、入力スキーマ不一致があれば停止する。

## 5. 全検証を行う

最新版Markdownプロトコルに記載された検証をすべて実行し、加えて次を確認する。

- Overall、目次、Day 1〜Day 11の計13 HTMLが存在し、すべて空でない。
- `2026_summer_roadtrip_maps_latest_rebuilt.zip` が存在し、空でない。
- `generation_manifest.json` が存在し、列挙されたHTMLと実ファイルが一致する。
- ZIP内に同じ生成回の必須13 HTMLが含まれ、余分な `index.html` がない。
- 目次内の相対HTMLリンク先がすべて存在する。
- OverallとDay地図にLeaflet地図要素がある。
- 必要なHTMLにApple MapsリンクとGoogle画像検索リンクがある。
- 除外カテゴリ、複数日データ、ID、色、ファイル名、リンク構造が最新版プロトコルどおりである。
- 可能なら一時ローカルHTTPサーバーで目次と代表的な地図を読み、HTTP 200と読み込みエラーがないことを確認してサーバーを停止する。
- 生成対象とZIPに `index.html` が含まれない。
- リポジトリ上の `index.html` と既存公開HTML・ZIPがまだ無変更である。

1項目でも失敗または未確認なら、公開成果物を置換せず、commitもpushも行わない。

## 6. 検証済み成果物だけを反映する

1. 全検証合格後に限り、一時生成物から許可対象14ファイルだけをリポジトリルートの同名ファイルへ置換する。
2. `index.html`、旅行地図以外のファイル、Google Drive、Google Sheets、Pages設定を変更しない。
3. `git status --short`、`git diff --stat`、`git diff --name-only`、必要な内容差分を確認する。
4. Git差分の全パスが許可対象リスト内であることを機械的に照合する。
5. `index.html` のSHA-256が開始時と一致し、`git diff -- index.html` が空であることを確認する。
6. 変更された公開HTMLが空でなく、ZIPと同じ生成回であることを再確認する。

許可対象外の差分があれば、自動で破棄または修正せず、commitせずに停止して報告する。

## 7. GitHubへ公開する

1. GitHub認証を確認する。
2. 意図した許可対象ファイルだけを明示的にstageする。`git add -A` を使わない。
3. 検証結果を再確認してから、旅行地図更新を説明する簡潔なcommitを作成する。
4. `origin/main` が作業開始後に進んでいないかfetchして確認する。進んでいた場合はforce pushせず、安全に統合できなければtopic branchとPRへ切り替える。
5. 検証済みcommitを `main` へ通常pushする。`--force`、`--force-with-lease` を使わない。
6. branch protectionまたは権限で直接pushが拒否された場合は、同じ検証済みcommitから `codex/travel-map-update-<date>` のようなtopic branchを作り、pushして `main` 向けPull Requestを作成する。
7. PR経由の場合は自動mergeせず、変更ファイル、入力取得時刻、検証結果、`index.html` 無変更、未解決事項を本文へ記載する。
8. 検証失敗後のcommitやpush、`main`へのforce push、保護回避を行わない。

## 8. リモートと公開ページを読み戻す

1. `git ls-remote`、GitHub API、または `gh` でリモートブランチとcommit SHAを読み戻し、意図したcommitと一致することを確認する。
2. GitHub上の変更ファイル一覧が許可対象だけであることを確認する。
3. 直接pushなら `main`、PRならhead branch、PR URL、状態、checksを確認する。
4. GitHub Pages反映後、公開目次へcommit SHA等のcache-busting queryを付けて取得し、HTTP 200、OverallとDay 1〜11へのリンク、代表的な最新内容を確認する。
5. 公開された `index.html` が保護されたダミーページのままで、旅行地図へのリンクが追加されていないことを確認する。
6. Pages反映待ちやPR未mergeなら成功と断定せず、現在の状態と必要な次操作を報告する。

## 9. 完了報告する

次を簡潔に報告する。

1. 使用したDrive正本ファイルの名前、ID、更新時刻、SHA-256
2. XLSXの取得結果、必須シート、SHA-256
3. Python照合、構文、依存関係、生成、全検証の結果
4. 生成したHTML、ZIP、manifest
5. Gitで変更したファイル
6. `index.html` と非対象公開ファイルが無変更であること
7. commit SHA、push先ブランチ、直接pushまたはPRの別
8. PR URLと状態（該当する場合）
9. GitHub Pagesの公開確認結果
10. 未解決事項または未確認事項

失敗時は、どの安全条件で停止したか、公開操作を行っていないこと、ユーザーに必要な操作を明示する。
