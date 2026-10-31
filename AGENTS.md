# Blog 项目规则

- 不允许擅自执行 `hexo deploy`（`hexo d`）。它会把 `public/` 强制推送到 GitHub Pages 的线上仓库，属于对外发布，必须先得到用户明确授权。`hexo generate` 和本地预览不受限制。
- sitemap 排序不稳定。如果 `public` 下的 sitemap 跟 `.deploy_git` 下的相比没有实质性更改，就直接设为 `.deploy_git` 下的，以免后续 `hexo d` 引入不必要的 diff。如果有实质性更改，也尽量消掉不必要的 diff，只留下实质性更改。
