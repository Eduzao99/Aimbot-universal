# 🎯 Roblox Aimbot Script Avançado

## ⚠️ AVISO IMPORTANTE
Este script é **apenas para fins educacionais** e para demonstrar conceitos de programação em Lua para Roblox. O uso de scripts de aimbot pode violar os termos de serviço do Roblox e resultar em banimento da conta.

## 📋 Funcionalidades

### 🎮 Funcionalidades Principais
- **Aimbot Inteligente**: Sistema de mira automática com detecção avançada de alvos
- **GUI Moderna**: Interface gráfica completa e intuitiva
- **Múltiplas Configurações**: Mais de 10 opções personalizáveis
- **Sistema de Predição**: Antecipa movimento dos alvos
- **Silent Aim**: Mira sem mover a câmera visualmente
- **Trigger Bot**: Disparo automático quando mira no alvo

### 🔧 Configurações Disponíveis

#### Toggles (Liga/Desliga)
- **Aimbot Enabled**: Liga/desliga o aimbot principal
- **Team Check**: Ignora jogadores da mesma equipe
- **Wall Check**: Verifica se há paredes entre você e o alvo
- **Visible Check**: Só mira em alvos visíveis
- **Prediction**: Prediz movimento do alvo
- **Silent Aim**: Mira sem mover a câmera visualmente
- **Trigger Bot**: Atira automaticamente quando mira no alvo
- **Show FOV**: Mostra círculo do campo de visão
- **Target Highlight**: Destaca o alvo atual

#### Sliders (Valores Ajustáveis)
- **FOV**: Campo de visão do aimbot (10-360 graus)
- **Smoothness**: Suavidade da mira (0 = instantâneo, 1 = muito suave)
- **Max Distance**: Distância máxima para detectar alvos (100-2000 studs)
- **Prediction Strength**: Força da predição de movimento (0-2)

#### Dropdown (Seleção)
- **Target Part**: Parte do corpo para mirar (Head, Torso, HumanoidRootPart)

## 🎮 Controles

### Teclas de Atalho
- **F**: Liga/desliga o aimbot
- **G**: Mostra/esconde círculo FOV
- **H**: Mostra/esconde a GUI

### Interface GUI
- **Arrastar**: Clique e arraste o título da GUI para mover
- **Scroll**: Use a roda do mouse para navegar pelas opções
- **Toggles**: Clique nos botões ON/OFF para ativar/desativar
- **Sliders**: Clique e arraste para ajustar valores
- **Dropdown**: Clique para alternar entre opções

## 🚀 Como Usar

### Método 1: Executor de Scripts
1. Abra seu executor de scripts favorito (Synapse X, KRNL, etc.)
2. Cole o código do arquivo `roblox_aimbot.lua`
3. Execute o script
4. A GUI aparecerá automaticamente

### Método 2: Script Local
1. No Roblox Studio, crie um LocalScript
2. Cole o código do arquivo `roblox_aimbot.lua`
3. Coloque o script em StarterPlayerScripts
4. Execute o jogo

## 🎨 Interface GUI

### Design Moderno
- **Tema Escuro**: Interface elegante com gradientes
- **Cantos Arredondados**: Visual moderno e polido
- **Cores Intuitivas**: Verde para ativado, vermelho para desativado
- **Scrollable**: Lista rolável para todas as opções
- **Responsiva**: Interface que se adapta ao conteúdo

### Organização
- **Categorias Claras**: Toggles, sliders e dropdowns organizados
- **Descrições**: Cada opção tem uma descrição explicativa
- **Valores em Tempo Real**: Veja os valores atuais dos sliders
- **Feedback Visual**: Cores e estados indicam status atual

## ⚙️ Configurações Recomendadas

### Para Iniciantes
```lua
FOV = 80
Smoothness = 0.3
Max Distance = 500
Target Part = "Torso"
Team Check = true
Wall Check = true
```

### Para Usuários Avançados
```lua
FOV = 120
Smoothness = 0.1
Max Distance = 1000
Target Part = "Head"
Prediction = true
Prediction Strength = 0.8
```

### Para Modo Stealth
```lua
FOV = 60
Smoothness = 0.7
Silent Aim = true
Show FOV = false
Target Highlight = false
```

## 🔍 Recursos Técnicos

### Detecção de Alvos
- **Raycast**: Verificação precisa de obstáculos
- **FOV Calculation**: Cálculo matemático do campo de visão
- **Distance Check**: Verificação de distância em tempo real
- **Team Detection**: Sistema inteligente de detecção de equipes

### Sistema de Mira
- **Smooth Aiming**: Transições suaves usando TweenService
- **Prediction Algorithm**: Algoritmo de predição de movimento
- **Silent Aim**: Mira sem alteração visual da câmera
- **Multiple Target Parts**: Suporte para diferentes partes do corpo

### Performance
- **Optimized Loop**: Loop otimizado usando RunService.Heartbeat
- **Memory Management**: Limpeza automática de recursos
- **Error Handling**: Tratamento de erros para estabilidade
- **Cleanup System**: Sistema de limpeza ao sair do jogo

## 🛡️ Recursos de Segurança

### Anti-Detection
- **Smooth Movements**: Movimentos naturais para evitar detecção
- **Configurable Settings**: Configurações ajustáveis para diferentes situações
- **Silent Mode**: Modo silencioso para uso discreto

### Proteções
- **Team Check**: Evita mirar em aliados
- **Wall Check**: Não mira através de paredes
- **Distance Limit**: Limite de distância realista
- **Visibility Check**: Só mira em alvos visíveis

## 🐛 Solução de Problemas

### Problemas Comuns

**GUI não aparece:**
- Verifique se o script está em LocalScript
- Confirme que está executando no cliente
- Pressione H para mostrar/esconder a GUI

**Aimbot não funciona:**
- Verifique se "Aimbot Enabled" está ligado
- Ajuste o FOV para um valor maior
- Desative "Wall Check" temporariamente para testar

**Performance baixa:**
- Reduza o FOV
- Aumente a distância máxima
- Desative "Target Highlight"

## 📝 Notas do Desenvolvedor

### Arquitetura do Código
- **Modular**: Código organizado em funções específicas
- **Configurável**: Todas as configurações em uma tabela central
- **Extensível**: Fácil de adicionar novas funcionalidades
- **Documentado**: Comentários explicativos em todo o código

### Possíveis Melhorias
- Sistema de múltiplos alvos
- Configurações salvam automaticamente
- Mais opções de customização visual
- Sistema de hotkeys personalizáveis
- Modo de treinamento/prática

## ⚖️ Disclaimer Legal

Este script é fornecido "como está" apenas para fins educacionais. O desenvolvedor não se responsabiliza por:
- Banimentos de conta
- Violações dos termos de serviço
- Uso inadequado do script
- Consequências do uso em jogos online

**Use por sua própria conta e risco.**

## 🤝 Contribuições

Sinta-se livre para:
- Reportar bugs
- Sugerir melhorias
- Contribuir com código
- Compartilhar configurações otimizadas

---

**Desenvolvido para fins educacionais | Use com responsabilidade**
    
