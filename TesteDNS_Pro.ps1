# --- CONFIGURAÇÃO DE ACENTOS E EMOJIS (UTF-8) ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8

# --- Definição dos Servidores DNS ---
# MUVNET
$Muvnet_v4_Pri = "168.197.24.20";       $Muvnet_v4_Sec = "168.197.24.22"
$Muvnet_v6_Pri = "2804:34B8:4000:53::1"; $Muvnet_v6_Sec = "2804:34B8:8000:53::2"

# EXTERNOS (Para comparação)
$Google_v4_Pri = "8.8.8.8";     $Google_v4_Sec = "8.8.4.4"
$Google_v6_Pri = "2001:4860:4860::8888"; $Google_v6_Sec = "2001:4860:4860::8844"
$Cloud_v4_Pri  = "1.1.1.1";     $Cloud_v4_Sec  = "1.0.0.1"
$Cloud_v6_Pri  = "2606:4700:4700::1111"; $Cloud_v6_Sec  = "2606:4700:4700::1001"

# --- Lista de Sites para Teste ---
$ListaSites = @(
    "google.com", "youtube.com", "facebook.com", "instagram.com", "whatsapp.com",
    "amazon.com", "microsoft.com", "netflix.com", "wikipedia.org", "cloudflare.com",
    "globo.com", "uol.com.br", "mercadolivre.com.br", "gov.br", "caixa.gov.br",
    "bb.com.br", "correios.com.br", "terra.com.br", "r7.com", "estadao.com.br"
)

