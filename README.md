# 📡 Muvnet DNS Monitor (Web Dashboard)

Painel de monitoramento e diagnóstico de DNS desenvolvido em **Python** com **Streamlit**.
Ferramenta criada para a equipe de suporte da **Muvnet** visualizar a saúde dos servidores IPv4 e IPv6 em tempo real via navegador.

## 🚀 Funcionalidades

* **Dashboard Visual:** Interface moderna (Dark Mode) com cards de status e métricas.
* **Seleção Inteligente:** Menu hierárquico (Provedor > Protocolo > Servidor).
* **Dual-Stack:** Suporte completo para testes de resolução **IPv4 (A)** e **IPv6 (AAAA)**.
* **Modos de Teste:**
    * 🔄 **Carga Completa:** Testa 20 sites críticos (Bancos, Redes Sociais, Gov).
    * 🎯 **Site Único:** Lista selecionável.
    * ✍️ **Manual:** Teste de qualquer domínio customizado.
* **Relatórios:** Cálculo de latência média e exportação de resultados em **CSV**.

## 📷 Screenshots

### Painel Principal
> *Adicione o print do painel aqui (ex: `![Dashboard](img/dashboard.png)`) com os cards coloridos.*

### Tabela de Resultados
> *Adicione o print da tabela aqui (ex: `![Tabela](img/tabela.png)`).*

## 📋 Pré-requisitos

* Python 3.8 ou superior.
* Navegador Web (Chrome, Edge, Firefox).

## 🔧 Instalação e Uso

1. **Clone o repositório:**
   ```bash
   git clone [https://github.com/SEU-USUARIO/muvnet-dns-web.git](https://github.com/SEU-USUARIO/muvnet-dns-web.git)
   cd muvnet-dns-web
   ````

2.  **Instale as dependências:**

    ```bash
    pip install -r requirements.txt
    ```

3.  **Execute a aplicação:**

    ```bash
    streamlit run app.py
    ```

    *O navegador abrirá automaticamente.*

## ⚡ Atalho Rápido (Windows)

O projeto inclui o arquivo `Iniciar_Painel.bat`. Basta dar dois cliques nele para iniciar o servidor e abrir o navegador automaticamente, sem precisar digitar comandos.

## 🛠️ Tecnologias Utilizadas

  * [Python](https://www.python.org/) - Linguagem Base
  * [Streamlit](https://streamlit.io/) - Framework Web
  * [dnspython](https://www.dnspython.org/) - Resolução de Nomes
  * [Pandas](https://pandas.pydata.org/) - Manipulação de Dados e CSV

## 📝 Autor

Desenvolvido por **Michael Marin**.

```

---

### 🚀 Como subir para o GitHub (Passo a Passo)

Como esse é um projeto diferente, recomendo criar um **NOVO Repositório** no GitHub (chamado tipo `muvnet-dns-web`).

1.  No VS Code, abra a aba do **Source Control** (o ícone de "galho" à esquerda).
2.  Clique em **Initialize Repository** (se ainda não tiver feito).
3.  Escreva a mensagem: "Primeira versão Dashboard Python".
4.  Clique em **Commit**.
5.  Clique em **Publish Branch** (ou Publish to GitHub).
    * Selecione **Public repository**.

Pronto! Agora você tem dois projetos de peso no portfólio: o **CLI em PowerShell** e o **Web App em Python**. 👊
```
