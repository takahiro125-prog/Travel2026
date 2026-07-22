---
name: travel-map-update
description: "Travel2026旅行地図の作成、再生成、更新、Google Driveへの配置、GitHub公開に使う。「旅行地図を作成して」「旅程地図を更新して」では最新版のDriveプロトコルとSheetsから完全更新する。「アップロードだけ」「公開だけ」「後半だけ」「Driveの生成済みHTMLをGitHubへ反映して」では再生成や詳細検証を省略する軽量公開モードを使う。Remote経由の短い指示も含む。"
---

# Travel2026旅行地図

## 固定対象

- リポジトリ: `https://github.com/takahiro125-prog/Travel2026`
- ブランチ: `main`
- Driveプロトコルフォルダ: `https://drive.google.com/drive/folders/1XdyXOVDOaXGHo20x8DTsNEs0CWJFdtSD`
- Google Sheets: `https://docs.google.com/spreadsheets/d/1ecSx5D36tAQcqp3wvGjBQIxAA3_gYdFdikZihq2kKTs/edit`
- 生成済み成果物フォルダ: `https://drive.google.com/drive/folders/1-_5bM7DARLeOI9BX83b-NGbYIbxZ5fWh`
- 公開目次: `https://takahiro125-prog.github.io/Travel2026/day1_day11_maps_index.html`

最初にリポジトリルートの `AGENTS.md` を読む。対象リポジトリを確認できなければ停止する。DriveとSheetsは読み取り専用として扱う。

## モードを選ぶ

### 完全更新モード

「作成して」「再生成して」「最新の旅程表から更新して」など、生成を求める依頼に使う。

1. cleanな `main` と正しいremoteを確認し、`origin/main` を取得する。
2. その実行中にプロトコルフォルダを一覧取得し、最新版のMarkdownと独立Pythonを `.codex-map-work/protocol/` へ取得する。
3. その実行中に最新XLSXを `.codex-map-work/input/` へ取得する。
4. 独立Pythonを正本として、Markdown内コードとの実質一致と構文を確認する。不一致なら停止する。
5. 最新プロトコルのコマンドで `.codex-map-work/generated/` へ生成する。
6. 最新プロトコルに明記された生成上の必須確認を行う。
7. 生成した公開対象だけをDriveとGitHubへ反映し、通常pushする。

過去の入力、Drive一覧、connector file referenceを正本として再利用しない。生成エラーや必須成果物の欠落があればcommit、pushしない。

### 軽量公開モード

「アップロードだけ」「公開だけ」「後半だけ」「すでにDriveにあるHTMLをGitHubへ反映して」など、生成済み成果物の公開だけを明示した依頼に使う。

ローカルGoogle Driveが `G:\マイドライブ\private\Trip2026\website` にマウントされている場合は、手作業のコピーやconnector取得より先に `scripts/publish_from_local_gdrive.ps1` を使う。このスクリプトは対象14ファイルだけをコピーし、明示的にstage、commit、通常pushする。ZIP名に ` (1)` などが付いていても、最新の候補を正規名で公開する。

1. ローカル同期フォルダが利用可能なら、リポジトリルートから次を実行する。

   ```powershell
   powershell -ExecutionPolicy Bypass -File .agents\skills\travel-map-update\scripts\publish_from_local_gdrive.ps1
   ```

2. ローカル同期フォルダが利用できない場合だけ、固定の生成済み成果物フォルダを一覧取得し、公開対象を `.codex-map-work/publish/` へ取得する。
3. 取得した公開対象だけをリポジトリへ反映し、明示的にstage、commit、通常pushする。
4. push結果を報告する。公開ページの読み戻しは行わない。

軽量公開モードでは次を行わない。

- Google Sheets、プロトコル、独立Pythonの取得
- 地図の再生成
- SHA-256の記録または照合
- MarkdownとPythonの照合
- ZIPの展開または内部検査
- HTMLの意味、リンク、ピン、色、件数の検査
- Day 1〜11の個別HTTP確認
- Driveへの再アップロードまたは全件読み戻し
- GitHub上のcommitやPagesの再読み戻し

ファイル取得、commit、pushなど公開操作自体の失敗は報告する。内容検証を省略したことは失敗扱いにしない。

## 公開対象

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

`generation_manifest.json` はGitへ追加しない。`index.html`、旅行地図以外のファイル、Pages設定、workflow、ディレクトリ構造を変更しない。

## GitHub公開

- 公開対象だけをファイル名指定でstageし、`git add -A` を使わない。
- force pushを使わない。
- `origin/main` が進んで安全に統合できなければ、topic branchへpushしてPRを作る。自動mergeしない。
- `index.html` をstageしない。

## 報告

完全更新モードでは、使用した入力、生成結果、Drive反映、commit、公開結果を簡潔に報告する。

軽量公開モードでは、Driveから取得したファイル、commit SHA、push先だけを簡潔に報告し、詳細検証は省略したと一言添える。
