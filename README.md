# Social Sales Dashboard - GitHub Pages Preview

이 폴더는 외부 공유용 GitHub Pages 정적 페이지입니다.

실제 로컬 대시보드는 `dashboard.py`, Claude CLI, Codex CLI, Chrome CDP를 사용하므로 GitHub Pages에서 직접 실행되지 않습니다.

GitHub Pages는 로컬 `http://127.0.0.1:8765`에서 생성하고 저장한 `drafts.json`과 이미지 파일을 복사해서 보여주는 보기 전용 스냅샷입니다.

## 배포

로컬 대시보드에서 콘텐츠를 생성하고 저장한 뒤, GitHub CLI 로그인 상태에서 아래 스크립트를 실행합니다.

```powershell
cd "C:\Users\khcho\Documents\2.회계감사 _제안서\GPT_작업폴더\social_sales_dashboard\github_pages"
gh auth login
.\publish_to_github_pages.ps1
```

스크립트는 먼저 `sync_local_to_pages.py`를 실행해 다음 파일을 갱신합니다.

- `preview-data.js`: 로컬 `drafts.json` 복사본
- `assets/`: 로컬 생성 이미지 복사본

기본 저장소 이름은 `social-sales-dashboard-pages`입니다.
