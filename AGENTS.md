# Blog 项目规则

- 不允许擅自执行 `hexo deploy`（`hexo d`）。它会把 `public/` 强制推送到 GitHub Pages 的线上仓库，属于对外发布，必须先得到用户明确授权。`hexo generate` 和本地预览不受限制。
- sitemap 排序不稳定。如果 `public` 下的 sitemap 跟 `.deploy_git` 下的相比没有实质性更改，就直接设为 `.deploy_git` 下的，以免后续 `hexo d` 引入不必要的 diff。如果有实质性更改，也尽量消掉不必要的 diff，只留下实质性更改。
- `updated` 只在文章被重新处理时才会从 git 刷新，commit 之后直接 `hexo g` 不会更新（`touch` 和 `hexo g --force` 也无效）。如果发现一篇文章的 `updated` 没更新，就从 `db.json` 的 `models.Cache` 删掉该文件的条目、`models.Post` 删掉对应记录再 `hexo g`，不用征求用户同意。
