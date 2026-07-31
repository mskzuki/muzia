# Generator-Evaluatorハーネス導入 仕様書

## 文書情報

- 仕様ID: 2607311942
- ステータス: Draft
- 作成日: 2026-07-31
- 更新日: 2026-07-31

## 1. 目的

Generatorが実装した成果物を、独立したEvaluatorが要件・設計・テスト・実行結果に基づいて検証できる開発プロセスを整備する。

評価基準、評価例、スプリント契約をリポジトリ内のMarkdownとして管理し、エージェントが同じ基準を繰り返し参照できるようにする。

## 2. 対象範囲

### 対象

- 共通のEvaluatorルーブリック
- Evaluatorの判定例とフィードバック例
- スプリント契約テンプレート
- GeneratorとEvaluatorが参照する文書の配置と運用ルール

### 対象外

- GeneratorやEvaluatorを実行する自動Driverの実装
- LLMプロバイダーや新しいFlutterパッケージの追加
- 製品要件の変更
- Evaluatorの判定を完全に自動化する仕組み

## 3. 要件

### 機能要件

- [ ] REQ-001: `docs/harness/evaluator-rubric.md`で評価基準を定義する
- [ ] REQ-002: `docs/harness/sprint-contract-template.md`で実装前の完了条件を合意する形式を定義する
- [ ] REQ-003: 評価基準は、対象機能の要件、アーキテクチャ、検証、ファイル安全性を扱う
- [ ] REQ-004: Evaluatorは各基準について判定、根拠、失敗時の具体的な修正内容を返す
- [ ] REQ-005: 各機能の受け入れ条件は、対象機能の`spec.md`とスプリント契約で具体化する

### 非機能要件

- [ ] NFR-001: 評価基準は実装方法を過度に固定せず、観測可能な結果を評価する
- [ ] NFR-002: 評価基準と契約はMarkdownで人間がレビュー・更新できる
- [ ] NFR-003: 製品要件、アーキテクチャ、テスト方針と矛盾しない

## 4. 運用フロー

1. PlannerまたはGeneratorが対象機能のスプリント契約案を作成する
2. Evaluatorが完了条件と検証方法を確認する
3. Generatorが契約に従って実装する
4. Evaluatorが実装、テスト、実行中のアプリを検証する
5. 不合格の場合、Evaluatorが根拠と修正項目を返す
6. Generatorが修正し、Evaluatorが再検証する

## 5. 完了条件

- [ ] 共通ルーブリックとスプリント契約テンプレートが追加されている
- [ ] 文書がAnthropicのGenerator-Evaluator運用（基準、契約、観測、具体的なフィードバック）に対応している
- [ ] `docs/requirements.md`、`docs/architecture.md`、`docs/testing.md`への参照がある
- [ ] 文書内のリンクとMarkdown構文を確認している

## 6. 設計メモ

評価ルーブリックはYAML形式の独自スキーマではなく、Anthropicの公開例に合わせてMarkdownで管理する。評価基準は自然言語で記述し、各基準に合格条件、不合格条件、必要な証拠を持たせる。

自動テストの実行コマンドはEvaluatorの検証手順として記述するが、コマンドの成否だけでUIや要件の充足を判定しない。実行中のアプリの観測結果と、対象機能の受け入れ条件を合わせて判定する。

スプリント契約は`tasks.md`の作業チェックリストを複製せず、対象スプリントでEvaluatorが確認する観測可能な振る舞いと判定方法だけを記述する。実装作業、テスト追加、コマンド実行の進捗は`tasks.md`で管理する。

## 7. 関連文書

- [全体要件](../../requirements.md)
- [アーキテクチャ](../../architecture.md)
- [テスト計画](../../testing.md)
- [Evaluatorルーブリック](../../harness/evaluator-rubric.md)
