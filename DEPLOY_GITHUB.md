# GitHub 部署适配指南

## 1. 仓库准备（必须）

- 推送前确认未提交真实密钥：`application-local.yml`、`.env`、私有 SQL 备份。
- 仓库已提供以下安全文件：
  - 根忽略规则：`.gitignore`
  - CI 工作流：`.github/workflows/ci.yml`
  - 示例变量文件：`backend/.env.example`、`user/.env.example`、`admin/.env.example`

## 2. GitHub 仓库 Variables / Secrets

后端需要的环境变量（部署平台或自托管机器）：

- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `JWT_SECRET`
- `AI_API_KEY`（可选，仅系统 Key 模式需要）

前端构建变量（`user` / `admin`）：

- `VITE_API_BASE_URL`（例如 `https://api.your-domain.com`）

## 3. GitHub Actions CI

本项目已配置 CI（见 `.github/workflows/ci.yml`），会自动执行：

- `backend`：`mvn -B -DskipTests package`
- `user`：`npm ci && npm run build`
- `admin`：`npm ci && npm run build`

## 4. 推荐部署拓扑

- 后端：Railway / Render / ECS / 云主机（通过环境变量注入密钥）
- 前端：Vercel / Netlify / Nginx 静态托管
- 两个前端都配置 `VITE_API_BASE_URL` 指向后端域名

## 5. 首次上线核对清单

- 已轮换历史可能泄露的密钥（尤其 AI Key、JWT Secret、数据库密码）
- 后端 `/api/health` 可访问，业务接口可登录
- `user` 与 `admin` 页面都能正常调用后端接口
- 浏览器 Network 中无明文密钥暴露

## 6. Railway 后端部署（新增）

- 在 Railway 新建项目并连接本仓库。
- 将 `Root Directory` 设置为 `backend`（非常关键，当前仓库是多目录结构）。
- Railway 会自动读取 `backend/railway.json` 执行构建与启动。
- 在 Railway Variables 中配置：
  - `DB_URL`
  - `DB_USERNAME`
  - `DB_PASSWORD`
  - `JWT_SECRET`
  - `AI_API_KEY`（可选）
- `PORT` 由 Railway 自动注入，无需手动设置；后端已适配 `server.port=${PORT:8080}`。
- 部署完成后访问 `<你的后端域名>/api/health` 验证服务状态。
