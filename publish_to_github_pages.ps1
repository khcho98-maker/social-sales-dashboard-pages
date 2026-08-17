$ErrorActionPreference = "Stop"

$repoName = "social-sales-dashboard-pages"
$branch = "main"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  throw "GitHub CLI(gh)를 찾지 못했습니다. https://cli.github.com/ 에서 설치하세요."
}

gh auth status | Out-Host

if (-not (Test-Path -LiteralPath ".git")) {
  git init
  git branch -M $branch
}

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
  throw "Python을 찾지 못했습니다. 로컬 대시보드 스냅샷을 만들 수 없습니다."
}

python .\sync_local_to_pages.py

git add index.html README.md .nojekyll publish_to_github_pages.ps1 sync_local_to_pages.py preview-data.js assets
git commit -m "Publish local dashboard snapshot to GitHub Pages" 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host "No new commit was created. Continuing with existing files."
}

$owner = gh api user --jq ".login"
$fullName = "$owner/$repoName"

$repoExists = $false
try {
  gh repo view $fullName *> $null
  $repoExists = $true
} catch {
  $repoExists = $false
}

if (-not $repoExists) {
  gh repo create $fullName --public --description "Social sales dashboard GitHub Pages preview"
}

$remoteUrl = "https://github.com/$fullName.git"
if (git remote get-url origin 2>$null) {
  git remote set-url origin $remoteUrl
} else {
  git remote add origin $remoteUrl
}

git push -u origin $branch

try {
  gh api -X POST "repos/$fullName/pages" -f "source[branch]=$branch" -f "source[path]=/" | Out-Null
} catch {
  Write-Host "Pages may already be enabled. Continuing."
}

$ownerName = $fullName.Split("/")[0]
$url = "https://$ownerName.github.io/$repoName/"
Write-Host ""
Write-Host "GitHub Pages URL:"
Write-Host $url
