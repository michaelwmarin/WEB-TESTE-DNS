@echo off
title Muvnet Dashboard Launcher
echo Iniciando o Servidor Web...
echo Pode minimizar esta janela, mas NAO FECHE.
echo.

:: Entra na pasta onde está o arquivo (garante que acha o app.py)
cd /d "%~dp0"

:: Roda o Streamlit
python -m streamlit run app.py