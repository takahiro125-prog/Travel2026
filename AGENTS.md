# Codex repository instructions

## Travel2026旅行地図

正本のGoogle Driveプロトコルフォルダは `https://drive.google.com/drive/folders/1XdyXOVDOaXGHo20x8DTsNEs0CWJFdtSD`、Google Sheetsは `https://docs.google.com/spreadsheets/d/1ecSx5D36tAQcqp3wvGjBQIxAA3_gYdFdikZihq2kKTs/edit` とする。

Travel2026旅行地図の作業では、毎回Google Drive上の指定プロトコルフォルダを一覧取得し、最新版のMarkdownと独立Pythonを取得する。

Google Sheetsは毎回、指定URLから最新XLSXを取得する。以前取得したXLSX、プロトコル、Python、Drive一覧を正本として再利用しない。

地図の生成、検証、GitHubへの反映は、Driveから取得した最新版Markdownプロトコルに厳密に従う。

独立した `generate_2026_roadtrip_html_maps.py` を実行コードの正本とする。Markdown内コードと実質的に不一致の場合は作業を停止する。

`index.html` はダミーページであり、変更、削除、旅行地図へのリンク追加、目次ページへの置換を禁止する。

検証に失敗した場合はcommitまたはpushを行わない。

旅行地図以外の既存ファイルを変更または削除しない。

作業開始時に `index.html` のSHA-256を記録し、完了前に同じ値であることを確認する。Google Drive上の正本ファイルとGoogle Sheetsは読み取り専用として扱い、編集、上書き、移動、削除しない。

一時取得物、仮想環境、ドライラン出力は `.codex-map-work/` と `.venv/` に置き、Gitへ追加しない。具体的な生成、アップロード、検証の手順はGoogle Drive上の最新版Markdownプロトコルを正本とし、このファイルへ重複して転記しない。
