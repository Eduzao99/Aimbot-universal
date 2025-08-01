# Script de Controle de Câmera 3D por Toque - Godot

Este script implementa controle de rotação para Camera3D usando toque (mobile) e mouse (desktop).

## Como Usar

1. **Anexar o Script:**
   - Adicione uma Camera3D à sua cena
   - Anexe o script `TouchCameraController.gd` à Camera3D
   - O script funcionará automaticamente

2. **Configurações Disponíveis:**
   - `mouse_sensitivity`: Sensibilidade do mouse (padrão: 0.003)
   - `touch_sensitivity`: Sensibilidade do toque (padrão: 0.005)
   - `min_pitch`: Limite mínimo de rotação vertical em radianos (padrão: -1.5)
   - `max_pitch`: Limite máximo de rotação vertical em radianos (padrão: 1.5)

## Funcionalidades

### Mobile (Toque)
- **Arrastar na tela**: Rotaciona a câmera
- **Movimento horizontal**: Rotação horizontal (yaw)
- **Movimento vertical**: Rotação vertical (pitch) com limites

### Desktop (Mouse)
- **Movimento do mouse**: Rotaciona a câmera quando o cursor está capturado
- **ESC**: Alterna entre cursor capturado/livre

## Funções Públicas

```gdscript
# Resetar rotação para posição inicial
reset_rotation()

# Alterar sensibilidade dinamicamente
set_sensitivity(nova_sensibilidade_mouse, nova_sensibilidade_toque)
```

## Exemplo de Configuração no Editor

1. Selecione a Camera3D com o script anexado
2. No Inspector, você verá:
   - Mouse Sensitivity: 0.003
   - Touch Sensitivity: 0.005
   - Min Pitch: -1.5
   - Max Pitch: 1.5

## Personalização

Para personalizar o comportamento, você pode:

1. **Ajustar sensibilidade** no Inspector ou via código
2. **Modificar limites de rotação** para restringir o movimento vertical
3. **Adicionar suavização** modificando a função `apply_rotation()`
4. **Implementar zoom** adicionando detecção de pinch gesture

## Compatibilidade

- **Godot 4.x** (usa sintaxe @export)
- **Mobile e Desktop**
- **Funciona em 2D e 3D**

## Notas Importantes

- O script captura automaticamente o cursor no desktop
- Use ESC para liberar o cursor durante desenvolvimento
- Para mobile, certifique-se de que o projeto está configurado para touch input
- Os limites de pitch previnem rotação completa (evita desorientação)