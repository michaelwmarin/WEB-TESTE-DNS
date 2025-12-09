import streamlit as st
import dns.resolver
import time
import pandas as pd

# --- Configuração da Página ---
st.set_page_config(page_title="DNS Tool", page_icon="📡", layout="wide")

# --- ESTILOS CSS ---
st.markdown("""
<style>
    .stApp { background-color: #0e1117; }
    
    .custom-card {
        background-color: #1e1e1e;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
        margin-bottom: 20px;
    }
    
    .card-orange { border-left: 5px solid #ff9800; }
    .card-blue { border-left: 5px solid #00d2ff; }
    .card-green { border-left: 5px solid #4caf50; }
    .card-purple { border-left: 5px solid #9c27b0; }
    
    .card-label { font-size: 14px; color: #b0b0b0; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 5px; }
    .card-value { font-size: 22px; font-weight: bold; color: white; }
    
    .stButton>button { width: 100%; border-radius: 8px; font-weight: bold; height: 50px; }
</style>
""", unsafe_allow_html=True)

# --- Cabeçalho ---
st.title("📡 DNS Monitor")
st.markdown("##### Painel de Diagnóstico e Performance de Rede")
st.markdown("---")

# --- ESTRUTURA DE DADOS ---
DADOS_DNS = {
    "Muvnet": {
        "IPv4": {"Primário": "168.197.24.20", "Secundário": "168.197.24.22"},
        "IPv6": {"Primário": "2804:34b8:4000:53::1", "Secundário": "2804:34b8:8000:53::2"}
    },
    "Google": {
        "IPv4": {"Primário": "8.8.8.8", "Secundário": "8.8.4.4"},
        "IPv6": {"Primário": "2001:4860:4860::8888", "Secundário": "2001:4860:4860::8844"}
    },
    "Cloudflare": {
        "IPv4": {"Primário": "1.1.1.1", "Secundário": "1.0.0.1"},
        "IPv6": {"Primário": "2606:4700:4700::1111", "Secundário": "2606:4700:4700::1001"}
    }
}

SITES = {
    "Google": "google.com", "YouTube": "youtube.com", "Facebook": "facebook.com",
    "Instagram": "instagram.com", "WhatsApp": "whatsapp.com", "Amazon": "amazon.com",
    "Microsoft": "microsoft.com", "Netflix": "netflix.com", "Wikipedia": "wikipedia.org",
    "Cloudflare": "cloudflare.com", "Globo.com": "globo.com", "UOL": "uol.com.br",
    "Mercado Livre": "mercadolivre.com.br", "Gov.br": "gov.br", "Caixa": "caixa.gov.br",
    "BB": "bb.com.br", "Correios": "correios.com.br", "Terra": "terra.com.br",
    "R7": "r7.com", "Estadão": "estadao.com.br"
}

# --- Função de Teste (Atualizada para aceitar o Tipo de Registro) ---
def testar_dns(servidor_ip, site, tipo_registro):
    resolver = dns.resolver.Resolver(configure=False)
    resolver.nameservers = [servidor_ip]
    resolver.lifetime = 2.0 
    
    inicio = time.time()
    try:
        # Busca 'A' (IPv4) ou 'AAAA' (IPv6) dependendo do que foi pedido
        resposta = resolver.resolve(site, tipo_registro, raise_on_no_answer=False)
        fim = time.time()
        tempo_ms = (fim - inicio) * 1000
        
        # Pega o IP retornado (pode ser v4 ou v6)
        ip_resolvido = str(resposta[0]) if resposta else "---"
        return True, tempo_ms, ip_resolvido
    except Exception as e:
        # Se der erro (ex: site não tem IPv6), retorna falso
        return False, 0, str(e) if "Time" in str(e) else "---"

# --- MENU LATERAL ---
with st.sidebar:
    st.header("⚙️ Configurações")
    empresa_sel = st.selectbox("1. Provedor", list(DADOS_DNS.keys()))
    proto_sel = st.selectbox("2. Protocolo", list(DADOS_DNS[empresa_sel].keys()))
    tipo_sel = st.radio("3. Tipo", list(DADOS_DNS[empresa_sel][proto_sel].keys()), horizontal=True)
    
    ip_alvo = DADOS_DNS[empresa_sel][proto_sel][tipo_sel]
    
    st.divider()
    modo_teste = st.radio("Modo de Teste", ["Carga Completa (20 Sites)", "Site Único", "Manual"])
    
    if modo_teste == "Carga Completa (20 Sites)":
        lista_final = list(SITES.items())
    elif modo_teste == "Site Único":
        nome_selecionado = st.selectbox("Site", list(SITES.keys()))
        lista_final = [(nome_selecionado, SITES[nome_selecionado])]
    else:
        input_manual = st.text_input("Domínio", "terra.com.br")
        lista_final = [(input_manual, input_manual)]
        
    st.divider()
    btn_iniciar = st.button("🚀 INICIAR DIAGNÓSTICO", type="primary")

