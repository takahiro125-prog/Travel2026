# Codex repository instructions

## Travel2026旅行地図

正本のGoogle Driveプロトコルフォルダは `https://drive.google.com/drive/folders/1XdyXOVDOaXGHo20x8DTsNEs0CWJFdtSD`、Google Sheetsは `https://docs.google.com/spreadsheets/d/1ecSx5D36tAQcqp3wvGjBQIxAA3_gYdFdikZihq2kKTs/edit` とする。

Travel2026旅行地図を作成、再生成、または旅程データから更新する場合は、Google Drive上の指定プロトコルフォルダを一覧取得し、最新版のMarkdownと独立Pythonを取得する。

生成を伴う場合は、Google Sheetsを指定URLから最新XLSXとして取得する。以前取得したXLSX、プロトコル、Python、Drive一覧を正本として再利用しない。

地図の生成は、Driveから取得した最新版Markdownプロトコルに従う。

独立した `generate_2026_roadtrip_html_maps.py` を実行コードの正本とする。Markdown内コードと実質的に不一致の場合は作業を停止する。

`index.html` はダミーページであり、変更、削除、旅行地図へのリンク追加、目次ページへの置換を禁止する。

生成時に必要なファイルが作られなかった場合はcommitまたはpushを行わない。

旅行地図以外の既存ファイルを変更または削除しない。

`index.html` は作業対象に含めず、Google Drive上の正本ファイルとGoogle Sheetsは読み取り専用として扱い、編集、上書き、移動、削除しない。

一時取得物、仮想環境、ドライラン出力は `.codex-map-work/` と `.venv/` に置き、Gitへ追加しない。具体的な生成手順はGoogle Drive上の最新版Markdownプロトコルを正本とし、このファイルへ重複して転記しない。

## 生成済み地図の軽量公開

ユーザーが「アップロードだけ」「公開だけ」「後半だけ」「Driveの生成済みHTMLをGitHubへ反映して」など、生成済み成果物の公開だけを明示した場合は、軽量公開モードを使う。

軽量公開モードでは、Google Sheets、プロトコル、独立Pythonを取得せず、地図を再生成しない。指定されたGoogle Driveフォルダから生成済みの公開成果物を新しく取得し、旅行地図の公開対象ファイルだけをGitHubへcommit、通常pushする。

ローカルGoogle Driveが `G:\マイドライブ\private\Trip2026\website` にマウントされている場合は、`.agents/skills/travel-map-update/scripts/publish_from_local_gdrive.ps1` を使う。この経路ではGoogle Drive connectorを使わない。

軽量公開モードでは、SHA-256照合、MarkdownとPythonの照合、ZIP展開、HTML内容検査、全ページHTTP確認、Driveへの再アップロードと読み戻しを行わない。ファイルの取得失敗、Git競合、push失敗など、公開操作そのものを完了できないエラーだけを停止条件とする。

軽量公開モードでも `index.html` と旅行地図以外のファイルは変更しない。`git add -A` とforce pushは使わない。

## 旅行地図更新スキル

ユーザーが旅行地図の作成、更新、再生成、公開、アップロードを依頼した場合は、Remote経由の短い指示を含め、リポジトリスキル `$travel-map-update` を使用する。依頼文に従って完全更新モードまたは軽量公開モードを選ぶ。`index.html` は引き続き保護対象であり、変更しない。
