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

git add index.html README.md .nojekyll publish_to_github_pages.ps1
git commit -m "Publish social sales dashboard GitHub Pages preview" 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host "No new commit was created. Continuing with existing files."
}

$repoExists = $false
try {
  gh repo view $repoName *> $null
  $repoExists = $true
} catch {
  $repoExists = $false
}

if (-not $repoExists) {
  gh repo create $repoName --public --source . --remote origin --push
} else {
  if (-not (git remote get-url origin 2>$null)) {
    $owner = gh api user --jq ".login"
    git remote add origin "https://github.com/$owner/$repoName.git"
  }
  git push -u origin $branch
}

$fullName = gh repo view $repoName --json nameWithOwner --jq ".nameWithOwner"

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