# --- Função de Cabeçalho (COM ARTE!) ---
function Cabecalho {
    Clear-Host
    # ASCII Art da MUVNET (Rede/Conexão)
    Write-Host "      .---." -ForegroundColor Cyan
    Write-Host "     /   /|" -ForegroundColor Cyan
    Write-Host "    .---. |" -ForegroundColor Cyan
    Write-Host "    |   | ' .---." -ForegroundColor Cyan
    Write-Host "    |   |/ /   /|" -ForegroundColor Cyan
    Write-Host "    '---' .---. |   M U V N E T" -ForegroundColor Cyan
    Write-Host "          |   | '   DNS TOOL PRO" -ForegroundColor Cyan
    Write-Host "          |   |/ " -ForegroundColor Cyan
    Write-Host "          '---'" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "======================================================" -ForegroundColor DarkGray
    Write-Host "Servidores Configurados:" -ForegroundColor Gray
    Write-Host "IPv4: $Muvnet_v4_Pri | $Muvnet_v4_Sec"
    Write-Host "IPv6: $Muvnet_v6_Pri | $Muvnet_v6_Sec"
    Write-Host "------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

# --- Função Auxiliar: Escolher Sites ---
function Obter-Sites-Para-Teste {
    Write-Host "Como deseja testar?" -ForegroundColor Cyan
    Write-Host "[1] Testar TODOS os 20 sites (Carga Completa)"
    Write-Host "[2] Escolher um site específico da lista"
    Write-Host "[3] Digitar um site manualmente"
    Write-Host ""
    
    $modoTeste = Read-Host "Opção"
    Write-Host ""

    if ($modoTeste -eq '1') { return $ListaSites }
    elseif ($modoTeste -eq '2') {
        Write-Host "--- Lista de Sites ---" -ForegroundColor Gray
        for ($i=0; $i -lt $ListaSites.Count; $i++) {
            Write-Host ("[{0:D2}] {1}" -f ($i+1), $ListaSites[$i])
        }
        Write-Host ""
        $id = Read-Host "Digite o número do site"
        try {
            $index = [int]$id - 1
            if ($index -ge 0 -and $index -lt $ListaSites.Count) { return @($ListaSites[$index]) }
        } catch {}
        Write-Host "Inválido. Usando Google." -ForegroundColor Red; return @("google.com")
    }
    elseif ($modoTeste -eq '3') {
        $manual = Read-Host "Digite o endereço (ex: terra.com.br)"; return @($manual)
    }
    else { return $ListaSites }
}

# --- Função de Teste ---
function Executar-Teste ($ip, $tipo, $sites) {
    Write-Host "------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "⏳ Conectando ao servidor: $tipo ($ip)" -ForegroundColor Yellow
    Write-Host ""

    # 1. Ping
    Write-Host "Checando conectividade... " -NoNewline
    try {
        $ping = Test-Connection -ComputerName $ip -Count 1 -ErrorAction Stop
        Write-Host "ONLINE ✅" -ForegroundColor Green
    }
    catch {
        Write-Host "OFFLINE ❌ (Abortando testes)" -ForegroundColor Red
        return 
    }
    Write-Host ""

    # 2. DNS
    $sucessos = 0
    $falhas = 0
    
    Write-Host ("{0,-20} | {1,-6} | {2,-9} | {3,-15} | {4}" -f "SITE", "STATUS", "TEMPO", "IPv4", "IPv6") -ForegroundColor Gray
    Write-Host "------------------------------------------------------------------------------------" -ForegroundColor DarkGray

    foreach ($site in $sites) {
        $resultado = $null
        try {
            $tempo = Measure-Command { 
                $resultado = Resolve-DnsName -Name $site -Server $ip -ErrorAction Stop 
            }
            $ms = [math]::Round($tempo.TotalMilliseconds, 2)
            
            # Filtro IPv4
            $recIPv4 = $resultado | Where-Object { $_.Type -eq 'A' }
            if ($recIPv4) {
                 if ($recIPv4 -is [array]) { $txtIPv4 = $recIPv4[0].IPAddress } else { $txtIPv4 = $recIPv4.IPAddress }
            } else { $txtIPv4 = "---" }

            # Filtro IPv6
            $recIPv6 = $resultado | Where-Object { $_.Type -eq 'AAAA' }
            if ($recIPv6) {
                 if ($recIPv6 -is [array]) { $txtIPv6 = $recIPv6[0].IP6Address } else { $txtIPv6 = $recIPv6.IP6Address }
            } else { $txtIPv6 = "---" }

            # Cores
            if ($ms -lt 50) { $corTempo = "Green" } elseif ($ms -lt 150) { $corTempo = "Yellow" } else { $corTempo = "Red" }
            
            Write-Host ("{0,-20} | " -f $site) -NoNewline
            Write-Host "OK ✅  | " -NoNewline -ForegroundColor Green
            Write-Host ("{0,-9} | " -f "$ms ms") -NoNewline -ForegroundColor $corTempo
            Write-Host ("{0,-15} | " -f $txtIPv4) -NoNewline -ForegroundColor Gray
            Write-Host $txtIPv6 -ForegroundColor DarkGray
            $sucessos++
        }
        catch {
            Write-Host ("{0,-20} | " -f $site) -NoNewline
            Write-Host "FALHA ❌ | " -NoNewline -ForegroundColor Red
            Write-Host "---       | ---             | ---" 
            $falhas++
        }
    }
    Write-Host ""
    Write-Host "RESUMO: $sucessos Sucessos / $falhas Falhas" -ForegroundColor Cyan
    Write-Host ""
}

# --- LOOP PRINCIPAL ---
do {
    Cabecalho

    Write-Host "Escolha o SERVIDOR para testar:" -ForegroundColor Yellow
    Write-Host "[1] MUVNET IPv4 (Interno)"
    Write-Host "[2] MUVNET IPv6 (Interno)"
    Write-Host "---------------------------" -ForegroundColor DarkGray
    Write-Host "[3] GOOGLE IPv4 (8.8.8.8 / 8.8.4.4)"
    Write-Host "[4] GOOGLE IPv6 (2001:4860:4860::8888 / 2001:4860:4860::8844)"
    Write-Host "---------------------------" -ForegroundColor DarkGray
    Write-Host "[5] CLOUDFLARE IPv4 (1.1.1.1 / 1.0.0.1)"
    Write-Host "[6] CLOUDFLARE IPv6 (2606:4700:4700::1111 /2606:4700:4700::1001)"
    Write-Host ""
    Write-Host "[0] Sair" -ForegroundColor Gray
    Write-Host ""

    $escolha = Read-Host "Digite a opção"
    Write-Host ""

    if ($escolha -in '1','2','3','4','5','6') {
        $meusSites = Obter-Sites-Para-Teste
    }

    switch ($escolha) {
        '1' { 
            Executar-Teste $Muvnet_v4_Pri "MUVNET v4 Pri" $meusSites
            Executar-Teste $Muvnet_v4_Sec "MUVNET v4 Sec" $meusSites
            Pause
        }
        '2' { 
            Executar-Teste $Muvnet_v6_Pri "MUVNET v6 Pri" $meusSites
            Executar-Teste $Muvnet_v6_Sec "MUVNET v6 Sec" $meusSites
            Pause
        }
        '3' { 
            Executar-Teste $Google_v4_Pri "GOOGLE v4 Pri" $meusSites
            Executar-Teste $Google_v4_Sec "GOOGLE v4 Sec" $meusSites
            Pause
        }
        '4' { 
            Executar-Teste $Google_v6_Pri "GOOGLE v6 Pri" $meusSites
            Executar-Teste $Google_v6_Sec "GOOGLE v6 Sec" $meusSites
            Pause
        }
        '5' { 
            Executar-Teste $Cloud_v4_Pri "CLOUDFLARE v4 Pri" $meusSites
            Executar-Teste $Cloud_v4_Sec "CLOUDFLARE v4 Sec" $meusSites
            Pause
        }
        '6' { 
            Executar-Teste $Cloud_v6_Pri "CLOUDFLARE v6 Pri" $meusSites
            Executar-Teste $Cloud_v6_Sec "CLOUDFLARE v6 Sec" $meusSites
            Pause
        }
        '0' { 
            Write-Host "Saindo... Até mais! 👋" -ForegroundColor Cyan
            Start-Sleep -Seconds 1
        }
        default { 
            Write-Host "Opção inválida!" -ForegroundColor Red; Start-Sleep -Seconds 1 
        }
    }

} until ($escolha -eq '0')