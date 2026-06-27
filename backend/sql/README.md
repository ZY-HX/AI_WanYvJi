# 第一阶段：数据库初始化模块

本目录对应需求文档中的第一阶段交付物，包含：

- `ddl.sql`：完整数据库建表脚本
- `init_data.sql`：初始化测试数据脚本

## 导入顺序

1. 执行 `ddl.sql`
2. 执行 `init_data.sql`

数据库名统一为 `english_learning_mate`，字符集使用 `utf8mb4`，引擎使用 `InnoDB`。

## 设计约定

- 所有删除操作统一走软删除，使用 `status` 字段表示启用/删除状态
- `word_bank.is_public` 使用三态：`0-私有`、`1-待审核`、`2-已公开`
- 全面弃用物理外键，统一采用逻辑外键，方便后续扩展
- 高频更新表 `user`、`word_bank` 使用 `version` 字段支持乐观锁
- 密码字段使用 BCrypt 哈希保存
- 所有时间字段使用 `datetime`

## 表关系说明

| 主表 | 关联字段 | 从表 | 关系说明 |
| --- | --- | --- | --- |
| `user` | `id` | `word_bank.user_id` | 一个用户可创建多个词库 |
| `word_bank` | `id` | `word.word_bank_id` | 一个词库包含多个单词 |
| `user` | `id` | `user_study_record.user_id` | 一个用户有多条学习记录 |
| `word_bank` | `id` | `user_study_record.word_bank_id` | 学习记录归属某个词库 |
| `word` | `id` | `user_study_record.word_id` | 学习记录对应具体单词 |
| `user` | `id` | `error_book.user_id` | 一个用户有多条错题记录 |
| `word` | `id` | `error_book.word_id` | 错题记录对应具体单词 |
| `user` | `id` | `ai_article_log.user_id` | 一个用户可生成多篇 AI 文章 |
| `word_bank` | `id` | `ai_article_log.word_bank_id` | AI 文章可关联词库 |
| `user` | `id` | `user_quota.user_id` | 一个用户可有多种配额 |
| `user` | `id` | `word_bank_collect.user_id` | 用户可收藏多个词库 |
| `word_bank` | `id` | `word_bank_collect.word_bank_id` | 一个词库可被多个用户收藏 |
| `user` | `id` | `notification.user_id` | 用户接收站内消息，`0` 表示全站消息 |
| `user` | `id` | `operation_log.admin_id` | 管理员拥有多条操作日志 |

## 初始化数据说明

- 账号初始化：
  - `admin / admin123`
  - `user1 / 123456`
  - `user2 / 123456`
- 已初始化 3 个内置词库：四级、六级、考研
- 已初始化 3 个自定义词库：计算机专业词汇、日常英语词汇、商务英语词汇
- 已初始化学习记录、错题记录、配额、收藏、通知、操作日志等联调用示例数据

## 当前边界

需求文档中要求内置词库包含完整四级、六级、考研词表，但当前仓库未提供可直接导入的词表原始文件。
因此本阶段脚本先提供：

- 完整词库表结构
- 内置词库元数据
- 可用于联调的示例单词数据

后续只需补充批量导入脚本或原始词表文件，即可继续扩展到完整词量，不影响现有表结构。
