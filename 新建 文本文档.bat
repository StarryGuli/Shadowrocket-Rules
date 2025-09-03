@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
pushd "%~dp0"

if not exist ".git" (
  echo [ERROR] 这里不是 Git 仓库：%cd%
  pause & exit /b 1
)

set "LOG=%cd%\_push.log"
echo === %date% %time% === >> "%LOG%"

REM 1) 先拉一下，减少冲突
git pull --rebase --autostash origin main >> "%LOG%" 2>&1

REM 2) 无论如何先把改动加入暂存区（防止漏掉新文件）
git add -A

REM 3) 判断暂存区是否有变化（有就提交）
git diff --cached --quiet
if errorlevel 1 (
  for /f "tokens=1-3 delims=/- " %%a in ("%date%") do set TODAY=%%a-%%b-%%c
  set "MSG=auto: %TODAY% %time%"
  git commit -m "%MSG%" >> "%LOG%" 2>&1
) else (
  echo No staged changes. >> "%LOG%"
)

REM 4) 推送（即使刚才没提交也没关系；没有新提交就不会变）
git push >> "%LOG%" 2>&1

echo Done. 查看 _push.log 可看详细记录。
echo.
pause
popd
endlocal
