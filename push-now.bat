@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
REM ====== 一键同步推送（放在仓库根目录双击运行） ======
pushd "%~dp0"

REM 0) 自检：是否是 Git 仓库
if not exist ".git" (
  echo [ERROR] 当前目录不是 Git 仓库：%cd%
  echo 请把本文件放到你的仓库根目录再运行。
  goto :END
)

REM 1) 寻找 git.exe
set "GIT=git"
where git >nul 2>nul || (
  if exist "%ProgramFiles%\Git\cmd\git.exe" set "GIT=%ProgramFiles%\Git\cmd\git.exe"
  if exist "%ProgramFiles(x86)%\Git\cmd\git.exe" set "GIT=%ProgramFiles(x86)%\Git\cmd\git.exe"
  if exist "%LocalAppData%\Programs\Git\cmd\git.exe" set "GIT=%LocalAppData%\Programs\Git\cmd\git.exe"
)
"%GIT%" --version >nul 2>&1 || (
  echo [ERROR] 未找到 git。请安装 Git for Windows 并勾选 "Add to PATH"。
  goto :END
)

REM 2) 日志
set "LOG=%cd%\_push.log"
echo === %date% %time% === >> "%LOG%"

REM 3) 先 fetch 看 ahead/behind
"%GIT%" fetch origin main >> "%LOG%" 2>&1

set AHEAD=0
set BEHIND=0
for /f "tokens=1,2" %%a in ('"%GIT%" rev-list --left-right --count HEAD...origin/main') do (
  set AHEAD=%%a
  set BEHIND=%%b
)
echo [INFO] ahead=%AHEAD% behind=%BEHIND% >> "%LOG%"

REM 4) 如果落后远端，先拉取（带 rebase/autostash）
if %BEHIND% GTR 0 (
  echo Pulling %BEHIND% upstream commit(s)...
  "%GIT%" pull --rebase --autostash origin main >> "%LOG%" 2>&1
  if errorlevel 1 (
    echo [ERROR] pull 失败（可能有冲突）。请在窗口中运行：
    echo     git status
    echo     git rebase --continue  或  git rebase --abort
    goto :END
  )
)

REM 5) 是否存在工作区改动
set HAS_CHANGES=
for /f "delims=" %%s in ('"%GIT%" status --porcelain') do set HAS_CHANGES=1

if defined HAS_CHANGES (
  "%GIT%" add -A >> "%LOG%" 2>&1
  for /f "tokens=1-3 delims=/- " %%a in ("%date%") do set TODAY=%%a-%%b-%%c
  set "MSG=auto: %TODAY% %time%"
  "%GIT%" commit -m "%MSG%" >> "%LOG%" 2>&1
  "%GIT%" push >> "%LOG%" 2>&1
  echo Done. (changes committed and pushed)
  goto :END
)

if %AHEAD% GTR 0 (
  echo Pushing %AHEAD% local commit(s)...
  "%GIT%" push >> "%LOG%" 2>&1
  echo Done. (unpushed commits pushed)
  goto :END
)

if %BEHIND% GTR 0 (
  echo Pulled %BEHIND% commit(s) from remote. Nothing to push.
) else (
  echo Up to date. Nothing to do.
)

:END
echo.
echo 按任意键关闭窗口...
pause >nul
popd
endlocal