# --- ÁREA PRINCIPAL ---
c1, c2, c3 = st.columns(3)
with c1:
    st.markdown(f"""<div class="custom-card card-orange"><div class="card-label">🏢 Provedor</div><div class="card-value">{empresa_sel}</div></div>""", unsafe_allow_html=True)
with c2:
    st.markdown(f"""<div class="custom-card card-blue"><div class="card-label">🌐 Protocolo</div><div class="card-value">{proto_sel} - {tipo_sel}</div></div>""", unsafe_allow_html=True)
with c3:
    st.markdown(f"""<div class="custom-card card-green"><div class="card-label">🔌 IP do Servidor</div><div class="card-value">{ip_alvo}</div></div>""", unsafe_allow_html=True)

# --- Lógica de Execução ---
if 'rodou' not in st.session_state: st.session_state.rodou = False
if btn_iniciar: st.session_state.rodou = True

if st.session_state.rodou:
    
    progresso = st.progress(0)
    status_container = st.status("Executando testes...", expanded=True)
    resultados = []
    
    # Define qual registro buscar baseado na escolha do menu
    # Se escolheu IPv6, busca 'AAAA'. Se IPv4, busca 'A'.
    registro_dns = 'AAAA' if proto_sel == 'IPv6' else 'A'
    
    for i, (nome_amigavel, dominio) in enumerate(lista_final):
        status_container.write(f"🔎 Resolvendo **{nome_amigavel}** ({registro_dns})...")
        
        # Chama a função passando o tipo de registro
        ok, ms, ip_retornado = testar_dns(ip_alvo, dominio, registro_dns)
        
        status_icon = "✅" if ok else "❌"
        lat_display = f"{ms:.2f} ms" if ok else "---"
        
        # Classificação visual
        lat_resumo = 0
        if ok:
            lat_resumo = ms
            if ms < 50: lat_icon = "🟢"
            elif ms < 150: lat_icon = "🟡"
            else: lat_icon = "🔴"
        else:
            lat_icon = "🔻"
            
        resultados.append({
            "Site": nome_amigavel,
            "Status": status_icon,
            "Latência Visual": f"{lat_icon} {lat_display}",
            "Latência (ms)": lat_resumo,
            "IP Retornado": ip_retornado
        })
        
        progresso.progress((i + 1) / len(lista_final))
        time.sleep(0.02)

    status_container.update(label="✅ Diagnóstico Concluído!", state="complete", expanded=False)
    
    # Exibe Tabela
    df = pd.DataFrame(resultados)
    
    # Ajuste na exibição do título da coluna IP
    titulo_coluna_ip = f"IP Retornado ({registro_dns})"
    df_exibicao = df.rename(columns={"IP Retornado": titulo_coluna_ip})
    
    st.dataframe(
        df_exibicao[["Site", "Status", "Latência Visual", titulo_coluna_ip]], 
        use_container_width=True,
        column_config={
            "Site": st.column_config.TextColumn("Site", width="medium"),
            titulo_coluna_ip: st.column_config.TextColumn(titulo_coluna_ip, width="large"),
        }
    )
    
    # --- RESUMO ---
    st.markdown("### 📊 Relatório Final")
    sucessos = df[df["Status"] == "✅"].shape[0]
    media_latencia = df[df["Status"] == "✅"]["Latência (ms)"].mean()
    if pd.isna(media_latencia): media_latencia = 0
    
    rc1, rc2, rc3 = st.columns(3)
    with rc1:
        st.markdown(f"""<div class="custom-card card-purple"><div class="card-label">📊 Taxa de Sucesso</div><div class="card-value">{sucessos} / {len(lista_final)}</div></div>""", unsafe_allow_html=True)
    with rc2:
        cor_media = "green" if media_latencia < 100 else "orange" if media_latencia < 200 else "red"
        st.markdown(f"""<div class="custom-card" style="border-left: 5px solid {cor_media};"><div class="card-label">⚡ Latência Média</div><div class="card-value">{media_latencia:.2f} ms</div></div>""", unsafe_allow_html=True)
    with rc3:
        st.markdown('<div style="height: 10px;"></div>', unsafe_allow_html=True)
        csv = df.to_csv(index=False).encode('utf-8')
        st.download_button("📥 Baixar CSV", csv, f"dns_{proto_sel}_report.csv", "text/csv", use_container_width=True)
        if st.button("⬅️ Limpar"):
            st.session_state.rodou = False
            st.rerun()

else:
    st.info("👈 Selecione as opções no menu lateral para começar.")

st.markdown("<br><br>", unsafe_allow_html=True)
st.caption("Desenvolvido por Michael Marin | Support Tools")